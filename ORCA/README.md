# ORCA Example Run

This example uses the `caffeine.inp` input file to demonstrate how to run ORCA on multiple nodes.

Make sure `caffeine.inp` is present in the submission directory, then launch the job with:

```bash
sbatch sbatch.sh
```

The example requires:

```bash
ORCA/6.1.1-gompi-2024a-avx2
```

The provided job runs on:

```text
2 nodes
12 MPI ranks per node
1 CPU per MPI rank
```

The main ORCA output is written to the `out` file (as specified in the submission script).

A successful execution should end with:

```text
****ORCA TERMINATED NORMALLY****
```

The total execution time is also reported at the end of the output.
