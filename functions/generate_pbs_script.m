function generate_pbs_script(fname,node)
%GENERATE_PBS_SCRIPT Generate a PBS job submission script for MATLAB job
%
% Usage:
%   generate_pbs_script('run_matlab_job.sh')
%
% Example output file:
%   #!/bin/bash
%   #PBS -N C_Cond
%   #PBS -j oe
%   #PBS -l walltime=24:00:00
%   #PBS -l nodes=cn001:ppn=24
%   cd $PBS_O_WORKDIR
%   NODEFILE=$PBS_NODEFILE
%   PPN=$(cat $NODEFILE | wc -l)
%   echo $NODEFILE
%   echo $PPN
%   module purge
%   module load apps/matlab/R2021b-new
%   #matlab -nodisplay -nodesktop -r compute_LES_cCond_stats_CZ_field_with_CH2O > ./log/vlog.${PBS_JOBID} 2> ./log/errlog.${PBS_JOBID}
filename = sprintf('batch_cluster_matlab_%s.sh',fname);
fid = fopen(filename, 'w');
if fid == -1
    error('Unable to open file: %s', filename);
end

fprintf(fid, '#!/bin/bash\n');
fprintf(fid, '#PBS -N C_Cond%s\n',fname);
fprintf(fid, '#PBS -j oe\n');
fprintf(fid, '#PBS -l walltime=24:00:00\n');
fprintf(fid, '#PBS -l nodes=cn%03d:ppn=24\n',node);
fprintf(fid, 'cd $PBS_O_WORKDIR\n');
fprintf(fid, 'NODEFILE=$PBS_NODEFILE\n');
fprintf(fid, 'PPN=$(cat $NODEFILE | wc -l)\n');
fprintf(fid, 'echo $NODEFILE\n');
fprintf(fid, 'echo $PPN\n');
fprintf(fid, 'module purge\n');
fprintf(fid, 'module load apps/matlab/R2021b-new\n\n');
fprintf(fid, 'matlab -nodisplay -nodesktop -r Ccond_stats_computation_%s > ./log/vlog.${PBS_JOBID}',fname);
