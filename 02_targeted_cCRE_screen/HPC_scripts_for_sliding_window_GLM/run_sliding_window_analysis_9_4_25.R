#!/usr/bin/env Rscript

# ==============================================================================
# Description:
# This script performs a memory-efficient, parallelized sliding window analysis
# with bootstrapping to assess the stability of model estimates. It loads the
# main data object within each parallel worker to minimize memory overhead.
# Date: September 4, 2025
# ==============================================================================

# --- 1. SETUP: Load Libraries ---
cat("Loading required libraries...\n")
suppressPackageStartupMessages({
    library(monocle3)
    library(dplyr)
    library(tidyr)
    library(tibble)
    library(stringr)
    library(optparse)
    library(foreach)
    library(doParallel)
})

# --- 2. ARGUMENT PARSING ---
option_list <- list(
    make_option(c("-c", "--cds_path"), type="character", default=NULL,
                help="Path to the input CDS object (.rds file)", metavar="character"),
    make_option(c("-o", "--output_path"), type="character", default="sliding_window_results.csv",
                help="Path for the output results CSV file [default= %default]", metavar="character"),
    make_option(c("-t", "--cell_threshold"), type="integer", default=50,
                help="Minimum number of cells required in a window to run the model [default= %default]", metavar="integer"),
    make_option(c("-w", "--window_size"), type="integer", default=200,
                help="Size of the sliding window in base pairs [default= %default]", metavar="integer"),
    make_option(c("-s", "--slide_size"), type="integer", default=50,
                help="Step size (slide) for the sliding window in base pairs [default= %default]", metavar="integer"),
    make_option(c("-b", "--n_bootstraps"), type="integer", default=100,
                help="Number of bootstrap iterations to perform [default= %default]", metavar="integer")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$cds_path)){
    print_help(opt_parser)
    stop("Input CDS file path (--cds_path) must be provided.", call.=FALSE)
}

# --- 3. PRE-COMPUTE TASKS (MEMORY EFFICIENT) ---
cat("Generating task list from input data...\n")
temp_cds <- readRDS(opt$cds_path)
cd <- as.data.frame(colData(temp_cds))

targeting_cd <- cd %>% filter(ATAC_bin != "NTC")
unique_bins <- targeting_cd %>%
               distinct(ATAC_bin, ATAC_bin_start, ATAC_bin_end, ATAC_bin_length)

cat(paste("Found", nrow(unique_bins), "unique experimental ATAC bins to process.\n"))

tasks_list <- list()
for (i in 1:nrow(unique_bins)) {
    bin_info <- unique_bins[i, ]
    if (is.na(bin_info$ATAC_bin_length)) {
        tasks_list[[length(tasks_list) + 1]] <- tibble(
            ATAC_bin = bin_info$ATAC_bin, window_start = NA_real_, window_end = NA_real_,
            window_scheme = "NA_control_window"
        )
    } else if (bin_info$ATAC_bin_length >= opt$window_size) {
        current_start <- bin_info$ATAC_bin_start
        while(TRUE) {
            current_end <- current_start + opt$window_size
            tasks_list[[length(tasks_list) + 1]] <- tibble(
                ATAC_bin = bin_info$ATAC_bin,
                window_start = current_start,
                window_end = current_end,
                window_scheme = "sliding_window"
            )
            if (current_end >= bin_info$ATAC_bin_end) {
                break
            }
            current_start <- current_start + opt$slide_size
        }
    } else {
        tasks_list[[length(tasks_list) + 1]] <- tibble(
            ATAC_bin = bin_info$ATAC_bin, window_start = bin_info$ATAC_bin_start, window_end = bin_info$ATAC_bin_end,
            window_scheme = "small_window"
        )
    }
}

tasks_df <- bind_rows(tasks_list)
doses <- unique(cd$dose[!is.na(cd$dose)])
tasks_to_run <- expand_grid(tasks_df, dose = doses)

rm(temp_cds, cd, targeting_cd, unique_bins, tasks_list, tasks_df)
gc()

cat(paste("Generated a total of", nrow(tasks_to_run), "window/dose combinations for analysis.\n"))

# --- 4. SETUP AND RUN PARALLEL ANALYSIS ---
num_cores <- as.numeric(Sys.getenv("SLURM_NTASKS"))
if (is.na(num_cores) || num_cores < 1) {
  num_cores <- 1
}
registerDoParallel(cores = num_cores)
cat(paste("Registered parallel backend with", num_cores, "cores.\n"))

