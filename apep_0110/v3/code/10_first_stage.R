# =============================================================================
# 10_first_stage.R
# First-Stage Validation: Cannabis Access Discontinuity at Border
# Addresses reviewer concern: validate that treatment intensity jumps at cutoff
# =============================================================================

source("00_packages.R")

# Load data
crashes <- readRDS("../data/crashes_analysis.rds")
crashes$rv <- -crashes$running_var  # Positive = legal

cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("FIRST-STAGE VALIDATION: CANNABIS ACCESS DISCONTINUITY\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# =============================================================================
# PART 1: Distance to Nearest Dispensary as First-Stage Outcome
# =============================================================================

cat("PART 1: DISPENSARY DISTANCE DISCONTINUITY\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

cat(sprintf("Crashes with dispensary distance: %d\n", sum(!is.na(crashes$dist_to_dispensary_km))))
cat(sprintf("Mean distance to dispensary: %.1f km\n", mean(crashes$dist_to_dispensary_km, na.rm = TRUE)))
cat(sprintf("  Legal states: %.1f km\n", mean(crashes$dist_to_dispensary_km[crashes$legal_status == "Legal"], na.rm = TRUE)))
cat(sprintf("  Prohibition states: %.1f km\n", mean(crashes$dist_to_dispensary_km[crashes$legal_status == "Prohibition"], na.rm = TRUE)))

# RDD on distance to dispensary
rdd_distance <- rdrobust(
  y = crashes$dist_to_dispensary_km,
  x = crashes$rv,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

cat("\nFirst-Stage RDD: Distance to Nearest Dispensary\n")
summary(rdd_distance)

first_stage_dist <- list(
  outcome = "Distance to nearest dispensary (km)",
  estimate = rdd_distance$coef[1],
  se = rdd_distance$se[1],
  ci_lower = rdd_distance$coef[1] - 1.96 * rdd_distance$se[1],
  ci_upper = rdd_distance$coef[1] + 1.96 * rdd_distance$se[1],
  bandwidth = rdd_distance$bws[1, 1],
  n_effective = rdd_distance$N_h[1] + rdd_distance$N_h[2]
)

cat(sprintf("\nFirst-stage estimate: %.2f km (SE = %.2f)\n",
            first_stage_dist$estimate, first_stage_dist$se))
cat(sprintf("Interpretation: Crossing into legal state DECREASES distance to dispensary by %.1f km\n",
            -first_stage_dist$estimate))

# =============================================================================
# PART 2: Log Distance (Proportional Change)
# =============================================================================

cat("\n\nPART 2: LOG DISTANCE DISCONTINUITY\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

# Log transformation for proportional interpretation
crashes$log_dist_dispensary <- log(crashes$dist_to_dispensary_km + 1)

rdd_log_dist <- rdrobust(
  y = crashes$log_dist_dispensary,
  x = crashes$rv,
  c = 0,
  kernel = "triangular",
  p = 1
)

summary(rdd_log_dist)

first_stage_log <- list(
  outcome = "Log(distance to dispensary + 1)",
  estimate = rdd_log_dist$coef[1],
  se = rdd_log_dist$se[1],
  pct_change = (exp(rdd_log_dist$coef[1]) - 1) * 100
)

cat(sprintf("\nLog-distance estimate: %.3f (SE = %.3f)\n",
            first_stage_log$estimate, first_stage_log$se))
cat(sprintf("Percent change: %.1f%%\n", first_stage_log$pct_change))

# =============================================================================
# PART 3: Binary Access Indicator (Any Dispensary within 50km)
# =============================================================================

cat("\n\nPART 3: ACCESS INDICATOR DISCONTINUITY\n")
cat(paste0(rep("-", 50), collapse = ""), "\n\n")

crashes$has_dispensary_50km <- as.integer(crashes$dist_to_dispensary_km <= 50)

cat(sprintf("Share with dispensary within 50km: %.1f%%\n", 100 * mean(crashes$has_dispensary_50km)))
cat(sprintf("  Legal states: %.1f%%\n", 100 * mean(crashes$has_dispensary_50km[crashes$legal_status == "Legal"])))
cat(sprintf("  Prohibition states: %.1f%%\n", 100 * mean(crashes$has_dispensary_50km[crashes$legal_status == "Prohibition"])))

rdd_access <- rdrobust(
  y = crashes$has_dispensary_50km,
  x = crashes$rv,
  c = 0,
  kernel = "triangular",
  p = 1
)

summary(rdd_access)

first_stage_access <- list(
  outcome = "Has dispensary within 50km",
  estimate = rdd_access$coef[1],
  se = rdd_access$se[1]
)

cat(sprintf("\nAccess indicator estimate: %.3f (SE = %.3f)\n",
            first_stage_access$estimate, first_stage_access$se))
cat(sprintf("Interpretation: Crossing into legal state increases P(dispensary within 50km) by %.1f pp\n",
            100 * first_stage_access$estimate))

# =============================================================================
# PART 4: First-Stage Visualization
# =============================================================================

cat("\n\nCreating first-stage figure...\n")

# Use the same bandwidth as the first-stage RDD (approximately 24-30 km)
# to show what the RDD is actually estimating
bw_first_stage <- rdd_distance$bws[1, 1]  # Get the MSE-optimal bandwidth
cat(sprintf("Using first-stage bandwidth: %.1f km\n", bw_first_stage))

# Bin crashes by distance to border - restrict to ±50km for visualization
# but highlight the bandwidth region
crashes_binned <- crashes %>%
  filter(abs(rv) <= 50) %>%  # Restrict to closer region
  mutate(dist_bin = cut(rv, breaks = seq(-50, 50, by = 5), include.lowest = TRUE)) %>%
  group_by(dist_bin) %>%
  summarise(
    n = n(),
    mean_dist = mean(rv),
    mean_disp_dist = mean(dist_to_dispensary_km, na.rm = TRUE),
    se_disp_dist = sd(dist_to_dispensary_km, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  filter(n >= 10)  # Only bins with enough observations

# Plot: Distance to dispensary
# Note: rv is constructed as -running_var, so positive = legal, negative = prohibition
# To match paper convention (negative = legal, positive = prohibition), flip the x-axis
crashes_binned$mean_dist_paper <- -crashes_binned$mean_dist  # Flip for paper convention

# Within-bandwidth data for RDD-style fits
crashes_bw <- crashes %>%
  filter(abs(rv) <= bw_first_stage) %>%
  mutate(rv_paper = -rv)  # Flip for paper convention

p_dist <- ggplot(crashes_binned, aes(x = mean_dist_paper, y = mean_disp_dist)) +
  # Add shaded region for bandwidth
  annotate("rect", xmin = -bw_first_stage, xmax = bw_first_stage,
           ymin = -Inf, ymax = Inf, alpha = 0.1, fill = "blue") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(aes(size = n), alpha = 0.6, color = "steelblue") +
  # Linear fits on full ±50km range (descriptive)
  geom_smooth(data = filter(crashes_binned, mean_dist_paper > 0),
              method = "lm", se = TRUE, color = "darkred", linetype = "dashed", alpha = 0.3) +
  geom_smooth(data = filter(crashes_binned, mean_dist_paper <= 0),
              method = "lm", se = TRUE, color = "darkgreen", linetype = "dashed", alpha = 0.3) +
  scale_size_continuous(range = c(1, 4), guide = "none") +
  scale_x_continuous(limits = c(-50, 50)) +
  labs(
    x = "Distance to Border (km, negative = legal state)",
    y = "Mean Distance to Nearest Dispensary (km)",
    title = "First Stage: Dispensary Distance by Border Distance",
    subtitle = sprintf("Shaded region = RDD bandwidth (%.0f km); within bandwidth, level shift is small", bw_first_stage),
    caption = "Note: Point size proportional to bin sample size. Dashed lines are global linear fits (descriptive only)."
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

ggsave("../figures/fig07_first_stage.pdf", p_dist, width = 8, height = 5)
cat("Saved: fig07_first_stage.pdf\n")

# =============================================================================
# PART 5: Summary Table
# =============================================================================

first_stage_summary <- data.frame(
  outcome = c("Distance to dispensary (km)", "Log(distance + 1)", "Has dispensary within 50km"),
  estimate = c(first_stage_dist$estimate, first_stage_log$estimate, first_stage_access$estimate),
  se = c(first_stage_dist$se, first_stage_log$se, first_stage_access$se),
  interpretation = c(
    sprintf("%.1f km decrease", -first_stage_dist$estimate),
    sprintf("%.0f%% decrease", -100 * (exp(first_stage_log$estimate) - 1)),
    sprintf("%.0f pp increase", 100 * first_stage_access$estimate)
  )
)

first_stage_summary$p_value <- 2 * pnorm(-abs(first_stage_summary$estimate / first_stage_summary$se))
first_stage_summary$significant <- first_stage_summary$p_value < 0.05

print(first_stage_summary)

saveRDS(first_stage_summary, "../data/first_stage_results.rds")
write.csv(first_stage_summary, "../tables/tab06_first_stage.csv", row.names = FALSE)

# =============================================================================
# Summary
# =============================================================================

cat("\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("FIRST-STAGE VALIDATION COMPLETE\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

cat("Key findings:\n")
n_sig <- sum(first_stage_summary$significant)
cat(sprintf("  %d of 3 first-stage measures show significant discontinuity\n", n_sig))

if (n_sig >= 2) {
  cat("  CONCLUSION: Treatment intensity (cannabis access) jumps at border\n")
  cat("  The main RDD is testing the effect of a REAL change in access\n")
} else {
  cat("  WARNING: Weak first stage - access may not differ much at border\n")
  cat("  Null main result could reflect weak treatment, not lack of effect\n")
}
