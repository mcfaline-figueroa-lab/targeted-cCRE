# ATAC-seq Analysis

This folder contains the scripts for analyzing the ATAC-seq data.

## Data Requirements

To run these scripts, you must first download the required external datasets and place them in a central `data/` directory at the root of the repository (`../data/`).

### 1. GEO Data (A172 GBM ATAC-seq)
Download the raw ATAC-seq counts and BigWig files from GEO for the sample `A172_GBM_ATAC_seq`. 
Place all downloaded files directly into the following folder:
`../data/A172_GBM_ATAC_seq/`

*Note: You do not need to unzip the `.gz` files or remove the `GSM9825200_` prefix. The scripts are designed to dynamically read the raw, gzipped files straight from GEO.*

### 2. MANE Annotation
The plotting scripts utilize the MANE Transcript Annotation Data (Version 1.5).
Download `MANE.GRCh38.v1.5.refseq_genomic.gff.gz` directly from the NCBI FTP site:
`ftp://ftp.ncbi.nlm.nih.gov/refseq/MANE/release_1.5/`

Place the downloaded `.gff.gz` file in the following folder:
`../data/MANE/`

### 3. Patient Data
The patient data BED files from Wang (2022) (GSE174554) used for consensus overlap are already provided within the repository at `../data/patient_data/GSE174554/`.

## Execution
Run `ATAC_analysis.Rmd` first. It will create an `outputs/` folder and generate the required intermediate BED files for the downstream visualization scripts (`DAS_regions_8_bigwigs_visualization.Rmd` and `all_bigwigs_dense_and_full_gene_tracks_MMR.Rmd`).
