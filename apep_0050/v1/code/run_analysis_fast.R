# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# run_analysis_fast.R - Streamlined Analysis with State-Year Panel
# ============================================================================

cat("Starting streamlined analysis pipeline...\n")
cat("Working directory:", getwd(), "\n")

# ============================================================================
# Load Packages
# ============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
  library(fixest)
  library(sf)
  library(tigris)
})

options(tigris_use_cache = TRUE)

# ============================================================================
# APEP Theme
# ============================================================================

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
  "female" = "#CC79A7"
)

# ============================================================================
# 1. Load and Combine MORG Data
# ============================================================================

cat("\n1. Loading MORG data files...\n")

morg_files <- list.files("data", pattern = "morg.*\\.dta$", full.names = TRUE)
cat("Found", length(morg_files), "MORG files\n")

morg_list <- list()
for (f in morg_files) {
  year <- as.numeric(paste0("20", gsub(".*morg(\\d+)\\.dta", "\\1", f)))
  cat("  Loading", year, "...\n")
  df <- haven::read_dta(f)
  df$year <- year
  morg_list[[as.character(year)]] <- df
}

cps_raw <- bind_rows(morg_list)
cat("Total observations:", format(nrow(cps_raw), big.mark = ","), "\n")

# ============================================================================
# 2. Define Treatment
# ============================================================================

cat("\n2. Defining treatment...\n")

treatment_dates <- tribble(
  ~stfips, ~state_abbr, ~state_name, ~treatment_year, ~threshold,
  8,  "CO", "Colorado",       2021, 1,
  6,  "CA", "California",     2023, 15,
  53, "WA", "Washington",     2023, 15,
  36, "NY", "New York",       2023, 4,
  15, "HI", "Hawaii",         2024, 50,
  11, "DC", "District of Columbia", 2024, 1,
  24, "MD", "Maryland",       2024, 1,
  17, "IL", "Illinois",       2025, 15,
  27, "MN", "Minnesota",      2025, 30
)

# ============================================================================
# 3. Clean Data
# ============================================================================

cat("\n3. Cleaning data...\n")

cps <- cps_raw %>%
  rename_with(tolower) %>%
  rename(
    statefip = any_of(c("stfips", "state")),
    earnweek = any_of(c("earnwke", "earnweek")),
    uhrswork = any_of(c("uhourse", "uhrswork"))
  )

# Apply sample restrictions
cps_analysis <- cps %>%
  filter(
    age >= 18, age <= 64,
    !is.na(earnweek), earnweek > 0,
    earnweek < 2885
  )

# Create female indicator
if (!"female" %in% names(cps_analysis)) {
  cps_analysis <- cps_analysis %>%
    mutate(female = as.integer(sex == 2))
}

# Merge treatment
cps_analysis <- cps_analysis %>%
  left_join(treatment_dates %>% select(stfips, state_abbr, state_name, treatment_year, threshold),
            by = c("statefip" = "stfips")) %>%
  mutate(
    ever_treated = !is.na(treatment_year),
    treatment_year = ifelse(is.na(treatment_year), 0, treatment_year),
    treated = ever_treated & year >= treatment_year,
    log_earnweek = log(earnweek),
    cohort = case_when(
      treatment_year == 0 ~ "Never treated",
      treatment_year == 2021 ~ "2021",
      treatment_year == 2023 ~ "2023",
      treatment_year == 2024 ~ "2024",
      treatment_year == 2025 ~ "2025",
      TRUE ~ as.character(treatment_year)
    )
  )

cat("After restrictions:", format(nrow(cps_analysis), big.mark = ","), "observations\n")

# Save individual-level data
saveRDS(cps_analysis, "data/cps_analysis.rds")

# ============================================================================
# 4. Create State-Year Panel
# ============================================================================

cat("\n4. Creating state-year panel...\n")

