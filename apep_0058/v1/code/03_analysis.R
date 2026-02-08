# =============================================================================
# Paper 73: SOI Discrimination Laws and Housing Voucher Utilization
# 03_analysis.R - Main DiD analysis using Callaway-Sant'Anna
# =============================================================================

source("code/00_packages.R")
library(readxl)
library(did)
library(fixest)

# =============================================================================
# 1. Load and Prepare Panel Data
# =============================================================================

# Load treatment data
soi_treatment <- read_csv("data/soi_treatment.csv", show_col_types = FALSE)

# Load HUD data for all years
years <- 2015:2024
hud_list <- lapply(years, function(yr) {
  read_csv(sprintf("data/hud_state_%d_clean.csv", yr), show_col_types = FALSE)
})
hud_all <- bind_rows(hud_list)

cat("HUD data loaded:", nrow(hud_all), "rows\n")

# =============================================================================
# 2. Filter to Housing Choice Voucher Program
# =============================================================================

# Program code 3 = Housing Choice Vouchers
hud_hcv <- hud_all %>%
  filter(program == 3) %>%
  mutate(
    state_name = str_trim(states),
    state_name = gsub("^[A-Z]{2} ", "", state_name)  # Remove state abbreviation prefix
  )

cat("HCV data:", nrow(hud_hcv), "state-year observations\n")

# Check states
cat("\nStates in HUD data:\n")
print(sort(unique(hud_hcv$state_name)))

# =============================================================================
# 3. Merge Treatment Status
# =============================================================================

# Create clean state name matching
hud_hcv <- hud_hcv %>%
  left_join(soi_treatment, by = "state_name")

# Check merge
cat("\nMerge results:\n")
cat("Matched:", sum(!is.na(hud_hcv$state_abbr)), "\n")
cat("Unmatched:", sum(is.na(hud_hcv$state_abbr)), "\n")

if (sum(is.na(hud_hcv$state_abbr)) > 0) {
  cat("Unmatched states:\n")
  print(unique(hud_hcv$state_name[is.na(hud_hcv$state_abbr)]))
}

# =============================================================================
# 4. Create Analysis Variables
# =============================================================================

analysis_df <- hud_hcv %>%
  filter(!is.na(state_abbr)) %>%
  mutate(
    # Treatment timing for C-S: first year of treatment, 0 for never-treated
    first_treat = ifelse(treat_year > 2024, 0, treat_year),

    # Create numeric state ID
    state_id = as.numeric(factor(state_abbr)),

    # Outcome: occupancy rate (pct_occupied)
    utilization = pct_occupied,

    # Alternative: total_units as measure of program size
    total_hcv_units = total_units,

    # People served
    people_served = people_total
  ) %>%
  # Keep only necessary columns
  select(
    year, state_abbr, state_name, state_id,
    first_treat, has_soi, law_strength,
    utilization, total_hcv_units, people_served,
    hh_income, rent_per_month, spending_per_month
  ) %>%
  # Remove rows with missing outcome
  filter(!is.na(utilization))

cat("\nAnalysis sample:", nrow(analysis_df), "state-year observations\n")
cat("States:", n_distinct(analysis_df$state_abbr), "\n")
cat("Years:", min(analysis_df$year), "-", max(analysis_df$year), "\n")

# Save analysis dataset
write_csv(analysis_df, "data/analysis_panel.csv")

# =============================================================================
# 5. Summary Statistics
# =============================================================================

summary_stats <- analysis_df %>%
  group_by(has_soi) %>%
  summarize(
    n_state_years = n(),
    n_states = n_distinct(state_abbr),
    mean_utilization = mean(utilization, na.rm = TRUE),
    sd_utilization = sd(utilization, na.rm = TRUE),
    mean_units = mean(total_hcv_units, na.rm = TRUE),
    mean_income = mean(hh_income, na.rm = TRUE),
    .groups = "drop"
  )

cat("\n=== Summary Statistics by Treatment Status ===\n")
print(summary_stats)

# =============================================================================
# 6. Callaway-Sant'Anna Estimation
# =============================================================================

cat("\n=== Callaway-Sant'Anna Estimation ===\n")

# Filter to states with non-zero first_treat for treated group
# and states with first_treat = 0 for never-treated
analysis_cs <- analysis_df %>%
  # Focus on recent treatment variation (2016+)
  # Exclude always-treated states (pre-2016) as they have no pre-treatment periods
  filter(first_treat == 0 | first_treat >= 2016)

cat("C-S sample size:", nrow(analysis_cs), "\n")
cat("Treatment cohorts:\n")
print(table(analysis_cs$first_treat[analysis_cs$first_treat > 0]))

