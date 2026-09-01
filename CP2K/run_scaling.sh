#!/bin/bash

# ============================================================
# CP2K H2O-256 scaling benchmark
#
# Nodes:           1, 2, 4, 8, 16, 32
# Cores/node:      56
# CPUs/task:       1, 2, 4
#
# ntasks-per-node = 56 / cpus-per-task
# ============================================================

TEMPLATE="cp2k.template"

CORES_PER_NODE=56

BASE_DIR="./scaling"

mkdir -p "${BASE_DIR}"

for nodes in 1 2 4 8 16 32; do

    for cpus in 1 2 4; do

        # MPI ranks per node
        ntasks_per_node=$((CORES_PER_NODE / cpus))

        # Total MPI ranks
        ntasks=$((nodes * ntasks_per_node))

        # Total CPU cores requested
        total_cpus=$((ntasks * cpus))

        OUTDIR="${BASE_DIR}/nodes-${nodes}/cpus-${cpus}"

        mkdir -p "${OUTDIR}"

        JOB_SCRIPT="${OUTDIR}/job.sh"

        echo "=========================================="
        echo "Configuration"
        echo "  Nodes:             ${nodes}"
        echo "  CPUs/task:         ${cpus}"
        echo "  NTASKS/node:       ${ntasks_per_node}"
        echo "  Total NTASKS:      ${ntasks}"
        echo "  Total CPUs:        ${total_cpus}"
        echo "  Output directory:  ${OUTDIR}"
        echo "=========================================="

        sed \
            -e "s|__NODES__|${nodes}|g" \
            -e "s|__CPUS__|${cpus}|g" \
            -e "s|__NTASKS__|${ntasks}|g" \
            -e "s|__NTASKS_PER_NODE__|${ntasks_per_node}|g" \
            -e "s|__TOTAL_CPUS__|${total_cpus}|g" \
            -e "s|__OUTDIR__|${OUTDIR}|g" \
            "${TEMPLATE}" > "${JOB_SCRIPT}"

        chmod +x "${JOB_SCRIPT}"

        JOB_ID=$(sbatch --parsable "${JOB_SCRIPT}")

        echo "  Job ID:            ${JOB_ID}"

        sleep 1

    done

done
