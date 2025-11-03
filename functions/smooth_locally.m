function Tclean = smooth_locally(Z, C, T, z_range, c_range,window,varargin)
%SMOOTH_LOCAL_ANOMALY  Smooth anomalies in a local region of T(Z,C)
%
%   Tclean = smooth_local_anomaly(Z, C, T, z_range, c_range)
%
%   Inputs:
%       Z, C     : Meshgrid matrices (same size as T)
%                   - Each row of Z is a constant z value
%                   - Each column of C is a constant c value
%       T        : Temperature (or scalar field) matrix
%       z_range  : [zmin, zmax] region in Z (inclusive)
%       c_range  : [cmin, cmax] region in C (inclusive)
%
%   Output:
%       Tclean   : Smoothed temperature matrix (only local region modified)
%
%   Notes:
%    - The function avoids plotting.
%    - It is defensive about small subregions and edge cells.
%    - If a local replacement cannot be computed, it falls back to the
%      median of the entire subregion (omitnan).
%
%   Example:
%       Tclean = smooth_local_anomaly(Z, C, T, [7 9], [0 0.2]);
        
    if nargin > 6
     limit = varargin{1};
    else
        limit = 0;
    end
    % Validate sizes
    if ~isequal(size(Z), size(C), size(T))
        error('Z, C and T must be the same size.');
    end

    % Copy original
    Tclean = T;

    % Build ROI and find bounding box
    roi = (Z >= z_range(1) & Z <= z_range(2)) & ...
          (C >= c_range(1) & C <= c_range(2));

    [i_idx, j_idx] = find(roi);
    if isempty(i_idx)
        warning('smooth_local_anomaly:NoPoints', 'No points found in specified z/c region. Returning original T.');
        return;
    end

    i_min = min(i_idx); i_max = max(i_idx);
    j_min = min(j_idx); j_max = max(j_idx);

    % Extract submatrix
    Tsub = T(i_min:i_max, j_min:j_max);
    if limit
        Tsub(Tsub < limit) = limit;
    end
    % If submatrix is all NaN/Inf, warn and return
    if all(isnan(Tsub(:)) | isinf(Tsub(:)))
        warning('smooth_local_anomaly:AllBad', 'Subregion is all NaN or Inf. Returning original T.');
        return;
    end

    Tsub = apply_smoothing_ignore_boundaries(Tsub, window, 'left', 1);

%     Tsub = myutils.f_return_smooth_field(Tsub,window,'row');
%     Tsub = myutils.f_return_smooth_field(Tsub,window,'col');

    % Put corrected submatrix back
    Tclean(i_min:i_max, j_min:j_max) = Tsub;
end
