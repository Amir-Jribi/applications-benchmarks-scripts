# GROMACS benchMEM Benchmark

Download the benchMEM.tpr input file from the official benchmark page, then copy it to the directory from which you will submit the job:

[`benchMEM`](https://www.mpinat.mpg.de/benchMEM)

The benchmark is tested on both the **CPU partition** and the **H100 GPU partition**.

## CPU Run

The provided CPU job runs on:

```text
2 nodes
56 MPI ranks per node
1 CPU per MPI rank
```

Submit the job with:

```bash
sbatch sbatch-cclake.sh
```

The benchmark is executed with:

```bash
srun --mpi=pmix --nodes=2 --ntasks-per-node=56 \
    gmx_mpi mdrun -s benchMEM.tpr
```

## H100 GPU Run

The provided GPU job uses:

```text
1 H100 GPU
1 MPI rank
28 CPU threads
```

Submit the job with:

```bash
sbatch sbatch-h100.sh
```

The benchmark is executed with GPU offloading enabled for the non-bonded interactions, PME, and bonded interactions:

```bash
srun --mpi=pmix \
    gmx_mpi mdrun -s benchMEM.tpr \
    -nb gpu \
    -pme gpu \
    -bonded gpu
```

For runs using multiple MPI ranks with GPU PME offloading, the `-npme` option should also be specified to define the number of PME ranks.
