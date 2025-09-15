function plot_fields_separately(data_dir,fields,C_MAT,Z_MAT,save_fig,plot_smooth_flag)
    D = 2e-3; % Diameter scaling factor
    
    for i = 1:size(fields, 1)
        if plot_smooth_flag
            filename = sprintf('%s_smooth.mat', fields{i, 1});
        else
            filename = sprintf('%s.mat', fields{i, 1});
        end
        colorbar_label = fields{i, 2};
        fig_name = fields{i, 3};
        
        filepath = sprintf("%s/%s", data_dir, filename);
        if exist(filepath, 'file')
            data = load(filepath);
            
            % Create separate figure for each field
            fidx = 10 + i;
            figure(fidx);
            
            if isfield(data, 'DF')
                myutils.plot_contourf(fidx, C_MAT, Z_MAT/D, data.DF, '$c$', '$z/D$', colorbar_label);
                pbaspect([8 16 1]);
                
                % Save individual figure
                if save_fig
                    if plot_smooth_flag
                        if ~isfolder(sprintf('%s/Figs_smooth',data_dir));mkdir(sprintf('%s/Figs_smooth',data_dir));end
                        saveas(gcf, sprintf('%s/Figs_smooth/%s.png', data_dir,fig_name));
                        saveas(gcf, sprintf('%s/Figs_smooth/%s.fig', data_dir,fig_name));
                        fprintf('Saved %s.png and .fig\n', fig_name);
                    else
                        if ~isfolder(sprintf('%s/Figs',data_dir));mkdir(sprintf('%s/Figs',data_dir));end
                        saveas(gcf, sprintf('%s/Figs/%s.png', data_dir,fig_name));
                        saveas(gcf, sprintf('%s/Figs/%s.fig', data_dir,fig_name));
                        fprintf('Saved %s.png and .fig\n', fig_name);
                    end
                end

            end
        else
            fprintf("Skipping %s fields\n",filename);
        end

    end
end