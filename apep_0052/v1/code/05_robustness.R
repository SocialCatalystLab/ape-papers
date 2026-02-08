# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# 05_robustness.R - Robustness Checks and Sensitivity Analysis
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# 1. LOAD DATA
# ==============================================================================
cat("=== Loading Data for Robustness ===\n")

analysis <- arrow::read_parquet("data/analysis_panel.parquet")
load("data/cs_results.RData")  # Main CS results

# Prepare did data
did_data <- analysis %>%
  mutate(
    gname = ifelse(treated, treat_year, 0),
    id = as.numeric(factor(st_fips))
  )

# ==============================================================================
# 2. ALTERNATIVE THRESHOLDS (65%, 75%)
# ==============================================================================
cat("\n=== Alternative Treatment Thresholds ===\n")

run_cs_threshold <- function(data, threshold, outcome = "individualizing") {
  # Create treatment timing for this threshold
  treat_timing <- data %>%
    filter(broadband_rate >= threshold) %>%
    group_by(st_fips) %>%
    summarise(treat_year_alt = min(year), .groups = "drop")

  df <- data %>%
    left_join(treat_timing, by = "st_fips") %>%
    mutate(
      gname_alt = ifelse(!is.na(treat_year_alt), treat_year_alt, 0),
      id = as.numeric(factor(st_fips))
    )

  # Run CS
  cs <- att_gt(
    yname = outcome,
    tname = "year",
    idname = "id",
    gname = "gname_alt",
    data = df,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    clustervars = "state_fips",
    bstrap = TRUE,
    biters = 500,
    print_details = FALSE
  )

  att <- aggte(cs, type = "simple", na.rm = TRUE)
  return(list(att = att$overall.att, se = att$overall.se, n_treated = nrow(treat_timing)))
}

# Run for different thresholds
thresholds <- c(0.65, 0.70, 0.75)
threshold_results <- list()

for (thresh in thresholds) {
  cat(sprintf("  Threshold: %.0f%%\n", thresh * 100))

  for (outcome in c("individualizing", "binding", "log_univ_comm")) {
    res <- run_cs_threshold(analysis, thresh, outcome)
    threshold_results[[paste0(thresh * 100, "_", outcome)]] <- res
    cat(sprintf("    %s: ATT = %.4f (SE = %.4f), N_treated = %d\n",
                outcome, res$att, res$se, res$n_treated))
  }
}

# Create comparison table
threshold_table <- expand_grid(
  threshold = thresholds,
  outcome = c("individualizing", "binding", "log_univ_comm")
) %>%
  mutate(
    key = paste0(threshold * 100, "_", outcome),
    att = map_dbl(key, ~threshold_results[[.x]]$att),
    se = map_dbl(key, ~threshold_results[[.x]]$se),
    n_treated = map_dbl(key, ~threshold_results[[.x]]$n_treated)
  ) %>%
  select(-key)

write_csv(threshold_table, "tables/robustness_thresholds.csv")

# ==============================================================================
# 3. CONTINUOUS TREATMENT (TWFE)
# ==============================================================================
cat("\n=== Continuous Treatment TWFE ===\n")

# Standard TWFE with continuous broadband rate
twfe_continuous <- feols(
  c(individualizing, binding, log_univ_comm) ~ broadband_rate | place_id + year,
  data = analysis,
  cluster = ~state_fips
)

cat("\n  Continuous Treatment Results:\n")
etable(twfe_continuous,
       headers = c("Individualizing", "Binding", "Log Univ/Comm"),
       fitstat = ~ r2 + n)

# ==============================================================================
# 4. SUN-ABRAHAM ESTIMATOR (via fixest)
# ==============================================================================
cat("\n=== Sun-Abraham Estimator ===\n")

# Need to create proper event-time dummies
analysis_sa <- analysis %>%
  filter(treated) %>%
  mutate(
    # Cohort for Sun-Abraham
    cohort_sa = treat_year
  )

# Sun-Abraham via sunab()
sa_individual <- feols(
  individualizing ~ sunab(cohort_sa, year) | place_id + year,
  data = analysis_sa,
  cluster = ~state_fips
)

sa_binding <- feols(
  binding ~ sunab(cohort_sa, year) | place_id + year,
  data = analysis_sa,
  cluster = ~state_fips
)

cat("\n  Sun-Abraham Results (treated sample only):\n")
etable(sa_individual, sa_binding,
       headers = c("Individualizing", "Binding"))

# ==============================================================================
# 5. DROPPING SPECIFIC COHORTS
# ==============================================================================
cat("\n=== Dropping Specific Cohorts ===\n")

# Drop each cohort one at a time
cohorts <- sort(unique(did_data$gname[did_data$gname > 0]))

drop_cohort_results <- list()

for (cohort in cohorts[1:min(5, length(cohorts))]) {  # First 5 cohorts
  df_drop <- did_data %>%
    filter(gname != cohort)

  cs_drop <- att_gt(
    yname = "individualizing",
    tname = "year",
    idname = "id",
    gname = "gname",
    data = df_drop,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    clustervars = "state_fips",
    bstrap = TRUE,
    biters = 200,
    print_details = FALSE
  )

  att_drop <- aggte(cs_drop, type = "simple", na.rm = TRUE)
  drop_cohort_results[[as.character(cohort)]] <- c(att_drop$overall.att, att_drop$overall.se)

  cat(sprintf("  Drop cohort %d: ATT = %.4f (SE = %.4f)\n",
              cohort, att_drop$overall.att, att_drop$overall.se))
}

