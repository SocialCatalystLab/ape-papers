# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 07_additional_exhibits.R - Additional Figures and Tables for Publication
# ============================================================================

cat("Generating additional exhibits for publication...\n")

# ============================================================================
# Load packages and data
# ============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)
  library(sf)
  library(tigris)
})

options(tigris_use_cache = TRUE)

# APEP Theme
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

theme_set(theme_apep())

apep_colors <- c(
  "treated" = "#0072B2",
  "control" = "#D55E00",
  "male" = "#56B4E9",
  "female" = "#CC79A7",
  "colorado" = "#1a9850",
  "california" = "#91cf60",
  "highlight" = "#E69F00"
)

# Load data
cps_analysis <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
results <- readRDS("data/main_results.rds")

# Convert haven_labelled to numeric
state_year <- state_year %>%
  mutate(across(where(haven::is.labelled), as.numeric))

cat("Data loaded. Starting additional analysis...\n")

# ============================================================================
# Figure 8: Wage Inequality (90/10 ratio) Event Study
# ============================================================================

cat("  Figure 8: Wage inequality event study\n")

# DiD on wage inequality
ineq_did <- feols(
  wage_9010 ~ treated | statefip + year,
  data = state_year,
  weights = ~n_obs,
  cluster = ~statefip
)

# Event study
ineq_es <- feols(
  wage_9010 ~ sunab(cohort_year, year) | statefip + year,
  data = state_year %>% filter(is.finite(cohort_year) | treatment_year == 0),
  weights = ~n_obs,
  cluster = ~statefip
)

# Extract event study coefficients
ineq_coefs <- coef(ineq_es)
ineq_se <- se(ineq_es)

ineq_df <- tibble(
  term = names(ineq_coefs),
  estimate = ineq_coefs,
  se = ineq_se
) %>%
  filter(grepl("^year::", term)) %>%
  mutate(
    event_time = as.numeric(gsub("year::(-?[0-9]+)", "\\1", term)),
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  ) %>%
  filter(!is.na(event_time))

fig8 <- ggplot(ineq_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "solid", color = "grey30") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = apep_colors["highlight"]) +
  geom_point(size = 3, color = apep_colors["highlight"]) +
  labs(
    title = "Effect on Wage Inequality (90/10 Ratio)",
    subtitle = "Sun-Abraham event study estimates",
    x = "Years Relative to Treatment",
    y = "Change in 90/10 Wage Ratio",
    caption = "Note: 95% confidence intervals with state-clustered SEs."
  ) +
  theme_apep()

ggsave("figures/fig8_inequality_es.pdf", fig8, width = 10, height = 6)
ggsave("figures/fig8_inequality_es.png", fig8, width = 10, height = 6, dpi = 300)

# ============================================================================
# Figure 9: Gender Gap Event Study
# ============================================================================

cat("  Figure 9: Gender gap event study\n")

gap_es <- results$gap_es

gap_coefs <- coef(gap_es)
gap_se_vals <- se(gap_es)

gap_df <- tibble(
  term = names(gap_coefs),
  estimate = gap_coefs,
  se = gap_se_vals
) %>%
  filter(grepl("^year::", term)) %>%
  mutate(
    event_time = as.numeric(gsub("year::(-?[0-9]+)", "\\1", term)),
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  ) %>%
  filter(!is.na(event_time))

fig9 <- ggplot(gap_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "solid", color = "grey30") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors["female"]) +
  geom_line(linewidth = 1, color = apep_colors["female"]) +
  geom_point(size = 3, color = apep_colors["female"]) +
  labs(
    title = "Effect on Gender Wage Gap",
    subtitle = "Sun-Abraham event study (negative = gap reduction)",
    x = "Years Relative to Treatment",
    y = "Change in Gender Gap (Log Points)",
    caption = "Note: Gender gap defined as male minus female log earnings."
  ) +
  theme_apep()

ggsave("figures/fig9_gender_gap_es.pdf", fig9, width = 10, height = 6)
ggsave("figures/fig9_gender_gap_es.png", fig9, width = 10, height = 6, dpi = 300)

# ============================================================================
# Figure 10: State-by-State Effects
# ============================================================================

cat("  Figure 10: State-by-state effects\n")

