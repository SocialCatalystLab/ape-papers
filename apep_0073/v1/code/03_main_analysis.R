# ==============================================================================
# APEP Paper 93: SNAP Work Requirements and Employment
# 03_main_analysis.R - Primary DiD estimation
# ==============================================================================

source("00_packages.R")

# Load data
state_year <- readRDS("../data/state_year.rds")
analysis_sample <- readRDS("../data/analysis_sample.rds")

cat("State-year data:", nrow(state_year), "observations\n")

# ------------------------------------------------------------------------------
# Callaway-Sant'Anna Estimator
# ------------------------------------------------------------------------------

cat("\n=== Callaway-Sant'Anna Estimation ===\n")

# Prepare data for CS estimator
cs_data <- state_year %>%
  mutate(
    # Group = first treatment year (0 for never treated)
    G = first_treat
  ) %>%
  arrange(state_id, year)

# Run CS estimator
cs_out <- att_gt(
  yname = "employed",
  tname = "year",
  idname = "state_id",
  gname = "G",
  data = cs_data,
  control_group = "nevertreated",
  weightsname = "pop",
  clustervars = "state_id",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

# Print summary
summary(cs_out)

# Aggregate to overall ATT
att_overall <- aggte(cs_out, type = "simple")
cat("\n=== Overall ATT ===\n")
print(att_overall)

# Aggregate to event study
att_es <- aggte(cs_out, type = "dynamic", min_e = -4, max_e = 4)
cat("\n=== Event Study ATT ===\n")
print(att_es)

# Save results
saveRDS(cs_out, "../data/cs_results.rds")
saveRDS(att_overall, "../data/att_overall.rds")
saveRDS(att_es, "../data/att_es.rds")

# ------------------------------------------------------------------------------
# Two-Way Fixed Effects (for comparison)
# ------------------------------------------------------------------------------

cat("\n=== TWFE Regression ===\n")

# Basic TWFE
twfe_basic <- feols(
  employed ~ treated | ST + year,
  data = state_year,
  weights = ~pop,
  cluster = ~ST
)

# TWFE with controls (state-specific trends)
twfe_trends <- feols(
  employed ~ treated | ST + year + ST:year,
  data = state_year,
  weights = ~pop,
  cluster = ~ST
)

# Display results
etable(twfe_basic, twfe_trends,
       headers = c("Basic TWFE", "With State Trends"),
       fitstat = ~ r2.within + n)

# Save TWFE results
saveRDS(list(basic = twfe_basic, trends = twfe_trends), "../data/twfe_results.rds")

# ------------------------------------------------------------------------------
# Labor Force Participation (Secondary Outcome)
# ------------------------------------------------------------------------------

cat("\n=== Labor Force Participation ===\n")

cs_out_lf <- att_gt(
  yname = "in_lf",
  tname = "year",
  idname = "state_id",
  gname = "G",
  data = cs_data,
  control_group = "nevertreated",
  weightsname = "pop",
  clustervars = "state_id",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

att_lf <- aggte(cs_out_lf, type = "simple")
cat("\nLabor Force Participation ATT:\n")
print(att_lf)

# ------------------------------------------------------------------------------
# SNAP Receipt (Mechanism Check)
# ------------------------------------------------------------------------------

cat("\n=== SNAP Receipt ===\n")

cs_out_snap <- att_gt(
  yname = "snap",
  tname = "year",
  idname = "state_id",
  gname = "G",
  data = cs_data,
  control_group = "nevertreated",
  weightsname = "pop",
  clustervars = "state_id",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

att_snap <- aggte(cs_out_snap, type = "simple")
cat("\nSNAP Receipt ATT:\n")
print(att_snap)

saveRDS(cs_out_snap, "../data/cs_snap.rds")

cat("\n=== Analysis Complete ===\n")
