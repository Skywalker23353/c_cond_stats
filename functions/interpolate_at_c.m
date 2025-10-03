function [DF_interp, C_interp, Z_interp] = interpolate_at_c(DF, C_MAT, Z_MAT, C_n)
    % Interpolate field data DF at specified progress variable values C_n
    % Inputs:
    %   DF: nz x nc matrix of field values
    %   C_MAT: nz x nc matrix of c-coordinates (constant along rows)
    %   Z_MAT: nz x nc matrix of z-coordinates (constant along columns)
    %   C_n: vector of c-values for interpolation (between 0 and 1)
    % Outputs:
    %   DF_interp: nz x length(C_n) interpolated field values
    %   C_interp: nz x length(C_n) interpolated c-coordinates
    %   Z_interp: nz x length(C_n) interpolated z-coordinates
    
    % Extract unique z and c vectors
    z_vec = Z_MAT(:, 1);  % nz x 1, z-locations
    c_vec = C_MAT(1, :);  % 1 x nc, c-locations
    
    % Initialize interpolated matrices
    nz = length(z_vec);
    nc_n = length(C_n);
    DF_interp = zeros(nz, nc_n);
    C_interp = repmat(C_n(:)', nz, 1);  % nz x nc_n
    Z_interp = repmat(z_vec, 1, nc_n);  % nz x nc_n
    
    % Interpolate for each z-location
    for i = 1:nz
        DF_interp(i, :) = interp1(c_vec, DF(i, :), C_n, 'linear', 'extrap');
    end
end
