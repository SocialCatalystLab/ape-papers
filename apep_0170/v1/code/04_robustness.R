# ==============================================================================
# 04_robustness.R - Robustness Checks and Placebo Tests
# Paper: Salary History Bans and Wage Compression
# ==============================================================================

library(tidyverse)
library(fixest)
library(did)
library(here)

# Set paths relative to paper directory
data_dir <- file.path(here::here(), "data")
tables_dir <- file.path(here::here(), "tables")

# Load data
state_year <- read_csv(file.path(data_dir, "state_year_wages.csv"),
                       show_col_types = FALSE)

cat(strrep("=", 60), "\n")
cat("ROBUSTNESS CHECKS\n")
cat(strrep("=", 60), "\n\n")

# ------------------------------------------------------------------------------
# 1. Pre-Trends Test (Event Study)
# ------------------------------------------------------------------------------

cat("1. PRE-TRENDS TEST\n\n")

# Create relative time to treatment
state_year <- state_year %>%
  mutate(
    rel_time = ifelse(first_treat > 0, year - first_treat, NA),
    rel_time_factor = case_when(
      rel_time <= -4 ~ "-4+",
      rel_time == -3 ~ "-3",
      rel_time == -2 ~ "-2",
      rel_time == -1 ~ "-1",
      rel_time == 0 ~ "0",
      rel_time == 1 ~ "1",
      rel_time == 2 ~ "2",
      rel_time >= 3 ~ "3+",
      TRUE ~ "Never Treated"
    ),
    rel_time_factor = factor(rel_time_factor, 
                            levels = c("-4+", "-3", "-2", "-1", "0", "1", "2", "3+", "Never Treated"))
  )

# Event study regression
es_reg <- feols(
  p90_p10 ~ i(rel_time_factor, ref = "-1") | statefip + year,
  data = state_year %>% filter(first_treat > 0),  # Treated states only
  cluster = ~statefip
)

cat("Event Study Coefficients:\n")
print(coeftable(es_reg))

# Save event study coefficients
es_coefs <- broom::tidy(es_reg) %>%
  filter(str_detect(term, "rel_time")) %>%
  mutate(
    rel_time = as.numeric(str_extract(term, "-?\\d+"))
  )

write_csv(es_coefs, file.path(data_dir, "event_study_twfe.csv"))

# ------------------------------------------------------------------------------
# 2. Placebo Test: Non-Labor Income
# ------------------------------------------------------------------------------

cat("\n2. PLACEBO TEST\n\n")

# Load individual-level data for placebo (if available)
# Placebo outcome: investment income, social security - should not be affected

cat("Placebo outcomes should show null effect.\n")
cat("(Requires individual-level data with INCINVST variable)\n")

# ------------------------------------------------------------------------------
# 3. Alternative Control Groups
# ------------------------------------------------------------------------------

cat("\n3. ALTERNATIVE CONTROL GROUPS\n\n")

# Only use not-yet-treated as control (exclude never-treated)
cs_data <- state_year %>%
  filter(first_treat > 0 | first_treat == 0) %>%  # Keep never-treated for now
  mutate(id = statefip, time = year, G = first_treat)

# CS with not-yet-treated control
# Set seed for reproducible bootstrap inference
set.seed(156)
cs_notyet <- tryCatch({
  att_gt(
    yname = "p90_p10",
    tname = "time",
    idname = "id",
    gname = "G",
    data = cs_data,
    control_group = "notyettreated",
    bstrap = TRUE,
    biters = 500
  )
}, error = function(e) {
  cat("CS with not-yet-treated failed:", e$message, "\n")
  return(NULL)
})

if (!is.null(cs_notyet)) {
  cs_notyet_agg <- aggte(cs_notyet, type = "simple")
  cat("CS (Not-Yet-Treated Control):\n")
  cat("  ATT:", round(cs_notyet_agg$overall.att, 4), "\n")
  cat("  SE:", round(cs_notyet_agg$overall.se, 4), "\n")
}

# ------------------------------------------------------------------------------
# 4. Heterogeneity Analysis
# ------------------------------------------------------------------------------

cat("\n4. HETEROGENEITY BY STATE CHARACTERISTICS\n\n")

# Would typically split by:
# - Baseline wage inequality (high vs low)
# - State minimum wage levels
# - Industry composition

cat("Heterogeneity analysis requires additional state-level covariates.\n")

# ------------------------------------------------------------------------------
# 5. Sun-Abraham Estimator (Alternative to CS)
# ------------------------------------------------------------------------------

cat("\n5. SUN-ABRAHAM ESTIMATOR\n\n")

# Sun-Abraham is built into fixest
sa_result <- feols(
  p90_p10 ~ sunab(first_treat, year) | statefip + year,
  data = state_year %>% filter(!is.na(p90_p10)),
  cluster = ~statefip
)

cat("Sun-Abraham Results:\n")
print(summary(sa_result))

# ------------------------------------------------------------------------------
# 6. Bacon Decomposition (TWFE Diagnostic)
# ------------------------------------------------------------------------------

cat("\n6. GOODMAN-BACON DECOMPOSITION\n\n")

# Install bacondecomp if needed
if (!requireNamespace("bacondecomp", quietly = TRUE)) {
  cat("bacondecomp package not installed. Skipping decomposition.\n")
} else {
  library(bacondecomp)
  
  bacon_data <- state_year %>%
    filter(!is.na(p90_p10)) %>%
    mutate(treat = as.numeric(shb))
  
  bacon_result <- bacon(
    p90_p10 ~ treat,
    data = bacon_data,
    id_var = "statefip",
    time_var = "year"
  )
  
  cat("Bacon Decomposition:\n")
  print(bacon_result)
  
  write_csv(bacon_result, file.path(data_dir, "bacon_decomposition.csv"))
}

# ------------------------------------------------------------------------------
# Save Robustness Results
# ------------------------------------------------------------------------------

robustness_summary <- tibble(
  check = c(
    "Pre-trends (F-test p-value)",
    "Placebo: Non-labor income",
    "CS Not-Yet-Treated Control",
    "Sun-Abraham ATT"
  ),
  result = c(
    "See event study plot",
    "Pending (requires micro data)",
    ifelse(!is.null(cs_notyet), 
           sprintf("%.4f (%.4f)", cs_notyet_agg$overall.att, cs_notyet_agg$overall.se),
           "Failed"),
    sprintf("%.4f", mean(coef(sa_result)[!is.na(coef(sa_result))]))
  )
)

write_csv(robustness_summary, file.path(tables_dir, "robustness_summary.csv"))

cat("\n")
cat(strrep("=", 60), "\n")
cat("ROBUSTNESS CHECKS COMPLETE\n")
cat(strrep("=", 60), "\n")