# ==============================================================================
# 6. PLACEBO OUTCOMES
# ==============================================================================
cat("\n=== Placebo Outcomes ===\n")

# Test: Meeting length (should not be affected by broadband)
# This requires meeting-level data with word counts

placebo_words <- att_gt(
  yname = "n_total_words",  # Total words (proxy for meeting length)
  tname = "year",
  idname = "id",
  gname = "gname",
  data = did_data,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  clustervars = "state_fips",
  bstrap = TRUE,
  biters = 500,
  print_details = FALSE
)

att_placebo <- aggte(placebo_words, type = "simple", na.rm = TRUE)
cat(sprintf("\n  Placebo (Total Words): ATT = %.2f (SE = %.2f), p = %.3f\n",
            att_placebo$overall.att, att_placebo$overall.se,
            2 * (1 - pnorm(abs(att_placebo$overall.att / att_placebo$overall.se)))))

# ==============================================================================
# 7. MATCHING/IPW ESTIMATOR
# ==============================================================================
cat("\n=== Matching/IPW Robustness ===\n")

# Use DRDID for doubly-robust DiD with propensity score matching
library(DRDID)

# Prepare data for DRDID (simpler 2x2 setting)
# Define pre/post periods
pre_year <- 2014
post_year <- 2019

drdid_data <- analysis %>%
  filter(year %in% c(pre_year, post_year)) %>%
  arrange(st_fips, year) %>%
  group_by(st_fips) %>%
  filter(n() == 2) %>%  # Keep only balanced
  ungroup() %>%
  mutate(
    post = as.numeric(year == post_year),
    treat = as.numeric(treat_year <= post_year & treat_year > pre_year)
  )

# Check we have variation
cat(sprintf("\n  DRDID sample: %d place-periods, %d treated\n",
            nrow(drdid_data), sum(drdid_data$treat & drdid_data$post)))

if (sum(drdid_data$treat) > 10) {
  # Run DRDID
  drdid_result <- drdid(
    yname = "individualizing",
    tname = "post",
    idname = "st_fips",
    dname = "treat",
    xformla = ~ log(population + 1) + pct_college + pct_white + median_age,
    data = drdid_data,
    panel = TRUE
  )

  cat(sprintf("\n  DRDID Estimate: %.4f (SE: %.4f)\n",
              drdid_result$ATT, drdid_result$se))
}

# ==============================================================================
# 8. HETEROGENEITY BY BASELINE CHARACTERISTICS
# ==============================================================================
cat("\n=== Heterogeneity Analysis ===\n")

# By population size
analysis <- analysis %>%
  mutate(
    pop_tercile = ntile(population, 3),
    pop_group = case_when(
      pop_tercile == 1 ~ "Small (<10k)",
      pop_tercile == 2 ~ "Medium (10-50k)",
      pop_tercile == 3 ~ "Large (>50k)"
    )
  )

het_results <- list()

for (group in unique(na.omit(analysis$pop_group))) {
  cat(sprintf("  Population group: %s\n", group))

  df_sub <- analysis %>%
    filter(pop_group == group) %>%
    mutate(
      gname = ifelse(treated, treat_year, 0),
      id = as.numeric(factor(st_fips))
    )

  if (n_distinct(df_sub$gname) > 1) {
    cs_sub <- att_gt(
      yname = "individualizing",
      tname = "year",
      idname = "id",
      gname = "gname",
      data = df_sub,
      control_group = "nevertreated",
      anticipation = 0,
      est_method = "dr",
      bstrap = TRUE,
      biters = 200,
      print_details = FALSE
    )

    att_sub <- aggte(cs_sub, type = "simple", na.rm = TRUE)
    het_results[[group]] <- c(att_sub$overall.att, att_sub$overall.se)
    cat(sprintf("    ATT = %.4f (SE = %.4f)\n", att_sub$overall.att, att_sub$overall.se))
  }
}

# ==============================================================================
# 9. SAVE ROBUSTNESS RESULTS
# ==============================================================================
cat("\n=== Saving Robustness Results ===\n")

# Compile all robustness checks
robustness_summary <- bind_rows(
  # Thresholds
  threshold_table %>%
    filter(outcome == "individualizing") %>%
    mutate(check = paste0("Threshold ", threshold * 100, "%")) %>%
    select(check, att, se),

  # Placebo
  tibble(check = "Placebo (Total Words)",
         att = att_placebo$overall.att,
         se = att_placebo$overall.se),

  # Heterogeneity
  tibble(
    check = paste0("Pop: ", names(het_results)),
    att = map_dbl(het_results, ~.x[1]),
    se = map_dbl(het_results, ~.x[2])
  )
)

write_csv(robustness_summary, "tables/robustness_summary.csv")

# LaTeX tables
etable(twfe_continuous,
       tex = TRUE,
       file = "tables/twfe_continuous.tex",
       title = "Continuous Treatment TWFE Results",
       label = "tab:twfe_continuous")

save(threshold_results, drop_cohort_results, het_results,
     file = "data/robustness_results.RData")

cat("\n=== Robustness Checks Complete ===\n")
