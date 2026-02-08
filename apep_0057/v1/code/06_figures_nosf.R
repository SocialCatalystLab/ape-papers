# =============================================================================
# Paper 73: Publication-Quality Figures (No SF dependency)
# =============================================================================

library(tidyverse)
library(data.table)
library(scales)

setwd("/Users/dyanag/auto-policy-evals")

# APEP ggplot theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size * 1.2, hjust = 0),
      plot.subtitle = element_text(size = base_size, color = "gray40", hjust = 0),
      plot.caption = element_text(size = base_size * 0.8, color = "gray50", hjust = 1),
      axis.title = element_text(face = "bold"),
      axis.text = element_text(color = "gray30"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Load data
analysis <- fread("output/paper_73/data/analysis_final.csv")
quintile_results <- fread("output/paper_73/data/quintile_results.csv")

cat("Loaded analysis data:", nrow(analysis), "counties\n")

# Ensure figures directory exists
dir.create("output/paper_73/figures", showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Figure 1: Distribution of SCI Diversity
# -----------------------------------------------------------------------------

cat("\nCreating Figure 1: SCI Diversity Distribution...\n")

fig1 <- ggplot(analysis, aes(x = diversity)) +
  geom_histogram(bins = 50, fill = "#2E86AB", color = "white", alpha = 0.8) +
  geom_vline(xintercept = mean(analysis$diversity), linetype = "dashed",
             color = "#E94F37", linewidth = 1) +
  annotate("text", x = mean(analysis$diversity) + 0.05,
           y = Inf, vjust = 2, hjust = 0,
           label = sprintf("Mean = %.2f", mean(analysis$diversity)),
           color = "#E94F37", fontface = "bold") +
  labs(
    x = "SCI Geographic Diversity (1 - HHI of state connections)",
    y = "Number of Counties",
    title = "Distribution of Social Network Diversity Across U.S. Counties",
    subtitle = "Higher values indicate connections spread across more states; lower values indicate concentrated local networks",
    caption = "Source: Facebook Social Connectedness Index (October 2021). N = 3,216 counties."
  ) +
  theme_apep() +
  scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2))

ggsave("output/paper_73/figures/fig1_diversity_dist.png", fig1,
       width = 10, height = 6, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig1_diversity_dist.pdf", fig1,
       width = 10, height = 6, bg = "white")

cat("  Saved fig1_diversity_dist\n")

# -----------------------------------------------------------------------------
# Figure 2: Binned Scatter - Network Exposure vs Own Shock
# -----------------------------------------------------------------------------

cat("Creating Figure 2: Network Exposure vs Own Shock...\n")

# Create 20 bins for smoother visualization
analysis_binned <- analysis %>%
  mutate(exposure_bin = ntile(network_exposure, 20)) %>%
  group_by(exposure_bin) %>%
  summarize(
    mean_exposure = mean(network_exposure),
    mean_shock = mean(unemp_shock),
    se_shock = sd(unemp_shock) / sqrt(n()),
    n = n()
  )

fig2 <- ggplot(analysis_binned, aes(x = mean_exposure, y = mean_shock)) +
  geom_point(aes(size = n), color = "#2E86AB", alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_shock - 1.96*se_shock,
                    ymax = mean_shock + 1.96*se_shock),
                width = 0.02, color = "gray50", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#E94F37", linewidth = 1, se = TRUE, alpha = 0.2) +
  scale_size_continuous(range = c(2, 6), guide = "none") +
  labs(
    x = "Network Shock Exposure (SCI-weighted mean of connected counties' shocks)",
    y = "Own Unemployment Shock (pp, 2019-2021)",
    title = "Counties More Connected to Shocked Areas Experience Larger Own Shocks",
    subtitle = "Each point represents the mean of ~160 counties; error bars show 95% CI",
    caption = "Note: Network exposure = Σ (SCI_ij × shock_j) for all connected counties j. Shocks measured as change in unemployment rate."
  ) +
  theme_apep() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50")

ggsave("output/paper_73/figures/fig2_exposure_shock.png", fig2,
       width = 10, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig2_exposure_shock.pdf", fig2,
       width = 10, height = 7, bg = "white")

cat("  Saved fig2_exposure_shock\n")

# -----------------------------------------------------------------------------
# Figure 3: Quintile Comparison
# -----------------------------------------------------------------------------

cat("Creating Figure 3: Quintile Analysis...\n")

quintile_plot_data <- quintile_results %>%
  mutate(
    quintile_label = factor(exposure_quintile,
                            labels = c("Q1\n(Lowest)", "Q2", "Q3", "Q4", "Q5\n(Highest)"))
  )

