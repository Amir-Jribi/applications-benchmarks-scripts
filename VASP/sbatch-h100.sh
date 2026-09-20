#!/bin/bash
#SBATCH --job-name=vasp-test-h100
#SBATCH --account=SW_STACK-373LCD9R8IO-PREMIUM-GPU
#SBATCH --partition=gpu_h100
#SBATCH --nodes=1
#SBATCH --ntasks=1            # 1 MPI ranks
#SBATCH --gres=gpu:1          # 1 GPUs
##SBATCH --cpus-per-task=24 # 96/4
#SBATCH --time=00:30:00
#SBATCH -o ./output/vasp_output_%A.log
#SBATCH -e ./output/vasp_error_%A.log

module purge

cd ./input

ml load VASP/6.6.0-NVHPC-23.5-CUDA-12.2.0

#echo "===== GPU status before run ====="
nvidia-smi
export NVCOMPILER_ACC_NOTIFY=3
export NVCOMPILER_ACC_SYNCHRONOUS=1

nvidia-smi dmon -s um -d 1 > gpu_usage.log &
MONITOR_PID=$!

echo "===== Starting VASP ====="
#IMPORTANT: bind 1 rank per GPU
srun --mpi=pmix --gpus-per-task=1 vasp_std

kill $MONITOR_PID
