# CP2K H2O-256 Benchmark

To run the `H2O-256.inp` CP2K benchmark, make sure the input file is present in the same directory where the Slurm job will be submitted.

Run:

```bash
sbatch sbatch.sh
```

The benchmark requires:

```bash
CP2K/2023.1-foss-2023a
```

The provided job runs on a **single node** using:

```text
14 MPI tasks
4 CPUs per task
56 CPU cores in total
```

By default, `sbatch.sh` performs a **single benchmark run**.

Since a single execution can be affected by performance variations, it is recommended to perform warm-up runs followed by several measured runs.

After installing [`hyperfine`](https://github.com/sharkdp/hyperfine), you can use:

```bash
hyperfine --warmup 1 --runs 3 \
    --prepare "rm -f H2O-256.out H2O-256-*.ener H2O-256-pos-*.xyz" \
    "srun --mpi=pmix --nodes=1 --ntasks=14 --ntasks-per-node=14 --cpus-per-task=4 cp2k.psmp -i H2O-256.inp -o H2O-256.out"
```

This performs **1 warm-up run** and **3 measured runs**, giving more representative execution-time results.
