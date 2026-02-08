# =============================================================================
# 05_figures.R
# Generate all figures for the paper
# =============================================================================

library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
library(readr)

theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold"),
      legend.position = "bottom"
    )
)

message("=== GENERATING FIGURES ===")

df <- readRDS("output/paper_116/data/acs_clean.rds")
results <- readRDS("output/paper_116/data/main_results.rds")
robustness <- readRDS("output/paper_116/data/robustness_results.rds")

fig_dir <- "output/paper_116/figures"
dir.create(fig_dir, showWarnings = FALSE)

# =============================================================================
# FIGURE 1: Self-Employment Rates Over Time
# =============================================================================

fig1_data <- df %>%
  mutate(
    age_band = if_else(pre_medicare, "55-64 (Pre-Medicare)", "65-74 (Medicare-Eligible)")
  ) %>%
  group_by(YEAR, age_band) %>%
  summarize(
    self_emp_rate = weighted.mean(self_employed, PWGTP) * 100,
    .groups = "drop"
  )

fig1 <- ggplot(fig1_data, aes(x = YEAR, y = self_emp_rate, 
                               color = age_band, linetype = age_band)) +
  geom_line(size = 1.2) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "gray50") +
  annotate("text", x = 2014.5, y = 26, label = "ACA", hjust = 0, size = 3) +
  scale_color_manual(values = c("55-64 (Pre-Medicare)" = "#2171B5", 
                                "65-74 (Medicare-Eligible)" = "#CB181D")) +
  labs(
    title = "Self-Employment Rates by Age Group, 2012-2022",
    subtitle = "ACS 1-Year Estimates, Workers Aged 55-74",
    x = "Year",
    y = "Self-Employment Rate (%)",
    color = "Age Group",
    linetype = "Age Group"
  ) +
  scale_y_continuous(limits = c(14, 30))

ggsave(file.path(fig_dir, "fig1_selfempl_trends.pdf"), fig1, width = 8, height = 5)
message("Figure 1 saved")

# =============================================================================
# FIGURE 2: Hours Distribution
# =============================================================================

df_main <- df %>% filter(sample_main)

fig2 <- ggplot(df_main, aes(x = hours_weekly, fill = self_employed)) +
  geom_histogram(aes(y = ..density..), bins = 40, alpha = 0.6, 
                 position = "identity", color = "white") +
  scale_fill_manual(
    values = c("TRUE" = "#CB181D", "FALSE" = "#2171B5"),
    labels = c("TRUE" = "Self-Employed", "FALSE" = "Wage Workers")
  ) +
  labs(
    title = "Distribution of Weekly Hours Worked",
    subtitle = "Workers Aged 55-64, 2012-2022",
    x = "Hours Worked Per Week",
    y = "Density",
    fill = "Employment Type"
  ) +
  geom_vline(xintercept = 35, linetype = "dashed", color = "gray40") +
  annotate("text", x = 36, y = 0.04, label = "Part-time", hjust = 0, size = 3)

ggsave(file.path(fig_dir, "fig2_hours_distribution.pdf"), fig2, width = 8, height = 5)
message("Figure 2 saved")

# =============================================================================
# FIGURE 3: Event Study
# =============================================================================

yearly <- robustness$yearly_effects %>%
  mutate(
    ci_lower = effect - 1.96 * se,
    ci_upper = effect + 1.96 * se
  )

fig3 <- ggplot(yearly, aes(x = YEAR, y = effect)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray50") +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), fill = "#2171B5", alpha = 0.2) +
  geom_line(color = "#2171B5", size = 1) +
  geom_point(color = "#2171B5", size = 2.5) +
  annotate("text", x = 2014.2, y = 0.1, label = "ACA", hjust = 0, size = 3) +
  labs(
    title = "Self-Employment Effect on Hours Worked Over Time",
    subtitle = "OLS estimates with 95% CI, Workers Aged 55-64",
    x = "Year",
    y = "Effect on Hours (vs. wage workers)"
  )

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), fig3, width = 8, height = 5)
message("Figure 3 saved")

# =============================================================================
# FIGURE 4: Propensity Score
# =============================================================================

ps_fit <- glm(self_employed ~ AGEP + female + married + college + has_disability,
              data = df_main, family = binomial())
df_main$ps <- predict(ps_fit, type = "response")

