function [Am_X,Am_Y,Am_Z] = get_burner_grid2(wkdir,rmax)

gfile = sprintf('%s/Reactants_grids_0.h5',wkdir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in +X direction; 6,12,13

%Block 6
dsetname = '/burner/source_blocks/6/x';
a1_X = h5read(gfile,dsetname);
a1_X = permute(a1_X,[3 2 1]);
dsetname = '/burner/source_blocks/6/y';
a1_Y = h5read(gfile,dsetname);
a1_Y = permute(a1_Y,[3 2 1]);
dsetname = '/burner/source_blocks/6/z';
a1_Z = h5read(gfile,dsetname);
a1_Z = permute(a1_Z,[3 2 1]);

[NR1,NA,NZ] = size(a1_X);

%Block 12
dsetname = '/burner/source_blocks/12/x';
a2_X = h5read(gfile,dsetname);
a2_X = permute(a2_X,[3 2 1]);
dsetname = '/burner/source_blocks/12/y';
a2_Y = h5read(gfile,dsetname);
a2_Y = permute(a2_Y,[3 2 1]);
dsetname = '/burner/source_blocks/12/z';
a2_Z = h5read(gfile,dsetname);
a2_Z = permute(a2_Z,[3 2 1]);

[NR2,NA,NZ] = size(a2_X);

%Block 13
dsetname = '/burner/source_blocks/13/x';
a3_X = h5read(gfile,dsetname);
a3_X = permute(a3_X,[3 2 1]);
dsetname = '/burner/source_blocks/13/y';
a3_Y = h5read(gfile,dsetname);
a3_Y = permute(a3_Y,[3 2 1]);
dsetname = '/burner/source_blocks/13/z';
a3_Z = h5read(gfile,dsetname);
a3_Z = permute(a3_Z,[3 2 1]);

[NR3,NA,NZ] = size(a3_X);

%Merged Ablk1 in +Xdir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk1_X = zeros(NRb,NAb,NZb);
Ablk1_Y = zeros(NRb,NAb,NZb);
Ablk1_Z = zeros(NRb,NAb,NZb);

Ablk1_X(1:NR1,:,:) = flip(flip(a1_X),2);
Ablk1_X(NR1:NR1+NR2-1,:,:) = flip(flip(a2_X),2);
Ablk1_X(NR1+NR2-1:NRb,:,:) = flip(flip(a3_X),2);

Ablk1_Y(1:NR1,:,:) = flip(flip(a1_Y),2);
Ablk1_Y(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Y),2);
Ablk1_Y(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Y),2);

Ablk1_Z(1:NR1,:,:) = flip(flip(a1_Z),2);
Ablk1_Z(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Z),2);
Ablk1_Z(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Z),2);

x_axis = squeeze(Ablk1_X(:,floor(NAb/2)+1,1));
% z_axis = squeeze(Ablk1_Z(1,floor(NAb/2)+1,:));

ridx = find(x_axis>rmax,1);
zidx = NZ;%find(z_axis>zmax,1);

Ablk1_X = Ablk1_X(1:ridx,:,1:zidx);
Ablk1_Y = Ablk1_Y(1:ridx,:,1:zidx);
Ablk1_Z = Ablk1_Z(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in +Y direction; 4,14,15

%Block 4
dsetname = '/burner/source_blocks/4/x';
a1_X = h5read(gfile,dsetname);
a1_X = permute(a1_X,[3 2 1]);
dsetname = '/burner/source_blocks/4/y';
a1_Y = h5read(gfile,dsetname);
a1_Y = permute(a1_Y,[3 2 1]);
dsetname = '/burner/source_blocks/4/z';
a1_Z = h5read(gfile,dsetname);
a1_Z = permute(a1_Z,[3 2 1]);

[NR1,NA,NZ] = size(a1_X);

%Block 14
dsetname = '/burner/source_blocks/14/x';
a2_X = h5read(gfile,dsetname);
a2_X = permute(a2_X,[3 2 1]);
dsetname = '/burner/source_blocks/14/y';
a2_Y = h5read(gfile,dsetname);
a2_Y = permute(a2_Y,[3 2 1]);
dsetname = '/burner/source_blocks/14/z';
a2_Z = h5read(gfile,dsetname);
a2_Z = permute(a2_Z,[3 2 1]);

[NR2,NA,NZ] = size(a2_X);

%Block 15
dsetname = '/burner/source_blocks/15/x';
a3_X = h5read(gfile,dsetname);
a3_X = permute(a3_X,[3 2 1]);
dsetname = '/burner/source_blocks/15/y';
a3_Y = h5read(gfile,dsetname);
a3_Y = permute(a3_Y,[3 2 1]);
dsetname = '/burner/source_blocks/15/z';
a3_Z = h5read(gfile,dsetname);
a3_Z = permute(a3_Z,[3 2 1]);

[NR3,NA,NZ] = size(a3_X);

%Merged Ablk2 in +Ydir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk2_X = zeros(NRb,NAb,NZb);
Ablk2_Y = zeros(NRb,NAb,NZb);
Ablk2_Z = zeros(NRb,NAb,NZb);

Ablk2_X(1:NR1,:,:) = flip(flip(a1_X),2);
Ablk2_X(NR1:NR1+NR2-1,:,:) = flip(flip(a2_X),2);
Ablk2_X(NR1+NR2-1:NRb,:,:) = flip(flip(a3_X),2);

Ablk2_Y(1:NR1,:,:) = flip(flip(a1_Y),2);
Ablk2_Y(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Y),2);
Ablk2_Y(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Y),2);

