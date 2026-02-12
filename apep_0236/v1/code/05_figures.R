## =============================================================================
## 05_figures.R — Publication-ready figures
## APEP Working Paper apep_0232
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

results <- readRDS(file.path(data_dir, "main_results.rds"))
robust <- readRDS(file.path(data_dir, "robust_results.rds"))
panel <- results$panel

## ---------------------------------------------------------------------------
## Figure 1: Treatment Rollout — IMLC Adoption Timeline
## ---------------------------------------------------------------------------

cat("Figure 1: Treatment rollout...\n")

rollout <- panel %>%
  filter(year == 2017) %>%
  select(state_abbr, imlc_year) %>%
  mutate(
    group = case_when(
      imlc_year == 0    ~ "Never Adopted",
      imlc_year == 2017 ~ "2017",
      imlc_year == 2018 ~ "2018",
      imlc_year == 2019 ~ "2019",
      imlc_year == 2020 ~ "2020",
      imlc_year == 2021 ~ "2021",
      imlc_year >= 2022 ~ "2022+"
    ),
    group = factor(group, levels = c("2017", "2018", "2019", "2020",
                                     "2021", "2022+", "Never Adopted"))
  ) %>%
  arrange(group, state_abbr)

# Bar chart showing cohort sizes
cohort_counts <- rollout %>%
  count(group) %>%
  mutate(fill_color = case_when(
    group == "Never Adopted" ~ "grey60",
    TRUE ~ apep_colors[1]
  ))

p1 <- ggplot(cohort_counts, aes(x = group, y = n)) +
  geom_col(aes(fill = group == "Never Adopted"), width = 0.7) +
  scale_fill_manual(values = c("FALSE" = apep_colors[1], "TRUE" = "grey60"),
                    guide = "none") +
  geom_text(aes(label = n), vjust = -0.5, size = 3.5, fontface = "bold") +
  labs(
    title = "IMLC Adoption: States by Cohort Year",
    subtitle = "Compact became operational April 2017; staggered adoption through 2024",
    x = "Year of IMLC Adoption",
    y = "Number of States"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_treatment_rollout.pdf"),
       p1, width = 8, height = 5)

## ---------------------------------------------------------------------------
## Figure 2: Pre-treatment Trends — Healthcare Employment by Cohort
## ---------------------------------------------------------------------------

cat("Figure 2: Pre-treatment trends...\n")

trend_data <- panel %>%
  filter(!is.na(annual_avg_emplvl_healthcare)) %>%
  group_by(cohort_label, year) %>%
  summarise(
    mean_log_emp = mean(log_hc_emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(cohort_label %in% c("2017 Cohort", "2018 Cohort", "2019 Cohort",
                             "Never Treated"))

p2 <- ggplot(trend_data, aes(x = year, y = mean_log_emp,
                             color = cohort_label, linetype = cohort_label)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2016.5, linetype = "dotted", color = "grey50") +
  annotate("text", x = 2016.3, y = max(trend_data$mean_log_emp),
           label = "IMLC\nOperational", size = 3, hjust = 1, color = "grey40") +
  scale_color_manual(values = c(apep_colors[1:3], "grey50")) +
  scale_linetype_manual(values = c("solid", "dashed", "dotdash", "solid")) +
  labs(
    title = "Healthcare Employment Trends by IMLC Adoption Cohort",
    subtitle = "Mean log employment across states within each adoption cohort",
    x = "Year",
    y = "Mean Log Healthcare Employment",
    color = "Cohort",
    linetype = "Cohort"
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig2_pretrends.pdf"),
       p2, width = 9, height = 6)

## ---------------------------------------------------------------------------
## Figure 3: Event Study — Healthcare Employment (Main Result)
## ---------------------------------------------------------------------------

cat("Figure 3: Event study (healthcare employment)...\n")

es <- results$es_hc_emp
es_df <- data.frame(
  time = es$egt,
  att = es$att.egt,
  se = es$se.egt
) %>%
  filter(time >= -5, time <= 6)

p3 <- ggplot(es_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: IMLC and Healthcare Employment",
    subtitle = "Callaway-Sant'Anna ATT estimates; 95% CI; never-treated control",
    x = "Years Since IMLC Adoption",
    y = "ATT (Log Healthcare Employment)"
  ) +
  scale_x_continuous(breaks = seq(-5, 6, 1)) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_event_study_hc_emp.pdf"),
       p3, width = 9, height = 6)

## ---------------------------------------------------------------------------
## Figure 4: Event Study — Ambulatory Employment
## ---------------------------------------------------------------------------

cat("Figure 4: Event study (ambulatory employment)...\n")

es_amb <- results$es_amb_emp
es_amb_df <- data.frame(
  time = es_amb$egt,
  att = es_amb$att.egt,
  se = es_amb$se.egt
) %>%
  filter(time >= -5, time <= 6)

p4 <- ggplot(es_amb_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 2.5) +
  geom_line(color = apep_colors[3], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: IMLC and Ambulatory Care Employment",
    subtitle = "NAICS 621 (outpatient clinics, telehealth-intensive); CS estimator",
    x = "Years Since IMLC Adoption",
    y = "ATT (Log Ambulatory Employment)"
  ) +
  scale_x_continuous(breaks = seq(-5, 6, 1)) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_event_study_amb_emp.pdf"),
       p4, width = 9, height = 6)

