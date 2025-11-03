function data_vec_interp = down_sample_field(C_field_vec, C_vec, data_vec)
    % Linear interpolation function
    tol = 1e-6;
    [AA, BB] = ndgrid(C_vec, C_field_vec);
    mask = abs(AA - BB) < tol;
    index_in_A = find(any(mask, 2));
    data_vec_interp = data_vec(index_in_A);
end