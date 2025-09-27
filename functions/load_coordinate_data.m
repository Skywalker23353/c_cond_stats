function [C_MAT, Z_MAT] = load_coordinate_data(data_dir)
% Load coordinate data from the data directory

coord_file = sprintf('%s/CZ_data.mat', data_dir);
if exist(coord_file, 'file')
    fprintf('Loading coordinate data from %s\n', coord_file);
    coord_data = load(coord_file);
    C_MAT = coord_data.C_MAT;
    Z_MAT = coord_data.Z_MAT;
else
    fprintf('Warning: Coordinate file %s not found. Plots will be skipped.\n', coord_file);
    C_MAT = [];
    Z_MAT = [];
end
end