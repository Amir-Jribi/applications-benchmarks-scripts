# VASP Example Run

This example demonstrates how to run VASP on the **CPU**, **A100 GPU**, and **H100 GPU** partitions.

Make sure the VASP input files are available inside the `input/` directory before submitting the job.

## CPU Run

The CPU job uses:

```text
VASP 6.5.0
Compiled with Intel 2024a
```

The provided job runs on:

```text
1 node
4 MPI ranks
```

Submit with:

```bash
sbatch sbatch_cpu.sh
```

The calculation is launched with:

```bash
mpirun -np 4 vasp_std
```

## A100 GPU Run

The A100 job uses:

```text
VASP 6.6.0
Compiled with NVHPC 23.5
CUDA 12.1.0
```

The provided job runs on:

```text
1 A100 GPU
1 MPI rank
```

Submit with:

```bash
sbatch sbatch-a100.sh
```

The calculation is launched with:

```bash
srun --mpi=pmix vasp_std
```

## H100 GPU Run

The H100 job uses:

```text
VASP 6.6.0
Compiled with NVHPC 23.5
CUDA 12.2.0
```

The provided job runs on:

```text
1 H100 GPU
1 MPI rank
```

Submit with:

```bash
sbatch sbatch-h100.sh
```

The calculation is launched with:

```bash
srun --mpi=pmix vasp_std
```

The required VASP module is loaded automatically inside each submission script.
