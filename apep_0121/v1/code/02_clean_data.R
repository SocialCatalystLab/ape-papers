# ==============================================================================
# 02_clean_data.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Load the merged analysis panel from 01_fetch_data.R, construct
#          outcome and treatment variables, add transforms, save final panel
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================================\n")
cat("  02_clean_data.R: Building analysis panel\n")
cat("========================================================\n\n")

# ==============================================================================
# SECTION 1: Read the pre-merged analysis panel
# ==============================================================================

cat("--- Reading analysis_panel.csv ---\n\n")

panel <- read.csv(file.path(DATA_DIR, "analysis_panel.csv"),
                  stringsAsFactors = FALSE)
cat("  analysis_panel.csv:", nrow(panel), "rows x", ncol(panel), "cols\n")
cat("  Columns:", paste(names(panel), collapse = ", "), "\n\n")

# ==============================================================================
# SECTION 2: Standardize FIPS codes
# ==============================================================================

cat("--- Standardizing identifiers ---\n")

panel$state_fips <- as.integer(panel$state_fips)

# Drop Puerto Rico (FIPS 72) — separate MW structure, not in our MW panel
panel <- panel %>% filter(state_fips != 72)
cat("  Dropped Puerto Rico (FIPS 72)\n")

cat("  Years:", paste(range(panel$year), collapse = "-"), "\n")
cat("  States:", length(unique(panel$state_fips)), "\n")

# ==============================================================================
# SECTION 3: Construct outcome variables (percentages)
# ==============================================================================

cat("\n--- Constructing outcome variables ---\n")

panel <- panel %>%
  mutate(
    # Primary outcome: percentage living with parents
    pct_with_parents = share_with_parents * 100,

    # Alternative outcome: percentage living independently
    pct_independent = share_independent * 100,

    # Sub-component: percentage living alone
    pct_alone = share_alone * 100,

    # Sub-component: percentage with spouse
    pct_with_spouse = (ya_with_spouse / ya_total) * 100,

    # Sub-component: percentage with partner
    pct_with_partner = (ya_with_partner / ya_total) * 100,

    # Residual: other arrangements
    pct_other = (ya_other / ya_total) * 100
  )

cat("  Outcome variables constructed:\n")
cat("    pct_with_parents:  mean =", round(mean(panel$pct_with_parents, na.rm = TRUE), 2), "\n")
cat("    pct_independent:   mean =", round(mean(panel$pct_independent, na.rm = TRUE), 2), "\n")
cat("    pct_alone:         mean =", round(mean(panel$pct_alone, na.rm = TRUE), 2), "\n")
cat("    pct_with_spouse:   mean =", round(mean(panel$pct_with_spouse, na.rm = TRUE), 2), "\n")
cat("    pct_with_partner:  mean =", round(mean(panel$pct_with_partner, na.rm = TRUE), 2), "\n")

# ==============================================================================
# SECTION 4: Verify treatment variables
# ==============================================================================

cat("\n--- Verifying treatment variables ---\n")

# first_treat and treated_yr already come from 01_fetch_data.R
# Rename treated_yr -> treated for consistency
panel <- panel %>%
  mutate(
    treated = as.integer(treated_yr),
    first_treat = as.integer(ifelse(is.na(first_treat), 0L, first_treat))
  )

n_treated_states <- length(unique(panel$state_fips[panel$first_treat > 0]))
n_nevertreated   <- length(unique(panel$state_fips[panel$first_treat == 0]))
n_total_states   <- length(unique(panel$state_fips))

cat("  Treated states (ever):     ", n_treated_states, "\n")
cat("  Never-treated states:      ", n_nevertreated, "\n")
cat("  Total states:              ", n_total_states, "\n")

# Treatment cohort distribution
cohorts <- panel %>%
  filter(first_treat > 0) %>%
  select(state_fips, state_abbr, first_treat) %>%
  distinct() %>%
  arrange(first_treat)