# Calculate state-specific effects using simple before/after comparison
state_effects <- state_year %>%
  filter(ever_treated, treatment_year > 0, treatment_year <= 2024) %>%
  group_by(statefip, state_abbr, treatment_year) %>%
  summarise(
    pre_mean = weighted.mean(mean_log_earn[year < treatment_year], n_obs[year < treatment_year], na.rm = TRUE),
    post_mean = weighted.mean(mean_log_earn[year >= treatment_year], n_obs[year >= treatment_year], na.rm = TRUE),
    n_pre = sum(n_obs[year < treatment_year], na.rm = TRUE),
    n_post = sum(n_obs[year >= treatment_year], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    effect = post_mean - pre_mean,
    state_label = paste0(state_abbr, " (", treatment_year, ")"),
    state_label = factor(state_label, levels = state_label[order(effect)])
  )

fig10 <- ggplot(state_effects, aes(x = effect, y = state_label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_segment(aes(x = 0, xend = effect, y = state_label, yend = state_label),
               color = "grey70") +
  geom_point(aes(color = factor(treatment_year)), size = 4) +
  scale_color_manual(values = c("2021" = "#1a9850", "2023" = "#91cf60", "2024" = "#d9ef8b"),
                     name = "Treatment Year") +
  labs(
    title = "State-Specific Wage Changes After Transparency Laws",
    subtitle = "Simple pre/post comparison (not causal)",
    x = "Change in Log Weekly Earnings",
    y = NULL,
    caption = "Note: Raw before/after differences, not controlling for trends."
  ) +
  theme_apep() +
  theme(panel.grid.major.y = element_blank())

ggsave("figures/fig10_state_effects.pdf", fig10, width = 9, height = 5)
ggsave("figures/fig10_state_effects.png", fig10, width = 9, height = 5, dpi = 300)

# ============================================================================
# Figure 11: Placebo Test - Pre-treatment Trends
# ============================================================================

cat("  Figure 11: Placebo test\n")

# Run placebo using only pre-treatment data
pre_data <- state_year %>%
  filter(year < 2021) %>%
  mutate(
    placebo_treat_2019 = ever_treated & year >= 2019,
    placebo_cohort = ifelse(ever_treated, 2019, Inf)
  )

placebo_es <- feols(
  mean_log_earn ~ sunab(placebo_cohort, year) | statefip + year,
  data = pre_data,
  weights = ~n_obs,
  cluster = ~statefip
)

placebo_coefs <- coef(placebo_es)
placebo_se_vals <- se(placebo_es)

placebo_df <- tibble(
  term = names(placebo_coefs),
  estimate = placebo_coefs,
  se = placebo_se_vals
) %>%
  filter(grepl("^year::", term)) %>%
  mutate(
    event_time = as.numeric(gsub("year::(-?[0-9]+)", "\\1", term)),
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  ) %>%
  filter(!is.na(event_time))

fig11 <- ggplot(placebo_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "solid", color = "grey30") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = "grey40") +
  geom_point(size = 3, color = "grey40") +
  labs(
    title = "Placebo Test: Fake Treatment in 2019",
    subtitle = "Using only pre-2021 data",
    x = "Years Relative to Placebo Treatment",
    y = "Placebo ATT (Log Points)",
    caption = "Note: Non-zero effects suggest pre-existing differences."
  ) +
  theme_apep()

ggsave("figures/fig11_placebo.pdf", fig11, width = 10, height = 6)
ggsave("figures/fig11_placebo.png", fig11, width = 10, height = 6, dpi = 300)

# ============================================================================
# Figure 12: Sample Size by State and Year
# ============================================================================

cat("  Figure 12: Sample size heatmap\n")

sample_matrix <- state_year %>%
  select(statefip, state_abbr, year, n_obs, ever_treated) %>%
  filter(!is.na(state_abbr) | ever_treated)

# Select states to show (treated + major control states)
show_states <- state_year %>%
  group_by(statefip, state_abbr, ever_treated) %>%
  summarise(total_n = sum(n_obs), .groups = "drop") %>%
  arrange(desc(ever_treated), desc(total_n)) %>%
  head(20)

sample_heat <- sample_matrix %>%
  filter(statefip %in% show_states$statefip) %>%
  left_join(show_states %>% select(statefip, total_n), by = "statefip") %>%
  mutate(state_label = ifelse(!is.na(state_abbr), state_abbr, sprintf("State %d", statefip)))

fig12 <- ggplot(sample_heat, aes(x = year, y = reorder(state_label, total_n), fill = n_obs)) +
  geom_tile(color = "white", linewidth = 0.5) +
  scale_fill_viridis_c(option = "plasma", trans = "log10", name = "N Obs\n(log scale)") +
  labs(
    title = "Sample Size by State and Year",
    subtitle = "CPS MORG observations for selected states",
    x = "Year", y = NULL
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 8),
        legend.position = "right")

ggsave("figures/fig12_sample_heatmap.pdf", fig12, width = 10, height = 7)
ggsave("figures/fig12_sample_heatmap.png", fig12, width = 10, height = 7, dpi = 300)

# ============================================================================
# Table 5: Event Study Coefficients
# ============================================================================

cat("  Table 5: Event study coefficients\n")

es_model <- results$es_model
es_coefs <- coef(es_model)
es_se_vals <- se(es_model)

table5 <- tibble(
  Coefficient = names(es_coefs),
  Estimate = es_coefs,
  SE = es_se_vals
) %>%
  filter(grepl("^year::", Coefficient)) %>%
  mutate(
    Event_Time = as.numeric(gsub("year::(-?[0-9]+)", "\\1", Coefficient)),
    CI_lower = Estimate - 1.96 * SE,
    CI_upper = Estimate + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(Estimate / SE))),
    stars = case_when(p_value < 0.01 ~ "***", p_value < 0.05 ~ "**", p_value < 0.10 ~ "*", TRUE ~ "")
  ) %>%
  select(Event_Time, Estimate, SE, CI_lower, CI_upper, p_value, stars) %>%
  arrange(Event_Time)

