## =============================================================================
## 05_figures.R — All Figure Generation
## APEP-0369: Click to Prescribe
## =============================================================================

source("00_packages.R")

cat("=== Generating figures ===\n")

panel <- readRDS("../data/analysis_panel.rds")

## ---------------------------------------------------------------------------
## Figure 1: Treatment rollout (already created in 03, recreate here)
## ---------------------------------------------------------------------------

cat("Figure 1: Treatment rollout...\n")

rollout <- panel %>%
  filter(epcs_mandate_year > 0, epcs_mandate_year <= 2023) %>%
  select(state_abbr, epcs_mandate_year) %>%
  distinct() %>%
  arrange(epcs_mandate_year, state_abbr) %>%
  mutate(order = row_number())

p1 <- ggplot(rollout, aes(x = epcs_mandate_year, y = reorder(state_abbr, -order))) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_vline(xintercept = 2022.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2022.7, y = 3, label = "CMS\nMandate", size = 3, hjust = 0, color = "grey40") +
  labs(
    title = "Staggered Adoption of State EPCS Mandates",
    subtitle = "33 states enacted electronic prescribing mandates for controlled substances",
    x = "Year of EPCS Mandate",
    y = ""
  ) +
  scale_x_continuous(breaks = seq(2011, 2024, 1)) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave("../figures/fig1_treatment_rollout.pdf", p1, width = 8, height = 10)

## ---------------------------------------------------------------------------
## Figure 2: Cohort outcome trends
## ---------------------------------------------------------------------------

cat("Figure 2: Cohort trends...\n")

panel <- panel %>%
  mutate(
    cohort_group = case_when(
      epcs_mandate_year == 0 ~ "Never Treated",
      epcs_mandate_year <= 2019 ~ "Early (2011-2019)",
      epcs_mandate_year == 2020 ~ "2020 Cohort",
      epcs_mandate_year == 2021 ~ "2021 Cohort",
      epcs_mandate_year >= 2022 ~ "2022+ Cohort"
    ),
    cohort_group = factor(cohort_group, levels = c(
      "Never Treated", "Early (2011-2019)", "2020 Cohort", "2021 Cohort", "2022+ Cohort"
    ))
  )

