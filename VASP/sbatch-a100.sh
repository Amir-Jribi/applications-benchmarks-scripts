#!/bin/bash
#SBATCH --job-name=vasp-test-a100
#SBATCH --account=SW_STACK-373LCD9R8IO-PREMIUM-GPU
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1            # 1 MPI ranks
#SBATCH --gres=gpu:1          # 1 GPUs
##SBATCH --cpus-per-task=32 # 128/4
#SBATCH --time=00:30:00
#SBATCH -o ./output/vasp_output_%A.log
#SBATCH -e ./output/vasp_error_%A.log

module purge
ml unuse /srv/software/easybuild/modules/all
ml unuse /srv/software/easybuild/h100/modules/all

cd ./input

module use /srv/software/easybuild/a100/modules/all

ml load VASP/6.6.0-NVHPC-23.5-CUDA-12.1.0

export NVCOMPILER_ACC_SYNCHRONOUS=1

echo "===== Starting VASP ====="
srun --mpi=pmix vasp_std
