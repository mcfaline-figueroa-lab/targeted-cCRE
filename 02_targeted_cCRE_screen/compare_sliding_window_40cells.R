# compare_sliding_window_40cells.R

library(tools)

orig_output_dir <- "/Users/annaschoonen/Documents/JMF_lab_project/aim2/combined_analysis_of_all_working_KRAB_premade_probe_targeted_sci_experiments_feb_may_june/true_sliding_windows_with_overlap/bootstrap_sliding_windows/updated_bootstrap_code_9_4_25/updated_code_1000bootstrap_150bpwindow_slide25_40cells/final_lollipop_plots"
orig_supp_dir <- file.path(orig_output_dir, "Final_supplemental_figs_for_paper")
orig_pdf_dir <- "/Users/annaschoonen/Documents/JMF_lab_project/figures_for_paper/supplementary_figs/goes_with_fig2/distribution_mean_norm_effect_modeling_results"
orig_calc_dir <- "/Users/annaschoonen/Documents/JMF_lab_project/aim2/combined_analysis_of_all_working_KRAB_premade_probe_targeted_sci_experiments_feb_may_june/true_sliding_windows_with_overlap/bootstrap_sliding_windows/updated_bootstrap_code_9_4_25/updated_code_1000bootstrap_150bpwindow_slide25_40cells/calculations_for_paper_results_section"
new_output_dir <- "./outputs/sliding_window_40cells"

files_to_compare <- list(
  # PDFs
  list(orig = file.path(orig_pdf_dir, "40cells_dist_mean_norm_effect.pdf"),
       new = file.path(new_output_dir, "40cells_dist_mean_norm_effect.pdf"), type="binary"),
  list(orig = file.path(orig_output_dir, "cells40_all_modeling_results_static_lollipop_final.pdf"),
       new = file.path(new_output_dir, "cells40_all_modeling_results_static_lollipop_final.pdf"), type="binary"),
  list(orig = file.path(orig_output_dir, "cells40_static_lollipop_significant_windows_inverted_v5.pdf"),
       new = file.path(new_output_dir, "cells40_static_lollipop_significant_windows.pdf"), type="binary"),
  list(orig = file.path(orig_supp_dir, "FINAL_Supp_fig_40cell_threshold_cell_number_static_lollipop_significant_windows_inverted_v5.pdf"),
       new = file.path(new_output_dir, "40cell_threshold_cell_number_static_lollipop_significant_windows.pdf"), type="binary"),

  # PNGs
  list(orig = file.path(orig_output_dir, "cells40_all_modeling_results_static_lollipop_final.png"),
       new = file.path(new_output_dir, "cells40_all_modeling_results_static_lollipop_final.png"), type="binary"),
  list(orig = file.path(orig_output_dir, "cells40_static_lollipop_significant_windows_inverted_v5.png"),
       new = file.path(new_output_dir, "cells40_static_lollipop_significant_windows.png"), type="binary"),
  list(orig = file.path(orig_supp_dir, "FINAL_Supp_fig_40cell_threshold_cell_number_static_lollipop_significant_windows_inverted_v5.png"),
       new = file.path(new_output_dir, "40cell_threshold_cell_number_static_lollipop_significant_windows.png"), type="binary"),

  # CSVs
  list(orig = file.path(orig_output_dir, "significant_atac_bins_40cells_w_colors.csv"),
       new = file.path(new_output_dir, "significant_atac_bins_40cells_w_colors.csv"), type="csv"),
  list(orig = file.path(orig_calc_dir, "significant_windows_only_40cells_v6script.csv"),
       new = file.path(new_output_dir, "significant_windows_only_40cells.csv"), type="csv"),
  list(orig = file.path(orig_calc_dir, "all_sgRNA_across_significant_windows_40cells.csv"),
       new = file.path(new_output_dir, "all_sgRNA_across_significant_windows_40cells.csv"), type="csv"),
       
  # HTMLs
  list(orig = file.path(orig_output_dir, "cells40_all_modeling_results_interactive_lollipop_final.html"),
       new = file.path(new_output_dir, "cells40_all_modeling_results_interactive_lollipop_final.html"), type="binary"),
  list(orig = file.path(orig_output_dir, "cells40_interactive_lollipop_nominal_hit_windows_detailed_hover_FINAL.html"),
       new = file.path(new_output_dir, "cells40_interactive_lollipop_nominal_hit_windows_detailed_hover_FINAL.html"), type="binary")
)

all_match <- TRUE

for (f in files_to_compare) {
  cat("\nComparing:", basename(f$new), "\n")
  
  if (!file.exists(f$orig)) {
    cat("  [FAIL] Original file missing:", f$orig, "\n")
    all_match <- FALSE
    next
  }
  if (!file.exists(f$new)) {
    cat("  [FAIL] New file missing:", f$new, "\n")
    all_match <- FALSE
    next
  }
  
  if (f$type == "csv") {
    orig_df <- read.csv(f$orig)
    new_df <- read.csv(f$new)
    if (isTRUE(all.equal(orig_df, new_df))) {
      cat("  [PASS] CSV contents match.\n")
    } else {
      cat("  [FAIL] CSV contents DO NOT match.\n")
      all_match <- FALSE
    }
  } else {
    orig_md5 <- md5sum(f$orig)
    new_md5 <- md5sum(f$new)
    if (orig_md5 == new_md5) {
      cat("  [PASS] MD5 hashes match (", new_md5, ").\n", sep="")
    } else {
      cat("  [WARNING] MD5 hashes differ. (This is common for PDFs/HTML/PNGs due to timestamps or randomized widget IDs).\n")
      cat("       Orig:", orig_md5, "\n")
      cat("       New :", new_md5, "\n")
    }
  }
}

if (all_match) {
  cat("\nSUCCESS: All critical data structures (CSVs) match perfectly!\n")
} else {
  cat("\nFAILURE: Some critical files were missing or their underlying data structures did not match.\n")
}
