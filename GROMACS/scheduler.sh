!/bin/bash

# Submit a sweep of GROMACS benchmark jobs for a given parallelization strategy.
#
# Usage:
#   ./scheduler.sh {openmp|mpi|hybrid|threadmpi|gpu-threadmpi|all}
#
# Env overrides (optional):
#   CORES_PER_NODE    physical cores/node          (default 56)
#   GMX_TPR           path to .tpr input           (default ../benchmarks/benchMEM/benchMEM.tpr)
#   GMX_MODULE        module to load               (default GROMACS/2024.4-foss-2023b-CUDA-12.4.0)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOB_SCRIPT="${SCRIPT_DIR}/job.sh"
LOG_DIR="${SCRIPT_DIR}/../output/"
mkdir -p "${LOG_DIR}"

CORES_PER_NODE="${CORES_PER_NODE:-56}"
GMX_TPR="${GMX_TPR:-../benchmarks/benchMEM/benchMEM.tpr}"
GMX_MODULE="${GMX_MODULE:-GROMACS/2024.4-foss-2023b-CUDA-12.4.0}"

# submit_job <tag> <nodes> <ntasks> <ntasks-per-node> <cpus-per-task> <omp-threads> [cmd-prefix]
# cmd-prefix, if given, overrides job.sh's default "srun --mpi=pmix gmx_mpi" launcher.
submit_job() {
    local tag=$1
    local nodes=$2
    local ntasks=$3
    local ntasks_per_node=$4
    local cpus_per_task=$5
    local omp_threads=$6
    local cmd_prefix=${7:-}

    local job_name="gromacs_${tag}"

    local strategy_dir="${tag%%_*}"
    local job_out_dir="${LOG_DIR}/${strategy_dir}/${job_name}"
    mkdir -p "${job_out_dir}"

    OMP_NUM_THREADS="${omp_threads}" \
    GMX_TPR="${GMX_TPR}" \
    GMX_MODULE="${GMX_MODULE}" \
    GMX_OUTDIR="${job_out_dir}" \
    GMX_CMD_PREFIX="${cmd_prefix}" \
    GMX_EXTRA_ARGS="${GMX_EXTRA_ARGS}" \
    sbatch \
        --job-name="${job_name}" \
        --nodes="${nodes}" \
        --ntasks="${ntasks}" \
        --ntasks-per-node="${ntasks_per_node}" \
        --cpus-per-task="${cpus_per_task}" \
        ${SBATCH_ACCOUNT:+--account="${SBATCH_ACCOUNT}"} \
        ${SBATCH_PARTITION:+--partition="${SBATCH_PARTITION}"} \
        ${SBATCH_GRES:+--gres="${SBATCH_GRES}"} \
        --output="${job_out_dir}/${job_name}_%j.out" \
        --error="${job_out_dir}/${job_name}_%j.err" \
        "${JOB_SCRIPT}"

    echo "submitted ${job_name}: nodes=${nodes} ntasks=${ntasks} ntasks-per-node=${ntasks_per_node} cpus-per-task=${cpus_per_task} OMP_NUM_THREADS=${omp_threads} outdir=${job_out_dir} cmd=${cmd_prefix:-<default srun>}"
}

# OpenMP only: single node, gmx mdrun run, threads = 56/28/14/7
submit_openmp() {
    local threads
    for threads in 56 28 14 7; do
        submit_job "openmp_t${threads}" 1 1 1 "${threads}" "${threads}" "gmx"
    done
}

# Thread-MPI only: single node, scale thread-MPI threads
submit_threadmpi() {
    local threads
    for threads in 7 14 28 56; do
        GMX_EXTRA_ARGS="-ntmpi ${threads} -ntomp 1" submit_job "threadmpi_t${threads}" 1 1 1 "${threads}" 1 "gmx"
    done
}

# MPI only: 1 thread/rank, nodes = 1/2/4/8
submit_mpi() {
    local nodes ntasks
    for nodes in 1 2 4 8; do
        ntasks=$(( nodes * CORES_PER_NODE ))
        submit_job "mpi_n${nodes}" "${nodes}" "${ntasks}" "${CORES_PER_NODE}" 1 1
    done
}

