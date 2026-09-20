#!/bin/bash

#SBATCH --job-name=fluent_run
#SBATCH --output=fluent_output_%A.out
#SBATCH --error=fluent_error_%A.err
#SBATCH --nodes=1
#SBATCH --ntasks=56
#SBATCH --cpus-per-task=1
#SBATCH --time=00:20:00

ml load ansys/fluent

fluent 3d -g -t56 -i run.jou 
