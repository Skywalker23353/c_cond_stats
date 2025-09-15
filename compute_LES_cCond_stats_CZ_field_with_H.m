clear all;
clc;
%% Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LES_start_idx = 200;    LES_end_idx = 800;
Yu = 0.222606; Yb = 0.0423208;
Y = [Yu,Yb];
delC = 0.0125;  C = (0.0:1e-2:1.0)';
D = 2e-3;   x_lim = 5*D;    z_lim = 8.5*D;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opDirName = 'C_cond_fields_800';
if ~isfolder(opDirName); mkdir(opDirName);end
% wkdir = '/store1/anindya/CH4_jet_PF/2025_runs/LES_base_case_v6/TB1_run';
wkdir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/LES_base_case_v6/filtering_run3/TB1_run';
tic;
parpool('local',12)
% disp(gcp)
%%
field_name ='H';
[Na,Nc,R0,C_r,C_z] = getplanar_grid(wkdir,x_lim);
z_axis = squeeze(C_z(floor(Nc(1)/2)+1,floor(Nc(2)/2)+1,:));
z_lim_idx = find(z_axis > z_lim,1);
C_r = C_r(:,:,1:z_lim_idx);C_z = C_z(:,:,1:z_lim_idx);
Na(3) = z_lim_idx;Nc(3) = z_lim_idx;
%%
[Z,DF] = getplanar_cCond_Dist_O2_LES_parallel2(wkdir,field_name,D,Na,Nc,R0,C_r,C_z,LES_start_idx,LES_end_idx,Y,C,delC);
[C_MAT,Z_MAT] = meshgrid(C,Z);
DF = DF';

save(sprintf('%s/%s.mat',opDirName,field_name),"DF");
%%
fprintf("ALL FIELDS COMPUTED");