# Run C-S estimation
cs_result <- att_gt(
  yname = "utilization",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  xformla = ~ 1,  # No covariates for now
  data = analysis_cs,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "varying"
)

# Print summary
cat("\nGroup-Time ATT Results:\n")
summary(cs_result)

# Aggregate to event study
es_result <- aggte(cs_result, type = "dynamic", min_e = -4, max_e = 4)

cat("\n=== Event Study Results ===\n")
summary(es_result)

# Aggregate to simple ATT
att_simple <- aggte(cs_result, type = "simple")
cat("\n=== Overall ATT ===\n")
summary(att_simple)

# =============================================================================
# 7. Event Study Plot
# =============================================================================

# Create event study data frame
es_df <- data.frame(
  event_time = es_result$egt,
  att = es_result$att.egt,
  se = es_result$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

# Plot
p_event_study <- ggplot(es_df, aes(x = event_time, y = att)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Effect of SOI Discrimination Laws on Voucher Occupancy",
    subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
    x = "Years Relative to Law Effective Date",
    y = "Effect on Occupancy Rate (percentage points)",
    caption = "Note: Uses varying base period (each cohort compared to its own pre-treatment period). Sample excludes always-treated states."
  ) +
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  theme_apep()

ggsave("figures/event_study.pdf", p_event_study, width = 8, height = 5)
ggsave("figures/event_study.png", p_event_study, width = 8, height = 5, dpi = 300)

cat("\nEvent study plot saved to figures/event_study.pdf\n")

# =============================================================================
# 8. TWFE Comparison (for reference)
# =============================================================================

cat("\n=== TWFE Comparison ===\n")

# Create post-treatment indicator
analysis_cs <- analysis_cs %>%
  mutate(
    post = as.numeric(year >= first_treat & first_treat > 0)
  )

# Standard TWFE
twfe_model <- feols(
  utilization ~ post | state_id + year,
  data = analysis_cs,
  cluster = ~state_id
)

cat("\nTWFE Results:\n")
print(summary(twfe_model))

# =============================================================================
# 9. Parallel Trends Visualization
# =============================================================================

# Average outcomes by treatment cohort
trends_df <- analysis_cs %>%
  mutate(
    cohort = case_when(
      first_treat == 0 ~ "Never Treated",
      first_treat <= 2018 ~ "Early (2016-2018)",
      TRUE ~ "Recent (2019-2022)"
    )
  ) %>%
  group_by(year, cohort) %>%
  summarize(
    mean_util = mean(utilization, na.rm = TRUE),
    se_util = sd(utilization, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p_trends <- ggplot(trends_df, aes(x = year, y = mean_util, color = cohort)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  geom_ribbon(aes(ymin = mean_util - 1.96 * se_util,
                  ymax = mean_util + 1.96 * se_util,
                  fill = cohort), alpha = 0.15, color = NA) +
  scale_color_manual(values = apep_colors[1:3]) +
  scale_fill_manual(values = apep_colors[1:3]) +
  labs(
    title = "Voucher Utilization Trends by Treatment Cohort",
    subtitle = "State-level average occupancy rates",
    x = "Year",
    y = "Mean Utilization Rate (%)",
    color = "Treatment Cohort",
    fill = "Treatment Cohort",
    caption = "Note: Shaded areas show 95% confidence intervals."
  ) +
  theme_apep()

ggsave("figures/parallel_trends.pdf", p_trends, width = 8, height = 5)
ggsave("figures/parallel_trends.png", p_trends, width = 8, height = 5, dpi = 300)

cat("Parallel trends plot saved to figures/parallel_trends.pdf\n")

# =============================================================================
# 10. Save Results
# =============================================================================

# Save C-S results
results_list <- list(
  cs_result = cs_result,
  es_result = es_result,
  att_simple = att_simple,
  twfe_model = twfe_model
)

saveRDS(results_list, "data/estimation_results.rds")

# Create summary table
results_table <- tibble(
  Estimator = c("Callaway-Sant'Anna", "TWFE"),
  ATT = c(att_simple$overall.att, coef(twfe_model)["post"]),
  SE = c(att_simple$overall.se, se(twfe_model)["post"]),
  CI_Lower = ATT - 1.96 * SE,
  CI_Upper = ATT + 1.96 * SE,
  p_value = c(2 * (1 - pnorm(abs(ATT / SE))),
              2 * (1 - pnorm(abs(coef(twfe_model)["post"] / se(twfe_model)["post"]))))
)

write_csv(results_table, "tables/main_results.csv")
cat("\nResults saved to tables/main_results.csv\n")

print(results_table)

cat("\n=== Analysis Complete ===\n")
