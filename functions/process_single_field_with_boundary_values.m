function success = process_single_field_with_boundary_values(data_dir, field_name, boundary_struct, ...
                                                           boundary_width, save_output, plot_results, ...
                                                           output_suffix, C_MAT, Z_MAT, D, field_idx)
% Process a single field with boundary values

success = false;

% Define file paths
input_file = sprintf('%s/%s.mat', data_dir, field_name);
output_file = sprintf('%s/%s%s.mat', data_dir, field_name, output_suffix);

% Check if input file exists
if ~exist(input_file, 'file')
    fprintf('  Warning: Input file %s not found\n', input_file);
    return;
end

try
    % Load field data
    fprintf('  Loading %s...\n', field_name);
    data = load(input_file);

    if ~isfield(data, 'DF')
        fprintf('  Warning: Field DF not found in %s\n', input_file);
        return;
    end

    original_field = data.DF;
    fprintf('  Original field size: %d x %d\n', size(original_field));
    fprintf('  Original field range: [%.6e, %.6e]\n', min(original_field(:)), max(original_field(:)));

    % Create boundary value structure for set_boundary_values
    boundary_value = struct('left', boundary_struct.left, 'right', boundary_struct.right);

    % Apply boundary values
    fprintf('  Setting left boundary to %.6f and right boundary to %.6f (width=%d)\n', ...
            boundary_struct.left, boundary_struct.right, boundary_width);

    processed_field = set_boundary_values(original_field, boundary_value, ...
                                        'BoundaryWidth', boundary_width, ...
                                        'Boundaries', {'left', 'right'});

    fprintf('  Processed field range: [%.6e, %.6e]\n', min(processed_field(:)), max(processed_field(:)));

    % Create output data structure
    processed_data = data;
    processed_data.DF = processed_field;

    % Save processed data
    if save_output
        fprintf('  Saving to %s\n', output_file);
        save(output_file, '-struct', 'processed_data');
    end

    % Generate comparison plots
    if plot_results && ~isempty(C_MAT) && ~isempty(Z_MAT)
        plot_comparison(data_dir, data, processed_data, C_MAT, Z_MAT, D, ...
                       field_name, field_idx, false); % save_fig_flag set to false for now
    end

    success = true;

catch ME
    fprintf('  Error in process_single_field_with_boundary_values: %s\n', ME.message);
    success = false;
end
end