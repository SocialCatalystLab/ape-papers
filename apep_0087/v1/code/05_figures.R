# ==============================================================================
# 05_figures.R - Generate All Figures
# Paper 110: Automation Exposure and Older Worker Labor Force Exit
# ==============================================================================

source("00_packages.R")

message("\n=== Loading Data and Results ===")

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ==============================================================================
# Figure 1: Distribution of Automation Exposure
# ==============================================================================

message("\n=== Creating Figure 1: Automation Exposure Distribution ===")

fig1 <- ggplot(df, aes(x = automation_exposure)) +
  geom_histogram(aes(weight = PWGTP), bins = 30,
                 fill = cb_palette[1], color = "white", alpha = 0.8) +
  geom_vline(xintercept = c(0.40, 0.55),
             linetype = "dashed", color = cb_palette[2], linewidth = 0.8) +
  labs(
    title = "Distribution of Occupational Automation Exposure",
    subtitle = "Vertical lines indicate category cutoffs (0.40 and 0.55)",
    x = "Automation Exposure Index (0 = Low, 1 = High)",
    y = "Weighted Count"
  ) +
  scale_x_continuous(breaks = seq(0, 1, 0.2)) +
  scale_y_continuous(labels = scales::comma)

ggsave(file.path(fig_dir, "fig1_automation_distribution.pdf"), 
       fig1, width = 8, height = 5)
message("Saved: fig1_automation_distribution.pdf")

# ==============================================================================
# Figure 2: Labor Force Exit by Automation Exposure and Education
# ==============================================================================

message("\n=== Creating Figure 2: Exit Rate by Automation and Education ===")

exit_by_auto_edu <- df %>%
  group_by(automation_tercile, education) %>%
  summarise(
    exit_rate = weighted.mean(not_in_labor_force, w = PWGTP),
    se = sqrt(weighted.mean(not_in_labor_force, w = PWGTP) * 
              (1 - weighted.mean(not_in_labor_force, w = PWGTP)) / sum(PWGTP)),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    automation_label = factor(automation_tercile, 
                              labels = c("Low", "Medium", "High")),
    ci_lower = exit_rate - 1.96 * se,
    ci_upper = exit_rate + 1.96 * se
  )

fig2 <- ggplot(exit_by_auto_edu, aes(x = automation_label, y = exit_rate, 
                                      fill = education)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), 
           width = 0.7, alpha = 0.8) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                position = position_dodge(width = 0.8), width = 0.2) +
  labs(
    title = "Labor Force Exit Rate by Automation Exposure and Education",
    subtitle = "Workers aged 55-70, weighted by survey weights",
    x = "Automation Exposure Category",
    y = "Probability of Not in Labor Force",
    fill = "Education"
  ) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.5)) +
  scale_fill_manual(values = cb_palette[1:5]) +
  theme(legend.position = "right")

ggsave(file.path(fig_dir, "fig2_exit_by_automation_education.pdf"), 
       fig2, width = 10, height = 6)
message("Saved: fig2_exit_by_automation_education.pdf")

# ==============================================================================
# Figure 3: Heterogeneous Effects by Education (Forest Plot)
# ==============================================================================

message("\n=== Creating Figure 3: Heterogeneous Effects Forest Plot ===")

# Combine heterogeneity results
het_combined <- bind_rows(
  main_results$heterogeneity$by_education %>%
    mutate(category = "Education"),
  main_results$heterogeneity$by_age %>%
    mutate(category = "Age Group"),
  main_results$heterogeneity$by_sex %>%
    mutate(category = "Sex")
) %>%
  filter(!is.na(ate)) %>%
  mutate(
    ci_lower = ate - 1.96 * se,
    ci_upper = ate + 1.96 * se,
    subgroup = factor(subgroup, levels = rev(unique(subgroup)))
  )

fig3 <- ggplot(het_combined, aes(x = ate, y = subgroup, color = category)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = main_results$aipw$estimate, 
             linetype = "solid", color = cb_palette[1], alpha = 0.5) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2) +
  geom_point(size = 3) +
  facet_wrap(~category, scales = "free_y", ncol = 1) +
  labs(
    title = "Heterogeneous Effects of Automation Exposure on Labor Force Exit",
    subtitle = "Point estimates and 95% CIs from AIPW; vertical line = overall effect",
    x = "Effect on Probability of Not in Labor Force",
    y = ""
  ) +
  scale_color_manual(values = cb_palette[c(1, 2, 3)], guide = "none") +
  scale_x_continuous(labels = scales::percent) +
  theme(strip.text = element_text(face = "bold"))

ggsave(file.path(fig_dir, "fig3_heterogeneous_effects.pdf"), 
       fig3, width = 8, height = 8)
message("Saved: fig3_heterogeneous_effects.pdf")

# ==============================================================================
# Figure 4: Propensity Score Overlap
# ==============================================================================

