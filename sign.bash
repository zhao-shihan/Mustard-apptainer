apptainer sign mace-tianhe2.sif
apptainer sign mace-tianhe2-mt.sif
apptainer sign mace-tianhe2-slim.sif
apptainer sign mace-tianhe2-mt-slim.sif
for mpi in mpich openmpi; do
    apptainer sign mace-$mpi.sif
    apptainer sign mace-$mpi-mt.sif
    apptainer sign mace-$mpi-slim.sif
    apptainer sign mace-$mpi-mt-slim.sif
done
