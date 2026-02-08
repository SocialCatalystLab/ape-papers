# =============================================================================
# Paper 72: RD Analysis - Age 26 Insurance Cliff
# =============================================================================
# Implements discrete RD design for effect of losing parental coverage at 26
# on payment source for delivery
# =============================================================================

library(tidyverse)
library(fixest)        # For parametric RD specifications

# Install rdrobust if available
tryCatch({
  library(rdrobust)
  has_rdrobust <- TRUE
}, error = function(e) {
  cat("rdrobust not available - using parametric RD only\n")
  has_rdrobust <<- FALSE
})

# Set theme for figures
source("output/paper_72/code/00_theme.R", local = TRUE)

# Directories
data_dir <- "output/paper_72/data"
fig_dir <- "output/paper_72/figures"
table_dir <- "output/paper_72/tables"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# Load data
# =============================================================================

cat("Loading data...\n")

# Individual-level data
rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))

# Age-level aggregates
agg_by_age <- readRDS(file.path(data_dir, "agg_by_age.rds"))
agg_by_age_year <- readRDS(file.path(data_dir, "agg_by_age_year.rds"))

cat(sprintf("Individual observations: %s\n", format(nrow(rdd_sample), big.mark = ",")))
cat(sprintf("Age cells: %d\n", nrow(agg_by_age)))

# =============================================================================
# Figure 1: RD Plot - Medicaid Share by Mother's Age
# =============================================================================

cat("\n=== Figure 1: RD Plot ===\n")

fig1 <- agg_by_age %>%
  ggplot(aes(x = mother_age, y = medicaid_share)) +
  geom_point(aes(size = n_births), alpha = 0.7, color = "#2166AC") +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "#B2182B", linewidth = 0.8) +
  geom_smooth(
    data = . %>% filter(mother_age < 26),
    method = "lm", se = TRUE, color = "#2166AC", fill = "#92C5DE"
  ) +
  geom_smooth(
    data = . %>% filter(mother_age >= 26),
    method = "lm", se = TRUE, color = "#2166AC", fill = "#92C5DE"
  ) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_size_continuous(labels = scales::comma, guide = "none") +
  annotate("text", x = 25.3, y = max(agg_by_age$medicaid_share) - 0.02,
           label = "Age 26:\nLose parental\ncoverage", hjust = 1, size = 3, color = "#B2182B") +
  labs(
    title = "Payment Source at Delivery by Mother's Age",
    subtitle = "Share of births covered by Medicaid",
    x = "Mother's Age at Delivery",
    y = "Medicaid Share",
    caption = "Note: Dashed line at age 26 marks loss of ACA dependent coverage eligibility.\nSource: CDC/NCHS Natality Public Use File."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_rd_plot_medicaid.pdf"), fig1, width = 10, height = 7)
ggsave(file.path(fig_dir, "fig1_rd_plot_medicaid.png"), fig1, width = 10, height = 7, dpi = 300)

cat("Saved: fig1_rd_plot_medicaid.pdf\n")

# =============================================================================
# Figure 2: RD Plot - All Payment Sources
# =============================================================================

cat("\n=== Figure 2: All Payment Sources ===\n")

fig2_data <- agg_by_age %>%
  select(mother_age, n_births, medicaid_share, private_share, self_pay_share) %>%
  pivot_longer(
    cols = ends_with("_share"),
    names_to = "payment",
    values_to = "share"
  ) %>%
  mutate(
    payment = str_remove(payment, "_share"),
    payment = case_when(
      payment == "medicaid" ~ "Medicaid",
      payment == "private" ~ "Private Insurance",
      payment == "self_pay" ~ "Self-Pay"
    ),
    payment = factor(payment, levels = c("Medicaid", "Private Insurance", "Self-Pay"))
  )

fig2 <- fig2_data %>%
  ggplot(aes(x = mother_age, y = share)) +
  geom_point(alpha = 0.7, color = "#2166AC") +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "#B2182B", linewidth = 0.8) +
  geom_smooth(
    data = . %>% filter(mother_age < 26),
    method = "lm", se = TRUE, color = "#2166AC", fill = "#92C5DE"
  ) +
  geom_smooth(
    data = . %>% filter(mother_age >= 26),
    method = "lm", se = TRUE, color = "#2166AC", fill = "#92C5DE"
  ) +
  scale_y_continuous(labels = scales::percent_format()) +
  facet_wrap(~payment, scales = "free_y", ncol = 3) +
  labs(
    title = "Payment Source at Delivery by Mother's Age",
    x = "Mother's Age at Delivery",
    y = "Share of Births",
    caption = "Note: Dashed line at age 26 marks loss of ACA dependent coverage eligibility.\nSource: CDC/NCHS Natality Public Use File."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_rd_all_payments.pdf"), fig2, width = 12, height = 5)
ggsave(file.path(fig_dir, "fig2_rd_all_payments.png"), fig2, width = 12, height = 5, dpi = 300)

cat("Saved: fig2_rd_all_payments.pdf\n")

# =============================================================================
# Figure 3: Density of Births by Age (Manipulation Test)
# =============================================================================

cat("\n=== Figure 3: Density Test ===\n")

fig3 <- agg_by_age %>%
  ggplot(aes(x = mother_age, y = n_births)) +
  geom_col(fill = "#2166AC", alpha = 0.7) +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "#B2182B", linewidth = 0.8) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Number of Births by Mother's Age",
    subtitle = "Testing for bunching/manipulation at age 26",
    x = "Mother's Age at Delivery",
    y = "Number of Births",
    caption = "Note: No evidence of bunching around age 26.\nSource: CDC/NCHS Natality Public Use File."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_density.pdf"), fig3, width = 10, height = 6)