state_year <- cps_analysis %>%
  group_by(statefip, state_abbr, state_name, year, treatment_year, ever_treated, treated, cohort) %>%
  summarise(
    mean_earnweek = mean(earnweek, na.rm = TRUE),
    mean_log_earn = mean(log_earnweek, na.rm = TRUE),
    mean_earn_male = mean(log_earnweek[female == 0], na.rm = TRUE),
    mean_earn_female = mean(log_earnweek[female == 1], na.rm = TRUE),
    gender_gap = mean_earn_male - mean_earn_female,
    p10_earn = quantile(earnweek, 0.1, na.rm = TRUE),
    p50_earn = quantile(earnweek, 0.5, na.rm = TRUE),
    p90_earn = quantile(earnweek, 0.9, na.rm = TRUE),
    wage_9010 = p90_earn / p10_earn,
    pct_female = mean(female, na.rm = TRUE),
    mean_age = mean(age, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    event_time = ifelse(ever_treated & treatment_year > 0, year - treatment_year, NA_integer_),
    # For Sun-Abraham: cohort_year needs to be treatment year for treated, Inf for control
    cohort_year = ifelse(treatment_year > 0, treatment_year, Inf)
  )

saveRDS(state_year, "data/state_year_panel.rds")
cat("State-year observations:", nrow(state_year), "\n")

# ============================================================================
# 5. Main DiD Analysis using fixest
# ============================================================================

cat("\n5. Running main DiD analysis...\n")

# Simple DiD with state and year FE
cat("  5a. Simple DiD...\n")
did_simple <- feols(
  mean_log_earn ~ treated | statefip + year,
  data = state_year,
  weights = ~n_obs,
  cluster = ~statefip
)

cat("\nSimple DiD Results:\n")
print(summary(did_simple))

# Sun-Abraham Event Study
cat("\n  5b. Sun-Abraham Event Study...\n")
es_model <- feols(
  mean_log_earn ~ sunab(cohort_year, year) | statefip + year,
  data = state_year %>% filter(is.finite(cohort_year) | treatment_year == 0),
  weights = ~n_obs,
  cluster = ~statefip
)

cat("\nSun-Abraham Event Study:\n")
print(summary(es_model))

# Extract ATT
att_agg <- summary(es_model, agg = "ATT")
cat("\nOverall ATT:", att_agg$coeftable[1, 1],
    "(SE:", att_agg$coeftable[1, 2], ")\n")

# ============================================================================
# 6. Gender Wage Gap Analysis
# ============================================================================

cat("\n6. Gender wage gap analysis...\n")

# DiD on gender gap
gap_did <- feols(
  gender_gap ~ treated | statefip + year,
  data = state_year,
  weights = ~n_obs,
  cluster = ~statefip
)

cat("\nGender Gap DiD:\n")
print(summary(gap_did))

# Event study on gender gap
gap_es <- feols(
  gender_gap ~ sunab(cohort_year, year) | statefip + year,
  data = state_year %>% filter(is.finite(cohort_year) | treatment_year == 0),
  weights = ~n_obs,
  cluster = ~statefip
)

cat("\nGender Gap Event Study:\n")
print(summary(gap_es))

# ============================================================================
# 7. Heterogeneity Analysis
# ============================================================================

cat("\n7. Heterogeneity analysis...\n")

# DiD on male and female earnings separately
male_did <- feols(
  mean_earn_male ~ treated | statefip + year,
  data = state_year,
  weights = ~n_obs,
  cluster = ~statefip
)

female_did <- feols(
  mean_earn_female ~ treated | statefip + year,
  data = state_year,
  weights = ~n_obs,
  cluster = ~statefip
)

cat("\nMale earnings effect:", coef(male_did), "(SE:", se(male_did), ")\n")
cat("Female earnings effect:", coef(female_did), "(SE:", se(female_did), ")\n")

# ============================================================================
# 8. Save Results
# ============================================================================

cat("\n8. Saving results...\n")

results <- list(
  did_simple = did_simple,
  es_model = es_model,
  gap_did = gap_did,
  gap_es = gap_es,
  male_did = male_did,
  female_did = female_did
)

saveRDS(results, "data/main_results.rds")

# ============================================================================
# 9. Create Figures
# ============================================================================

cat("\n9. Creating figures...\n")

# Figure 1: Adoption Map
cat("  Figure 1: Adoption map\n")

states_sf <- states(cb = TRUE, class = "sf") %>%
  filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"))

treatment_map <- state_year %>%
  filter(year == 2024) %>%
  distinct(statefip, treatment_year, cohort) %>%
  mutate(STATEFP = sprintf("%02d", statefip))

states_map <- states_sf %>%
  left_join(treatment_map, by = "STATEFP") %>%
  mutate(adoption = ifelse(is.na(treatment_year) | treatment_year == 0,
                           "Not adopted", as.character(treatment_year)))

fig1 <- ggplot(states_map) +
  geom_sf(aes(fill = adoption), color = "white", size = 0.2) +
  scale_fill_manual(
    values = c("2021" = "#1a9850", "2023" = "#91cf60", "2024" = "#d9ef8b",
               "2025" = "#fee08b", "Not adopted" = "#f7f7f7"),
    na.value = "#f7f7f7",
    name = "Adoption Year"
  ) +
  labs(title = "State Salary Transparency Law Adoption",
       subtitle = "Laws requiring salary range disclosure in job postings",
       caption = "Note: Shows states with laws effective by 2025. Grey indicates no law adopted.") +
  theme_void() +
  theme(legend.position = "bottom",
        plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5))

