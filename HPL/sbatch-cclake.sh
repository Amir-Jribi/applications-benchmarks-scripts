#!/bin/bash
#SBATCH -J two_nodes
#SBATCH -o two_nodes_%A.out
#SBATCH -e two_nodes_%A.err
#SBATCH -N 4
#SBATCH --ntasks-per-node=1
#SBATCH -t 30:00
#SBATCH --exclusive

module load intel-compilers/2022.2.0
module load imkl/2021.3.0-gompi-2021a
module load impi/2021.7.0-intel-compilers-2022.2.0

echo "Job is running on the following nodes: $SLURM_NODELIST"
echo $SLURM_CPUS_PER_TASK

export KMP_AFFINITY=compact

mpirun -np 4 --map-by node ./xhpl
