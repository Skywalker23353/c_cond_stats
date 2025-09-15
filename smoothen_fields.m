clear;clc;
% close all;
addpath('~/MATLAB');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');
%% Inputs
data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800';
% fields = {'Temperature','density','CH2O','CH3','CH4','CO','CO2','H','H2','H2O','HO2','N2','O','O2','OH',...
% 'SYm_CH4','SYm_O2','SYm_CO2','SYm_H2O'};
    fields = {
%          FILENAME,          LATEX NAME,                           FIG NAME
%         'Heatrelease', '$\langle \dot{\omega}_{T}|c\rangle$'; % window = 7,n_cycles=3;
%         'Temperature', '$\langle T|c\rangle$';9,3
%         'density','$\langle \rho|c\rangle$';11,3
%         'CH2O','$\langle CH2O|c\rangle$';
%         'CH3','$\langle CH3|c\rangle$';
%         'CH4','$\langle CH4|c\rangle$';11,3
%         'CO','$\langle CO|c\rangle$';
%         'CO2','$\langle CO2|c\rangle$';
%         'H','$\langle H|c\rangle$';
%         'H2O','$\langle H2O|c\rangle$';
%         'HO2','$\langle HO2|c\rangle$';
%         'N2','$\langle N2|c\rangle$';
%         'O','$\langle O|c\rangle$';
%         'O2','$\langle O2|c\rangle$';7,3
%         'OH','$\langle OH|c\rangle$';
%         'H2','$\langle H2|c\rangle$';

%         'SYm_CH4','$\langle \dot{\omega}_{CH_4}|c\rangle$';
%         'SYm_O2','$\langle \dot{\omega}_{O_2}|c\rangle$';5,3
%         'SYm_CO2','$\langle \dot{\omega}_{CO_2}|c\rangle$';
        'SYm_H2O','$\langle \dot{\omega}_{H_2O}|c\rangle$';9,3
        };
window = 3;
n_cycles = 3;
save_results_flag = false;
plot_results_flag = false;
plot_surface_flag = true;
save_figs = false;

batch_smooth_fields(data_dir, save_results_flag, fields, window, n_cycles,plot_results_flag,plot_surface_flag,save_figs);
%%
function f_smoothen_fields(varargin)
    % Parse input arguments
    p = inputParser;
    addParameter(p, 'DataDir', 'C_cond_fields_800', @ischar);
    addParameter(p, 'Window', 3, @isnumeric);
    addParameter(p, 'Smoothing_cycles', 2, @isnumeric);
    addParameter(p, 'Fields', {}, @iscell);
    addParameter(p, 'AutoDetect', false, @islogical);
    addParameter(p, 'SaveOutput', false, @islogical);
    addParameter(p, 'PlotResults', false, @islogical);
    addParameter(p, 'PlotSurf', false, @islogical);
    addParameter(p, 'SaveFigs', false, @islogical);
    
    parse(p, varargin{:});
    
    data_dir = p.Results.DataDir;
    window = p.Results.Window;
    n_cycle = p.Results.Smoothing_cycles;
    specified_fields = p.Results.Fields(:,1);
    specified_fields_fig_labels = p.Results.Fields(:,2);
    auto_detect = p.Results.AutoDetect;
    save_output = p.Results.SaveOutput;
    plot_results = p.Results.PlotResults;
    plot_surf_flag = p.Results.PlotSurf;
    save_fig_flag = p.Results.SaveFigs;
    alpha = 0.01;
    
    % Load coordinate data
    coord_file = sprintf("%s/CZ_data.mat", data_dir);
    if exist(coord_file, 'file')
        coord_data = load(coord_file);
        C_MAT = coord_data.C_MAT;
        Z_MAT = coord_data.Z_MAT;
    else
        fprintf('Warning: Coordinate file %s not found. Using default coordinates.\n', coord_file);
        C_MAT = [];
        Z_MAT = [];
    end
    
    D = 2e-3;
    
    % Determine which fields to process
    if auto_detect && isempty(specified_fields)
        % Auto-detect all .mat files in the directory
        if exist(data_dir, 'dir')
            mat_files = dir(fullfile(data_dir, '*.mat'));
            field_names = {};
            for i = 1:length(mat_files)
                [~, name, ~] = fileparts(mat_files(i).name);
                % Skip coordinate files and already smoothed files
                if ~contains(name, 'smooth') && ~strcmp(name, 'Heatrelease')
                    field_names{end+1} = name;
                end
            end
        else
            error('Data directory %s not found!', data_dir);
        end
    elseif ~isempty(specified_fields)
        field_names = specified_fields;
        field_fig_labels = specified_fields_fig_labels;
    else
        % Default to Temperature field
        field_names = {'Temperature'};
    end
    
    fprintf('Processing %d fields with smoothing window = %d\n', length(field_names), window);
    
    % Process each field
    for i = 1:length(field_names)
        fieldsName = field_names{i};
        fieldsfigLabel = field_fig_labels{i};
        fprintf('Processing field %d/%d: %s\n', i, length(field_names), fieldsName);
        
        % Define input and output filenames
        input_file = sprintf("%s/%s.mat", data_dir, fieldsName);
        opfilename = sprintf("%s/%s_smooth", data_dir, fieldsName);
        
        % Check if input file exists
        if ~exist(input_file, 'file')
            fprintf('Warning: Input file %s not found. Skipping.\n', input_file);
            continue;
        end
        
        % Load data
        try
            data = load(input_file);
            
            if ~isfield(data, 'DF')
                fprintf('Warning: Field DF not found in %s. Skipping.\n', input_file);
                continue;
            end
            if strcmp(fieldsName,'Heatrelease')
                fprintf('Thresholding Heatrelease using alpha %e',alpha);
                data.DF = threshold_data(data,alpha);
            end
            % Apply smoothing operation
            fprintf('  Applying smoothing...\n');
