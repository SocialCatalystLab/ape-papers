# ==============================================================================
# 03_main_analysis.R
# Main DiD Analysis: Clean Slate Laws and Employment Outcomes
# Using fixest with Sun-Abraham estimator
# ==============================================================================

source("output/paper_59/code/00_packages.R")

# Load data
panel_data <- readRDS("output/paper_59/data/panel_data.rds")

cat("========================================\n")
cat("MAIN ANALYSIS: Clean Slate Laws\n")
cat("========================================\n\n")

# ==============================================================================
# Sample Description
# ==============================================================================

cat("Sample Description:\n")
cat(sprintf("  States: %d\n", n_distinct(panel_data$state_fips)))
cat(sprintf("  Years: %d - %d\n", min(panel_data$year), max(panel_data$year)))
cat(sprintf("  Observations: %d state-years\n", nrow(panel_data)))

# Treatment summary
treat_summary <- panel_data %>%
  filter(year == 2023) %>%
  group_by(treated) %>%
  summarize(n_states = n(), .groups = "drop")

cat(sprintf("\nTreatment Status (as of 2023):\n"))
cat(sprintf("  Treated (Clean Slate adopted): %d states\n",
            treat_summary$n_states[treat_summary$treated == 1]))
cat(sprintf("  Never-treated: %d states\n",
            treat_summary$n_states[treat_summary$treated == 0]))

# Treatment timing
cat("\nTreatment Timing:\n")
panel_data %>%
  filter(treat_year > 0 & treat_year <= 2024) %>%
  distinct(state_abbr, treat_year) %>%
  arrange(treat_year) %>%
  print(n = 20)

# ==============================================================================
# Outcome Variables Summary
# ==============================================================================

