#!/bin/bash
#
#SBATCH --account=cgl               # Change to your account name
#SBATCH --job-name=1000_boot_MSH2    # A descriptive job name
#SBATCH --time=48:00:00             # Time limit (hrs:min:sec)
#SBATCH --nodes=1                   # Request 1 full node
#SBATCH --ntasks-per-node=32        # Use all 32 cores on that node
#SBATCH --exclusive                 # Ensure no other jobs run on the node
#SBATCH -o "batch-logs/%u-%x-%j.out"  # Standard output and error log

# --- Setup ---
echo "#####################################################"
echo "Job started on $(hostname) at $(date)"
echo "Job ID: $SLURM_JOB_ID"
echo "Working directory: $(pwd)"
echo "#####################################################"

# --- Load Required Modules ---
# Use the module versions that are known to work on your cluster
echo "Loading required modules..."
module load R/4.1.0
module load gdal/3.3.0
module load geos
echo "R executable: $(which R)"
echo "#####################################################"

# --- Define File Paths and Parameters ---
# It's good practice to define these at the top for easy editing
RSCRIPT_PATH="./run_sliding_window_analysis_9_4_25.R"
CDS_INPUT_PATH="../outputs/targeted_cCRE_combined_cds_msh2_only_final.RDS"
RESULTS_OUTPUT_PATH="100cells_msh2_sliding_window_1000bootstrap_results.csv"
CELL_THRESHOLD=100 # Change as needed, we ran this twice, for 40 and 100 cells
WINDOW_SIZE=150
SLIDE_SIZE=25
NUM_BOOTSTRAPS=1000

# --- Safety Check: Verify Script Exists ---
echo "Verifying R script location..."
ls -l ${RSCRIPT_PATH}
echo "#####################################################"

# --- Print Parameters to Log ---
echo "Running analysis with the following parameters:"
echo "Cell Threshold: ${CELL_THRESHOLD}"
echo "Window Size: ${WINDOW_SIZE}"
echo "Slide Size: ${SLIDE_SIZE}"
echo "Number of Bootstraps: ${NUM_BOOTSTRAPS}"
echo "#####################################################"

# --- Execute the R Script ---
echo "Running the sliding window analysis R script..."
Rscript ${RSCRIPT_PATH} \
    --cds_path ${CDS_INPUT_PATH} \
    --output_path ${RESULTS_OUTPUT_PATH} \
    --cell_threshold ${CELL_THRESHOLD} \
    --window_size ${WINDOW_SIZE} \
    --slide_size ${SLIDE_SIZE} \
    --n_bootstraps ${NUM_BOOTSTRAPS}

echo "R script finished with exit code $?."
echo "#####################################################"
echo "Job finished at $(date)"
echo "#####################################################"
