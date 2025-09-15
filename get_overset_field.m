function Cm_F = get_overset_field(wkdir,file_ndx,field_name,zidx)

outfile = sprintf('%s/Reactants_%d.h5',wkdir,file_ndx);

dsetname = sprintf('/Reactants/overset/fields/1/%s',field_name);
Cm_F = h5read(outfile,dsetname);
Cm_F = permute(Cm_F,[3 2 1]);
%[NX,NY,NZ] = size(Cm_F);

Cm_F = Cm_F(:,:,1:zidx);

end