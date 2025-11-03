function f_smoothen_fields(varargin)
% F_SMOOTHEN_FIELDS - Apply smoothing to CFD field data with optional boundary ignoring
%
% SYNTAX:
%   f_smoothen_fields('DataDir', data_dir, 'Fields', field_configs)
%   f_smoothen_fields('DataDir', data_dir, 'Fields', field_configs, 'IgnoreBoundaries', {'left', 'right'})
%
% INPUTS:
%   Required Name-Value pairs:
%   'DataDir'       - Path to directory containing field .mat files
%   'Fields'        - Cell array of field configurations with columns:
%                     {field_name, fig_label, window_size, n_cycles}
%
%   Optional Name-Value pairs:
%   'AutoDetect'    - Auto-detect fields from directory (default: false)
%   'SaveOutput'    - Save smoothed fields (default: false)
%   'PlotResults'   - Generate comparison plots (default: false)
%   'PlotSurf'      - Generate surface plots (default: false)
%   'SaveFigs'      - Save generated figures (default: false)
%   'IgnoreBoundaries' - Cell array of boundaries to ignore during smoothing
%                        Options: 'left', 'right', 'top', 'bottom', 'all'
%                        Default: {} (no boundaries ignored)
%   'BoundaryWidth' - Width of boundary region to ignore (default: 1)
%                     Can be scalar or 4-element vector [top, bottom, left, right]
%
% EXAMPLES:
%   % Standard smoothing
%   fields = {'Temperature', '$\langle T|c\rangle$', 3, 3};
%   f_smoothen_fields('DataDir', data_dir, 'Fields', {fields}, 'SaveOutput', true);
%
%   % Smoothing while ignoring left and right boundaries
%   f_smoothen_fields('DataDir', data_dir, 'Fields', {fields}, ...
%                    'IgnoreBoundaries', {'left', 'right'}, 'SaveOutput', true);
%
%   % Ignore all boundaries with custom width
%   f_smoothen_fields('DataDir', data_dir, 'Fields', {fields}, ...
%                    'IgnoreBoundaries', 'all', 'BoundaryWidth', 2, 'SaveOutput', true);
    % Parse input arguments
    p = inputParser;
    addParameter(p, 'DataDir', 'C_cond_fields_800', @ischar);
    addParameter(p, 'Fields', {}, @iscell);
    addParameter(p, 'AutoDetect', false, @islogical);
    addParameter(p, 'SaveOutput', false, @islogical);
    addParameter(p, 'PlotResults', false, @islogical);
    addParameter(p, 'PlotSurf', false, @islogical);
    addParameter(p, 'SaveFigs', false, @islogical);
    addParameter(p, 'IgnoreBoundaries', {}, @(x) iscell(x) || ischar(x) || isstring(x));
    addParameter(p, 'BoundaryWidth', 1, @(x) isnumeric(x) && all(x > 0) && (isscalar(x) || length(x) == 4));
    
    parse(p, varargin{:});
    
    data_dir = p.Results.DataDir;
    specified_fields = p.Results.Fields(:,1);
    specified_fields_fig_labels = p.Results.Fields(:,2);
    if size(p.Results.Fields,2) >= 4
        specified_windows = cell2mat(p.Results.Fields(:,3));
        specified_n_cycles = cell2mat(p.Results.Fields(:,4));
    else
        % Default values if not specified
        specified_windows = repmat(3, size(p.Results.Fields,1),1);
        specified_n_cycles = repmat(3, size(p.Results.Fields,1),1);
    end
    auto_detect = p.Results.AutoDetect;
    save_output = p.Results.SaveOutput;
    plot_results = p.Results.PlotResults;
    plot_surf_flag = p.Results.PlotSurf;
    save_fig_flag = p.Results.SaveFigs;
    ignore_boundaries = p.Results.IgnoreBoundaries;
    boundary_width = p.Results.BoundaryWidth;
    
    % Process ignore_boundaries parameter
    if ischar(ignore_boundaries) || isstring(ignore_boundaries)
        if strcmpi(ignore_boundaries, 'all')
            ignore_boundaries = {'top', 'bottom', 'left', 'right'};
        else
            ignore_boundaries = {char(ignore_boundaries)};
        end
    elseif isempty(ignore_boundaries)
        ignore_boundaries = {};
    end
    
    alpha = 1;
    
    % Load coordinate data
    coord_file = sprintf("%s/CZ_data.mat", data_dir);
    if exist(coord_file, 'file')
        coord_data = load(coord_file);
        C_MAT = coord_data.C_MAT;
        Z_MAT = coord_data.Z_MAT;
    else
        fprintf('Warning: Coordinate file %s not found. Using default coordinates.\n', coord_file);
        C_MAT = [];
        Z_MAT = [];
    end
    
    D = 2e-3;
    
    % Determine which fields to process
    if auto_detect && isempty(specified_fields)
        % Auto-detect all .mat files in the directory
        if exist(data_dir, 'dir')
            mat_files = dir(fullfile(data_dir, '*.mat'));
            field_names = {};
            field_fig_labels = {};
            field_windows = [];
            field_n_cycles = [];
            for i = 1:length(mat_files)
                [~, name, ~] = fileparts(mat_files(i).name);
                % Skip coordinate files and already smoothed files
                if ~contains(name, 'smooth') && ~strcmp(name, 'Heatrelease')
                    field_names{end+1} = name;
                    field_fig_labels{end+1} = name; % Default label
                    field_windows(end+1) = 3; % Default
                    field_n_cycles(end+1) = 3; % Default
                end
            end
        else
            error('Data directory %s not found!', data_dir);
        end
    elseif ~isempty(specified_fields)
        field_names = specified_fields;
        field_fig_labels = specified_fields_fig_labels;
        field_windows = specified_windows;
        field_n_cycles = specified_n_cycles;
    else
        % Default to Temperature field
        field_names = {'Temperature'};
        field_fig_labels = {'Temperature'};
        field_windows = 3;
        field_n_cycles = 3;
    end
    
    fprintf('Processing %d fields\n', length(field_names));
    
    % Process each field
    for i = 1:length(field_names)
        fieldsName = field_names{i};
        fieldsfigLabel = field_fig_labels{i};
        fprintf('Processing field %d/%d: %s with window=%d, n_cycles=%d\n', i, length(field_names), fieldsName, field_windows(i), field_n_cycles(i));
        
        % Define input and output filenames
        input_file = sprintf("%s/%s.mat", data_dir, fieldsName);
        opfilename = sprintf("%s/%s_smooth", data_dir, fieldsName);
        
        % Check if input file exists
        if ~exist(input_file, 'file')
            fprintf('Warning: Input file %s not found. Skipping.\n', input_file);
            continue;
        end
        
        % Load data
        try
            data = load(input_file);
            
            if ~isfield(data, 'DF')
                fprintf('Warning: Field DF not found in %s. Skipping.\n', input_file);
                continue;
            end
            if strcmp(fieldsName,'Heatrelease')
                fprintf('Thresholding Heatrelease using alpha %e',alpha);
                data.DF = threshold_data(data,alpha);
            end
            data.fieldname = fieldsName;
            % Apply smoothing operation
            fprintf('  Applying smoothing...\n');
            if isempty(ignore_boundaries)
                % Standard smoothing
                smoothed_data = apply_smoothing_and_populate_non_zero_data(data, field_windows(i),field_n_cycles(i));
            else
                % Smoothing with boundary ignoring
                smoothed_data = apply_smoothing_ignore_boundaries(data, field_windows(i), ignore_boundaries, boundary_width);
            end
            
            % Save smoothed data
            if save_output
                fprintf('  Saving to %s.mat\n', opfilename);
                save(sprintf('%s.mat', opfilename), '-struct', 'smoothed_data');
            end
            
            % Optional plotting
            if plot_results && ~isempty(C_MAT) && ~isempty(Z_MAT)
                plot_comparison(data_dir,data, smoothed_data, C_MAT, Z_MAT, D, fieldsName, i,save_fig_flag);
            elseif plot_surf_flag && ~isempty(C_MAT) && ~isempty(Z_MAT)
%                     plot_surf_field(data_dir,data.DF,C_MAT,Z_MAT,D,fieldsName,fieldsfigLabel,save_fig_flag,i*30);
                    plot_surf_field(data_dir,smoothed_data.DF,C_MAT,Z_MAT,D,fieldsName,fieldsfigLabel,save_fig_flag,4*i);
            end
            
        catch ME
            fprintf('Error processing %s: %s\n', fieldsName, ME.message);
            continue;
        end
    end
    
    fprintf('Smoothing complete for all fields!\n');
end

