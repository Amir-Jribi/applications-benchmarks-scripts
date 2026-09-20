#!/bin/bash
#SBATCH --job-name=vasp-test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:10:00
#SBATCH -o vasp_output_%A.log
#SBATCH -e vasp_error_%A.log

cd ./input

module load VASP/6.5.0-intel-2024a

mpirun -np 4 vasp_std
