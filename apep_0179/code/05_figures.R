# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 05_figures.R - Generate all figures
# ============================================================================

source("00_packages.R")

# Load data
natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))
age_summary <- readRDS(file.path(data_dir, "age_summary.rds"))

# ============================================================================
# Figure 1: Main RDD Plot - Payment Source by Age
# ============================================================================

cat("Generating Figure 1: Main RDD Plot...\n")

# Prepare data for plotting
plot_data <- age_summary[, .(
  MAGER,
  `Medicaid` = pct_medicaid * 100,
  `Private Insurance` = pct_private * 100,
  `Self-Pay (Uninsured)` = pct_selfpay * 100
)]

# Reshape for ggplot
plot_long <- melt(plot_data, id.vars = "MAGER",
                  variable.name = "Payment", value.name = "Percent")

# Main RDD plot
pdf(file.path(fig_dir, "figure1_rdd_main.pdf"), width = 10, height = 6)

ggplot(plot_long, aes(x = MAGER, y = Percent, color = Payment, shape = Payment)) +
  # Points
  geom_point(size = 3, alpha = 0.9) +
  # Lines connecting points (separately for below/above 26)
  geom_line(data = plot_long[MAGER < 26], linewidth = 0.8, alpha = 0.7) +
  geom_line(data = plot_long[MAGER >= 26], linewidth = 0.8, alpha = 0.7) +
  # Cutoff line
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "grey30", linewidth = 0.8) +
  # Colors
  scale_color_manual(values = c("Medicaid" = "#E41A1C",
                                "Private Insurance" = "#377EB8",
                                "Self-Pay (Uninsured)" = "#4DAF4A")) +
  scale_shape_manual(values = c(16, 17, 15)) +
  # Labels
  labs(
    title = "Source of Payment for Delivery by Mother's Age",
    subtitle = "Regression Discontinuity at Age 26 (Loss of Dependent Coverage Eligibility)",
    x = "Mother's Age at Delivery",
    y = "Percent of Births",
    caption = "Data: CDC Natality Public Use Files, 2016-2023. Dashed line indicates age 26 cutoff."
  ) +
  # Annotation
  annotate("text", x = 23.5, y = max(plot_long$Percent) * 0.95,
           label = "Eligible for\nParent's Insurance",
           hjust = 0.5, size = 3.5, color = "grey40") +
  annotate("text", x = 28.5, y = max(plot_long$Percent) * 0.95,
           label = "Lost Eligibility\n(Age 26+)",
           hjust = 0.5, size = 3.5, color = "grey40") +
  theme_apep() +
  theme(legend.position = "bottom")

dev.off()

cat("Figure 1 saved.\n")

# ============================================================================
# Figure 2: RDD Plot for Medicaid (Main Outcome)
# ============================================================================

cat("Generating Figure 2: Medicaid RDD Plot...\n")

pdf(file.path(fig_dir, "figure2_medicaid_rdd.pdf"), width = 8, height = 6)

# Medicaid only
medicaid_data <- age_summary[, .(MAGER, pct = pct_medicaid * 100)]

ggplot(medicaid_data, aes(x = MAGER, y = pct)) +
  # Points
  geom_point(aes(color = MAGER >= 26), size = 4, alpha = 0.9) +
  # Local polynomial fit (separately for each side)
  geom_smooth(data = medicaid_data[MAGER < 26], method = "lm",
              formula = y ~ poly(x, 2), se = TRUE,
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2) +
  geom_smooth(data = medicaid_data[MAGER >= 26], method = "lm",
              formula = y ~ poly(x, 2), se = TRUE,
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2) +
  # Cutoff
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "grey30", linewidth = 0.8) +
  # Colors
  scale_color_manual(values = c(apep_colors[1], apep_colors[2]),
                     labels = c("Below 26", "26 and Above"),
                     name = "") +
  # Labels
  labs(
    title = "Effect of Aging Out on Medicaid-Paid Births",
    subtitle = "Regression Discontinuity at Age 26",
    x = "Mother's Age at Delivery",
    y = "Percent of Births Paid by Medicaid",
    caption = "Data: CDC Natality 2016-2023. Shaded regions show 95% CI for local polynomial."
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.9))

dev.off()

cat("Figure 2 saved.\n")

# ============================================================================
# Figure 3: Covariate Balance
# ============================================================================

cat("Generating Figure 3: Covariate Balance...\n")

