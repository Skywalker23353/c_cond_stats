function Am_F = get_burner_field(wkdir,file_idx,field_name,ridx,zidx)

outfile = sprintf('%s/Reactants_%d.h5',wkdir,file_idx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in +X direction; 6,12,13

%Block 6
dsetname = sprintf('/Reactants/burner/fields/6/%s',field_name);
a1_F = h5read(outfile,dsetname);
a1_F = permute(a1_F,[3 2 1]);

[NR1,NA,NZ] = size(a1_F);

%Block 12
dsetname = sprintf('/Reactants/burner/fields/12/%s',field_name);
a2_F = h5read(outfile,dsetname);
a2_F = permute(a2_F,[3 2 1]);

[NR2,NA,NZ] = size(a2_F);

%Block 13
dsetname = sprintf('/Reactants/burner/fields/13/%s',field_name);
a3_F = h5read(outfile,dsetname);
a3_F = permute(a3_F,[3 2 1]);

[NR3,NA,NZ] = size(a3_F);

%Merged Ablk1 in +Xdir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk1_F = zeros(NRb,NAb,NZb);

Ablk1_F(1:NR1,:,:) = flip(flip(a1_F),2);
Ablk1_F(NR1:NR1+NR2-1,:,:) = flip(flip(a2_F),2);
Ablk1_F(NR1+NR2-1:NRb,:,:) = flip(flip(a3_F),2);

Ablk1_F = Ablk1_F(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in +Y direction; 4,14,15

%Block 4
dsetname = sprintf('/Reactants/burner/fields/4/%s',field_name);
a1_F = h5read(outfile,dsetname);
a1_F = permute(a1_F,[3 2 1]);

[NR1,NA,NZ] = size(a1_F);

%Block 14
dsetname = sprintf('/Reactants/burner/fields/14/%s',field_name);
a2_F = h5read(outfile,dsetname);
a2_F = permute(a2_F,[3 2 1]);

[NR2,NA,NZ] = size(a2_F);

%Block 15
dsetname = sprintf('/Reactants/burner/fields/15/%s',field_name);
a3_F = h5read(outfile,dsetname);
a3_F = permute(a3_F,[3 2 1]);

[NR3,NA,NZ] = size(a3_F);

%Merged Ablk2 in +Ydir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk2_F = zeros(NRb,NAb,NZb);

Ablk2_F(1:NR1,:,:) = flip(flip(a1_F),2);
Ablk2_F(NR1:NR1+NR2-1,:,:) = flip(flip(a2_F),2);
Ablk2_F(NR1+NR2-1:NRb,:,:) = flip(flip(a3_F),2);

%Since A has to be in CCW 
Ablk2_F = Ablk2_F(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in -X direction; 7,9,11

%Block 7
dsetname = sprintf('/Reactants/burner/fields/7/%s',field_name);
a1_F = h5read(outfile,dsetname);
a1_F = permute(a1_F,[3 2 1]);

[NR1,NA,NZ] = size(a1_F);
%Block 9
dsetname = sprintf('/Reactants/burner/fields/9/%s',field_name);
a2_F = h5read(outfile,dsetname);
a2_F = permute(a2_F,[3 2 1]);

[NR2,NA,NZ] = size(a2_F);

%Block 11
dsetname = sprintf('/Reactants/burner/fields/11/%s',field_name);
a3_F = h5read(outfile,dsetname);
a3_F = permute(a3_F,[3 2 1]);

[NR3,NA,NZ] = size(a3_F);

%Merged Ablk3 in -Xdir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk3_F = zeros(NRb,NAb,NZb);

Ablk3_F(1:NR1,:,:) = flip(flip(a1_F),2);
Ablk3_F(NR1:NR1+NR2-1,:,:) = flip(flip(a2_F),2);
Ablk3_F(NR1+NR2-1:NRb,:,:) = flip(flip(a3_F),2);

Ablk3_F = Ablk3_F(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in -Y direction; 5,8,10

%Block 5
dsetname = sprintf('/Reactants/burner/fields/5/%s',field_name);
a1_F = h5read(outfile,dsetname);
a1_F = permute(a1_F,[3 2 1]);

[NR1,NA,NZ] = size(a1_F);

%Block 8
dsetname = sprintf('/Reactants/burner/fields/8/%s',field_name);
a2_F = h5read(outfile,dsetname);
a2_F = permute(a2_F,[3 2 1]);

[NR2,NA,NZ] = size(a2_F);
%Block 10
dsetname = sprintf('/Reactants/burner/fields/10/%s',field_name);
a3_F = h5read(outfile,dsetname);
a3_F = permute(a3_F,[3 2 1]);

[NR3,NA,NZ] = size(a3_F);

%Merged Ablk4 in -Ydir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk4_F = zeros(NRb,NAb,NZb);

Ablk4_F(1:NR1,:,:) = flip(flip(a1_F),2);
Ablk4_F(NR1:NR1+NR2-1,:,:) = flip(flip(a2_F),2);
Ablk4_F(NR1+NR2-1:NRb,:,:) = flip(flip(a3_F),2);

Ablk4_F = Ablk4_F(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[NRb,NAb,NZb] = size(Ablk1_F);

NRm = NRb;
NAm = 4*NAb-4;
NZm = NZb;

Am_F = zeros(NRm,NAm,NZm);

Am_F(:,1:NAb,:) = Ablk1_F;

Am_F(:,NAb:2*NAb-1,:) = Ablk2_F;

Am_F(:,2*NAb-1:3*NAb-2,:) = Ablk3_F;

Am_F(:,3*NAb-2:NAm,:) = Ablk4_F(:,1:NAb-1,:);

end