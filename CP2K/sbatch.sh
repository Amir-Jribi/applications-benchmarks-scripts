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


export PATH=$PATH:$project/users/$USER/software-install/hyperfine/hyperfine-v1.20.0-x86_64-unknown-linux-gnu


hyperfine --warmup 1 --runs 3 \
    --prepare "rm H2O-256* || true" \
     "srun --mpi=pmix --nodes=1 --ntasks=14 --ntasks-per-node=14 --cpus-per-task=4 cp2k.psmp -i ./input/H2O-256.inp -o H2O-256.out"
