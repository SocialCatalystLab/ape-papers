# ==============================================================================
# 03_main_analysis.R - Main DiD Analysis
# Paper 60: State Auto-IRA Mandates and Retirement Savings
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# Load Data
# ==============================================================================

cps_private <- readRDS("data/cps_private.rds")
auto_ira_dates <- readRDS("data/auto_ira_policy_dates.rds")

cat("Loaded", nrow(cps_private), "private sector observations\n")

# ==============================================================================
# 1. TWFE Baseline (for comparison)
# ==============================================================================

cat("\n=== TWFE Baseline Specification ===\n")

# Simple TWFE
twfe_simple <- feols(
  has_pension_at_job ~ treated |
    statefip + year,
  data = cps_private,
  weights = ~weight,
  cluster = ~statefip
)

# TWFE with controls
twfe_controls <- feols(
  has_pension_at_job ~ treated + age + I(age^2) + female + married +
    educ_hs + educ_some_college + educ_ba_plus |
    statefip + year,
  data = cps_private,
  weights = ~weight,
  cluster = ~statefip
)

cat("TWFE Results (for comparison - subject to heterogeneity bias):\n")
etable(twfe_simple, twfe_controls,
       se.below = TRUE,
       fitstat = c("n", "r2"))

# ==============================================================================
# 2. Callaway-Sant'Anna Estimator (Main Specification)
# ==============================================================================

cat("\n=== Callaway-Sant'Anna Group-Time ATTs ===\n")

# Aggregate to state-year level for did package
# (did package is designed for panel data at the unit level)
state_year <- cps_private %>%
  filter(!is.na(has_pension_at_job), !is.na(weight)) %>%
  group_by(statefip, year, first_treat, auto_ira_state) %>%
  summarise(
    has_pension = weighted.mean(has_pension_at_job, weight, na.rm = TRUE),
    pension_participant = weighted.mean(pension_participant, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight),
    # Controls (use weight from same obs)
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_married = weighted.mean(married, weight, na.rm = TRUE),
    pct_ba_plus = weighted.mean(educ_ba_plus, weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    # Create unique unit ID
    id = statefip
  )

cat("State-year panel:", nrow(state_year), "observations\n")
cat("Unique states:", n_distinct(state_year$statefip), "\n")
cat("Years:", paste(sort(unique(state_year$year)), collapse = ", "), "\n")

# Callaway-Sant'Anna: No covariates
cs_out <- att_gt(
  yname = "has_pension",
  tname = "year",
  idname = "id",
  gname = "first_treat",
  data = state_year,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",  # Doubly robust
  base_period = "universal"  # Use last pre-treatment period
)

cat("\nGroup-Time ATTs:\n")
summary(cs_out)

# ==============================================================================
# 3. Aggregate Effects
# ==============================================================================

cat("\n=== Aggregated Effects ===\n")

# Overall ATT
att_overall <- aggte(cs_out, type = "simple")
cat("\nOverall ATT:\n")
summary(att_overall)

# Group-specific ATTs (by adoption cohort)
att_group <- aggte(cs_out, type = "group")
cat("\nATT by Treatment Cohort:\n")
summary(att_group)

# Dynamic effects (event study)
att_dynamic <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)
cat("\nDynamic Effects (Event Study):\n")
summary(att_dynamic)

# ==============================================================================
# 4. Event Study Plot
# ==============================================================================

cat("\n=== Creating Event Study Plot ===\n")

es_data <- data.frame(
  time = att_dynamic$egt,
  att = att_dynamic$att.egt,
  se = att_dynamic$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

p_event_study <- ggplot(es_data, aes(x = time, y = att)) +
  # Confidence interval ribbon
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  # Labels
  labs(
    title = "Event Study: Effect of Auto-IRA Mandates on Retirement Plan Coverage",
    subtitle = "Callaway-Sant'Anna estimator with never-treated control group",
    x = "Years Relative to Policy Adoption",
    y = "ATT (Percentage Points)",
    caption = "Note: Reference period is t = -1. Shaded region shows 95% CI.\nSample: Private sector workers ages 25-64."
  ) +
  scale_x_continuous(breaks = seq(-5, 5, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  theme_apep()

ggsave("figures/event_study_main.pdf", p_event_study, width = 9, height = 5.5)
cat("Event study plot saved to figures/event_study_main.pdf\n")

# ==============================================================================
# 5. Sun-Abraham Estimator (Robustness)
# ==============================================================================

cat("\n=== Sun-Abraham Estimator ===\n")

# Need individual-level data for sunab
# Create relative time variable
cps_private <- cps_private %>%
  mutate(
    rel_time = ifelse(first_treat > 0, year - first_treat, NA),
    rel_time_binned = case_when(
      is.na(rel_time) ~ NA_real_,
      rel_time < -5 ~ -5,
      rel_time > 5 ~ 5,
      TRUE ~ rel_time
    )
  )

# Sun-Abraham with fixest
sa_out <- feols(
  has_pension_at_job ~ sunab(first_treat, year) |
    statefip + year,
  data = cps_private %>% filter(first_treat > 0 | auto_ira_state == 0),
  weights = ~weight,
  cluster = ~statefip
)

cat("Sun-Abraham Results:\n")
summary(sa_out)

# ==============================================================================
# 6. Save Results
# ==============================================================================

results <- list(
  twfe_simple = twfe_simple,
  twfe_controls = twfe_controls,
  cs_out = cs_out,
  att_overall = att_overall,
  att_group = att_group,
  att_dynamic = att_dynamic,
  sa_out = sa_out,
  es_data = es_data
)

saveRDS(results, "data/main_results.rds")
cat("\nResults saved to data/main_results.rds\n")

# ==============================================================================
# 7. Summary Table
# ==============================================================================

cat("\n=== MAIN RESULTS SUMMARY ===\n")
cat("Overall ATT (C-S):", round(att_overall$overall.att, 4),
    "SE:", round(att_overall$overall.se, 4), "\n")
cat("TWFE (simple):", round(coef(twfe_simple)["treated"], 4), "\n")
cat("TWFE (controls):", round(coef(twfe_controls)["treated"], 4), "\n")

# Pre-trends test
pre_coeffs <- es_data %>% filter(time < 0)
cat("\nPre-trend coefficients (should be ~0):\n")
print(pre_coeffs)

cat("\nMain analysis complete.\n")
