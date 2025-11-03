function [file_max, max_block_id, max_grid_name] = process_single_file(file_path, phase_name, grid_names, dataset_name, file_num, total_files)
    % Process a single HDF5 file and return its maximum value
    
    file_max = -inf;
    max_block_id = '';
    max_grid_name = '';
    
    % Check if file exists
    if ~isfile(file_path)
        return;
    end
    
    try
        % Loop through each grid
        for g = 1:length(grid_names)
            grid_name = grid_names{g};
            
            % Construct path to fields directory
            fields_path = ['/' phase_name '/' grid_name '/fields'];
            
            % Check if this grid exists in the file
            try
                file_info = h5info(file_path, fields_path);
            catch
                % Grid doesn't exist in this file, skip to next grid
                continue;
            end
            
            % Get list of blocks
            blocks = {file_info.Groups.Name};
            
            % Loop through each block
            for j = 1:length(blocks)
                block_path = blocks{j};
                
                % Extract block ID from path
                block_parts = strsplit(block_path, '/');
                block_id = block_parts{end};
                
                % Construct full dataset path
                dataset_path = [block_path '/' dataset_name];
                
                try
                    % Read the dataset
                    data = h5read(file_path, dataset_path);
                    
                    % Find max in this dataset
                    local_max = max(data(:));
                    
                    % Update file max if necessary
                    if local_max > file_max
                        file_max = local_max;
                        max_block_id = block_id;
                        max_grid_name = grid_name;
                    end
                    
                catch
                    % Dataset not found in this block, skip silently
                    continue;
                end
            end
        end
        
        % Print progress every 50 files
        if mod(file_num, 50) == 0
            fprintf('  Processed %d/%d files (%.1f%%)...\n', ...
                    file_num, total_files, 100*file_num/total_files);
        end
        
    catch
        % Error processing file, return -inf
        return;
    end
end