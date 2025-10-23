% Main script to create conditional statistics computation scripts for multiple fields
% This script calls write_cCond_mat_script for each specified field
clear all;
clc;

% Add functions directory to path
addpath('functions');
%%
% Define all fields to process
field_list = {
%     'Heatrelease';     
%     'density';       
%     'Temperature';  
%     'CH4';          % Mass Fraction
%     'CH2O';
%     'CH3';
%     'CO2';
%     'CO';
%     'HO2';
%     'H2';
    'H';
%     'H2O';
%     'O2'; 
%     'O';
%     'OH';
%     'N2';
       
%     'SYm_CH4';      % mass production rate
%     'SYm_O2';       
%     'SYm_CO2';      
%     'SYm_H2O';      

};
%%
node_list = [026];%001,002,004,005,007,001,002,004,015,021,
bin_size = 0.02;
c_vec = bin_size/2:bin_size:1 - bin_size/2;
% Common parameters for all fields
common_params = struct(...
    'LESStart', 201, ...
    'LESEnd', 1001, ...
    'Yu', 0.222606, ...
    'Yb', 0.0411, ...
    'c_vec', c_vec, ...
    'delC', bin_size/2, ... 
    'D', 2e-3, ...
    'xlim_factor', 5, ...
    'zlim_factor', 10, ...
    'OutputDir', 'C_cond_fields_800_10D_bin_0.02', ...
    'WorkDir', '/work/home/anindya/Anindya_Cases/CH4_jet_PF/2025_Runs/LES_base_case_v6/TB1_run', ...
    'NumWorkers', 24);
% 'WorkDir','/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/LES_base_case_v6/filtering_run3/TB1_run_with_chem_src',
%     'WorkDir', '/store1/anindya/CH4_jet_PF/2025_runs/LES_base_case_v6/TB1_run_with_chem_src', ...

fprintf('Creating conditional statistics computation scripts...\n');
fprintf('Total fields to process: %d\n\n', length(field_list));

%%

% Loop through each field and create the script
for i = 1:length(field_list)
    field_name = field_list{i};
    
    fprintf('Processing field %d/%d: %s\n', i, length(field_list), field_name);
    
    try
        % Call write_cCond_mat_script with field-specific parameters
        write_cCond_mat_script(...
            'FieldName', field_name, ...
            'LESStart', common_params.LESStart, ...
            'LESEnd', common_params.LESEnd, ...
            'Yu', common_params.Yu, ...
            'Yb', common_params.Yb, ...
            'c_vec',common_params.c_vec, ...
            'delC', common_params.delC, ...
            'D', common_params.D, ...
            'xlim_factor', common_params.xlim_factor, ...
            'zlim_factor', common_params.zlim_factor, ...
            'OutputDir', common_params.OutputDir, ...
            'WorkDir', common_params.WorkDir, ...
            'NumWorkers', common_params.NumWorkers);
        
        fprintf('  ✓ Created script: Ccond_stats_computation_%s.m\n', field_name);

        node = node_list(i);
        generate_pbs_script(field_name,node);
        
    catch ME
        fprintf('  ✗ Error creating script for %s: %s\n', field_name, ME.message);
    end
end

fprintf('\nScript generation completed!\n');
fprintf('Generated scripts can be found in the current directory.\n');