# Hybrid: for each node count, sweep thread counts so ranks_per_node * threads = CORES_PER_NODE
submit_hybrid() {
    local nodes threads ranks_per_node ntasks
    for nodes in 1 2 4 8; do
        for threads in 1 2 4 8; do
            ranks_per_node=$(( CORES_PER_NODE / threads ))
            ntasks=$(( nodes * ranks_per_node ))
            submit_job "hybrid_n${nodes}_r${ranks_per_node}_t${threads}" \
                "${nodes}" "${ntasks}" "${ranks_per_node}" "${threads}" "${threads}"
        done
    done
}

# GPU-MP strategy: single MPI rank, openmp threads scaling
submit_gpu_mp() {
    local threads pme bonded update
    export SBATCH_ACCOUNT="sw_stack-373lcd9r8io-premium-gpu"
    export SBATCH_PARTITION="gpu_h100"
    export SBATCH_GRES="gpu:1"

    for threads in 56 28 14 7; do
        for pme in gpu; do
            for bonded in cpu; do
                for update in cpu; do
                    local gmx_args="-nb cpu -pme ${pme} -bonded ${bonded} -update ${update}"
                    local tag="pme-gpu-mp_t${threads}_pme-${pme}_bnd-${bonded}_upd-${update}"

                    GMX_EXTRA_ARGS="${gmx_args}" submit_job "${tag}" 1 1 1 "${threads}" "${threads}"
                done
            done
        done
    done
}

# GPU-MPI strategy: single openmp thread per rank, ranks scaling
submit_gpu_mpi() {
    local ranks pme bonded update
    export SBATCH_PARTITION="gpu_h100"
    export SBATCH_GRES="gpu:1"

    for ranks in 56 28 14 7; do
        for pme in auto cpu gpu; do
            for bonded in auto cpu gpu; do
                for update in auto cpu gpu; do
                    local gmx_args="-nb gpu -pme ${pme} -bonded ${bonded} -update ${update}"
                    if [ "${pme}" = "gpu" ]; then
                        gmx_args="${gmx_args} -npme 1"
                    fi
                    local tag="gpu-mpi_r${ranks}_pme-${pme}_bnd-${bonded}_upd-${update}"

                    GMX_EXTRA_ARGS="${gmx_args}" submit_job "${tag}" 1 "${ranks}" "${ranks}" 1 1
                done
            done
        done
    done
}

# GPU-Thread-MPI strategy: single task, threadMPI threads scaling, single openmp thread
submit_gpu_threadmpi() {
    local threads pme bonded update
    export SBATCH_PARTITION="gpu_h100"
    export SBATCH_GRES="gpu:1"

    for threads in 56 28 14 7; do
        for pme in auto cpu gpu; do
            for bonded in auto cpu gpu; do
                for update in auto cpu gpu; do
                    local gmx_args="-nb gpu -pme ${pme} -bonded ${bonded} -update ${update} -ntmpi ${threads} -ntomp 1"
                    if [ "${pme}" = "gpu" ]; then
                        gmx_args="${gmx_args} -npme 1"
                    fi
                    local tag="gpu-threadmpi_t${threads}_pme-${pme}_bnd-${bonded}_upd-${update}"

                    GMX_EXTRA_ARGS="${gmx_args}" submit_job "${tag}" 1 1 1 "${threads}" 1 "gmx"
                done
            done
        done
    done
}

strategy="${1:-}"
case "${strategy}" in
    openmp) submit_openmp ;;
    mpi)    submit_mpi ;;
    hybrid) submit_hybrid ;;
    threadmpi) submit_threadmpi ;;
    gpu-mp) submit_gpu_mp ;;
    gpu-mpi) submit_gpu_mpi ;;
    gpu-threadmpi) submit_gpu_threadmpi ;;
    all)
        submit_openmp
        submit_mpi
        submit_hybrid
        submit_threadmpi
        submit_gpu_mp
        submit_gpu_mpi
        submit_gpu_threadmpi
        ;;
    *)
        echo "Usage: $0 {openmp|mpi|hybrid|threadmpi|gpu-mp|gpu-mpi|gpu-threadmpi|all}" >&2
        exit 1
        ;;
esac
