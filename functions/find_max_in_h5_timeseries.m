function [max_value, max_info, min_value, min_info] = find_max_in_h5_timeseries(LES_file_path, file_basename, start_idx, end_idx, phase_name, grid_names, dataset_name)
% FIND_MAX_IN_H5_TIMESERIES Find maximum and minimum values of a quantity across HDF5 time series
%
% Inputs:
%   LES_file_path - Path to the directory containing HDF5 files
%   file_basename - Base name of files (e.g., 'Reactants')
%   start_idx     - Starting file index (e.g., 201)
%   end_idx       - Ending file index (e.g., 1001)
%   phase_name    - Name of the phase (e.g., 'Phase1')
%   grid_names    - Cell array of grid names (e.g., {'Grid1'} or {'Grid1', 'Grid2'})
%   dataset_name  - Name of the dataset to analyze (e.g., 'Temperature')
%
% Outputs:
%   max_value - Maximum value found across all files and blocks
%   max_info  - Structure containing information about where max was found
%   min_value - Minimum value found across all files and blocks
%   min_info  - Structure containing information about where min was found
%               Fields: filename, file_index, block_id, phase, grid, dataset
%
% Example:
%   [max_val, max_info, min_val, min_info] = find_max_in_h5_timeseries('/path', 'Reactants', 201, 1001, 'Phase1', {'Grid1', 'Grid2'}, 'O2');

    % Convert single grid name to cell array if needed
    if ischar(grid_names) || isstring(grid_names)
        grid_names = {char(grid_names)};
    end
    
    % Initialize output
    max_value = -inf;
    min_value = inf;
    max_info = struct('filename', '', 'file_index', 0, 'block_id', '', ...
                      'phase', phase_name, 'grid', '', 'dataset', dataset_name);
    min_info = struct('filename', '', 'file_index', 0, 'block_id', '', ...
                      'phase', phase_name, 'grid', '', 'dataset', dataset_name);
    
    % Calculate number of files
    num_files = end_idx - start_idx + 1;
    num_grids = length(grid_names);
    fprintf('Processing %d HDF5 files (%s_%d.h5 to %s_%d.h5)...\n', ...
            num_files, file_basename, start_idx, file_basename, end_idx);
    fprintf('Processing %d grid(s): %s\n', num_grids, strjoin(grid_names, ', '));
    
    % Pre-allocate arrays for parallel results
    file_max_values = -inf(num_files, 1);
    file_min_values = inf(num_files, 1);
    file_max_blocks = cell(num_files, 1);
    file_min_blocks = cell(num_files, 1);
    file_max_grids = cell(num_files, 1);
    file_min_grids = cell(num_files, 1);
    file_indices = start_idx:end_idx;
    
    % Start timer
    tic;
    
    % Process files in parallel
        parfor idx = 1:num_files
            file_idx = file_indices(idx);
            file_path = sprintf('%s/%s_%d.h5', LES_file_path,file_basename, file_idx);
            
            [file_max_values(idx), file_max_blocks{idx}, file_max_grids{idx}, ...
             file_min_values(idx), file_min_blocks{idx}, file_min_grids{idx}] = ...
                process_single_file(file_path, phase_name, grid_names, dataset_name, idx, num_files);
        end
    
    elapsed_time = toc;
    
    % Find global maximum from all files
    [max_value, max_idx] = max(file_max_values);
    
    % Find global minimum from all files
    [min_value, min_idx] = min(file_min_values);
    
    % Check if any valid data was found
    if isinf(max_value) || isnan(max_value)
        warning('No valid data found. Check phase name, grid names, and dataset name.');
        max_value = NaN;
        min_value = NaN;
    else
        % Store information about where max was found
        max_file_idx = file_indices(max_idx);
        max_info.filename = sprintf('%s_%d.h5', file_basename, max_file_idx);
        max_info.file_index = max_file_idx;
        max_info.block_id = file_max_blocks{max_idx};
        max_info.grid = file_max_grids{max_idx};
        
        % Store information about where min was found
        min_file_idx = file_indices(min_idx);
        min_info.filename = sprintf('%s_%d.h5', file_basename, min_file_idx);
        min_info.file_index = min_file_idx;
        min_info.block_id = file_min_blocks{min_idx};
        min_info.grid = file_min_grids{min_idx};
        
        fprintf('\n=== RESULTS ===\n');
        fprintf('Maximum value: %.10e\n', max_value);
        fprintf('Found in file: %s\n', max_info.filename);
        fprintf('Grid: %s, Block ID: %s\n', max_info.grid, max_info.block_id);
        fprintf('Path: /%s/%s/fields/%s/%s\n', max_info.phase, max_info.grid, ...
                max_info.block_id, max_info.dataset);
        fprintf('\n');
        fprintf('Minimum value: %.10e\n', min_value);
        fprintf('Found in file: %s\n', min_info.filename);
        fprintf('Grid: %s, Block ID: %s\n', min_info.grid, min_info.block_id);
        fprintf('Path: /%s/%s/fields/%s/%s\n', min_info.phase, min_info.grid, ...
                min_info.block_id, min_info.dataset);
        fprintf('\n');
        fprintf('Processing time: %.2f seconds\n', elapsed_time);
        fprintf('Average time per file: %.3f seconds\n', elapsed_time/num_files);
    end

end


