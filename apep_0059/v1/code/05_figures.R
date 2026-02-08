# =============================================================================
# 05_figures.R
# Generate publication-ready figures
# =============================================================================

source("00_packages.R")

# Load data and results
df <- readRDS(file.path(data_dir, "pums_clean.rds"))
results <- readRDS(file.path(data_dir, "aipw_results.rds"))
results_df <- readRDS(file.path(data_dir, "aipw_results_df.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# =============================================================================
# Figure 1: Propensity Score Overlap
# =============================================================================

cat("Creating Figure 1: Propensity Score Overlap...\n")

# Extract propensity scores
ps <- results$any_insurance$aipw_obj$obs_est$ps_hat
ps_df <- tibble(
  ps = ps,
  group = ifelse(df$self_employed == 1, "Self-Employed", "Wage Workers")
)

p1 <- ggplot(ps_df, aes(x = ps, fill = group)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50,
                 alpha = 0.6, position = "identity") +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[1]),
                    name = "") +
  geom_vline(xintercept = c(0.02, 0.98), linetype = "dashed",
             color = "grey40", linewidth = 0.5) +
  annotate("text", x = 0.5, y = Inf, vjust = 1.5,
           label = sprintf("Self-employed: %.1f%%", 100*mean(df$self_employed)),
           size = 3.5, fontface = "italic") +
  labs(
    title = "Propensity Score Distributions by Treatment Status",
    subtitle = "Dashed lines indicate trimming thresholds (0.02, 0.98)",
    x = "Propensity Score (Probability of Self-Employment)",
    y = "Density",
    caption = "Note: Propensity scores estimated using SuperLearner ensemble."
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.85))

ggsave(file.path(fig_dir, "fig1_propensity_overlap.pdf"), p1,
       width = 8, height = 5)

# =============================================================================
# Figure 2: Main Results Forest Plot
# =============================================================================

cat("Creating Figure 2: Main Results Forest Plot...\n")

# Prepare data for forest plot
results_plot <- results_df %>%
  mutate(
    Outcome = factor(Outcome, levels = rev(c(
      "any_insurance", "private_coverage", "public_coverage",
      "employer_insurance", "direct_purchase", "medicaid"
    ))),
    Outcome_Label = case_when(
      Outcome == "any_insurance" ~ "Any Health Insurance",
      Outcome == "private_coverage" ~ "Private Coverage",
      Outcome == "public_coverage" ~ "Public Coverage",
      Outcome == "employer_insurance" ~ "Employer-Sponsored",
      Outcome == "direct_purchase" ~ "Direct Purchase/Marketplace",
      Outcome == "medicaid" ~ "Medicaid"
    ),
    Outcome_Label = factor(Outcome_Label, levels = rev(c(
      "Any Health Insurance", "Private Coverage", "Public Coverage",
      "Employer-Sponsored", "Direct Purchase/Marketplace", "Medicaid"
    ))),
    significant = P_Value < 0.05
  )

p2 <- ggplot(results_plot, aes(x = ATT, y = Outcome_Label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper),
                 height = 0.2, color = "grey40") +
  geom_point(aes(color = significant), size = 3) +
  scale_color_manual(values = c("TRUE" = apep_colors[1], "FALSE" = "grey60"),
                     guide = "none") +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Effect of Self-Employment on Health Insurance Coverage",
    subtitle = "AIPW estimates with 95% confidence intervals (ATT)",
    x = "Effect on Coverage Rate (Percentage Points)",
    y = "",
    caption = "Note: Filled points indicate p < 0.05. Standard errors are influence-function based."
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 10))

ggsave(file.path(fig_dir, "fig2_main_results_forest.pdf"), p2,
       width = 8, height = 5)

# =============================================================================
# Figure 3: Insurance Coverage by Self-Employment Status
# =============================================================================

cat("Creating Figure 3: Descriptive Comparison...\n")

# Calculate weighted means by group
coverage_by_group <- df %>%
  group_by(self_employed) %>%
  summarise(
    `Any Insurance` = weighted.mean(any_insurance, PWGTP),
    `Employer-Sponsored` = weighted.mean(employer_insurance, PWGTP),
    `Direct Purchase` = weighted.mean(direct_purchase, PWGTP),
    `Medicaid` = weighted.mean(medicaid, PWGTP),
    .groups = "drop"
  ) %>%
  mutate(Group = ifelse(self_employed == 1, "Self-Employed", "Wage Workers")) %>%
  pivot_longer(cols = -c(self_employed, Group),
               names_to = "Coverage_Type", values_to = "Rate")

p3 <- ggplot(coverage_by_group, aes(x = Coverage_Type, y = Rate, fill = Group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[2]), name = "") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1)) +
  labs(
    title = "Health Insurance Coverage by Employment Type",
    subtitle = "Weighted proportions, ACS 2018-2022",
    x = "",
    y = "Coverage Rate",
    caption = "Note: Sample restricted to employed civilians age 25-64."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

ggsave(file.path(fig_dir, "fig3_coverage_by_group.pdf"), p3,
       width = 8, height = 5)

# =============================================================================
# Figure 4: Subgroup Heterogeneity
# =============================================================================

cat("Creating Figure 4: Subgroup Heterogeneity...\n")

subgroup_plot <- robustness$subgroup %>%
  filter(outcome == "any_insurance") %>%
  mutate(
    subgroup = factor(subgroup, levels = rev(c(
      "Medicaid Expansion States", "Non-Expansion States",
      "Low Income (Q1-Q2)", "High Income (Q4-Q5)",
      "Married (Spouse Present)", "Not Married"
    )))
  )

p4 <- ggplot(subgroup_plot, aes(x = att, y = subgroup)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = results_df$ATT[results_df$Outcome == "any_insurance"],
             linetype = "dotted", color = apep_colors[1], linewidth = 0.8) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, color = "grey40") +
  geom_point(color = apep_colors[1], size = 3) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Heterogeneous Effects by Subgroup",
    subtitle = "Effect on any health insurance coverage (ATT)",
    x = "Effect on Coverage Rate (Percentage Points)",
    y = "",
    caption = "Note: Dotted vertical line shows overall sample estimate."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_subgroup_heterogeneity.pdf"), p4,
       width = 8, height = 5)