%             smoothed_data = apply_smoothing(data, window);
            smoothed_data = apply_smoothing_and_populate_non_zero_data(data, window, n_cycle);
            
            % Save smoothed data
            if save_output
                fprintf('  Saving to %s.mat\n', opfilename);
                save(sprintf('%s.mat', opfilename), '-struct', 'smoothed_data');
            end
            
            % Optional plotting
            if plot_results && ~isempty(C_MAT) && ~isempty(Z_MAT)
                plot_comparison(data_dir,data, smoothed_data, C_MAT, Z_MAT, D, fieldsName, i,save_fig_flag);
            elseif plot_surf_flag && ~isempty(C_MAT) && ~isempty(Z_MAT)
%                     plot_surf_field(data_dir,data.DF,C_MAT,Z_MAT,D,fieldsName,fieldsfigLabel,save_fig_flag,i*30);
                    plot_surf_field(data_dir,smoothed_data.DF,C_MAT,Z_MAT,D,fieldsName,fieldsfigLabel,save_fig_flag,4*i);
            end
            
        catch ME
            fprintf('Error processing %s: %s\n', fieldsName, ME.message);
            continue;
        end
    end
    
    fprintf('Smoothing complete for all fields!\n');
end

function smoothed_data = apply_smoothing_and_populate_non_zero_data(data, window, n_cycle)
    % Apply the multi-step smoothing operation

    % Replace zeros with the first non-zero value
    field = remove_zero_near_centerline(data.DF);
    temp_f = field;
    for i = 1:n_cycle
        % Apply smoothing sequence: row -> row -> col -> col
        fprintf('    Step 1: Row smoothing...\n');
        temp_fr = myutils.f_return_smooth_field(temp_f, window, 'row');
        
        fprintf('    Step 2: Row smoothing (second pass)...\n');
        temp_fc = myutils.f_return_smooth_field(temp_fr, window, 'col');
        
        temp_f = temp_fc;
    end
    fprintf('    Total Smoothing cycle : %d...\n',i);clear i;
        
    % Create output structure
    smoothed_data = data;
    smoothed_data.DF = temp_f;
end

