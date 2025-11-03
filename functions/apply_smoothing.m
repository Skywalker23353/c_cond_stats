function smoothed_data = apply_smoothing(field, window)
    % Apply the multi-step smoothing operation
    
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
    smoothed_data = temp_f;
end