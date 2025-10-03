clear; clc;
% close all;
addpath('~/MATLAB/');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');

%% Configuration
save_fig = false;
save_data = true;  % New flag to save interpolated data to disk
plot_smooth_data = true;
data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D';
output_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D/interpolated/';
fields = {
    'Heatrelease', '$\langle \dot{\omega}_{T}|c\rangle$', 'Heat Release Rate';
    'Temperature', '$\langle T|c\rangle$', 'Temperature';
    'density', '$\langle \rho|c\rangle$', 'density';
    % Add more fields as needed
};
C_n = [0.1, 0.3, 0.5, 0.7, 0.9];  % Vector of c-values for interpolation

%% Load coordinate data
fprintf('Loading coordinate data from CZ_data.mat...\n');
try
    coord_data = load(fullfile(data_dir, 'CZ_data.mat'));
    C_MAT = coord_data.C_MAT;
    Z_MAT = coord_data.Z_MAT;
    fprintf('Successfully loaded coordinate data\n');
catch ME
    fprintf('Error loading coordinate data: %s\n', ME.message);
    fprintf('Please ensure CZ_data.mat exists in: %s\n', data_dir);
    return;
end

%% Process each field: Load, interpolate, save, and plot
for i = 1:size(fields, 1)
    field_name = fields{i, 1};
    latex_name = fields{i, 2};
    fig_name = fields{i, 3};
    
    % Load field data
    if plot_smooth_data
        mat_file = sprintf('%s_smooth.mat', field_name);
    else
        mat_file = sprintf('%s.mat', field_name);
    end
    try
        field_data = load(fullfile(data_dir, mat_file));
        DF = field_data.DF;
        fprintf('Loaded %s\n', mat_file);
    catch ME
        fprintf('Error loading %s: %s\n', mat_file, ME.message);
        continue;
    end
    
    % Interpolate at C_n values
    [DF_interp, C_interp, Z_interp] = interpolate_at_c(DF, C_MAT, Z_MAT, C_n);
    DF = DF_interp;  % Use interpolated data for plotting
    if i == 1
        C_MAT_n = C_interp;  % Update C_MAT to interpolated values
        Z_MAT_n = Z_interp;  % Update Z_MAT to interpolated values
        filename = f
        save('CZ_data_interp.mat', 'C_MAT_n', 'Z_MAT_n');  % Save interpolated coordinates once
    end
    
    % Save interpolated data if enabled
    if save_data
        interp_file = sprintf('%s_interp.mat', field_name);
        save(fullfile(output_dir, interp_file), 'DF');
        fprintf('Saved interpolated data to %s\n', interp_file);
    end
    
    % Plot interpolated fields using the existing plotting function
    % Adapt the call for interpolated data (C_interp as c-matrix, Z_interp as z-matrix)
    plot_surf_fields_separately(data_dir, {{field_name, latex_name, fig_name}}, C_interp, Z_interp, save_fig, false, DF_interp);
end