Ablk2_Z(1:NR1,:,:) = flip(flip(a1_Z),2);
Ablk2_Z(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Z),2);
Ablk2_Z(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Z),2);

%Since A has to be in CCW 
Ablk2_X = Ablk2_X(1:ridx,:,1:zidx);
Ablk2_Y = Ablk2_Y(1:ridx,:,1:zidx);
Ablk2_Z = Ablk2_Z(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in -X direction; 7,9,11

%Block 7
dsetname = '/burner/source_blocks/7/x';
a1_X = h5read(gfile,dsetname);
a1_X = permute(a1_X,[3 2 1]);
dsetname = '/burner/source_blocks/7/y';
a1_Y = h5read(gfile,dsetname);
a1_Y = permute(a1_Y,[3 2 1]);
dsetname = '/burner/source_blocks/7/z';
a1_Z = h5read(gfile,dsetname);
a1_Z = permute(a1_Z,[3 2 1]);

[NR1,NA,NZ] = size(a1_X);

% %since R is in +X dir
% tempX = a1_X;
% tempY = a1_Y;
% tempZ = a1_Z;
% 
% for i=1:NR1
%     a1_X(i,:,:) = tempX(NR1-i+1,:,:);
%     a1_Y(i,:,:) = tempY(NR1-i+1,:,:);
%     a1_Z(i,:,:) = tempZ(NR1-i+1,:,:);
% end

%Block 9
dsetname = '/burner/source_blocks/9/x';
a2_X = h5read(gfile,dsetname);
a2_X = permute(a2_X,[3 2 1]);
dsetname = '/burner/source_blocks/9/y';
a2_Y = h5read(gfile,dsetname);
a2_Y = permute(a2_Y,[3 2 1]);
dsetname = '/burner/source_blocks/9/z';
a2_Z = h5read(gfile,dsetname);
a2_Z = permute(a2_Z,[3 2 1]);

[NR2,NA,NZ] = size(a2_X);

%Block 11
dsetname = '/burner/source_blocks/11/x';
a3_X = h5read(gfile,dsetname);
a3_X = permute(a3_X,[3 2 1]);
dsetname = '/burner/source_blocks/11/y';
a3_Y = h5read(gfile,dsetname);
a3_Y = permute(a3_Y,[3 2 1]);
dsetname = '/burner/source_blocks/11/z';
a3_Z = h5read(gfile,dsetname);
a3_Z = permute(a3_Z,[3 2 1]);

[NR3,NA,NZ] = size(a3_X);

%Merged Ablk3 in -Xdir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk3_X = zeros(NRb,NAb,NZb);
Ablk3_Y = zeros(NRb,NAb,NZb);
Ablk3_Z = zeros(NRb,NAb,NZb);

Ablk3_X(1:NR1,:,:) = flip(flip(a1_X),2);
Ablk3_X(NR1:NR1+NR2-1,:,:) = flip(flip(a2_X),2);
Ablk3_X(NR1+NR2-1:NRb,:,:) = flip(flip(a3_X),2);

Ablk3_Y(1:NR1,:,:) = flip(flip(a1_Y),2);
Ablk3_Y(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Y),2);
Ablk3_Y(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Y),2);

Ablk3_Z(1:NR1,:,:) = flip(flip(a1_Z),2);
Ablk3_Z(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Z),2);
Ablk3_Z(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Z),2);

%Since A has to be in CCW
% tempX = Ablk3_X;
% tempY = Ablk3_Y;
% tempZ = Ablk3_Z;
% 
% for i=1:NAb
%     Ablk3_X(:,i,:) = tempX(:,NAb-i+1,:);
%     Ablk3_Y(:,i,:) = tempY(:,NAb-i+1,:);
%     Ablk3_Z(:,i,:) = tempZ(:,NAb-i+1,:);
% end

