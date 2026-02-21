# ============================================================================
# 05_figures.R — Generate all figures
# Multi-Level Political Alignment and Local Development in India
# ============================================================================

source("00_packages.R")
data_dir <- "../data"
fig_dir  <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
load(file.path(data_dir, "analysis_data.RData"))
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

rdd_data_state <- results$rdd_data_state
rdd_data_center <- results$rdd_data_center

# ============================================================================
# Figure 1: RDD Plot — State Alignment
# ============================================================================
cat("Generating Figure 1: State Alignment RDD...\n")

# Bin the running variable
rdd_state_plot <- copy(rdd_data_state)
rdd_state_plot[, margin_bin := round(rdd_margin_state, 2)]
binned <- rdd_state_plot[, .(y = mean(post_log_nl, na.rm = TRUE),
                              se = sd(post_log_nl, na.rm = TRUE) / sqrt(.N),
                              n = .N),
                          by = margin_bin]
binned <- binned[n >= 5]  # Drop thin bins

# Separate fits on each side
left <- rdd_state_plot[rdd_margin_state < 0 & abs(rdd_margin_state) <= 0.20]
right <- rdd_state_plot[rdd_margin_state >= 0 & rdd_margin_state <= 0.20]

fig1 <- ggplot() +
  geom_point(data = binned[abs(margin_bin) <= 0.20],
             aes(x = margin_bin, y = y), size = 1.8, alpha = 0.6, color = "grey30") +
  geom_smooth(data = left, aes(x = rdd_margin_state, y = post_log_nl),
              method = "lm", formula = y ~ x, se = TRUE,
              color = "#E74C3C", fill = "#E74C3C", alpha = 0.15) +
  geom_smooth(data = right, aes(x = rdd_margin_state, y = post_log_nl),
              method = "lm", formula = y ~ x, se = TRUE,
              color = "#2980B9", fill = "#2980B9", alpha = 0.15) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  labs(x = "Vote Margin (Ruling Party − Opposition)",
       y = "Log Nightlights (Post-Election Average)",
       title = "State-Level Political Alignment and Nighttime Lights",
       subtitle = "No discontinuity at the threshold") +
  scale_x_continuous(labels = percent_format()) +
  coord_cartesian(xlim = c(-0.20, 0.20))