ggsave("figures/fig1_adoption_map.pdf", fig1, width = 10, height = 7)
ggsave("figures/fig1_adoption_map.png", fig1, width = 10, height = 7, dpi = 300)

# Figure 2: Event Study
cat("  Figure 2: Event study\n")

# Extract event study coefficients directly
es_coefs <- coef(es_model)
es_se <- se(es_model)

# Event times are encoded as "year::-3" etc.
es_df <- tibble(
  term = names(es_coefs),
  estimate = es_coefs,
  se = es_se
) %>%
  filter(grepl("^year::", term)) %>%
  mutate(
    event_time = as.numeric(gsub("year::(-?[0-9]+)", "\\1", term)),
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  ) %>%
  filter(!is.na(event_time))

fig2 <- ggplot(es_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "solid", color = "grey30") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = apep_colors["treated"]) +
  geom_point(size = 3, color = apep_colors["treated"]) +
  labs(
    title = "Effect of Salary Transparency Laws on Log Weekly Earnings",
    subtitle = "Sun-Abraham event study estimates",
    x = "Years Relative to Treatment",
    y = "ATT (Log Points)",
    caption = "Note: 95% confidence intervals with state-clustered SEs."
  ) +
  theme_apep()

ggsave("figures/fig2_event_study.pdf", fig2, width = 10, height = 6)
ggsave("figures/fig2_event_study.png", fig2, width = 10, height = 6, dpi = 300)

# Figure 3: Cohort Trends
cat("  Figure 3: Cohort trends\n")

cohort_trends <- state_year %>%
  group_by(cohort, year) %>%
  summarise(
    mean_earn = weighted.mean(mean_log_earn, n_obs, na.rm = TRUE),
    se = sqrt(sum(n_obs * (mean_log_earn - mean_earn)^2) / sum(n_obs)) / sqrt(n()),
    .groups = "drop"
  ) %>%
  filter(cohort %in% c("2021", "2023", "2024", "Never treated"))

treatment_lines <- tibble(
  cohort = c("2021", "2023", "2024"),
  treat_year = c(2021, 2023, 2024)
)