function plot_comparison(data_dir,original_data, smoothed_data, C_MAT, Z_MAT, D, fieldsName, field_idx,save_fig_flag)
    % Plot comparison between original and smoothed data
    original_min = min(original_data.DF(:));
    original_max = max(original_data.DF(:));

    figure_handle = figure(100 + field_idx);
    set(figure_handle, 'Position', [100 + field_idx*50, 100 + field_idx*30, 1200, 500]);
    
    % Original data
    subplot(1, 2, 1);
    myutils.plot_contourf(figure_handle, C_MAT, Z_MAT/D, original_data.DF, ...
        '$c$', '$z/D$', sprintf('$\\langle %s|c\\rangle$ (Original)', fieldsName));
    title(sprintf('%s - Original', fieldsName), 'Interpreter', 'latex');
    pbaspect([1, 2, 1]);
    caxis([original_min, original_max]);
    
    % Smoothed data
    subplot(1, 2, 2);
    myutils.plot_contourf(figure_handle, C_MAT, Z_MAT/D, smoothed_data.DF, ...
        '$c$', '$z/D$', sprintf('$\\langle %s|c\\rangle$ (Smoothed)', fieldsName));
    title(sprintf('%s - Smoothed', fieldsName), 'Interpreter', 'latex');
    pbaspect([1, 2, 1]);
    caxis([original_min, original_max]);
    
    sgtitle(sprintf('Smoothing Comparison: %s', fieldsName), 'FontSize', 14);
    
    % Save comparison plot
    if save_fig_flag
        figdir = 'smoothened_figs';
        if ~isfolder(sprintf('%s/%s',data_dir,figdir));mkdir(sprintf('%s/%s',data_dir,figdir));end
                    
        saveas(figure_handle, sprintf('%s/%s/%s_smoothing_comparison.png', data_dir,figdir,fieldsName));
        saveas(figure_handle, sprintf('%s/%s/%s_smoothing_comparison.fig', data_dir,figdir,fieldsName));
    end
end

function smoothed_data = apply_smoothing(data, window)
    % Apply the multi-step smoothing operation
    
    field = data.DF;
    
    % Replace zeros with the first non-zero value
    zero_indices = find(field == 0);
    if ~isempty(zero_indices)
        field(zero_indices) = data.DF(1,1);
    end

%     field = remove_zero_near_centerline(data.DF);
    
    % Apply smoothing sequence: row -> row -> col -> col
    fprintf('    Step 1: Row smoothing...\n');
    temp_f1 = myutils.f_return_smooth_field(field, window, 'row');
    
    fprintf('    Step 2: Row smoothing (second pass)...\n');
    temp_f2 = myutils.f_return_smooth_field(temp_f1, window, 'row');
    
    fprintf('    Step 3: Column smoothing...\n');
    temp_f3 = myutils.f_return_smooth_field(temp_f2, window, 'col');
    
    fprintf('    Step 4: Column smoothing (second pass)...\n');
    temp_f = myutils.f_return_smooth_field(temp_f3, window, 'col');
    
    % Create output structure
    smoothed_data = data;
    smoothed_data.DF = temp_f;
end

% Batch processing function for convenience
function batch_smooth_fields(data_dir, save_flag, field_list, window, n_cycles,plot_results_flag,plot_surf_flag,save_figs)
    % Convenience function for batch processing
    if nargin < 7
        plot_surf_flag = false;
    end
    if nargin < 6
        plot_results_flag = false;
    end
    if nargin < 5
        n_cycles = 2;
    end
    if nargin < 4
        window = 3;
    end
    if nargin < 3
        field_list = {};
    end
    if nargin < 2
        save_flag = false;
    end
    
    f_smoothen_fields('DataDir', data_dir, 'Fields', field_list, 'Window', window, ...
                   'SaveOutput', save_flag, 'PlotResults', plot_results_flag, 'PlotSurf', plot_surf_flag, 'Smoothing_cycles',n_cycles,'SaveFigs',save_figs);
end

% Quick smoothing function for single field (backward compatibility)
function quick_smooth_single_field(fieldsName, save_flag, data_dir, window)
    % Quick function to smooth a single field (maintains original functionality)
    if nargin < 4
        window = 3;
    end
    if nargin < 3
        data_dir = 'C_cond_fields_800';
    end
    if nargin < 2
        save_flag = false;
    end
    
    f_smoothen_fields('DataDir', data_dir, 'Fields', {fieldsName}, 'Window', window, ...
                   'AutoDetect', false, 'SaveOutput', save_flag, 'PlotResults', true);
end
function field = threshold_data(data,alpha)
    threshold = alpha*max(max(data.DF));
    field = data.DF;
    field(find(field <= threshold)) = 0;
end
