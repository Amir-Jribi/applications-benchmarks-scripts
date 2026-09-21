#!/bin/bash
#SBATCH --job-name=orca_test
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=12
#SBATCH --cpus-per-task=1
#SBATCH --time=03:10:00
#SBATCH --output=out_%A.out
#SBATCH --error=err_%A.err

module load ORCA/6.1.1-gompi-2024a-avx2

export OMPI_HOME="${EBROOTOPENMPI}"

scontrol show hostnames "$SLURM_JOB_NODELIST" > hosts
export HOSTS_FILE="hosts"

echo "----------HOSTS------------"
cat hosts
echo "----------OMPI_HOME-------"
echo "${OMPI_HOME}"
echo "----------TMPDIR-------"
echo "${TMPDIR}"
echo "----------SLURM_SUBMIT_DIR-------"
echo "${SLURM_SUBMIT_DIR}"

SCRATCH="${TMPDIR}/orca_${SLURM_JOBID}"
mkdir -p "$SCRATCH"

cp caffeine.inp hosts "$SCRATCH"
cd "$SCRATCH"

export RSH_COMMAND="/usr/bin/ssh"
export PARAMS="-machinefile ${HOSTS_FILE} --prefix ${OMPI_HOME}"

$EBROOTORCA/bin/orca caffeine.inp "$PARAMS" > out

# Copy everything from the scratch directory
cp * "$SLURM_SUBMIT_DIR"
cd "${SLURM_SUBMIT_DIR}"

# Remove scratch directory after completion
trap "rm -rf '${SCRATCH}'" EXIT