cohort_means <- panel %>%
  filter(!is.na(rx_opioid_death_rate)) %>%
  group_by(cohort_group, year) %>%
  summarise(
    mean_rate = mean(rx_opioid_death_rate, na.rm = TRUE),
    se_rate = sd(rx_opioid_death_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p2 <- ggplot(cohort_means, aes(x = year, y = mean_rate,
                                color = cohort_group, group = cohort_group)) +
  geom_ribbon(aes(ymin = mean_rate - 1.96*se_rate, ymax = mean_rate + 1.96*se_rate,
                  fill = cohort_group), alpha = 0.1, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  labs(
    title = "Prescription Opioid Death Rates by EPCS Adoption Cohort",
    subtitle = "Natural & semi-synthetic opioid deaths (T40.2) per 100,000",
    x = "Year",
    y = "Deaths per 100,000",
    color = "EPCS Cohort",
    fill = "EPCS Cohort"
  ) +
  scale_color_manual(values = c("grey50", apep_colors[1:4])) +
  scale_fill_manual(values = c("grey50", apep_colors[1:4])) +
  scale_x_continuous(breaks = 2015:2023) +
  theme_apep()

ggsave("../figures/fig2_cohort_trends.pdf", p2, width = 9, height = 6)

## ---------------------------------------------------------------------------
## Figure 3: Event study — Prescription opioid deaths
## ---------------------------------------------------------------------------

cat("Figure 3: Event study (Rx opioids)...\n")

es_rx <- readRDS("../data/es_rx_results.rds")

es_df <- data.frame(
  time = es_rx$egt,
  att = es_rx$att.egt,
  se = es_rx$se.egt
)

p3 <- ggplot(es_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: EPCS Mandates and Prescription Opioid Deaths",
    subtitle = "Callaway-Sant'Anna ATT(e) with 95% confidence bands",
    x = "Years Relative to EPCS Mandate",
    y = "ATT: Deaths per 100,000",
    caption = "Note: Control group = never-treated states. 1-year anticipation allowed."
  ) +
  scale_x_continuous(breaks = -5:3) +
  theme_apep()

ggsave("../figures/fig3_event_study_rx.pdf", p3, width = 8, height = 6)

## ---------------------------------------------------------------------------
## Figure 4: Event study — Placebo (synthetic opioids)
## ---------------------------------------------------------------------------

cat("Figure 4: Event study (placebo — synthetic opioids)...\n")

es_synth <- readRDS("../data/es_synth_results.rds")

es_synth_df <- data.frame(
  time = es_synth$egt,
  att = es_synth$att.egt,
  se = es_synth$se.egt
)

p4 <- ggplot(es_synth_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Placebo Test: EPCS Mandates and Synthetic Opioid Deaths",
    subtitle = "Illicit fentanyl deaths (T40.4) should NOT respond to prescribing format",
    x = "Years Relative to EPCS Mandate",
    y = "ATT: Deaths per 100,000",
    caption = "Note: Null result expected — EPCS mandates affect prescriptions, not illicit supply."
  ) +
  scale_x_continuous(breaks = -5:3) +
  theme_apep()

ggsave("../figures/fig4_event_study_placebo.pdf", p4, width = 8, height = 6)

## ---------------------------------------------------------------------------
## Figure 5: Combined event study panel
## ---------------------------------------------------------------------------

cat("Figure 5: Combined event study panel...\n")

# Combine for panel plot
combined_es <- bind_rows(
  es_df %>% mutate(outcome = "Prescription Opioids (T40.2)"),
  es_synth_df %>% mutate(outcome = "Synthetic Opioids [Placebo] (T40.4)")
)

p5 <- ggplot(combined_es, aes(x = time, y = att, color = outcome, fill = outcome)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.15, color = NA) +
  geom_point(size = 2.5) +
  geom_line(linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  facet_wrap(~outcome, scales = "free_y", ncol = 1) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[2])) +
  labs(
    title = "EPCS Mandates: Treatment vs. Placebo Outcomes",
    subtitle = "Callaway-Sant'Anna event study with 95% confidence bands",
    x = "Years Relative to EPCS Mandate",
    y = "ATT: Deaths per 100,000"
  ) +
  scale_x_continuous(breaks = -5:3) +
  theme_apep() +
  theme(legend.position = "none",
        strip.text = element_text(size = 11, face = "bold"))

ggsave("../figures/fig5_combined_event_study.pdf", p5, width = 8, height = 9)

## ---------------------------------------------------------------------------
## Figure 6: Heterogeneity by pre-treatment prescribing level
## ---------------------------------------------------------------------------

cat("Figure 6: Heterogeneity...\n")

tryCatch({
  hetero_high <- readRDS("../data/robustness_hetero_high.rds")
  hetero_low <- readRDS("../data/robustness_hetero_low.rds")

  es_high <- aggte(hetero_high$cs, type = "dynamic", min_e = -5, max_e = 3)
  es_low <- aggte(hetero_low$cs, type = "dynamic", min_e = -5, max_e = 3)

  hetero_combined <- bind_rows(
    data.frame(time = es_high$egt, att = es_high$att.egt, se = es_high$se.egt,
               group = "High Pre-Treatment Rate"),
    data.frame(time = es_low$egt, att = es_low$att.egt, se = es_low$se.egt,
               group = "Low Pre-Treatment Rate")
  )

  p6 <- ggplot(hetero_combined, aes(x = time, y = att, color = group, fill = group)) +
    geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
                alpha = 0.15, color = NA) +
    geom_point(size = 2.5) +
    geom_line(linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c(apep_colors[1], apep_colors[3])) +
    scale_fill_manual(values = c(apep_colors[1], apep_colors[3])) +
    labs(
      title = "Treatment Effect Heterogeneity by Pre-Treatment Overdose Rate",
      subtitle = "States split at median pre-2019 prescription opioid death rate",
      x = "Years Relative to EPCS Mandate",
      y = "ATT: Deaths per 100,000",
      color = "Subgroup",
      fill = "Subgroup"
    ) +
    scale_x_continuous(breaks = -5:3) +
    theme_apep()

  ggsave("../figures/fig6_heterogeneity.pdf", p6, width = 8, height = 6)
}, error = function(e) {
  cat(sprintf("  Heterogeneity figure failed: %s\n", e$message))
})

## ---------------------------------------------------------------------------
## Figure 7: National trend in opioid deaths by type
## ---------------------------------------------------------------------------

cat("Figure 7: National trends by drug class...\n")

national_trends <- panel %>%
  group_by(year) %>%
  summarise(
    `Prescription Opioids (T40.2)` = sum(rx_opioid_deaths, na.rm = TRUE),
    `Synthetic Opioids (T40.4)` = sum(synth_opioid_deaths, na.rm = TRUE),
    `Heroin (T40.1)` = sum(heroin_deaths, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-year, names_to = "Drug Class", values_to = "Deaths")

p7 <- ggplot(national_trends, aes(x = year, y = Deaths / 1000, color = `Drug Class`)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  labs(
    title = "U.S. Drug Overdose Deaths by Opioid Type, 2015-2023",
    subtitle = "EPCS mandates target prescription opioids; synthetic opioid deaths are driven by illicit fentanyl",
    x = "Year",
    y = "Deaths (thousands)",
    color = ""
  ) +
  scale_color_manual(values = apep_colors[c(1, 2, 3)]) +
  scale_x_continuous(breaks = 2015:2023) +
  theme_apep()

ggsave("../figures/fig7_national_trends.pdf", p7, width = 9, height = 6)

cat("\n=== All figures generated ===\n")