ggsave(file.path(fig_dir, "fig1_rdd_state.pdf"), fig1, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig1_rdd_state.png"), fig1, width = 7, height = 5, dpi = 300)

# ============================================================================
# Figure 2: RDD Plot — Center Alignment
# ============================================================================
cat("Generating Figure 2: Center Alignment RDD...\n")

rdd_center_plot <- copy(rdd_data_center)
rdd_center_plot[, margin_bin := round(rdd_margin_center, 2)]
binned_c <- rdd_center_plot[, .(y = mean(post_log_nl, na.rm = TRUE),
                                 se = sd(post_log_nl, na.rm = TRUE) / sqrt(.N),
                                 n = .N),
                             by = margin_bin]
binned_c <- binned_c[n >= 5]

left_c <- rdd_center_plot[rdd_margin_center < 0 & abs(rdd_margin_center) <= 0.20]
right_c <- rdd_center_plot[rdd_margin_center >= 0 & rdd_margin_center <= 0.20]

fig2 <- ggplot() +
  geom_point(data = binned_c[abs(margin_bin) <= 0.20],
             aes(x = margin_bin, y = y), size = 1.8, alpha = 0.6, color = "grey30") +
  geom_smooth(data = left_c, aes(x = rdd_margin_center, y = post_log_nl),
              method = "lm", formula = y ~ x, se = TRUE,
              color = "#E74C3C", fill = "#E74C3C", alpha = 0.15) +
  geom_smooth(data = right_c, aes(x = rdd_margin_center, y = post_log_nl),
              method = "lm", formula = y ~ x, se = TRUE,
              color = "#2980B9", fill = "#2980B9", alpha = 0.15) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  labs(x = "Vote Margin (Central Party − Opposition)",
       y = "Log Nightlights (Post-Election Average)",
       title = "Center-Level Political Alignment and Nighttime Lights",
       subtitle = "No discontinuity at the threshold") +
  scale_x_continuous(labels = percent_format()) +
  coord_cartesian(xlim = c(-0.20, 0.20))

ggsave(file.path(fig_dir, "fig2_rdd_center.pdf"), fig2, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig2_rdd_center.png"), fig2, width = 7, height = 5, dpi = 300)

# ============================================================================
# Figure 3: McCrary Density Test
# ============================================================================
cat("Generating Figure 3: McCrary Density...\n")

density_plot_data <- data.table(
  x = rdd_data_state$rdd_margin_state
)

fig3 <- ggplot(density_plot_data[abs(x) <= 0.30], aes(x = x)) +
  geom_histogram(aes(y = after_stat(density)), bins = 60,
                 fill = "steelblue", alpha = 0.5, color = "white") +
  geom_density(linewidth = 0.8, color = "darkred") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  labs(x = "Vote Margin (Ruling Party − Opposition)",
       y = "Density",
       title = "Distribution of Vote Margins",
       subtitle = "McCrary density test: borderline (p = 0.045)") +
  scale_x_continuous(labels = percent_format())

ggsave(file.path(fig_dir, "fig3_mccrary.pdf"), fig3, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig3_mccrary.png"), fig3, width = 7, height = 5, dpi = 300)

# ============================================================================
# Figure 4: Bandwidth Sensitivity
# ============================================================================
cat("Generating Figure 4: Bandwidth Sensitivity...\n")

bw_state <- robustness$bw_results_state
bw_center <- robustness$bw_results_center

bw_state[, type := "State Alignment"]
bw_center[, type := "Center Alignment"]
bw_both <- rbind(bw_state, bw_center)

fig4 <- ggplot(bw_both, aes(x = h, y = est, ymin = ci_lo, ymax = ci_hi)) +
  geom_ribbon(alpha = 0.2, fill = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ type) +
  labs(x = "Bandwidth (h)", y = "RDD Estimate (τ)",
       title = "Bandwidth Sensitivity of Alignment Effects",
       subtitle = "Estimates with 95% confidence intervals") +
  scale_x_continuous(labels = percent_format())

ggsave(file.path(fig_dir, "fig4_bw_sensitivity.pdf"), fig4, width = 9, height = 4.5)
ggsave(file.path(fig_dir, "fig4_bw_sensitivity.png"), fig4, width = 9, height = 4.5, dpi = 300)

# ============================================================================
# Figure 5: Dynamic Effects
# ============================================================================
cat("Generating Figure 5: Dynamic Effects...\n")

dyn_s <- robustness$dynamic_state
dyn_c <- robustness$dynamic_center
dyn_s[, type := "State Alignment"]
dyn_c[, type := "Center Alignment"]
dyn_both <- rbind(dyn_s, dyn_c)

fig5 <- ggplot(dyn_both, aes(x = rel_year, y = est,
                              ymin = est - 1.96 * se,
                              ymax = est + 1.96 * se)) +
  geom_ribbon(alpha = 0.15, fill = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.8) +
  geom_point(size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey50") +
  facet_wrap(~ type) +
  labs(x = "Years Relative to Election",
       y = "RDD Estimate (τ)",
       title = "Dynamic Alignment Effects Over the Election Cycle",
       subtitle = "Pre-election (left of dashed line) and post-election effects") +
  scale_x_continuous(breaks = -2:5)

ggsave(file.path(fig_dir, "fig5_dynamic.pdf"), fig5, width = 9, height = 4.5)
ggsave(file.path(fig_dir, "fig5_dynamic.png"), fig5, width = 9, height = 4.5, dpi = 300)

# ============================================================================
# Figure 6: Covariate Balance
# ============================================================================
cat("Generating Figure 6: Covariate Balance...\n")

covariates <- c("log_baseline", "pop", "lit_rate", "sc_share",
                "st_share", "work_rate", "ag_share")
cov_labels <- c("Log Baseline NL", "Population", "Literacy Rate",
                "SC Share", "ST Share", "Work Participation", "Agriculture Share")

bal_results <- data.table()
for (i in seq_along(covariates)) {
  cv <- covariates[i]
  y <- rdd_data_state[[cv]]
  x <- rdd_data_state$rdd_margin_state
  valid <- !is.na(y) & !is.na(x) & is.finite(y)
  if (sum(valid) >= 100) {
    bal <- tryCatch({
      rdrobust(y = y[valid], x = x[valid], c = 0, p = 1, kernel = "triangular")
    }, error = function(e) NULL)
    if (!is.null(bal)) {
      bal_results <- rbind(bal_results, data.table(
        var = cov_labels[i],
        est = bal$coef[1], se = bal$se[1], pval = bal$pv[1]
      ))
    }
  }
}

if (nrow(bal_results) > 0) {
  # Standardize: divide by pooled SD for visualization
  bal_results[, ci_lo := est - 1.96 * se]
  bal_results[, ci_hi := est + 1.96 * se]
  bal_results[, sig := ifelse(pval < 0.05, "p < 0.05", "p ≥ 0.05")]
  bal_results[, var := factor(var, levels = rev(cov_labels))]

  fig6 <- ggplot(bal_results, aes(x = est, y = var, color = sig)) +
    geom_point(size = 3) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    scale_color_manual(values = c("p < 0.05" = "#E74C3C", "p ≥ 0.05" = "steelblue")) +
    labs(x = "RDD Estimate", y = NULL, color = NULL,
         title = "Covariate Balance at the Cutoff",
         subtitle = "Baseline covariates should show no discontinuity") +
    theme(legend.position = "bottom")

  ggsave(file.path(fig_dir, "fig6_balance.pdf"), fig6, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig6_balance.png"), fig6, width = 7, height = 5, dpi = 300)
}

cat("\nAll figures saved to", fig_dir, "\n")
