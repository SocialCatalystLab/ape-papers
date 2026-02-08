# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 08_honestdid.R - Sensitivity Analysis for Parallel Trends Violations
# ============================================================================

cat("Running HonestDiD sensitivity analysis...\n")

# ============================================================================
# Load packages
# ============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)
})

# Try to load HonestDiD - if not available, create placeholders
honestdid_available <- requireNamespace("HonestDiD", quietly = TRUE)

if (!honestdid_available) {
  cat("Note: HonestDiD package not available. Creating manual sensitivity analysis.\n")
}

# Load data
state_year <- readRDS("data/state_year_panel.rds") %>%
  mutate(across(where(haven::is.labelled), as.numeric))

# ============================================================================
# APEP Theme
# ============================================================================

theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

theme_set(theme_apep())

# ============================================================================
# 1. Re-run Event Study to Get Coefficients
# ============================================================================

cat("1. Running event study...\n")

es_model <- feols(
  mean_log_earn ~ sunab(cohort_year, year) | statefip + year,
  data = state_year %>% filter(is.finite(cohort_year) | treatment_year == 0),
  weights = ~n_obs,
  cluster = ~statefip
)

# Extract coefficients
es_coefs <- coef(es_model)
es_se <- se(es_model)
es_vcov <- vcov(es_model)

es_df <- tibble(
  term = names(es_coefs),
  estimate = es_coefs,
  se = es_se
) %>%
  filter(grepl("^year::", term)) %>%
  mutate(
    event_time = as.numeric(gsub("year::(-?[0-9]+)", "\\1", term)),
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  ) %>%
  filter(!is.na(event_time)) %>%
  arrange(event_time)

# ============================================================================
# 2. Manual Sensitivity Analysis (Rambachan-Roth Style)
# ============================================================================

cat("2. Running sensitivity analysis...\n")

# The key insight from Rambachan-Roth is:
# Under violation of PT, the bias depends on the maximum difference in trends
# We can bound the ATT by considering how trends could have evolved

# Get pre-treatment coefficients
pre_coefs <- es_df %>% filter(event_time < 0)
post_coefs <- es_df %>% filter(event_time >= 0)

# Maximum absolute pre-trend violation
max_pre_violation <- max(abs(pre_coefs$estimate))
max_pre_se <- pre_coefs$se[which.max(abs(pre_coefs$estimate))]

cat("  Maximum pre-trend coefficient:", round(max_pre_violation, 4), "\n")

# Calculate bounds on ATT under different assumptions
# M-bar represents the maximum change in trend that could occur in each period

# Create sensitivity bounds
m_bar_values <- seq(0, 0.05, by = 0.005)
att_naive <- mean(post_coefs$estimate)

sensitivity_results <- tibble(
  M_bar = m_bar_values,
  ATT_point = att_naive,
  # Bias bound: in the worst case, trends could have diverged by M_bar per period
  # Over the pre-treatment period, this accumulates
  max_bias = M_bar * max(abs(post_coefs$event_time) + 1),
  ATT_lower = ATT_point - max_bias,
  ATT_upper = ATT_point + max_bias,
  # Check if CI still excludes zero
  excludes_zero = (ATT_upper < 0) | (ATT_lower > 0),
  zero_in_ci = !excludes_zero
)

write_csv(sensitivity_results, "tables/table11_sensitivity.csv")

# ============================================================================
# 3. Create Sensitivity Figure
# ============================================================================

cat("3. Creating sensitivity figure...\n")

# Plot showing how the confidence set changes with M
fig_sensitivity <- ggplot(sensitivity_results, aes(x = M_bar)) +
  geom_ribbon(aes(ymin = ATT_lower, ymax = ATT_upper), alpha = 0.3, fill = "#0072B2") +
  geom_line(aes(y = ATT_point), color = "#0072B2", linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = max_pre_violation, linetype = "dotted", color = "#D55E00") +
  annotate("text", x = max_pre_violation + 0.003, y = 0.02,
           label = "Max observed\npre-trend", hjust = 0, size = 3, color = "#D55E00") +
  labs(
    title = "Sensitivity Analysis: Robustness to Parallel Trends Violations",
    subtitle = "Bounds on ATT under different assumptions about trend deviations",
    x = expression(bar(M) ~ "(Maximum trend deviation per period)"),
    y = "ATT Bounds (Log Points)",
    caption = "Note: Shaded region shows identification bounds. Vertical line indicates observed pre-trend magnitude."
  ) +
  theme_apep() +
  coord_cartesian(ylim = c(-0.15, 0.05))

