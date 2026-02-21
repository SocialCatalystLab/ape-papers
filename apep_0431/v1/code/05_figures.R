## ────────────────────────────────────────────────────────────────────────────
## 05_figures.R — Publication-ready figures
## ────────────────────────────────────────────────────────────────────────────

source("00_packages.R")
load("../data/analysis_data.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

df <- panel[special_state == FALSE & !is.na(pop2001) & pop2001 > 0]
fig_dir <- "../figures"

# ════════════════════════════════════════════════════════════════════════════
# FIGURE 1: McCrary Density Test
# ════════════════════════════════════════════════════════════════════════════

# Histogram of village population near threshold
fig1_data <- df[pop2001 >= 200 & pop2001 <= 800]

p1 <- ggplot(fig1_data, aes(x = pop2001)) +
  geom_histogram(binwidth = 10, fill = apep_colors[1], alpha = 0.7,
                 color = "white", linewidth = 0.2) +
  geom_vline(xintercept = 500, linetype = "dashed", color = "red", linewidth = 0.8) +
  labs(
    title = "Distribution of Village Population Near PMGSY Threshold",
    subtitle = sprintf("McCrary test: t = %.2f, p = %.3f",
                       mccrary_result$t_stat, mccrary_result$p_value),
    x = "Village Population (Census 2001)",
    y = "Number of Villages"
  ) +
  annotate("text", x = 510, y = Inf, label = "Threshold = 500",
           hjust = 0, vjust = 1.5, size = 3.5, color = "red")

ggsave(file.path(fig_dir, "fig1_density.pdf"), p1, width = 7, height = 5)
cat("Saved: fig1_density.pdf\n")

# ════════════════════════════════════════════════════════════════════════════
# FIGURE 2: RDD Plots — Female vs Male Non-Agricultural Share
# ════════════════════════════════════════════════════════════════════════════

# Bin scatter for RDD visualization
make_binscatter <- function(dt, yvar, ylab, title_text) {
  d <- dt[!is.na(get(yvar)) & pop2001 >= 200 & pop2001 <= 800]
  d[, bin := cut(pop2001, breaks = seq(200, 800, by = 20), include.lowest = TRUE)]
  binned <- d[, .(y = mean(get(yvar), na.rm = TRUE),
                  x = mean(pop2001, na.rm = TRUE),
                  n = .N), by = bin]
  binned <- binned[!is.na(y)]

  ggplot(binned, aes(x = x, y = y)) +
    geom_point(size = 2, color = apep_colors[1], alpha = 0.8) +
    geom_vline(xintercept = 500, linetype = "dashed", color = "red", linewidth = 0.6) +
    geom_smooth(data = binned[x < 500], method = "lm", se = TRUE,
                color = apep_colors[2], fill = apep_colors[2], alpha = 0.15) +
    geom_smooth(data = binned[x >= 500], method = "lm", se = TRUE,
                color = apep_colors[2], fill = apep_colors[2], alpha = 0.15) +
    labs(title = title_text, x = "Village Population (Census 2001)", y = ylab)
}

p2a <- make_binscatter(df, "d_nonag_share_f",
                       "Change in Non-Agricultural Share",
                       "Panel A: Female Non-Agricultural Employment")
p2b <- make_binscatter(df, "d_nonag_share_m",
                       "Change in Non-Agricultural Share",
                       "Panel B: Male Non-Agricultural Employment")
p2c <- make_binscatter(df, "d_nonag_share_gap",
                       "Gender Gap Change (F - M)",
                       "Panel C: Gender Gap (Female - Male)")

p2 <- p2a / p2b / p2c +
  plot_annotation(
    title = "RDD Estimates: Roads and Gendered Structural Transformation",
    subtitle = "Binned scatter plots (bins of 20 persons) with linear fits on each side of cutoff"
  )

ggsave(file.path(fig_dir, "fig2_rdd_gender.pdf"), p2, width = 7, height = 12)
cat("Saved: fig2_rdd_gender.pdf\n")

# ════════════════════════════════════════════════════════════════════════════
# FIGURE 3: Dynamic RDD — Year-by-Year Nightlights Effects
# ════════════════════════════════════════════════════════════════════════════

dyn <- dynamic_results[!is.na(estimate)]
dyn[, period_color := fifelse(year < 2000, "Pre-PMGSY",
                       fifelse(year <= 2002, "Rollout", "Post-PMGSY"))]

p3 <- ggplot(dyn, aes(x = year, y = estimate)) +
  # Confidence intervals
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15,
              fill = apep_colors[1]) +
  # Point estimates
  geom_point(aes(color = period_color), size = 2.5) +
  geom_line(color = apep_colors[1], alpha = 0.5) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 2000, linetype = "dotted", color = "red", linewidth = 0.6) +
  # Annotations
  annotate("text", x = 2000.5, y = max(dyn$ci_upper, na.rm = TRUE),
           label = "PMGSY\nlaunched", hjust = 0, size = 3, color = "red") +
  scale_color_manual(
    name = "Period",
    values = c("Pre-PMGSY" = apep_colors[2],
               "Rollout" = apep_colors[4],
               "Post-PMGSY" = apep_colors[1])
  ) +
  labs(
    title = "Dynamic RDD: Year-by-Year Effect of PMGSY Eligibility on Nightlights",
    subtitle = "RDD estimate at population threshold (500) for each year; 95% robust CI",
    x = "Year",
    y = "RDD Estimate (log nightlights)"
  )