fig3 <- ggplot(quintile_plot_data, aes(x = quintile_label, y = mean_own_shock)) +
  geom_col(fill = "#2E86AB", alpha = 0.8, width = 0.7) +
  geom_errorbar(aes(ymin = mean_own_shock - 1.96*se_shock,
                    ymax = mean_own_shock + 1.96*se_shock),
                width = 0.2, color = "gray30") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(
    x = "Network Exposure Quintile",
    y = "Mean Unemployment Shock (pp)",
    title = "Unemployment Shocks by Network Exposure Quintile",
    subtitle = "Counties with higher network exposure to shocked areas experience worse own outcomes",
    caption = "Note: Error bars show 95% confidence intervals. Network exposure quintiles based on SCI-weighted shock exposure."
  ) +
  theme_apep() +
  theme(panel.grid.major.x = element_blank()) +
  annotate("text", x = 1, y = quintile_plot_data$mean_own_shock[1] - 0.15,
           label = sprintf("%.2f pp", quintile_plot_data$mean_own_shock[1]),
           size = 3.5, fontface = "bold") +
  annotate("text", x = 5, y = quintile_plot_data$mean_own_shock[5] + 0.15,
           label = sprintf("%.2f pp", quintile_plot_data$mean_own_shock[5]),
           size = 3.5, fontface = "bold")

ggsave("output/paper_73/figures/fig3_quintiles.png", fig3,
       width = 9, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig3_quintiles.pdf", fig3,
       width = 9, height = 7, bg = "white")

cat("  Saved fig3_quintiles\n")

# -----------------------------------------------------------------------------
# Figure 4: SCI Diversity vs College Share
# -----------------------------------------------------------------------------

cat("Creating Figure 4: Diversity vs College Share...\n")

fig4 <- ggplot(analysis, aes(x = diversity, y = college_share)) +
  geom_point(alpha = 0.3, color = "#2E86AB", size = 0.8) +
  geom_smooth(method = "lm", color = "#E94F37", linewidth = 1.2, se = TRUE) +
  labs(
    x = "SCI Geographic Diversity (1 - HHI)",
    y = "College-Educated Share (%)",
    title = "Social Network Diversity Correlates with Human Capital",
    subtitle = sprintf("r = %.2f; counties with more geographically diverse networks have more educated populations",
                       cor(analysis$diversity, analysis$college_share, use = "complete.obs")),
    caption = "Note: Each point is a U.S. county. College share from ACS 2019 5-year estimates."
  ) +
  theme_apep()

ggsave("output/paper_73/figures/fig4_diversity_college.png", fig4,
       width = 9, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig4_diversity_college.pdf", fig4,
       width = 9, height = 7, bg = "white")

cat("  Saved fig4_diversity_college\n")

# -----------------------------------------------------------------------------
# Figure 5: Distribution of Shocks
# -----------------------------------------------------------------------------

cat("Creating Figure 5: Shock Distribution...\n")

fig5 <- ggplot(analysis, aes(x = unemp_shock)) +
  geom_histogram(bins = 50, fill = "#2E86AB", color = "white", alpha = 0.8) +
  geom_vline(xintercept = 0, linetype = "solid", color = "black", linewidth = 0.5) +
  geom_vline(xintercept = mean(analysis$unemp_shock), linetype = "dashed",
             color = "#E94F37", linewidth = 1) +
  annotate("text", x = mean(analysis$unemp_shock) - 0.3,
           y = Inf, vjust = 2, hjust = 1,
           label = sprintf("Mean = %.2f pp", mean(analysis$unemp_shock)),
           color = "#E94F37", fontface = "bold") +
  labs(
    x = "Unemployment Shock (pp, 2019-2021)",
    y = "Number of Counties",
    title = "Distribution of COVID-Era Unemployment Shocks",
    subtitle = "Positive values indicate unemployment increased; negative values indicate recovery by 2021",
    caption = "Source: American Community Survey 5-year estimates. Shock = unemployment rate 2021 - unemployment rate 2019."
  ) +
  theme_apep()

ggsave("output/paper_73/figures/fig5_shock_dist.png", fig5,
       width = 10, height = 6, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig5_shock_dist.pdf", fig5,
       width = 10, height = 6, bg = "white")

cat("  Saved fig5_shock_dist\n")

# -----------------------------------------------------------------------------
# Figure 6: Within-State Variation
# -----------------------------------------------------------------------------

cat("Creating Figure 6: Within-State Analysis...\n")

# Add state-level means for visualization
state_means <- analysis %>%
  group_by(state_fips) %>%
  summarize(
    state_mean_exposure = mean(network_exposure),
    state_mean_shock = mean(unemp_shock)
  )

analysis_demean <- analysis %>%
  left_join(state_means, by = "state_fips") %>%
  mutate(
    exposure_demean = network_exposure - state_mean_exposure,
    shock_demean = unemp_shock - state_mean_shock
  )

