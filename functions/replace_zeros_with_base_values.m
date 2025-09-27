function data_corrected = replace_zeros_with_base_values(data)
    % REPLACE_ZEROS_WITH_BASE_VALUES Replaces zero values with base values in radial fashion
    %
    % This function takes a 2D dataset and replaces zero values in each Z row
    % with non-zero values from the base (rightmost positions) of the same row.
    %
    % Input:
    %   data - 2D matrix where rows represent Z positions and columns represent 
    %          radial positions (c values from 0 to 1)
    %
    % Output:
    %   data_corrected - 2D matrix with zeros replaced by base values
    %
    % Algorithm:
    %   For each Z row:
    %   - Find the first N zero values in the row
    %   - Replace them with the first N non-zero values from the base (rightmost)
    %   - If 1 zero → use 1st base value only
    %   - If 2 zeros → use 1st and 2nd base values only  
    %   - If N zeros → use first N base values only
    %   - If fewer than N base values available → use all available + padding
    %
    % Example:
    %   data = [0 0 5 8; 1 3 6 9; 2 4 7 10];
    %   result = replace_zeros_with_base_values(data);
    %   % First 2 zeros in row 1 are replaced with base values [8, 5] (from right)
    
    % Input validation
    if ~ismatrix(data) || ~isnumeric(data)
        error('Input must be a 2D numeric matrix');
    end
    
    % Initialize output
    data_corrected = data;
    
    % Get matrix dimensions
    [num_rows, ~] = size(data);
    
    base_z_idx = find(data_corrected(:,1) == 0 ,1) ;
    % Process each Z row independently
    for row = 1:num_rows
        row_data = data_corrected(row, :);
        
        % Find zero indices in current row
        zero_indices = find(row_data == 0);
        
        % Skip if no zeros in this row
        if isempty(zero_indices)
            continue;
        end
        
        base_values = data_corrected(base_z_idx-1,:);
%         base_values = data_corrected(1,:);
        
        % Get only the FIRST N zero values (leftmost zeros)
        zero_indices_sorted = sort(zero_indices);  % Sort zeros left to right
        
        % Number of zeros to replace (first N zeros)
        num_zeros = length(zero_indices_sorted);
        
        % Number of available base values
        num_base_values = length(base_values);
        
        % Use only the first N non-zero base values (where N = number of zeros)
        if num_base_values >= num_zeros
            replacement_values = base_values(1:num_zeros);
        else
            % If not enough base values, use all available and warn
            replacement_values = base_values;
            warning('Row %d: Only %d base values available for %d zeros', row, num_base_values, num_zeros);
            % Pad with the last available base value if needed
            if num_base_values < num_zeros
                last_value = base_values(end);
                padding = repmat(last_value, 1, num_zeros - num_base_values);
                replacement_values = [replacement_values, padding];
            end
        end
        
        % Replace the first N zeros with base values
        data_corrected(row, zero_indices_sorted) = replacement_values;
        
        % Debug output (optional - can be commented out)
        if length(zero_indices) > 0
            fprintf('Row %d: Replaced %d zeros with base values\n', row, length(zero_indices));
        end
    end
    
    % Verification: check if any zeros remain
    remaining_zeros = sum(data_corrected(:) == 0);
    if remaining_zeros > 0
        warning('%d zeros remain after processing (likely in rows with all zeros)', remaining_zeros);
    else
        fprintf('All zeros successfully replaced with base values\n');
    end
end