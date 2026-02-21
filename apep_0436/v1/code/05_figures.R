## ============================================================
## 05_figures.R — Generate all figures
## MGNREGA and Structural Transformation
## ============================================================

source("00_packages.R")

data_dir  <- file.path("..", "data")
fig_dir   <- file.path("..", "figures")

census <- fread(file.path(data_dir, "analysis_census_panel.csv"))
nl     <- fread(file.path(data_dir, "analysis_nightlights_panel.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
rob     <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ── Figure 1: Treatment Rollout Map ─────────────────────────
# Bar chart showing number of districts per phase
cat("Creating Figure 1: MGNREGA rollout...\n")

phase_counts <- census[year == 2001, .N, by = mgnrega_phase]
phase_counts[, phase_label := factor(mgnrega_phase,
  levels = 1:3,
  labels = c("Phase I\n(Feb 2006)", "Phase II\n(Apr 2007)", "Phase III\n(Apr 2008)"))]

p1 <- ggplot(phase_counts, aes(x = phase_label, y = N, fill = factor(mgnrega_phase))) +
  geom_col(width = 0.6) +
  geom_text(aes(label = N), vjust = -0.5, size = 4, fontface = "bold") +
  scale_fill_manual(values = apep_colors[1:3], guide = "none") +
  labs(x = NULL, y = "Number of Districts",
       title = "MGNREGA Phased Rollout",
       subtitle = "Districts assigned by Planning Commission Backwardness Index") +
  theme_apep() +
  ylim(0, max(phase_counts$N) * 1.15)

ggsave(file.path(fig_dir, "fig1_rollout.pdf"), p1, width = 6, height = 4.5)
ggsave(file.path(fig_dir, "fig1_rollout.png"), p1, width = 6, height = 4.5, dpi = 300)

# ── Figure 2: Pre-treatment Worker Composition by Phase ──────
cat("Creating Figure 2: Worker composition by phase...\n")

comp_data <- census[, .(
  Cultivators = mean(cult_share, na.rm = TRUE),
  `Ag. Laborers` = mean(aglab_share, na.rm = TRUE),
  `Non-Farm` = mean(nonfarm_share, na.rm = TRUE)
), by = .(mgnrega_phase, year)]

comp_long <- melt(comp_data, id.vars = c("mgnrega_phase", "year"),
                  variable.name = "category", value.name = "share")
comp_long[, phase_label := factor(mgnrega_phase,
  levels = 1:3, labels = c("Phase I", "Phase II", "Phase III"))]

p2 <- ggplot(comp_long, aes(x = factor(year), y = share, fill = category)) +
  geom_col(position = "stack", width = 0.7) +
  facet_wrap(~phase_label) +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[4], apep_colors[1]),
                    name = "Worker Category") +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Census Year", y = "Share of Main Workers",
       title = "Worker Composition by MGNREGA Phase",
       subtitle = "Structural transformation: shift from agricultural to non-farm employment") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig2_composition.pdf"), p2, width = 9, height = 5)
ggsave(file.path(fig_dir, "fig2_composition.png"), p2, width = 9, height = 5, dpi = 300)

# ── Figure 3: Parallel Trends (Census) ──────────────────────
cat("Creating Figure 3: Parallel trends...\n")

trends_data <- census[mgnrega_phase %in% c(1L, 3L), .(
  nonfarm_share = mean(nonfarm_share, na.rm = TRUE),
  cult_share = mean(cult_share, na.rm = TRUE),
  aglab_share = mean(aglab_share, na.rm = TRUE)
), by = .(mgnrega_phase, year)]

trends_data[, phase_label := factor(mgnrega_phase,
  levels = c(1, 3), labels = c("Phase I (early)", "Phase III (late)"))]

p3a <- ggplot(trends_data, aes(x = year, y = nonfarm_share,
                                color = phase_label, group = phase_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 2006, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  annotate("text", x = 2006, y = max(trends_data$nonfarm_share) * 0.95,
           label = "Phase I\ntreatment", hjust = -0.1, size = 3, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2], name = NULL) +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Census Year", y = "Non-Farm Worker Share",
       title = "A. Non-Farm Employment Share") +
  theme_apep()

