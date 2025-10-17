clear; clc;
close all;
addpath('~/MATLAB/');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');

%% Configuration
save_data = false;  % New flag to save interpolated data to disk
%% Paths
data_dir = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs' ...
    '/c_cond_stats/C_cond_fields_800_10D_coarse'];
output_dir = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs' ...
    '/c_cond_stats/C_cond_fields_800_10D_coarse/BC'];
C_one_bc_file_path = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs' ...
    '/derivatives_files/Interpolate_derivs_on_R_Z_plane' ...
    '/interp_16_unilat_structured_pl_combustor_domain/interp_fields'];
R_Z_file_path = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs' ...
    '/derivatives_files/Interpolate_derivs_on_R_Z_plane'];
%% parameters
D = 2e-3;
C_N = [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0];
bc = struct();
bc.c_zero = struct();bc.c_one = struct();
C_ZERO_bc = [0.00;800;0.4243;0.044;0.222;0.00;0.00;0.00;0.00;0.00;0.00];
c_one_bc_r = 2*D;
%%
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
%% Load C_one BC value
try
    C_one_bc_data = load(fullfile(C_one_bc_file_path, 'Mean_field_azim_avg.mat'));
    fprintf('Successfully loaded C = 1 BC data\n');
catch ME
    fprintf('Error loading C = 1 BC data: %s\n', ME.message);
    return;
end
%% Load R-Z data
try
    R_Z_data = load(fullfile(R_Z_file_path, 'structured_grid_from_LES_grid_with_zero_16_unilat_planes.mat'));
    fprintf('Successfully loaded R_Z data\n');
catch ME
    fprintf('Error loading R_Z data: %s\n', ME.message);
    return;
end
%% Find C_one bc radial index
r_idx = find(R_Z_data.R1(1,:) > c_one_bc_r,1);
z_idx = length(Z_MAT_o);
fields = {
    'Heatrelease',C_ZERO_bc(1,1)*ones(z_idx,1),C_one_bc_data.HRR_mean(1:z_idx,r_idx),'$\dot{\omega}_{T}$';

    'Temperature',C_ZERO_bc(2,1)*ones(z_idx,1),C_one_bc_data.T_mean(1:z_idx,r_idx),'$T$';
    
    'density',C_ZERO_bc(3,1)*ones(z_idx,1),C_one_bc_data.rho_mean(1:z_idx,r_idx),'$\rho$';
    
    'CH4',C_ZERO_bc(4,1)*ones(z_idx,1),C_one_bc_data.CH4_mean(1:z_idx,r_idx),'$Y_{CH_4}$';
    
    'O2',C_ZERO_bc(5,1)*ones(z_idx,1),C_one_bc_data.O2_mean(1:z_idx,r_idx),'$Y_{O_2}$';
    
    'CO2',C_ZERO_bc(6,1)*ones(z_idx,1),C_one_bc_data.CO2_mean(1:z_idx,r_idx),'$Y_{CO_2}$';
    
    'H2O',C_ZERO_bc(7,1)*ones(z_idx,1),C_one_bc_data.H2O_mean(1:z_idx,r_idx),'$Y_{H_2O}$';
    
    'SYm_CH4',C_ZERO_bc(8,1)*ones(z_idx,1),C_ZERO_bc(8,1)*ones(z_idx,1),'$\dot{\omega}_{CH_4}$';
    
    'SYm_O2',C_ZERO_bc(9,1)*ones(z_idx,1),C_ZERO_bc(9,1)*ones(z_idx,1),'$\dot{\omega}_{O_2}$';
    
    'SYm_CO2',C_ZERO_bc(10,1)*ones(z_idx,1),C_ZERO_bc(10,1)*ones(z_idx,1),'$\dot{\omega}_{CO_2}$';
    
    'SYm_H2O',C_ZERO_bc(11,1)*ones(z_idx,1),C_ZERO_bc(11,1)*ones(z_idx,1),'$\dot{\omega}_{H_2O}$';

};

%% Load coordinate data
if ~isfolder(output_dir); mkdir(output_dir);end
%% Process each field: Load, interpolate, save, and plot
for i = 1:size(fields, 1)
    field_name = fields{i, 1};
    C_zero_bc = fields{i,2};
    C_one_bc = fields{i,3};
    latex_label = fields{i,4};

    mat_file = sprintf('%s.mat', field_name);

    try
        field_data = load(fullfile(data_dir, mat_file));
        DF = field_data.DF;
        fprintf('Loaded %s\n', mat_file);
    catch ME
        fprintf('Error loading %s: %s\n', mat_file, ME.message);
        continue;
    end
    
    figure();
    set(gcf, 'WindowState', 'maximized');
    subplot(1,2,1);
    myutils.plot_surf_field(gcf,C_MAT_o,Z_MAT_o/D, field_data.DF,'$c$','$z/D$',latex_label);

    field_w_bc = zeros(size(Z_MAT_o,1),length(C_N));
    field_w_bc(:,1) = C_zero_bc;
    field_w_bc(:,2:end-1) = field_data.DF;
    field_w_bc(:,end) = C_one_bc;
    
    DF = field_w_bc;

    if i == 1
        [C_MAT,Z_MAT] = meshgrid(C_N,Z_MAT_o(:,1));
        save(fullfile(output_dir,'CZ_data.mat'),"C_MAT","Z_MAT");
    end

    subplot(1,2,2);
    myutils.plot_surf_field(gcf,C_MAT,Z_MAT/D, DF,'$c$','$z/D$',latex_label);
    
    % Save interpolated data if enabled
    if save_data
        bc_file = sprintf('%s.mat', field_name);
        save(fullfile(output_dir, bc_file), 'DF');
        fprintf('Saved BC data to %s\n', bc_file);
    end


end
