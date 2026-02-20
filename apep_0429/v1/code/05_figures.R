## 05_figures.R — Publication-quality figures for PMGSY dynamic RDD
## APEP-0429

source("00_packages.R")
load("../data/analysis_data.RData")
load("../data/main_results.RData")

fig_dir <- "../figures"

## ── Figure 1: McCrary Density Test ──────────────────────────────────
cat("Generating Figure 1: McCrary density test...\n")
mccrary_plot <- rddensity(X = sample$pop_centered, c = 0)

pdf(file.path(fig_dir, "fig1_mccrary.pdf"), width = 7, height = 5)
rdplotdensity(mccrary_plot, sample$pop_centered,
              plotRange = c(-300, 300),
              title = "",
              xlabel = "Census 2001 Population (centered at 500)",
              ylabel = "Density")
dev.off()
cat("  Saved fig1_mccrary.pdf\n")

## ── Figure 2: RDD Scatter Plots for Key Years ──────────────────────
cat("Generating Figure 2: RDD scatter plots...\n")

make_rdplot <- function(data, y_col, title_text, fname) {
  y <- asinh(data[[y_col]])
  valid <- !is.na(y) & !is.na(data$pop_centered) &
    abs(data$pop_centered) <= 300
  tryCatch({
    pdf(file.path(fig_dir, fname), width = 7, height = 5)
    rdplot(y[valid], data$pop_centered[valid], c = 0, nbins = c(40, 40),
           title = "", x.label = "Population (centered at 500)",
           y.label = paste0("asinh(", gsub("_", " ", y_col), ")"))
    dev.off()
  }, error = function(e) {
    cat("  Error generating", fname, ":", e$message, "\n")
    if (dev.cur() > 1) dev.off()
  })
}

make_rdplot(sample, "dmsp_1998", "DMSP 1998 (Pre-Treatment)", "fig2a_rdd_dmsp1998.pdf")
make_rdplot(sample, "dmsp_2005", "DMSP 2005 (Early Post)", "fig2b_rdd_dmsp2005.pdf")
make_rdplot(sample, "dmsp_2013", "DMSP 2013 (Late Post)", "fig2c_rdd_dmsp2013.pdf")
make_rdplot(sample, "viirs_2020", "VIIRS 2020 (Long Run)", "fig2d_rdd_viirs2020.pdf")
cat("  Saved fig2 panels\n")

## ── Figure 3: Dynamic Treatment Effect Plot ─────────────────────────
cat("Generating Figure 3: Dynamic treatment effects...\n")

## Prepare data
dyn_plot <- copy(dynamic_all)
dyn_plot[, ci_lo := estimate - 1.96 * se]
dyn_plot[, ci_hi := estimate + 1.96 * se]

## DMSP series
p_dmsp <- ggplot(dyn_plot[sensor == "DMSP"],
                 aes(x = year, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = 2000, linetype = "dotted", color = "#D55E00",
             linewidth = 0.8) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15,
              fill = "#0072B2") +
  geom_point(color = "#0072B2", size = 2) +
  geom_line(color = "#0072B2", linewidth = 0.5) +
  annotate("text", x = 2000.5, y = max(dyn_plot[sensor == "DMSP"]$ci_hi, na.rm = TRUE),
           label = "PMGSY\nlaunched", hjust = 0, size = 3, color = "#D55E00") +
  scale_x_continuous(breaks = seq(1994, 2013, 2)) +
  labs(x = "Year", y = "RDD Estimate (asinh nightlights)",
       subtitle = "Panel A: DMSP (1994\u20132013)") +
  theme_apep()