p3b <- ggplot(trends_data, aes(x = year, y = cult_share,
                                color = phase_label, group = phase_label)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_vline(xintercept = 2006, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  scale_color_manual(values = apep_colors[1:2], name = NULL) +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Census Year", y = "Cultivator Share",
       title = "B. Cultivator Share") +
  theme_apep()

p3 <- p3a / p3b + plot_annotation(
  title = "Parallel Trends: Phase I vs Phase III Districts",
  subtitle = "Pre-treatment period (1991-2001) shows similar trends across groups",
  theme = theme(plot.title = element_text(size = 14, face = "bold"),
                plot.subtitle = element_text(size = 11, color = "grey40"))
)

ggsave(file.path(fig_dir, "fig3_parallel_trends.pdf"), p3, width = 8, height = 8)
ggsave(file.path(fig_dir, "fig3_parallel_trends.png"), p3, width = 8, height = 8, dpi = 300)

# ── Figure 4: Nightlights Event Study ───────────────────────
cat("Creating Figure 4: Event study...\n")

es <- results$es_nl
es_df <- data.frame(
  event_time = es$egt,
  att = es$att.egt,
  se = es$se.egt
)
es_df$ci_lower <- es_df$att - 1.96 * es_df$se
es_df$ci_upper <- es_df$att + 1.96 * es_df$se
es_df$significant <- (es_df$ci_lower > 0) | (es_df$ci_upper < 0)

p4 <- ggplot(es_df, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(aes(color = significant), size = 2.5) +
  scale_color_manual(values = c("TRUE" = apep_colors[1], "FALSE" = "grey60"),
                     guide = "none") +
  labs(x = "Years Relative to MGNREGA Implementation",
       y = "ATT (Log Nightlights)",
       title = "Event Study: MGNREGA Effect on Nightlights",
       subtitle = "Callaway-Sant'Anna estimates with 95% CI") +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_event_study.pdf"), p4, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig4_event_study.png"), p4, width = 8, height = 5.5, dpi = 300)

# ── Figure 5: Randomization Inference ────────────────────────
cat("Creating Figure 5: Randomization inference...\n")

ri_df <- data.frame(perm_coef = rob$perm_coefs[!is.na(rob$perm_coefs)])

p5 <- ggplot(ri_df, aes(x = perm_coef)) +
  geom_histogram(bins = 40, fill = "grey70", color = "white") +
  geom_vline(xintercept = rob$obs_coef, color = apep_colors[2],
             linewidth = 1.2, linetype = "solid") +
  annotate("text", x = rob$obs_coef, y = Inf,
           label = paste0("Observed\n(p = ", round(rob$ri_pvalue, 3), ")"),
           hjust = -0.1, vjust = 1.5, color = apep_colors[2], fontface = "bold", size = 3.5) +
  labs(x = "Permuted Treatment Effect on Non-Farm Share",
       y = "Frequency",
       title = "Randomization Inference",
       subtitle = "Distribution of placebo effects under 500 random phase assignments") +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_ri.pdf"), p5, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig5_ri.png"), p5, width = 7, height = 5, dpi = 300)

# ── Figure 6: Heterogeneity ─────────────────────────────────
cat("Creating Figure 6: Heterogeneity...\n")

het_df <- data.frame(
  subgroup = c("High Baseline\nNon-Farm", "Low Baseline\nNon-Farm",
               "High SC/ST\nShare", "Low SC/ST\nShare"),
  coef = c(coef(rob$het_high)["early_post"],
           coef(rob$het_low)["early_post"],
           coef(rob$het_scst_high)["early_post"],
           coef(rob$het_scst_low)["early_post"]),
  se = c(se(rob$het_high)["early_post"],
         se(rob$het_low)["early_post"],
         se(rob$het_scst_high)["early_post"],
         se(rob$het_scst_low)["early_post"])
)
het_df$ci_lower <- het_df$coef - 1.96 * het_df$se
het_df$ci_upper <- het_df$coef + 1.96 * het_df$se
het_df$category <- c("Baseline\nDevelopment", "Baseline\nDevelopment",
                     "SC/ST\nShare", "SC/ST\nShare")

p6 <- ggplot(het_df, aes(x = subgroup, y = coef, color = category)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper), size = 0.8, linewidth = 0.8) +
  scale_color_manual(values = apep_colors[c(1, 3)], name = NULL) +
  labs(x = NULL, y = "DiD Estimate (Non-Farm Share)",
       title = "Heterogeneous Treatment Effects",
       subtitle = "MGNREGA effect by baseline district characteristics") +
  theme_apep() +
  theme(axis.text.x = element_text(size = 9))

ggsave(file.path(fig_dir, "fig6_heterogeneity.pdf"), p6, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig6_heterogeneity.png"), p6, width = 8, height = 5, dpi = 300)

# ── Figure 7: Raw nightlights by phase ──────────────────────
cat("Creating Figure 7: Nightlights by phase...\n")

nl_trends <- nl[, .(mean_light = mean(log_light, na.rm = TRUE)),
                by = .(mgnrega_phase, year)]
nl_trends[, phase_label := factor(mgnrega_phase,
  levels = 1:3, labels = c("Phase I", "Phase II", "Phase III"))]

p7 <- ggplot(nl_trends, aes(x = year, y = mean_light, color = phase_label)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2006, linetype = "dashed", color = apep_colors[1], alpha = 0.5) +
  geom_vline(xintercept = 2007, linetype = "dashed", color = apep_colors[2], alpha = 0.5) +
  geom_vline(xintercept = 2008, linetype = "dashed", color = apep_colors[3], alpha = 0.5) +
  scale_color_manual(values = apep_colors[1:3], name = "MGNREGA Phase") +
  labs(x = "Year", y = "Mean Log(Nightlights + 1)",
       title = "Nightlights Trends by MGNREGA Phase",
       subtitle = "Dashed lines indicate phase implementation dates") +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_nl_trends.pdf"), p7, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig7_nl_trends.png"), p7, width = 8, height = 5, dpi = 300)

cat("\nAll figures saved to:", fig_dir, "\n")
