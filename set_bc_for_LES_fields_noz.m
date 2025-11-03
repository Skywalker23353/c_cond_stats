clear; clc;
close all;
addpath('~/MATLAB/');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');

%% Configuration
save_data = false;  % New flag to save interpolated data to disk
%% Paths
data_dir = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats' ...
    '/C_cond_fields_800_10D_bin_0.02/noz'];
output_dir = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats' ...
    '/C_cond_fields_800_10D_bin_0.02/noz/BC'];
C_one_bc_file_path = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs' ...
    '/derivatives_files/Interpolate_derivs_on_R_Z_plane' ...
    '/interp_16_unilat_structured_pl_nozzle_domain_with_zero/interp_fields'];
R_Z_file_path = ['/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs' ...
    '/derivatives_files/Interpolate_derivs_on_R_Z_plane'];
%% parameters
D = 2e-3;
c_one_bc_r = D;
%%
fprintf('Loading coordinate data from CZ_data.mat...\n');
try
    coord_data = load(fullfile(data_dir, 'CZ_data.mat'));
    C_MAT_Old = coord_data.C_MAT;
    Z_MAT_Old = coord_data.Z_MAT;
    fprintf('Successfully loaded coordinate data\n');
catch ME
    fprintf('Error loading coordinate data: %s\n', ME.message);
    fprintf('Please ensure CZ_data.mat exists in: %s\n', data_dir);
    return;
end

C_New = [0.0, C_MAT_Old(1,:), 1.0];
%% Load C_equals_one BC value
try
    C_one_bc_data = load(fullfile(C_one_bc_file_path, 'YO2_field_structured_grid_16_planes_1011260202_avg.mat'));
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
r_idx = find(abs(R_Z_data.R2(1,:) - c_one_bc_r) <= 1e-6,1);
n_z_idx = size(Z_MAT_Old,1);
%% Load Boundary configuration file
fields = load_BC_config_file_noz(C_one_bc_data,r_idx,n_z_idx);

%%
if ~isfolder(output_dir); mkdir(output_dir);end
%% Process each field: Load, interpolate, save, and plot
for i = 1:size(fields, 1)
    field_name = fields{i, 1};
    C_zero_bc = fields{i,2};
    C_zero_bc = C_zero_bc*ones(n_z_idx,1);
    C_one_bc = fields{i,3};
    if length(C_one_bc) <=1
        C_one_bc = C_one_bc*ones(n_z_idx,1);
    end
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
    myutils.plot_surf_field(gcf,C_MAT_Old,Z_MAT_Old/D, field_data.DF,'$c$','$z/D$',latex_label);

    field_w_bc = zeros(size(Z_MAT_Old,1),length(C_New));
    field_w_bc(:,1) = C_zero_bc;
    field_w_bc(:,2:end-1) = field_data.DF;
    field_w_bc(:,end) = C_one_bc;
    
    DF = field_w_bc;

    if i == 1
        [C_MAT,Z_MAT] = meshgrid(C_New,Z_MAT_Old(:,1));
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
