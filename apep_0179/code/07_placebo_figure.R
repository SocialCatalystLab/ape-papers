# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 07_placebo_figure.R - Placebo cutoff visualization
# ============================================================================

source("00_packages.R")

# Load placebo results
placebo_table <- readRDS(file.path(data_dir, "placebo_results.rds"))

# Create figure showing RD estimates at each cutoff
placebo_table$Cutoff <- as.factor(placebo_table$Cutoff)
placebo_table$IsReal <- placebo_table$Cutoff == "26"

# Create CI columns
placebo_table$CI_Lower <- placebo_table$RD_Estimate - 1.96 * placebo_table$Robust_SE
placebo_table$CI_Upper <- placebo_table$RD_Estimate + 1.96 * placebo_table$Robust_SE

pdf(file.path(fig_dir, "figure6_placebo_cutoffs.pdf"), width = 8, height = 5)

ggplot(placebo_table, aes(x = Cutoff, y = RD_Estimate, color = IsReal)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = CI_Lower, ymax = CI_Upper), width = 0.2, linewidth = 0.8) +
  scale_color_manual(values = c("FALSE" = apep_colors[1], "TRUE" = apep_colors[2]),
                     labels = c("Placebo Cutoff", "Policy Cutoff (Age 26)"),
                     name = "") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "RDD Estimates at Placebo and Policy Cutoffs",
    subtitle = "Medicaid payment discontinuity",
    x = "Cutoff Age",
    y = "RD Estimate (pp)",
    caption = "Note: Points show RD estimates; bars show 95% CI. Only age 26 shows a positive discontinuity."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

dev.off()
cat("Placebo figure saved.\n")
