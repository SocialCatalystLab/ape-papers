## =============================================================================
## 03_main_analysis.R — Primary Regressions
## APEP-0369: Click to Prescribe
## =============================================================================

source("00_packages.R")

cat("=== Running main analysis ===\n")

set.seed(2024)  # Reproducible bootstrap inference

panel <- readRDS("../data/analysis_panel.rds")

## ---------------------------------------------------------------------------
## 1. Descriptive: Treatment rollout plot
## ---------------------------------------------------------------------------

cat("Creating treatment rollout visualization...\n")

rollout <- panel %>%
  filter(epcs_mandate_year > 0) %>%
  select(state_abbr, epcs_mandate_year) %>%
  distinct() %>%
  arrange(epcs_mandate_year, state_abbr) %>%
  mutate(order = row_number())

p_rollout <- ggplot(rollout, aes(x = epcs_mandate_year, y = reorder(state_abbr, -order))) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_vline(xintercept = 2022.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2022.7, y = 3, label = "CMS\nMandate", size = 3, hjust = 0, color = "grey40") +
  labs(
    title = "Staggered Adoption of EPCS Mandates",
    x = "Year of EPCS Mandate",
    y = ""
  ) +
  scale_x_continuous(breaks = 2011:2024) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave("../figures/fig1_treatment_rollout.pdf", p_rollout, width = 8, height = 10)

## ---------------------------------------------------------------------------
## 2. Descriptive: Average outcomes by treatment cohort
## ---------------------------------------------------------------------------

cat("Plotting outcome trends by cohort...\n")

# Group cohorts for visualization
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

