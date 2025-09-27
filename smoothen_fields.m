clear;clc;
close all;
addpath('~/MATLAB');
addpath('/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/functions/');

%% Inputs
save_results_flag = false;
save_results_flag_final = false;
plot_results_flag = true;
plot_surface_flag = true;
save_figs = false;
clamp_boundary_flag = true;
data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D';
%% DONE ONCE
% fields = {'SYm_CH4';'SYm_O2';'SYm_CO2';'SYm_H2O'};
% bc_config = struct('width', 1, 'boundaries', {{'left', 'right'}});
% process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', fields, ...
%                                       'BoundaryConfig', bc_config,'SaveOutput', true);
%%
fields = {
%          FILENAME,          LATEX NAME,                           FIG NAME, WINDOW, N_CYCLES
        'Heatrelease', '$\langle \dot{\omega}_{T}|c\rangle$', 3,3;%7, 3;
        'Temperature', '$\langle T|c\rangle$', 3,3;%9, 3;
        'density','$\langle \rho|c\rangle$', 3,3;%11, 3;
%         'CH2O','$\langle CH2O|c\rangle$', 3, 3;
%         'CH3','$\langle CH3|c\rangle$', 3, 3;
        'CH4','$\langle CH4|c\rangle$', 3,3;%11, 3;
%         'CO','$\langle CO|c\rangle$', 3, 3;
        'CO2','$\langle CO2|c\rangle$', 3, 3;
%         'H','$\langle H|c\rangle$', 3, 3;
        'H2O','$\langle H2O|c\rangle$', 3, 3;
%         'HO2','$\langle HO2|c\rangle$', 3, 3;
%         'N2','$\langle N2|c\rangle$', 3, 3;
%         'O','$\langle O|c\rangle$', 3, 3;
        'O2','$\langle O2|c\rangle$', 3, 3;
%         'OH','$\langle OH|c\rangle$', 3, 3;
%         'H2','$\langle H2|c\rangle$', 3, 3;
        'SYm_CH4','$\langle \dot{\omega}_{CH_4}|c\rangle$', 3, 3;
        'SYm_O2','$\langle \dot{\omega}_{O_2}|c\rangle$', 3,3;%5, 3;%5,3
        'SYm_CO2','$\langle \dot{\omega}_{CO_2}|c\rangle$', 3, 3;
        'SYm_H2O','$\langle \dot{\omega}_{H_2O}|c\rangle$', 3,3;%9, 3;%9,3
        };

% batch_smooth_fields(data_dir, save_results_flag, fields, plot_results_flag,plot_surface_flag,save_figs);
% With boundary ignoring
batch_smooth_fields('DataDir', data_dir, 'Fields', fields, 'PlotResults', true, ...
                   'SaveOutput', save_results_flag,'PlotSurf', plot_surface_flag, 'SaveFigs', save_figs);
%% DONE ONCE
if clamp_boundary_flag
    fields = {'SYm_CH4_smooth';'SYm_O2_smooth';'SYm_CO2_smooth';'SYm_H2O_smooth'};
    bc_config = struct('width', 1, 'boundaries', {{'left', 'right'}});
    process_fields_with_boundary_zeroing('DataDir', data_dir, 'Fields', fields, ...
                                          'PlotResults', true, 'BoundaryConfig', bc_config, 'SaveOutput', false);
end
% Define fields with their boundary values
fields = {
    'Temperature_smooth', struct('left', 800, 'right', 2319);
    'density_smooth', struct('left', 0.5, 'right', 1.2);
    'CH4_smooth', struct('left', 0.0, 'right', 0.1);
    'O2_smooth', struct('left', 0.21, 'right', 0.0);
    'CO2_smooth', struct('left', 0.0, 'right', 0.0);
    'H2O_smooth', struct('left', 0.0, 'right', 0.0);
};

% Process the fields
process_fields_with_boundary_values('DataDir', data_dir, 'Fields', fields, ...
                                   'PlotResults', true, 'BoundaryWidth', 1, 'SaveOutput', false);
%%
fields = {
%          FILENAME,          LATEX NAME,                           FIG NAME, WINDOW, N_CYCLES
        'Heatrelease_boundary_set', '$\langle \dot{\omega}_{T}|c\rangle$', 3,3;%7, 3;
        'Temperature_boundary_set', '$\langle T|c\rangle$', 3,3;%9, 3;
        'density_boundary_set','$\langle \rho|c\rangle$', 3,3;%11, 3;
        'CH4_boundary_set','$\langle CH4|c\rangle$', 3,3;%11, 3;
        'CO2_boundary_set','$\langle CO2|c\rangle$', 3, 3;
        'H2O_boundary_set','$\langle H2O|c\rangle$', 3, 3;
        'O2_boundary_set','$\langle O2|c\rangle$', 3, 3;
        };
batch_smooth_fields('DataDir', data_dir, 'Fields', fields, 'PlotResults', true, ...
                   'SaveOutput', save_results_flag_final,'PlotSurf', plot_surface_flag, 'SaveFigs', save_figs, ...
                   'IgnoreBoundaries', {'left', 'right'}, 'BoundaryWidth', 1);
