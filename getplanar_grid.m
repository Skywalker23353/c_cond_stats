function [Na,Nc,R0,C_r,C_z] = getplanar_grid(wkdir,rmax)
    ann_mesh_idx = 4;% exclude_from_ann_mesh_overlap_idx
    [A_x,A_y,~] = get_burner_grid2(wkdir,rmax);
    Na = size(A_x);
    R0 = sqrt(power(A_x(ann_mesh_idx,1,1),2) + power(A_y(ann_mesh_idx,1,1),2));
    
    [C_x,C_y,C_z] = get_overset_grid2(wkdir);
    Nc = size(C_x);
    C_r = sqrt(C_x.^2 + C_y.^2);

end



    
