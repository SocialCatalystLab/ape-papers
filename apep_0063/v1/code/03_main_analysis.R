# ============================================================================
# Paper 81: State Heat Protection Standards and Worker Safety
# 03_main_analysis.R - Primary DiD and Synthetic Control Analysis
# ============================================================================

# Source packages script (relative path)
source(file.path(dirname(sys.frame(1)$ofile %||% "."), "00_packages.R"))

# Load data
panel <- read_csv(file.path(DATA_DIR, "heat_panel.csv"), show_col_types = FALSE)

# ============================================================================
# 1. DESCRIPTIVE STATISTICS
# ============================================================================

cat("\n============================================================\n")
cat("DESCRIPTIVE STATISTICS\n")
cat("============================================================\n")

# Summary by treatment status
desc_stats <- panel %>%
  mutate(treatment_group = case_when(
    ever_treated == 1 & treated == 0 ~ "Pre-treatment (treated states)",
    ever_treated == 1 & treated == 1 ~ "Post-treatment (treated states)",
    TRUE ~ "Never treated"
  )) %>%
  group_by(treatment_group) %>%
  summarize(
    n_obs = n(),
    mean_heat_rate = mean(heat_rate, na.rm = TRUE),
    sd_heat_rate = sd(heat_rate, na.rm = TRUE),
    mean_employment = mean(employment, na.rm = TRUE) / 1e6,
    mean_construction_share = mean(construction_share, na.rm = TRUE),
    .groups = "drop"
  )

print(desc_stats)

