function Tclean = smooth_local_anomaly(Z, C, T, z_range, c_range,window)
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

    % If submatrix is all NaN/Inf, warn and return
    if all(isnan(Tsub(:)) | isinf(Tsub(:)))
        warning('smooth_local_anomaly:AllBad', 'Subregion is all NaN or Inf. Returning original T.');
        return;
    end

    % Compute local variation safely (handle very small dims)
    % Use window length 3 if dimension >=3, otherwise use the full dimension
    k_z = min(window, size(Tsub,1));
    k_c = min(window, size(Tsub,2));

    % movmean handles k = 1 (returns original values)
    dTz = abs(Tsub - movmean(Tsub, k_z, 1));  % variation along z (rows)
    dTc = abs(Tsub - movmean(Tsub, k_c, 2));  % variation along c (cols)
    dT  = dTz + dTc;

    % Local threshold (omit NaNs in std)
    st = std(Tsub(:), 'omitnan');
    if st == 0 || isnan(st)
        % if no variation, set a small threshold
        threshold = eps(max(abs(Tsub(:)),1));
        fprintf("using condition 1\n ");
    else
        threshold = 0.1 * st;fprintf("using condition 2\n ");
    end

    % Build anomaly mask: large jumps, NaN, Inf
    mask = (dT > threshold) | isnan(Tsub) | isinf(Tsub);

    % If no anomalies, return unchanged region
    if ~any(mask(:))
        return;
    end

    % Prepare padded arrays to avoid indexing checks at borders
    padT = padarray(Tsub, [1 1], NaN);
    padMask = padarray(mask, [1 1], false);

    % Loop over inner cells of padded (corresponds to original Tsub)
    [nr, nc] = size(Tsub);
    for ii = 1:nr
        for jj = 1:nc
            if mask(ii,jj)
                % neighborhood in padded coordinates
                i0 = ii + 1; j0 = jj + 1;
                localVals = padT(i0-1:i0+1, j0-1:j0+1);
                localMask = padMask(i0-1:i0+1, j0-1:j0+1);

                % Exclude neighbor values that are flagged as anomalies or NaN/Inf
                good = localVals(~localMask);
                good = good(~isnan(good) & ~isinf(good));

                if ~isempty(good)
                    % use mean of good neighbors
                    Tsub(ii,jj) = mean(good);
                else
                    % Fallback: use median of entire subregion (omit NaN)
                    med = median(Tsub(:), 'omitnan');
                    if ~isnan(med)
                        Tsub(ii,jj) = med;
                    else
                        % ultimate fallback: leave original value (or set to 0)
                        % choose to leave original value to avoid introducing artifacts
                        % (it is already NaN or Inf; replace with 0 is also an option)
                        Tsub(ii,jj) = 0;
                    end
                end
            end
        end
    end

    % Put corrected submatrix back
    Tclean(i_min:i_max, j_min:j_max) = Tsub;
end
