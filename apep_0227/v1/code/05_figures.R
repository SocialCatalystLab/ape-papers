## ============================================================================
## 05_figures.R — All figures for the paper
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robust <- readRDS(file.path(data_dir, "robustness_results.rds"))

## ---------------------------------------------------------------------------
## Figure 1: Treatment Rollout Map
## ---------------------------------------------------------------------------

cat("Figure 1: Treatment rollout...\n")

rollout_df <- df %>%
  filter(first_treat > 0) %>%
  distinct(state_abb, first_treat) %>%
  mutate(cohort_label = paste0(first_treat))

# Create categorical cohort variable for all states
all_states <- df %>%
  distinct(state_abb, first_treat) %>%
  mutate(
    cohort_cat = case_when(
      first_treat == 0 ~ "Never\ntreated",
      first_treat == 2017 ~ "2017",
      first_treat == 2018 ~ "2018",
      first_treat == 2019 ~ "2019",
      first_treat == 2020 ~ "2020",
      first_treat == 2021 ~ "2021",
      first_treat == 2022 ~ "2022",
      first_treat == 2023 ~ "2023",
      TRUE ~ "Excluded"
    ),
    cohort_cat = factor(cohort_cat, levels = c(
      "2017", "2018", "2019", "2020", "2021", "2022", "2023", "Never\ntreated", "Excluded"
    ))
  )

# Bar chart of adoption by year (simpler and more informative than map)
p1 <- all_states %>%
  filter(cohort_cat != "Excluded") %>%
  count(cohort_cat) %>%
  ggplot(aes(x = cohort_cat, y = n, fill = cohort_cat)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = n), vjust = -0.3, size = 4, fontface = "bold") +
  scale_fill_manual(values = c(
    "2017" = "#041E42", "2018" = "#08306B", "2019" = "#2171B5", "2020" = "#4292C6",
    "2021" = "#6BAED6", "2022" = "#9ECAE1", "2023" = "#C6DBEF",
    "Never\ntreated" = "#D55E00"
  )) +
  labs(
    title = "Staggered Adoption of Fentanyl Test Strip Legalization",
    subtitle = "Number of states adopting by year",
    x = "Adoption Cohort", y = "Number of States"
  ) +
  theme_apep() +
  theme(legend.position = "none") +
  ylim(0, max(all_states %>% filter(cohort_cat != "Excluded") %>% count(cohort_cat) %>% pull(n)) * 1.15)

ggsave(file.path(fig_dir, "fig1_rollout.pdf"), p1, width = 8, height = 5)

## ---------------------------------------------------------------------------
## Figure 2: Raw Trends — Treated vs. Never-Treated
## ---------------------------------------------------------------------------

cat("Figure 2: Raw outcome trends...\n")

trend_df <- df %>%
  mutate(
    treat_status = case_when(
      first_treat == 0 ~ "Never-treated states",
      first_treat > 0 ~ "Eventually-treated states",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(treat_status)) %>%
  group_by(year, treat_status) %>%
  summarise(
    mean_rate = weighted.mean(rate_synth_opioid, population, na.rm = TRUE),
    se_rate = sqrt(sum(population^2 * (rate_synth_opioid - weighted.mean(rate_synth_opioid, population))^2) /
                     sum(population)^2),
    .groups = "drop"
  )

p2 <- ggplot(trend_df, aes(x = year, y = mean_rate, color = treat_status)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2017.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2017.3, y = max(trend_df$mean_rate) * 0.95,
           label = "First FTS\nlegalization", hjust = 1, size = 3, color = "grey40") +
  scale_color_manual(values = c(
    "Eventually-treated states" = apep_colors[1],
    "Never-treated states" = apep_colors[2]
  )) +
  labs(
    title = "Synthetic Opioid Overdose Death Rates",
    subtitle = "Population-weighted average, treated vs. never-treated states",
    x = "Year", y = "Deaths per 100,000",
    color = NULL
  ) +
  theme_apep() +
  scale_x_continuous(breaks = 2015:2023)

ggsave(file.path(fig_dir, "fig2_trends.pdf"), p2, width = 9, height = 5.5)

## ---------------------------------------------------------------------------
## Figure 3: CS-DiD Event Study (Primary Result)
## ---------------------------------------------------------------------------

cat("Figure 3: CS-DiD event study...\n")

es_data <- data.frame(
  time = results$cs_es_never$egt,
  att = results$cs_es_never$att.egt,
  se = results$cs_es_never$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

p3 <- ggplot(es_data, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: Effect of FTS Legalization on Synthetic Opioid Deaths",
    subtitle = "Callaway-Sant'Anna (2021), never-treated comparison group",
    x = "Years Relative to FTS Legalization",
    y = "ATT (Deaths per 100,000)",
    caption = "95% pointwise confidence intervals. Doubly-robust estimation with 1,000 bootstrap iterations."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 4, 1))

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), p3, width = 9, height = 5.5)

## ---------------------------------------------------------------------------
## Figure 4: Comparison of Estimators
## ---------------------------------------------------------------------------

cat("Figure 4: Estimator comparison...\n")