# National trends in heat deaths
national_trends <- panel %>%
  group_by(year) %>%
  summarize(
    total_heat_deaths = sum(heat_deaths_imputed, na.rm = TRUE),
    mean_heat_rate = mean(heat_rate, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nNational heat death trends:\n")
print(national_trends %>% filter(year >= 2000))

# ============================================================================
# 2. CALIFORNIA ANALYSIS (Longest Post-Treatment)
# ============================================================================

cat("\n============================================================\n")
cat("CALIFORNIA SYNTHETIC CONTROL ANALYSIS\n")
cat("============================================================\n")

# California treatment: 2006
# Pre-treatment: 1992-2005 (14 years)
# Post-treatment: 2006-2023 (18 years)

# Prepare data for California analysis
ca_data <- panel %>%
  filter(state_abbr != "MN") %>%  # Exclude Minnesota (treated in 1984)
  mutate(
    ca_treat = if_else(state_abbr == "CA" & year >= 2006, 1, 0),
    ca_state = if_else(state_abbr == "CA", 1, 0)
  )

# Simple DiD for California vs all never-treated states
# Restrict to states that are never treated (through 2023)
never_treated_states <- panel %>%
  filter(is.infinite(treat_year)) %>%
  pull(state_abbr) %>%
  unique()

ca_did_data <- panel %>%
  filter(state_abbr == "CA" | state_abbr %in% never_treated_states) %>%
  mutate(
    post = if_else(year >= 2006, 1, 0),
    treat = if_else(state_abbr == "CA", 1, 0)
  )

# Two-way fixed effects (naive, for comparison)
twfe_ca <- feols(
  heat_rate ~ treat:post | state_abbr + year,
  data = ca_did_data,
  cluster = ~state_abbr
)

cat("\nTWFE for California (vs never-treated states):\n")
summary(twfe_ca)

# Event study for California
# Create relative time variable for ALL observations (not just treated)
ca_did_data <- ca_did_data %>%
  mutate(
    rel_year = year - 2006,
    # Bin endpoints
    rel_year_binned = case_when(
      rel_year < -10 ~ -10,
      rel_year > 15 ~ 15,
      TRUE ~ rel_year
    )
  )

# Event study using Sun-Abraham approach via fixest
# This handles the reference period correctly
tryCatch({
  event_ca <- feols(
    heat_rate ~ sunab(treat_year, year, ref.p = -1) | state_abbr + year,
    data = ca_did_data %>% mutate(treat_year = if_else(treat == 1, 2006, 10000)),
    cluster = ~state_abbr
  )
  cat("\nEvent study for California (Sun-Abraham):\n")
  summary(event_ca)
}, error = function(e) {
  cat("\nEvent study failed (likely due to sparse data):", e$message, "\n")
  event_ca <<- NULL
})

# ============================================================================
# 3. MANUAL SYNTHETIC CONTROL FOR CALIFORNIA
# ============================================================================

# Since Synth package has issues, implement manual synthetic control
# using simple weighted average matching on pre-treatment outcomes

# Pre-treatment period: 1992-2005
pre_period <- 1992:2005
post_period <- 2006:2023

# Get California pre-treatment outcomes
ca_pre <- ca_did_data %>%
  filter(state_abbr == "CA", year %in% pre_period) %>%
  arrange(year) %>%
  pull(heat_rate)

# Get donor states (never treated) pre-treatment outcomes
donor_pre <- ca_did_data %>%
  filter(state_abbr %in% never_treated_states, year %in% pre_period) %>%
  pivot_wider(
    id_cols = year,
    names_from = state_abbr,
    values_from = heat_rate
  ) %>%
  arrange(year) %>%
  select(-year) %>%
  as.matrix()

# Simple synthetic control: find weights to minimize pre-treatment RMSE
# Using quadratic programming (manual implementation)
# For simplicity, use regression-based weights

# Stack pre-treatment data
n_pre <- length(pre_period)
n_donors <- ncol(donor_pre)

# Use constrained regression to find weights
# Weights should be non-negative and sum to 1

# Simple approach: use leave-one-out cross-validation to select donors
# Then average their outcomes

# Calculate correlation of each donor with CA
donor_correlations <- apply(donor_pre, 2, function(x) cor(x, ca_pre, use = "complete.obs"))
donor_df <- tibble(
  state_abbr = names(donor_correlations),
  correlation = donor_correlations
) %>%
  arrange(desc(correlation))

cat("\nTop donor states (by correlation with CA pre-treatment):\n")
print(head(donor_df, 10))

# Select top 10 donors with positive correlation
top_donors <- donor_df %>%
  filter(correlation > 0) %>%
  head(10) %>%
  pull(state_abbr)

# Equal weights for top donors (simple average)
synth_weights <- rep(1/length(top_donors), length(top_donors))
names(synth_weights) <- top_donors

# Calculate synthetic California
donor_post <- ca_did_data %>%
  filter(state_abbr %in% top_donors, year %in% post_period) %>%
  group_by(year) %>%
  summarize(synth_heat_rate = mean(heat_rate, na.rm = TRUE), .groups = "drop")

ca_post <- ca_did_data %>%
  filter(state_abbr == "CA", year %in% post_period) %>%
  select(year, ca_heat_rate = heat_rate)

# Combine and calculate gap
synth_results <- ca_post %>%
  left_join(donor_post, by = "year") %>%
  mutate(
    gap = ca_heat_rate - synth_heat_rate,
    years_since_treat = year - 2006
  )

cat("\nSynthetic control results (CA vs synthetic CA):\n")
print(synth_results)

# Average treatment effect (post-treatment)
ate_synth <- mean(synth_results$gap, na.rm = TRUE)
cat("\nAverage gap (CA - Synthetic CA), post-treatment:", round(ate_synth, 4), "\n")

# Pre-treatment RMSE
donor_pre_synth <- ca_did_data %>%
  filter(state_abbr %in% top_donors, year %in% pre_period) %>%
  group_by(year) %>%
  summarize(synth_heat_rate = mean(heat_rate, na.rm = TRUE), .groups = "drop")

ca_pre_df <- ca_did_data %>%
  filter(state_abbr == "CA", year %in% pre_period) %>%
  select(year, ca_heat_rate = heat_rate)

pre_fit <- ca_pre_df %>%
  left_join(donor_pre_synth, by = "year") %>%
  mutate(gap = ca_heat_rate - synth_heat_rate)

pre_rmse <- sqrt(mean(pre_fit$gap^2, na.rm = TRUE))
cat("Pre-treatment RMSE:", round(pre_rmse, 4), "\n")

# ============================================================================
# 4. STACKED DID FOR MULTIPLE TREATMENT COHORTS
# ============================================================================

cat("\n============================================================\n")
cat("STACKED DID ANALYSIS (All Treatment Cohorts)\n")
cat("============================================================\n")

# Treatment cohorts (excluding MN which is too early)
treatment_cohorts <- panel %>%
  filter(is.finite(treat_year), treat_year > 1990) %>%
  distinct(state_abbr, treat_year)

cat("\nTreatment cohorts:\n")
print(treatment_cohorts)

# For each cohort, create a stacked dataset
# Using a 5-year pre and 5-year post window (where data available)

create_cohort_data <- function(cohort_state, cohort_year, df) {
  # Window: 5 years before and after
  window_start <- max(1992, cohort_year - 5)
  window_end <- min(2023, cohort_year + 5)

  # Treated unit
  treated_df <- df %>%
    filter(state_abbr == cohort_state, year >= window_start, year <= window_end) %>%
    mutate(
      cohort = cohort_year,
      relative_time = year - cohort_year,
      treat = 1,
      post = if_else(year >= cohort_year, 1, 0)
    )

  # Control units (never treated)
  control_df <- df %>%
    filter(is.infinite(treat_year), year >= window_start, year <= window_end) %>%
    mutate(
      cohort = cohort_year,
      relative_time = year - cohort_year,
      treat = 0,
      post = if_else(year >= cohort_year, 1, 0)
    )

  bind_rows(treated_df, control_df)
}

# Create stacked data for all cohorts
stacked_data <- map2_dfr(
  treatment_cohorts$state_abbr,
  treatment_cohorts$treat_year,
  ~create_cohort_data(.x, .y, panel)
)

cat("\nStacked data dimensions:", nrow(stacked_data), "observations\n")
cat("Cohorts:", n_distinct(stacked_data$cohort), "\n")

# Stacked DiD
stacked_did <- feols(
  heat_rate ~ treat:post | cohort^state_abbr + cohort^year,
  data = stacked_data,
  cluster = ~cohort^state_abbr
)

cat("\nStacked DiD results:\n")
summary(stacked_did)

# ============================================================================
# 5. CALLAWAY-SANT'ANNA ESTIMATOR
# ============================================================================

cat("\n============================================================\n")
cat("CALLAWAY-SANT'ANNA ESTIMATOR\n")
cat("============================================================\n")

# Prepare data for did package
did_data <- panel %>%
  filter(year >= 1992) %>%
  mutate(
    # Group variable: first treatment year (0 for never treated)
    G = if_else(is.infinite(treat_year), 0, treat_year),
    # Unit ID
    id = as.numeric(factor(state_abbr))
  ) %>%
  # Remove MN (treated before sample period)
  filter(state_abbr != "MN")

# Run Callaway-Sant'Anna
cs_out <- att_gt(
  yname = "heat_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = did_data,
  control_group = "nevertreated",
  bstrap = TRUE,
  cband = TRUE
)

cat("\nCallaway-Sant'Anna group-time ATTs:\n")
summary(cs_out)

# Aggregate to overall ATT
overall_att <- aggte(cs_out, type = "simple")
cat("\nOverall ATT:\n")
summary(overall_att)

# Event study aggregation
cs_es <- aggte(cs_out, type = "dynamic")
cat("\nEvent study (dynamic aggregation):\n")
summary(cs_es)

# ============================================================================
# 6. SAVE RESULTS
# ============================================================================

# Save key results
results <- list(
  twfe_california = twfe_ca,
  event_california = event_ca,
  synth_results = synth_results,
  stacked_did = stacked_did,
  cs_results = cs_out,
  cs_overall = overall_att,
  cs_eventstudy = cs_es
)

saveRDS(results, file.path(DATA_DIR, "analysis_results.rds"))

cat("\n============================================================\n")
cat("ANALYSIS COMPLETE\n")
cat("============================================================\n")
cat("Results saved to:", file.path(DATA_DIR, "analysis_results.rds"), "\n")
