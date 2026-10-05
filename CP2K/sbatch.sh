#!/bin/bash

#SBATCH --job-name="cp2k-H2O256-n1-c4"
#SBATCH --nodes=1
#SBATCH --ntasks=14
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_%j.out
#SBATCH --error=slurm_%j.err

ml load CP2K/2023.1-foss-2023a

export OMP_NUM_THREADS=4

echo "=========================================="
echo "CP2K H2O-256 benchmark"
echo "=========================================="
echo "Nodes:          1"
echo "NTASKS:         14"
echo "CPUs/task:      4"
echo "Total CPUs:     56"
echo "=========================================="


rm -f H2O-256.out
rm -f H2O-256-*.ener
rm -f H2O-256-pos-*.xyz

srun --mpi=pmix cp2k.psmp -i H2O-256.inp -o H2O-256.out