write_csv(table5, "tables/table5_event_study.csv")

# ============================================================================
# Table 6: Robustness Checks
# ============================================================================

cat("  Table 6: Robustness checks\n")

# Main specification
main_mod <- feols(
  mean_log_earn ~ treated | statefip + year,
  data = state_year,
  weights = ~n_obs,
  cluster = ~statefip
)
main_att <- coef(main_mod)[1]
main_se <- se(main_mod)[1]

# Never-treated only - use all states but proper treatment def
did_never <- feols(
  mean_log_earn ~ treated | statefip + year,
  data = state_year,
  weights = ~n_obs,
  cluster = ~statefip
)

# Excluding Colorado
did_no_co <- feols(
  mean_log_earn ~ treated | statefip + year,
  data = state_year %>% filter(statefip != 8),
  weights = ~n_obs,
  cluster = ~statefip
)

# Excluding California (largest treated state)
did_no_ca <- feols(
  mean_log_earn ~ treated | statefip + year,
  data = state_year %>% filter(statefip != 6),
  weights = ~n_obs,
  cluster = ~statefip
)

# Unweighted
did_unweighted <- feols(
  mean_log_earn ~ treated | statefip + year,
  data = state_year,
  cluster = ~statefip
)

table6 <- tibble(
  Specification = c("Main (weighted)", "Never-treated control",
                    "Excluding Colorado", "Excluding California", "Unweighted"),
  ATT = c(main_att, coef(did_never)[1], coef(did_no_co)[1],
          coef(did_no_ca)[1], coef(did_unweighted)[1]),
  SE = c(main_se, se(did_never)[1], se(did_no_co)[1],
         se(did_no_ca)[1], se(did_unweighted)[1]),
  N_states = c(51, 51, 50, 50, 51)
) %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(ATT / SE))),
    stars = case_when(p_value < 0.01 ~ "***", p_value < 0.05 ~ "**", p_value < 0.10 ~ "*", TRUE ~ "")
  )

write_csv(table6, "tables/table6_robustness.csv")

# ============================================================================
# Table 7: Heterogeneity by Demographic Groups
# ============================================================================

cat("  Table 7: Demographic heterogeneity\n")

# Create age and education groups at individual level
cps_demo <- cps_analysis %>%
  mutate(
    age_group = case_when(
      age < 35 ~ "Young (18-34)",
      age < 50 ~ "Middle (35-49)",
      TRUE ~ "Older (50-64)"
    ),
    educ_group = case_when(
      grade92 < 39 ~ "No college",
      grade92 < 43 ~ "Some college",
      TRUE ~ "College+"
    )
  )

# Aggregate to state-year level by demographic group
demo_panels <- list()

for (ag in unique(cps_demo$age_group)) {
  temp <- cps_demo %>%
    filter(age_group == ag) %>%
    group_by(statefip, year, treatment_year, ever_treated, treated) %>%
    summarise(mean_log_earn = mean(log_earnweek, na.rm = TRUE),
              n_obs = n(), .groups = "drop") %>%
    mutate(cohort_year = ifelse(treatment_year > 0, treatment_year, Inf))
  demo_panels[[paste0("age_", ag)]] <- temp
}

for (eg in unique(na.omit(cps_demo$educ_group))) {
  temp <- cps_demo %>%
    filter(educ_group == eg) %>%
    group_by(statefip, year, treatment_year, ever_treated, treated) %>%
    summarise(mean_log_earn = mean(log_earnweek, na.rm = TRUE),
              n_obs = n(), .groups = "drop") %>%
    mutate(cohort_year = ifelse(treatment_year > 0, treatment_year, Inf))
  demo_panels[[paste0("educ_", eg)]] <- temp
}

