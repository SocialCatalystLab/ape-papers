## ── 05_figures.R ──────────────────────────────────────────────────────────
## Generate all figures for apep_0426
## ──────────────────────────────────────────────────────────────────────────

source("00_packages.R")

data_dir <- "../data"
fig_dir  <- "../figures"

panel <- fread(file.path(data_dir, "analysis_panel_clean.csv"))
cross <- fread(file.path(data_dir, "district_cross_section.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

panel[, did := as.integer(as.factor(dist_code))]

## ══════════════════════════════════════════════════════════════════════════
## Figure 1: Raw Nightlight Trends by MGNREGA Phase
## ══════════════════════════════════════════════════════════════════════════

trends <- panel[, .(mean_light = mean(log_light, na.rm = TRUE),
                     se = sd(log_light, na.rm = TRUE) / sqrt(.N)),
                 by = .(year, nrega_phase)]
trends[, phase_label := factor(nrega_phase,
                                levels = 1:3,
                                labels = c("Phase I (2006)", "Phase II (2007)", "Phase III (2008)"))]

fig1 <- ggplot(trends, aes(x = year, y = mean_light,
                             color = phase_label, group = phase_label)) +
  geom_line(linewidth = 0.8) +
  geom_ribbon(aes(ymin = mean_light - 1.96*se,
                   ymax = mean_light + 1.96*se,
                   fill = phase_label), alpha = 0.15, color = NA) +
  geom_vline(xintercept = c(2006, 2007, 2008),
             linetype = "dashed", alpha = 0.4) +
  annotate("text", x = 2006, y = max(trends$mean_light) * 0.98,
           label = "Phase I", hjust = -0.1, size = 3, color = "grey40") +
  annotate("text", x = 2007, y = max(trends$mean_light) * 0.95,
           label = "Phase II", hjust = -0.1, size = 3, color = "grey40") +
  annotate("text", x = 2008, y = max(trends$mean_light) * 0.92,
           label = "Phase III", hjust = -0.1, size = 3, color = "grey40") +
  scale_color_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A")) +
  scale_fill_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A")) +
  labs(x = "Year", y = "Mean Log(Nightlights + 1)",
       title = "District Nightlight Trends by MGNREGA Phase",
       color = NULL, fill = NULL) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig1_trends.pdf"), fig1, width = 8, height = 5)
cat("✓ Figure 1 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Figure 2: Event Study (Callaway-Sant'Anna Dynamic ATT)
## ══════════════════════════════════════════════════════════════════════════

cs_dynamic <- results$cs_dynamic
es_data <- data.table(
  event_time = cs_dynamic$egt,
  att = cs_dynamic$att.egt,
  se = cs_dynamic$se.egt
)
es_data[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

fig2 <- ggplot(es_data, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
  geom_vline(xintercept = -0.5, color = "grey50", linetype = "dashed") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#377EB8") +
  geom_point(size = 1.8, color = "#377EB8") +
  geom_line(color = "#377EB8", linewidth = 0.5) +
  labs(x = "Years Relative to MGNREGA Implementation",
       y = "ATT (Log Nightlights)",
       title = "Dynamic Treatment Effects of MGNREGA on Nightlights",
       subtitle = "Callaway-Sant'Anna regression-based estimator, not-yet-treated controls") +
  scale_x_continuous(breaks = seq(-10, 15, 5))

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), fig2, width = 8, height = 5)
cat("✓ Figure 2 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Figure 3: ATT by Cohort
## ══════════════════════════════════════════════════════════════════════════

cs_cohort <- results$cs_cohort
cohort_data <- data.table(
  cohort = cs_cohort$egt,
  att = cs_cohort$att.egt,
  se = cs_cohort$se.egt
)
cohort_data[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]
cohort_data[, label := paste0("Phase ", 1:nrow(cohort_data), "\n(", cohort, ")")]

fig3 <- ggplot(cohort_data, aes(x = factor(cohort), y = att)) +
  geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  color = "#E41A1C", size = 0.8) +
  labs(x = "Treatment Cohort", y = "ATT (Log Nightlights)",
       title = "Treatment Effects by MGNREGA Cohort") +
  scale_x_discrete(labels = c("Phase I\n(2006)", "Phase II\n(2007)", "Phase III\n(2008)"))

ggsave(file.path(fig_dir, "fig3_cohort_att.pdf"), fig3, width = 6, height = 5)
cat("✓ Figure 3 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Figure 4: Heterogeneity by Baseline Development
## ══════════════════════════════════════════════════════════════════════════

het_dev <- panel[!is.na(dev_quartile), .(
  mean_light = mean(log_light, na.rm = TRUE)
), by = .(year, dev_quartile, nrega_phase)]

## Run TWFE by quartile
het_results <- list()
for (q in unique(na.omit(panel$dev_quartile))) {
  sub <- panel[dev_quartile == q]
  m <- feols(log_light ~ treated | dist_code + year,
             data = sub, cluster = ~state_code)
  het_results[[q]] <- data.table(
    quartile = q,
    att = coef(m)["treated"],
    se = se(m)["treated"]
  )
}
het_dt <- rbindlist(het_results)
het_dt[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

fig4 <- ggplot(het_dt, aes(x = quartile, y = att)) +
  geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  color = "#4DAF4A", size = 0.8) +
  labs(x = "Baseline Development Quartile (Year 2000 Nightlights)",
       y = "TWFE Coefficient (Log Nightlights)",
       title = "MGNREGA Effects by Baseline Development Level") +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

ggsave(file.path(fig_dir, "fig4_heterogeneity_dev.pdf"), fig4, width = 7, height = 5)
cat("✓ Figure 4 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Figure 5: Structural Transformation (Census Cross-Section)
## ══════════════════════════════════════════════════════════════════════════

cross[, phase_label := factor(nrega_phase,
                               levels = 1:3,
                               labels = c("Phase I", "Phase II", "Phase III"))]

fig5 <- ggplot(cross[!is.na(delta_nonfarm)],
               aes(x = phase_label, y = delta_nonfarm)) +
  geom_boxplot(aes(fill = phase_label), alpha = 0.6, outlier.size = 0.5) +
  geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
  scale_fill_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A")) +
  labs(x = "MGNREGA Phase", y = "Change in Non-Farm Worker Share (2001-2011)",
       title = "Structural Transformation by MGNREGA Phase") +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "fig5_structural_transform.pdf"), fig5, width = 6, height = 5)
cat("✓ Figure 5 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Figure 6: Map of MGNREGA Phases (Backwardness Ranking)
## ══════════════════════════════════════════════════════════════════════════

## Simple ranked bar chart showing backwardness distribution by phase
dist_01 <- fread(file.path(data_dir, "district_census_2001.csv"))
dist_01[, phase_label := factor(nrega_phase,
                                 levels = 1:3,
                                 labels = c("Phase I", "Phase II", "Phase III"))]

fig6 <- ggplot(dist_01, aes(x = backward_rank, y = backwardness, fill = phase_label)) +
  geom_bar(stat = "identity", width = 1) +
  scale_fill_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A")) +
  labs(x = "District Rank (by Backwardness Index)",
       y = "Composite Backwardness Index",
       title = "MGNREGA Phase Assignment by District Backwardness",
       fill = NULL) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig6_phase_assignment.pdf"), fig6, width = 8, height = 4)
cat("✓ Figure 6 saved\n")

cat("\n✓ All figures generated.\n")
