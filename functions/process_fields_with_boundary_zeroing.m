function process_fields_with_boundary_zeroing(varargin)
% PROCESS_FIELDS_WITH_BOUNDARY_ZEROING - Applies boundary zeroing to specific fields
%
% SYNTAX:
%   process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', field_configs)
%   process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', field_configs, 'SaveOutput', true)
%   process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', field_configs, 'BoundaryConfig', boundary_config)
%
% INPUTS:
%   Required Name-Value pairs:
%   'DataDir'       - Path to directory containing field .mat files
%   'Fields'        - Cell array of field configurations, each row contains:
%                     {field_name, boundary_config} or just {field_name}
%                     
%   Optional Name-Value pairs:
%   'SaveOutput'    - Save processed fields (default: false)
%   'PlotResults'   - Generate comparison plots (default: false)
%   'BoundaryConfig'- Default boundary configuration structure with fields:
%                     .width - boundary width (default: 1)
%                     .boundaries - cell array of boundaries (default: {'all'})
%   'OutputSuffix'  - Suffix for output files (default: '_boundary_zero')
%   'PlotSurface'   - Generate surface plots (default: false)
%   'SaveFigs'      - Save generated figures (default: false)
%
% EXAMPLES:
%   % Basic usage - set all boundaries to zero for Temperature and density
%   fields = {'Temperature'; 'density'};
%   process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', fields);
%
%   % Custom boundary configuration for specific fields
%   fields = {
%       'Temperature', struct('width', 2, 'boundaries', {{'top', 'bottom'}});
%       'density', struct('width', 1, 'boundaries', {{'all'}});
%       'CH4', struct('width', 3, 'boundaries', {{'left', 'right'}});
%   };
%   process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', fields, 'SaveOutput', true);
%
%   % Use with existing field processing pipeline
%   bc_config = struct('width', 2, 'boundaries', {{'top', 'bottom'}});
%   combustion_fields = {'CH4'; 'O2'; 'CO2'; 'H2O'; 'Temperature'};
%   process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', combustion_fields, ...
%                                       'BoundaryConfig', bc_config, 'SaveOutput', true, 'PlotResults', true);
%
% INTEGRATION WITH SMOOTHEN_FIELDS:
%   % Process fields with boundary zeroing before or after smoothing
%   % 1. Apply boundary zeroing first
%   process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', field_list, 'SaveOutput', true);
%   % 2. Then apply smoothing to boundary-zeroed fields
%   batch_smooth_fields(data_dir, true, field_list_with_suffix, false, true, false);
%
% See also: set_boundary_to_zero, set_boundary_values, smoothen_fields

% Author: GitHub Copilot Assistant
% Date: September 2025
% Part of MATLAB CFD Post-processing Suite

%% Parse input arguments
p = inputParser;
addParameter(p, 'DataDir', '', @ischar);
addParameter(p, 'Fields', {}, @iscell);
addParameter(p, 'SaveOutput', true, @islogical);
addParameter(p, 'PlotResults', false, @islogical);
addParameter(p, 'PlotSurface', false, @islogical);
addParameter(p, 'SaveFigs', false, @islogical);
addParameter(p, 'OutputSuffix', '_boundary_zero', @ischar);
addParameter(p, 'BoundaryConfig', struct('width', 1, 'boundaries', {{'all'}}), @isstruct);

parse(p, varargin{:});

data_dir = p.Results.DataDir;
field_configs = p.Results.Fields;
save_output = p.Results.SaveOutput;
plot_results = p.Results.PlotResults;
plot_surface = p.Results.PlotSurface;
save_figs = p.Results.SaveFigs;
output_suffix = p.Results.OutputSuffix;
default_boundary_config = p.Results.BoundaryConfig;

%% Validation
if isempty(data_dir)
    error('DataDir must be specified');
end

if isempty(field_configs)
    error('Fields must be specified');
end

if ~exist(data_dir, 'dir')
    error('Data directory %s not found!', data_dir);
end

%% Add necessary paths
addpath(fullfile(pwd, 'functions'));
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');
if exist('~/MATLAB', 'dir')
    addpath('~/MATLAB');
end

%% Load coordinate data
[C_MAT, Z_MAT] = load_coordinate_data(data_dir);
D = 2e-3; % Diameter scale