# Run DiD for each group
het_results <- list()
for (nm in names(demo_panels)) {
  df <- demo_panels[[nm]]
  mod <- feols(
    mean_log_earn ~ treated | statefip + year,
    data = df,
    weights = ~n_obs,
    cluster = ~statefip
  )
  het_results[[nm]] <- tibble(
    Group = nm,
    ATT = coef(mod)[1],
    SE = se(mod)[1],
    N = nrow(df)
  )
}

table7 <- bind_rows(het_results) %>%
  mutate(
    Group = gsub("age_", "Age: ", Group),
    Group = gsub("educ_", "Education: ", Group),
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(ATT / SE))),
    stars = case_when(p_value < 0.01 ~ "***", p_value < 0.05 ~ "**", p_value < 0.10 ~ "*", TRUE ~ "")
  )

write_csv(table7, "tables/table7_demographic_het.csv")

# ============================================================================
# Table 8: Wage Distribution Effects
# ============================================================================

cat("  Table 8: Wage distribution effects\n")

# Create percentile outcomes
dist_panel <- cps_analysis %>%
  group_by(statefip, year, treatment_year, ever_treated, treated) %>%
  summarise(
    p10 = quantile(log_earnweek, 0.10, na.rm = TRUE),
    p25 = quantile(log_earnweek, 0.25, na.rm = TRUE),
    p50 = quantile(log_earnweek, 0.50, na.rm = TRUE),
    p75 = quantile(log_earnweek, 0.75, na.rm = TRUE),
    p90 = quantile(log_earnweek, 0.90, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(cohort_year = ifelse(treatment_year > 0, treatment_year, Inf))

dist_results <- list()
for (pctl in c("p10", "p25", "p50", "p75", "p90")) {
  mod <- feols(
    as.formula(paste0(pctl, " ~ treated | statefip + year")),
    data = dist_panel,
    weights = ~n_obs,
    cluster = ~statefip
  )
  dist_results[[pctl]] <- tibble(
    Percentile = pctl,
    ATT = coef(mod)[1],
    SE = se(mod)[1]
  )
}

table8 <- bind_rows(dist_results) %>%
  mutate(
    Percentile = gsub("p", "", Percentile),
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(ATT / SE))),
    stars = case_when(p_value < 0.01 ~ "***", p_value < 0.05 ~ "**", p_value < 0.10 ~ "*", TRUE ~ "")
  )

write_csv(table8, "tables/table8_distribution.csv")

# ============================================================================
# Table 9: Balance Table
# ============================================================================

cat("  Table 9: Balance table\n")

balance <- cps_analysis %>%
  filter(year < 2021) %>%
  group_by(ever_treated) %>%
  summarise(
    Log_Earnings = mean(log_earnweek, na.rm = TRUE),
    Age = mean(age, na.rm = TRUE),
    Pct_Female = mean(female, na.rm = TRUE) * 100,
    N = n()
  ) %>%
  mutate(Group = ifelse(ever_treated, "Treated States", "Control States")) %>%
  select(Group, Log_Earnings, Age, Pct_Female, N)

# Add difference and p-value
treated_vals <- balance %>% filter(Group == "Treated States")
control_vals <- balance %>% filter(Group == "Control States")

diff_row <- tibble(
  Group = "Difference",
  Log_Earnings = treated_vals$Log_Earnings - control_vals$Log_Earnings,
  Age = treated_vals$Age - control_vals$Age,
  Pct_Female = treated_vals$Pct_Female - control_vals$Pct_Female,
  N = NA_real_
)

table9 <- bind_rows(balance, diff_row)
write_csv(table9, "tables/table9_balance.csv")

# ============================================================================
# Table 10: State-Year Observations
# ============================================================================

cat("  Table 10: Data structure\n")

table10 <- state_year %>%
  group_by(year) %>%
  summarise(
    N_States = n(),
    N_Treated = sum(treated, na.rm = TRUE),
    N_Control = sum(!treated, na.rm = TRUE),
    Total_Obs = sum(n_obs),
    Mean_State_Obs = mean(n_obs),
    .groups = "drop"
  )

write_csv(table10, "tables/table10_data_structure.csv")

# ============================================================================
# Summary
# ============================================================================

cat("\n============================================\n")
cat("ADDITIONAL EXHIBITS COMPLETE\n")
cat("============================================\n")
cat("\nAdditional figures created: fig8-12\n")
cat("Additional tables created: table5-10\n")
cat("\nTotal figures: 12\n")
cat("Total tables: 10\n")
