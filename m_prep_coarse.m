clear;clc;
%%
data_dir = '/work/home/satyam/satyam_files/CH4_jet_PF/2025_Runs/c_cond_stats/C_cond_fields_800_10D_bin_0.02/bckup';
fields = {'Heatrelease','density','Temperature','CH4','O2','CO2','H2O','SYm_CH4','SYm_O2','SYm_CO2','SYm_H2O'};
save_flag = true;


batch_interp_fields(data_dir, save_flag, fields);

%%
function batch_interp_fields(data_dir, save_flag, field_list)
    % Convenience function for batch processing
    if nargin < 3
        field_list = {};
    end
    
    f_interp_fields('DataDir', data_dir, 'Fields', field_list, ...
                   'SaveOutput', save_flag);
end

function f_interp_fields(varargin)
    % Parse input arguments
    p = inputParser;
    addParameter(p, 'DataDir', 'C_cond_fields_800', @ischar);
    addParameter(p, 'Fields', {}, @iscell);
    addParameter(p, 'AutoDetect', false, @islogical);
    addParameter(p, 'SaveOutput', false, @islogical);

    
    parse(p, varargin{:});
    
    data_dir = p.Results.DataDir;
    specified_fields = p.Results.Fields;
    auto_detect = p.Results.AutoDetect;
    save_output = p.Results.SaveOutput;
    
    % Load target coordinate data
    coord_file = sprintf("%s/CZ_data.mat", data_dir);
    if exist(coord_file, 'file')
        coord_data = load(coord_file);
        C_MAT_t = coord_data.C_MAT;
        Z_MAT_t = coord_data.Z_MAT;
    else
        fprintf('Warning: Coordinate file %s not found. Using default coordinates.\n', coord_file);
        C_MAT_t = [];
        Z_MAT_t = [];
    end
    
    D = 2e-3;
    
    % Determine which fields to process
    if auto_detect && isempty(specified_fields)
        % Auto-detect all .mat files in the directory
        if exist(data_dir, 'dir')
            mat_files = dir(fullfile(data_dir, '*.mat'));
            field_names = {};
            for i = 1:length(mat_files)
                [~, name, ~] = fileparts(mat_files(i).name);
                % Skip coordinate files and already smoothed files
                if ~contains(name, 'final') && ~strcmp(name, 'Heatrelease')
                    field_names{end+1} = name;
                end
            end
        else
            error('Data directory %s not found!', data_dir);
        end
    elseif ~isempty(specified_fields)
        field_names = specified_fields;
    else
        % Default to CH4 field
        field_names = {'SYm_CH4'};
    end
    
    fprintf('Processing %d fields \n', length(field_names));
    
    % Process each field
    coord_file = sprintf("%s/CZ_data_fine.mat", data_dir);
    if exist(coord_file, 'file')
        coord_data = load(coord_file);
        C_MAT_i = coord_data.C_MAT;
    else
        fprintf('Warning: Coordinate file %s not found. Using default coordinates.\n', coord_file);
        C_MAT_i = [];
    end
    for i = 1:length(field_names)
        fieldsName = field_names{i};
        fprintf('Processing field %d/%d: %s\n', i, length(field_names), fieldsName);
        
        % Define input and output filenames
        input_file = sprintf("%s/%s.mat", data_dir, fieldsName);
        opfilename = sprintf("%s/%s_final", data_dir, fieldsName);
        
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
            
            % Apply smoothing operation
            fprintf('  Interpolating...\n');
            interp_data = zeros(size(C_MAT_t));
            for z = 1:size(Z_MAT_t, 1)
                if mod(z, 10) == 0 || z == 1 || z == size(Z_MAT_t, 1)
                    fprintf('    Processing Z level %d/%d...\n', z, size(Z_MAT_t, 1));
                end
                interp_data(z, :) = down_sample_field(C_MAT_t(z, :)', ...
                                                          C_MAT_i(z, :)', ...
                                                          data.DF(z, :)');
            end
            
            % Save smoothed data
            DF = interp_data;clear interp_data;
            if save_output
                fprintf('  Saving to %s.mat\n', opfilename);
                save(sprintf('%s.mat', opfilename), 'DF');
            end
            
            
        catch ME
            fprintf('Error processing %s: %s\n', fieldsName, ME.message);
            continue;
        end
    end
    
    fprintf('Interpolation complete for all fields!\n');
end