%% Process field configurations
fprintf('=== Processing Fields with Boundary Zeroing ===\n');
fprintf('Data Directory: %s\n', data_dir);
fprintf('Number of fields to process: %d\n', size(field_configs, 1));

successful_fields = {};
failed_fields = {};

for i = 1:size(field_configs, 1)
    fprintf('\n--- Processing field %d/%d ---\n', i, size(field_configs, 1));
    
    % Parse field configuration
    field_name = field_configs{i, 1};
    
    if size(field_configs, 2) >= 2 && ~isempty(field_configs{i, 2})
        % Custom boundary configuration provided
        boundary_config = field_configs{i, 2};
    else
        % Use default boundary configuration
        boundary_config = default_boundary_config;
    end
    
    try
        % Process individual field
        success = process_single_field(data_dir, field_name, boundary_config, ...
                                     save_output, output_suffix, plot_results, ...
                                     plot_surface, save_figs, C_MAT, Z_MAT, D, i);
        
        if success
            successful_fields{end+1} = field_name;
            fprintf('✓ Successfully processed %s\n', field_name);
        else
            failed_fields{end+1} = field_name;
            fprintf('✗ Failed to process %s\n', field_name);
        end
        
    catch ME
        failed_fields{end+1} = field_name;
        fprintf('✗ Error processing %s: %s\n', field_name, ME.message);
    end
end

%% Summary
fprintf('\n=== Processing Summary ===\n');
fprintf('Total fields processed: %d\n', length(successful_fields) + length(failed_fields));
fprintf('Successful: %d [%s]\n', length(successful_fields), strjoin(successful_fields, ', '));
if ~isempty(failed_fields)
    fprintf('Failed: %d [%s]\n', length(failed_fields), strjoin(failed_fields, ', '));
end

fprintf('\n=== Boundary Zeroing Complete ===\n');
end

function success = process_single_field(data_dir, field_name, boundary_config, ...
                                       save_output, output_suffix, plot_results, ...
                                       plot_surface, save_figs, C_MAT, Z_MAT, D, field_idx)
% Process a single field with boundary zeroing

success = false;

% Define file paths
input_file = sprintf('%s/%s.mat', data_dir, field_name);
output_file = sprintf('%s/%s%s.mat', data_dir, field_name, output_suffix);

% Check if input file exists
if ~exist(input_file, 'file')
    fprintf('  Warning: Input file %s not found\n', input_file);
    return;
end

try
    % Load field data
    fprintf('  Loading %s...\n', field_name);
    data = load(input_file);
    
    if ~isfield(data, 'DF')
        fprintf('  Warning: Field DF not found in %s\n', input_file);
        return;
    end
    
    original_field = data.DF;
    fprintf('  Original field size: %d x %d\n', size(original_field));
    fprintf('  Original field range: [%.6e, %.6e]\n', min(original_field(:)), max(original_field(:)));
    
    % Apply boundary zeroing
    fprintf('  Applying boundary zeroing with config:\n');
    fprintf('    Width: %s\n', mat2str(boundary_config.width));
    fprintf('    Boundaries: %s\n', strjoin(boundary_config.boundaries, ', '));
    
    processed_field = set_boundary_to_zero(original_field, ...
                                          'BoundaryWidth', boundary_config.width, ...
                                          'Boundaries', boundary_config.boundaries);
    
    fprintf('  Processed field range: [%.6e, %.6e]\n', min(processed_field(:)), max(processed_field(:)));
    
    % Create output data structure
    processed_data = data;
    processed_data.DF = processed_field;
    
    % Save processed data
    if save_output
        fprintf('  Saving to %s\n', output_file);
        save(output_file, '-struct', 'processed_data');
    end
    
    % Generate plots
    if plot_results && ~isempty(C_MAT) && ~isempty(Z_MAT)
        plot_boundary_comparison(data_dir, data, processed_data, C_MAT, Z_MAT, D, ...
                               field_name, field_idx, save_figs, boundary_config);
    end
    
    if plot_surface && ~isempty(C_MAT) && ~isempty(Z_MAT)
        plot_surface_field(data_dir, processed_data.DF, C_MAT, Z_MAT, D, ...
                          field_name, field_idx, save_figs);
    end
    
    success = true;
    
catch ME
    fprintf('  Error in process_single_field: %s\n', ME.message);
    success = false;
end
end

