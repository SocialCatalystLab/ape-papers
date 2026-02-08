# ============================================================================
# Paper 105: State EITC Generosity and Property Crime
# Script: 03_main_analysis.R - Main DiD Analysis
# ============================================================================

source("00_packages.R")

cat("Running main analysis for Paper 105...\n\n")

# Load analysis data
analysis_data <- read_csv(file.path(DATA_DIR, "analysis_eitc_crime.csv"), show_col_types = FALSE)
cat(sprintf("Loaded %d state-year observations\n\n", nrow(analysis_data)))

# ============================================================================
# PART 1: TWFE Regressions
# ============================================================================

cat("====================================\n")
cat("PART 1: Two-Way Fixed Effects Models\n")
cat("====================================\n\n")

# 1.1 Binary Treatment (Has EITC)
cat("1.1 Binary Treatment: Has State EITC\n")
cat("-------------------------------------\n")

# Main outcomes: property crime and its components
twfe_property <- feols(log_property_rate ~ treated | state_abbr + year,
                       data = analysis_data, cluster = "state_abbr")

twfe_burglary <- feols(log_burglary_rate ~ treated | state_abbr + year,
                       data = analysis_data, cluster = "state_abbr")

twfe_larceny <- feols(log_larceny_rate ~ treated | state_abbr + year,
                      data = analysis_data, cluster = "state_abbr")

twfe_mvt <- feols(log_mvt_rate ~ treated | state_abbr + year,
                  data = analysis_data, cluster = "state_abbr")

# Placebo: violent crime (different mechanism)
twfe_violent <- feols(log_violent_rate ~ treated | state_abbr + year,
                      data = analysis_data, cluster = "state_abbr")

