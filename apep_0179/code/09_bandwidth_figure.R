# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 09_bandwidth_figure.R - Bandwidth sensitivity figure
# ============================================================================

source("00_packages.R")

# Load bandwidth sensitivity data
bw_table <- readRDS(file.path(data_dir, "bandwidth_sensitivity.rds"))

# Create figure
pdf(file.path(fig_dir, "figure7_bandwidth.pdf"), width = 8, height = 5)

ggplot(bw_table, aes(x = Bandwidth, y = RD_Estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 4, color = apep_colors[2]) +
  geom_errorbar(aes(ymin = CI_Lower, ymax = CI_Upper), width = 0.1,
                linewidth = 0.8, color = apep_colors[2]) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1),
                     limits = c(0, 0.05)) +
  scale_x_continuous(breaks = 1:4) +
  labs(
    title = "Bandwidth Sensitivity Analysis",
    subtitle = "RDD estimate for Medicaid payment at age 26 threshold",
    x = "Bandwidth (Years)",
    y = "RD Estimate",
    caption = "Note: Points show RD estimates; bars show 95% CI. Effect stable across bandwidths."
  ) +
  theme_apep()

dev.off()
cat("Bandwidth sensitivity figure saved.\n")