cat("\n  Treatment cohort distribution:\n")
cohort_tab <- table(cohorts$first_treat)
for (i in seq_along(cohort_tab)) {
  yr   <- names(cohort_tab)[i]
  n    <- cohort_tab[i]
  abbrs <- cohorts %>%
    filter(first_treat == as.integer(yr)) %>%
    pull(state_abbr) %>%
    paste(collapse = ", ")
  cat(sprintf("    %s: %2d states (%s)\n", yr, n, abbrs))
}

# ==============================================================================
# SECTION 5: Create additional variables
# ==============================================================================

cat("\n--- Creating log transforms and additional variables ---\n")

# Rename controls for downstream scripts (handle idempotent re-runs)
if ("total_pop" %in% names(panel))  panel <- panel %>% rename(population = total_pop)
if ("unemp_rate" %in% names(panel)) panel <- panel %>% rename(unemployment_rate = unemp_rate)

panel <- panel %>%
  mutate(
    # Log transforms for controls
    log_population = log(population),
    log_rent       = log(pmax(median_rent, 1)),

    # Relative time to treatment (for event study convenience)
    rel_time = ifelse(first_treat > 0, year - first_treat, NA_integer_),

    # Post-treatment indicator
    post = as.integer(year >= first_treat & first_treat > 0),

    # Treatment intensity: MW gap (continuous)
    mw_gap_continuous = pmax(effective_mw - federal_mw, 0),

    # Census region (for heterogeneity analysis)
    region = case_when(
      state_fips %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50)       ~ "Northeast",
      state_fips %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55) ~ "Midwest",
      state_fips %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28,
                         37, 40, 45, 47, 48, 51, 54)               ~ "South",
      state_fips %in% c(2, 4, 6, 8, 15, 16, 30, 32, 35, 41, 49,
                         53, 56)                                    ~ "West",
      TRUE                                                          ~ "Other"
    )
  )

cat("  log_population: non-missing =", sum(!is.na(panel$log_population)), "\n")
cat("  log_rent:       non-missing =", sum(!is.na(panel$log_rent)), "\n")
cat("  Region distribution:\n")
region_tab <- panel %>%
  select(state_fips, region) %>%
  distinct() %>%
  count(region)
for (i in seq_len(nrow(region_tab))) {
  cat(sprintf("    %-12s: %d states\n", region_tab$region[i], region_tab$n[i]))
}

# ==============================================================================
# SECTION 6: Data quality checks
# ==============================================================================

cat("\n--- Running data quality checks ---\n")

# Check for missing values in key variables
key_vars <- c("year", "state_fips", "pct_with_parents", "pct_independent",
              "first_treat", "treated", "unemployment_rate", "log_rent")
for (v in key_vars) {
  n_miss <- sum(is.na(panel[[v]]))
  if (n_miss > 0) {
    cat("  WARNING:", v, "has", n_miss, "missing values\n")
  }
}

# Check outcome variable ranges
stopifnot(all(panel$pct_with_parents >= 0 & panel$pct_with_parents <= 100, na.rm = TRUE))
stopifnot(all(panel$pct_independent  >= 0 & panel$pct_independent  <= 100, na.rm = TRUE))
cat("  Outcome ranges OK (all within [0, 100])\n")

# Check panel balance
obs_per_state <- panel %>% count(state_fips)
if (length(unique(obs_per_state$n)) == 1) {
  cat("  Panel is balanced:", unique(obs_per_state$n), "years per state\n")
} else {
  cat("  WARNING: Panel is unbalanced. Obs per state range:",
      min(obs_per_state$n), "-", max(obs_per_state$n), "\n")
}

# ==============================================================================
# SECTION 7: Save analysis panel
# ==============================================================================

cat("\n--- Saving analysis panel ---\n")

# Overwrite the analysis_panel.csv with the fully cleaned version
write.csv(panel, file.path(DATA_DIR, "analysis_panel.csv"), row.names = FALSE)
cat("  Saved:", file.path(DATA_DIR, "analysis_panel.csv"), "\n")
cat("  Dimensions:", nrow(panel), "rows x", ncol(panel), "cols\n")

# Also save as RDS for faster loading
saveRDS(panel, file.path(DATA_DIR, "analysis_panel.rds"))
cat("  Saved:", file.path(DATA_DIR, "analysis_panel.rds"), "\n")

