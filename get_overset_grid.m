function [Cm_X,Cm_Y,Cm_Z] = get_overset_grid(wkdir,zmax)

gfile = sprintf('%s/Reactants_grids_0.h5',wkdir);

dsetname = '/overset/1/xcoord';
Cm_X = hdf5read(gfile,dsetname);
Cm_X = permute(Cm_X,[3 2 1]);

dsetname = '/overset/1/ycoord';
Cm_Y = hdf5read(gfile,dsetname);
Cm_Y = permute(Cm_Y,[3 2 1]);

dsetname = '/overset/1/zcoord';
Cm_Z = hdf5read(gfile,dsetname);
Cm_Z = permute(Cm_Z,[3 2 1]);


[NX,NY,NZ] = size(Cm_Z);

z_axis = squeeze(Cm_Z(1,1,:));

zidx = NZ;%find(z_axis>zmax,1);

Cm_X = Cm_X(:,:,1:zidx);
Cm_Y = Cm_Y(:,:,1:zidx);
Cm_Z = Cm_Z(:,:,1:zidx);

end