# =============================================================================
# 03_main_analysis.R - Main DiD Analysis
# Paper 59: State Insulin Price Caps and Diabetes Management Outcomes
# =============================================================================

source("output/paper_59/code/00_packages.R")

# =============================================================================
# Load Data
# =============================================================================

state_year <- readRDS("output/paper_59/data/state_year_panel.rds")
brfss_diabetes <- readRDS("output/paper_59/data/brfss_diabetes.rds")

cat("State-year panel dimensions:\n")
cat(sprintf("  Observations: %d\n", nrow(state_year)))
cat(sprintf("  States: %d\n", length(unique(state_year$state_fips))))
cat(sprintf("  Years: %s\n", paste(range(state_year$year), collapse = "-")))

# Treatment distribution
cat("\nTreatment cohorts:\n")
state_year %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat, state_abbr) %>%
  arrange(first_treat) %>%
  print(n = 30)

cat("\nNever-treated states:\n")
state_year %>%
  filter(first_treat == 0) %>%
  distinct(state_fips) %>%
  nrow() %>%
  cat("Count:", ., "\n")

# =============================================================================
# Descriptive Statistics
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("DESCRIPTIVE STATISTICS\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Mean outcomes by treatment status and year
desc_stats <- state_year %>%
  mutate(treatment_group = ifelse(first_treat > 0, "Treated", "Control")) %>%
  group_by(treatment_group, year) %>%
  summarize(
    n_states = n_distinct(state_fips),
    mean_insulin = mean(insulin_rate, na.rm = TRUE),
    mean_a1c = mean(a1c_check_rate, na.rm = TRUE),
    mean_eye_exam = mean(eye_exam_rate, na.rm = TRUE),
    mean_poor_health = mean(poor_health_rate, na.rm = TRUE),
    .groups = "drop"
  )

cat("Outcomes by treatment group and year:\n")
print(desc_stats, n = 20)

# =============================================================================
# Parallel Trends Visualization
# =============================================================================

cat("\n\nGenerating parallel trends plots...\n")

# Aggregate by treatment status and year
trends_data <- state_year %>%
  mutate(treatment_group = ifelse(first_treat > 0, "Treated States", "Never-Treated States")) %>%
  group_by(treatment_group, year) %>%
  summarize(
    insulin_rate = weighted.mean(insulin_rate, total_weight, na.rm = TRUE),
    a1c_check_rate = weighted.mean(a1c_check_rate, total_weight, na.rm = TRUE),
    eye_exam_rate = weighted.mean(eye_exam_rate, total_weight, na.rm = TRUE),
    poor_health_rate = weighted.mean(poor_health_rate, total_weight, na.rm = TRUE),
    .groups = "drop"
  )

# Plot: Insulin Use Rate
p_insulin <- ggplot(trends_data, aes(x = year, y = insulin_rate, color = treatment_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2019.5, linetype = "dashed", color = "grey50", alpha = 0.7) +
  annotate("text", x = 2019.8, y = max(trends_data$insulin_rate, na.rm = TRUE) * 0.95,
           label = "First treatments\n(2020)", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2], name = "") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Insulin Use Rate Among Diabetics",
    subtitle = "Parallel trends: treated vs. never-treated states",
    x = "Year",
    y = "Insulin Use Rate",
    caption = "Source: BRFSS 2019-2022. Weighted means."
  ) +
  theme_apep()

ggsave("output/paper_59/figures/parallel_trends_insulin.pdf", p_insulin, width = 8, height = 5)
cat("  Saved: figures/parallel_trends_insulin.pdf\n")

# Plot: A1C Monitoring Rate
p_a1c <- ggplot(trends_data, aes(x = year, y = a1c_check_rate, color = treatment_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2019.5, linetype = "dashed", color = "grey50", alpha = 0.7) +
  scale_color_manual(values = apep_colors[1:2], name = "") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0.9, 1)) +
  labs(
    title = "A1C Monitoring Rate Among Diabetics",
    subtitle = "Percent with A1C check in past year",
    x = "Year",
    y = "A1C Monitoring Rate",
    caption = "Source: BRFSS 2019-2022. Weighted means."
  ) +
  theme_apep()

ggsave("output/paper_59/figures/parallel_trends_a1c.pdf", p_a1c, width = 8, height = 5)
cat("  Saved: figures/parallel_trends_a1c.pdf\n")

