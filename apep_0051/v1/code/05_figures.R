# Paper 67: Aging Out at 26 and Fertility
# 05_figures.R - Generate publication-quality figures

source("output/paper_67/code/00_packages.R")

# Load data
cat("Loading data...\n")
data <- readRDS("output/paper_67/data/analysis_data.rds")
results <- readRDS("output/paper_67/data/rdd_results.rds")

# Create summary by age for plotting
age_summary <- data %>%
  group_by(AGEP) %>%
  summarise(
    n = n(),
    n_weighted = sum(weight, na.rm = TRUE),
    birth_rate = weighted.mean(gave_birth, weight, na.rm = TRUE),
    insurance_rate = weighted.mean(has_insurance, weight, na.rm = TRUE),
    private_rate = weighted.mean(has_private, weight, na.rm = TRUE),
    public_rate = weighted.mean(has_public, weight, na.rm = TRUE),
    married_rate = weighted.mean(married, weight, na.rm = TRUE),
    college_rate = weighted.mean(college, weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    post_26 = AGEP >= 26
  )

# ============================================================
# FIGURE 1: First Stage - Insurance Coverage by Age
# ============================================================

fig1 <- ggplot(age_summary, aes(x = AGEP)) +
  # Private insurance
  geom_point(aes(y = private_rate, color = "Private Insurance"),
             size = 3) +
  geom_line(aes(y = private_rate, color = "Private Insurance",
                group = post_26), linewidth = 1) +
  # Public insurance
  geom_point(aes(y = public_rate, color = "Public Insurance"),
             size = 3) +
  geom_line(aes(y = public_rate, color = "Public Insurance",
                group = post_26), linewidth = 1) +
  # Vertical line at 26
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "gray40") +
  # Labels
  labs(
    title = "Health Insurance Coverage by Age",
    subtitle = "First Stage: Insurance drops at age 26 when dependent coverage ends",
    x = "Age",
    y = "Coverage Rate",
    color = "Insurance Type",
    caption = "Source: ACS PUMS 2011-2019. Weighted means. Vertical line at age 26 cutoff."
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0.15, 0.75)) +
  scale_color_manual(values = c("Private Insurance" = "#2E86AB",
                                "Public Insurance" = "#A23B72")) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("output/paper_67/figures/fig1_first_stage.pdf", fig1,
       width = 8, height = 6, device = cairo_pdf)
ggsave("output/paper_67/figures/fig1_first_stage.png", fig1,
       width = 8, height = 6, dpi = 300)

cat("Figure 1 saved.\n")

# ============================================================
# FIGURE 2: Reduced Form - Birth Rate by Age
# ============================================================

fig2 <- ggplot(age_summary, aes(x = AGEP, y = birth_rate)) +
  geom_point(color = "#2E86AB", size = 4) +
  geom_line(aes(group = post_26), color = "#2E86AB", linewidth = 1) +
  # Fitted lines on each side
  geom_smooth(data = filter(age_summary, AGEP < 26),
              method = "lm", se = FALSE, color = "#2E86AB",
              linetype = "dashed", linewidth = 0.8) +
  geom_smooth(data = filter(age_summary, AGEP >= 26),
              method = "lm", se = FALSE, color = "#2E86AB",
              linetype = "dashed", linewidth = 0.8) +
  # Vertical line at 26
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "gray40") +
  # Labels
  labs(
    title = "Birth Rate by Age",
    subtitle = "Reduced Form: Small discontinuity at age 26",
    x = "Age",
    y = "Birth Rate (Past 12 Months)",
    caption = "Source: ACS PUMS 2011-2019. Weighted means. Dashed lines show linear fit."
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1),
                     limits = c(0.06, 0.12)) +
  theme_apep()

ggsave("output/paper_67/figures/fig2_birth_rate.pdf", fig2,
       width = 8, height = 6, device = cairo_pdf)
ggsave("output/paper_67/figures/fig2_birth_rate.png", fig2,
       width = 8, height = 6, dpi = 300)

cat("Figure 2 saved.\n")

