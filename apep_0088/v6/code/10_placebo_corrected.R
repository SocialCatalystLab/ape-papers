# =============================================================================
# 10_placebo_corrected.R - Run Placebo RDD on Corrected Sample
#
# This script runs the placebo RDD (unrelated referendums) using the same
# corrected sample construction as the main RDD, ensuring diagnostics
# match the identification strategy.
# =============================================================================

# Get script directory for portable sourcing
get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

cat("\n", rep("=", 70), "\n")
cat("PLACEBO RDD ON CORRECTED SAMPLE\n")
cat(rep("=", 70), "\n\n")

# =============================================================================
# LOAD CORRECTED SAMPLE AND VOTING DATA
# =============================================================================

cat("Loading corrected sample...\n")

# Load the corrected RDD sample from 09_fix_rdd_sample.R
corrected_sample <- tryCatch({
  readRDS(file.path(data_dir, "rdd_sample_corrected.rds"))
}, error = function(e) {
  stop("Corrected sample not found. Run 09_fix_rdd_sample.R first.")
})

# Load all voting data (includes multiple referendums)
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))

# Get the unique municipality IDs from the corrected sample
corrected_mun_ids <- unique(corrected_sample$mun_id)
cat(paste("Corrected sample has", length(corrected_mun_ids), "unique municipalities\n"))

# Get the border distances from the corrected sample
border_distances <- corrected_sample %>%
  select(mun_id, dist_to_own_border, nearest_border_pair, signed_distance_km, treated) %>%
  distinct()

# =============================================================================
# IDENTIFY PLACEBO REFERENDUMS
# =============================================================================

cat("\nIdentifying placebo referendums...\n")

# Available referendums in the data
available_votes <- voting_data %>%
  group_by(vote_type) %>%
  summarise(n = n(), .groups = "drop") %>%
  print()

# Define placebo referendums (unrelated to energy policy)
placebo_votes <- c("immigration_2016", "durchsetzung_2016",
                   "corporate_tax_2017", "usr_iii_2017")

# Filter voting data for placebo votes
placebo_data <- voting_data %>%
  filter(vote_type %in% placebo_votes)

if (nrow(placebo_data) == 0) {
  cat("No placebo referendums found in data. Trying alternative approach...\n")
  # Try to use any non-energy referendums
  non_energy <- voting_data %>%
    filter(!grepl("energy", vote_type, ignore.case = TRUE))

  if (nrow(non_energy) > 0) {
    placebo_data <- non_energy
    placebo_votes <- unique(non_energy$vote_type)
    cat(paste("Found", length(placebo_votes), "non-energy referendums\n"))
  }
}

# =============================================================================
# MERGE WITH CORRECTED BORDER DISTANCES
# =============================================================================

cat("\nMerging with corrected border distances...\n")

# Merge placebo voting data with corrected border distances
placebo_corrected <- placebo_data %>%
  inner_join(border_distances, by = "mun_id") %>%
  filter(!is.na(dist_to_own_border))

cat(paste("Placebo sample size after merge:", nrow(placebo_corrected), "\n"))

if (nrow(placebo_corrected) == 0) {
  cat("\nNo matching placebo data found. Using main energy vote for demonstration.\n")

  # Fall back to energy 2017 to verify the corrected sample works
  main_energy <- corrected_sample

  cat("\n--- Energy 2017 (Corrected Sample) ---\n")
  rdd_energy <- rdrobust(
    y = main_energy$yes_share,
    x = main_energy$signed_distance_km,
    c = 0
  )

  cat(paste("Estimate:", round(rdd_energy$coef[1], 2), "pp\n"))
  cat(paste("SE:", round(rdd_energy$se[1], 2), "\n"))
  cat(paste("p-value:", round(rdd_energy$pv[1], 3), "\n"))
  cat(paste("Bandwidth:", round(rdd_energy$bws[1], 1), "km\n"))
  cat(paste("N (left, right):", rdd_energy$N[1], ",", rdd_energy$N[2], "\n"))

} else {

  # =============================================================================
  # RUN PLACEBO RDD ON CORRECTED SAMPLE
  # =============================================================================

  cat("\nRunning placebo RDDs on corrected sample...\n")

  # Define German-speaking same-language border pairs
  german_cantons <- c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG",
                      "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG")

  placebo_results <- map_dfr(unique(placebo_corrected$vote_type), function(vt) {
    cat(paste("\nProcessing:", vt, "\n"))

    sample_vt <- placebo_corrected %>%
      filter(vote_type == vt)

    if (nrow(sample_vt) < 100) {
      return(tibble(
        referendum = vt,
        estimate = NA_real_,
        se = NA_real_,
        pvalue = NA_real_,
        n = nrow(sample_vt),
        bandwidth = NA_real_,
        sample = "corrected"
      ))
    }

    rd <- tryCatch({
      rdrobust(
        y = sample_vt$yes_share,
        x = sample_vt$signed_distance_km,
        c = 0
      )
    }, error = function(e) {
      cat(paste("  Error:", e$message, "\n"))
      NULL
    })

    if (is.null(rd)) {
      return(tibble(
        referendum = vt,
        estimate = NA_real_,
        se = NA_real_,
        pvalue = NA_real_,
        n = nrow(sample_vt),
        bandwidth = NA_real_,
        sample = "corrected"
      ))
    }

    cat(paste("  Estimate:", round(rd$coef[1], 2), "pp (p =", round(rd$pv[1], 3), ")\n"))

    tibble(
      referendum = vt,
      estimate = rd$coef[1],
      se = rd$se[1],
      pvalue = rd$pv[1],
      n = sum(rd$N),
      bandwidth = rd$bws[1],
      sample = "corrected"
    )
  })

  cat("\n", rep("=", 60), "\n")
  cat("PLACEBO RDD RESULTS (Corrected Sample)\n")
  cat(rep("=", 60), "\n\n")

  print(placebo_results)

  # Save results
  write_csv(placebo_results, file.path(tab_dir, "placebo_rdd_corrected.csv"))
  saveRDS(placebo_results, file.path(data_dir, "placebo_results_corrected.rds"))

  cat("\nResults saved.\n")
}

cat("\n", rep("=", 70), "\n")
cat("PLACEBO RDD ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n")