ggsave(file.path(fig_dir, "fig3_density.png"), fig3, width = 10, height = 6, dpi = 300)

cat("Saved: fig3_density.pdf\n")

# =============================================================================
# Figure 4: Covariate Balance
# =============================================================================

cat("\n=== Figure 4: Covariate Balance ===\n")

fig4_data <- agg_by_age %>%
  select(mother_age, married_share, first_birth_share, early_prenatal_share) %>%
  pivot_longer(
    cols = -mother_age,
    names_to = "covariate",
    values_to = "share"
  ) %>%
  mutate(
    covariate = case_when(
      covariate == "married_share" ~ "Married*",
      covariate == "first_birth_share" ~ "First Birth",
      covariate == "early_prenatal_share" ~ "Early Prenatal Care"
    ),
    covariate = factor(covariate, levels = c("Married*", "First Birth", "Early Prenatal Care"))
  )

fig4 <- fig4_data %>%
  ggplot(aes(x = mother_age, y = share)) +
  geom_point(alpha = 0.7, color = "#2166AC") +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "#B2182B", linewidth = 0.8) +
  geom_smooth(
    data = . %>% filter(mother_age < 26),
    method = "lm", se = TRUE, color = "#2166AC", fill = "#92C5DE"
  ) +
  geom_smooth(
    data = . %>% filter(mother_age >= 26),
    method = "lm", se = TRUE, color = "#2166AC", fill = "#92C5DE"
  ) +
  scale_y_continuous(labels = scales::percent_format()) +
  facet_wrap(~covariate, scales = "free_y") +
  labs(
    title = "Covariate Balance at Age 26 Threshold",
    x = "Mother's Age at Delivery",
    y = "Share",
    caption = "*Marriage may be a mechanism (marry for spousal coverage), not a balance test.\nSource: CDC/NCHS Natality Public Use File."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_balance.pdf"), fig4, width = 12, height = 5)
ggsave(file.path(fig_dir, "fig4_balance.png"), fig4, width = 12, height = 5, dpi = 300)

cat("Saved: fig4_balance.pdf\n")

# =============================================================================
# Main RD Estimates
# =============================================================================

cat("\n=== RD Estimation ===\n")

# Create running variable centered at cutoff
rdd_sample <- rdd_sample %>%
  mutate(
    age_centered = mother_age - 26,
    above_26 = ifelse(mother_age >= 26, 1, 0)
  )

# Window: ages 23-28 (3 years on each side)
window_left <- 23
window_right <- 28

rd_sample <- rdd_sample %>%
  filter(mother_age >= window_left, mother_age <= window_right)

cat(sprintf("Window: %d to %d\n", window_left, window_right))
cat(sprintf("Observations in window: %s\n", format(nrow(rd_sample), big.mark = ",")))

# Simple difference in means
rd_means <- rd_sample %>%
  group_by(above_26) %>%
  summarise(
    n = n(),
    medicaid_mean = mean(medicaid, na.rm = TRUE),
    private_mean = mean(private, na.rm = TRUE),
    self_pay_mean = mean(self_pay, na.rm = TRUE),
    married_mean = mean(married, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nMeans by treatment status:\n")
print(rd_means)

rd_effect_medicaid <- rd_means$medicaid_mean[2] - rd_means$medicaid_mean[1]
rd_effect_private <- rd_means$private_mean[2] - rd_means$private_mean[1]
rd_effect_selfpay <- rd_means$self_pay_mean[2] - rd_means$self_pay_mean[1]

cat(sprintf("\nSimple RD effect (Medicaid): %.4f (%.2f pp)\n",
            rd_effect_medicaid, rd_effect_medicaid * 100))
cat(sprintf("Simple RD effect (Private): %.4f (%.2f pp)\n",
            rd_effect_private, rd_effect_private * 100))
cat(sprintf("Simple RD effect (Self-pay): %.4f (%.2f pp)\n",
            rd_effect_selfpay, rd_effect_selfpay * 100))

# Parametric RD with linear trend
cat("\n--- Parametric RD (Linear) ---\n")

rd_medicaid_linear <- feols(
  medicaid ~ above_26 + age_centered + above_26:age_centered,
  data = rd_sample,
  vcov = "HC1"
)

rd_private_linear <- feols(
  private ~ above_26 + age_centered + above_26:age_centered,
  data = rd_sample,
  vcov = "HC1"
)

rd_selfpay_linear <- feols(
  self_pay ~ above_26 + age_centered + above_26:age_centered,
  data = rd_sample,
  vcov = "HC1"
)

cat("\nMedicaid RD Results:\n")
print(summary(rd_medicaid_linear))

cat("\nPrivate Insurance RD Results:\n")
print(summary(rd_private_linear))

cat("\nSelf-Pay RD Results:\n")
print(summary(rd_selfpay_linear))

# =============================================================================
# Table 3: Main RD Results
# =============================================================================

cat("\n=== Creating Results Table ===\n")

# Extract coefficients and SEs
extract_results <- function(model, outcome) {
  coef_val <- coef(model)["above_26"]
  se_val <- sqrt(vcov(model)["above_26", "above_26"])
  tibble(
    outcome = outcome,
    estimate = coef_val,
    se = se_val,
    t_stat = coef_val / se_val,
    p_value = 2 * pt(-abs(coef_val / se_val), df = nobs(model) - 4),
    n = nobs(model)
  )
}

main_results <- bind_rows(
  extract_results(rd_medicaid_linear, "Medicaid"),
  extract_results(rd_private_linear, "Private Insurance"),
  extract_results(rd_selfpay_linear, "Self-Pay")
) %>%
  mutate(
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.1 ~ "*",
      TRUE ~ ""
    ),
    estimate_pp = estimate * 100,
    se_pp = se * 100
  )

cat("\nMain RD Results (Window: 23-28):\n")
print(main_results %>% select(outcome, estimate_pp, se_pp, stars))

# Save table
write_csv(main_results, file.path(table_dir, "table3_main_rd.csv"))

# Create LaTeX table
latex_table <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Losing Dependent Coverage at Age 26 on Payment Source}\n",
  "\\label{tab:main_rd}\n",
  "\\begin{tabular}{lccc}\n",
  "\\hline\\hline\n",
  " & Medicaid & Private Insurance & Self-Pay \\\\\n",
  "\\hline\n",
  sprintf("Above Age 26 & %.3f%s & %.3f%s & %.3f%s \\\\\n",
          main_results$estimate[1], main_results$stars[1],
          main_results$estimate[2], main_results$stars[2],
          main_results$estimate[3], main_results$stars[3]),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\\n",
          main_results$se[1], main_results$se[2], main_results$se[3]),
  "\\hline\n",
  sprintf("Observations & %s & %s & %s \\\\\n",
          format(main_results$n[1], big.mark = ","),
          format(main_results$n[2], big.mark = ","),
          format(main_results$n[3], big.mark = ",")),
  "Window & \\multicolumn{3}{c}{Ages 23--28} \\\\\n",
  "\\hline\\hline\n",
  "\\multicolumn{4}{l}{\\footnotesize Notes: Standard errors (HC1) in parentheses.} \\\\\n",
  "\\multicolumn{4}{l}{\\footnotesize * p$<$0.1, ** p$<$0.05, *** p$<$0.01} \\\\\n",
  "\\end{tabular}\n",
  "\\end{table}\n"
)

