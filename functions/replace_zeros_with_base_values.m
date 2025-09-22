function data_corrected = replace_zeros_with_base_values(data)
    % REPLACE_ZEROS_WITH_BASE_VALUES Replaces zero values with base values in radial fashion
    %
    % This function takes a 2D dataset and replaces zero values in each Z column
    % with non-zero values from the base (bottom) of the same column, following
    % a radial pattern.
    %
    % Input:
    %   data - 2D matrix where columns represent Z positions and rows represent 
    %          radial positions (c values from 0 to 1)
    %
    % Output:
    %   data_corrected - 2D matrix with zeros replaced by base values
    %
    % Algorithm:
    %   For each Z column:
    %   - Identify zero values
    %   - Replace them with the first N non-zero values from the base of the column
    %   - If 1 zero → use 1st base value
    %   - If 2 zeros → use 1st and 2nd base values
    %   - If N zeros → use first N base values
    %
    % Example:
    %   data = [0 1 2; 0 3 4; 5 6 7; 8 9 10];
    %   result = replace_zeros_with_base_values(data);
    %   % Zeros in column 1 are replaced with base values [5; 8]
    
    % Input validation
    if ~ismatrix(data) || ~isnumeric(data)
        error('Input must be a 2D numeric matrix');
    end
    
    % Initialize output
    data_corrected = data;
    
    % Get matrix dimensions
    [~, num_cols] = size(data);
    
    % Process each Z column independently
    for col = 1:num_cols
        column_data = data_corrected(:, col);
        
        % Find zero indices in current column
        zero_indices = find(column_data == 0);
        
        % Skip if no zeros in this column
        if isempty(zero_indices)
            continue;
        end
        
        % Find non-zero values starting from the base (bottom of column)
        non_zero_indices = find(column_data ~= 0);
        
        % If no non-zero values exist, skip this column
        if isempty(non_zero_indices)
            warning('Column %d contains only zeros - no replacement possible', col);
            continue;
        end
        
        % Start from the bottom (highest row index) to find base values
        % Sort non-zero indices in descending order (base first)
        base_indices = sort(non_zero_indices, 'descend');
        base_values = column_data(base_indices);
        
        % Number of zeros to replace
        num_zeros = length(zero_indices);
        
        % Number of available base values
        num_base_values = length(base_values);
        
        % If we have enough base values, use the first N
        if num_base_values >= num_zeros
            replacement_values = base_values(1:num_zeros);
        else
            % If not enough base values, repeat the pattern
            replacement_values = repmat(base_values, ceil(num_zeros/num_base_values), 1);
            replacement_values = replacement_values(1:num_zeros);
        end
        
        % Replace zeros with base values
        % Sort zero indices to replace from top to bottom consistently
        zero_indices_sorted = sort(zero_indices);
        data_corrected(zero_indices_sorted, col) = replacement_values;
        
        % Debug output (optional - can be commented out)
        if length(zero_indices) > 0
            fprintf('Column %d: Replaced %d zeros with base values\n', col, length(zero_indices));
        end
    end
    
    % Verification: check if any zeros remain
    remaining_zeros = sum(data_corrected(:) == 0);
    if remaining_zeros > 0
        warning('%d zeros remain after processing (likely in columns with all zeros)', remaining_zeros);
    else
        fprintf('All zeros successfully replaced with base values\n');
    end
end