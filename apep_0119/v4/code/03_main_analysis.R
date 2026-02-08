###############################################################################
# 03_main_analysis.R
# Paper 141: EERS and Residential Electricity Consumption (Revision of apep_0130)
# Primary DiD analysis using Callaway-Sant'Anna and TWFE
#
# REVISION NOTES (apep_0141):
#   - Added CS-DiD cluster bootstrap for robust inference
#   - Added cohort contribution diagnostics
#   - Added treatment intensity (DSM expenditure) analysis
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
fig_dir  <- "../figures/"
tab_dir  <- "../tables/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(paste0(data_dir, "panel_clean.rds"))

###############################################################################
# PART 1: Descriptive Analysis — Treatment Rollout
###############################################################################

# Plot treatment rollout over time
rollout <- panel %>%
  filter(eers_year > 0) %>%
  distinct(state_abbr, eers_year) %>%
  arrange(eers_year)

rollout_plot <- ggplot(rollout, aes(x = eers_year, y = reorder(state_abbr, -eers_year))) +
  geom_point(size = 3, color = apep_colors["treated"]) +
  geom_segment(aes(xend = 2023, yend = reorder(state_abbr, -eers_year)),
               color = apep_colors["treated"], alpha = 0.3, linewidth = 0.5) +
  labs(
    title = "EERS Adoption Timing by State",
    subtitle = "Points show year of mandatory EERS adoption; lines extend to end of sample",
    x = "Year of EERS Adoption",
    y = ""
  ) +
  scale_x_continuous(breaks = seq(1998, 2022, 4)) +
  theme(axis.text.y = element_text(size = 7))

ggsave(paste0(fig_dir, "fig1_treatment_rollout.pdf"), rollout_plot,
       width = 8, height = 10, units = "in")

# Cohort size histogram
cohort_plot <- rollout %>%
  count(eers_year) %>%
  ggplot(aes(x = eers_year, y = n)) +
  geom_col(fill = apep_colors["treated"], alpha = 0.8) +
  labs(
    title = "Number of States Adopting EERS by Year",
    x = "Year of Adoption",
    y = "Number of States"
  ) +
  scale_x_continuous(breaks = seq(1998, 2022, 2)) +
  scale_y_continuous(breaks = seq(0, 10, 2))

ggsave(paste0(fig_dir, "fig2_cohort_sizes.pdf"), cohort_plot,
       width = 8, height = 5, units = "in")

###############################################################################
# PART 2: Average Outcomes by Treatment Group
###############################################################################

