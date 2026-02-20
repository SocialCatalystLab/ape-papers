# =============================================================================
# 04b_scm.R — Synthetic Control Method for Cross-Country Analysis
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Running Synthetic Control Method ===\n")

if (!requireNamespace("tidysynth", quietly = TRUE)) install.packages("tidysynth")
library(tidysynth)

# Load cross-country data
cross_country <- readRDS("../data/cross_country_panel.rds")

# ---------------------------------------------------------------
# Prepare data for SCM
# ---------------------------------------------------------------
cat("Preparing SCM data...\n")

# Youth employment rate panel: France + 7 controls
scm_data <- cross_country %>%
  filter(age_group == "Y15-24") %>%
  select(country, yq, emp_rate) %>%
  filter(!is.na(emp_rate)) %>%
  arrange(country, yq)

# Also get adult employment for predictors
adult_data <- cross_country %>%
  filter(age_group == "Y25-54") %>%
  select(country, yq, emp_rate) %>%
  rename(adult_emp_rate = emp_rate) %>%
  filter(!is.na(adult_emp_rate))

scm_data <- scm_data %>%
  left_join(adult_data, by = c("country", "yq"))

# Treatment period: 2023Q1 (yq = 2023.0)
# Use integer time ID for tidysynth
scm_data <- scm_data %>%
  mutate(time_id = as.integer(round((yq - min(yq)) * 4) + 1))

# Identify treatment time
treatment_time <- scm_data %>%
  filter(yq == 2023.0) %>%
  pull(time_id) %>%
  unique()

cat(sprintf("  Treatment time ID: %d (yq = 2023.0)\n", treatment_time[1]))
cat(sprintf("  Countries: %s\n", paste(sort(unique(scm_data$country)), collapse = ", ")))
cat(sprintf("  Time periods: %d\n", n_distinct(scm_data$time_id)))

# ---------------------------------------------------------------
# Run SCM with tidysynth
# ---------------------------------------------------------------
cat("Running synthetic control...\n")

scm_out <- tryCatch({
  scm_data %>%
    synthetic_control(
      outcome = emp_rate,
      unit = country,
      time = time_id,
      i_unit = "FR",
      i_time = treatment_time[1],
      generate_placebos = TRUE
    ) %>%
    generate_predictor(
      time_window = c(1, treatment_time[1] - 1),
      mean_emp = mean(emp_rate, na.rm = TRUE)
    ) %>%
    generate_predictor(
      time_window = c(treatment_time[1] - 8, treatment_time[1] - 1),
      recent_emp = mean(emp_rate, na.rm = TRUE)
    ) %>%
    generate_predictor(
      time_window = c(1, treatment_time[1] - 1),
      mean_adult = mean(adult_emp_rate, na.rm = TRUE)
    ) %>%
    generate_weights(optimization_window = c(1, treatment_time[1] - 1)) %>%
    generate_control()
}, error = function(e) {
  cat(sprintf("  SCM error: %s\n", e$message))
  NULL
})

if (!is.null(scm_out)) {
  cat("  SCM completed successfully.\n")

  # Extract weights
  scm_weights <- scm_out %>% grab_unit_weights()
  cat("  Synthetic France weights:\n")
  print(scm_weights %>% filter(weight > 0.01) %>% arrange(desc(weight)))

  # Extract synthetic vs actual
  scm_table <- scm_out %>% grab_synthetic_control()

  cat(sprintf("  SCM table columns: %s\n", paste(names(scm_table), collapse = ", ")))

  # Map time_id back to yq
  time_map <- scm_data %>%
    filter(country == "FR") %>%
    distinct(time_id, yq)

  # Find the time column in scm_table
  time_col <- intersect(names(scm_table), c("time_id", "time_unit"))
  if (length(time_col) > 0) {
    if (time_col[1] != "time_id") {
      scm_table <- scm_table %>% rename(time_id = !!time_col[1])
    }
    scm_table <- scm_table %>%
      left_join(time_map, by = "time_id")
  } else {
    # If no time column matches, use row order
    cat("  WARNING: No matching time column, using row index.\n")
    fr_yq <- scm_data %>% filter(country == "FR") %>% arrange(time_id) %>% pull(yq)
    scm_table$yq <- fr_yq[1:nrow(scm_table)]
    scm_table$time_id <- 1:nrow(scm_table)
  }

  # Compute pre-treatment RMSPE
  pre_rmspe <- scm_table %>%
    filter(time_id < treatment_time[1]) %>%
    summarize(rmspe = sqrt(mean((real_y - synth_y)^2, na.rm = TRUE))) %>%
    pull(rmspe)
  cat(sprintf("  Pre-treatment RMSPE: %.4f\n", pre_rmspe))

  # Post-treatment gap
  post_gap <- scm_table %>%
    filter(time_id >= treatment_time[1]) %>%
    summarize(mean_gap = mean(real_y - synth_y, na.rm = TRUE)) %>%
    pull(mean_gap)
  cat(sprintf("  Post-treatment mean gap (France - Synthetic): %.4f pp\n", post_gap))

  # ---------------------------------------------------------------
  # Placebo tests: in-space (each control as pseudo-treated)
  # ---------------------------------------------------------------
  cat("  Computing placebo MSPE ratios...\n")

  placebo_mspe <- tryCatch(
    scm_out %>% grab_significance(),
    error = function(e) {
      cat(sprintf("  grab_significance failed: %s\n", e$message))
      # Try alternative spelling
      tryCatch(scm_out %>% grab_signficance(),
               error = function(e2) NULL)
    }
  )
  cat("  Placebo significance:\n")
  print(placebo_mspe)

  if (!is.null(placebo_mspe)) {
    # MSPE ratio for France
    fr_mspe <- placebo_mspe %>% filter(unit_name == "FR")
    if (nrow(fr_mspe) > 0) {
      cat(sprintf("  France MSPE ratio rank: %d / %d\n",
                  fr_mspe$rank[1], nrow(placebo_mspe)))
      cat(sprintf("  Fisher exact p-value: %.3f\n", fr_mspe$fishers_exact_pvalue[1]))
    }
  } else {
    cat("  Placebo MSPE ratios not available.\n")
    placebo_mspe <- tibble(unit_name = "FR", fishers_exact_pvalue = NA_real_)
  }

  # Save all results
  saveRDS(list(
    scm_out = scm_out,
    scm_table = scm_table,
    weights = scm_weights,
    pre_rmspe = pre_rmspe,
    post_gap = post_gap,
    placebo_mspe = placebo_mspe,
    treatment_time = treatment_time[1],
    time_map = time_map
  ), "../data/scm_results.rds")

} else {
  cat("  WARNING: SCM failed. Saving NULL placeholder.\n")
  saveRDS(NULL, "../data/scm_results.rds")
}

cat("\n=== SCM analysis complete ===\n")