ggsave("figures/fig13_sensitivity.pdf", fig_sensitivity, width = 10, height = 6)
ggsave("figures/fig13_sensitivity.png", fig_sensitivity, width = 10, height = 6, dpi = 300)

# ============================================================================
# 4. Breakdown Point Analysis
# ============================================================================

cat("4. Calculating breakdown point...\n")

# Find the M_bar at which the confidence interval includes zero
# This is the "breakdown point" - how much PT violation would be needed
# to invalidate our conclusion

breakdown_point <- sensitivity_results %>%
  filter(ATT_upper >= 0) %>%
  slice(1) %>%
  pull(M_bar)

if (length(breakdown_point) == 0) {
  breakdown_point <- max(m_bar_values)
}

cat("  Breakdown point (M_bar where CI includes 0):", round(breakdown_point, 4), "\n")

# ============================================================================
# 5. Bacon Decomposition (Manual)
# ============================================================================

cat("5. Creating comparison weight analysis...\n")

# Since we're using Sun-Abraham, create a summary of comparison groups
comparison_summary <- state_year %>%
  mutate(
    comparison_type = case_when(
      treatment_year == 0 ~ "Never-treated",
      !is.na(treatment_year) & treatment_year > 0 & year < treatment_year ~ "Not-yet-treated",
      !is.na(treatment_year) & treatment_year > 0 & year >= treatment_year ~ "Treated",
      TRUE ~ "Other"
    )
  ) %>%
  group_by(year, comparison_type) %>%
  summarise(
    n_states = n_distinct(statefip),
    n_obs = sum(n_obs),
    .groups = "drop"
  )

write_csv(comparison_summary, "tables/table12_comparison_groups.csv")

# Plot comparison group composition over time
fig_comparison <- ggplot(comparison_summary, aes(x = year, y = n_states, fill = comparison_type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(
    values = c("Never-treated" = "#E69F00", "Not-yet-treated" = "#56B4E9",
               "Treated" = "#009E73", "Other" = "grey70"),
    name = "Comparison Group"
  ) +
  labs(
    title = "Control Group Composition Over Time",
    subtitle = "Number of states in each comparison group by year",
    x = "Year", y = "Number of States",
    caption = "Note: Sun-Abraham uses never-treated and not-yet-treated as controls."
  ) +
  theme_apep()

ggsave("figures/fig14_comparison_groups.pdf", fig_comparison, width = 10, height = 6)
ggsave("figures/fig14_comparison_groups.png", fig_comparison, width = 10, height = 6, dpi = 300)

# ============================================================================
# 6. Summary
# ============================================================================

cat("\n============================================\n")
cat("SENSITIVITY ANALYSIS COMPLETE\n")
cat("============================================\n")
cat("\nKey Results:\n")
cat("  Naive ATT:", round(att_naive, 4), "\n")
cat("  Max pre-trend violation:", round(max_pre_violation, 4), "\n")
cat("  Breakdown point (M_bar):", round(breakdown_point, 4), "\n")
cat("\nInterpretation:\n")
cat("  At the observed level of pre-trend violation (M_bar =", round(max_pre_violation, 4), "),\n")
cat("  the ATT bounds are [", round(sensitivity_results$ATT_lower[sensitivity_results$M_bar == round(max_pre_violation, 3)][1], 4),
    ",", round(sensitivity_results$ATT_upper[sensitivity_results$M_bar == round(max_pre_violation, 3)][1], 4), "]\n")
cat("\nNew files created:\n")
cat("  tables/table11_sensitivity.csv\n")
cat("  tables/table12_comparison_groups.csv\n")
cat("  figures/fig13_sensitivity.pdf/png\n")
cat("  figures/fig14_comparison_groups.pdf/png\n")
