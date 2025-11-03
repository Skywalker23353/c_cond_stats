%% MAIN_FIND_MAX_H5 - Main script to find maximum value in HDF5 time series
% This script is to find max value in HDF5 time series i.e.
% to find the maximum value of a quantity across multiple HDF5 files

clear; clc; close all;
addpath('functions');
%% ========== USER CONFIGURATION ==========
% Processing options
save_results = true;       % Save results to .mat file

% Time series file configuration
LES_file_path = '/store1/anindya/CH4_jet_PF/2025_runs/LES_base_case_v6/TB1_run';
file_basename = 'Reactants';  % Base name of the files
start_index = 101;            % Starting file index
end_index = 102;             % Ending file index

% HDF5 structure information
phase_name = 'Reactants';      
grid_names = {'burner';'overset'};      
dataset_name = 'Temperature';  
parpool('local',24);
%% ========== FIND MAXIMUM VALUE ==========
% Call the function
[max_value, max_info] = find_max_in_h5_timeseries(LES_file_path, file_basename, start_index, end_index, ...
                                                   phase_name, grid_names, dataset_name);

%% ========== DISPLAY RESULTS ==========

if ~isnan(max_value)
    fprintf('\n==============================================\n');
    fprintf('FINAL RESULTS\n');
    fprintf('==============================================\n');
    fprintf('Maximum Value: %.10e\n', max_value);
    fprintf('File: %s (index %d)\n', max_info.filename, max_info.file_index);
    fprintf('Block ID: %s\n', max_info.block_id);
    fprintf('Full Path: /%s/%s/fields/%s/%s\n', ...
            max_info.phase, max_info.grid, max_info.block_id, max_info.dataset);
    fprintf('==============================================\n');
    
    % Optional: Save results to file
    if save_results
        results_file = sprintf('max_value_results_%s_%d_%d.mat', dataset_name, start_index, end_index);
        save(results_file, 'max_value', 'max_info');
        fprintf('Results saved to: %s\n', results_file);
    end
else
    fprintf('\n==============================================\n');
    fprintf('No valid data found!\n');
    fprintf('Please check:\n');
    fprintf('  1. HDF5 files exist in current directory\n');
    fprintf('  2. Phase name is correct: %s\n', phase_name);
    fprintf('  3. Grid names are correct: %s\n', strjoin(grid_names, ', '));
    fprintf('  4. Dataset name is correct: %s\n', dataset_name);
    fprintf('==============================================\n');
end

%% ========== OPTIONAL: INSPECT HDF5 STRUCTURE ==========
% Uncomment the section below to explore the structure of your HDF5 files

% sample_file = sprintf('%s_%d.h5', file_basename, start_index);
% if isfile(sample_file)
%     fprintf('\n=== HDF5 File Structure (first file) ===\n');
%     h5disp(sample_file);
% end
