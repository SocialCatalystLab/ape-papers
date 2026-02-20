## ============================================================================
## 05_figures.R — All figure generation
## Paper: Can Clean Cooking Save Lives? (apep_0422)
## ============================================================================

source(file.path(dirname(sys.frame(1)$ofile), "00_packages.R"))

district <- fread(file.path(data_dir, "district_analysis.csv"))
panel    <- fread(file.path(data_dir, "panel_analysis.csv"))
load(file.path(data_dir, "regression_objects.RData"))
load(file.path(data_dir, "robustness_objects.RData"))

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 1: Distribution of Baseline Clean Fuel Usage
# ═══════════════════════════════════════════════════════════════════════════════

fig1 <- ggplot(district[!is.na(ujjwala_exposure)],
               aes(x = nfhs4_val_clean_fuel)) +
  geom_histogram(aes(fill = exposure_tercile), bins = 40, alpha = 0.8,
                 color = "white", linewidth = 0.2) +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[3], apep_colors[2]),
                    name = "Ujjwala Exposure") +
  labs(
    title = "Distribution of Baseline Clean Fuel Usage Across Districts",
    subtitle = "NFHS-4 (2015-16): % households using clean fuel for cooking",
    x = "Clean Fuel for Cooking (%)",
    y = "Number of Districts",
    caption = paste0("Source: NFHS-4 district factsheets. N = ",
                     sum(!is.na(district$nfhs4_val_clean_fuel)), " districts.")
  ) +
  geom_vline(xintercept = median(district$nfhs4_val_clean_fuel, na.rm = TRUE),
             linetype = "dashed", color = "grey30") +
  annotate("text",
           x = median(district$nfhs4_val_clean_fuel, na.rm = TRUE) + 2,
           y = Inf, vjust = 2, hjust = 0, size = 3, color = "grey30",
           label = paste0("Median: ",
                          round(median(district$nfhs4_val_clean_fuel, na.rm = TRUE), 1), "%")) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_baseline_fuel_distribution.pdf"),
       fig1, width = 8, height = 5)
