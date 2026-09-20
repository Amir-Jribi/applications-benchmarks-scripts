#!/bin/bash

#SBATCH --job-name=benchMEM
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=28
#SBATCH --account=sw_stack-373lcd9r8io-premium-gpu
#SBATCH --partition=gpu_h100
#SBATCH --gres=gpu:1
#SBATCH --output=output_%A.out
#SBATCH --error=error_%A.err

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load GROMACS/2024.4-foss-2023b-CUDA-12.4.0

srun --pmi=pmix gmx_mpi mdrun -s benchMEM.tpr -nb gpu -pme gpu -bonded gpu
