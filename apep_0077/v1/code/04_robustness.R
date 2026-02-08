# ============================================================================
# Paper 105: State EITC Generosity and Property Crime
# Script: 04_robustness.R - Robustness Checks
# ============================================================================

source("00_packages.R")

cat("Running robustness checks for Paper 105...\n\n")

# Load analysis data
analysis_data <- read_csv(file.path(DATA_DIR, "analysis_eitc_crime.csv"), show_col_types = FALSE)

# ============================================================================
# PART 1: Alternative Specifications
# ============================================================================

cat("====================================\n")
cat("PART 1: Alternative Specifications\n")
cat("====================================\n\n")

# 1.1 Add time-varying controls (population)
cat("1.1 With Population Control\n")
cat("---------------------------\n")

twfe_pop <- feols(log_property_rate ~ treated + log_population | state_abbr + year,
                  data = analysis_data, cluster = "state_abbr")

twfe_violent_pop <- feols(log_violent_rate ~ treated + log_population | state_abbr + year,
                          data = analysis_data, cluster = "state_abbr")

etable(twfe_pop, twfe_violent_pop,
       headers = c("Property", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# 1.2 State-specific linear trends
cat("\n\n1.2 State-Specific Linear Trends\n")
cat("---------------------------------\n")

# Create trend variable
analysis_data <- analysis_data %>%
  mutate(trend = year - 1999)

twfe_trend <- feols(log_property_rate ~ treated | state_abbr[trend] + year,
                    data = analysis_data, cluster = "state_abbr")

twfe_violent_trend <- feols(log_violent_rate ~ treated | state_abbr[trend] + year,
                            data = analysis_data, cluster = "state_abbr")

etable(twfe_trend, twfe_violent_trend,
       headers = c("Property", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# ============================================================================
# PART 2: Sample Restrictions
# ============================================================================

cat("\n====================================\n")
cat("PART 2: Sample Restrictions\n")
cat("====================================\n\n")

# 2.1 Exclude early adopters (pre-1999)
cat("2.1 Exclude Pre-1999 Adopters (MD, VT, WI, MN, NY, MA, OR, KS)\n")
cat("-------------------------------------------------------------\n")

early_adopters <- c("MD", "VT", "WI", "MN", "NY", "MA", "OR", "KS")

twfe_no_early <- feols(log_property_rate ~ treated | state_abbr + year,
                       data = filter(analysis_data, !(state_abbr %in% early_adopters)),
                       cluster = "state_abbr")

twfe_violent_no_early <- feols(log_violent_rate ~ treated | state_abbr + year,
                               data = filter(analysis_data, !(state_abbr %in% early_adopters)),
                               cluster = "state_abbr")

etable(twfe_no_early, twfe_violent_no_early,
       headers = c("Property", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# 2.2 Restrict to 2005-2019 (exclude early recession years)
cat("\n\n2.2 Restrict to 2005-2019\n")
cat("-------------------------\n")

twfe_late <- feols(log_property_rate ~ treated | state_abbr + year,
                   data = filter(analysis_data, year >= 2005),
                   cluster = "state_abbr")

twfe_violent_late <- feols(log_violent_rate ~ treated | state_abbr + year,
                           data = filter(analysis_data, year >= 2005),
                           cluster = "state_abbr")

etable(twfe_late, twfe_violent_late,
       headers = c("Property", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# 2.3 Exclude DC (outlier)
cat("\n\n2.3 Exclude DC\n")
cat("--------------\n")

twfe_no_dc <- feols(log_property_rate ~ treated | state_abbr + year,
                    data = filter(analysis_data, state_abbr != "DC"),
                    cluster = "state_abbr")

twfe_violent_no_dc <- feols(log_violent_rate ~ treated | state_abbr + year,
                            data = filter(analysis_data, state_abbr != "DC"),
                            cluster = "state_abbr")

etable(twfe_no_dc, twfe_violent_no_dc,
       headers = c("Property", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# ============================================================================
# PART 3: Placebo Tests
# ============================================================================

cat("\n====================================\n")
cat("PART 3: Placebo Tests\n")
cat("====================================\n\n")

# 3.1 Murder rate (should not be affected by income support)
cat("3.1 Murder Rate (Placebo)\n")
cat("-------------------------\n")

twfe_murder <- feols(log(murder_rate + 1) ~ treated | state_abbr + year,
                     data = analysis_data, cluster = "state_abbr")

summary(twfe_murder)

# 3.2 Pre-treatment placebo (fake treatment 3 years before actual)
cat("\n\n3.2 Pre-Treatment Placebo (t-3)\n")
cat("-------------------------------\n")

# Create fake treatment that turns on 3 years before actual
placebo_data <- analysis_data %>%
  mutate(
    fake_adopted = if_else(!is.na(eitc_adopted), eitc_adopted - 3L, NA_integer_),
    fake_treated = if_else(!is.na(fake_adopted) & year >= fake_adopted, 1L, 0L)
  ) %>%
  # Only use pre-treatment data
  filter(is.na(eitc_adopted) | year < eitc_adopted)

twfe_placebo <- feols(log_property_rate ~ fake_treated | state_abbr + year,
                      data = placebo_data, cluster = "state_abbr")

summary(twfe_placebo)
cat("\nNote: Coefficient should be close to zero if parallel trends holds.\n")

# ============================================================================
# PART 4: Heterogeneity Analysis
# ============================================================================

cat("\n====================================\n")
cat("PART 4: Heterogeneity Analysis\n")
cat("====================================\n\n")

# 4.1 By refundability status
cat("4.1 By EITC Refundability\n")
cat("-------------------------\n")

# Create refundability indicator
refundable_states <- c("CA", "CO", "CT", "DC", "IL", "IN", "IA", "KS", "LA",
                       "MD", "MA", "MI", "MN", "MT", "NE", "NJ", "NM", "NY",
                       "OK", "OR", "RI", "VT", "WI")

analysis_data <- analysis_data %>%
  mutate(
    refundable = if_else(state_abbr %in% refundable_states & treated == 1, 1L, 0L),
    nonrefundable = if_else(!(state_abbr %in% refundable_states) & treated == 1, 1L, 0L)
  )

twfe_refund <- feols(log_property_rate ~ refundable + nonrefundable | state_abbr + year,
                     data = analysis_data, cluster = "state_abbr")

summary(twfe_refund)

# 4.2 By EITC generosity terciles
cat("\n\n4.2 By EITC Generosity Terciles\n")
cat("--------------------------------\n")

analysis_data <- analysis_data %>%
  mutate(
    eitc_low = if_else(eitc_generosity > 0 & eitc_generosity <= 10, 1L, 0L),
    eitc_med = if_else(eitc_generosity > 10 & eitc_generosity <= 25, 1L, 0L),
    eitc_high = if_else(eitc_generosity > 25, 1L, 0L)
  )

twfe_tercile <- feols(log_property_rate ~ eitc_low + eitc_med + eitc_high | state_abbr + year,
                      data = analysis_data, cluster = "state_abbr")

summary(twfe_tercile)
cat("\nNote: Higher generosity categories show larger effects if dose-response.\n")

# ============================================================================
# PART 5: Alternative Standard Errors
# ============================================================================

cat("\n====================================\n")
cat("PART 5: Alternative Standard Errors\n")
cat("====================================\n\n")

# Main spec with different clustering
twfe_main <- feols(log_property_rate ~ treated | state_abbr + year,
                   data = analysis_data)

cat("5.1 State-clustered (baseline):\n")
summary(twfe_main, cluster = "state_abbr")

cat("\n5.2 Two-way clustered (state + year):\n")
summary(twfe_main, cluster = c("state_abbr", "year"))

cat("\n5.3 Heteroskedasticity-robust (no clustering):\n")
summary(twfe_main, vcov = "hetero")

# ============================================================================
# PART 6: Save Robustness Results
# ============================================================================

cat("\n====================================\n")
cat("Saving Robustness Results\n")
cat("====================================\n\n")

# Save robustness table
robustness_table <- etable(
  twfe_pop, twfe_trend, twfe_no_early, twfe_late, twfe_no_dc,
  headers = c("Pop Control", "State Trends", "No Early", "2005+", "No DC"),
  se.below = TRUE,
  fitstat = c("n", "r2"),
  tex = TRUE,
  file = file.path(TAB_DIR, "robustness.tex")
)

# Save heterogeneity table
het_table <- etable(
  twfe_refund, twfe_tercile,
  headers = c("Refundability", "Terciles"),
  se.below = TRUE,
  fitstat = c("n", "r2"),
  tex = TRUE,
  file = file.path(TAB_DIR, "heterogeneity.tex")
)

cat("Robustness tables saved to:\n")
cat(sprintf("  - %s/robustness.tex\n", TAB_DIR))
cat(sprintf("  - %s/heterogeneity.tex\n", TAB_DIR))

cat("\n============================================\n")
cat("Robustness checks complete!\n")
cat("============================================\n")
