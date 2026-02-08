# =============================================================================
# 04b_medicare_placebo.R - Medicare Placebo Test
# Paper 59: State Insulin Price Caps and Diabetes Management Outcomes
# State caps don't affect Medicare (federal program) - use as placebo
# =============================================================================

source("output/paper_59/code/00_packages.R")

library(haven)

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("MEDICARE PLACEBO TEST\n")
cat("State insulin caps should NOT affect Medicare beneficiaries\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# =============================================================================
# Load Individual-Level Data
# =============================================================================

brfss_diabetes <- readRDS("output/paper_59/data/brfss_diabetes.rds")
treatment_df <- readRDS("output/paper_59/data/treatment_assignment.rds")

cat(sprintf("Diabetic sample: %d observations\n", nrow(brfss_diabetes)))

# =============================================================================
# Identify Medicare Population (65+)
# =============================================================================

# Age group: 12-13 corresponds to 65+ in BRFSS _AGEG5YR variable
if ("age_group" %in% names(brfss_diabetes)) {
  brfss_diabetes <- brfss_diabetes %>%
    mutate(
      is_medicare_age = ifelse(age_group %in% c(12, 13), 1, 0),
      is_under_65 = ifelse(age_group %in% 1:11, 1, 0)
    )

  cat("\nAge distribution in diabetic sample:\n")
  table(brfss_diabetes$age_group_clean, useNA = "ifany") %>% print()

  cat("\nMedicare-age (65+) vs Under-65:\n")
  cat(sprintf("  65+ (Medicare-eligible): %d (%.1f%%)\n",
              sum(brfss_diabetes$is_medicare_age == 1, na.rm = TRUE),
              100 * mean(brfss_diabetes$is_medicare_age == 1, na.rm = TRUE)))
  cat(sprintf("  Under 65: %d (%.1f%%)\n",
              sum(brfss_diabetes$is_under_65 == 1, na.rm = TRUE),
              100 * mean(brfss_diabetes$is_under_65 == 1, na.rm = TRUE)))
} else {
  cat("Warning: age_group variable not found. Cannot run Medicare placebo.\n")
  quit(save = "no", status = 0)
}

# =============================================================================
# Create Separate State-Year Panels by Age Group
# =============================================================================

# Medicare-age population (65+) - PLACEBO GROUP
# State caps should NOT affect this group
medicare_panel <- brfss_diabetes %>%
  filter(is_medicare_age == 1) %>%
  group_by(state_fips, year, treatment_year, first_treat, state_abbr) %>%
  summarize(
    insulin_rate = weighted.mean(takes_insulin, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    id = state_fips,
    time = year,
    first_treat_cs = first_treat,
    population = "Medicare (65+)"
  )

# Under-65 population - TREATMENT GROUP
# State caps should affect this group (privately insured subset)
under65_panel <- brfss_diabetes %>%
  filter(is_under_65 == 1) %>%
  group_by(state_fips, year, treatment_year, first_treat, state_abbr) %>%
  summarize(
    insulin_rate = weighted.mean(takes_insulin, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    id = state_fips,
    time = year,
    first_treat_cs = first_treat,
    population = "Under 65"
  )

cat(sprintf("\nMedicare-age panel: %d state-years\n", nrow(medicare_panel)))
cat(sprintf("Under-65 panel: %d state-years\n", nrow(under65_panel)))

# =============================================================================
# Run CS Estimator on Medicare Population (Placebo)
# =============================================================================

cat("\n")
cat(rep("-", 50) %>% paste0(collapse = ""), "\n")
cat("PLACEBO: Medicare-Age Population (65+)\n")
cat("Expected: NULL effect (state caps don't affect Medicare)\n")
cat(rep("-", 50) %>% paste0(collapse = ""), "\n\n")

cs_medicare <- tryCatch({
  att_gt(
    yname = "insulin_rate",
    tname = "time",
    idname = "id",
    gname = "first_treat_cs",
    data = medicare_panel %>% filter(!is.na(insulin_rate)),
    control_group = "notyettreated",
    est_method = "reg",
    base_period = "universal",
    clustervars = "id",
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat("Error in CS estimation for Medicare:", e$message, "\n")
  return(NULL)
})

if (!is.null(cs_medicare)) {
  agg_medicare <- aggte(cs_medicare, type = "simple", na.rm = TRUE)
  cat("Medicare Placebo ATT:\n")
  print(summary(agg_medicare))

  medicare_att <- agg_medicare$overall.att
  medicare_se <- agg_medicare$overall.se
  medicare_ci_low <- medicare_att - 1.96 * medicare_se
  medicare_ci_high <- medicare_att + 1.96 * medicare_se

  cat(sprintf("\nMedicare Placebo: ATT = %.4f (SE = %.4f)\n", medicare_att, medicare_se))
  cat(sprintf("95%% CI: [%.4f, %.4f]\n", medicare_ci_low, medicare_ci_high))

  if (medicare_ci_low <= 0 & medicare_ci_high >= 0) {
    cat("\nPLACEBO PASSES: Cannot reject null effect for Medicare population.\n")
    placebo_pass <- TRUE
  } else {
    cat("\nPLACEBO FAILS: Significant effect detected for Medicare (should be null).\n")
    cat("This suggests confounding or model misspecification.\n")
    placebo_pass <- FALSE
  }
}

# =============================================================================
# Run CS Estimator on Under-65 Population
# =============================================================================

cat("\n")
cat(rep("-", 50) %>% paste0(collapse = ""), "\n")
cat("TREATMENT GROUP: Under-65 Population\n")
cat("Expected: Positive effect (if policy works)\n")
cat(rep("-", 50) %>% paste0(collapse = ""), "\n\n")

cs_under65 <- tryCatch({
  att_gt(
    yname = "insulin_rate",
    tname = "time",
    idname = "id",
    gname = "first_treat_cs",
    data = under65_panel %>% filter(!is.na(insulin_rate)),
    control_group = "notyettreated",
    est_method = "reg",
    base_period = "universal",
    clustervars = "id",
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat("Error in CS estimation for Under-65:", e$message, "\n")
  return(NULL)
})

if (!is.null(cs_under65)) {
  agg_under65 <- aggte(cs_under65, type = "simple", na.rm = TRUE)
  cat("Under-65 ATT:\n")
  print(summary(agg_under65))

  under65_att <- agg_under65$overall.att
  under65_se <- agg_under65$overall.se

  cat(sprintf("\nUnder-65: ATT = %.4f (SE = %.4f)\n", under65_att, under65_se))
}

# =============================================================================
# Event Study Comparison Plot
# =============================================================================

cat("\n\nGenerating comparison event study plot...\n")

# Get event studies for both populations
get_event_study_df <- function(cs_result, pop_name) {
  agg <- tryCatch({
    aggte(cs_result, type = "dynamic", min_e = -2, max_e = 2, na.rm = TRUE)
  }, error = function(e) NULL)

  if (!is.null(agg)) {
    data.frame(
      event_time = agg$egt,
      att = agg$att.egt,
      se = agg$se.egt,
      population = pop_name
    ) %>%
      mutate(
        ci_lower = att - 1.96 * se,
        ci_upper = att + 1.96 * se
      )
  } else {
    NULL
  }
}

es_medicare <- get_event_study_df(cs_medicare, "Medicare (65+) - Placebo")
es_under65 <- get_event_study_df(cs_under65, "Under 65 - Treatment")

if (!is.null(es_medicare) && !is.null(es_under65)) {
  es_combined <- bind_rows(es_medicare, es_under65)

  p_placebo <- ggplot(es_combined, aes(x = event_time, y = att,
                                        color = population, fill = population)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, color = NA) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c(apep_colors[3], apep_colors[1]), name = "") +
    scale_fill_manual(values = c(apep_colors[3], apep_colors[1]), name = "") +
    scale_x_continuous(breaks = seq(-3, 3, 1)) +
    labs(
      title = "Medicare Placebo Test: Event Study Comparison",
      subtitle = "State insulin caps should not affect Medicare (federal program)",
      x = "Years Relative to Treatment",
      y = "ATT (Insulin Use Rate)",
      caption = "Note: Medicare population (65+) serves as placebo. Caps apply to state-regulated plans, not Medicare."
    ) +
    theme_apep() +
    theme(legend.position = "bottom")

  ggsave("output/paper_59/figures/medicare_placebo.pdf", p_placebo, width = 9, height = 6)
  cat("  Saved: figures/medicare_placebo.pdf\n")
}

# =============================================================================
# Summary Table
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("PLACEBO TEST SUMMARY\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

summary_table <- data.frame(
  Population = c("Under 65 (Treatment)", "65+ (Medicare Placebo)"),
  ATT = c(
    ifelse(exists("under65_att"), sprintf("%.4f", under65_att), "NA"),
    ifelse(exists("medicare_att"), sprintf("%.4f", medicare_att), "NA")
  ),
  SE = c(
    ifelse(exists("under65_se"), sprintf("%.4f", under65_se), "NA"),
    ifelse(exists("medicare_se"), sprintf("%.4f", medicare_se), "NA")
  ),
  CI_95 = c(
    ifelse(exists("under65_att"),
           sprintf("[%.4f, %.4f]", under65_att - 1.96 * under65_se, under65_att + 1.96 * under65_se),
           "NA"),
    ifelse(exists("medicare_att"),
           sprintf("[%.4f, %.4f]", medicare_ci_low, medicare_ci_high),
           "NA")
  )
)

print(summary_table)

cat("\n")
if (exists("placebo_pass")) {
  if (placebo_pass) {
    cat("INTERPRETATION: Placebo test PASSES - no significant effect on Medicare.\n")
    cat("This is consistent with the identifying assumption that state caps\n")
    cat("affect only state-regulated private plans, not Medicare.\n")
  } else {
    cat("INTERPRETATION: Placebo test FAILS - significant effect detected on Medicare.\n")
    cat("This casts doubt on the identification strategy and suggests\n")
    cat("confounding factors affecting both populations.\n")
  }
}

# =============================================================================
# Save Results
# =============================================================================

placebo_results <- list(
  medicare_panel = medicare_panel,
  under65_panel = under65_panel,
  cs_medicare = cs_medicare,
  cs_under65 = cs_under65,
  es_medicare = es_medicare,
  es_under65 = es_under65,
  placebo_pass = if(exists("placebo_pass")) placebo_pass else NA
)

saveRDS(placebo_results, "output/paper_59/data/placebo_results.rds")
cat("\nResults saved to data/placebo_results.rds\n")

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("MEDICARE PLACEBO TEST COMPLETE\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