cat("Saved: fig1_baseline_fuel_distribution.pdf\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 2: First Stage — Baseline Fuel Gap vs Clean Fuel Improvement
# ═══════════════════════════════════════════════════════════════════════════════

fig2 <- ggplot(district[!is.na(ujjwala_exposure) & !is.na(delta_clean_fuel)],
               aes(x = ujjwala_exposure * 100, y = delta_clean_fuel)) +
  geom_point(alpha = 0.3, size = 1.2, color = apep_colors[1]) +
  geom_smooth(method = "lm", color = apep_colors[2], linewidth = 1,
              se = TRUE, fill = apep_colors[2], alpha = 0.15) +
  labs(
    title = "First Stage: Baseline Fuel Gap Predicts Clean Fuel Adoption",
    subtitle = "Change in clean fuel usage (NFHS-4 to NFHS-5) vs. baseline solid fuel dependence",
    x = "Baseline Solid Fuel Dependence (100 - NFHS-4 clean fuel %)",
    y = "Change in Clean Fuel Usage (pp)",
    caption = paste0("Source: NFHS-4/5 district factsheets. N = ",
                     sum(!is.na(district$ujjwala_exposure) & !is.na(district$delta_clean_fuel)),
                     " districts. Line: OLS fit with 95% CI.")
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_first_stage.pdf"), fig2, width = 8, height = 5)
cat("Saved: fig2_first_stage.pdf\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 3: Reduced Form — Health Outcomes by Exposure Tercile
# ═══════════════════════════════════════════════════════════════════════════════

outcomes_for_plot <- c("diarrhea_prev", "stunting", "underweight")
tercile_means <- panel[outcome_var %in% outcomes_for_plot &
                         !is.na(exposure_tercile) & !is.na(outcome),
                       .(mean_outcome = mean(outcome, na.rm = TRUE),
                         se_outcome = sd(outcome, na.rm = TRUE) / sqrt(.N),
                         n = .N),
                       by = .(outcome_var, exposure_tercile, period)]

tercile_means[, period_label := ifelse(period == 0, "NFHS-4\n(2015-16)", "NFHS-5\n(2019-21)")]
tercile_means[, outcome_label := fcase(
  outcome_var == "diarrhea_prev", "Diarrhea Prevalence (%)",
  outcome_var == "stunting", "Stunting (%)",
  outcome_var == "underweight", "Underweight (%)"
)]

fig3 <- ggplot(tercile_means,
               aes(x = period_label, y = mean_outcome,
                   color = exposure_tercile, group = exposure_tercile)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.8) +
  geom_errorbar(aes(ymin = mean_outcome - 1.96 * se_outcome,
                    ymax = mean_outcome + 1.96 * se_outcome),
                width = 0.1) +
  facet_wrap(~outcome_label, scales = "free_y", nrow = 1) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[3], apep_colors[2]),
                     name = "Ujjwala Exposure") +
  labs(
    title = "Child Health Outcomes by Ujjwala Exposure Tercile",
    subtitle = "Districts with higher Ujjwala exposure (low baseline clean fuel) show convergence",
    x = "",
    y = "District Mean (%)",
    caption = paste0("Source: NFHS-4/5 district factsheets. Error bars: 95% CI. N = ",
                     nrow(district[!is.na(exposure_tercile)]),
                     " districts.")
  ) +
  theme_apep() +
  theme(strip.text = element_text(face = "bold", size = 10))

ggsave(file.path(fig_dir, "fig3_health_by_tercile.pdf"), fig3, width = 12, height = 5)
cat("Saved: fig3_health_by_tercile.pdf\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 4: Clean Fuel Adoption by Exposure Tercile (First Stage Visual)
# ═══════════════════════════════════════════════════════════════════════════════

fuel_means <- panel[outcome_var == "clean_fuel" &
                      !is.na(exposure_tercile) & !is.na(outcome),
                    .(mean_outcome = mean(outcome, na.rm = TRUE),
                      se_outcome = sd(outcome, na.rm = TRUE) / sqrt(.N)),
                    by = .(exposure_tercile, period)]
fuel_means[, period_label := ifelse(period == 0, "NFHS-4\n(2015-16)", "NFHS-5\n(2019-21)")]

fig4 <- ggplot(fuel_means,
               aes(x = period_label, y = mean_outcome,
                   color = exposure_tercile, group = exposure_tercile)) +
  geom_point(size = 4) +
  geom_line(linewidth = 1) +
  geom_errorbar(aes(ymin = mean_outcome - 1.96 * se_outcome,
                    ymax = mean_outcome + 1.96 * se_outcome),
                width = 0.1) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[3], apep_colors[2]),
                     name = "Ujjwala Exposure") +
  labs(
    title = "Clean Fuel Adoption: Convergence Across Exposure Groups",
    subtitle = "High-exposure districts (low baseline clean fuel) show largest gains — Ujjwala first stage",
    x = "",
    y = "District Mean Clean Fuel Usage (%)",
    caption = "Source: NFHS-4/5 district factsheets. Error bars: 95% CI."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_fuel_by_tercile.pdf"), fig4, width = 8, height = 5)
cat("Saved: fig4_fuel_by_tercile.pdf\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 5: Binned Scatter — Fuel Gap vs Outcome Changes
# ═══════════════════════════════════════════════════════════════════════════════

# Binned scatter for diarrhea
dt_plot <- district[!is.na(ujjwala_exposure) & !is.na(delta_diarrhea)]
dt_plot[, exposure_bin := cut(ujjwala_exposure, breaks = 20, labels = FALSE)]
binned <- dt_plot[, .(mean_exp = mean(ujjwala_exposure),
                      mean_delta = mean(delta_diarrhea, na.rm = TRUE),
                      se_delta = sd(delta_diarrhea, na.rm = TRUE) / sqrt(.N)),
                  by = exposure_bin]

fig5a <- ggplot(binned, aes(x = mean_exp * 100, y = mean_delta)) +
  geom_point(size = 2.5, color = apep_colors[1]) +
  geom_errorbar(aes(ymin = mean_delta - 1.96 * se_delta,
                    ymax = mean_delta + 1.96 * se_delta),
                width = 1, color = apep_colors[1], alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = apep_colors[2], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  labs(title = "A. Diarrhea Prevalence Change",
       x = "Baseline Solid Fuel Dependence (%)",
       y = "Change in Diarrhea Prevalence (pp)") +
  theme_apep()

# Binned scatter for clean fuel (first stage)
dt_plot2 <- district[!is.na(ujjwala_exposure) & !is.na(delta_clean_fuel)]
dt_plot2[, exposure_bin := cut(ujjwala_exposure, breaks = 20, labels = FALSE)]
binned2 <- dt_plot2[, .(mean_exp = mean(ujjwala_exposure),
                        mean_delta = mean(delta_clean_fuel, na.rm = TRUE),
                        se_delta = sd(delta_clean_fuel, na.rm = TRUE) / sqrt(.N)),
                    by = exposure_bin]

fig5b <- ggplot(binned2, aes(x = mean_exp * 100, y = mean_delta)) +
  geom_point(size = 2.5, color = apep_colors[1]) +
  geom_errorbar(aes(ymin = mean_delta - 1.96 * se_delta,
                    ymax = mean_delta + 1.96 * se_delta),
                width = 1, color = apep_colors[1], alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = apep_colors[2], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  labs(title = "B. Clean Fuel Adoption Change",
       x = "Baseline Solid Fuel Dependence (%)",
       y = "Change in Clean Fuel Usage (pp)") +
  theme_apep()

fig5 <- cowplot::plot_grid(fig5a, fig5b, nrow = 1, align = "h")
cowplot::save_plot(file.path(fig_dir, "fig5_binned_scatter.pdf"),
                   fig5, base_width = 12, base_height = 5)
cat("Saved: fig5_binned_scatter.pdf\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 6: Placebo Test — Real vs Placebo Treatment
# ═══════════════════════════════════════════════════════════════════════════════

# Collect coefficients
coef_real <- coef(lm(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
                       baseline_sanitation + baseline_water + baseline_female_literate +
                       factor(state_code), data = district))["ujjwala_exposure"]
se_real <- sqrt(vcovHC(lm(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
                            baseline_sanitation + baseline_water + baseline_female_literate +
                            factor(state_code), data = district),
                       type = "HC1")["ujjwala_exposure", "ujjwala_exposure"])

coef_placebo <- coef(placebo_diarrhea)["electricity_gap"]
se_placebo <- sqrt(vcovHC(placebo_diarrhea, type = "HC1")["electricity_gap", "electricity_gap"])

placebo_dt <- data.table(
  test = c("Clean Fuel Gap\n(Treatment)", "Electricity Gap\n(Placebo)"),
  coef = c(coef_real, coef_placebo),
  se = c(se_real, se_placebo)
)

fig6 <- ggplot(placebo_dt, aes(x = test, y = coef)) +
  geom_point(size = 4, color = c(apep_colors[2], apep_colors[1])) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 0.15, linewidth = 0.8,
                color = c(apep_colors[2], apep_colors[1])) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  labs(
    title = "Placebo Test: Real vs. Placebo Treatment Effect on Diarrhea",
    subtitle = "Clean fuel gap (treatment) should predict diarrhea reduction; electricity gap (placebo) should not",
    x = "",
    y = "Coefficient (pp change in diarrhea prevalence)",
    caption = "Bars: 95% CI with HC1 robust standard errors. State FE and baseline controls included."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo_test.pdf"), fig6, width = 7, height = 5)
cat("Saved: fig6_placebo_test.pdf\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 7: Leave-One-State-Out Sensitivity
# ═══════════════════════════════════════════════════════════════════════════════

loso_diarrhea <- loso_all[outcome == "diarrhea"]

fig7 <- ggplot(loso_diarrhea, aes(x = reorder(factor(state_dropped), beta), y = beta)) +
  geom_point(size = 2, color = apep_colors[1]) +
  geom_errorbar(aes(ymin = beta - 1.96 * se, ymax = beta + 1.96 * se),
                width = 0.3, color = apep_colors[1], alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  coord_flip() +
  labs(
    title = "Leave-One-State-Out: Diarrhea Coefficient Stability",
    subtitle = "Each point drops one state; coefficient should remain stable",
    x = "State Dropped (Census Code)",
    y = "Coefficient on Ujjwala Exposure",
    caption = "Bars: 95% CI. Controls: baseline electricity, sanitation, water, literacy."
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave(file.path(fig_dir, "fig7_loso_sensitivity.pdf"), fig7, width = 8, height = 8)
cat("Saved: fig7_loso_sensitivity.pdf\n")

cat("\n=== All Figures Generated ===\n")