## ---------------------------------------------------------------------------
## Figure 5: Event Study — Healthcare Establishments
## ---------------------------------------------------------------------------

cat("Figure 5: Event study (healthcare establishments)...\n")

es_est <- results$es_hc_estabs
es_est_df <- data.frame(
  time = es_est$egt,
  att = es_est$att.egt,
  se = es_est$se.egt
) %>%
  filter(time >= -5, time <= 6)

p5 <- ggplot(es_est_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: IMLC and Healthcare Establishments",
    subtitle = "Number of healthcare establishments (NAICS 62); CS estimator",
    x = "Years Since IMLC Adoption",
    y = "ATT (Log Healthcare Establishments)"
  ) +
  scale_x_continuous(breaks = seq(-5, 6, 1)) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_event_study_estabs.pdf"),
       p5, width = 9, height = 6)

## ---------------------------------------------------------------------------
## Figure 6: Placebo Event Study — Retail Employment
## ---------------------------------------------------------------------------

cat("Figure 6: Placebo event study (retail)...\n")

es_ret <- robust$es_retail
es_ret_df <- data.frame(
  time = es_ret$egt,
  att = es_ret$att.egt,
  se = es_ret$se.egt
) %>%
  filter(time >= -5, time <= 6)

p6 <- ggplot(es_ret_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = "grey50") +
  geom_point(color = "grey40", size = 2.5) +
  geom_line(color = "grey40", linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Placebo Test: IMLC and Accommodation Employment",
    subtitle = "NAICS 72 (unrelated to healthcare licensing); expect null effect",
    x = "Years Since IMLC Adoption",
    y = "ATT (Log Accommodation Employment)"
  ) +
  scale_x_continuous(breaks = seq(-5, 6, 1)) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo_retail.pdf"),
       p6, width = 9, height = 6)

## ---------------------------------------------------------------------------
## Figure 7: Sub-industry Comparison — Ambulatory vs Hospital
## ---------------------------------------------------------------------------

cat("Figure 7: Sub-industry comparison...\n")

es_hosp <- robust$es_hosp
es_hosp_df <- data.frame(
  time = es_hosp$egt,
  att = es_hosp$att.egt,
  se = es_hosp$se.egt,
  sector = "Hospitals (622)"
) %>%
  filter(time >= -5, time <= 6)

es_amb_compare <- data.frame(
  time = es_amb$egt,
  att = es_amb$att.egt,
  se = es_amb$se.egt,
  sector = "Ambulatory (621)"
) %>%
  filter(time >= -5, time <= 6)

compare_df <- bind_rows(es_amb_compare, es_hosp_df)

p7 <- ggplot(compare_df, aes(x = time, y = att, color = sector, fill = sector)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.15) +
  geom_point(size = 2) +
  geom_line(linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  scale_color_manual(values = c(apep_colors[3], apep_colors[4])) +
  scale_fill_manual(values = c(apep_colors[3], apep_colors[4])) +
  labs(
    title = "IMLC Effects by Healthcare Sub-industry",
    subtitle = "Ambulatory care (telehealth-intensive) vs. Hospitals (physical presence)",
    x = "Years Since IMLC Adoption",
    y = "ATT (Log Employment)",
    color = "Sub-industry",
    fill = "Sub-industry"
  ) +
  scale_x_continuous(breaks = seq(-5, 6, 1)) +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_subindustry_comparison.pdf"),
       p7, width = 9, height = 6)

## ---------------------------------------------------------------------------
## Figure 8: Cohort-specific ATTs
## ---------------------------------------------------------------------------

cat("Figure 8: Cohort-specific ATTs...\n")

cohort_df <- robust$cohort_atts %>%
  mutate(
    cohort_label = as.character(cohort),
    ci_lo = att - 1.96 * se,
    ci_hi = att + 1.96 * se
  )

p8 <- ggplot(cohort_df, aes(x = cohort_label, y = att)) +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  color = apep_colors[1], size = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "IMLC Effect by Adoption Cohort",
    subtitle = "Cohort-specific ATTs for healthcare employment; 95% CI",
    x = "Adoption Cohort",
    y = "ATT (Log Healthcare Employment)"
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig8_cohort_atts.pdf"),
       p8, width = 8, height = 5)

## ---------------------------------------------------------------------------
## Figure 9: Bacon Decomposition (if available)
## ---------------------------------------------------------------------------

if (!is.null(robust$bacon_result)) {
  cat("Figure 9: Bacon decomposition...\n")

  p9 <- ggplot(robust$bacon_result, aes(x = weight, y = estimate, color = type)) +
    geom_point(size = 2, alpha = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    scale_color_manual(values = apep_colors[1:3]) +
    labs(
      title = "Goodman-Bacon Decomposition",
      subtitle = "TWFE estimate as weighted average of 2x2 DiD comparisons",
      x = "Weight",
      y = "2x2 DiD Estimate",
      color = "Comparison Type"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig9_bacon_decomp.pdf"),
         p9, width = 9, height = 6)
}

cat("\n=== All figures saved to", fig_dir, "===\n")