fig3 <- ggplot(cohort_trends, aes(x = year, y = mean_earn, color = cohort)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(data = treatment_lines, aes(xintercept = treat_year, color = cohort),
             linetype = "dashed", alpha = 0.5) +
  scale_color_manual(values = c("2021" = "#1a9850", "2023" = "#91cf60",
                                 "2024" = "#d9ef8b", "Never treated" = "#d73027"),
                     name = "Cohort") +
  labs(
    title = "Average Log Weekly Earnings by Treatment Cohort",
    subtitle = "State-level means weighted by sample size",
    x = "Year", y = "Log Weekly Earnings",
    caption = "Note: Dashed lines indicate treatment year for each cohort."
  ) +
  theme_apep()

ggsave("figures/fig3_cohort_trends.pdf", fig3, width = 10, height = 6)
ggsave("figures/fig3_cohort_trends.png", fig3, width = 10, height = 6, dpi = 300)

# Figure 4: Gender Gap Over Time
cat("  Figure 4: Gender gap trends\n")

gap_trends <- state_year %>%
  group_by(ever_treated, year) %>%
  summarise(
    gap = weighted.mean(gender_gap, n_obs, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(ever_treated, "Treated States", "Control States"))

fig4 <- ggplot(gap_trends, aes(x = year, y = gap, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Treated States" = apep_colors["treated"],
                                 "Control States" = apep_colors["control"])) +
  labs(
    title = "Gender Wage Gap Over Time",
    subtitle = "Male-female log wage differential",
    x = "Year", y = "Gender Gap (Log Points)",
    color = NULL,
    caption = "Note: Higher values indicate larger male wage premium."
  ) +
  theme_apep()

ggsave("figures/fig4_gender_gap_trends.pdf", fig4, width = 9, height = 6)
ggsave("figures/fig4_gender_gap_trends.png", fig4, width = 9, height = 6, dpi = 300)

# Figure 5: Heterogeneity
cat("  Figure 5: Heterogeneity\n")

het_df <- tibble(
  Group = c("All Workers", "Male", "Female"),
  ATT = c(coef(did_simple), coef(male_did), coef(female_did)),
  SE = c(se(did_simple), se(male_did), se(female_did))
) %>%
  mutate(
    ci_lower = ATT - 1.96 * SE,
    ci_upper = ATT + 1.96 * SE,
    Group = factor(Group, levels = rev(c("All Workers", "Male", "Female")))
  )

fig5 <- ggplot(het_df, aes(x = ATT, y = Group)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = apep_colors["treated"]) +
  geom_point(size = 3, color = apep_colors["treated"]) +
  labs(
    title = "Heterogeneous Treatment Effects",
    subtitle = "Effect of transparency laws on log weekly earnings by group",
    x = "ATT (Log Points)", y = NULL,
    caption = "Note: 95% confidence intervals with state-clustered SEs."
  ) +
  theme_apep() +
  theme(panel.grid.major.y = element_blank())

ggsave("figures/fig5_heterogeneity.pdf", fig5, width = 8, height = 4)
ggsave("figures/fig5_heterogeneity.png", fig5, width = 8, height = 4, dpi = 300)

# Figure 6: Treatment timeline
cat("  Figure 6: Treatment timeline\n")

timeline_data <- treatment_dates %>%
  mutate(state_name = factor(state_name, levels = state_name[order(treatment_year)]))

fig6 <- ggplot(timeline_data, aes(x = treatment_year, y = fct_rev(state_name))) +
  geom_segment(aes(x = 2016, xend = treatment_year, y = fct_rev(state_name), yend = fct_rev(state_name)),
               color = "grey80") +
  geom_point(aes(color = factor(treatment_year)), size = 4) +
  geom_text(aes(label = paste0(threshold, "+ emp")), hjust = -0.3, size = 3) +
  scale_color_manual(values = c("2021" = "#1a9850", "2023" = "#91cf60",
                                 "2024" = "#d9ef8b", "2025" = "#fee08b"),
                     guide = "none") +
  scale_x_continuous(breaks = 2016:2025, limits = c(2016, 2026)) +
  labs(
    title = "Staggered Adoption of Salary Transparency Laws",
    subtitle = "Effective dates and employer size thresholds",
    x = "Year", y = NULL,
    caption = "Note: Labels show minimum employer size for law to apply."
  ) +
  theme_apep() +
  theme(panel.grid.major.y = element_blank())

ggsave("figures/fig6_timeline.pdf", fig6, width = 9, height = 5)
ggsave("figures/fig6_timeline.png", fig6, width = 9, height = 5, dpi = 300)

# Figure 7: Wage distribution shift
cat("  Figure 7: Wage distribution\n")

wage_dist <- cps_analysis %>%
  filter(ever_treated, treatment_year == 2021) %>%
  mutate(period = ifelse(year < 2021, "Pre-treatment", "Post-treatment"))

fig7 <- ggplot(wage_dist, aes(x = log_earnweek, fill = period)) +
  geom_density(alpha = 0.5, color = NA) +
  scale_fill_manual(values = c("Pre-treatment" = apep_colors["control"],
                                "Post-treatment" = apep_colors["treated"]),
                    name = NULL) +
  labs(
    title = "Log Wage Distribution in Colorado",
    subtitle = "Before and after transparency law (effective Jan 2021)",
    x = "Log Weekly Earnings", y = "Density"
  ) +
  theme_apep() +
  theme(legend.position = c(0.8, 0.8))

ggsave("figures/fig7_wage_dist.pdf", fig7, width = 9, height = 6)
ggsave("figures/fig7_wage_dist.png", fig7, width = 9, height = 6, dpi = 300)

cat("Figures saved to figures/\n")

# ============================================================================
# 10. Create Tables
# ============================================================================

cat("\n10. Creating tables...\n")

# Table 1: Summary Statistics
summ_by_group <- cps_analysis %>%
  group_by(ever_treated) %>%
  summarise(
    mean_earn = mean(earnweek, na.rm = TRUE),
    mean_log = mean(log_earnweek, na.rm = TRUE),
    pct_female = mean(female, na.rm = TRUE) * 100,
    mean_age = mean(age, na.rm = TRUE),
    n = n()
  ) %>%
  mutate(Group = ifelse(ever_treated, "Treated", "Control"))

summ_all <- cps_analysis %>%
  summarise(
    mean_earn = mean(earnweek, na.rm = TRUE),
    mean_log = mean(log_earnweek, na.rm = TRUE),
    pct_female = mean(female, na.rm = TRUE) * 100,
    mean_age = mean(age, na.rm = TRUE),
    n = n()
  ) %>%
  mutate(Group = "Full Sample")

summ_stats <- bind_rows(summ_by_group, summ_all)
write_csv(summ_stats, "tables/table1_summary.csv")

# Table 2: Main Results
main_table <- tibble(
  Specification = c("Simple DiD", "Sun-Abraham ATT"),
  Estimate = c(coef(did_simple)["treated"], att_agg$coeftable[1, 1]),
  SE = c(se(did_simple)["treated"], att_agg$coeftable[1, 2]),
  N_obs = c(nrow(state_year), nrow(state_year %>% filter(is.finite(cohort_year) | treatment_year == 0))),
  N_states = c(n_distinct(state_year$statefip),
               n_distinct(state_year$statefip[is.finite(state_year$cohort_year) | state_year$treatment_year == 0]))
) %>%
  mutate(
    CI_lower = Estimate - 1.96 * SE,
    CI_upper = Estimate + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(Estimate / SE))),
    stars = case_when(p_value < 0.01 ~ "***", p_value < 0.05 ~ "**", p_value < 0.10 ~ "*", TRUE ~ "")
  )