# Plot average per-capita residential electricity by treatment status over time
group_means <- panel %>%
  filter(!is.na(res_elec_pc)) %>%
  mutate(group = ifelse(treated == 1, "EERS States", "Non-EERS States")) %>%
  group_by(year, group) %>%
  summarise(
    mean_res_pc = mean(res_elec_pc, na.rm = TRUE),
    se = sd(res_elec_pc, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

trends_plot <- ggplot(group_means, aes(x = year, y = mean_res_pc, color = group)) +
  geom_line(linewidth = 1) +
  geom_ribbon(aes(ymin = mean_res_pc - 1.96 * se, ymax = mean_res_pc + 1.96 * se,
                  fill = group), alpha = 0.15, color = NA) +
  scale_color_manual(values = c("EERS States" = apep_colors["treated"],
                                "Non-EERS States" = apep_colors["control"])) +
  scale_fill_manual(values = c("EERS States" = apep_colors["treated"],
                               "Non-EERS States" = apep_colors["control"])) +
  labs(
    title = "Mean Per-Capita Residential Electricity Consumption",
    subtitle = "EERS states vs. non-EERS states, with 95% confidence bands",
    x = "Year",
    y = "Per-Capita Consumption (Billion Btu)",
    color = "", fill = ""
  ) +
  scale_x_continuous(breaks = seq(1990, 2023, 5))

ggsave(paste0(fig_dir, "fig3_raw_trends.pdf"), trends_plot,
       width = 9, height = 6, units = "in")

###############################################################################
# PART 3: Callaway-Sant'Anna Estimation
###############################################################################

cat("\n=== CALLAWAY-SANT'ANNA ESTIMATION ===\n\n")

# Prepare data for CS
cs_data <- panel %>%
  filter(!is.na(log_res_elec_pc)) %>%
  mutate(
    # CS requires first_treat = 0 for never-treated
    first_treat = ifelse(eers_year == 0, 0L, as.integer(eers_year))
  )

cat("CS data: ", n_distinct(cs_data$state_abbr), " states, ",
    n_distinct(cs_data$year), " years\n")
cat("Treated states: ", sum(cs_data$first_treat > 0) / n_distinct(cs_data$year), "\n")
cat("Never-treated: ", sum(cs_data$first_treat == 0) / n_distinct(cs_data$year), "\n")

# Main CS estimation: Log per-capita residential electricity
# Note: bstrap = TRUE enables cluster bootstrap for inference
# This addresses reviewer concerns about inference with 51 state clusters
cs_result <- att_gt(
  yname = "log_res_elec_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = cs_data,
  control_group = "nevertreated",
  est_method = "dr",       # Doubly robust
  base_period = "universal", # Universal base period
  bstrap = TRUE,           # ADDED: Cluster bootstrap for robust inference
  cband = TRUE,            # ADDED: Compute uniform confidence bands
  biters = 1000            # ADDED: Number of bootstrap iterations (AER standard)
)

cat("\nCS ATT(g,t) summary:\n")
summary(cs_result)

# Save CS result
saveRDS(cs_result, paste0(data_dir, "cs_result_main.rds"))

###############################################################################
# PART 3b: Cohort Contribution Diagnostics
# Shows how many cohorts contribute to each event time in the event study
###############################################################################

cat("\n=== COHORT CONTRIBUTION DIAGNOSTICS ===\n")

# Get unique cohorts
cohorts <- cs_data %>%
  filter(first_treat > 0) %>%
  distinct(first_treat) %>%
  pull(first_treat) %>%
  sort()

cat("Number of treatment cohorts:", length(cohorts), "\n")
cat("Cohort years:", paste(cohorts, collapse = ", "), "\n")

# For each event time, count how many cohorts contribute
event_times <- -10:15
cohort_contributions <- data.frame(
  event_time = event_times,
  n_cohorts = sapply(event_times, function(e) {
    # A cohort g contributes to event time e if there exists a year t
    # such that t - g == e and t is in the data range
    max_year <- max(cs_data$year)
    min_year <- min(cs_data$year)
    sum(sapply(cohorts, function(g) {
      t <- g + e
      t >= min_year & t <= max_year
    }))
  })
)

cat("\nCohort contributions by event time:\n")
print(cohort_contributions %>% filter(n_cohorts > 0))

# Save for use in figures
saveRDS(cohort_contributions, paste0(data_dir, "cohort_contributions.rds"))

###############################################################################
# PART 4: Aggregate Treatment Effects
###############################################################################

# Simple ATT (overall)
cs_att <- aggte(cs_result, type = "simple")
cat("\n=== OVERALL ATT ===\n")
summary(cs_att)

# Group-level ATT (by adoption cohort)
cs_group <- aggte(cs_result, type = "group")
cat("\n=== GROUP-LEVEL ATT ===\n")
summary(cs_group)

# Dynamic/event-study ATT
cs_dynamic <- aggte(cs_result, type = "dynamic", min_e = -10, max_e = 15)
cat("\n=== DYNAMIC ATT (Event Study) ===\n")
summary(cs_dynamic)

# Calendar time ATT
cs_calendar <- aggte(cs_result, type = "calendar")
cat("\n=== CALENDAR TIME ATT ===\n")
summary(cs_calendar)

# Save all aggregations
saveRDS(cs_att, paste0(data_dir, "cs_att_simple.rds"))
saveRDS(cs_group, paste0(data_dir, "cs_att_group.rds"))
saveRDS(cs_dynamic, paste0(data_dir, "cs_att_dynamic.rds"))
saveRDS(cs_calendar, paste0(data_dir, "cs_att_calendar.rds"))

###############################################################################
# PART 5: Event Study Plot
###############################################################################

# Extract dynamic coefficients
es_data <- data.frame(
  event_time = cs_dynamic$egt,
  estimate = cs_dynamic$att.egt,
  se = cs_dynamic$se.egt
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    pre_post = ifelse(event_time < 0, "Pre-treatment", "Post-treatment")
  )

es_plot <- ggplot(es_data, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2,
              fill = apep_colors["treated"]) +
  geom_point(aes(color = pre_post), size = 2) +
  geom_line(color = apep_colors["treated"], linewidth = 0.5) +
  scale_color_manual(values = c("Pre-treatment" = "gray50",
                                "Post-treatment" = apep_colors["treated"])) +
  labs(
    title = "Event Study: Effect of EERS on Log Per-Capita Residential Electricity",
    subtitle = "Callaway-Sant'Anna estimator, never-treated control group, 95% CI",
    x = "Years Since EERS Adoption",
    y = "ATT (Log Points)",
    color = ""
  ) +
  scale_x_continuous(breaks = seq(-10, 15, 2)) +
  annotate("text", x = -5, y = min(es_data$ci_lower) * 0.9,
           label = paste0("Overall ATT = ", round(cs_att$overall.att, 4),
                          " (SE = ", round(cs_att$overall.se, 4), ")"),
           hjust = 0, size = 3.5, color = "gray30")

ggsave(paste0(fig_dir, "fig4_event_study.pdf"), es_plot,
       width = 10, height = 6, units = "in")

###############################################################################
# PART 6: TWFE Comparison (for Goodman-Bacon decomposition)
###############################################################################

cat("\n=== TWFE ESTIMATION (for comparison) ===\n")

# Standard TWFE
twfe_main <- feols(
  log_res_elec_pc ~ post | state_id + year,
  data = cs_data,
  cluster = ~state_id
)
cat("\nTWFE result:\n")
summary(twfe_main)

# Sun-Abraham event study
sa_result <- feols(
  log_res_elec_pc ~ sunab(first_treat, year) | state_id + year,
  data = cs_data %>% filter(first_treat != 0 | first_treat == 0),
  cluster = ~state_id
)
cat("\nSun-Abraham result:\n")
summary(sa_result)

# Save TWFE results
saveRDS(twfe_main, paste0(data_dir, "twfe_main.rds"))
saveRDS(sa_result, paste0(data_dir, "sa_result.rds"))

###############################################################################
# PART 7: Goodman-Bacon Decomposition
###############################################################################

cat("\n=== GOODMAN-BACON DECOMPOSITION ===\n")

# Prepare balanced panel for bacon decomposition
bacon_data <- cs_data %>%
  group_by(state_id) %>%
  filter(n() == max(cs_data %>% count(state_id) %>% pull(n))) %>%
  ungroup()

bacon_result <- tryCatch({
  bacon(
    log_res_elec_pc ~ post,
    data = bacon_data,
    id_var = "state_id",
    time_var = "year"
  )
}, error = function(e) {
  cat("Bacon decomposition failed:", e$message, "\n")
  NULL
})

if (!is.null(bacon_result)) {
  saveRDS(bacon_result, paste0(data_dir, "bacon_result.rds"))

  # Bacon decomposition plot
  bacon_plot <- ggplot(bacon_result, aes(x = weight, y = estimate, color = type)) +
    geom_point(size = 3, alpha = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    labs(
      title = "Goodman-Bacon Decomposition of TWFE Estimate",
      subtitle = "Each point is a 2x2 DiD comparison; size proportional to weight",
      x = "Weight",
      y = "Estimate",
      color = "Comparison Type"
    ) +
    theme(legend.position = "bottom")

  ggsave(paste0(fig_dir, "fig5_bacon_decomposition.pdf"), bacon_plot,
         width = 9, height = 6, units = "in")
}

###############################################################################
# PART 8: Summary of Main Results
###############################################################################

cat("\n\n========================================\n")
cat("MAIN RESULTS SUMMARY\n")
cat("========================================\n\n")

cat("1. CS Overall ATT:", round(cs_att$overall.att, 4),
    " (SE:", round(cs_att$overall.se, 4), ")\n")
cat("   Interpretation: EERS adoption is associated with a",
    round(cs_att$overall.att * 100, 2),
    "% change in per-capita residential electricity consumption\n\n")

cat("2. TWFE coefficient:", round(coef(twfe_main)["post"], 4),
    " (SE:", round(se(twfe_main)["post"], 4), ")\n\n")

cat("3. Number of treated states:", n_distinct(cs_data$state_abbr[cs_data$first_treat > 0]), "\n")
cat("4. Number of never-treated states:", n_distinct(cs_data$state_abbr[cs_data$first_treat == 0]), "\n")
cat("5. Total state-year observations:", nrow(cs_data), "\n")
cat("========================================\n")

###############################################################################
# PART 9: Treatment Intensity Analysis (DSM Expenditures)
#
# This extends the binary treatment to a continuous dose-response analysis
# using DSM (demand-side management) expenditure data as treatment intensity.
###############################################################################

cat("\n=== TREATMENT INTENSITY ANALYSIS ===\n")

# Check if DSM data is available
dsm_file <- paste0(data_dir, "dsm_expenditures.rds")

if (file.exists(dsm_file)) {
  dsm_data <- readRDS(dsm_file)

  # Merge DSM expenditures with panel
  panel_intensity <- panel %>%
    left_join(
      dsm_data %>% select(state_abbr, year, dsm_cost_thousands, dsm_quartile, dsm_high),
      by = c("state_abbr", "year")
    ) %>%
    filter(!is.na(log_res_elec_pc), !is.na(dsm_cost_thousands))

  cat("Panel with DSM intensity:", nrow(panel_intensity), "observations\n")

  # Create normalized DSM intensity (per million population)
  panel_intensity <- panel_intensity %>%
    mutate(
      dsm_intensity = dsm_cost_thousands / (population / 1e6),  # $/million pop
      log_dsm_intensity = log(dsm_intensity + 1)
    )

  # TWFE with continuous treatment intensity
  cat("\nTWFE with Continuous DSM Intensity:\n")
  twfe_intensity <- feols(
    log_res_elec_pc ~ log_dsm_intensity | state_id + year,
    data = panel_intensity,
    cluster = ~state_id
  )

  cat("  Coefficient on log(DSM intensity):", round(coef(twfe_intensity)["log_dsm_intensity"], 4),
      " (SE:", round(se(twfe_intensity)["log_dsm_intensity"], 4), ")\n")
  cat("  Interpretation: 10% increase in DSM spending is associated with",
      round(coef(twfe_intensity)["log_dsm_intensity"] * 0.1 * 100, 3),
      "% change in consumption\n")

  saveRDS(twfe_intensity, paste0(data_dir, "twfe_intensity.rds"))

  # TWFE comparing high vs low DSM spending (quartile-based)
  cat("\nTWFE with DSM Quartiles (High vs Low Spending):\n")
  twfe_quartile <- feols(
    log_res_elec_pc ~ dsm_high | state_id + year,
    data = panel_intensity,
    cluster = ~state_id
  )

  cat("  Coefficient (High DSM vs Low):", round(coef(twfe_quartile)["dsm_high"], 4),
      " (SE:", round(se(twfe_quartile)["dsm_high"], 4), ")\n")

  saveRDS(twfe_quartile, paste0(data_dir, "twfe_dsm_quartile.rds"))

  # Dose-response plot: consumption by DSM quartile
  dose_response <- panel_intensity %>%
    filter(year >= 2005) %>%  # Focus on years with DSM data
    group_by(dsm_quartile, year) %>%
    summarise(
      mean_consumption = mean(res_elec_pc, na.rm = TRUE),
      se = sd(res_elec_pc, na.rm = TRUE) / sqrt(n()),
      .groups = "drop"
    )

  dose_plot <- ggplot(dose_response, aes(x = year, y = mean_consumption,
                                          color = factor(dsm_quartile))) +
    geom_line(linewidth = 1) +
    geom_ribbon(aes(ymin = mean_consumption - 1.96*se, ymax = mean_consumption + 1.96*se,
                    fill = factor(dsm_quartile)), alpha = 0.1, color = NA) +
    scale_color_viridis_d(option = "plasma", end = 0.8,
                          labels = c("Q1 (Lowest)", "Q2", "Q3", "Q4 (Highest)")) +
    scale_fill_viridis_d(option = "plasma", end = 0.8,
                         labels = c("Q1 (Lowest)", "Q2", "Q3", "Q4 (Highest)")) +
    labs(
      title = "Per-Capita Residential Electricity by DSM Spending Quartile",
      subtitle = "States grouped by annual DSM expenditure intensity",
      x = "Year",
      y = "Per-Capita Consumption (Billion Btu)",
      color = "DSM Spending\nQuartile",
      fill = "DSM Spending\nQuartile"
    )

  ggsave(paste0(fig_dir, "fig8_dose_response.pdf"), dose_plot,
         width = 9, height = 6, units = "in")

  cat("\nTreatment intensity analysis complete.\n")

} else {
  cat("DSM expenditure data not found. Run 01e_fetch_dsm.R first.\n")
}

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