# Covariates by age
balance_data <- age_summary[, .(
  MAGER,
  `Married` = pct_married * 100,
  `College+` = pct_college * 100,
  `US-Born` = pct_us_born * 100
)]

balance_long <- melt(balance_data, id.vars = "MAGER",
                     variable.name = "Covariate", value.name = "Percent")

pdf(file.path(fig_dir, "figure3_balance.pdf"), width = 10, height = 8)

ggplot(balance_long, aes(x = MAGER, y = Percent)) +
  facet_wrap(~Covariate, scales = "free_y", ncol = 2) +
  geom_point(aes(color = MAGER >= 26), size = 3) +
  geom_smooth(data = balance_long[MAGER < 26], method = "lm",
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2, se = TRUE) +
  geom_smooth(data = balance_long[MAGER >= 26], method = "lm",
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2, se = TRUE) +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "grey30") +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2]),
                     labels = c("Below 26", "26+"), name = "") +
  labs(
    title = "Covariate Balance at Age 26 Cutoff",
    subtitle = "Predetermined characteristics should not show discontinuity",
    x = "Mother's Age",
    y = "Percent",
    caption = "Data: CDC Natality 2016-2023. These covariates are determined before age 26."
  ) +
  theme_apep() +
  theme(legend.position = "bottom",
        strip.text = element_text(face = "bold", size = 11))

dev.off()

cat("Figure 3 saved.\n")

# ============================================================================
# Figure 4: Heterogeneity by Marital Status
# ============================================================================

cat("Generating Figure 4: Heterogeneity by Marital Status...\n")

# Compute by age and marital status
het_data <- natality[MAGER >= 22 & MAGER <= 30, .(
  N = .N,
  pct_medicaid = mean(medicaid, na.rm=TRUE) * 100,
  pct_private = mean(private, na.rm=TRUE) * 100
), by = .(MAGER, marital_status = ifelse(married == 1, "Married", "Unmarried"))]

pdf(file.path(fig_dir, "figure4_heterogeneity_marital.pdf"), width = 10, height = 6)

ggplot(het_data, aes(x = MAGER, y = pct_medicaid, color = marital_status)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_line(data = het_data[MAGER < 26], linewidth = 0.8) +
  geom_line(data = het_data[MAGER >= 26], linewidth = 0.8) +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "grey30") +
  scale_color_manual(values = c("Married" = apep_colors[1],
                                "Unmarried" = apep_colors[2]),
                     name = "Marital Status") +
  labs(
    title = "Heterogeneity in Aging Out Effect by Marital Status",
    subtitle = "Unmarried mothers show larger shift to Medicaid at age 26",
    x = "Mother's Age at Delivery",
    y = "Percent Medicaid-Paid",
    caption = "Note: Unmarried mothers less likely to have spousal coverage after losing parental coverage."
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.85))

dev.off()

cat("Figure 4 saved.\n")

# ============================================================================
# Figure 5: Health Outcomes
# ============================================================================

cat("Generating Figure 5: Health Outcomes...\n")

health_data <- age_summary[, .(
  MAGER,
  `Early Prenatal Care` = pct_early_prenatal * 100,
  `Preterm Birth` = pct_preterm * 100,
  `Low Birth Weight` = pct_low_birthweight * 100
)]

health_long <- melt(health_data, id.vars = "MAGER",
                    variable.name = "Outcome", value.name = "Percent")

pdf(file.path(fig_dir, "figure5_health_outcomes.pdf"), width = 10, height = 8)

ggplot(health_long, aes(x = MAGER, y = Percent)) +
  facet_wrap(~Outcome, scales = "free_y", ncol = 2) +
  geom_point(aes(color = MAGER >= 26), size = 3) +
  geom_smooth(data = health_long[MAGER < 26], method = "lm",
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2) +
  geom_smooth(data = health_long[MAGER >= 26], method = "lm",
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2) +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "grey30") +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2]),
                     labels = c("Below 26", "26+"), name = "") +
  labs(
    title = "Health Outcomes by Mother's Age",
    subtitle = "Do insurance changes at age 26 affect maternal and infant health?",
    x = "Mother's Age",
    y = "Percent",
    caption = "Data: CDC Natality 2016-2023."
  ) +
  theme_apep() +
  theme(legend.position = "bottom",
        strip.text = element_text(face = "bold", size = 11))

dev.off()

cat("Figure 5 saved.\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== All Figures Generated ===\n")
cat("Figures saved to:", fig_dir, "\n")
print(list.files(fig_dir, pattern = "\\.pdf$"))
