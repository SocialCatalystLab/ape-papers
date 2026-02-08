# =============================================================================
# 03_main_analysis.R
# Main DiD analysis: Minimum Wage Effects on Elderly Employment
# Paper 102: Minimum Wage and Elderly Worker Employment
# =============================================================================

source("output/paper_102/code/00_packages.R")

# Load data
state_year <- read_csv(file.path(data_dir, "state_year_panel.csv"), show_col_types = FALSE)

# =============================================================================
# Part 1: Descriptive Event Study (TWFE)
# =============================================================================

message("Running TWFE event study...")

# Restrict to balanced panel with sufficient pre/post
df_balanced <- state_year %>%
  filter(year >= 2010, year <= 2022) %>%
  # Create event time indicators
  mutate(
    # Bin endpoints
    rel_time_binned = case_when(
      is.na(rel_time) ~ NA_real_,
      rel_time < -5 ~ -5,
      rel_time > 5 ~ 5,
      TRUE ~ rel_time
    ),
    # Factor for regression (omit -1)
    event_time = factor(rel_time_binned)
  )

# TWFE Event Study: Low-wage elderly employment
twfe_es <- feols(
  emp_rate_lowwage ~ i(rel_time_binned, ref = -1) | state + year,
  data = df_balanced %>% filter(!is.na(rel_time_binned)),
  cluster = ~state
)

# Summary
summary(twfe_es)

# =============================================================================
# Part 2: Callaway-Sant'Anna Estimator
# =============================================================================

message("Running Callaway-Sant'Anna DiD...")

# Prepare data for did package
df_cs <- state_year %>%
  filter(year >= 2010, year <= 2022) %>%
  # Required: id, year, outcome, group (first treat year, 0 for never treated)
  mutate(
    id = state,
    G = group  # first_treat_year or 0
  ) %>%
  # Remove missing outcomes
  filter(!is.na(emp_rate_lowwage))

# Callaway-Sant'Anna estimation
cs_out <- att_gt(
  yname = "emp_rate_lowwage",
  tname = "year",
  idname = "id",
  gname = "G",
  data = df_cs,
  control_group = "nevertreated",
  est_method = "dr",  # Doubly robust
  print_details = FALSE,
  base_period = "universal"  # Compare to period before any treatment
)

# Summary
summary(cs_out)

# Aggregate to event study
cs_es <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)
summary(cs_es)

# Aggregate to simple ATT
cs_att <- aggte(cs_out, type = "simple")
summary(cs_att)

# =============================================================================
# Part 3: Main TWFE Regression (for robustness)
# =============================================================================

message("Running TWFE regressions...")

# Model 1: Basic TWFE
m1 <- feols(
  emp_rate_lowwage ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

# Model 2: Continuous treatment (log MW)
m2 <- feols(
  emp_rate_lowwage ~ log_eff_mw | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

# Model 3: All 65+ (not just low-wage)
m3 <- feols(
  emp_rate_all ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

# Model 4: Low-education 65+ (alternative exposure definition)
m4 <- feols(
  emp_rate_lowedu ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

# Print results
etable(m1, m2, m3, m4,
       headers = c("Low-Wage 65+", "Log(MW)", "All 65+", "Low-Edu 65+"),
       fitstat = ~ r2 + n)

# =============================================================================
# Part 4: Save results
# =============================================================================

# Save C&S results
cs_results <- data.frame(
  type = c("Simple ATT", rep("Event Study", length(cs_es$egt))),
  time = c(NA, cs_es$egt),
  att = c(cs_att$overall.att, cs_es$att.egt),
  se = c(cs_att$overall.se, cs_es$se.egt),
  ci_lower = c(cs_att$overall.att - 1.96 * cs_att$overall.se,
               cs_es$att.egt - 1.96 * cs_es$se.egt),
  ci_upper = c(cs_att$overall.att + 1.96 * cs_att$overall.se,
               cs_es$att.egt + 1.96 * cs_es$se.egt)
)

write_csv(cs_results, file.path(data_dir, "cs_results.csv"))

# Save TWFE coefficients
twfe_results <- data.frame(
  model = c("Post (Low-Wage)", "Log(MW) (Low-Wage)",
            "Post (All 65+)", "Post (Low-Edu)"),
  coef = c(coef(m1)["post"], coef(m2)["log_eff_mw"],
           coef(m3)["post"], coef(m4)["post"]),
  se = c(se(m1)["post"], se(m2)["log_eff_mw"],
         se(m3)["post"], se(m4)["post"])
)

write_csv(twfe_results, file.path(data_dir, "twfe_results.csv"))

# =============================================================================
# Part 5: Summary
# =============================================================================

message("\n=== Main Results Summary ===")
message("\nCallaway-Sant'Anna ATT:")
message(sprintf("  ATT = %.4f (SE = %.4f)", cs_att$overall.att, cs_att$overall.se))
message(sprintf("  95%% CI: [%.4f, %.4f]",
                cs_att$overall.att - 1.96 * cs_att$overall.se,
                cs_att$overall.att + 1.96 * cs_att$overall.se))

message("\nTWFE Results:")
message(sprintf("  Post coefficient: %.4f (SE = %.4f)", coef(m1)["post"], se(m1)["post"]))

message("\nMain analysis complete.")
