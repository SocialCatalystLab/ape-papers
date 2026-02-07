# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 03_descriptive.R - Summary statistics and descriptive patterns
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================\n")
cat("  03_descriptive.R\n")
cat("========================================\n\n")

# ==============================================================================
# 1. LOAD DATA
# ==============================================================================
cat("=== Loading Analysis Panel ===\n")

df <- arrow::read_parquet("data/analysis_panel.parquet")
cat(sprintf("  Rows: %s\n", format(nrow(df), big.mark = ",")))
cat(sprintf("  Places: %s\n", format(n_distinct(df$place_id), big.mark = ",")))
cat(sprintf("  States: %d\n", n_distinct(df$state_fips)))
cat(sprintf("  Years: %d - %d\n", min(df$year), max(df$year)))
cat(sprintf("  Treated places: %d\n", n_distinct(df$place_id[df$treated])))
cat(sprintf("  Never-treated places: %d\n", n_distinct(df$place_id[!df$treated])))

# Ensure output directories exist
dir.create("tables", showWarnings = FALSE, recursive = TRUE)
dir.create("data", showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# 2. SUMMARY STATISTICS TABLE
#    Comparing treated vs never-treated places
# ==============================================================================
cat("\n=== Summary Statistics Table ===\n")

summary_vars <- c("individualizing", "binding", "universalism_index",
                   "moral_intensity", "broadband_rate", "population",
                   "median_income", "pct_college", "pct_white",
                   "median_age", "n_meetings", "rep_share")

# Identify which variables actually exist in the data
available_vars <- summary_vars[summary_vars %in% names(df)]
missing_vars <- setdiff(summary_vars, available_vars)
if (length(missing_vars) > 0) {
  cat(sprintf("  WARNING: Variables not found in data: %s\n",
              paste(missing_vars, collapse = ", ")))
}

# Function to compute summary stats for one variable
compute_summary <- function(data, varname) {
  x_all <- data[[varname]]
  x_treated <- data[[varname]][data$treated]
  x_control <- data[[varname]][!data$treated]

  n_all <- sum(!is.na(x_all))
  n_treated <- sum(!is.na(x_treated))
  n_control <- sum(!is.na(x_control))

  mean_all <- mean(x_all, na.rm = TRUE)
  mean_treated <- mean(x_treated, na.rm = TRUE)
  mean_control <- mean(x_control, na.rm = TRUE)

  # Difference and SE of difference (allowing unequal variances)
  diff_val <- mean_treated - mean_control
  se_diff <- tryCatch({
    tt <- t.test(x_treated, x_control, var.equal = FALSE)
    tt$stderr
  }, error = function(e) NA_real_)

  tibble(
    Variable = varname,
    N = n_all,
    Mean_All = mean_all,
    SD_All = sd(x_all, na.rm = TRUE),
    Mean_Treated = mean_treated,
    Mean_NeverTreated = mean_control,
    Diff = diff_val,
    SE_Diff = se_diff,
    p_value = tryCatch({
      t.test(x_treated, x_control, var.equal = FALSE)$p.value
    }, error = function(e) NA_real_)
  )
}

summary_stats <- map_dfr(available_vars, ~compute_summary(df, .x))

cat("\n  Summary Statistics:\n")
print(summary_stats, width = Inf)

write_csv(summary_stats, "tables/summary_stats.csv")
cat("  Saved: tables/summary_stats.csv\n")

# ==============================================================================
# 3. TREATMENT TIMING DISTRIBUTION
# ==============================================================================
cat("\n=== Treatment Timing Distribution ===\n")

timing_dist <- df %>%
  filter(treated) %>%
  distinct(place_id, treat_year) %>%
  count(treat_year, name = "n_places") %>%
  arrange(treat_year) %>%
  mutate(
    pct = n_places / sum(n_places) * 100,
    cum_pct = cumsum(pct)
  )

cat("\n  Treatment cohort distribution:\n")
print(timing_dist, n = Inf)

# Add a total row
timing_with_total <- bind_rows(

  timing_dist,
  tibble(
    treat_year = NA_real_,
    n_places = sum(timing_dist$n_places),
    pct = 100,
    cum_pct = 100
  )
)

write_csv(timing_with_total, "tables/treatment_timing.csv")
cat("  Saved: tables/treatment_timing.csv\n")

# Also report never-treated count
n_never <- n_distinct(df$place_id[!df$treated])
cat(sprintf("\n  Never-treated places: %d\n", n_never))
cat(sprintf("  Total places: %d\n", n_distinct(df$place_id)))

# ==============================================================================
# 4. BALANCE TABLE: PRE-TREATMENT CHARACTERISTICS
#    Treated vs Never-Treated, using normalized differences
# ==============================================================================
cat("\n=== Pre-Treatment Balance Table ===\n")

# Use the earliest available year for each place as "pre-treatment" baseline,
# or restrict to pre-treatment periods for treated places
pre_treatment <- df %>%
  filter(
    # For treated places: years before treatment
    (treated & year < treat_year) |
    # For never-treated: all years
    (!treated)
  )

cat(sprintf("  Pre-treatment observations: %s\n",
            format(nrow(pre_treatment), big.mark = ",")))

# Collapse to place-level means (average over pre-treatment years)
place_means <- pre_treatment %>%
  group_by(place_id, treated) %>%
  summarise(
    across(all_of(available_vars), ~mean(., na.rm = TRUE)),
    n_years = n(),
    .groups = "drop"
  )

# Compute normalized differences (Imbens & Rubin 2015)
# ND = (mean_T - mean_C) / sqrt((var_T + var_C) / 2)
compute_balance <- function(data, varname) {
  x_treated <- data[[varname]][data$treated]
  x_control <- data[[varname]][!data$treated]

  mean_t <- mean(x_treated, na.rm = TRUE)
  mean_c <- mean(x_control, na.rm = TRUE)
  var_t <- var(x_treated, na.rm = TRUE)
  var_c <- var(x_control, na.rm = TRUE)

  # Normalized difference
  norm_diff <- (mean_t - mean_c) / sqrt((var_t + var_c) / 2)

  # Also compute standard t-test for reference
  tt <- tryCatch(
    t.test(x_treated, x_control, var.equal = FALSE),
    error = function(e) list(p.value = NA_real_, stderr = NA_real_)
  )

  tibble(
    Variable = varname,
    N_Treated = sum(!is.na(x_treated)),
    N_Control = sum(!is.na(x_control)),
    Mean_Treated = mean_t,
    SD_Treated = sd(x_treated, na.rm = TRUE),
    Mean_Control = mean_c,
    SD_Control = sd(x_control, na.rm = TRUE),
    Diff = mean_t - mean_c,
    Norm_Diff = norm_diff,
    SE_Diff = tt$stderr,
    p_value = tt$p.value,
    Balanced = abs(norm_diff) < 0.25  # Standard threshold
  )
}

balance_table <- map_dfr(available_vars, ~compute_balance(place_means, .x))

cat("\n  Balance Table (Pre-Treatment, Normalized Differences):\n")
balance_table %>%
  select(Variable, Mean_Treated, Mean_Control, Norm_Diff, p_value, Balanced) %>%
  mutate(
    Mean_Treated = round(Mean_Treated, 4),
    Mean_Control = round(Mean_Control, 4),
    Norm_Diff = round(Norm_Diff, 3),
    p_value = round(p_value, 3)
  ) %>%
  print(n = Inf)

# Flag imbalanced variables
imbalanced <- balance_table %>% filter(!Balanced)
if (nrow(imbalanced) > 0) {
  cat(sprintf("\n  WARNING: %d variables with |normalized diff| > 0.25:\n",
              nrow(imbalanced)))
  cat(paste("    -", imbalanced$Variable, sprintf("(ND = %.3f)", imbalanced$Norm_Diff),
            collapse = "\n"), "\n")
} else {
  cat("\n  All variables balanced (|normalized diff| < 0.25)\n")
}

write_csv(balance_table, "tables/balance_table.csv")
cat("  Saved: tables/balance_table.csv\n")

# ==============================================================================
# 5. DESCRIPTIVE TRENDS BY TREATMENT STATUS
#    Annual means for figures
# ==============================================================================
cat("\n=== Descriptive Trends ===\n")

# Core outcomes and covariates to track over time
trend_vars <- intersect(

  c("individualizing", "binding", "universalism_index", "log_univ_comm",
    "moral_intensity", "broadband_rate", "care_p", "fairness_p",
    "loyalty_p", "authority_p", "sanctity_p", "n_meetings"),
  names(df)
)

trends <- df %>%
  group_by(year, treated) %>%
  summarise(
    n_places = n_distinct(place_id),
    n_obs = n(),
    across(all_of(trend_vars),
           list(mean = ~mean(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE),
                median = ~median(., na.rm = TRUE),
                q25 = ~quantile(., 0.25, na.rm = TRUE),
                q75 = ~quantile(., 0.75, na.rm = TRUE)),
           .names = "{.col}_{.fn}"),
    .groups = "drop"
  ) %>%
  mutate(
    group = ifelse(treated, "Treated", "Never-Treated")
  )

cat(sprintf("  Computed trends for %d variables across %d year-group cells\n",
            length(trend_vars), nrow(trends)))

write_csv(trends, "data/descriptive_trends.csv")
cat("  Saved: data/descriptive_trends.csv\n")

# Print key outcome trends
cat("\n  Mean Individualizing by Year and Treatment Status:\n")
trends %>%
  select(year, group, n_places, individualizing_mean) %>%
  pivot_wider(
    names_from = group,
    values_from = c(n_places, individualizing_mean),
    names_sep = "_"
  ) %>%
  print(n = Inf)

cat("\n  Mean Binding by Year and Treatment Status:\n")
trends %>%
  select(year, group, binding_mean) %>%
  pivot_wider(names_from = group, values_from = binding_mean) %>%
  print(n = Inf)

# ==============================================================================
# 6. ADDITIONAL DESCRIPTIVES
# ==============================================================================
cat("\n=== Additional Descriptive Patterns ===\n")

# 6a. Outcome distributions
cat("\n  Outcome distribution summary:\n")
df %>%
  summarise(
    across(
      c(individualizing, binding),
      list(
        min = ~min(., na.rm = TRUE),
        p10 = ~quantile(., 0.10, na.rm = TRUE),
        mean = ~mean(., na.rm = TRUE),
        median = ~median(., na.rm = TRUE),
        p90 = ~quantile(., 0.90, na.rm = TRUE),
        max = ~max(., na.rm = TRUE)
      ),
      .names = "{.col}_{.fn}"
    )
  ) %>%
  pivot_longer(everything(), names_to = "stat", values_to = "value") %>%
  print(n = Inf)

# 6b. Panel structure summary
cat("\n  Panel structure:\n")
panel_structure <- df %>%
  group_by(place_id) %>%
  summarise(
    n_years = n(),
    year_min = min(year),
    year_max = max(year),
    treated = first(treated),
    .groups = "drop"
  )

cat(sprintf("  Mean years per place: %.1f\n", mean(panel_structure$n_years)))
cat(sprintf("  Median years per place: %.0f\n", median(panel_structure$n_years)))
cat(sprintf("  Places with full panel: %d\n",
            sum(panel_structure$n_years == max(panel_structure$n_years))))

# 6c. Geographic coverage
cat("\n  Geographic coverage:\n")
state_coverage <- df %>%
  group_by(state_fips) %>%
  summarise(
    n_places = n_distinct(place_id),
    n_treated = n_distinct(place_id[treated]),
    pct_treated = n_treated / n_places * 100,
    .groups = "drop"
  ) %>%
  arrange(desc(n_places))

cat(sprintf("  States: %d\n", nrow(state_coverage)))
cat(sprintf("  States with treated places: %d\n", sum(state_coverage$n_treated > 0)))
cat(sprintf("  Mean places per state: %.1f\n", mean(state_coverage$n_places)))

# 6d. Treatment intensity (broadband rate at threshold crossing)
if ("treat_year" %in% names(df)) {
  treat_intensity <- df %>%
    filter(treated, year == treat_year) %>%
    summarise(
      mean_bb = mean(broadband_rate, na.rm = TRUE),
      sd_bb = sd(broadband_rate, na.rm = TRUE),
      min_bb = min(broadband_rate, na.rm = TRUE),
      max_bb = max(broadband_rate, na.rm = TRUE)
    )

  cat(sprintf("\n  Broadband rate at threshold crossing:\n"))
  cat(sprintf("    Mean: %.3f (SD: %.3f)\n", treat_intensity$mean_bb, treat_intensity$sd_bb))
  cat(sprintf("    Range: [%.3f, %.3f]\n", treat_intensity$min_bb, treat_intensity$max_bb))
}

# ==============================================================================
# 7. SAVE R DATA FOR DOWNSTREAM SCRIPTS
# ==============================================================================

# Save summary objects for table/figure scripts
descriptive_results <- list(
  summary_stats = summary_stats,
  timing_dist = timing_dist,
  balance_table = balance_table,
  trends = trends,
  state_coverage = state_coverage,
  panel_structure = panel_structure
)

save(descriptive_results, file = "data/descriptive_results.RData")
cat("\n  Saved: data/descriptive_results.RData\n")

cat("\n========================================\n")
cat("  03_descriptive.R COMPLETE\n")
cat("========================================\n")