# Display results
cat("\nTWFE Results (Binary Treatment):\n")
etable(twfe_property, twfe_burglary, twfe_larceny, twfe_mvt, twfe_violent,
       headers = c("Property", "Burglary", "Larceny", "MVT", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# 1.2 Continuous Treatment (EITC Generosity)
cat("\n\n1.2 Continuous Treatment: EITC Generosity (% of Federal)\n")
cat("----------------------------------------------------------\n")

twfe_property_cont <- feols(log_property_rate ~ eitc_generosity | state_abbr + year,
                            data = analysis_data, cluster = "state_abbr")

twfe_burglary_cont <- feols(log_burglary_rate ~ eitc_generosity | state_abbr + year,
                            data = analysis_data, cluster = "state_abbr")

twfe_larceny_cont <- feols(log_larceny_rate ~ eitc_generosity | state_abbr + year,
                           data = analysis_data, cluster = "state_abbr")

twfe_mvt_cont <- feols(log_mvt_rate ~ eitc_generosity | state_abbr + year,
                       data = analysis_data, cluster = "state_abbr")

twfe_violent_cont <- feols(log_violent_rate ~ eitc_generosity | state_abbr + year,
                           data = analysis_data, cluster = "state_abbr")

cat("\nTWFE Results (Continuous Treatment):\n")
etable(twfe_property_cont, twfe_burglary_cont, twfe_larceny_cont, twfe_mvt_cont, twfe_violent_cont,
       headers = c("Property", "Burglary", "Larceny", "MVT", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# ============================================================================
# PART 2: Event Study
# ============================================================================

cat("\n====================================\n")
cat("PART 2: Event Study Analysis\n")
cat("====================================\n\n")

# Create relative time variable (years since EITC adoption)
# Restrict to states that adopted during sample period
analysis_data_es <- analysis_data %>%
  filter(!is.na(eitc_adopted) & eitc_adopted >= 1999) %>%
  mutate(
    rel_time = year - eitc_adopted,
    # Bin extreme values
    rel_time_binned = case_when(
      rel_time < -5 ~ -5,
      rel_time > 10 ~ 10,
      TRUE ~ rel_time
    )
  )

cat(sprintf("Event study sample: %d state-years (states adopting 1999-2019)\n", nrow(analysis_data_es)))

# Event study regression using fixest sunab
es_property <- feols(log_property_rate ~ sunab(eitc_adopted, year, ref.p = -1) | state_abbr + year,
                     data = analysis_data %>% filter(!is.na(eitc_adopted) & eitc_adopted >= 1999),
                     cluster = "state_abbr")

es_burglary <- feols(log_burglary_rate ~ sunab(eitc_adopted, year, ref.p = -1) | state_abbr + year,
                     data = analysis_data %>% filter(!is.na(eitc_adopted) & eitc_adopted >= 1999),
                     cluster = "state_abbr")

# Event study coefficients
cat("\nEvent Study Coefficients (Property Crime):\n")
print(summary(es_property))

# ============================================================================
# PART 3: Callaway-Sant'Anna Estimator
# ============================================================================

cat("\n====================================\n")
cat("PART 3: Callaway-Sant'Anna DiD\n")
cat("====================================\n\n")

# Prepare data for did package
cs_data <- analysis_data %>%
  mutate(
    # CS requires numeric id
    id = as.numeric(factor(state_abbr)),
    # First treatment period (0 for never treated)
    first_treat_cs = if_else(is.na(eitc_adopted) | eitc_adopted < 1999, 0, as.integer(eitc_adopted))
  )

# Run CS estimator for property crime
cs_property <- att_gt(
  yname = "log_property_rate",
  tname = "year",
  idname = "id",
  gname = "first_treat_cs",
  data = cs_data,
  control_group = "nevertreated",
  base_period = "universal"
)

cat("Callaway-Sant'Anna Group-Time ATTs:\n")
print(summary(cs_property))

# Aggregate to overall ATT
cs_agg <- aggte(cs_property, type = "simple")
cat("\n\nOverall ATT (Callaway-Sant'Anna):\n")
print(summary(cs_agg))

# Dynamic/event study aggregation
cs_dynamic <- aggte(cs_property, type = "dynamic")
cat("\n\nDynamic ATT (Event Study):\n")
print(summary(cs_dynamic))

# ============================================================================
# PART 4: Bacon Decomposition
# ============================================================================

cat("\n====================================\n")
cat("PART 4: Goodman-Bacon Decomposition\n")
cat("====================================\n\n")

# Bacon decomposition to diagnose TWFE issues
bacon_data <- analysis_data %>%
  mutate(
    # Create state numeric id
    state_id = as.numeric(factor(state_abbr))
  )

bacon_out <- bacon(log_property_rate ~ treated,
                   data = bacon_data,
                   id_var = "state_id",
                   time_var = "year")

cat("Bacon Decomposition:\n")
print(bacon_out)

# Summary by comparison type
bacon_summary <- bacon_out %>%
  group_by(type) %>%
  summarise(
    n_comparisons = n(),
    total_weight = sum(weight),
    weighted_estimate = sum(weight * estimate) / sum(weight),
    .groups = "drop"
  )

cat("\nDecomposition by Comparison Type:\n")
print(bacon_summary)

# ============================================================================
# PART 5: Save Results
# ============================================================================

cat("\n====================================\n")
cat("Saving Results\n")
cat("====================================\n\n")

# Save TWFE results as table
twfe_table <- etable(twfe_property, twfe_burglary, twfe_larceny, twfe_mvt, twfe_violent,
                     headers = c("Property", "Burglary", "Larceny", "MVT", "Violent"),
                     tex = TRUE,
                     file = file.path(TAB_DIR, "twfe_binary.tex"))

twfe_table_cont <- etable(twfe_property_cont, twfe_burglary_cont, twfe_larceny_cont,
                          twfe_mvt_cont, twfe_violent_cont,
                          headers = c("Property", "Burglary", "Larceny", "MVT", "Violent"),
                          tex = TRUE,
                          file = file.path(TAB_DIR, "twfe_continuous.tex"))

# Save CS results
cs_results <- list(
  att_gt = cs_property,
  agg_simple = cs_agg,
  agg_dynamic = cs_dynamic
)
saveRDS(cs_results, file.path(DATA_DIR, "cs_results.rds"))

# Save Bacon results
write_csv(bacon_out, file.path(DATA_DIR, "bacon_decomposition.csv"))

cat("Results saved to:\n")
cat(sprintf("  - %s/twfe_binary.tex\n", TAB_DIR))
cat(sprintf("  - %s/twfe_continuous.tex\n", TAB_DIR))
cat(sprintf("  - %s/cs_results.rds\n", DATA_DIR))
cat(sprintf("  - %s/bacon_decomposition.csv\n", DATA_DIR))

cat("\n============================================\n")
cat("Main analysis complete!\n")
cat("============================================\n")
