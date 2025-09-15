clear;clc;
% close all;
%%
addpath("~/MATLAB/");
D = 2e-3;
%% Plot all C_cond statistics
data_dir = 'C_cond_fields_800';
hrr = load(sprintf("%s/Heatrelease_smooth.mat",data_dir));
Temp = load(sprintf("%s/Temperature_smooth.mat",data_dir));
CH4 = load(sprintf("%s/CH4.mat",data_dir));
CO2 = load(sprintf("%s/CO2.mat",data_dir));
%%
z_vec = hrr.Z_MAT(:,1);
zidx = find(z_vec > 2e-3,1);
fsz = 40;
figure(20)
plot(hrr.C_MAT(1,:),hrr.DF(zidx,:),'-bx','MarkerSize',15,'LineWidth',2,'DisplayName','$\frac{z}{D} = 1.0$');hold on;
zidx = find(z_vec > 4e-3,1);
plot(hrr.C_MAT(1,:),hrr.DF(zidx,:),'-rx','MarkerSize',15,'LineWidth',2,'DisplayName','$\frac{z}{D} = 2.0$');
zidx = find(z_vec > 10e-3,1);
plot(hrr.C_MAT(1,:),hrr.DF(zidx,:),'-kx','MarkerSize',15,'LineWidth',2,'DisplayName','$\frac{z}{D} = 5.0$');
xlabel('$c$','Interpreter','latex','FontSize',fsz);
ylabel('$\langle \dot{\omega}_{T}|c\rangle $','Interpreter','latex','FontSize',fsz);
set(findall(gcf,'-property','Fontsize'),'Fontsize',fsz);
legend('Interpreter','latex');
grid on ;
hold off;
%%
% %
% z_vec = Temp.Z_MAT(:,1);
% zidx = find(z_vec > 2e-3,1);
% fsz = 40;
% figure(21)
% plot(Temp.C_MAT(1,:),Temp.DF(zidx,:),'-bx','MarkerSize',15,'LineWidth',2,'DisplayName','$\frac{z}{D} = 1.0$');hold on;
% zidx = find(z_vec > 4e-3,1);
% plot(Temp.C_MAT(1,:),Temp.DF(zidx,:),'-rx','MarkerSize',15,'LineWidth',2,'DisplayName','$\frac{z}{D} = 2.0$');
% zidx = find(z_vec > 10e-3,1);
% plot(Temp.C_MAT(1,:),Temp.DF(zidx,:),'-kx','MarkerSize',15,'LineWidth',2,'DisplayName','$\frac{z}{D} = 5.0$');
% xlabel('$c$','Interpreter','latex','FontSize',fsz);
% ylabel('$\langle T|c\rangle $','Interpreter','latex','FontSize',fsz);
% set(findall(gcf,'-property','Fontsize'),'Fontsize',fsz);
% legend('Interpreter','latex');
% grid on ;
% hold off;