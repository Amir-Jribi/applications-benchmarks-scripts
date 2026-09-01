#!/bin/bash

# Parameterized GROMACS mdrun job.
#
# Runtime parameters coming in as environment variables:
#   OMP_NUM_THREADS
#   GMX_TPR          - path to the .tpr input file (default ../benchmarks/benchMEM/benchMEM.tpr)
#   GMX_MODULE       - GROMACS module to load
#   GMX_OUTDIR       - directory mdrun output files should be written into
#   GMX_CMD_PREFIX   - command used to launch mdrun.
#   GMX_EXTRA_ARGS   - optional extra args appended to mdrun

# Fail if parameters are not set
: "${GMX_EXTRA_ARGS:=}"
: "${GMX_TPR:=../benchmarks/benchMEM/benchMEM.tpr}"
: "${GMX_MODULE:=GROMACS/2024.4-foss-2023b-CUDA-12.4.0}"
: "${OMP_NUM_THREADS:?OMP_NUM_THREADS must be set (exported via sbatch --export)}"
: "${GMX_OUTDIR:=.}"
: "${GMX_CMD_PREFIX:=srun --mpi=pmix gmx_mpi}"

# Resolve GMX_TPR to an absolute path *before* we cd, since it's likely
# given as a path relative to the submission directory.
case "${GMX_TPR}" in
    /*) : ;;  # already absolute
    *)  GMX_TPR="$(cd "$(dirname "${GMX_TPR}")" && pwd)/$(basename "${GMX_TPR}")" ;;
esac

mkdir -p "${GMX_OUTDIR}"
cd "${GMX_OUTDIR}" || { echo "Failed to cd into GMX_OUTDIR=${GMX_OUTDIR}" >&2; exit 1; }

module purge
module load "${GMX_MODULE}"

echo "== ${SLURM_JOB_NAME:-run_gromacs} (job ${SLURM_JOB_ID:-N/A}) =="
echo "nodes=${SLURM_NNODES:-?} ntasks=${SLURM_NTASKS:-?} ntasks-per-node=${SLURM_NTASKS_PER_NODE:-?} cpus-per-task=${SLURM_CPUS_PER_TASK:-?} OMP_NUM_THREADS=${OMP_NUM_THREADS}"
echo "tpr=${GMX_TPR} module=${GMX_MODULE} outdir=$(pwd)"
echo "cmd=${GMX_CMD_PREFIX} mdrun -s ${GMX_TPR} ${GMX_EXTRA_ARGS}"

${GMX_CMD_PREFIX} mdrun -s "${GMX_TPR}" ${GMX_EXTRA_ARGS}
