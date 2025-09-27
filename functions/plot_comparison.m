function plot_comparison(data_dir,original_data, smoothed_data, C_MAT, Z_MAT, D, fieldsName, field_idx,save_fig_flag)
    % Plot comparison between original and smoothed data
    original_min = min(original_data.DF(:));
    original_max = max(original_data.DF(:));

    figure_handle = figure(100 + field_idx);
    set(figure_handle, 'Position', [100 + field_idx*50, 100 + field_idx*30, 1200, 500]);
    
    % Original data
    subplot(1, 2, 1);
    myutils.plot_contourf(figure_handle, C_MAT, Z_MAT/D, original_data.DF, ...
        '$c$', '$z/D$', sprintf('$\\langle %s|c\\rangle$ (Original)', fieldsName));
    title(sprintf('%s - Original', fieldsName), 'Interpreter', 'latex');
    pbaspect([1, 2, 1]);
    caxis([original_min, original_max]);
    
    % Smoothed data
    subplot(1, 2, 2);
    myutils.plot_contourf(figure_handle, C_MAT, Z_MAT/D, smoothed_data.DF, ...
        '$c$', '$z/D$', sprintf('$\\langle %s|c\\rangle$ (Smoothed)', fieldsName));
    title(sprintf('%s - Smoothed', fieldsName), 'Interpreter', 'latex');
    pbaspect([1, 2, 1]);
    caxis([original_min, original_max]);
    
    sgtitle(sprintf('Smoothing Comparison: %s', fieldsName), 'FontSize', 14);
    
    % Save comparison plot
    if save_fig_flag
        figdir = 'smoothened_figs';
        if ~isfolder(sprintf('%s/%s',data_dir,figdir));mkdir(sprintf('%s/%s',data_dir,figdir));end
                    
        saveas(figure_handle, sprintf('%s/%s/%s_smoothing_comparison.png', data_dir,figdir,fieldsName));
        saveas(figure_handle, sprintf('%s/%s/%s_smoothing_comparison.fig', data_dir,figdir,fieldsName));
    end
end