cat("\n\nOutcome Variables (2019 baseline, by treatment status):\n")
panel_data %>%
  filter(year == 2019) %>%
  group_by(treated) %>%
  summarize(
    n = n(),
    emp_rate_mean = mean(emp_rate, na.rm = TRUE),
    emp_rate_sd = sd(emp_rate, na.rm = TRUE),
    lfp_rate_mean = mean(lfp_rate, na.rm = TRUE),
    lfp_rate_sd = sd(lfp_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(treated = ifelse(treated == 1, "Treated", "Control")) %>%
  print()

# ==============================================================================
# ANALYSIS 1: Traditional TWFE (Known to be biased)
# ==============================================================================

cat("\n========================================\n")
cat("TWFE ESTIMATION (for reference)\n")
cat("========================================\n\n")

# Traditional TWFE - included for comparison but note limitations
twfe_emp <- feols(
  emp_rate ~ post | state_fips + year,
  data = panel_data,
  cluster = ~state_fips
)

cat("TWFE - Employment Rate:\n")
print(summary(twfe_emp))

twfe_lfp <- feols(
  lfp_rate ~ post | state_fips + year,
  data = panel_data,
  cluster = ~state_fips
)

cat("\nTWFE - LFP Rate:\n")
print(summary(twfe_lfp))

# ==============================================================================
# ANALYSIS 2: Sun-Abraham Estimator (Heterogeneity-Robust)
# ==============================================================================

cat("\n========================================\n")
cat("SUN-ABRAHAM ESTIMATION\n")
cat("========================================\n\n")

# Sun-Abraham via fixest's sunab() function
# Handles staggered adoption and heterogeneous treatment effects

# Employment Rate
sa_emp <- feols(
  emp_rate ~ sunab(cohort, year, ref.p = -1) | state_fips + year,
  data = panel_data,
  cluster = ~state_fips
)

cat("Sun-Abraham - Employment Rate:\n")
print(summary(sa_emp))

# LFP Rate
sa_lfp <- feols(
  lfp_rate ~ sunab(cohort, year, ref.p = -1) | state_fips + year,
  data = panel_data,
  cluster = ~state_fips
)

cat("\nSun-Abraham - LFP Rate:\n")
print(summary(sa_lfp))

# Unemployment Rate
sa_unemp <- feols(
  unemp_rate ~ sunab(cohort, year, ref.p = -1) | state_fips + year,
  data = panel_data,
  cluster = ~state_fips
)

cat("\nSun-Abraham - Unemployment Rate:\n")
print(summary(sa_unemp))

# ==============================================================================
# Aggregate ATT from Sun-Abraham
# ==============================================================================

cat("\n========================================\n")
cat("AGGREGATED ATT (Post-Treatment Average)\n")
cat("========================================\n\n")

# Extract coefficients for post-treatment periods
agg_att_emp <- aggregate(sa_emp, agg = "ATT")
agg_att_lfp <- aggregate(sa_lfp, agg = "ATT")
agg_att_unemp <- aggregate(sa_unemp, agg = "ATT")

cat("Employment Rate ATT:\n")
print(agg_att_emp)

cat("\nLFP Rate ATT:\n")
print(agg_att_lfp)

cat("\nUnemployment Rate ATT:\n")
print(agg_att_unemp)

# ==============================================================================
# Event Study Coefficients
# ==============================================================================

cat("\n========================================\n")
cat("EVENT STUDY COEFFICIENTS\n")
cat("========================================\n\n")

# Extract event study coefficients
es_coefs_emp <- coeftable(sa_emp) %>%
  as.data.frame() %>%
  rownames_to_column("term") %>%
  filter(grepl("year::", term)) %>%
  mutate(
    rel_time = as.numeric(gsub("year::", "", term)),
    outcome = "Employment Rate"
  ) %>%
  rename(estimate = Estimate, se = `Std. Error`, pval = `Pr(>|t|)`)

es_coefs_lfp <- coeftable(sa_lfp) %>%
  as.data.frame() %>%
  rownames_to_column("term") %>%
  filter(grepl("year::", term)) %>%
  mutate(
    rel_time = as.numeric(gsub("year::", "", term)),
    outcome = "LFP Rate"
  ) %>%
  rename(estimate = Estimate, se = `Std. Error`, pval = `Pr(>|t|)`)

es_coefs_unemp <- coeftable(sa_unemp) %>%
  as.data.frame() %>%
  rownames_to_column("term") %>%
  filter(grepl("year::", term)) %>%
  mutate(
    rel_time = as.numeric(gsub("year::", "", term)),
    outcome = "Unemployment Rate"
  ) %>%
  rename(estimate = Estimate, se = `Std. Error`, pval = `Pr(>|t|)`)

es_coefs <- bind_rows(es_coefs_emp, es_coefs_lfp, es_coefs_unemp)

cat("Event study coefficients (Employment Rate):\n")
es_coefs %>%
  filter(outcome == "Employment Rate") %>%
  select(rel_time, estimate, se) %>%
  arrange(rel_time) %>%
  head(15) %>%
  print()

# ==============================================================================
# Pre-Trends Test
# ==============================================================================

cat("\n========================================\n")
cat("PRE-TRENDS TEST\n")
cat("========================================\n\n")

# Test if pre-treatment coefficients are jointly zero
pre_coefs_emp <- es_coefs_emp %>% filter(rel_time < 0)
pre_coefs_lfp <- es_coefs_lfp %>% filter(rel_time < 0)

if (nrow(pre_coefs_emp) > 0) {
  cat("Employment Rate - Pre-treatment coefficients:\n")
  print(pre_coefs_emp %>% select(rel_time, estimate, se, pval))

  # Check if any pre-period coefficient is significant at 5%
  sig_pre <- sum(pre_coefs_emp$pval < 0.05, na.rm = TRUE)
  cat(sprintf("\nNumber of significant (p<0.05) pre-period coefficients: %d of %d\n",
              sig_pre, nrow(pre_coefs_emp)))
}

# ==============================================================================
# Save Results
# ==============================================================================

results <- list(
  # Models
  twfe_emp = twfe_emp,
  twfe_lfp = twfe_lfp,
  sa_emp = sa_emp,
  sa_lfp = sa_lfp,
  sa_unemp = sa_unemp,
  # Aggregated ATT
  att_emp = agg_att_emp,
  att_lfp = agg_att_lfp,
  att_unemp = agg_att_unemp,
  # Event study coefficients
  es_coefs = es_coefs
)

saveRDS(results, "output/paper_59/data/main_results.rds")

# ==============================================================================
# Summary Table
# ==============================================================================

cat("\n========================================\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat("========================================\n\n")

# Extract ATT values safely
get_att <- function(agg_result) {
  if (is.null(agg_result)) return(c(NA, NA))
  cf <- coef(agg_result)
  se <- sqrt(vcov(agg_result)[1,1])
  return(c(cf, se))
}

emp_att <- get_att(agg_att_emp)
lfp_att <- get_att(agg_att_lfp)
unemp_att <- get_att(agg_att_unemp)

summary_table <- tibble(
  Outcome = c("Employment Rate", "LFP Rate", "Unemployment Rate"),
  ATT = c(emp_att[1], lfp_att[1], unemp_att[1]),
  SE = c(emp_att[2], lfp_att[2], unemp_att[2])
) %>%
  mutate(
    `95% CI Lower` = ATT - 1.96 * SE,
    `95% CI Upper` = ATT + 1.96 * SE,
    across(ATT:`95% CI Upper`, ~round(., 3)),
    Significant = ifelse(`95% CI Lower` > 0 | `95% CI Upper` < 0, "*", "")
  )

print(summary_table)

write_csv(summary_table, "output/paper_59/data/main_results_summary.csv")

cat("\n\nInterpretation:\n")
cat("- Employment Rate ATT: Effect of Clean Slate on employment-population ratio\n")
cat("- LFP Rate ATT: Effect on labor force participation rate\n")
cat("- Unemployment Rate ATT: Effect on unemployment rate\n")
cat("- Positive employment/LFP effects = Clean Slate increases labor market participation\n")
cat("- Negative unemployment effects = Clean Slate reduces unemployment\n")

cat("\n\nResults saved to output/paper_59/data/\n")