message("\n=== Creating Figure 4: Propensity Score Overlap ===")

# Calculate propensity scores using logistic regression
df_ps <- df %>%
  select(high_automation, AGEP, age_squared, SEX, education, 
         race_ethnicity, married, has_disability, log_income) %>%
  drop_na() %>%
  mutate(across(where(is.factor), as.numeric))

ps_model <- glm(high_automation ~ ., data = df_ps, family = binomial)
df_ps$propensity_score <- predict(ps_model, type = "response")
df_ps$treatment_label <- ifelse(df_ps$high_automation == 1, 
                                 "High Automation", "Low/Medium Automation")

fig4 <- ggplot(df_ps, aes(x = propensity_score, fill = treatment_label)) +
  geom_density(alpha = 0.6) +
  labs(
    title = "Propensity Score Distributions by Treatment Status",
    subtitle = "Overlap indicates covariate balance achievable through weighting",
    x = "Propensity Score (Probability of High Automation Exposure)",
    y = "Density",
    fill = "Treatment Group"
  ) +
  scale_fill_manual(values = cb_palette[c(1, 2)]) +
  theme(legend.position = c(0.8, 0.8))

ggsave(file.path(fig_dir, "fig4_propensity_overlap.pdf"), 
       fig4, width = 8, height = 5)
message("Saved: fig4_propensity_overlap.pdf")

# ==============================================================================
# Figure 5: Robustness Across Specifications
# ==============================================================================

message("\n=== Creating Figure 5: Robustness Summary ===")

# Create robustness summary dataframe
robustness_summary <- tribble(
  ~specification, ~estimate, ~se, ~category,
  "Main (OLS)", main_results$ols$estimate, main_results$ols$se, "Main",
  "AIPW", main_results$aipw$estimate, main_results$aipw$se, "Main",
  "Continuous Treatment", robustness_results$alternative_treatments$continuous$estimate, 
    robustness_results$alternative_treatments$continuous$se, "Treatment",
  "Top vs Bottom Tercile", robustness_results$alternative_treatments$tercile$estimate,
    robustness_results$alternative_treatments$tercile$se, "Treatment",
  "With Industry FE", robustness_results$fixed_effects$industry$estimate,
    robustness_results$fixed_effects$industry$se, "Controls",
  "With State FE", robustness_results$fixed_effects$state$estimate,
    robustness_results$fixed_effects$state$se, "Controls",
  "Excluding Disability", robustness_results$subsamples$no_disability, NA, "Sample",
  "Men Only", robustness_results$subsamples$men, NA, "Sample",
  "Women Only", robustness_results$subsamples$women, NA, "Sample"
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    specification = factor(specification, levels = rev(specification))
  )

fig5 <- ggplot(robustness_summary, aes(x = estimate, y = specification, color = category)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = main_results$aipw$estimate, 
             linetype = "dotted", color = cb_palette[1], linewidth = 1) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, na.rm = TRUE) +
  geom_point(size = 3) +
  labs(
    title = "Robustness of Main Effect Across Specifications",
    subtitle = "Dotted line = preferred AIPW estimate",
    x = "Effect on Probability of Not in Labor Force",
    y = "",
    color = "Specification Type"
  ) +
  scale_color_manual(values = cb_palette[c(1, 2, 3, 4)]) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig5_robustness_summary.pdf"), 
       fig5, width = 9, height = 7)
message("Saved: fig5_robustness_summary.pdf")

# ==============================================================================
# Figure 6: Labor Force Exit by Age and Automation
# ==============================================================================

message("\n=== Creating Figure 6: Age Profile by Automation ===")

age_profile <- df %>%
  group_by(AGEP, high_automation) %>%
  summarise(
    exit_rate = weighted.mean(not_in_labor_force, w = PWGTP),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    automation_label = ifelse(high_automation == 1, 
                               "High Automation", "Low/Medium Automation")
  )

fig6 <- ggplot(age_profile, aes(x = AGEP, y = exit_rate, 
                                 color = automation_label, linetype = automation_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2, alpha = 0.6) +
  labs(
    title = "Labor Force Exit Rate by Age and Automation Exposure",
    subtitle = "Workers aged 55-70; gap widens with age",
    x = "Age",
    y = "Probability of Not in Labor Force",
    color = "Automation Exposure",
    linetype = "Automation Exposure"
  ) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.6)) +
  scale_color_manual(values = cb_palette[c(1, 3)]) +
  theme(legend.position = c(0.2, 0.85))

ggsave(file.path(fig_dir, "fig6_age_profile.pdf"), 
       fig6, width = 8, height = 5)
message("Saved: fig6_age_profile.pdf")

# ==============================================================================
# Summary
# ==============================================================================

message("\n=== Figures Complete ===")
message("Generated 6 figures in ", fig_dir)

# List all figures
list.files(fig_dir, pattern = "\\.pdf$")
