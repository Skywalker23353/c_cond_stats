function plot_surf_field(data_dir,F_MAT,C_MAT,Z_MAT,D,fieldsName,fieldsfigLabel,save_fig,idx)
        colorbar_label = fieldsfigLabel;
        fig_name = fieldsName;
        % Create separate figure for each field
        fidx = 40 + idx;
        figure(fidx);
        myutils.plot_surf_field(fidx, C_MAT, Z_MAT/D, F_MAT, '$c$', '$z/D$', colorbar_label);

        % Save individual figure
        if save_fig
            if ~isfolder(sprintf('%s/Figs_smooth',data_dir));mkdir(sprintf('%s/Figs_smooth',data_dir));end
            saveas(gcf, sprintf('%s/Figs_smooth/%s.png', data_dir,fig_name));
            saveas(gcf, sprintf('%s/Figs_smooth/%s.fig', data_dir,fig_name));
            fprintf('Saved %s.png and .fig\n', fig_name);
        end
        
end