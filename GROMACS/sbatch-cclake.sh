#!/bin/sh

#SBATCH --job-name=benchMEM
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=56
#SBATCH --cpus-per-task=1
#SBATCH --output=output_%A.out
#SBATCH --error=error_%A.err

module load GROMACS/2024.4-foss-2024a

export OMP_NUM_THREADS=1

srun --mpi=pmix --nodes=2 --ntasks-per-node=56 gmx_mpi mdrun -s benchMEM.tpr