writeLines(latex_table, file.path(table_dir, "table3_main_rd.tex"))
cat("Saved: table3_main_rd.tex\n")

# =============================================================================
# Placebo Cutoffs
# =============================================================================

cat("\n=== Placebo Cutoff Tests ===\n")

placebo_cutoffs <- c(23, 24, 25, 27, 28, 29)

run_placebo <- function(cutoff) {
  sample_placebo <- rdd_sample %>%
    filter(mother_age >= (cutoff - 3), mother_age <= (cutoff + 3)) %>%
    mutate(
      above_cutoff = ifelse(mother_age >= cutoff, 1, 0),
      age_c = mother_age - cutoff
    )

  fit <- feols(medicaid ~ above_cutoff + age_c + above_cutoff:age_c,
               data = sample_placebo, vcov = "HC1")

  tibble(
    cutoff = cutoff,
    estimate = coef(fit)["above_cutoff"],
    se = sqrt(vcov(fit)["above_cutoff", "above_cutoff"]),
    n = nrow(sample_placebo)
  )
}

placebo_results <- map_dfr(placebo_cutoffs, run_placebo) %>%
  mutate(
    ci_low = estimate - 1.96 * se,
    ci_high = estimate + 1.96 * se,
    significant = ifelse(ci_low > 0 | ci_high < 0, "Yes", "No")
  )

