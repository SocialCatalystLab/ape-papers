# ============================================================================
# 05_figures.R - Generate all figures for the paper
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")

# Load data
load("../data/kenya_uct_data.RData")
mvpf_results <- readRDS("../data/mvpf_results.rds")
het_results <- readRDS("../data/heterogeneity_results.rds")

if (file.exists("../data/robustness_results.RData")) {
  load("../data/robustness_results.RData")
}

# Figure output directory
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# Figure 1: MVPF Components Breakdown
# -----------------------------------------------------------------------------

components <- tibble(
  component = c("WTP (Direct)", "VAT Externality", "Income Tax Ext.", "Net Cost"),
  value = c(mvpf_results$wtp_direct,
            mvpf_results$vat_externality,
            mvpf_results$income_tax_externality,
            mvpf_results$net_cost),
  type = c("Willingness to Pay", "Fiscal Externality", "Fiscal Externality", "Net Cost")
)

fig1 <- ggplot(components, aes(x = reorder(component, -value), y = value, fill = type)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = c("Willingness to Pay" = "#2E86AB",
                               "Fiscal Externality" = "#A23B72",
                               "Net Cost" = "#F18F01")) +
  labs(
    title = "MVPF Components: Kenya UCT Program",
    subtitle = sprintf("MVPF = WTP / Net Cost = $%.0f / $%.0f = %.2f",
                      mvpf_results$wtp_direct, mvpf_results$net_cost, mvpf_results$mvpf_direct),
    x = "",
    y = "Amount (USD)",
    fill = ""
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "mvpf_components.pdf"), fig1, width = 8, height = 6)
cat("Saved: mvpf_components.pdf\n")

# -----------------------------------------------------------------------------
# Figure 2: MVPF Heterogeneity by Poverty Quintile
# -----------------------------------------------------------------------------

quintile_data <- het_results$quintile %>%
  mutate(quintile_num = 1:5)

fig2 <- ggplot(quintile_data, aes(x = quintile_num, y = mvpf)) +
  geom_point(size = 4, color = "#2E86AB") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = "#2E86AB") +
  geom_hline(yintercept = mvpf_results$mvpf_direct, linetype = "dashed", color = "gray50") +
  annotate("text", x = 4.5, y = mvpf_results$mvpf_direct + 0.003,
           label = sprintf("Overall: %.2f", mvpf_results$mvpf_direct), size = 3.5) +
  scale_x_continuous(breaks = 1:5,
                     labels = c("Q1\n(Poorest)", "Q2", "Q3", "Q4", "Q5\n(Richest)")) +
  labs(
    title = "MVPF by Baseline Poverty Quintile",
    subtitle = sprintf("Limited heterogeneity: %.2f-%.2f across quintiles",
                       min(quintile_data$mvpf), max(quintile_data$mvpf)),
    x = "Baseline Consumption Quintile",
    y = "MVPF"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "mvpf_heterogeneity.pdf"), fig2, width = 8, height = 6)
cat("Saved: mvpf_heterogeneity.pdf\n")

# -----------------------------------------------------------------------------
# Figure 3: MVPF by Formality Status
# -----------------------------------------------------------------------------

formality_data <- het_results$formality %>%
  mutate(status_label = factor(status, levels = c("Informal workers", "Formal workers")))

fig3 <- ggplot(formality_data, aes(x = status_label, y = mvpf, fill = status_label)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("%.2f", mvpf)), vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("Informal workers" = "#F18F01", "Formal workers" = "#2E86AB")) +
  labs(
    title = "MVPF by Formality Status",
    subtitle = "Formal workers generate income tax externalities; informal workers do not",
    x = "",
    y = "MVPF"
  ) +
  ylim(0, 1) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none",
        plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "mvpf_formality.pdf"), fig3, width = 6, height = 6)
cat("Saved: mvpf_formality.pdf\n")

# -----------------------------------------------------------------------------
# Figure 4: MVPF Distribution from Monte Carlo
# -----------------------------------------------------------------------------

mc_data <- tibble(mvpf = mvpf_results$mvpf_direct_draws)

fig4 <- ggplot(mc_data, aes(x = mvpf)) +
  geom_histogram(bins = 50, fill = "#2E86AB", color = "white", alpha = 0.8) +
  geom_vline(xintercept = mvpf_results$mvpf_direct, color = "red", linetype = "dashed", size = 1) +
  geom_vline(xintercept = mvpf_results$ci_direct_lower, color = "gray50", linetype = "dotted") +
  geom_vline(xintercept = mvpf_results$ci_direct_upper, color = "gray50", linetype = "dotted") +
  labs(
    title = "MVPF Distribution (Monte Carlo, 10,000 draws)",
    subtitle = sprintf("Point estimate: %.3f, 95%% CI: [%.3f, %.3f]",
                      mvpf_results$mvpf_direct,
                      mvpf_results$ci_direct_lower,
                      mvpf_results$ci_direct_upper),
    x = "MVPF",
    y = "Frequency"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "mvpf_distribution.pdf"), fig4, width = 8, height = 6)
cat("Saved: mvpf_distribution.pdf\n")

# -----------------------------------------------------------------------------
# Figure 5: Comparison with US Programs
# -----------------------------------------------------------------------------

comparison_data <- tibble(
  program = c("TANF", "SNAP", "Kenya UCT", "Kenya UCT\n(with spillovers)", "EITC"),
  mvpf = c(0.65, 0.80, mvpf_results$mvpf_direct, mvpf_results$mvpf_with_spillovers, 0.92),
  country = c("USA", "USA", "Kenya", "Kenya", "USA")
)

fig5 <- ggplot(comparison_data, aes(x = reorder(program, mvpf), y = mvpf, fill = country)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("%.2f", mvpf)), hjust = -0.2, size = 4) +
  coord_flip() +
  scale_fill_manual(values = c("USA" = "#2E86AB", "Kenya" = "#F18F01")) +
  labs(
    title = "MVPF Comparison: Kenya UCT vs. US Transfer Programs",
    subtitle = "Kenya's program achieves comparable efficiency despite limited fiscal externalities",
    x = "",
    y = "MVPF",
    fill = "Country"
  ) +
  ylim(0, 1.1) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "mvpf_comparison.pdf"), fig5, width = 8, height = 6)
cat("Saved: mvpf_comparison.pdf\n")

cat("\n=== All figures saved to:", fig_dir, "===\n")
