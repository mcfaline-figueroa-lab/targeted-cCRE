# TMZ Survival Screen Analysis

This directory contains the scripts for processing and analyzing the TMZ survival screens with KRAB base editing (CRISPRi) and BE4max base editing.

## Data Requirements

To run the analysis scripts, you must first obtain the raw count files and place them in the correct directory.

### 1. Download from GEO

#### TMZ Survival Screen (KRAB)
Download the 6 raw count files from GEO Sample **GSM9825208** (sample name: `TMZ_survival_CRISPRi_KRAB`):
1. `GSM9825208_KRAB_TMZ_survival_01GG01_S1_counts.txt.gz` (DMSO replicate 1)
2. `GSM9825208_KRAB_TMZ_survival_02GG02_S2_counts.txt.gz` (DMSO replicate 2)
3. `GSM9825208_KRAB_TMZ_survival_03GG03_S3_counts.txt.gz` (DMSO replicate 3)
4. `GSM9825208_KRAB_TMZ_survival_04GG04_S4_counts.txt.gz` (TMZ replicate 1)
5. `GSM9825208_KRAB_TMZ_survival_05GG05_S5_counts.txt.gz` (TMZ replicate 2)
6. `GSM9825208_KRAB_TMZ_survival_06GG06_S6_counts.txt.gz` (TMZ replicate 3)

#### TMZ Survival Screen (BE4max)
Download the 6 raw count files from GEO Sample **GSM9825209** (sample name: `TMZ_survival_CRISPRi_BE4max`):
1. `GSM9825209_BE4max_TMZ_survival_01DD01_S1_counts.txt.gz` (DMSO replicate 1)
2. `GSM9825209_BE4max_TMZ_survival_02DD02_S2_counts.txt.gz` (DMSO replicate 2)
3. `GSM9825209_BE4max_TMZ_survival_03DD03_S3_counts.txt.gz` (DMSO replicate 3)
4. `GSM9825209_BE4max_TMZ_survival_04DD04_S4_counts.txt.gz` (TMZ replicate 1)
5. `GSM9825209_BE4max_TMZ_survival_05DD05_S5_counts.txt.gz` (TMZ replicate 2)
6. `GSM9825209_BE4max_TMZ_survival_06DD06_S6_counts.txt.gz` (TMZ replicate 3)

### 2. File Directory Placement
Place the downloaded count files in the following directory relative to this folder:
```
../data/TMZ_survival_screen/raw_counts/
```

*Note: You do not need to unzip the `.txt.gz` files. The analysis scripts are designed to dynamically read either the raw uncompressed `.txt` files or the gzipped `.txt.gz` files, and they will strip the GEO prefixes automatically.*