# Collect ATTs from different estimators
estimator_comp <- tribble(
  ~estimator, ~att, ~se,
  "TWFE (basic)", coef(results$twfe_basic)["treated"],
    summary(results$twfe_basic)$coeftable["treated", "Std. Error"],
  "CS-DiD\n(never-treated)", results$cs_agg_never$overall.att, results$cs_agg_never$overall.se,
  "CS-DiD\n(not-yet-treated)", results$cs_agg_notyet$overall.att, results$cs_agg_notyet$overall.se
)

p4 <- ggplot(estimator_comp, aes(x = estimator, y = att)) +
  geom_point(size = 4, color = apep_colors[1]) +
  geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                width = 0.15, color = apep_colors[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "Comparison of DiD Estimators",
    subtitle = "Point estimates and 95% confidence intervals",
    x = NULL, y = "ATT (Deaths per 100,000)"
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(size = 10))

ggsave(file.path(fig_dir, "fig4_estimator_comparison.pdf"), p4, width = 8, height = 5)

## ---------------------------------------------------------------------------
## Figure 5: Placebo Outcomes Event Studies
## ---------------------------------------------------------------------------

cat("Figure 5: Placebo event studies...\n")

# Combine main and placebo event studies
if (!is.null(robust$placebo_cocaine_es)) {
  placebo_data <- bind_rows(
    data.frame(
      time = results$cs_es_never$egt,
      att = results$cs_es_never$att.egt,
      se = results$cs_es_never$se.egt,
      outcome = "Synthetic Opioid\n(T40.4) [Primary]"
    ),
    data.frame(
      time = robust$placebo_cocaine_es$egt,
      att = robust$placebo_cocaine_es$att.egt,
      se = robust$placebo_cocaine_es$se.egt,
      outcome = "Cocaine\n(T40.5) [Placebo]"
    )
  )

  p5 <- ggplot(placebo_data, aes(x = time, y = att, color = outcome, fill = outcome)) +
    geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                alpha = 0.1, color = NA) +
    geom_point(size = 2.5) +
    geom_line(linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
    scale_fill_manual(values = c(apep_colors[1], apep_colors[2])) +
    labs(
      title = "Primary Outcome vs. Placebo: Event Study Comparison",
      subtitle = "Callaway-Sant'Anna (2021), never-treated comparison group",
      x = "Years Relative to FTS Legalization",
      y = "ATT (Deaths per 100,000)",
      color = NULL, fill = NULL
    ) +
    theme_apep() +
    scale_x_continuous(breaks = seq(-5, 4, 1))

  ggsave(file.path(fig_dir, "fig5_placebo.pdf"), p5, width = 9, height = 5.5)
}

## ---------------------------------------------------------------------------
## Figure 6: Randomization Inference Distribution
## ---------------------------------------------------------------------------

cat("Figure 6: Randomization inference...\n")

if (!is.null(robust$perm_atts) && length(robust$perm_atts) > 10) {
  ri_df <- data.frame(att = robust$perm_atts)
  actual_att <- results$cs_agg_never$overall.att

  p6 <- ggplot(ri_df, aes(x = att)) +
    geom_histogram(bins = 30, fill = "grey70", color = "white", alpha = 0.8) +
    geom_vline(xintercept = actual_att, color = apep_colors[2],
               linewidth = 1.2, linetype = "solid") +
    annotate("text", x = actual_att, y = Inf, vjust = 2,
             label = paste0("Actual ATT = ", round(actual_att, 2)),
             color = apep_colors[2], fontface = "bold", size = 3.5) +
    labs(
      title = "Randomization Inference: Permutation Distribution",
      subtitle = paste0("p-value = ", round(robust$ri_pvalue, 4),
                        " (", length(robust$perm_atts), " permutations)"),
      x = "ATT under Permuted Treatment Assignment",
      y = "Frequency"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_ri.pdf"), p6, width = 8, height = 5)
}

## ---------------------------------------------------------------------------
## Figure 7: Cohort-Specific ATTs with Controls Comparison
## ---------------------------------------------------------------------------

cat("Figure 7: Event study with controls overlay...\n")

if (!is.null(robust$controls_es)) {
  es_compare <- bind_rows(
    data.frame(
      time = results$cs_es_never$egt,
      att = results$cs_es_never$att.egt,
      se = results$cs_es_never$se.egt,
      spec = "Unconditional"
    ),
    data.frame(
      time = robust$controls_es$egt,
      att = robust$controls_es$att.egt,
      se = robust$controls_es$se.egt,
      spec = "With Controls"
    )
  )

  p7 <- ggplot(es_compare, aes(x = time, y = att, color = spec)) +
    geom_point(size = 2.5, position = position_dodge(width = 0.3)) +
    geom_line(linewidth = 0.7, position = position_dodge(width = 0.3)) +
    geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                  width = 0.2, position = position_dodge(width = 0.3)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c(apep_colors[1], apep_colors[3])) +
    labs(
      title = "Event Study: Unconditional vs. Conditional Parallel Trends",
      subtitle = "Controls: naloxone access, Medicaid expansion, poverty, unemployment",
      x = "Years Relative to FTS Legalization",
      y = "ATT (Deaths per 100,000)",
      color = "Specification"
    ) +
    theme_apep() +
    scale_x_continuous(breaks = seq(-5, 4, 1))

  ggsave(file.path(fig_dir, "fig7_controls_comparison.pdf"), p7, width = 9, height = 5.5)
}

cat("\n=== All figures saved to", fig_dir, "===\n")