Ablk3_X = Ablk3_X(1:ridx,:,1:zidx);
Ablk3_Y = Ablk3_Y(1:ridx,:,1:zidx);
Ablk3_Z = Ablk3_Z(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Blocks in -Y direction; 5,8,10

%Block 5
dsetname = '/burner/source_blocks/5/x';
a1_X = h5read(gfile,dsetname);
a1_X = permute(a1_X,[3 2 1]);
dsetname = '/burner/source_blocks/5/y';
a1_Y = h5read(gfile,dsetname);
a1_Y = permute(a1_Y,[3 2 1]);
dsetname = '/burner/source_blocks/5/z';
a1_Z = h5read(gfile,dsetname);
a1_Z = permute(a1_Z,[3 2 1]);

[NR1,NA,NZ] = size(a1_X);

%since R is in +Y dir
% tempX = a1_X;
% tempY = a1_Y;
% tempZ = a1_Z;
% 
% for i=1:NR1
%     a1_X(i,:,:) = tempX(NR1-i+1,:,:);
%     a1_Y(i,:,:) = tempY(NR1-i+1,:,:);
%     a1_Z(i,:,:) = tempZ(NR1-i+1,:,:);
% end

%Block 8
dsetname = '/burner/source_blocks/8/x';
a2_X = h5read(gfile,dsetname);
a2_X = permute(a2_X,[3 2 1]);
dsetname = '/burner/source_blocks/8/y';
a2_Y = h5read(gfile,dsetname);
a2_Y = permute(a2_Y,[3 2 1]);
dsetname = '/burner/source_blocks/8/z';
a2_Z = h5read(gfile,dsetname);
a2_Z = permute(a2_Z,[3 2 1]);

[NR2,NA,NZ] = size(a2_X);

%since R is in +Y dir
% tempX = a2_X;
% tempY = a2_Y;
% tempZ = a2_Z;
% 
% for i=1:NR2
%     a2_X(i,:,:) = tempX(NR2-i+1,:,:);
%     a2_Y(i,:,:) = tempY(NR2-i+1,:,:);
%     a2_Z(i,:,:) = tempZ(NR2-i+1,:,:);
% end

%Block 10
dsetname = '/burner/source_blocks/10/x';
a3_X = h5read(gfile,dsetname);
a3_X = permute(a3_X,[3 2 1]);
dsetname = '/burner/source_blocks/10/y';
a3_Y = h5read(gfile,dsetname);
a3_Y = permute(a3_Y,[3 2 1]);
dsetname = '/burner/source_blocks/10/z';
a3_Z = h5read(gfile,dsetname);
a3_Z = permute(a3_Z,[3 2 1]);

[NR3,NA,NZ] = size(a3_X);

% %since R is in +X dir
% tempX = a3_X;
% tempY = a3_Y;
% tempZ = a3_Z;
% 
% for i=1:NR3
%     a3_X(i,:,:) = tempX(NR3-i+1,:,:);
%     a3_Y(i,:,:) = tempY(NR3-i+1,:,:);
%     a3_Z(i,:,:) = tempZ(NR3-i+1,:,:);
% end

%Merged Ablk4 in -Ydir
NRb = NR1+NR2+NR3-2;
NAb = NA;
NZb = NZ;

Ablk4_X = zeros(NRb,NAb,NZb);
Ablk4_Y = zeros(NRb,NAb,NZb);
Ablk4_Z = zeros(NRb,NAb,NZb);

Ablk4_X(1:NR1,:,:) = flip(flip(a1_X),2);
Ablk4_X(NR1:NR1+NR2-1,:,:) = flip(flip(a2_X),2);
Ablk4_X(NR1+NR2-1:NRb,:,:) = flip(flip(a3_X),2);

Ablk4_Y(1:NR1,:,:) = flip(flip(a1_Y),2);
Ablk4_Y(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Y),2);
Ablk4_Y(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Y),2);

Ablk4_Z(1:NR1,:,:) = flip(flip(a1_Z),2);
Ablk4_Z(NR1:NR1+NR2-1,:,:) = flip(flip(a2_Z),2);
Ablk4_Z(NR1+NR2-1:NRb,:,:) = flip(flip(a3_Z),2);

Ablk4_X = Ablk4_X(1:ridx,:,1:zidx);
Ablk4_Y = Ablk4_Y(1:ridx,:,1:zidx);
Ablk4_Z = Ablk4_Z(1:ridx,:,1:zidx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[NRb,NAb,NZb] = size(Ablk1_X);

NRm = NRb;
NAm = 4*NAb-4;
NZm = NZb;

Am_X = zeros(NRm,NAm,NZm);
Am_Y = zeros(NRm,NAm,NZm);
Am_Z = zeros(NRm,NAm,NZm);

Am_X(:,1:NAb,:) = Ablk1_X;
Am_Y(:,1:NAb,:) = Ablk1_Y;
Am_Z(:,1:NAb,:) = Ablk1_Z;

Am_X(:,NAb:2*NAb-1,:) = Ablk2_X;
Am_Y(:,NAb:2*NAb-1,:) = Ablk2_Y;
Am_Z(:,NAb:2*NAb-1,:) = Ablk2_Z;

Am_X(:,2*NAb-1:3*NAb-2,:) = Ablk3_X;
Am_Y(:,2*NAb-1:3*NAb-2,:) = Ablk3_Y;
Am_Z(:,2*NAb-1:3*NAb-2,:) = Ablk3_Z;

Am_X(:,3*NAb-2:NAm,:) = Ablk4_X(:,1:NAb-1,:);
Am_Y(:,3*NAb-2:NAm,:) = Ablk4_Y(:,1:NAb-1,:);
Am_Z(:,3*NAb-2:NAm,:) = Ablk4_Z(:,1:NAb-1,:);

end