write_csv(main_table, "tables/table2_main_results.csv")

# Table 3: Heterogeneity
het_table <- tibble(
  Subgroup = c("All Workers", "Male Earnings", "Female Earnings", "Gender Gap"),
  ATT = c(coef(did_simple), coef(male_did), coef(female_did), coef(gap_did)),
  SE = c(se(did_simple), se(male_did), se(female_did), se(gap_did))
) %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE
  )

write_csv(het_table, "tables/table3_heterogeneity.csv")

# Table 4: Treatment timing
write_csv(treatment_dates, "tables/table4_treatment_timing.csv")

cat("Tables saved to tables/\n")

# ============================================================================
# 11. Summary
# ============================================================================

cat("\n============================================\n")
cat("ANALYSIS COMPLETE\n")
cat("============================================\n")
cat("\nKey Results:\n")
cat("  Simple DiD ATT:", round(coef(did_simple)["treated"], 4),
    "(SE:", round(se(did_simple)["treated"], 4), ")\n")
cat("  Sun-Abraham ATT:", round(att_agg$coeftable[1, 1], 4),
    "(SE:", round(att_agg$coeftable[1, 2], 4), ")\n")
cat("  Male earnings effect:", round(coef(male_did), 4),
    "(SE:", round(se(male_did), 4), ")\n")
cat("  Female earnings effect:", round(coef(female_did), 4),
    "(SE:", round(se(female_did), 4), ")\n")
cat("  Gender gap effect:", round(coef(gap_did), 4),
    "(SE:", round(se(gap_did), 4), ")\n")

cat("\nSample:\n")
cat("  Individual observations:", format(nrow(cps_analysis), big.mark = ","), "\n")
cat("  State-year observations:", nrow(state_year), "\n")
cat("  Treated states:", sum(treatment_dates$treatment_year > 0), "\n")
cat("  Control states:", n_distinct(state_year$statefip) - sum(treatment_dates$treatment_year > 0), "\n")

cat("\nFiles created:\n")
cat("  Data: data/cps_analysis.rds, data/state_year_panel.rds, data/main_results.rds\n")
cat("  Figures: figures/fig1-7 (.pdf and .png)\n")
cat("  Tables: tables/table1-4.csv\n")
