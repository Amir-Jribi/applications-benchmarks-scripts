# Quantum ESPRESSO AUSURF112 Benchmark

This benchmark uses the `AUSURF112` input files from the official Quantum ESPRESSO benchmark repository:

[`QEF/benchmarks`](https://github.com/QEF/benchmarks)

Clone the repository:

```bash
git clone https://github.com/QEF/benchmarks.git
```

Then copy the contents of:

```text
benchmarks/AUSURF112
```

to the directory from which you will submit the job.

The benchmark requires:

```bash
QuantumESPRESSO/7.4-foss-2024a
```

The provided job runs on:

```text
1 node
56 MPI ranks
1 CPU per MPI rank
```

Submit the job with:

```bash
sbatch sbatch.sh
```

The calculation is executed with:

```bash
mpirun -np 56 pw.x -i ausurf.in | tee ausurf.out
```

The main Quantum ESPRESSO output is written to:

```text
ausurf.out
```
