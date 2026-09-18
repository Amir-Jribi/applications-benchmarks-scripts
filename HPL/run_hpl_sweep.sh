#!/bin/bash

set -uo pipefail

# ============================================================
# Configuration
# ============================================================

DAT_DIR="${DAT_FILE_PATH:-$HOME/benchmarks/HPL-GPU}"
BASE_DAT="${DAT_DIR}/HPL.dat"


IMAGE="${APPTAINER_IMAGE:-$HOME/containers/hpc-benchmarks_25.04.sif}"
HPL_SCRIPT="/workspace/hpl.sh"

RESULT_DIR="${DAT_DIR}/results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "${RESULT_DIR}"

# ============================================================
# N values
#
# NB = 384 -> keep N divisible by 384
# ============================================================

# ~80k -> ~100k
N_1GPU=(
    80000
    85000
    90000
   100000
)

# ~100k -> ~120k
N_2GPU=(
    99840
    103680
    107520
    111360
    115200
    119040
)

# ~120k -> ~140k
N_4GPU=(
    119808
    124416
    129024
    133632
    138240
    139776
)


# ============================================================
# Modify HPL.dat
# ============================================================

prepare_hpl_dat()
{
    local N="$1"
    local P="$2"
    local Q="$3"
    local OUTPUT_DAT="$4"

    cp "${BASE_DAT}" "${OUTPUT_DAT}"

    # we are assuming here that there exist one single Number
    # before Ns, Ps, Qs
    # if there exist multiple numbers / there isnt none,
    # this reg exp part should be modified !
    # Modify N
    sed -i -E \
        "/^[[:space:]]*[0-9]+[[:space:]]+Ns/ \
         s/^[[:space:]]*[0-9]+/${N}/" \
        "${OUTPUT_DAT}"

    # Modify P
    sed -i -E \
        "/^[[:space:]]*[0-9]+[[:space:]]+Ps/ \
         s/^[[:space:]]*[0-9]+/${P}/" \
        "${OUTPUT_DAT}"

    # Modify Q
    sed -i -E \
        "/^[[:space:]]*[0-9]+[[:space:]]+Qs/ \
         s/^[[:space:]]*[0-9]+/${Q}/" \
        "${OUTPUT_DAT}"
}


# ============================================================
# Run one HPL experiment
# ============================================================

run_hpl()
{
    local GPUS="$1"
    local P="$2"
    local Q="$3"
    local N="$4"

    if (( P * Q != GPUS )); then
        echo "ERROR: P*Q must equal number of MPI ranks/GPUs"
        echo "GPUS=${GPUS}, P=${P}, Q=${Q}"
        exit 1
    fi

    local NAME="${GPUS}GPU_N${N}_P${P}_Q${Q}"

    local RUN_DAT="${RESULT_DIR}/${NAME}.dat"
    local LOG="${RESULT_DIR}/${NAME}.log"
    local RESULT_SUMMARY="${RESULT_DIR}/${GPUS}GPU_results.txt"

    prepare_hpl_dat \
        "${N}" \
        "${P}" \
        "${Q}" \
        "${RUN_DAT}"

    echo
    echo "============================================================"
    echo "HPL experiment"
    echo "============================================================"
    echo "GPUs : ${GPUS}"
    echo "N    : ${N}"
    echo "P    : ${P}"
    echo "Q    : ${Q}"
    echo "P*Q  : $((P * Q))"
    echo "DAT  : ${RUN_DAT}"
    echo "LOG  : ${LOG}"
    echo "============================================================"
    echo

    srun \
        --nodes=1 \
        --gres=gpu:"${GPUS}" \
        --ntasks="${GPUS}" \
        singularity exec --nv \
        "${IMAGE}" \
        "${HPL_SCRIPT}" \
        --dat "${RUN_DAT}" \
        2>&1 | tee "${LOG}"

    RC=${PIPESTATUS[0]}

    if [[ ${RC} -ne 0 ]]; then
        echo "WARNING: experiment failed: ${NAME}"
    else
        echo
        echo "Result:"
        grep '^WC' "${LOG}" | tail -1 >> "${RESULT_SUMMARY}" || true
    fi
}



# ============================================================
# 1 GPU
#
# MPI ranks = 1
# Process grid = 1 x 1
# ============================================================

for N in "${N_1GPU[@]}"; do

    run_hpl \
        1 \
        1 \
        1 \
        "${N}"

done


# ============================================================
# 2 GPUs
#
# MPI ranks = 2
# Process grid = 1 x 2
# ============================================================

for N in "${N_2GPU[@]}"; do

    run_hpl \
        2 \
        1 \
        2 \
        "${N}"

done


# ============================================================
# 4 GPUs
#
# MPI ranks = 4
# Process grid = 2 x 2
# ============================================================

for N in "${N_4GPU[@]}"; do

    run_hpl \
        4 \
        2 \
        2 \
        "${N}"

done






echo
echo "============================================================"
echo "ALL HPL EXPERIMENTS FINISHED"
echo "Results directory:"
echo "${RESULT_DIR}"
echo "============================================================"