# ==============================================================================
# SECTION 8: Summary statistics
# ==============================================================================

cat("\n========================================================\n")
cat("  SUMMARY STATISTICS\n")
cat("========================================================\n\n")

cat("--- Full panel ---\n")
cat(sprintf("  N observations:    %d\n", nrow(panel)))
cat(sprintf("  N states:          %d\n", n_total_states))
cat(sprintf("  N years:           %d (%d-%d)\n",
            length(unique(panel$year)), min(panel$year), max(panel$year)))
cat(sprintf("  Treated states:    %d\n", n_treated_states))
cat(sprintf("  Never-treated:     %d\n", n_nevertreated))

# Outcome variables
cat("\n--- Outcome variables ---\n")
outcome_vars <- c("pct_with_parents", "pct_independent", "pct_alone",
                  "pct_with_spouse", "pct_with_partner")
cat(sprintf("  %-20s %8s %8s %8s %8s\n", "Variable", "Mean", "SD", "Min", "Max"))
cat(paste(rep("-", 58), collapse = ""), "\n")
for (v in outcome_vars) {
  x <- panel[[v]]
  cat(sprintf("  %-20s %8.2f %8.2f %8.2f %8.2f\n",
              v, mean(x, na.rm = TRUE), sd(x, na.rm = TRUE),
              min(x, na.rm = TRUE), max(x, na.rm = TRUE)))
}

# Treatment variables
cat("\n--- Treatment variables ---\n")
treat_vars <- c("treated", "mw_gap", "state_mw", "federal_mw", "effective_mw")
cat(sprintf("  %-20s %8s %8s %8s %8s\n", "Variable", "Mean", "SD", "Min", "Max"))
cat(paste(rep("-", 58), collapse = ""), "\n")
for (v in treat_vars) {
  x <- panel[[v]]
  cat(sprintf("  %-20s %8.2f %8.2f %8.2f %8.2f\n",
              v, mean(x, na.rm = TRUE), sd(x, na.rm = TRUE),
              min(x, na.rm = TRUE), max(x, na.rm = TRUE)))
}

# Control variables
cat("\n--- Control variables ---\n")
ctrl_vars <- c("unemployment_rate", "population", "median_rent",
               "log_population", "log_rent")
cat(sprintf("  %-20s %8s %8s %8s %8s\n", "Variable", "Mean", "SD", "Min", "Max"))
cat(paste(rep("-", 58), collapse = ""), "\n")
for (v in ctrl_vars) {
  x <- panel[[v]]
  cat(sprintf("  %-20s %8.2f %8.2f %8.2f %8.2f\n",
              v, mean(x, na.rm = TRUE), sd(x, na.rm = TRUE),
              min(x, na.rm = TRUE), max(x, na.rm = TRUE)))
}

# Treated vs control comparison
cat("\n--- Treated vs. Never-Treated Comparison (pre-treatment means) ---\n")
pre_means <- panel %>%
  filter(year < first_treat | first_treat == 0) %>%
  group_by(ever_treated = first_treat > 0) %>%
  summarise(
    pct_with_parents = mean(pct_with_parents, na.rm = TRUE),
    pct_independent  = mean(pct_independent, na.rm = TRUE),
    unemployment     = mean(unemployment_rate, na.rm = TRUE),
    median_rent      = mean(median_rent, na.rm = TRUE),
    .groups = "drop"
  )

cat(sprintf("  %-20s %12s %12s\n", "", "Never-Treated", "Treated"))
cat(paste(rep("-", 48), collapse = ""), "\n")
for (v in c("pct_with_parents", "pct_independent", "unemployment", "median_rent")) {
  val_nt <- pre_means[[v]][pre_means$ever_treated == FALSE]
  val_tr <- pre_means[[v]][pre_means$ever_treated == TRUE]
  cat(sprintf("  %-20s %12.2f %12.2f\n", v, val_nt, val_tr))
}

cat("\n========================================================\n")
cat("  02_clean_data.R completed successfully.\n")
cat("========================================================\n")