function [C_MAT, Z_MAT] = load_coordinate_data(data_dir)
% Load coordinate data from the data directory

coord_file = sprintf('%s/CZ_data.mat', data_dir);
if exist(coord_file, 'file')
    fprintf('Loading coordinate data from %s\n', coord_file);
    coord_data = load(coord_file);
    C_MAT = coord_data.C_MAT;
    Z_MAT = coord_data.Z_MAT;
else
    fprintf('Warning: Coordinate file %s not found. Plots will be skipped.\n', coord_file);
    C_MAT = [];
    Z_MAT = [];
end
end

function plot_boundary_comparison(data_dir, original_data, processed_data, C_MAT, Z_MAT, D, ...
                                field_name, field_idx, save_figs, boundary_config)
% Plot comparison between original and boundary-zeroed data

try
    original_min = min(original_data.DF(:));
    original_max = max(original_data.DF(:));
    
    figure_handle = figure(200 + field_idx);
    set(figure_handle, 'Position', [100 + field_idx*50, 100 + field_idx*30, 1200, 500]);
    
    % Original data
    subplot(1, 2, 1);
    myutils.plot_contourf(figure_handle, C_MAT, Z_MAT/D, original_data.DF, ...
        '$c$', '$z/D$', sprintf('$\\langle %s|c\\rangle$ (Original)', field_name));
    title(sprintf('%s - Original', field_name), 'Interpreter', 'latex');
    pbaspect([1, 2, 1]);
    caxis([original_min, original_max]);
    
    % Boundary-zeroed data
    subplot(1, 2, 2);
    myutils.plot_contourf(figure_handle, C_MAT, Z_MAT/D, processed_data.DF, ...
        '$c$', '$z/D$', sprintf('$\\langle %s|c\\rangle$ (Boundary Zeroed)', field_name));
    title(sprintf('%s - Boundary Zeroed (w=%s, b=%s)', field_name, ...
                 mat2str(boundary_config.width), strjoin(boundary_config.boundaries, ',')), ...
          'Interpreter', 'latex');
    pbaspect([1, 2, 1]);
    caxis([original_min, original_max]);
    
    sgtitle(sprintf('Boundary Zeroing Comparison: %s', field_name), 'FontSize', 14);
    
    % Save comparison plot
    if save_figs
        figdir = 'boundary_zero_figs';
        fig_path = sprintf('%s/%s', data_dir, figdir);
        if ~isfolder(fig_path)
            mkdir(fig_path);
        end
        
        saveas(figure_handle, sprintf('%s/%s_boundary_zero_comparison.png', fig_path, field_name));
        saveas(figure_handle, sprintf('%s/%s_boundary_zero_comparison.fig', fig_path, field_name));
        fprintf('  Saved comparison plot to %s\n', fig_path);
    end
    
catch ME
    fprintf('  Warning: Plot generation failed: %s\n', ME.message);
end
end

function plot_surface_field(data_dir, field_data, C_MAT, Z_MAT, D, field_name, field_idx, save_figs)
% Plot surface representation of the boundary-zeroed field

try
    figure_handle = figure(300 + field_idx);
    set(figure_handle, 'Position', [200 + field_idx*60, 200 + field_idx*40, 800, 600]);
    
    surf(C_MAT, Z_MAT/D, field_data);
    xlabel('$c$', 'Interpreter', 'latex');
    ylabel('$z/D$', 'Interpreter', 'latex');
    zlabel(sprintf('$\\langle %s|c\\rangle$', field_name), 'Interpreter', 'latex');
    title(sprintf('%s - Boundary Zeroed (Surface)', field_name), 'Interpreter', 'latex');
    colorbar;
    shading interp;
    
    % Save surface plot
    if save_figs
        figdir = 'boundary_zero_figs/surfaces';
        fig_path = sprintf('%s/%s', data_dir, figdir);
        if ~isfolder(fig_path)
            mkdir(fig_path);
        end
        
        saveas(figure_handle, sprintf('%s/%s_boundary_zero_surface.png', fig_path, field_name));
        saveas(figure_handle, sprintf('%s/%s_boundary_zero_surface.fig', fig_path, field_name));
        fprintf('  Saved surface plot to %s\n', fig_path);
    end
    
catch ME
    fprintf('  Warning: Surface plot generation failed: %s\n', ME.message);
end
end