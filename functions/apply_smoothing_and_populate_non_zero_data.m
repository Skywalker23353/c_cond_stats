function smoothed_data = apply_smoothing_and_populate_non_zero_data(data, window, n_cycle)
    % Apply the multi-step smoothing operation

    % Replace zeros with the first non-zero value
    if strcmp(data.fieldname,'Heatrelease')
        temp_f = remove_zero_near_centerline(data.DF);
    else
        temp_f = replace_zeros_with_base_values(data.DF);
    end
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