## VIIRS series
p_viirs <- ggplot(dyn_plot[sensor == "VIIRS"],
                  aes(x = year, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15,
              fill = "#009E73") +
  geom_point(color = "#009E73", size = 2) +
  geom_line(color = "#009E73", linewidth = 0.5) +
  scale_x_continuous(breaks = seq(2012, 2023, 2)) +
  labs(x = "Year", y = "RDD Estimate (asinh nightlights)",
       subtitle = "Panel B: VIIRS (2012\u20132023)") +
  theme_apep()

## Combined
p_dynamic <- p_dmsp / p_viirs +
  plot_annotation(title = "Dynamic RDD Estimates: Effect of PMGSY Eligibility on Nightlights",
                  theme = theme(plot.title = element_text(size = 14, face = "bold")))

ggsave(file.path(fig_dir, "fig3_dynamic_rdd.pdf"), p_dynamic,
       width = 8, height = 10)
cat("  Saved fig3_dynamic_rdd.pdf\n")

## ── Figure 4: Covariate Balance ─────────────────────────────────────
cat("Generating Figure 4: Covariate balance...\n")

bal_plot <- copy(balance_results)
bal_plot[, ci_lo := estimate - 1.96 * se]
bal_plot[, ci_hi := estimate + 1.96 * se]
bal_plot[, var_label := gsub("balance_", "", outcome)]
bal_plot[, var_label := factor(var_label,
                               levels = rev(c("pop91", "lit_rate_91",
                                              "female_share_01", "sc_share_01",
                                              "st_share_01")))]

p_balance <- ggplot(bal_plot, aes(x = estimate, y = var_label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey60") +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2,
                 color = "#0072B2") +
  geom_point(color = "#0072B2", size = 3) +
  labs(x = "RDD Estimate (Discontinuity at 500)",
       y = "",
       title = "Covariate Balance at PMGSY Threshold") +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_balance.pdf"), p_balance,
       width = 7, height = 4.5)
cat("  Saved fig4_balance.pdf\n")

## ── Figure 5: Bandwidth Sensitivity ─────────────────────────────────
cat("Generating Figure 5: Bandwidth sensitivity...\n")
load("../data/robustness_results.RData")

p_bw <- ggplot(bw_results, aes(x = h, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_ribbon(aes(ymin = estimate - 1.96 * se,
                  ymax = estimate + 1.96 * se), alpha = 0.15,
              fill = "#009E73") +
  geom_point(color = "#009E73", size = 3) +
  geom_line(color = "#009E73", linewidth = 0.5) +
  labs(x = "Bandwidth (population units)",
       y = "RDD Estimate",
       title = "Bandwidth Sensitivity: VIIRS 2020") +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_bandwidth.pdf"), p_bw,
       width = 7, height = 5)
cat("  Saved fig5_bandwidth.pdf\n")

## ── Figure 6: Placebo Thresholds ────────────────────────────────────
cat("Generating Figure 6: Placebo thresholds...\n")

placebo_plot <- copy(placebo_results)
placebo_plot[, ci_lo := estimate - 1.96 * se]
placebo_plot[, ci_hi := estimate + 1.96 * se]
## Add the true threshold
true_est <- data.table(threshold = 500,
                       estimate = dynamic_all[year == 2020 & sensor == "VIIRS"]$estimate,
                       se = dynamic_all[year == 2020 & sensor == "VIIRS"]$se)
true_est[, ci_lo := estimate - 1.96 * se]
true_est[, ci_hi := estimate + 1.96 * se]
placebo_all <- rbind(placebo_plot[, .(threshold, estimate, ci_lo, ci_hi)],
                     true_est[, .(threshold, estimate, ci_lo, ci_hi)])

p_placebo <- ggplot(placebo_all, aes(x = threshold, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 20,
                color = ifelse(placebo_all$threshold == 500, "#D55E00", "#0072B2")) +
  geom_point(size = 3,
             color = ifelse(placebo_all$threshold == 500, "#D55E00", "#0072B2")) +
  scale_x_continuous(breaks = c(200, 300, 400, 500, 600, 700, 800)) +
  labs(x = "Population Threshold",
       y = "RDD Estimate (asinh VIIRS 2020)",
       title = "Placebo Thresholds (500 = True PMGSY Threshold)") +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo.pdf"), p_placebo,
       width = 7, height = 5)
cat("  Saved fig6_placebo.pdf\n")

cat("\n=== All figures generated ===\n")
