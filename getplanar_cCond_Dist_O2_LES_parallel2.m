function [z_axis,Avgf] = getplanar_cCond_Dist_O2_LES_parallel2(wkdir,field_name,D,Na,Nc,R0,C_r,C_z,Ns,Ne,Y,c,delc)
ann_mesh_idx = 4;% exclude_from_ann_mesh_overlap_idx 
NRa = Na(1);NAa = Na(2);NZa = Na(3);

NRc = Nc(1);NAc = Nc(2);NZc = Nc(3);

z_axis = squeeze(C_z(floor(NRc/2)+1,floor(NAc/2)+1,:));


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
%         f_idx
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
        C_c = (C_O2 - Yu*ones(NRc,NAc))./(Yb-Yu);
        
        parfor c_idx=1:Nc
            %c(c_idx)
            %Annular Mesh%%%%%
            for i=ann_mesh_idx:NRa
                for j=1:NAa
                    if (A_c(i,j) > (c(c_idx,1)-delc)) && (A_c(i,j) <= (c(c_idx,1)+delc))
                        
                        Avgf(c_idx,z_idx) = (Nsamp(c_idx,z_idx)*Avgf(c_idx,z_idx) + A_F(i,j))/(Nsamp(c_idx,z_idx)+1);
                        Nsamp(c_idx,z_idx) = Nsamp(c_idx,z_idx) + 1;
                       
                    end     
                end
            end%%%%%%%%%%%%%%%
    
            %Centerline MEsh%%
            for i=1:NRc
                for j=1:NAc
    
                    if(C_r(i,j,z_idx) < R0) 
                        if (C_c(i,j) > (c(c_idx,1)-delc)) && (C_c(i,j) <= (c(c_idx,1)+delc))
                        
                        Avgf(c_idx,z_idx) = (Nsamp(c_idx,z_idx)*Avgf(c_idx,z_idx) + C_F(i,j))/(Nsamp(c_idx,z_idx)+1);
                        Nsamp(c_idx,z_idx) = Nsamp(c_idx,z_idx) + 1;
                       
                        end       
                    end
                    
                end
            end
          
        end
    end
end
end



    