# ============================================================
# FIGURE 3: Balance Test - Marriage Rate (Problem!)
# ============================================================

fig3 <- ggplot(age_summary, aes(x = AGEP, y = married_rate)) +
  geom_point(color = "#C73E1D", size = 4) +
  geom_line(aes(group = post_26), color = "#C73E1D", linewidth = 1) +
  # Fitted lines
  geom_smooth(data = filter(age_summary, AGEP < 26),
              method = "lm", se = FALSE, color = "#C73E1D",
              linetype = "dashed", linewidth = 0.8) +
  geom_smooth(data = filter(age_summary, AGEP >= 26),
              method = "lm", se = FALSE, color = "#C73E1D",
              linetype = "dashed", linewidth = 0.8) +
  # Vertical line at 26
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "gray40") +
  # Labels
  labs(
    title = "Marriage Rate by Age (Balance Test)",
    subtitle = "Problem: Marriage rate shows discontinuity at age 26",
    x = "Age",
    y = "Marriage Rate",
    caption = "Source: ACS PUMS 2011-2019. Marriage changes at 26 confounds the RDD."
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0.10, 0.50)) +
  theme_apep()

ggsave("output/paper_67/figures/fig3_balance_marriage.pdf", fig3,
       width = 8, height = 6, device = cairo_pdf)
ggsave("output/paper_67/figures/fig3_balance_marriage.png", fig3,
       width = 8, height = 6, dpi = 300)

cat("Figure 3 saved.\n")

# ============================================================
# FIGURE 4: Heterogeneity by Marital Status
# ============================================================

