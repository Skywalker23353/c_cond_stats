clear;clc;
addpath("~/MATLAB/")
%% Create smooth fields
saveData = 1;
work_dir = pwd;
data_dir = 'C_cond_fields_800';
window = 3;
D = 2e-3;
fieldsName = 'Heatrelease';
opfilename = sprintf("%s/%s_smooth",data_dir,fieldsName);
data = load(sprintf("%s/%s.mat",data_dir,fieldsName));
%%
alpha = 0.01;

z_idx_downstream = find((data.Z_MAT)/D >= 8.5,1);
data.DF = data.DF(1:z_idx_downstream,:);
data.C_MAT = data.C_MAT(1:z_idx_downstream,:);
data.Z_MAT = data.Z_MAT(1:z_idx_downstream,:);
smooth_field = data.DF;
%%
figure(200)
myutils.plot_field(200,data.C_MAT,data.Z_MAT/2e-3,data.DF,'$\langle  \dot{\omega}_{T}|c\rangle $');
% ylim([0 10]);
pbaspect([9 16 1]);
caxis([0 9e9]);
%%
z_axis = data.Z_MAT(:,1);
% z_idx = find((data.Z_MAT)/D >= 7,1);
z_idx = 1;
field = data.DF(z_idx:end,:);
threshold = alpha*max(max(data.DF));
field(find(field <= threshold)) = 0;
figure(202)
myutils.plot_field(202,data.C_MAT,data.Z_MAT/2e-3,field,'$\langle  \dot{\omega}_{T}|c\rangle threshold $');
% ylim([0 10]);
% caxis([0 9e9]);
pbaspect([9 16 1]);
%%
temp_f = myutils.f_return_smooth_field(field,window,'row');
temp_f = myutils.f_return_smooth_field(temp_f,window,'col');
temp_f = myutils.f_return_smooth_field(temp_f,window,'row');
temp_f = myutils.f_return_smooth_field(temp_f,window,'col');%smoothed twice
smooth_field(z_idx:end,:) = temp_f; 
data.DF = smooth_field;
%%
figure(203)
myutils.plot_field(203,data.C_MAT,data.Z_MAT/2e-3,smooth_field,'$\langle  \dot{\omega}_{T}|c\rangle $');
% ylim([0 10]);
caxis([0 9e9]);
pbaspect([9 16 1]);
% %%
% figure(202)
% myutils.plot_field(202,data.C_MAT,data.Z_MAT/2e-3,data.DF_nz,'$\langle  \dot{\omega}_{T}|c\rangle $');
% ylim([0 10]);
% % caxis([0 2200]);
% pbaspect([9 16 1]);
%%
if saveData
    save(sprintf("%s.mat",opfilename),'-struct',"data");
end