# Binned scatter of demeaned values
analysis_demean_binned <- analysis_demean %>%
  mutate(exposure_bin = ntile(exposure_demean, 20)) %>%
  group_by(exposure_bin) %>%
  summarize(
    mean_exposure = mean(exposure_demean),
    mean_shock = mean(shock_demean),
    se_shock = sd(shock_demean) / sqrt(n()),
    n = n()
  )

fig6 <- ggplot(analysis_demean_binned, aes(x = mean_exposure, y = mean_shock)) +
  geom_point(aes(size = n), color = "#2E86AB", alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_shock - 1.96*se_shock,
                    ymax = mean_shock + 1.96*se_shock),
                width = 0.01, color = "gray50", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#E94F37", linewidth = 1, se = TRUE, alpha = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  scale_size_continuous(range = c(2, 6), guide = "none") +
  labs(
    x = "Network Exposure (demeaned within state)",
    y = "Unemployment Shock (demeaned within state)",
    title = "Network Exposure Effect Persists Within States",
    subtitle = "Relationship holds after removing state-level variation (state fixed effects)",
    caption = "Note: Both variables demeaned by state mean to show within-state variation only."
  ) +
  theme_apep()

ggsave("output/paper_73/figures/fig6_within_state.png", fig6,
       width = 10, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig6_within_state.pdf", fig6,
       width = 10, height = 7, bg = "white")

cat("  Saved fig6_within_state\n")

# -----------------------------------------------------------------------------
# Figure 7: Population vs Diversity (Confounding)
# -----------------------------------------------------------------------------

cat("Creating Figure 7: Population vs Diversity...\n")

fig7 <- ggplot(analysis, aes(x = log_pop, y = diversity)) +
  geom_point(alpha = 0.3, color = "#2E86AB", size = 0.8) +
  geom_smooth(method = "lm", color = "#E94F37", linewidth = 1.2, se = TRUE) +
  labs(
    x = "Log Population",
    y = "SCI Geographic Diversity",
    title = "Larger Counties Have More Diverse Social Networks",
    subtitle = sprintf("r = %.2f; population is a key confounder that must be controlled",
                       cor(analysis$log_pop, analysis$diversity, use = "complete.obs")),
    caption = "Note: This strong correlation motivates controlling for population in all specifications."
  ) +
  theme_apep()

ggsave("output/paper_73/figures/fig7_pop_diversity.png", fig7,
       width = 9, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig7_pop_diversity.pdf", fig7,
       width = 9, height = 7, bg = "white")

cat("  Saved fig7_pop_diversity\n")

# -----------------------------------------------------------------------------
# Figure 8: Coefficient Plot
# -----------------------------------------------------------------------------

cat("Creating Figure 8: Coefficient Comparison...\n")

# Regression coefficient estimates from main analysis
coef_data <- data.frame(
  model = c("Bivariate", "+ Controls", "+ Network\nControls", "State FE", "Clustered SE"),
  estimate = c(0.283, 0.270, 0.258, 0.139, 0.139),
  se = c(0.025, 0.025, 0.026, 0.030, 0.100),
  significant = c(TRUE, TRUE, TRUE, TRUE, FALSE)
)

coef_data$model <- factor(coef_data$model, levels = coef_data$model)

fig8 <- ggplot(coef_data, aes(x = model, y = estimate)) +
  geom_point(aes(color = significant), size = 4) +
  geom_errorbar(aes(ymin = estimate - 1.96*se, ymax = estimate + 1.96*se,
                    color = significant), width = 0.2, linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("TRUE" = "#2E86AB", "FALSE" = "#E94F37"),
                     labels = c("TRUE" = "p < 0.05", "FALSE" = "p ≥ 0.05"),
                     name = "Significance") +
  labs(
    x = "Model Specification",
    y = "Coefficient on Network Exposure (standardized)",
    title = "Network Exposure Effect Across Specifications",
    subtitle = "Effect attenuates with state FE and loses significance with clustered standard errors",
    caption = "Note: All models regress unemployment shock on standardized network exposure. Error bars show 95% CI."
  ) +
  theme_apep() +
  theme(panel.grid.major.x = element_blank())

ggsave("output/paper_73/figures/fig8_coef_plot.png", fig8,
       width = 10, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig8_coef_plot.pdf", fig8,
       width = 10, height = 7, bg = "white")

cat("  Saved fig8_coef_plot\n")

cat("\nAll figures created successfully!\n")

# List all figures
cat("\nFigures saved to output/paper_73/figures/:\n")
print(list.files("output/paper_73/figures/", pattern = "\\.(png|pdf)$"))
