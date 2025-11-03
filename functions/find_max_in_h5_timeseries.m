function [max_value, max_info] = find_max_in_h5_timeseries(file_basename, start_idx, end_idx, phase_name, grid_names, dataset_name, use_parallel)
% FIND_MAX_IN_H5_TIMESERIES Find maximum value of a quantity across HDF5 time series
%
% Inputs:
%   file_basename - Base name of files (e.g., 'Reactants')
%   start_idx     - Starting file index (e.g., 201)
%   end_idx       - Ending file index (e.g., 1001)
%   phase_name    - Name of the phase (e.g., 'Phase1')
%   grid_names    - Cell array of grid names (e.g., {'Grid1'} or {'Grid1', 'Grid2'})
%   dataset_name  - Name of the dataset to analyze (e.g., 'Temperature')
%   use_parallel  - (Optional) Use parallel processing (default: true)
%
% Outputs:
%   max_value - Maximum value found across all files and blocks
%   max_info  - Structure containing information about where max was found
%               Fields: filename, file_index, block_id, phase, grid, dataset
%
% Example:
%   [max_val, info] = find_max_in_h5_timeseries('Reactants', 201, 1001, 'Phase1', {'Grid1', 'Grid2'}, 'O2');

    % Handle optional parallel flag
    if nargin < 7
        use_parallel = true;
    end
    
    % Convert single grid name to cell array if needed
    if ischar(grid_names) || isstring(grid_names)
        grid_names = {char(grid_names)};
    end
    
    % Initialize output
    max_value = -inf;
    max_info = struct('filename', '', 'file_index', 0, 'block_id', '', ...
                      'phase', phase_name, 'grid', '', 'dataset', dataset_name);
    
    % Calculate number of files
    num_files = end_idx - start_idx + 1;
    num_grids = length(grid_names);
    fprintf('Processing %d HDF5 files (%s_%d.h5 to %s_%d.h5)...\n', ...
            num_files, file_basename, start_idx, file_basename, end_idx);
    fprintf('Processing %d grid(s): %s\n', num_grids, strjoin(grid_names, ', '));
    
    % Pre-allocate arrays for parallel results
    file_max_values = -inf(num_files, 1);
    file_max_blocks = cell(num_files, 1);
    file_max_grids = cell(num_files, 1);
    file_indices = start_idx:end_idx;
    
    % Start timer
    tic;
    
    % Process files in parallel or serial
    if use_parallel
        fprintf('Using parallel processing...\n');
        parfor idx = 1:num_files
            file_idx = file_indices(idx);
            file_path = sprintf('%s_%d.h5', file_basename, file_idx);
            
            [file_max_values(idx), file_max_blocks{idx}, file_max_grids{idx}] = ...
                process_single_file(file_path, phase_name, grid_names, dataset_name, idx, num_files);
        end
    else
        fprintf('Using serial processing...\n');
        for idx = 1:num_files
            file_idx = file_indices(idx);
            file_path = sprintf('%s_%d.h5', file_basename, file_idx);
            
            [file_max_values(idx), file_max_blocks{idx}, file_max_grids{idx}] = ...
                process_single_file(file_path, phase_name, grid_names, dataset_name, idx, num_files);
        end
    end
    
    elapsed_time = toc;
    
    % Find global maximum from all files
    [max_value, max_idx] = max(file_max_values);
    
    % Check if any valid data was found
    if isinf(max_value) || isnan(max_value)
        warning('No valid data found. Check phase name, grid names, and dataset name.');
        max_value = NaN;
    else
        % Store information about where max was found
        max_file_idx = file_indices(max_idx);
        max_info.filename = sprintf('%s_%d.h5', file_basename, max_file_idx);
        max_info.file_index = max_file_idx;
        max_info.block_id = file_max_blocks{max_idx};
        max_info.grid = file_max_grids{max_idx};
        
        fprintf('\n=== RESULTS ===\n');
        fprintf('Maximum value: %.10e\n', max_value);
        fprintf('Found in file: %s\n', max_info.filename);
        fprintf('Grid: %s\n', max_info.grid);
        fprintf('Block ID: %s\n', max_info.block_id);
        fprintf('Path: /%s/%s/fields/%s/%s\n', max_info.phase, max_info.grid, ...
                max_info.block_id, max_info.dataset);
        fprintf('Processing time: %.2f seconds\n', elapsed_time);
        fprintf('Average time per file: %.3f seconds\n', elapsed_time/num_files);
    end

end


