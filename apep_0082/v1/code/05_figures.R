## 05_figures.R — All figure generation
## Paper 110: Recreational Marijuana and Business Formation

source("00_packages.R")

# Load data
state_year <- read_csv(file.path(DATA_DIR, "panel_state_year.csv"), show_col_types = FALSE)
cs_es <- readRDS(file.path(DATA_DIR, "cs_es.rds"))
cs_cohort <- readRDS(file.path(DATA_DIR, "cs_cohort.rds"))
robustness <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))
series_models <- readRDS(file.path(DATA_DIR, "series_models.rds"))

# ──────────────────────────────────────────────────────────────
# Figure 1: Descriptive trends — treated vs. never-treated
# ──────────────────────────────────────────────────────────────
cat("Creating Figure 1: Descriptive trends...\n")

trends_data <- state_year %>%
  mutate(group = if_else(ever_treated == 1, "Opened Retail", "No Retail Sales")) %>%
  group_by(group, year) %>%
  summarise(
    mean_apps_pc = mean(apps_per_100k, na.rm = TRUE),
    se = sd(apps_per_100k, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p1 <- ggplot(trends_data, aes(x = year, y = mean_apps_pc, color = group, fill = group)) +
  geom_ribbon(aes(ymin = mean_apps_pc - 1.96*se, ymax = mean_apps_pc + 1.96*se),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2013.5, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  annotate("text", x = 2013.5, y = max(trends_data$mean_apps_pc) * 0.95,
           label = "First retail sales\n(CO, WA: 2014)", hjust = 1.05, size = 3, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_fill_manual(values = apep_colors[1:2]) +
  scale_x_continuous(breaks = c(seq(2005, 2023, 2), 2024)) +
  labs(
    title = "Business Applications per 100,000 Population",
    subtitle = "States that opened recreational retail vs. states without retail sales",
    x = "Year", y = "Business Applications per 100k",
    color = NULL, fill = NULL
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_trends.pdf"), p1, width = 8, height = 5)
ggsave(file.path(FIG_DIR, "fig1_trends.png"), p1, width = 8, height = 5, dpi = 300)
cat("  Saved fig1_trends\n")

# ──────────────────────────────────────────────────────────────
# Figure 2: CS Event Study
# ──────────────────────────────────────────────────────────────
cat("Creating Figure 2: CS Event Study...\n")

es_df <- tibble(
  event_time = cs_es$egt,
  att = cs_es$att.egt,
  se = cs_es$se.egt,
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se
) %>%
  filter(event_time >= -7 & event_time <= 7)

p2 <- ggplot(es_df, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, color = "grey60", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  scale_x_continuous(breaks = -7:7) +
  labs(
    title = "Event Study: Effect of Recreational Marijuana Retail Sales on Business Formation",
    subtitle = "Callaway-Sant'Anna estimates, log business applications per capita",
    x = "Years Relative to First Retail Sales",
    y = "ATT (log points)"
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig2_event_study.pdf"), p2, width = 8, height = 5.5)
ggsave(file.path(FIG_DIR, "fig2_event_study.png"), p2, width = 8, height = 5.5, dpi = 300)
cat("  Saved fig2_event_study\n")

# ──────────────────────────────────────────────────────────────
# Figure 3: BFS Series Decomposition — TWFE coefficients
# ──────────────────────────────────────────────────────────────
cat("Creating Figure 3: BFS series decomposition...\n")

# Extract coefficients from series models
series_names <- c("Total BA", "High-Propensity BA", "Planned-Wage BA",
                  "Corporate BA", "Business Formations (8Q)")
series_coefs <- c(
  coef(readRDS(file.path(DATA_DIR, "twfe_models.rds"))$twfe2)["treated"],
  coef(series_models$twfe_hba)["treated"],
  coef(series_models$twfe_wba)["treated"],
  coef(series_models$twfe_cba)["treated"],
  coef(series_models$twfe_bf)["treated"]
)
series_ses <- c(
  se(readRDS(file.path(DATA_DIR, "twfe_models.rds"))$twfe2)["treated"],
  se(series_models$twfe_hba)["treated"],
  se(series_models$twfe_wba)["treated"],
  se(series_models$twfe_cba)["treated"],
  se(series_models$twfe_bf)["treated"]
)

series_df <- tibble(
  series = factor(series_names, levels = rev(series_names)),
  coef = series_coefs,
  se = series_ses,
  ci_lower = coef - 1.96 * se,
  ci_upper = coef + 1.96 * se,
  type = c("Total", "Subset", "Subset", "Subset", "Outcome")
)

p3 <- ggplot(series_df, aes(x = coef, y = series, color = type)) +
  geom_vline(xintercept = 0, color = "grey60", linewidth = 0.5) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.3, linewidth = 0.6) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Total" = apep_colors[1],
                                "Subset" = apep_colors[2],
                                "Outcome" = apep_colors[3])) +
  labs(
    title = "Effect of Recreational Marijuana Across Business Formation Measures",
    subtitle = "TWFE coefficients on log applications/formations per capita, state-clustered SEs",
    x = "Coefficient (log points)",
    y = NULL,
    color = NULL
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.15))

ggsave(file.path(FIG_DIR, "fig3_series.pdf"), p3, width = 8, height = 5)
ggsave(file.path(FIG_DIR, "fig3_series.png"), p3, width = 8, height = 5, dpi = 300)
cat("  Saved fig3_series\n")

# ──────────────────────────────────────────────────────────────
# Figure 4: Randomization Inference
# ──────────────────────────────────────────────────────────────
cat("Creating Figure 4: Randomization inference...\n")

ri_df <- tibble(coef = robustness$perm_coefs)

p4 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50,
                 fill = "grey80", color = "grey60") +
  geom_vline(xintercept = robustness$obs_coef, color = apep_colors[1],
             linewidth = 1.2, linetype = "solid") +
  geom_vline(xintercept = -robustness$obs_coef, color = apep_colors[1],
             linewidth = 1.2, linetype = "dashed") +
  annotate("text", x = robustness$obs_coef, y = Inf,
           label = paste0("Observed\n(b = ", round(robustness$obs_coef, 3), ")"),
           hjust = -0.1, vjust = 1.5, size = 3.5, color = apep_colors[1]) +
  labs(
    title = "Randomization Inference: Permutation Distribution",
    subtitle = paste0("999 permutations of treatment assignment; two-sided p = ", round(robustness$ri_pvalue, 3)),
    x = "TWFE Coefficient (permuted)",
    y = "Density"
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig4_ri.pdf"), p4, width = 7, height = 5)
ggsave(file.path(FIG_DIR, "fig4_ri.png"), p4, width = 7, height = 5, dpi = 300)
cat("  Saved fig4_ri\n")

# ──────────────────────────────────────────────────────────────
# Figure 5: Cohort-specific trends (Appendix)
# ──────────────────────────────────────────────────────────────
cat("Creating Figure 5: Cohort trends...\n")

cohort_trends <- state_year %>%
  filter(first_treat > 0) %>%
  mutate(cohort = factor(first_treat)) %>%
  group_by(cohort, year) %>%
  summarise(
    mean_apps_pc = mean(apps_per_100k, na.rm = TRUE),
    .groups = "drop"
  )

never_trend <- state_year %>%
  filter(first_treat == 0) %>%
  group_by(year) %>%
  summarise(mean_apps_pc = mean(apps_per_100k, na.rm = TRUE)) %>%
  mutate(cohort = "Never Treated")

p5 <- ggplot() +
  geom_line(data = never_trend, aes(x = year, y = mean_apps_pc),
            color = "grey50", linewidth = 1.5, alpha = 0.5) +
  geom_line(data = cohort_trends, aes(x = year, y = mean_apps_pc, color = cohort),
            linewidth = 0.8) +
  geom_point(data = cohort_trends, aes(x = year, y = mean_apps_pc, color = cohort),
             size = 1.5) +
  scale_x_continuous(breaks = c(seq(2005, 2023, 2), 2024)) +
  labs(
    title = "Business Applications by Treatment Cohort",
    subtitle = "Grey line: never-treated states; colored lines: cohorts by first retail sales year",
    x = "Year", y = "Business Applications per 100k",
    color = "Cohort"
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig5_cohorts.pdf"), p5, width = 9, height = 5.5)
ggsave(file.path(FIG_DIR, "fig5_cohorts.png"), p5, width = 9, height = 5.5, dpi = 300)
cat("  Saved fig5_cohorts\n")

# ──────────────────────────────────────────────────────────────
# Figure 6: Individual state trends (Appendix)
# ──────────────────────────────────────────────────────────────
cat("Creating Figure 6: Individual state trends...\n")

early_states <- c("CO", "WA", "OR", "AK", "NV", "CA")
early_data <- state_year %>%
  filter(state_abbr %in% early_states) %>%
  mutate(state_label = state_abbr)

never_avg <- state_year %>%
  filter(first_treat == 0) %>%
  group_by(year) %>%
  summarise(apps_per_100k = mean(apps_per_100k, na.rm = TRUE)) %>%
  mutate(state_label = "Never-Treated Avg")

p6 <- ggplot() +
  geom_line(data = never_avg, aes(x = year, y = apps_per_100k),
            color = "grey50", linewidth = 1.2, linetype = "dashed") +
  geom_line(data = early_data, aes(x = year, y = apps_per_100k, color = state_label),
            linewidth = 0.8) +
  geom_point(data = early_data, aes(x = year, y = apps_per_100k, color = state_label),
             size = 1.5) +
  scale_x_continuous(breaks = c(seq(2005, 2023, 2), 2024)) +
  labs(
    title = "Business Application Trends: Early-Adopter States",
    subtitle = "Dashed grey: never-treated average",
    x = "Year", y = "Business Applications per 100k",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig6_early_states.pdf"), p6, width = 9, height = 5.5)
ggsave(file.path(FIG_DIR, "fig6_early_states.png"), p6, width = 9, height = 5.5, dpi = 300)
cat("  Saved fig6_early_states\n")

cat("\n=== All figures generated ===\n")
