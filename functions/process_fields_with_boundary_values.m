function process_fields_with_boundary_values(varargin)
% PROCESS_FIELDS_WITH_BOUNDARY_VALUES - Sets left and right boundaries to specified values for multiple fields
%
% SYNTAX:
%   process_fields_with_boundary_values('DataDir', data_dir, 'Fields', field_configs)
%   process_fields_with_boundary_values('DataDir', data_dir, 'Fields', field_configs, 'SaveOutput', true)
%   process_fields_with_boundary_values('DataDir', data_dir, 'Fields', field_configs, 'PlotResults', true)
%
% INPUTS:
%   Required Name-Value pairs:
%   'DataDir'       - Path to directory containing field .mat files
%   'Fields'        - Cell array of field configurations, each row contains:
%                     {field_name, boundary_struct} where boundary_struct has fields:
%                     .left  - value for left boundary
%                     .right - value for right boundary
%
%   Optional Name-Value pairs:
%   'SaveOutput'    - Save processed fields (default: true)
%   'PlotResults'   - Generate comparison plots using plot_comparison (default: false)
%   'OutputSuffix'  - Suffix for output files (default: '_boundary_set')
%   'BoundaryWidth' - Width of boundary region (default: 1)
%
% EXAMPLES:
%   % Set specific boundary values for Temperature and density
%   fields = {
%       'Temperature', struct('left', 300, 'right', 1500);
%       'density', struct('left', 0.5, 'right', 1.2);
%   };
%   process_fields_with_boundary_values('DataDir', data_dir, 'Fields', fields);
%
%   % With plotting and custom boundary width
%   process_fields_with_boundary_values('DataDir', data_dir, 'Fields', fields, ...
%                                       'PlotResults', true, 'BoundaryWidth', 2);
%
% See also: set_boundary_values, process_fields_with_boundary_zeroing, plot_comparison

% Author: GitHub Copilot Assistant
% Date: September 2025
% Part of MATLAB CFD Post-processing Suite

%% Parse input arguments
p = inputParser;
addParameter(p, 'DataDir', '', @ischar);
addParameter(p, 'Fields', {}, @iscell);
addParameter(p, 'SaveOutput', true, @islogical);
addParameter(p, 'PlotResults', false, @islogical);
addParameter(p, 'OutputSuffix', '_boundary_set', @ischar);
addParameter(p, 'BoundaryWidth', 1, @(x) isnumeric(x) && isscalar(x) && x > 0);

parse(p, varargin{:});

data_dir = p.Results.DataDir;
field_configs = p.Results.Fields;
save_output = p.Results.SaveOutput;
plot_results = p.Results.PlotResults;
output_suffix = p.Results.OutputSuffix;
boundary_width = p.Results.BoundaryWidth;

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

%% Load coordinate data for plotting
[C_MAT, Z_MAT] = load_coordinate_data(data_dir);
D = 2e-3; % Diameter scale

%% Process field configurations
fprintf('=== Processing Fields with Boundary Values ===\n');
fprintf('Data Directory: %s\n', data_dir);
fprintf('Number of fields to process: %d\n', size(field_configs, 1));
fprintf('Boundary width: %d\n', boundary_width);

successful_fields = {};
failed_fields = {};

for i = 1:size(field_configs, 1)
    fprintf('\n--- Processing field %d/%d ---\n', i, size(field_configs, 1));

    % Parse field configuration
    field_name = field_configs{i, 1};
    boundary_struct = field_configs{i, 2};

    % Validate boundary struct
    if ~isstruct(boundary_struct) || ~isfield(boundary_struct, 'left') || ~isfield(boundary_struct, 'right')
        fprintf('  Warning: Invalid boundary struct for %s, skipping\n', field_name);
        failed_fields{end+1} = field_name;
        continue;
    end

    try
        % Process individual field
        success = process_single_field_with_boundary_values(data_dir, field_name, boundary_struct, ...
                                                          boundary_width, save_output, plot_results, ...
                                                          output_suffix, C_MAT, Z_MAT, D, i);

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

fprintf('\n=== Boundary Values Setting Complete ===\n');
end