#!/bin/bash

#SBATCH --job-name=ausurf_benchmark
#SBATCH --output=ausurf_output_%A.out
#SBATCH --error=ausurf_error_%A.err
#SBATCH --nodes=1
#SBATCH --ntasks=56
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

export OMP_NUM_THREADS=1

ml load QuantumESPRESSO/7.4-foss-2024a

mpirun -np 56 pw.x -i ausurf.in | tee ausurf.out