# =============================================================================
# Callaway-Sant'Anna Difference-in-Differences
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("CALLAWAY-SANT'ANNA DiD ESTIMATION\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Prepare data for did package
# Need: panel with id, time, outcome, treatment cohort (0 for never-treated)
did_data <- state_year %>%
  mutate(
    id = state_fips,
    time = year,
    # Callaway-Sant'Anna expects first_treat = 0 for never-treated
    first_treat_cs = first_treat
  ) %>%
  filter(!is.na(insulin_rate))  # Remove missing outcomes

cat(sprintf("DiD sample: %d state-years\n", nrow(did_data)))
cat(sprintf("Treated cohorts: %d\n", length(unique(did_data$first_treat_cs[did_data$first_treat_cs > 0]))))
cat(sprintf("Never-treated states: %d\n", sum(did_data$first_treat_cs == 0) / length(unique(did_data$time))))

# Primary outcome: Insulin Use Rate
cat("\n--- PRIMARY OUTCOME: Insulin Use Rate ---\n\n")

cs_insulin <- tryCatch({
  att_gt(
    yname = "insulin_rate",
    tname = "time",
    idname = "id",
    gname = "first_treat_cs",
    data = did_data,
    control_group = "notyettreated",  # Use not-yet-treated as control (more power)
    est_method = "reg",  # OLS (simple for state-level aggregates)
    base_period = "universal",
    clustervars = "id",
    allow_unbalanced_panel = TRUE  # Allow unbalanced panel
  )
}, error = function(e) {
  cat("Error in CS estimation:", e$message, "\n")
  return(NULL)
})

if (!is.null(cs_insulin)) {
  cat("Group-Time ATT estimates:\n")
  print(summary(cs_insulin))

  # Aggregate to overall ATT
  agg_simple <- aggte(cs_insulin, type = "simple", na.rm = TRUE)
  cat("\n\nOverall ATT (simple aggregation):\n")
  print(summary(agg_simple))

  # Event study aggregation
  agg_dynamic <- tryCatch({
    aggte(cs_insulin, type = "dynamic", min_e = -2, max_e = 2, na.rm = TRUE)
  }, error = function(e) {
    cat("Note: Dynamic aggregation failed -", e$message, "\n")
    NULL
  })

  if (!is.null(agg_dynamic)) {
    cat("\n\nEvent Study (Dynamic ATT):\n")
    print(summary(agg_dynamic))

    # Create event study data frame
    es_df <- data.frame(
      event_time = agg_dynamic$egt,
      att = agg_dynamic$att.egt,
      se = agg_dynamic$se.egt
    ) %>%
      mutate(
        ci_lower = att - 1.96 * se,
        ci_upper = att + 1.96 * se
      )

    # Event study plot
    p_event_insulin <- ggplot(es_df, aes(x = event_time, y = att)) +
      geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                  alpha = 0.2, fill = apep_colors[1]) +
      geom_line(color = apep_colors[1], linewidth = 0.8) +
      geom_point(color = apep_colors[1], size = 2.5) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
      scale_x_continuous(breaks = seq(-3, 3, 1)) +
      labs(
        title = "Event Study: Effect of Insulin Price Caps on Insulin Use",
        subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
        x = "Years Relative to Treatment",
        y = "ATT (Insulin Use Rate)",
        caption = "Note: Reference period is t = -1. Never-treated states as control."
      ) +
      theme_apep()

    ggsave("output/paper_59/figures/event_study_insulin.pdf", p_event_insulin, width = 8, height = 5)
    cat("\n  Saved: figures/event_study_insulin.pdf\n")
  }
}

# Secondary outcome: A1C Monitoring
cat("\n--- SECONDARY OUTCOME: A1C Monitoring Rate ---\n\n")

cs_a1c <- tryCatch({
  att_gt(
    yname = "a1c_check_rate",
    tname = "time",
    idname = "id",
    gname = "first_treat_cs",
    data = did_data,
    control_group = "notyettreated",
    est_method = "reg",
    base_period = "universal",
    clustervars = "id",
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat("Error in CS estimation:", e$message, "\n")
  return(NULL)
})

if (!is.null(cs_a1c)) {
  agg_a1c <- aggte(cs_a1c, type = "simple", na.rm = TRUE)
  cat("Overall ATT for A1C Monitoring:\n")
  print(summary(agg_a1c))
}

# =============================================================================
# Alternative: Two-Way Fixed Effects with Sun-Abraham
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("SUN-ABRAHAM (TWFE with Interaction Weights)\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Sun-Abraham via fixest
# Need to exclude never-treated from the interaction (cohort indicator)
sa_data <- did_data %>%
  mutate(
    cohort = ifelse(first_treat_cs == 0, Inf, first_treat_cs)  # Inf = never-treated
  )

# Insulin rate
sa_insulin <- tryCatch({
  feols(
    insulin_rate ~ sunab(cohort, time) | id + time,
    data = sa_data,
    cluster = ~ id
  )
}, error = function(e) {
  cat("Error in Sun-Abraham estimation:", e$message, "\n")
  return(NULL)
})

if (!is.null(sa_insulin)) {
  cat("Sun-Abraham Event Study (Insulin Use Rate):\n")
  print(summary(sa_insulin))
}

# =============================================================================
# Gardner (2021) Two-Stage DiD
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("GARDNER TWO-STAGE DiD\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# did2s requires specific data structure
d2s_data <- did_data %>%
  rename(
    unit = id,
    g = first_treat_cs
  ) %>%
  mutate(
    # Create treatment indicator
    treat = ifelse(g > 0 & time >= g, 1, 0)
  )

# Check if we have enough variation
cat(sprintf("Treatment variation: %d treated obs, %d control obs\n",
            sum(d2s_data$treat == 1), sum(d2s_data$treat == 0)))

# Two-stage estimation
d2s_insulin <- tryCatch({
  did2s(
    data = d2s_data,
    yname = "insulin_rate",
    first_stage = ~ 0 | unit + time,  # Unit and time FE
    second_stage = ~ i(treat),
    treatment = "treat",
    cluster_var = "unit"
  )
}, error = function(e) {
  cat("Error in did2s estimation:", e$message, "\n")
  return(NULL)
})

if (!is.null(d2s_insulin)) {
  cat("Gardner Two-Stage DiD (Insulin Use Rate):\n")
  print(summary(d2s_insulin))
}

# =============================================================================
# Save Results
# =============================================================================

results <- list(
  cs_insulin = if(exists("cs_insulin")) cs_insulin else NULL,
  cs_a1c = if(exists("cs_a1c")) cs_a1c else NULL,
  sa_insulin = if(exists("sa_insulin")) sa_insulin else NULL,
  d2s_insulin = if(exists("d2s_insulin")) d2s_insulin else NULL,
  desc_stats = desc_stats,
  trends_data = trends_data
)

saveRDS(results, "output/paper_59/data/did_results.rds")
cat("\nResults saved to data/did_results.rds\n")

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
