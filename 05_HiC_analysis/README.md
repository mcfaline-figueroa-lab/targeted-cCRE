# Hi-C Looped Genome Interaction Visualization

The analysis script [`MANE_plot_hic_looped_final.Rmd`](MANE_plot_hic_looped_final.Rmd) visualizes Hi-C loops and contact maps at the STON1 locus using `plotgardener`.

Because `.mcool` files are extremely large (~500MB to 1.1GB each, totaling 24GB), they are excluded from this Git repository. To run this script, you must download them from the NCBI Gene Expression Omnibus (GEO).

## GEO Data Accession

* **GEO Series/Sample**: **GSE229962** (Micro-C and Hi-C profiling of glioblastoma stem cells)

### Download and Placement

1. Download the `.mcool` contact map files from GEO GSE229962 RAW.
2. Place the `.mcool` files into the directory relative to this folder:
   ```
   ../data/hi_c/mcool/
   ```