p_trends <- ggplot(cohort_means, aes(x = year, y = mean_rate,
                                      color = cohort_group, group = cohort_group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  labs(
    title = "Prescription Opioid Death Rates by EPCS Adoption Cohort",
    subtitle = "Natural & semi-synthetic opioid deaths (T40.2) per 100,000",
    x = "Year",
    y = "Deaths per 100,000",
    color = "EPCS Cohort"
  ) +
  scale_color_manual(values = c("grey50", apep_colors[1:4])) +
  theme_apep()

ggsave("../figures/fig2_cohort_trends.pdf", p_trends, width = 9, height = 6)

## ---------------------------------------------------------------------------
## 3. Callaway-Sant'Anna: Primary specification
## ---------------------------------------------------------------------------

cat("Running Callaway-Sant'Anna estimation...\n")

# Prepare data for did package
cs_data <- panel %>%
  filter(!is.na(rx_opioid_death_rate), !is.na(population)) %>%
  mutate(
    # did package needs gname = first treatment year (0 for never-treated)
    gname = epcs_mandate_year
  )

# Primary specification: Prescription opioid death rate
cs_rx <- att_gt(
  yname = "rx_opioid_death_rate",
  tname = "year",
  idname = "state_id",
  gname = "gname",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 1,
  base_period = "universal",
  est_method = "dr",  # Doubly robust
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

saveRDS(cs_rx, "../data/cs_rx_results.rds")

# Aggregate to event study
es_rx <- aggte(cs_rx, type = "dynamic", min_e = -5, max_e = 3)
saveRDS(es_rx, "../data/es_rx_results.rds")

cat("\n--- Primary ATT (Rx Opioid Death Rate) ---\n")
agg_rx <- aggte(cs_rx, type = "simple")
cat(sprintf("ATT: %.3f (SE: %.3f, p: %.4f)\n",
            agg_rx$overall.att, agg_rx$overall.se,
            2 * pnorm(-abs(agg_rx$overall.att / agg_rx$overall.se))))
cat(sprintf("95%% CI: [%.3f, %.3f]\n",
            agg_rx$overall.att - 1.96 * agg_rx$overall.se,
            agg_rx$overall.att + 1.96 * agg_rx$overall.se))

## ---------------------------------------------------------------------------
## 4. Placebo: Synthetic opioid deaths (T40.4 — illicit fentanyl)
## ---------------------------------------------------------------------------

cat("\nRunning placebo specification (synthetic opioid deaths)...\n")

cs_synth <- att_gt(
  yname = "synth_opioid_death_rate",
  tname = "year",
  idname = "state_id",
  gname = "gname",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 1,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

saveRDS(cs_synth, "../data/cs_synth_results.rds")

es_synth <- aggte(cs_synth, type = "dynamic", min_e = -5, max_e = 3)
saveRDS(es_synth, "../data/es_synth_results.rds")

cat("\n--- Placebo ATT (Synthetic Opioid Death Rate) ---\n")
agg_synth <- aggte(cs_synth, type = "simple")
cat(sprintf("ATT: %.3f (SE: %.3f, p: %.4f)\n",
            agg_synth$overall.att, agg_synth$overall.se,
            2 * pnorm(-abs(agg_synth$overall.att / agg_synth$overall.se))))

## ---------------------------------------------------------------------------
## 5. All opioid deaths
## ---------------------------------------------------------------------------

cat("\nRunning total opioid death specification...\n")

cs_all <- att_gt(
  yname = "all_opioid_death_rate",
  tname = "year",
  idname = "state_id",
  gname = "gname",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 1,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

saveRDS(cs_all, "../data/cs_all_results.rds")

es_all <- aggte(cs_all, type = "dynamic", min_e = -5, max_e = 3)
saveRDS(es_all, "../data/es_all_results.rds")

cat("\n--- ATT (All Opioid Death Rate) ---\n")
agg_all <- aggte(cs_all, type = "simple")
cat(sprintf("ATT: %.3f (SE: %.3f, p: %.4f)\n",
            agg_all$overall.att, agg_all$overall.se,
            2 * pnorm(-abs(agg_all$overall.att / agg_all$overall.se))))

## ---------------------------------------------------------------------------
## 6. Total drug overdose deaths
## ---------------------------------------------------------------------------

cat("\nRunning total overdose death specification...\n")

cs_total <- att_gt(
  yname = "total_od_death_rate",
  tname = "year",
  idname = "state_id",
  gname = "gname",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 1,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

saveRDS(cs_total, "../data/cs_total_results.rds")

## ---------------------------------------------------------------------------
## 7. TWFE comparison (for Bacon decomposition)
## ---------------------------------------------------------------------------

cat("\nRunning TWFE comparison...\n")

twfe_rx <- feols(
  rx_opioid_death_rate ~ epcs_treated | state_id + year,
  data = cs_data,
  cluster = ~state_id
)

twfe_synth <- feols(
  synth_opioid_death_rate ~ epcs_treated | state_id + year,
  data = cs_data,
  cluster = ~state_id
)

cat("\n--- TWFE Results ---\n")
cat("Rx opioid deaths:\n")
print(summary(twfe_rx))
cat("\nSynthetic opioid deaths (placebo):\n")
print(summary(twfe_synth))

saveRDS(list(twfe_rx = twfe_rx, twfe_synth = twfe_synth),
        "../data/twfe_results.rds")

## ---------------------------------------------------------------------------
## 8. Sun-Abraham event study (alternative estimator)
## ---------------------------------------------------------------------------

cat("\nRunning Sun-Abraham event study...\n")

# Create cohort variable for sunab
cs_data_sa <- cs_data %>%
  mutate(
    cohort = ifelse(gname == 0, Inf, gname)  # sunab uses Inf for never-treated
  )

sa_rx <- feols(
  rx_opioid_death_rate ~ sunab(cohort, year) | state_id + year,
  data = cs_data_sa,
  cluster = ~state_id
)

sa_synth <- feols(
  synth_opioid_death_rate ~ sunab(cohort, year) | state_id + year,
  data = cs_data_sa,
  cluster = ~state_id
)

saveRDS(list(sa_rx = sa_rx, sa_synth = sa_synth),
        "../data/sunab_results.rds")

cat("\n--- Sun-Abraham ATT ---\n")
cat("Rx opioid deaths:\n")
print(summary(sa_rx, agg = "ATT"))
cat("\nSynthetic opioid deaths (placebo):\n")
print(summary(sa_synth, agg = "ATT"))

## ---------------------------------------------------------------------------
## 9. Save all results summary
## ---------------------------------------------------------------------------

results_summary <- data.frame(
  outcome = c("Rx Opioid Deaths", "Synthetic Opioid Deaths (Placebo)",
              "All Opioid Deaths", "Total OD Deaths"),
  cs_att = c(agg_rx$overall.att, agg_synth$overall.att,
             agg_all$overall.att, aggte(cs_total, type = "simple")$overall.att),
  cs_se = c(agg_rx$overall.se, agg_synth$overall.se,
            agg_all$overall.se, aggte(cs_total, type = "simple")$overall.se),
  twfe_coef = c(coef(twfe_rx)["epcs_treated"], coef(twfe_synth)["epcs_treated"], NA, NA),
  twfe_se = c(se(twfe_rx)["epcs_treated"], se(twfe_synth)["epcs_treated"], NA, NA)
)

results_summary$cs_pval <- 2 * pnorm(-abs(results_summary$cs_att / results_summary$cs_se))

cat("\n\n========================================\n")
cat("RESULTS SUMMARY\n")
cat("========================================\n")
print(results_summary, digits = 3)

saveRDS(results_summary, "../data/results_summary.rds")

cat("\n=== Main analysis complete ===\n")