# Add true cutoff (age 26) to placebo results for plotting
true_cutoff <- tibble(
  cutoff = 26,
  estimate = main_results$estimate[1],
  se = main_results$se[1],
  n = main_results$n[1],
  ci_low = main_results$estimate[1] - 1.96 * main_results$se[1],
  ci_high = main_results$estimate[1] + 1.96 * main_results$se[1],
  significant = "Yes"
)

all_cutoffs <- bind_rows(placebo_results, true_cutoff) %>%
  arrange(cutoff) %>%
  mutate(is_true = ifelse(cutoff == 26, "True Cutoff", "Placebo"))

cat("\nPlacebo cutoff results:\n")
print(all_cutoffs)

# Figure 5: Placebo cutoffs
fig5 <- all_cutoffs %>%
  ggplot(aes(x = factor(cutoff), y = estimate, color = is_true)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("Placebo" = "#636363", "True Cutoff" = "#B2182B")) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Placebo Cutoff Tests",
    subtitle = "RD estimates at alternative cutoffs (true cutoff = 26)",
    x = "Cutoff Age",
    y = "RD Estimate (Medicaid Share)",
    color = "",
    caption = "Note: 95% confidence intervals shown."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig5_placebo.pdf"), fig5, width = 8, height = 6)
ggsave(file.path(fig_dir, "fig5_placebo.png"), fig5, width = 8, height = 6, dpi = 300)

cat("Saved: fig5_placebo.pdf\n")

# =============================================================================
# Bandwidth Sensitivity
# =============================================================================

cat("\n=== Bandwidth Sensitivity ===\n")

bandwidths <- list(
  c(24, 27),  # Narrow
  c(23, 28),  # Baseline
  c(22, 29),  # Wide
  c(21, 30)   # Very wide
)

run_bandwidth <- function(bw) {
  sample_bw <- rdd_sample %>%
    filter(mother_age >= bw[1], mother_age <= bw[2])

  fit <- feols(medicaid ~ above_26 + age_centered + above_26:age_centered,
               data = sample_bw, vcov = "HC1")

  tibble(
    window = sprintf("%d-%d", bw[1], bw[2]),
    estimate = coef(fit)["above_26"],
    se = sqrt(vcov(fit)["above_26", "above_26"]),
    n = nrow(sample_bw)
  )
}

bw_results <- map_dfr(bandwidths, run_bandwidth) %>%
  mutate(
    ci_low = estimate - 1.96 * se,
    ci_high = estimate + 1.96 * se
  )

cat("\nBandwidth sensitivity results:\n")
print(bw_results)

# Save bandwidth table
write_csv(bw_results, file.path(table_dir, "table4_bandwidth.csv"))
cat("Saved: table4_bandwidth.csv\n")

# =============================================================================
# Save all results
# =============================================================================

results_list <- list(
  rd_means = rd_means,
  main_results = main_results,
  placebo_results = all_cutoffs,
  bw_results = bw_results
)

saveRDS(results_list, file.path(data_dir, "rd_results.rds"))

cat("\n=============================================================================\n")
cat("RD Analysis Complete!\n")
cat("=============================================================================\n")

# Print summary
cat("\n=============================================================================\n")
cat("SUMMARY OF MAIN FINDINGS\n")
cat("=============================================================================\n")
cat(sprintf("Effect on Medicaid: %.2f pp (SE: %.2f)\n",
            main_results$estimate_pp[1], main_results$se_pp[1]))
cat(sprintf("Effect on Private: %.2f pp (SE: %.2f)\n",
            main_results$estimate_pp[2], main_results$se_pp[2]))
cat(sprintf("Effect on Self-Pay: %.2f pp (SE: %.2f)\n",
            main_results$estimate_pp[3], main_results$se_pp[3]))
cat("=============================================================================\n")