all_results <- foreach(
  i = 1:nrow(tasks_to_run),
  .combine = 'bind_rows',
  .packages = c("monocle3", "dplyr", "stringr", "tibble")
) %dopar% {

    # --- Initial data loading and setup within each worker ---
    cds <- readRDS(opt$cds_path)
    cd <- as.data.frame(colData(cds)) %>% mutate(cell_id = rownames(.))
    ntc_cd <- cd %>% filter(ATAC_bin == "NTC")
    targeting_cd <- cd %>% filter(ATAC_bin != "NTC")
    
    task <- tasks_to_run[i, ]
    current_bin <- task$ATAC_bin
    current_dose <- task$dose
    w_start <- task$window_start
    w_end <- task$window_end
    w_scheme <- task$window_scheme

    window_id <- if (w_scheme == "NA_control_window") {
        current_bin
    } else {
        paste0(current_bin, "_", w_start, "_", w_end)
    }

    # --- Subset cells for the current window ---
    if (w_scheme == "NA_control_window") {
        window_cells_cd <- targeting_cd %>% filter(ATAC_bin == current_bin, dose == current_dose)
    } else {
        window_cells_cd <- targeting_cd %>%
            filter(ATAC_bin == current_bin, dose == current_dose,
                   (genomic_start >= w_start & genomic_start <= w_end) | (genomic_end >= w_start & genomic_end <= w_end))
    }

    cell_count <- nrow(window_cells_cd)
    num_unique_sgrnas <- length(unique(window_cells_cd$sgRNA.sequence))
    sgrnas_in_window <- paste(unique(window_cells_cd$sgRNA.sequence), collapse = ",")

    # --- Main Analysis Logic with Bootstrapping ---
    if (cell_count >= opt$cell_threshold) {
        ntc_dose_cd <- ntc_cd %>% filter(dose == current_dose)
        if (nrow(ntc_dose_cd) > 0) {
            
            test_cell_ids <- window_cells_cd$cell_id
            control_cell_ids <- ntc_dose_cd$cell_id
            bootstrap_results_list <- list()

            for (b in 1:opt$n_bootstraps) {
                boot_test_ids <- sample(test_cell_ids, size = length(test_cell_ids), replace = TRUE)
                boot_control_ids <- sample(control_cell_ids, size = length(control_cell_ids), replace = TRUE)
                cds_boot <- cds[, c(boot_test_ids, boot_control_ids)]
                
                colData(cds_boot)$window <- "NTC"
                colData(cds_boot)[boot_test_ids, "window"] <- window_id
                colData(cds_boot)$window <- factor(colData(cds_boot)$window, levels = c("NTC", window_id))

                model_fit_boot <- tryCatch({
                    fit_models(cds_boot, model_formula_str = "~sample + window", expression_family = "quasipoisson")
                }, error = function(e) { NULL })

                if (!is.null(model_fit_boot)) {
                    coef_table_boot <- coefficient_table(model_fit_boot)
                    model_results_boot <- coef_table_boot %>%
                        filter(str_detect(term, "window")) %>%
                        mutate(bootstrap_iteration = b)
                    bootstrap_results_list[[b]] <- model_results_boot
                }
            } 

            if (length(bootstrap_results_list) > 0) {
                agg_results <- bind_rows(bootstrap_results_list) %>%
                    group_by(term) %>%
                    summarise(
                        id = first(id),
                        gene_short_name = first(gene_short_name),
                        model_component = first(model_component),
                        mean_normalized_effect = mean(normalized_effect, na.rm = TRUE),
                        std_err_normalized_effect = sd(normalized_effect, na.rm = TRUE),
                        median_p_value = median(p_value, na.rm = TRUE),
                        conf_low_95 = quantile(normalized_effect, 0.025, na.rm = TRUE),
                        conf_high_95 = quantile(normalized_effect, 0.975, na.rm = TRUE),
                        num_successful_fits = n(),
                        status = if (all(status == "OK")) "OK" else "PARTIAL_FAIL"
                    )
                model_results <- agg_results
            } else { model_results <- tibble(status = "ALL_BOOTSTRAP_FITS_FAILED") }

        } else { model_results <- tibble(status = "NO_NTC_CONTROLS") }
    } else {
        status_label <- if (cell_count == 0) "ZERO_CELLS" else "FILTERED_CELL_COUNT"
        model_results <- tibble(
            id = rowData(cds)$id[1],
            gene_short_name = rowData(cds)$gene_short_name[1],
            model_component = NA_character_,
            term = paste0("window", window_id),
            mean_normalized_effect = NA_real_,
            std_err_normalized_effect = NA_real_,
            median_p_value = NA_real_,
            conf_low_95 = NA_real_,
            conf_high_95 = NA_real_,
            num_successful_fits = 0,
            status = status_label
        )
    }

    # Attach metadata and return the aggregated summary for the window
    final_row <- model_results %>%
        mutate(ATAC_bin = current_bin, dose = current_dose, window_start = w_start,
               window_end = w_end, window_scheme = w_scheme, cell_count = cell_count, 
               num_unique_sgrnas = num_unique_sgrnas,
               sgRNA_per_window = sgrnas_in_window,
               .before = 1)
               
    return(final_row)
}

stopImplicitCluster()
cat("Parallel processing finished.\n")

# --- 5. SAVING FINAL RESULTS ---
cat("Saving final results...\n")

# The output data frame now contains all the columns needed
write.csv(all_results, opt$output_path, row.names = FALSE)

cat(paste("\nAnalysis complete! Results saved to:", opt$output_path, "\n"))