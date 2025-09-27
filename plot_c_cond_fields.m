clear;clc;
% close all;
addpath('~/MATLAB/');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');
%%
save_fig = false;
plot_smooth_data = true;
data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D';
    fields = {
%          FILENAME,          LATEX NAME,                           FIG NAME
        'Heatrelease', '$\langle \dot{\omega}_{T}|c\rangle$', 'Heat Release Rate';
        'Temperature', '$\langle T|c\rangle$', 'Temperature';
        'density','$\langle \rho|c\rangle$', 'density';
%         'CH2O','$\langle CH2O|c\rangle$', 'CH2O';
%         'CH3','$\langle CH3|c\rangle$', 'CH3';
%         'CH4','$\langle CH4|c\rangle$', 'CH4';
%         'CO','$\langle CO|c\rangle$', 'CO';
%         'CO2','$\langle CO2|c\rangle$', 'CO2';
%         'H','$\langle H|c\rangle$', 'H';
%         'H2O','$\langle H2O|c\rangle$', 'H2O';
%         'HO2','$\langle HO2|c\rangle$', 'HO2';
%         'N2','$\langle N2|c\rangle$', 'N2';
%         'O','$\langle O|c\rangle$', 'O';
%         'O2','$\langle O2|c\rangle$', 'O2';
%         'OH','$\langle OH|c\rangle$', 'OH';
%         'H2','$\langle H2|c\rangle$', 'H2';
% 
%         'SYm_CH4','$\langle \dot{\omega}_{CH_4}|c\rangle$', 'SYm_CH4';
%         'SYm_O2','$\langle \dot{\omega}_{O_2}|c\rangle$', 'SYm_O2';
%         'SYm_CO2','$\langle \dot{\omega}_{CO_2}|c\rangle$', 'SYm_CO2';
%         'SYm_H2O','$\langle \dot{\omega}_{H_2O}|c\rangle$', 'SYm_H2O';

        };
    %% Load coordinate data (C_MAT and Z_MAT)
fprintf('Loading coordinate data from CZ_data.mat...\n');
try
    coord_data = load(fullfile(data_dir, 'CZ_data.mat'));
    C_MAT = coord_data.C_MAT;
    Z_MAT = coord_data.Z_MAT;
    fprintf('? Successfully loaded coordinate data\n');
catch ME
    fprintf('? Error loading coordinate data: %s\n', ME.message);
    fprintf('Please ensure CZ_data.mat exists in: %s\n', data_dir);
    return;
end
%%
% Main execution
% plot_fields_separately(data_dir,fields,C_MAT,Z_MAT,save_fig,plot_smooth_data);
plot_surf_fields_separately(data_dir,fields,C_MAT,Z_MAT,save_fig,plot_smooth_data);