# =============================================================================
# Figure 5: Sensitivity Analysis (E-values)
# =============================================================================

cat("Creating Figure 5: Sensitivity Analysis...\n")

evalue_plot <- robustness$evalues %>%
  filter(!is.na(e_value_point)) %>%
  mutate(
    outcome_label = case_when(
      outcome == "any_insurance" ~ "Any Insurance",
      outcome == "employer_insurance" ~ "Employer-Sponsored",
      outcome == "direct_purchase" ~ "Direct Purchase",
      outcome == "medicaid" ~ "Medicaid",
      TRUE ~ outcome
    )
  )

p5 <- ggplot(evalue_plot, aes(x = outcome_label)) +
  geom_col(aes(y = e_value_point), fill = apep_colors[1], alpha = 0.7, width = 0.6) +
  geom_errorbar(aes(ymin = e_value_ci, ymax = e_value_point),
                width = 0.2, color = "grey30") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey50") +
  geom_hline(yintercept = 2, linetype = "dotted", color = apep_colors[2]) +
  annotate("text", x = 0.5, y = 2.1, label = "Strong confounding threshold",
           hjust = 0, size = 3, color = apep_colors[2]) +
  labs(
    title = "Sensitivity to Unmeasured Confounding: E-Values",
    subtitle = "Minimum strength of confounding needed to explain away effects",
    x = "",
    y = "E-Value",
    caption = "Note: E-value indicates how strong an unmeasured confounder would need to be\nto nullify the observed effect. Values > 2 suggest robust findings."
  ) +
  theme_apep() +
  coord_flip()

ggsave(file.path(fig_dir, "fig5_sensitivity_evalues.pdf"), p5,
       width = 8, height = 5)

# =============================================================================
# Figure 6: Covariate Balance
# =============================================================================

cat("Creating Figure 6: Covariate Balance...\n")

# Calculate standardized mean differences
covariates_for_balance <- c("age", "female", "married", "hours_worked", "household_size")

balance_df <- tibble()
for (var in covariates_for_balance) {
  smd_raw <- smd(df[[var]], df$self_employed)
  balance_df <- bind_rows(balance_df, tibble(
    variable = var,
    smd = smd_raw
  ))
}

# Add categorical variables (just take first level difference)
balance_df <- bind_rows(balance_df, tibble(
  variable = c("educ_ba_plus", "race_white"),
  smd = c(
    smd(as.numeric(df$educ %in% c("Bachelor's", "Graduate")), df$self_employed),
    smd(as.numeric(df$race == "White"), df$self_employed)
  )
))

balance_df <- balance_df %>%
  mutate(
    variable_label = case_when(
      variable == "age" ~ "Age",
      variable == "female" ~ "Female",
      variable == "married" ~ "Married",
      variable == "hours_worked" ~ "Hours Worked",
      variable == "household_size" ~ "Household Size",
      variable == "educ_ba_plus" ~ "BA or Higher",
      variable == "race_white" ~ "White"
    ),
    balanced = abs(smd) < 0.1
  )

p6 <- ggplot(balance_df, aes(x = smd, y = reorder(variable_label, abs(smd)))) +
  geom_vline(xintercept = 0, linetype = "solid", color = "grey30") +
  geom_vline(xintercept = c(-0.1, 0.1), linetype = "dashed", color = "grey60") +
  geom_point(aes(color = balanced), size = 3) +
  scale_color_manual(values = c("TRUE" = apep_colors[3], "FALSE" = apep_colors[2]),
                     labels = c("TRUE" = "Balanced (|SMD| < 0.1)",
                                "FALSE" = "Imbalanced"),
                     name = "") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +
  labs(
    title = "Covariate Balance: Self-Employed vs. Wage Workers",
    subtitle = "Standardized mean differences (unadjusted)",
    x = "Standardized Mean Difference",
    y = "",
    caption = "Note: Dashed lines indicate conventional balance threshold (|SMD| < 0.1)."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_covariate_balance.pdf"), p6,
       width = 8, height = 5)

# =============================================================================
# Summary
# =============================================================================

cat("\n=== Figures Created ===\n")
cat("1. fig1_propensity_overlap.pdf - Propensity score distributions\n")
cat("2. fig2_main_results_forest.pdf - Main effects forest plot\n")
cat("3. fig3_coverage_by_group.pdf - Descriptive comparison\n")
cat("4. fig4_subgroup_heterogeneity.pdf - Heterogeneous effects\n")
cat("5. fig5_sensitivity_evalues.pdf - E-value sensitivity\n")
cat("6. fig6_covariate_balance.pdf - Covariate balance\n")

cat("\nAll figures saved to:", fig_dir, "\n")
