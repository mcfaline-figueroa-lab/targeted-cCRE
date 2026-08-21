# Targeted cCRE Screen Analysis

This folder contains scripts for processing and analyzing the targeted cCRE screening data.

## Data Requirements

To run these scripts, you must first download the required external datasets and place them in a central `data/` directory at the root of the repository (`../data/`).

Download the 3 targeted cCRE datasets from GEO Series **GSE336011**. 

For each of the three targeted cCRE datasets (`targeted_cCRE_1`, `targeted_cCRE_2`, `targeted_cCRE_3`), make a subfolder in the `data` folder and download these 3 files directly into them:
1. `cds_precell_prehash.RDS`
2. `hashTable.out.txt.gz`
3. `CROPTable.out.txt.gz`

Your final data structure should look like this:
```
../data/
├── targeted_cCRE_1/
│   ├── cds_precell_prehash.RDS
│   ├── hashTable.out.txt.gz
│   └── CROPTable.out.txt.gz
├── targeted_cCRE_2/
│   ├── cds_precell_prehash.RDS
│   ├── hashTable.out.txt.gz
│   └── CROPTable.out.txt.gz
└── targeted_cCRE_3/
    ├── cds_precell_prehash.RDS
    ├── hashTable.out.txt.gz
    └── CROPTable.out.txt.gz
```

*Note: You do not need to unzip the `.txt.gz` files. The scripts are designed to dynamically read the raw, gzipped files straight from GEO.*

## Execution

1. **Step 1:** Run the dependency scripts (`targeted_cCRE_1.Rmd`, `targeted_cCRE_2.Rmd`, `targeted_cCRE_3.Rmd`) first. They will read from the `data/` folder and generate intermediate CDS objects with hash and CROP assignments in their respective `./outputs/` folders for downstream analysis.

2. **Step 2:** Run `targeted_cCRE_combine_cds_preliminary_analysis.Rmd`. This script needs to be run second, it prepares the MSH2 cds object necessary to run the sliding window script by combining the three cds objects from `targeted_cCRE_1.Rmd`, `targeted_cCRE_2.Rmd`, `targeted_cCRE_3.Rmd`, mapping the genomic location of the sgRNAs, and subsetting the cds for MSH2 (`targeted_cCRE_combined_cds_msh2_only_final.RDS`). It also outputs `targeted_cCRE_combined_cds_all_genes_final.RDS` which is used in `cds_calculations_paper_results_section.Rmd`. And it performs some preliminary analysis such as principal component analysis and UMAPs.

3. **Step 3:** Run `cds_calculations_paper_results_section.Rmd`. This script uses the full combined dataset from Step 2 (`targeted_cCRE_combined_cds_all_genes_final.RDS`) to calculate summary statistics (median cells per sgRNA/dose) and determine detectability ranks for genes of interest, generating the final summary tables for the paper.

4. **Step 4:** Run the sliding window GLM with bootstrapping on a computing cluster using the scripts in `HPC_scripts_for_sliding_window_GLM/`. This analysis uses the `targeted_cCRE_combined_cds_msh2_only_final.RDS` output from Step 2. *Note: We highly recommend running this on an HPC cluster due to the intensive computational requirements.* These scripts will output the bootstrapped GLM results in a `.csv` file. The final `.csv` results can be found pre-compiled in this repository's `../data/HPC_outputs/` folder, as well as in the supplementary tables Excel file: *Supplementary Table 5* (Sliding window analysis results with 100 cell threshold per window-dose combination) and *Supplementary Table 6* (Sliding window analysis results with 40 cell threshold per window-dose combination).

5. **Step 5:** Run `sliding_window_analysis_cells40_w150_s25.Rmd` (for the 40-cell threshold results) or `sliding_window_analysis_cells100_w150_s25.Rmd` (for the 100-cell threshold results). These scripts read the pre-computed cluster `.csv` results directly from the `../data/HPC_outputs/` folder and generate the final figures (including the interactive and static dose-dependent lollipop plots and effect distribution histograms) as well as filtered `.csv` outputs. The script `sliding_window_analysis_cells100_w150_s25.Rmd` also has code to perform "percent cells positive" plotting with bootstrapped p-values for STON1 and MSH2 nominal hit windows of interest. These plots are not specific to the 100-cell threshold because the same windows are nominal hits for the 40-cell threshold, and the code uses the base CDS object made prior to running the GLM.
