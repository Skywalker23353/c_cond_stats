function [z_axis,Avgf] = getplanar_cCond_Dist_O2_LES(wkdir, field_name, D, rmax,zmax, Ns, Ne,Y,c,delc)
ann_mesh_idx = 4;% exclude_from_ann_mesh_overlap_idx 
[A_x,A_y,A_z] = get_burner_grid2(wkdir,rmax,zmax);
[NRa,NAa,NZa] = size(A_x);
R0 = sqrt(power(A_x(ann_mesh_idx,1,1),2) + power(A_y(ann_mesh_idx,1,1),2));

[C_x,C_y,C_z] = get_overset_grid2(wkdir,zmax);
[NX,NY,NZc] = size(C_x);
C_r = sqrt(C_x.^2 + C_y.^2);

z_axis = squeeze(C_z(floor(NX/2)+1,floor(NY/2)+1,:));
% zidx_err = find(z_axis > 6.6*2e-3,1);

if ~(NZa == NZc)
    fprintf("Burner and centerline grid NK's does not match");
    exit;
end

Yu = Y(1); Yb = Y(2);
Nc = length(c);
Nsamp = zeros(Nc,NZa);
Avgf = zeros(Nc,NZa);
for z_idx = 1:NZa
    z_idx
    for f_idx =Ns:Ne
        f_idx
        %extract field
        A_f = get_burner_field(wkdir,f_idx,field_name,NRa,NZa);
        C_f = get_overset_field(wkdir,f_idx,field_name,NZc);
        %interpolated plane
        C_F = squeeze(C_f(:,:,z_idx));
        A_F = squeeze(A_f(:,:,z_idx));
        
        A_f = get_burner_field(wkdir,f_idx,'O2',NRa,NZa);
        C_f = get_overset_field(wkdir,f_idx,'O2',NZc);
        C_O2 = squeeze(C_f(:,:,z_idx));
        A_O2 = squeeze(A_f(:,:,z_idx));
        
        A_c = (A_O2 - Yu*ones(NRa,NAa))./(Yb-Yu);
        C_c = (C_O2 - Yu*ones(NX,NY))./(Yb-Yu);
        
        for c_idx=1:Nc
            %c(c_idx)
            %Annular Mesh%%%%%
            for i=ann_mesh_idx:NRa
                for j=1:NAa
                    if (A_c(i,j) >= (c(c_idx,1)-delc)) && (A_c(i,j) < (c(c_idx,1)+delc))
                        
                        Avgf(c_idx,z_idx) = (Nsamp(c_idx,z_idx)*Avgf(c_idx,z_idx) + A_F(i,j))/(Nsamp(c_idx,z_idx)+1);
                        Nsamp(c_idx,z_idx) = Nsamp(c_idx,z_idx) + 1;
                       
                    end     
                end
            end%%%%%%%%%%%%%%%
    
            %Centerline MEsh%%
            for i=1:NX
                for j=1:NY
    
                    if(C_r(i,j,z_idx) < R0) 
                        if (C_c(i,j) >= (c(c_idx,1)-delc)) && (C_c(i,j) < (c(c_idx,1)+delc))
                        
                        Avgf(c_idx,z_idx) = (Nsamp(c_idx,z_idx)*Avgf(c_idx,z_idx) + C_F(i,j))/(Nsamp(c_idx,z_idx)+1);
                        Nsamp(c_idx,z_idx) = Nsamp(c_idx,z_idx) + 1;
                       
                        end       
                    end
                    
                end
            end
          
        end
    end
end
% idx = find(Avgf>0,1);
% c = c(idx:length(c),1);
% Avgf = Avgf(idx:length(Avgf),1);
end



    
