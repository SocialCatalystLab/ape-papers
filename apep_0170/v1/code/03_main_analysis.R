# ==============================================================================
# 03_main_analysis.R - Main Difference-in-Differences Analysis
# Paper: Salary History Bans and Wage Compression
# ==============================================================================

library(tidyverse)
library(fixest)
library(did)
library(modelsummary)
library(here)

# Set paths relative to paper directory
data_dir <- file.path(here::here(), "data")
tables_dir <- file.path(here::here(), "tables")

# ------------------------------------------------------------------------------
# Load Data
# ------------------------------------------------------------------------------

state_year <- read_csv(file.path(data_dir, "state_year_wages.csv"),
                       show_col_types = FALSE)

job_changers <- read_csv(file.path(data_dir, "job_changer_wages.csv"),
                         show_col_types = FALSE)

cat("Data loaded:\n")
cat("  State-year panel:", nrow(state_year), "obs\n")
cat("  Job changers panel:", nrow(job_changers), "obs\n")

# ------------------------------------------------------------------------------
# Descriptive Statistics
# ------------------------------------------------------------------------------

cat("\n" , rep("=", 60), "\n")
cat("DESCRIPTIVE STATISTICS\n")
cat(rep("=", 60), "\n\n")

# Pre-treatment means by treatment status
pre_stats <- state_year %>%
  filter(year < 2018) %>%  # Pre any major adoption
  mutate(ever_treated = first_treat > 0) %>%
  group_by(ever_treated) %>%
  summarise(
    n_states = n_distinct(statefip),
    mean_log_wage = mean(mean_log_wage, na.rm = TRUE),
    mean_p90_p10 = mean(p90_p10, na.rm = TRUE),
    mean_sd_log_wage = mean(sd_log_wage, na.rm = TRUE),
    .groups = "drop"
  )

print(pre_stats)

# ------------------------------------------------------------------------------
# SPECIFICATION 1: Two-Way Fixed Effects (Baseline)
# ------------------------------------------------------------------------------

cat("\n" , rep("=", 60), "\n")
cat("SPECIFICATION 1: TWFE (All Workers)\n")
cat(rep("=", 60), "\n\n")

# Main outcomes: wage dispersion measures
# p90_p10: 90-10 log wage gap
# sd_log_wage: standard deviation of log wages

twfe_p90p10 <- feols(
  p90_p10 ~ shb | statefip + year,
  data = state_year,
  cluster = ~statefip
)

twfe_sd <- feols(
  sd_log_wage ~ shb | statefip + year,
  data = state_year,
  cluster = ~statefip
)

twfe_mean <- feols(
  mean_log_wage ~ shb | statefip + year,
  data = state_year,
  cluster = ~statefip
)

cat("TWFE Results (All Workers):\n\n")
etable(twfe_p90p10, twfe_sd, twfe_mean,
       headers = c("90-10 Gap", "SD Log Wage", "Mean Log Wage"),
       se.below = TRUE)

# ------------------------------------------------------------------------------
# SPECIFICATION 2: TWFE on Job Changers (Higher Exposure)
# ------------------------------------------------------------------------------

cat("\n" , rep("=", 60), "\n")
cat("SPECIFICATION 2: TWFE (Job Changers Only)\n")
cat(rep("=", 60), "\n\n")

twfe_jc_p90p10 <- feols(
  p90_p10 ~ shb | statefip + year,
  data = job_changers,
  cluster = ~statefip
)

twfe_jc_sd <- feols(
  sd_log_wage ~ shb | statefip + year,
  data = job_changers,
  cluster = ~statefip
)

twfe_jc_mean <- feols(
  mean_log_wage ~ shb | statefip + year,
  data = job_changers,
  cluster = ~statefip
)

cat("TWFE Results (Job Changers):\n\n")
etable(twfe_jc_p90p10, twfe_jc_sd, twfe_jc_mean,
       headers = c("90-10 Gap", "SD Log Wage", "Mean Log Wage"),
       se.below = TRUE)

# ------------------------------------------------------------------------------
# SPECIFICATION 3: Callaway-Sant'Anna Estimator
# ------------------------------------------------------------------------------

cat("\n" , rep("=", 60), "\n")
cat("SPECIFICATION 3: Callaway-Sant'Anna DiD\n")
cat(rep("=", 60), "\n\n")

# Prepare data for did package
cs_data <- state_year %>%
  mutate(
    id = statefip,
    time = year,
    G = first_treat  # 0 for never-treated
  ) %>%
  filter(!is.na(p90_p10))

# Callaway-Sant'Anna with never-treated as control
# Set seed for reproducible bootstrap inference
set.seed(156)
cs_result <- att_gt(
  yname = "p90_p10",
  tname = "time",
  idname = "id",
  gname = "G",
  data = cs_data,
  control_group = "nevertreated",
  bstrap = TRUE,
  biters = 1000,
  cband = TRUE
)

cat("Group-Time ATTs:\n")
summary(cs_result)

# Aggregate to overall ATT
cs_agg <- aggte(cs_result, type = "simple")
cat("\n\nOverall ATT (Simple Average):\n")
summary(cs_agg)

# Event study aggregation
cs_event <- aggte(cs_result, type = "dynamic", min_e = -5, max_e = 5)
cat("\n\nEvent Study Estimates:\n")
summary(cs_event)

# ------------------------------------------------------------------------------
# Save Main Results
# ------------------------------------------------------------------------------

# Create results table
main_results <- tibble(
  specification = c("TWFE All Workers", "TWFE Job Changers", "CS DiD"),
  outcome = "90-10 Log Wage Gap",
  estimate = c(
    coef(twfe_p90p10)["shb"],
    coef(twfe_jc_p90p10)["shb"],
    cs_agg$overall.att
  ),
  se = c(
    se(twfe_p90p10)["shb"],
    se(twfe_jc_p90p10)["shb"],
    cs_agg$overall.se
  ),
  n_obs = c(
    nrow(state_year),
    nrow(job_changers),
    nrow(cs_data)
  )
) %>%
  mutate(
    t_stat = estimate / se,
    p_value = 2 * (1 - pnorm(abs(t_stat))),
    ci_low = estimate - 1.96 * se,
    ci_high = estimate + 1.96 * se
  )

write_csv(main_results, file.path(tables_dir, "main_results.csv"))

# Save CS event study for plotting
cs_event_df <- tibble(
  event_time = cs_event$egt,
  att = cs_event$att.egt,
  se = cs_event$se.egt
) %>%
  mutate(
    ci_low = att - 1.96 * se,
    ci_high = att + 1.96 * se
  )

write_csv(cs_event_df, file.path(data_dir, "event_study_estimates.csv"))

cat("\n")
cat(rep("=", 60), "\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat(rep("=", 60), "\n")
cat("\nResults saved to:\n")
cat("  - tables/main_results.csv\n")
cat("  - data/event_study_estimates.csv\n")