# Create summaries by marital status
age_marital <- data %>%
  group_by(AGEP, married) %>%
  summarise(
    birth_rate = weighted.mean(gave_birth, weight, na.rm = TRUE),
    private_rate = weighted.mean(has_private, weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    post_26 = AGEP >= 26,
    marital_status = ifelse(married == 1, "Married", "Unmarried")
  )

fig4a <- ggplot(age_marital, aes(x = AGEP, y = private_rate,
                                  color = marital_status)) +
  geom_point(size = 3) +
  geom_line(aes(group = interaction(marital_status, post_26)),
            linewidth = 1) +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "gray40") +
  labs(
    title = "Private Insurance by Age and Marital Status",
    subtitle = "First stage varies dramatically by marriage",
    x = "Age",
    y = "Private Insurance Rate",
    color = "Marital Status"
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_color_manual(values = c("Married" = "#2E86AB",
                                "Unmarried" = "#A23B72")) +
  theme_apep() +
  theme(legend.position = "bottom")

fig4b <- ggplot(age_marital, aes(x = AGEP, y = birth_rate,
                                  color = marital_status)) +
  geom_point(size = 3) +
  geom_line(aes(group = interaction(marital_status, post_26)),
            linewidth = 1) +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "gray40") +
  labs(
    title = "Birth Rate by Age and Marital Status",
    subtitle = "No discontinuity within either group",
    x = "Age",
    y = "Birth Rate",
    color = "Marital Status"
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_color_manual(values = c("Married" = "#2E86AB",
                                "Unmarried" = "#A23B72")) +
  theme_apep() +
  theme(legend.position = "bottom")

fig4 <- fig4a + fig4b +
  plot_annotation(
    title = "Heterogeneity by Marital Status",
    caption = "Source: ACS PUMS 2011-2019. Marriage confounds the pooled result."
  )

ggsave("output/paper_67/figures/fig4_heterogeneity.pdf", fig4,
       width = 12, height = 5, device = cairo_pdf)
ggsave("output/paper_67/figures/fig4_heterogeneity.png", fig4,
       width = 12, height = 5, dpi = 300)

cat("Figure 4 saved.\n")

# ============================================================
# FIGURE 5: Placebo Tests
# ============================================================

placebo_df <- results$placebo_tests %>%
  mutate(
    significant = pvalue < 0.05,
    label = sprintf("%.3f\n(p=%.3f)", estimate, pvalue)
  )

# Add the actual estimate at 26
actual_26 <- data.frame(
  cutoff_age = 26,
  estimate = results$birth_rdd$estimate,
  se = results$birth_rdd$cluster_se,
  pvalue = results$birth_rdd$pvalue,
  significant = TRUE,
  label = sprintf("%.3f\n(p=%.3f)", results$birth_rdd$estimate,
                  results$birth_rdd$pvalue)
)

placebo_df <- rbind(placebo_df, actual_26) %>%
  arrange(cutoff_age)

fig5 <- ggplot(placebo_df, aes(x = cutoff_age, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_errorbar(aes(ymin = estimate - 1.96*se, ymax = estimate + 1.96*se),
                width = 0.2, color = "gray40") +
  geom_point(aes(color = significant, shape = cutoff_age == 26),
             size = 4) +
  geom_vline(xintercept = 26, linetype = "dashed", color = "gray40",
             alpha = 0.5) +
  # Labels
  labs(
    title = "Placebo Tests at Non-Policy Ages",
    subtitle = "Testing for discontinuities at ages without policy change",
    x = "Cutoff Age",
    y = "RDD Estimate (Birth Rate)",
    caption = "Note: Age 26 is the true policy cutoff. Age 27 also shows significance (concern)."
  ) +
  scale_color_manual(values = c("FALSE" = "gray50", "TRUE" = "#C73E1D"),
                     labels = c("Not Significant", "p < 0.05"),
                     name = "Significance") +
  scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 17),
                     labels = c("Placebo", "Policy Cutoff"),
                     name = "Cutoff Type") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("output/paper_67/figures/fig5_placebo.pdf", fig5,
       width = 8, height = 6, device = cairo_pdf)
ggsave("output/paper_67/figures/fig5_placebo.png", fig5,
       width = 8, height = 6, dpi = 300)

cat("Figure 5 saved.\n")

# ============================================================
# FIGURE 6: Combined RDD Plot (Main Result)
# ============================================================

fig6 <- ggplot(age_summary, aes(x = AGEP)) +
  # Insurance (secondary y-axis will be handled separately)
  geom_line(aes(y = private_rate * 0.15 + 0.02, color = "Private Insurance"),
            linewidth = 1, linetype = "dashed") +
  geom_point(aes(y = private_rate * 0.15 + 0.02, color = "Private Insurance"),
             size = 2) +
  # Birth rate
  geom_line(aes(y = birth_rate, color = "Birth Rate"),
            linewidth = 1.2) +
  geom_point(aes(y = birth_rate, color = "Birth Rate"),
             size = 3) +
  # Cutoff
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "gray40") +
  annotate("text", x = 25.7, y = 0.115,
           label = "Age 26\nCutoff", hjust = 0, size = 3) +
  # Labels
  labs(
    title = "Insurance Coverage and Birth Rate Around Age 26",
    subtitle = "Insurance drops sharply; birth rate shows small increase",
    x = "Age",
    y = "Birth Rate",
    color = "",
    caption = "Source: ACS PUMS 2011-2019. Private insurance scaled for visual comparison."
  ) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 0.1),
    sec.axis = sec_axis(~ (. - 0.02) / 0.15,
                        labels = scales::percent_format(accuracy = 1),
                        name = "Private Insurance Rate")
  ) +
  scale_color_manual(values = c("Birth Rate" = "#2E86AB",
                                "Private Insurance" = "#A23B72")) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("output/paper_67/figures/fig6_combined.pdf", fig6,
       width = 8, height = 6, device = cairo_pdf)
ggsave("output/paper_67/figures/fig6_combined.png", fig6,
       width = 8, height = 6, dpi = 300)

cat("Figure 6 saved.\n")

# List all figures
cat("\n=== Figures Generated ===\n")
cat("1. fig1_first_stage - Insurance coverage by age\n")
cat("2. fig2_birth_rate - Birth rate by age (reduced form)\n")
cat("3. fig3_balance_marriage - Marriage rate (balance failure)\n")
cat("4. fig4_heterogeneity - By marital status\n")
cat("5. fig5_placebo - Placebo tests at other ages\n")
cat("6. fig6_combined - Combined main result\n")

cat("\nFigures complete.\n")
