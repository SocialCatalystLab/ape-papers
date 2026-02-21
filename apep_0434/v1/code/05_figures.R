## ============================================================
## 05_figures.R — Publication-ready figures
## ============================================================

source("code/00_packages.R")

cat("=== Loading data and results ===\n")
census  <- readRDS("data/census_panel.rds")
nl_dist <- readRDS("data/nl_district_panel.rds")
results <- readRDS("data/main_results.rds")
rob     <- readRDS("data/robustness_results.rds")

fig_dir <- "figures"

# ============================================================
# Figure 1: Event Study — Nightlights CS-DiD
# ============================================================
cat("Figure 1: Event study (nightlights CS-DiD)...\n")

if (!is.null(results$es_out)) {
  es <- results$es_out
  es_df <- data.frame(
    time = es$egt,
    att  = es$att.egt,
    se   = es$se.egt
  )
  es_df$ci_lo <- es_df$att - 1.96 * es_df$se
  es_df$ci_hi <- es_df$att + 1.96 * es_df$se

  p1 <- ggplot(es_df, aes(x = time, y = att)) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                alpha = 0.2, fill = apep_colors[1]) +
    geom_point(color = apep_colors[1], size = 2.5) +
    geom_line(color = apep_colors[1], linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    labs(
      x = "Years Relative to MGNREGA Introduction",
      y = "ATT (Log Nightlights)",
      title = "Dynamic Treatment Effects of MGNREGA on Economic Activity",
      subtitle = "Callaway & Sant'Anna (2021) estimator; 95% pointwise CI",
      caption = "Notes: Treatment groups are Phase I (2006) and Phase II (2007) districts.\nControl group: Phase III districts (not yet treated). Outcome: log(total calibrated nightlights + 1)."
    ) +
    theme_apep() +
    annotate("text", x = min(es_df$time) + 1, y = max(es_df$ci_hi) * 0.9,
             label = "Pre-treatment", hjust = 0, size = 3.5, color = "grey50") +
    annotate("text", x = 1, y = max(es_df$ci_hi) * 0.9,
             label = "Post-treatment", hjust = 0, size = 3.5, color = "grey50")

  ggsave(file.path(fig_dir, "fig1_event_study_nightlights.pdf"),
         p1, width = 8, height = 5.5)
  cat("  Saved fig1_event_study_nightlights.pdf\n")
}

# ============================================================
# Figure 2: Worker Composition Changes by Phase
# ============================================================
cat("Figure 2: Worker composition changes...\n")

# Compute mean changes by phase
comp_df <- census[, .(
  `Non-Farm`         = mean(d_nonfarm_share, na.rm = TRUE),
  `Ag. Labor`        = mean(d_aglabor_share, na.rm = TRUE),
  `Cultivators`      = mean(d_cultivator_share, na.rm = TRUE),
  `HH Industry`      = mean(d_hh_ind_share, na.rm = TRUE)
), by = nrega_phase]

comp_long <- melt(comp_df, id.vars = "nrega_phase",
                  variable.name = "Category", value.name = "Change")
comp_long[, Phase := factor(nrega_phase, labels = c("Phase I\n(2006)",
                                                      "Phase II\n(2007)",
                                                      "Phase III\n(2008)"))]

p2 <- ggplot(comp_long, aes(x = Category, y = Change, fill = Phase)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8),
           width = 0.7) +
  geom_hline(yintercept = 0, color = "grey30") +
  scale_fill_manual(values = apep_colors[1:3]) +
  labs(
    x = "", y = "Mean Change in Worker Share (2001 to 2011)",
    title = "Structural Transformation by MGNREGA Phase",
    subtitle = "Change in village-level worker composition shares, Census 2001 to 2011",
    caption = "Notes: Each bar shows the mean change in worker category share across all villages\nin the corresponding MGNREGA phase. N = 580,000+ villages."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(size = 10))

ggsave(file.path(fig_dir, "fig2_worker_composition.pdf"),
       p2, width = 8, height = 5.5)
cat("  Saved fig2_worker_composition.pdf\n")

# ============================================================
# Figure 3: Pre-treatment Nightlight Trends by Phase
# ============================================================
cat("Figure 3: Pre-treatment nightlight trends...\n")

nl_trends <- nl_dist[year >= 2000 & year <= 2013,
                     .(mean_log_light = mean(log_light, na.rm = TRUE)),
                     by = .(year, nrega_phase)]
nl_trends[, Phase := factor(nrega_phase,
                            labels = c("Phase I (2006)", "Phase II (2007)",
                                        "Phase III (2008)"))]

p3 <- ggplot(nl_trends, aes(x = year, y = mean_log_light, color = Phase)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2005.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2005.5, y = max(nl_trends$mean_log_light),
           label = "MGNREGA\nPhase I", hjust = 1.1, size = 3, color = "grey50") +
  scale_color_manual(values = apep_colors[1:3]) +
  labs(
    x = "Year", y = "Mean Log(Nightlights + 1)",
    title = "Nighttime Luminosity Trends by MGNREGA Phase",
    subtitle = "District-level means, DMSP calibrated nightlights 2000–2013",
    caption = "Notes: Vertical dashed line marks onset of MGNREGA Phase I (Feb 2006).\nPre-treatment trends are broadly similar but a formal test detects\na significant differential trend (see Section 5.3)."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_nightlight_trends.pdf"),
       p3, width = 8, height = 5.5)
