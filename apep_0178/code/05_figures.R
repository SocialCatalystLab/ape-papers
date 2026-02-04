# ==============================================================================
# 05_figures.R
# Generate publication-quality figures
# Paper 154: The Insurance Value of Secondary Employment
# ==============================================================================

source("00_packages.R")

# Load data and results
cps <- readRDS(file.path(data_dir, "cps_with_pscore.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
hetero_results <- tryCatch(readRDS(file.path(data_dir, "heterogeneity_results.rds")),
                           error = function(e) NULL)
stability_results <- tryCatch(readRDS(file.path(data_dir, "coefficient_stability.rds")),
                              error = function(e) NULL)

# ==============================================================================
# Figure 1: Multiple Job Holder Rates Over Time
# ==============================================================================

cat("Creating Figure 1: MJH Rates Over Time...\n")

mjh_trends <- cps %>%
  group_by(year) %>%
  summarise(
    mjh_rate = weighted.mean(multiple_jobs, weight, na.rm = TRUE),
    n = n(),
    se = sqrt(mjh_rate * (1 - mjh_rate) / n),
    .groups = "drop"
  )

fig1 <- ggplot(mjh_trends, aes(x = year, y = mjh_rate * 100)) +
  geom_ribbon(aes(ymin = (mjh_rate - 1.96*se) * 100,
                  ymax = (mjh_rate + 1.96*se) * 100),
              fill = colors_paper["tertiary"], alpha = 0.2) +
  geom_line(color = colors_paper["primary"], linewidth = 1) +
  geom_point(color = colors_paper["primary"], size = 2) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "gray50") +
  annotate("text", x = 2020.3, y = max(mjh_trends$mjh_rate * 100) + 0.3,
           label = "COVID-19", hjust = 0, size = 3, color = "gray40") +
  scale_x_continuous(breaks = seq(2015, 2024, 2)) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(
    title = "Multiple Job Holding Rates in the United States, 2015-2024",
    subtitle = "Share of employed workers age 25-54 holding more than one job",
    x = "Year",
    y = "Multiple Job Holder Rate (%)",
    caption = "Source: Current Population Survey ASEC. Shaded area shows 95% confidence interval."
  )

ggsave(file.path(figure_dir, "fig1_mjh_trends.pdf"), fig1,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(figure_dir, "fig1_mjh_trends.png"), fig1,
       width = 8, height = 5, dpi = 300)

# ==============================================================================
# Figure 2: Propensity Score Overlap
# ==============================================================================

cat("Creating Figure 2: Propensity Score Overlap...\n")

fig2 <- ggplot(cps, aes(x = pscore, fill = factor(multiple_jobs))) +
  geom_density(alpha = 0.6, color = NA) +
  geom_vline(xintercept = c(0.01, 0.99), linetype = "dashed", color = "gray50") +
  scale_fill_manual(
    values = c("0" = colors_paper["tertiary"], "1" = colors_paper["secondary"]),
    labels = c("Single Job", "Multiple Jobs"),
    name = ""
  ) +
  scale_x_continuous(limits = c(0, 0.5), breaks = seq(0, 0.5, 0.1)) +
  labs(
    title = "Propensity Score Distributions by Treatment Status",
    subtitle = "Overlap assessment for doubly robust estimation",
    x = "Propensity Score (Probability of Holding Multiple Jobs)",
    y = "Density",
    caption = "Note: Dashed lines indicate common trimming thresholds (0.01, 0.99)."
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(figure_dir, "fig2_pscore_overlap.pdf"), fig2,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(figure_dir, "fig2_pscore_overlap.png"), fig2,
       width = 8, height = 5, dpi = 300)

# ==============================================================================
# Figure 3: Main Results - Coefficient Plot
# ==============================================================================

cat("Creating Figure 3: Main Results...\n")

fig3 <- ggplot(main_results, aes(x = estimate, y = reorder(outcome, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, color = colors_paper["primary"], linewidth = 0.8) +
  geom_point(color = colors_paper["secondary"], size = 3) +
  scale_x_continuous(labels = scales::percent_format(scale = 100)) +
  labs(
    title = "Effect of Holding Multiple Jobs on Labor Market Outcomes",
    subtitle = "Doubly robust AIPW estimates with 95% confidence intervals",
    x = "Treatment Effect (Percentage Points)",
    y = "",
    caption = "Note: Estimates from augmented inverse probability weighting with cross-fitting.\nCovariates include demographics, education, occupation, and geography."
  )

ggsave(file.path(figure_dir, "fig3_main_results.pdf"), fig3,
       width = 8, height = 4, device = cairo_pdf)
ggsave(file.path(figure_dir, "fig3_main_results.png"), fig3,
       width = 8, height = 4, dpi = 300)

# ==============================================================================
# Figure 4: Heterogeneity by Credit Constraints
# ==============================================================================

cat("Creating Figure 4: Heterogeneity Analysis...\n")

if (!is.null(hetero_results) && nrow(hetero_results) > 0) {
  hetero_results <- hetero_results %>%
    mutate(
      ci_lower = estimate - 1.96 * se,
      ci_upper = estimate + 1.96 * se
    )

  fig4 <- ggplot(hetero_results, aes(x = estimate, y = subgroup)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                   height = 0.2, color = colors_paper["primary"], linewidth = 0.8) +
    geom_point(aes(size = n), color = colors_paper["secondary"]) +
    scale_x_continuous(labels = scales::percent_format(scale = 100)) +
    scale_size_continuous(range = c(3, 6), labels = scales::comma, name = "Sample Size") +
    labs(
      title = "Heterogeneous Effects by Credit Constraint Status",
      subtitle = "Testing the insurance hypothesis: larger effects for constrained workers?",
      x = "Treatment Effect on Self-Employment (Percentage Points)",
      y = "",
      caption = "Note: Credit-constrained defined as bottom income quartile and renter.\nLarger effects for constrained workers support the insurance hypothesis."
    ) +
    theme(legend.position = "right")

  ggsave(file.path(figure_dir, "fig4_heterogeneity.pdf"), fig4,
         width = 8, height = 4, device = cairo_pdf)
  ggsave(file.path(figure_dir, "fig4_heterogeneity.png"), fig4,
         width = 8, height = 4, dpi = 300)
}

# ==============================================================================
# Figure 5: Coefficient Stability
# ==============================================================================

cat("Creating Figure 5: Coefficient Stability...\n")

if (!is.null(stability_results)) {
  fig5 <- ggplot(stability_results, aes(x = n_covariates, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = estimate - 1.96*se, ymax = estimate + 1.96*se),
                fill = colors_paper["tertiary"], alpha = 0.3) +
    geom_line(color = colors_paper["primary"], linewidth = 1) +
    geom_point(color = colors_paper["secondary"], size = 3) +
    geom_text(aes(label = specification), vjust = -1, size = 3) +
    scale_y_continuous(labels = scales::percent_format(scale = 100)) +
    labs(
      title = "Coefficient Stability Across Specifications",
      subtitle = "Testing sensitivity to inclusion of additional covariates",
      x = "Number of Covariates",
      y = "Estimated Effect on Self-Employment",
      caption = "Note: Stable coefficients across specifications suggest limited selection on observables.\nOster (2019) δ calculation provides formal bound on unobservable selection."
    )

  ggsave(file.path(figure_dir, "fig5_stability.pdf"), fig5,
         width = 8, height = 5, device = cairo_pdf)
  ggsave(file.path(figure_dir, "fig5_stability.png"), fig5,
         width = 8, height = 5, dpi = 300)
}

# ==============================================================================
# Figure 6: MJH Characteristics Comparison
# ==============================================================================

cat("Creating Figure 6: Characteristics Comparison...\n")

char_data <- cps %>%
  group_by(multiple_jobs) %>%
  summarise(
    `Age` = weighted.mean(age, weight),
    `Female (%)` = weighted.mean(female, weight) * 100,
    `College (%)` = weighted.mean(college, weight) * 100,
    `Married (%)` = weighted.mean(married, weight) * 100,
    `Homeowner (%)` = weighted.mean(homeowner, weight) * 100,
    .groups = "drop"
  ) %>%
  pivot_longer(-multiple_jobs, names_to = "characteristic", values_to = "value") %>%
  mutate(group = ifelse(multiple_jobs == 1, "Multiple Jobs", "Single Job"))

# Standardize for comparison
char_means <- char_data %>%
  group_by(characteristic) %>%
  summarise(mean_val = mean(value), sd_val = sd(value), .groups = "drop")

char_data <- char_data %>%
  left_join(char_means, by = "characteristic") %>%
  mutate(std_value = (value - mean_val) / sd_val)

fig6 <- ggplot(char_data, aes(x = std_value, y = characteristic, fill = group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_vline(xintercept = 0, linetype = "solid", color = "gray30") +
  scale_fill_manual(
    values = c("Single Job" = colors_paper["tertiary"],
               "Multiple Jobs" = colors_paper["secondary"]),
    name = ""
  ) +
  labs(
    title = "Comparing Multiple and Single Job Holders",
    subtitle = "Standardized differences in key characteristics",
    x = "Standardized Difference from Mean",
    y = "",
    caption = "Note: Values show deviation from overall mean in standard deviation units."
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(figure_dir, "fig6_characteristics.pdf"), fig6,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(figure_dir, "fig6_characteristics.png"), fig6,
       width = 8, height = 5, dpi = 300)

# ==============================================================================
# Figure 7: Covariate Balance After Weighting
# ==============================================================================

cat("Creating Figure 7: Covariate Balance...\n")

# Calculate standardized mean differences
balance_vars <- c("age", "female", "college", "married", "homeowner")

smd_unweighted <- map_dfr(balance_vars, function(v) {
  treated <- cps[[v]][cps$multiple_jobs == 1]
  control <- cps[[v]][cps$multiple_jobs == 0]

  diff <- mean(treated, na.rm = TRUE) - mean(control, na.rm = TRUE)
  pooled_sd <- sqrt((var(treated, na.rm = TRUE) + var(control, na.rm = TRUE)) / 2)

  tibble(
    variable = v,
    smd = diff / pooled_sd,
    type = "Unweighted"
  )
})

# IPW weights
cps$ipw <- ifelse(
  cps$multiple_jobs == 1,
  1 / cps$pscore,
  1 / (1 - cps$pscore)
)
cps$ipw <- pmin(cps$ipw, quantile(cps$ipw, 0.99, na.rm = TRUE))

smd_weighted <- map_dfr(balance_vars, function(v) {
  treated <- cps[[v]][cps$multiple_jobs == 1]
  control <- cps[[v]][cps$multiple_jobs == 0]
  w_treated <- cps$ipw[cps$multiple_jobs == 1]
  w_control <- cps$ipw[cps$multiple_jobs == 0]

  diff <- weighted.mean(treated, w_treated, na.rm = TRUE) -
    weighted.mean(control, w_control, na.rm = TRUE)

  pooled_sd <- sqrt((var(treated, na.rm = TRUE) + var(control, na.rm = TRUE)) / 2)

  tibble(
    variable = v,
    smd = diff / pooled_sd,
    type = "IPW Weighted"
  )
})

balance_data <- bind_rows(smd_unweighted, smd_weighted) %>%
  mutate(variable = factor(variable, levels = balance_vars))

fig7 <- ggplot(balance_data, aes(x = smd, y = variable, color = type, shape = type)) +
  geom_vline(xintercept = 0, linetype = "solid", color = "gray30") +
  geom_vline(xintercept = c(-0.1, 0.1), linetype = "dashed", color = "gray50") +
  geom_point(size = 3, position = position_dodge(width = 0.3)) +
  scale_color_manual(
    values = c("Unweighted" = colors_paper["tertiary"],
               "IPW Weighted" = colors_paper["secondary"]),
    name = ""
  ) +
  scale_shape_manual(values = c("Unweighted" = 16, "IPW Weighted" = 17), name = "") +
  scale_x_continuous(limits = c(-0.5, 0.5)) +
  labs(
    title = "Covariate Balance Before and After IPW Weighting",
    subtitle = "Standardized mean differences should be within ±0.1 after weighting",
    x = "Standardized Mean Difference",
    y = "",
    caption = "Note: Dashed lines indicate conventional balance threshold of |SMD| < 0.1."
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(figure_dir, "fig7_balance.pdf"), fig7,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(figure_dir, "fig7_balance.png"), fig7,
       width = 8, height = 5, dpi = 300)

cat("\n=== All Figures Created ===\n")
cat("Figures saved to:", figure_dir, "\n")
