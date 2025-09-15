function figure1 = plot_profile_box_fig(X1,Y1,valstr)
%CREATEFIGURE(X1, Y1, X2, Y2)
%  X1:  vector of x data
%  Y1:  vector of y data
%  X2:  vector of x data
%  Y2:  vector of y data

% Create figure
figure1 = figure;
set(gcf,'Position',[100 100 800 800]);
axes1 = axes('Parent',figure1,...
    'Position',[0.395 0.285 0.585 0.585]);
hold(axes1,'on');

lw = 2;

plot(X1,Y1,'k-','MarkerSize',15,'LineWidth',3);
% Create xlabel
xlabel('$c$','Interpreter','latex');

% Create ylabel
ylabel(valstr,'Interpreter','latex');

% Uncomment the following line to preserve the X-limits of the axes
xlim(axes1,[0 1]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',60,'XGrid','on','YGrid','on');
set(gca,'TickLabelInterpreter','latex')
%hl = legend('show');
%set(hl,...
%     'Position',[0.69995307896426 0.709368199668418 0.28041732142367 0.288888880474116],...
%     'Interpreter','latex',...
%     'FontSize',45);


