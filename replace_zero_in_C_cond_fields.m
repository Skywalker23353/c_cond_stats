clear;clc;
close all;
addpath('~/MATLAB');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');

%% Inputs
save_results = false;
plot_results = true;
D = 2e-3;
in_data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D_coarse_bin_0.15';
out_data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D_coarse_bin_0.15/nz';
if ~isfolder(out_data_dir); mkdir(out_data_dir);end
%%
fprintf('Loading coordinate data from CZ_data.mat...\n');
try
    coord_data = load(fullfile(in_data_dir, 'CZ_data.mat'));
    C_MAT = coord_data.C_MAT;
    Z_MAT = coord_data.Z_MAT;
    fprintf('? Successfully loaded coordinate data\n');
catch ME
    fprintf('? Error loading coordinate data: %s\n', ME.message);
    fprintf('Please ensure CZ_data.mat exists in: %s\n', in_data_dir);
    return;
end
%%
fields = {
%          FILENAME,   
        'Heatrelease'; 
        'Temperature';
        'density';
        'CH4';
        'CO2';
        'H2O';
        'N2';
        'O2';
        'SYm_CH4';
        'SYm_O2';
        'SYm_CO2';
        'SYm_H2O';
        };
%%
for i = 1:length(fields)
    fname = fields{i};
    load(fullfile(in_data_dir, fname),"DF");
    DF = remove_zero_near_centerline(DF);
    if save_results
        save(fullfile(out_data_dir, fname),"DF");
    end
    if plot_results
        fh = figure();
%         field_name = fprintf('%s',fname);
        myutils.plot_surf_field(fh,C_MAT,Z_MAT/D,DF,'$c$','$z/D$',fname);
    end
end