ggsave(file.path(fig_dir, "fig3_dynamic_rdd.pdf"), p3, width = 8, height = 5.5)
cat("Saved: fig3_dynamic_rdd.pdf\n")

# ════════════════════════════════════════════════════════════════════════════
# FIGURE 4: Bandwidth Sensitivity
# ════════════════════════════════════════════════════════════════════════════

bw <- bw_results[!is.na(estimate)]

p4 <- ggplot(bw, aes(x = bandwidth, y = estimate)) +
  geom_pointrange(aes(ymin = estimate - 1.96 * se_robust,
                      ymax = estimate + 1.96 * se_robust),
                  color = apep_colors[1], size = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = bw[multiplier == 1.0, bandwidth],
             linetype = "dotted", color = "red", alpha = 0.5) +
  annotate("text", x = bw[multiplier == 1.0, bandwidth], y = Inf,
           label = "Optimal\nBW", hjust = 0.5, vjust = 1.5, size = 3, color = "red") +
  labs(
    title = "Bandwidth Sensitivity: Female Non-Agricultural Share",
    subtitle = "Point estimates with 95% CI across bandwidth multipliers",
    x = "Bandwidth (Population Units)",
    y = "RDD Estimate"
  )

ggsave(file.path(fig_dir, "fig4_bw_sensitivity.pdf"), p4, width = 7, height = 5)
cat("Saved: fig4_bw_sensitivity.pdf\n")

# ════════════════════════════════════════════════════════════════════════════
# FIGURE 5: Placebo Thresholds
# ════════════════════════════════════════════════════════════════════════════

# Add actual threshold result
placebo_plot <- rbind(
  placebo_results[!is.na(estimate)],
  data.table(cutoff = 500,
             estimate = main_results[Outcome == "Change in female non-ag share", Estimate],
             se_robust = main_results[Outcome == "Change in female non-ag share", SE_robust],
             p_value = main_results[Outcome == "Change in female non-ag share", P_value])
)
placebo_plot[, is_real := cutoff == 500]

p5 <- ggplot(placebo_plot, aes(x = factor(cutoff), y = estimate, color = is_real)) +
  geom_pointrange(aes(ymin = estimate - 1.96 * se_robust,
                      ymax = estimate + 1.96 * se_robust), size = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c("FALSE" = "grey50", "TRUE" = apep_colors[1]),
                     guide = "none") +
  labs(
    title = "Placebo Threshold Tests: Female Non-Agricultural Share",
    subtitle = "RDD estimates at true (500) and placebo cutoffs",
    x = "Population Cutoff",
    y = "RDD Estimate"
  )

ggsave(file.path(fig_dir, "fig5_placebo_cutoffs.pdf"), p5, width = 7, height = 5)
cat("Saved: fig5_placebo_cutoffs.pdf\n")

# ════════════════════════════════════════════════════════════════════════════
# FIGURE 6: Regional Heterogeneity
# ════════════════════════════════════════════════════════════════════════════

reg <- region_results[!is.na(estimate_f)]
reg_long <- rbind(
  reg[, .(region, estimate = estimate_f, se = se_f, gender = "Female")],
  reg[, .(region, estimate = estimate_m, se = se_m, gender = "Male")]
)
reg_long <- reg_long[!is.na(estimate)]

p6 <- ggplot(reg_long, aes(x = region, y = estimate, color = gender)) +
  geom_pointrange(aes(ymin = estimate - 1.96 * se,
                      ymax = estimate + 1.96 * se),
                  position = position_dodge(width = 0.3), size = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_color_manual(name = "Gender",
                     values = c("Female" = apep_colors[1],
                                "Male" = apep_colors[2])) +
  labs(
    title = "Regional Heterogeneity in Road Effects on Structural Transformation",
    subtitle = "RDD estimates at 500 threshold by Indian region",
    x = "Region",
    y = "RDD Estimate (Change in Non-Ag Share)"
  )

ggsave(file.path(fig_dir, "fig6_regional_het.pdf"), p6, width = 7, height = 5)
cat("Saved: fig6_regional_het.pdf\n")

# ════════════════════════════════════════════════════════════════════════════
# FIGURE 7: Covariate Balance
# ════════════════════════════════════════════════════════════════════════════

cov <- cov_balance[!is.na(Estimate)]

p7 <- ggplot(cov, aes(x = Covariate, y = Estimate)) +
  geom_pointrange(aes(ymin = Estimate - 1.96 * SE,
                      ymax = Estimate + 1.96 * SE),
                  color = apep_colors[1], size = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  coord_flip() +
  labs(
    title = "Covariate Balance at PMGSY Threshold",
    subtitle = "RDD estimates for baseline covariates (should be near zero)",
    x = "",
    y = "RDD Estimate"
  )

ggsave(file.path(fig_dir, "fig7_covariate_balance.pdf"), p7, width = 7, height = 4.5)
cat("Saved: fig7_covariate_balance.pdf\n")

cat("\nAll figures saved to figures/\n")
