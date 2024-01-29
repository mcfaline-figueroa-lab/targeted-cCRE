#!/bin/bash
#
#
# Replace ACCOUNT with your account name before submitting.
#
#SBATCH --account=cgl      	 # Replace ACCOUNT with your group account name
#SBATCH --job-name=omni     # The job name
#SBATCH --time=0-24:00            # The time the job will take to run in D-HH:MM
#SBATCH --mem-per-cpu=6G         # The memory the job will use per cpu core
#SBATCH -c 12			# the number of CPUs needed,
#SBATCH -o "/burg/cgl/users/acs2330/working_outputs/%u-%x-%j.out"

/burg/home/acs2330/.conda/envs/omnienv/bin/nextflow run nf-core/atacseq --input /burg/cgl/users/acs2330/design.csv --genome GRCh38 -profile singularity --outdir /burg/cgl/users/acs2330/v3_12_1_22_nfcore_outputs/












