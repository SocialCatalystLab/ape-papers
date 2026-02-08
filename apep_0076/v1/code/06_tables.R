# ============================================================================
# Paper 105: State EITC Generosity and Property Crime
# Script: 06_tables.R - Publication-Ready Tables
# ============================================================================

source("00_packages.R")

# Load modelsummary for publication tables
if (!require("modelsummary", quietly = TRUE)) {
  install.packages("modelsummary", repos = "https://cloud.r-project.org")
  library(modelsummary)
} else {
  library(modelsummary)
}

cat("Generating tables for Paper 105...\n\n")

# Load data
analysis_data <- read_csv(file.path(DATA_DIR, "analysis_eitc_crime.csv"), show_col_types = FALSE)
eitc_policy <- read_csv(file.path(DATA_DIR, "eitc_policy.csv"), show_col_types = FALSE)

# ============================================================================
# TABLE 1: Summary Statistics
# ============================================================================

cat("Creating Table 1: Summary Statistics...\n")

# Overall summary statistics
summary_stats <- analysis_data %>%
  summarise(
    `Property Crime Rate` = sprintf("%.1f (%.1f)", mean(property_rate), sd(property_rate)),
    `Burglary Rate` = sprintf("%.1f (%.1f)", mean(burglary_rate), sd(burglary_rate)),
    `Larceny Rate` = sprintf("%.1f (%.1f)", mean(larceny_rate), sd(larceny_rate)),
    `Motor Vehicle Theft Rate` = sprintf("%.1f (%.1f)", mean(mvt_rate), sd(mvt_rate)),
    `Violent Crime Rate` = sprintf("%.1f (%.1f)", mean(violent_rate), sd(violent_rate)),
    `EITC Generosity (%)` = sprintf("%.1f (%.1f)", mean(eitc_generosity), sd(eitc_generosity)),
    `Has State EITC` = sprintf("%.2f (%.2f)", mean(treated), sd(treated)),
    `Population (millions)` = sprintf("%.2f (%.2f)", mean(population)/1e6, sd(population)/1e6),
    N = as.character(n())
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Mean (SD)")

# By treatment status
by_treatment <- analysis_data %>%
  group_by(treated) %>%
  summarise(
    `Property Crime Rate` = sprintf("%.1f (%.1f)", mean(property_rate), sd(property_rate)),
    `Violent Crime Rate` = sprintf("%.1f (%.1f)", mean(violent_rate), sd(violent_rate)),
    `Population (millions)` = sprintf("%.2f (%.2f)", mean(population)/1e6, sd(population)/1e6),
    N = as.character(n()),
    .groups = "drop"
  )

write_csv(summary_stats, file.path(TAB_DIR, "summary_stats.csv"))
cat("  Saved summary_stats.csv\n")

# ============================================================================
# TABLE 2: State EITC Policy Details
# ============================================================================

cat("\nCreating Table 2: State EITC Policies...\n")

eitc_details <- eitc_policy %>%
  arrange(eitc_adopted) %>%
  select(
    State = state_name,
    `Year Adopted` = eitc_adopted,
    `% of Federal (2019)` = eitc_pct_2019,
    Refundable = refundable
  ) %>%
  mutate(Refundable = if_else(Refundable, "Yes", "No"))

write_csv(eitc_details, file.path(TAB_DIR, "eitc_policies.csv"))
cat("  Saved eitc_policies.csv\n")

# ============================================================================
# TABLE 3: Main Results (LaTeX)
# ============================================================================

cat("\nCreating Table 3: Main Results...\n")

# Re-run main regressions for clean table
twfe_property <- feols(log_property_rate ~ treated | state_abbr + year,
                       data = analysis_data, cluster = "state_abbr")

twfe_burglary <- feols(log_burglary_rate ~ treated | state_abbr + year,
                       data = analysis_data, cluster = "state_abbr")

twfe_larceny <- feols(log_larceny_rate ~ treated | state_abbr + year,
                      data = analysis_data, cluster = "state_abbr")

twfe_mvt <- feols(log_mvt_rate ~ treated | state_abbr + year,
                  data = analysis_data, cluster = "state_abbr")

twfe_violent <- feols(log_violent_rate ~ treated | state_abbr + year,
                      data = analysis_data, cluster = "state_abbr")

# Export to LaTeX with modelsummary
models <- list(
  "Property" = twfe_property,
  "Burglary" = twfe_burglary,
  "Larceny" = twfe_larceny,
  "MVT" = twfe_mvt,
  "Violent" = twfe_violent
)

modelsummary(
  models,
  output = file.path(TAB_DIR, "main_results.tex"),
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  coef_rename = c("treated" = "State EITC"),
  gof_map = c("nobs", "r.squared", "r.squared.within"),
  title = "Effect of State EITC on Crime Rates",
  notes = "State and year fixed effects. Standard errors clustered at state level."
)

# Also save as CSV for easy inspection
main_results <- data.frame(
  Outcome = c("Property", "Burglary", "Larceny", "MVT", "Violent"),
  Coefficient = c(coef(twfe_property)["treated"],
                  coef(twfe_burglary)["treated"],
                  coef(twfe_larceny)["treated"],
                  coef(twfe_mvt)["treated"],
                  coef(twfe_violent)["treated"]),
  SE = c(se(twfe_property)["treated"],
         se(twfe_burglary)["treated"],
         se(twfe_larceny)["treated"],
         se(twfe_mvt)["treated"],
         se(twfe_violent)["treated"]),
  N = nobs(twfe_property)
) %>%
  mutate(
    `95% CI Lower` = Coefficient - 1.96 * SE,
    `95% CI Upper` = Coefficient + 1.96 * SE,
    `p-value` = 2 * (1 - pnorm(abs(Coefficient / SE)))
  )

write_csv(main_results, file.path(TAB_DIR, "main_results.csv"))
cat("  Saved main_results.tex and main_results.csv\n")

# ============================================================================
# TABLE 4: Continuous Treatment Results
# ============================================================================

cat("\nCreating Table 4: Continuous Treatment...\n")

twfe_property_cont <- feols(log_property_rate ~ eitc_generosity | state_abbr + year,
                            data = analysis_data, cluster = "state_abbr")

twfe_burglary_cont <- feols(log_burglary_rate ~ eitc_generosity | state_abbr + year,
                            data = analysis_data, cluster = "state_abbr")

twfe_violent_cont <- feols(log_violent_rate ~ eitc_generosity | state_abbr + year,
                           data = analysis_data, cluster = "state_abbr")

models_cont <- list(
  "Property" = twfe_property_cont,
  "Burglary" = twfe_burglary_cont,
  "Violent" = twfe_violent_cont
)

modelsummary(
  models_cont,
  output = file.path(TAB_DIR, "continuous_results.tex"),
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  coef_rename = c("eitc_generosity" = "EITC Generosity (\\%)"),
  gof_map = c("nobs", "r.squared", "r.squared.within"),
  title = "Effect of EITC Generosity on Crime Rates",
  notes = "EITC generosity measured as percentage of federal EITC."
)

cat("  Saved continuous_results.tex\n")

# ============================================================================
# TABLE 5: Callaway-Sant'Anna Results
# ============================================================================

cat("\nCreating Table 5: Callaway-Sant'Anna...\n")

cs_results <- readRDS(file.path(DATA_DIR, "cs_results.rds"))

# Extract key results
cs_summary <- data.frame(
  Estimator = c("Overall ATT", "Pre-treatment average", "Post-treatment average"),
  Estimate = c(
    cs_results$agg_simple$overall.att,
    mean(cs_results$agg_dynamic$att.egt[cs_results$agg_dynamic$egt < 0]),
    mean(cs_results$agg_dynamic$att.egt[cs_results$agg_dynamic$egt >= 0])
  ),
  SE = c(
    cs_results$agg_simple$overall.se,
    NA,  # Simplified
    NA
  )
)

write_csv(cs_summary, file.path(TAB_DIR, "cs_results.csv"))
cat("  Saved cs_results.csv\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n============================================\n")
cat("Tables saved to:", TAB_DIR, "\n")
cat("============================================\n")
cat("  - summary_stats.csv\n")
cat("  - eitc_policies.csv\n")
cat("  - main_results.tex/csv\n")
cat("  - continuous_results.tex\n")
cat("  - cs_results.csv\n")
cat("  - robustness.tex (from 04_robustness.R)\n")
cat("  - heterogeneity.tex (from 04_robustness.R)\n")
cat("============================================\n")
