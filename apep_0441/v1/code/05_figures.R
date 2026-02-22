## ============================================================================
## 05_figures.R — Generate all figures
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")
load("../data/analysis_panel.RData")
load("../data/main_results.RData")
load("../data/cs_results.RData")
load("../data/robustness_results.RData")
load("../data/ri_results.RData")
load("../data/es_coefs.RData")

fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel_2000 <- panel_dmsp[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]

## ============================================================================
## Figure 1: Raw nightlight trends by treatment group
## ============================================================================

trends <- panel_2000[, .(
  mean_nl = mean(nightlights, na.rm = TRUE),
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, treated)]
trends[, group := fifelse(treated == 1, "New State Districts", "Parent State Districts")]

fig1 <- ggplot(trends, aes(x = year, y = mean_log_nl, color = group, linetype = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2001, y = max(trends$mean_log_nl) * 0.95,
           label = "State creation\n(Nov 2000)", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_linetype_manual(values = c("solid", "dashed")) +
  labs(
    title = "Average Nightlight Intensity: New vs Parent State Districts",
    subtitle = "DMSP calibrated luminosity, district-level means (1994-2013)",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL, linetype = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_trends.pdf"), fig1, width = 8, height = 5)
cat("Figure 1 saved: trends\n")

## ============================================================================
## Figure 2: Event study plot (TWFE)
## ============================================================================

# Add reference period (t = -1, coef = 0)
es_plot_data <- rbind(
  es_coefs[, .(event_time, estimate, se)],
  data.table(event_time = -1L, estimate = 0, se = 0)
)
es_plot_data[, ci_lo := estimate - 1.96 * se]
es_plot_data[, ci_hi := estimate + 1.96 * se]
es_plot_data <- es_plot_data[order(event_time)]

fig2 <- ggplot(es_plot_data, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 2.5) +
  labs(
    title = "Event Study: Effect of State Creation on Nightlight Intensity",
    subtitle = "TWFE estimates with 95% CI, clustered at state level. Reference period: t = -1",
    x = "Years Relative to State Creation (2001 = first full year)",
    y = "Coefficient (log nightlights)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), fig2, width = 8, height = 5)
cat("Figure 2 saved: event study\n")

## ============================================================================
## Figure 3: Callaway-Sant'Anna event study
## ============================================================================

fig3_data <- tryCatch({
  cs_es_tidy <- data.table(
    event_time = cs_es$egt,
    estimate = cs_es$att.egt,
    se = cs_es$se.egt
  )
  cs_es_tidy[, ci_lo := estimate - 1.96 * se]
  cs_es_tidy[, ci_hi := estimate + 1.96 * se]
  cs_es_tidy
}, error = function(e) NULL)

if (!is.null(fig3_data)) {
  fig3 <- ggplot(fig3_data, aes(x = event_time, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[3]) +
    geom_line(color = apep_colors[3], linewidth = 0.8) +
    geom_point(color = apep_colors[3], size = 2.5) +
    labs(
      title = "Callaway-Sant'Anna Event Study",
      subtitle = "Heterogeneity-robust group-time ATTs aggregated dynamically",
      x = "Years Relative to State Creation",
      y = "ATT (log nightlights)"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig3_cs_event_study.pdf"), fig3, width = 8, height = 5)
  cat("Figure 3 saved: CS event study\n")
}

## ============================================================================
## Figure 4: Heterogeneity by state pair
## ============================================================================

pair_trends <- panel_2000[, .(
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, state_pair, treated)]
pair_trends[, group := fifelse(treated == 1, "New State", "Parent State")]

# Nice labels
pair_labels <- c("UK-UP" = "Uttarakhand vs UP",
                 "JH-BR" = "Jharkhand vs Bihar",
                 "CG-MP" = "Chhattisgarh vs MP")

fig4 <- ggplot(pair_trends, aes(x = year, y = mean_log_nl, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  facet_wrap(~state_pair, labeller = labeller(state_pair = pair_labels),
             scales = "free_y") +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(
    title = "Nightlight Trends by State Pair",
    subtitle = "Heterogeneous trajectories across the three bifurcations",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL
  ) +
  theme_apep() +
  theme(strip.text = element_text(face = "bold", size = 10))

ggsave(file.path(fig_dir, "fig4_pair_trends.pdf"), fig4, width = 10, height = 4)
cat("Figure 4 saved: pair trends\n")

## ============================================================================
## Figure 5: Randomization inference distribution
## ============================================================================

ri_df <- data.table(stat = ri_stats[!is.na(ri_stats)])

fig5 <- ggplot(ri_df, aes(x = stat)) +
  geom_histogram(bins = 20, fill = "grey70", color = "grey50", alpha = 0.7) +
  geom_vline(xintercept = actual_stat, color = apep_colors[1], linewidth = 1.2,
             linetype = "solid") +
  annotate("text", x = actual_stat, y = Inf, vjust = -0.5,
           label = paste0("Actual = ", round(actual_stat, 3)),
           color = apep_colors[1], fontface = "bold", size = 3.5) +
  labs(
    title = "Randomization Inference: Distribution of Placebo Estimates",
    subtitle = paste0("All C(6,3) = 20 permutations of treatment across states. RI p-value = ",
                      round(ri_pvalue, 3)),
    x = "Placebo Treatment Effect (log nightlights)",
    y = "Count"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_ri_distribution.pdf"), fig5, width = 7, height = 5)
cat("Figure 5 saved: RI distribution\n")

## ============================================================================
## Figure 6: Capital vs non-capital districts
## ============================================================================

capital_trends <- panel_2000[, .(
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, is_capital, treated)]

capital_trends[, group := fifelse(
  is_capital == 1, "New State Capital",
  fifelse(treated == 1, "New State (Non-Capital)", "Parent State")
)]

fig6 <- ggplot(capital_trends, aes(x = year, y = mean_log_nl, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = apep_colors[c(3, 1, 2)]) +
  labs(
    title = "Capital City Effect: New State Capitals vs Other Districts",
    subtitle = "New state capitals (Dehradun, Ranchi, Raipur) vs non-capital treated vs parent districts",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_capital_effect.pdf"), fig6, width = 8, height = 5)
cat("Figure 6 saved: capital effect\n")

## ============================================================================
## Figure 7: Extended panel (1994-2023, DMSP + VIIRS)
## ============================================================================

panel_ext <- panel_full[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]
ext_trends <- panel_ext[, .(
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, treated)]
ext_trends[, group := fifelse(treated == 1, "New State Districts", "Parent State Districts")]
ext_trends[, sensor := fifelse(year <= 2013, "DMSP", "VIIRS")]

fig7 <- ggplot(ext_trends, aes(x = year, y = mean_log_nl, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(aes(shape = sensor), size = 2) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 2013.5, linetype = "dotted", color = "grey70") +
  annotate("text", x = 2013.5, y = min(ext_trends$mean_log_nl) * 1.05,
           label = "DMSP→VIIRS", size = 2.5, color = "grey50", hjust = 1.1) +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(
    title = "Long-Run Trajectories: Two Decades After State Creation",
    subtitle = "Calibrated DMSP (1994-2013) + VIIRS (2014-2023)",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL, shape = "Sensor"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_extended_panel.pdf"), fig7, width = 9, height = 5)
cat("Figure 7 saved: extended panel\n")

cat("\n=== All figures generated ===\n")
