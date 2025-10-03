clear; clc;
close all;
addpath('~/MATLAB/');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');

%% Configuration
save_fig = false;
save_data = true;  % New flag to save interpolated data to disk
data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D_n';
output_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D_n/interpolated/';
D = 2e-3;
fields = {
    'Heatrelease_smooth', '$\langle \dot{\omega}_{T}|c\rangle$', 'Heat Release Rate';
    'Temperature_smooth_bc_smooth', '$\langle T|c\rangle$', 'Temperature';
    'density_smooth_bc_smooth', '$\langle \rho|c\rangle$', 'density';
    'CH4_smooth_bc_smooth', '$\langle CH_4|c\rangle$', 'CH4';
    'O2_smooth_bc_smooth', '$\langle O_2|c\rangle$', 'O2';
    'CO2_smooth_bc_smooth', '$\langle CO_2|c\rangle$', 'CO2';
    'H2O_smooth_bc_smooth', '$\langle H_20|c\rangle$', 'H2O';
    % Add more fields as needed
};
C_n = [0.1, 0.3, 0.5, 0.7, 0.9];  % Vector of c-values for interpolation

%% Load coordinate data
fprintf('Loading coordinate data from CZ_data.mat...\n');
try
    coord_data = load(fullfile(data_dir, 'CZ_data.mat'));
    C_MAT_o = coord_data.C_MAT;
    Z_MAT_o = coord_data.Z_MAT;
    fprintf('Successfully loaded coordinate data\n');
catch ME
    fprintf('Error loading coordinate data: %s\n', ME.message);
    fprintf('Please ensure CZ_data.mat exists in: %s\n', data_dir);
    return;
end
if ~isfolder(output_dir); mkdir(output_dir);end
%% Process each field: Load, interpolate, save, and plot
for i = 1:size(fields, 1)
    field_name = fields{i, 1};
    latex_name = fields{i, 2};
    fig_name = fields{i, 3};

    mat_file = sprintf('%s.mat', field_name);

    try
        field_data = load(fullfile(data_dir, mat_file));
        DF = field_data.DF;
        fprintf('Loaded %s\n', mat_file);
    catch ME
        fprintf('Error loading %s: %s\n', mat_file, ME.message);
        continue;
    end
    
    % Interpolate at C_n values
    [DF_interp, C_interp, Z_interp] = interpolate_at_c(DF, C_MAT_o, Z_MAT_o, C_n);
    DF = DF_interp;  % Use interpolated data for plotting
    if i == 1
        C_MAT = C_interp;  % Update C_MAT to interpolated values
        Z_MAT = Z_interp;  % Update Z_MAT to interpolated values
        fname = 'CZ_data.mat';
        save(fullfile(output_dir, fname), 'C_MAT', 'Z_MAT');  % Save interpolated coordinates once
    end
    
    % Save interpolated data if enabled
    if save_data
        interp_file = sprintf('%s_interp.mat', field_name);
        save(fullfile(output_dir, interp_file), 'DF');
        fprintf('Saved interpolated data to %s\n', interp_file);
    end
%     (data_dir,F_MAT,C_MAT,Z_MAT,D,fieldsName,fieldsfigLabel,save_fig,idx)
    plot_surf_field(data_dir,DF, C_interp, Z_interp,D, field_name, latex_name, false, i);
end
