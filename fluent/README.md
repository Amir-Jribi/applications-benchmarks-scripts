# ANSYS Fluent Example Run

This example demonstrates how to run ANSYS Fluent in batch mode on the CPU partition.

The job uses:

```text
ANSYS Fluent
3D solver
1 node
56 CPU tasks
```

Submit the job with:

```bash
sbatch sbatch.sh
```

The calculation is launched with:

```bash
fluent 3d -g -t56 -i run.jou
```

The `run.jou` file contains the Fluent commands to read the case, initialize the solution, perform the iterations, and write the resulting data. For example:

```text
/file/read-case "uav coarse mesh results.cas.h5"

/solve/initialize/initialize-flow

/solve/iterate 100

/file/write-data "uav_results_100iter.dat.h5"

/exit yes
```

Before running the job, update the case filename and other parameters in `run.jou` according to your use case, including the number of iterations and output filename.