cat("  Saved fig3_nightlight_trends.pdf\n")

# ============================================================
# Figure 4: Gender Heterogeneity — Female vs Male Worker Shifts
# ============================================================
cat("Figure 4: Gender heterogeneity...\n")

gender_df <- census[, .(
  Male_NonFarm    = mean(d_nonfarm_share, na.rm = TRUE),
  Female_NonFarm  = mean(d_f_nonfarm_share, na.rm = TRUE),
  Male_AgLabor    = mean(d_aglabor_share, na.rm = TRUE),
  Female_AgLabor  = mean(d_f_aglabor_share, na.rm = TRUE)
), by = .(Phase = factor(nrega_phase,
                         labels = c("Phase I\n(2006)", "Phase II\n(2007)",
                                     "Phase III\n(2008)")))]

gender_long <- melt(gender_df, id.vars = "Phase")
gender_long[, `:=`(
  Gender   = ifelse(grepl("Male_", variable), "Male", "Female"),
  Outcome  = ifelse(grepl("NonFarm", variable), "Non-Farm Share", "Ag. Labor Share")
)]

p4 <- ggplot(gender_long, aes(x = Phase, y = value, fill = Gender)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7),
           width = 0.6) +
  facet_wrap(~Outcome, scales = "free_y") +
  geom_hline(yintercept = 0, color = "grey30") +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[4])) +
  labs(
    x = "", y = "Mean Change in Share (2001–2011)",
    title = "Gender-Specific Structural Transformation by MGNREGA Phase",
    subtitle = "Change in worker composition shares, Census 2001 to 2011",
    caption = "Notes: Non-farm share = 'other workers' / total workers. Ag. labor = agricultural laborers / total workers."
  ) +
  theme_apep() +
  theme(strip.text = element_text(face = "bold", size = 11))

ggsave(file.path(fig_dir, "fig4_gender_heterogeneity.pdf"),
       p4, width = 9, height = 5.5)
cat("  Saved fig4_gender_heterogeneity.pdf\n")

# ============================================================
# Figure 5: Caste Heterogeneity — SC/ST vs Non-SC/ST
# ============================================================
cat("Figure 5: Caste heterogeneity...\n")

caste_df <- census[, .(
  `High SC/ST`  = mean(d_nonfarm_share[high_sc_st == 1], na.rm = TRUE),
  `Low SC/ST`   = mean(d_nonfarm_share[high_sc_st == 0], na.rm = TRUE)
), by = .(Phase = factor(nrega_phase,
                         labels = c("Phase I (2006)", "Phase II (2007)",
                                     "Phase III (2008)")))]

caste_long <- melt(caste_df, id.vars = "Phase",
                   variable.name = "Village Type", value.name = "Change")

p5 <- ggplot(caste_long, aes(x = Phase, y = Change, fill = `Village Type`)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.7),
           width = 0.6) +
  geom_hline(yintercept = 0, color = "grey30") +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[3])) +
  labs(
    x = "", y = "Mean Change in Non-Farm Worker Share",
    title = "MGNREGA and Structural Transformation by Caste Composition",
    subtitle = "Villages split at median SC/ST population share",
    caption = "Notes: 'High SC/ST' villages have above-median SC/ST population share in Census 2001.\nNon-farm share = other workers / total workers."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_caste_heterogeneity.pdf"),
       p5, width = 8, height = 5.5)
cat("  Saved fig5_caste_heterogeneity.pdf\n")

# ============================================================
# Figure 6: Dose-Response — Years of MGNREGA Exposure by Phase
# ============================================================
cat("Figure 6: Coefficient plot (dose-response)...\n")

# Coefficient plot: Phase I vs Phase II effects
dose_results <- data.frame(
  Phase = c("Phase I\n(5 years exposure)", "Phase II\n(4 years exposure)"),
  coef  = coef(rob$m_dose)[c("phase1", "phase2")],
  se    = se(rob$m_dose)[c("phase1", "phase2")]
)
dose_results$ci_lo <- dose_results$coef - 1.96 * dose_results$se
dose_results$ci_hi <- dose_results$coef + 1.96 * dose_results$se

p6 <- ggplot(dose_results, aes(x = Phase, y = coef)) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                width = 0.15, color = apep_colors[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    x = "", y = "Effect on Non-Farm Worker Share",
    title = "Dose-Response: MGNREGA Exposure and Structural Transformation",
    subtitle = "Relative to Phase III districts (3 years exposure by Census 2011)",
    caption = "Notes: Coefficients from OLS long-difference with state FE and baseline controls.\n95% CI based on district-clustered SEs."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_dose_response.pdf"),
       p6, width = 7, height = 5)
cat("  Saved fig6_dose_response.pdf\n")

cat("\nAll figures saved to figures/\n")
