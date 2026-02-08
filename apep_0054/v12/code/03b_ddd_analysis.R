# =============================================================================
# 03b_ddd_analysis.R
# Triple-Difference (DDD) Design: Exploiting Firm-Size Phase-In
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Motivation
# -----------------------------------------------------------------------------

# Auto-IRA mandates phase in by firm size, typically starting with large
# employers (100+) and extending to smaller employers over time. Workers at
# SMALL firms (who lack existing employer plans) should be most affected.
#
# DDD Design:
# - First difference: Treated vs control states
# - Second difference: Pre vs post treatment
# - Third difference: Small firms (<100) vs large firms (100+)
#
# The β3 coefficient on TreatedState × Post × SmallFirm isolates the effect
# on workers at targeted small firms, differencing out:
# - State-specific shocks (via state FE)
# - Time shocks (via year FE)
# - Differential trends by firm size (via SmallFirm × Year FE)
# - State-specific firm size differences (via State × SmallFirm FE)

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cat("Loading cleaned data...\n")
df <- readRDS(file.path(data_dir, "cps_asec_clean.rds"))

# Keep only observations with valid firm size
df_ddd <- df %>%
  filter(!is.na(small_firm))

cat("Observations with valid firm size:", nrow(df_ddd), "\n")
cat("Small firm share:", round(mean(df_ddd$small_firm), 3), "\n")

# -----------------------------------------------------------------------------
# Collapse to State-Year-FirmSize Level
# -----------------------------------------------------------------------------

cat("\nCollapsing to state-year-firmsize cells...\n")

df_cells <- df_ddd %>%
  group_by(statefip, year, first_treat, small_firm) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_college = weighted.mean(college, weight, na.rm = TRUE),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    n_obs = n(),
    sum_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.numeric(factor(statefip)),
    first_treat = replace_na(first_treat, 0),
    treated_state = ifelse(first_treat > 0, 1, 0),
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0),
    # Interaction terms
    treat_post = treated_state * post,
    treat_small = treated_state * small_firm,
    post_small = post * small_firm,
    treat_post_small = treated_state * post * small_firm,
    # Cell ID for clustering
    cell_id = paste(statefip, small_firm, sep = "_")
  )

cat("State-year-firmsize cells:", nrow(df_cells), "\n")

# Summary statistics by cell type
cat("\nCoverage rates by group:\n")
df_cells %>%
  group_by(treated_state, post, small_firm) %>%
  summarise(
    n_cells = n(),
    mean_coverage = weighted.mean(pension_rate, sum_weight),
    .groups = "drop"
  ) %>%
  mutate(
    group = case_when(
      treated_state == 0 ~ "Control",
      post == 0 ~ "Treated (Pre)",
      TRUE ~ "Treated (Post)"
    ),
    firm_type = ifelse(small_firm == 1, "Small (<100)", "Large (100+)")
  ) %>%
  select(group, firm_type, mean_coverage) %>%
  pivot_wider(names_from = firm_type, values_from = mean_coverage) %>%
  print()

# -----------------------------------------------------------------------------
# DDD Regression: Basic Specification
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("TRIPLE-DIFFERENCE (DDD) ANALYSIS\n")
cat(rep("=", 60), "\n\n")

# Basic DDD with all interactions
ddd_basic <- feols(
  pension_rate ~ treat_post + treat_small + post_small + treat_post_small |
    state_id + year,
  data = df_cells,
  weights = ~sum_weight,
  cluster = ~statefip
)

cat("Basic DDD (State + Year FE):\n")
print(summary(ddd_basic))

# -----------------------------------------------------------------------------
# DDD with Richer Fixed Effects
# -----------------------------------------------------------------------------

cat("\n--- DDD with State × Firm Size and Year × Firm Size FE ---\n\n")

# Create state × firm size FE
df_cells <- df_cells %>%
  mutate(
    state_firmsize = paste(statefip, small_firm, sep = "_"),
    year_firmsize = paste(year, small_firm, sep = "_")
  )

ddd_full <- feols(
  pension_rate ~ treat_post_small |
    state_firmsize + year_firmsize,
  data = df_cells,
  weights = ~sum_weight,
  cluster = ~statefip
)

cat("Full DDD (State×FirmSize + Year×FirmSize FE):\n")
print(summary(ddd_full))

# Save main DDD coefficient
ddd_coef <- coef(ddd_full)["treat_post_small"]
ddd_se <- se(ddd_full)["treat_post_small"]

cat("\n*** KEY DDD RESULT ***\n")
cat("Effect on small firm workers in treated states post-mandate:\n")
cat("  Coefficient:", round(ddd_coef, 4), " (", round(ddd_coef * 100, 2), " pp)\n")
cat("  SE:", round(ddd_se, 4), "\n")
cat("  t-stat:", round(ddd_coef / ddd_se, 3), "\n")
cat("  95% CI: [", round(ddd_coef - 1.96 * ddd_se, 4), ",",
    round(ddd_coef + 1.96 * ddd_se, 4), "]\n")

# -----------------------------------------------------------------------------
# Wild Bootstrap for DDD
# -----------------------------------------------------------------------------

cat("\n--- Wild Bootstrap Inference for DDD ---\n\n")

boot_ddd <- boottest(
  ddd_full,
  param = "treat_post_small",
  clustid = "statefip",
  B = 9999,
  type = "webb",
  impose_null = TRUE
)

cat("Wild Bootstrap Results for DDD:\n")
print(boot_ddd)

