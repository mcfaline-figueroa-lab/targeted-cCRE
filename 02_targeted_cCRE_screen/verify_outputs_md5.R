library(digest)
library(dplyr)

# Define paths
legacy_dir <- "/Users/annaschoonen/Documents/JMF_lab_project/aim2/combined_analysis_of_all_working_KRAB_premade_probe_targeted_sci_experiments_feb_may_june/true_sliding_windows_with_overlap/bootstrap_sliding_windows/updated_bootstrap_code_9_4_25/updated_code_1000bootstrap_150bpwindow_slide25_40cells/final_pooled_hit_sgRNA_FACS_guide_lib"

new_dir <- "./outputs/TMZ_survival_screen_sgRNA_library"

# 1. Compare Supplementary Table CSV
legacy_supp <- file.path(legacy_dir, "TMZ_survival_screen_pooled_1000_guides_6_20_25_use_this_for_publishing.csv")
new_supp <- file.path(new_dir, "TMZ_survival_screen_pooled_1000_guides_for_publishing.csv")

# 2. Compare GenScript Order CSV
legacy_order <- file.path(legacy_dir, "FINAL_POOL_genscript_ordering/github_clean_code_FACS_pooled_sgRNA_lib_hits_for_genscript_order.csv")
new_order <- file.path(new_dir, "TMZ_survival_screen_pooled_1000_sgRNA_lib_genscript_order.csv")

compare_files <- function(name, legacy_path, new_path) {
  cat("\n--- Comparing:", name, "---\n")
  
  if (!file.exists(legacy_path)) {
    cat("Legacy file missing:", legacy_path, "\n")
    return(FALSE)
  }
  if (!file.exists(new_path)) {
    cat("New file missing (Have you run the new Rmd script yet?):", new_path, "\n")
    return(FALSE)
  }
  
  # Check MD5 hash
  legacy_md5 <- digest(file = legacy_path, algo = "md5")
  new_md5 <- digest(file = new_path, algo = "md5")
  
  cat("Legacy MD5:", legacy_md5, "\n")
  cat("New MD5:   ", new_md5, "\n")
  
  if (legacy_md5 == new_md5) {
    cat("✅ PERFECT MATCH: MD5 hashes are identical!\n")
  } else {
    cat("❌ MISMATCH: MD5 hashes differ.\n")
    
    # Read in dataframes to see if they match mathematically
    leg_df <- read.csv(legacy_path)
    new_df <- read.csv(new_path)
    
    cat("Dimensions - Legacy:", dim(leg_df)[1], "x", dim(leg_df)[2], "| New:", dim(new_df)[1], "x", dim(new_df)[2], "\n")
    if (identical(leg_df, new_df)) {
        cat("✅ Dataframes ARE mathematically identical (mismatch is just due to timestamp/metadata or line endings from Mac/Windows mismatch).\n")
    } else {
        cat("❌ Dataframes are mathematically different!\n")
    }
  }
}

compare_files("Supplementary Publish File", legacy_supp, new_supp)
compare_files("GenScript Order File", legacy_order, new_order)