fig4 <- ggplot(df_main, aes(x = ps, fill = self_employed)) +
  geom_density(alpha = 0.5, color = NA) +
  scale_fill_manual(
    values = c("TRUE" = "#CB181D", "FALSE" = "#2171B5"),
    labels = c("TRUE" = "Self-Employed", "FALSE" = "Wage Workers")
  ) +
  labs(
    title = "Propensity Score Distribution",
    subtitle = "Evidence of substantial overlap",
    x = "Propensity Score",
    y = "Density",
    fill = "Employment Type"
  )

ggsave(file.path(fig_dir, "fig4_propensity_overlap.pdf"), fig4, width = 8, height = 5)
message("Figure 4 saved")

# =============================================================================
# FIGURE 5: Pre/Post ACA with Placebo
# =============================================================================

comparison_data <- tibble(
  Group = c("Pre-Medicare (55-64)", "Pre-Medicare (55-64)",
            "Medicare-Eligible (65-74)", "Medicare-Eligible (65-74)"),
  Period = c("Pre-ACA", "Post-ACA", "Pre-ACA", "Post-ACA"),
  ATT = c(
    results$pre_post$ATT_Hours[1],
    results$pre_post$ATT_Hours[2],
    results$placebo$ATT_Hours[1],
    results$placebo$ATT_Hours[2]
  ),
  SE = c(
    results$pre_post$ATT_SE[1],
    results$pre_post$ATT_SE[2],
    results$placebo$ATT_SE[1],
    results$placebo$ATT_SE[2]
  )
) %>%
  mutate(
    ci_lower = ATT - 1.96 * SE,
    ci_upper = ATT + 1.96 * SE
  )

fig5 <- ggplot(comparison_data, aes(x = Period, y = ATT, color = Group)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray50") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper), 
                  position = position_dodge(width = 0.3), size = 0.8) +
  scale_color_manual(values = c("Pre-Medicare (55-64)" = "#2171B5", 
                                "Medicare-Eligible (65-74)" = "#CB181D")) +
  labs(
    title = "Self-Employment Effect: Pre/Post ACA with Medicare Placebo",
    subtitle = "OLS estimates with 95% CI",
    x = "",
    y = "Effect on Hours",
    color = "Age Group"
  )

ggsave(file.path(fig_dir, "fig5_prepost_placebo.pdf"), fig5, width = 8, height = 5)
message("Figure 5 saved")

# =============================================================================
# FIGURE 6: Covariate Balance
# =============================================================================

balance_plot <- robustness$balance %>%
  mutate(Variable = factor(Variable, levels = c("Age", "Female", "Married", 
                                                 "College", "Disability")))

fig6 <- ggplot(balance_plot, aes(x = SMD, y = Variable)) +
  geom_vline(xintercept = 0, color = "gray50") +
  geom_vline(xintercept = c(-0.1, 0.1), linetype = "dashed", color = "gray70") +
  geom_point(size = 3, color = "#2171B5") +
  labs(
    title = "Covariate Balance: Self-Employed vs. Wage Workers",
    subtitle = "Standardized Mean Differences",
    x = "SMD",
    y = ""
  ) +
  scale_x_continuous(limits = c(-0.3, 0.2))

ggsave(file.path(fig_dir, "fig6_covariate_balance.pdf"), fig6, width = 7, height = 4)
message("Figure 6 saved")

# =============================================================================
# FIGURE 7: Medicaid Expansion Heterogeneity
# =============================================================================

hetero <- robustness$expansion_heterogeneity %>%
  mutate(
    ci_lower = Self_Emp_Effect - 1.96 * SE,
    ci_upper = Self_Emp_Effect + 1.96 * SE
  )

fig7 <- ggplot(hetero, aes(x = Group, y = Self_Emp_Effect)) +
  geom_hline(yintercept = 0, color = "gray50") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper), 
                  color = "#2171B5", size = 0.8) +
  labs(
    title = "Self-Employment Effect by Medicaid Expansion Status",
    subtitle = "Effect on weekly hours, workers aged 55-64",
    x = "",
    y = "Effect on Hours"
  ) +
  coord_flip()

ggsave(file.path(fig_dir, "fig7_expansion_heterogeneity.pdf"), fig7, width = 7, height = 4)
message("Figure 7 saved")

message("\n=== ALL FIGURES GENERATED ===")
list.files(fig_dir)