boot_ddd_pval <- boot_ddd$p_val
boot_ddd_ci <- confint(boot_ddd)

cat("\nDDD Wild Bootstrap Summary:\n")
cat("  Point estimate:", round(ddd_coef, 4), "\n")
cat("  Wild bootstrap p-value:", round(boot_ddd_pval, 4), "\n")
cat("  Wild bootstrap 95% CI: [", round(boot_ddd_ci[1], 4), ",",
    round(boot_ddd_ci[2], 4), "]\n")

# -----------------------------------------------------------------------------
# DDD Event Study
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("DDD EVENT STUDY\n")
cat(rep("=", 60), "\n\n")

# Create event time
df_cells <- df_cells %>%
  mutate(
    event_time = ifelse(first_treat > 0, year - first_treat, NA_integer_)
  )

# Create event time × small firm interactions
# Reference period: event_time = -1
event_times <- sort(unique(df_cells$event_time[!is.na(df_cells$event_time)]))
event_times <- event_times[event_times != -1]  # Exclude reference

# Create dummies for each event time × small firm
for (e in event_times) {
  var_name <- paste0("et", ifelse(e < 0, "m", "p"), abs(e), "_small")
  df_cells[[var_name]] <- ifelse(df_cells$event_time == e & df_cells$small_firm == 1, 1, 0)
  df_cells[[var_name]][is.na(df_cells[[var_name]])] <- 0
}

# Construct formula
event_vars <- paste0("et", ifelse(event_times < 0, "m", "p"), abs(event_times), "_small")
event_formula <- as.formula(paste("pension_rate ~", paste(event_vars, collapse = " + "),
                                   "| state_firmsize + year_firmsize"))

ddd_event <- feols(
  event_formula,
  data = df_cells,
  weights = ~sum_weight,
  cluster = ~statefip
)

cat("DDD Event Study Results:\n")
print(summary(ddd_event))

# Extract coefficients
ddd_es_coefs <- tibble(
  event_time = event_times,
  var_name = event_vars
) %>%
  mutate(
    att = map_dbl(var_name, ~coef(ddd_event)[.x]),
    se = map_dbl(var_name, ~se(ddd_event)[.x]),
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  ) %>%
  # Add reference period
  bind_rows(tibble(event_time = -1, var_name = "reference",
                   att = 0, se = 0, ci_lower = 0, ci_upper = 0)) %>%
  arrange(event_time)

# Save results
write_csv(ddd_es_coefs, file.path(data_dir, "ddd_event_study_coefs.csv"))

cat("\nDDD Event Study Coefficients:\n")
print(ddd_es_coefs)

# -----------------------------------------------------------------------------
# Compare Small vs Large Firm Effects
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SEPARATE EFFECTS BY FIRM SIZE\n")
cat(rep("=", 60), "\n\n")

# Small firms only
df_small <- df_cells %>% filter(small_firm == 1)
did_small <- feols(
  pension_rate ~ post | state_id + year,
  data = df_small %>% filter(first_treat > 0 | TRUE),  # All states
  weights = ~sum_weight,
  cluster = ~statefip
)

# Large firms only
df_large <- df_cells %>% filter(small_firm == 0)
did_large <- feols(
  pension_rate ~ post | state_id + year,
  data = df_large %>% filter(first_treat > 0 | TRUE),
  weights = ~sum_weight,
  cluster = ~statefip
)

cat("Effect on Small Firms Only:\n")
cat("  Coefficient:", round(coef(did_small)["post"], 4), "\n")
cat("  SE:", round(se(did_small)["post"], 4), "\n\n")

cat("Effect on Large Firms Only:\n")
cat("  Coefficient:", round(coef(did_large)["post"], 4), "\n")
cat("  SE:", round(se(did_large)["post"], 4), "\n\n")

cat("Difference (DDD coefficient):", round(ddd_coef, 4), "\n")

# -----------------------------------------------------------------------------
# Save Results
# -----------------------------------------------------------------------------

# Summary table
ddd_summary <- tibble(
  Specification = c(
    "Basic DDD (State + Year FE)",
    "Full DDD (State×FirmSize + Year×FirmSize FE)",
    "Small Firms Only DiD",
    "Large Firms Only DiD"
  ),
  Coefficient = c(
    coef(ddd_basic)["treat_post_small"],
    ddd_coef,
    coef(did_small)["post"],
    coef(did_large)["post"]
  ),
  SE = c(
    se(ddd_basic)["treat_post_small"],
    ddd_se,
    se(did_small)["post"],
    se(did_large)["post"]
  )
) %>%
  mutate(
    t_stat = Coefficient / SE,
    CI_Lower = Coefficient - 1.96 * SE,
    CI_Upper = Coefficient + 1.96 * SE,
    Significant = ifelse(CI_Lower > 0 | CI_Upper < 0, "*", "")
  )

print(ddd_summary)
write_csv(ddd_summary, file.path(data_dir, "ddd_summary.csv"))

# Save regression objects
saveRDS(ddd_basic, file.path(data_dir, "ddd_basic.rds"))
saveRDS(ddd_full, file.path(data_dir, "ddd_full.rds"))
saveRDS(ddd_event, file.path(data_dir, "ddd_event.rds"))
saveRDS(boot_ddd, file.path(data_dir, "ddd_wild_bootstrap.rds"))

cat("\n", rep("=", 60), "\n")
cat("DDD ANALYSIS COMPLETE\n")
cat(rep("=", 60), "\n")
cat("\nResults saved to:", data_dir, "\n")
cat("Next: Run 04_robustness.R\n")
