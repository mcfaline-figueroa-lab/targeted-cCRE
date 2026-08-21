# STON1 Locus Visualization Track Data

The analysis script [`STON1_locus_fig.Rmd`](STON1_locus_fig.Rmd) generates genomic browser figures for the **STON1** locus using ATAC-seq bigWig tracks.

Because the bigWig files are large (~200MB each), they are not checked into this Git repository. To run this script, you must download them from NCBI Gene Expression Omnibus (GEO).

## GEO Data Accession

* **GEO Series/Sample**: **GSM9825200** (A172 ATAC-seq timepoint profiling)

### Required Files

Download the following files and place them in `github_repository/data/STON1_locus/bigwig/`:
1. **`GSM9825200_96hr_0.mRp.clN.bigWig`** (96 hours 0µM DMSO control)
2. **`GSM9825200_96hr_100.mRp.clN.bigWig`** (96 hours 100µM TMZ treatment)

> [!NOTE]
> The RMarkdown script dynamically supports loading these files with or without their `GSM9825200_` prefix.
