# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# run_analysis.R - Complete Analysis Pipeline
# ============================================================================

cat("Starting analysis pipeline...\n")
cat("Working directory:", getwd(), "\n")

# ============================================================================
# Load Packages
# ============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
  library(did)
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

cat("Treatment states:\n")
print(treatment_dates %>% select(state_abbr, treatment_year))

# ============================================================================
# 3. Clean Data
# ============================================================================

cat("\n3. Cleaning data...\n")

# Harmonize variable names (MORG uses different names across years)
cps <- cps_raw %>%
  rename_with(tolower) %>%
  rename(
    statefip = any_of(c("stfips", "state")),
    earnweek = any_of(c("earnwke", "earnweek")),
    uhrswork = any_of(c("uhourse", "uhrswork"))
  )

# Check for key variables
required_vars <- c("statefip", "year", "age", "sex", "earnweek")
missing_vars <- required_vars[!required_vars %in% names(cps)]
if (length(missing_vars) > 0) {
  cat("Warning: Missing variables:", paste(missing_vars, collapse = ", "), "\n")
  cat("Available variables:", paste(head(names(cps), 30), collapse = ", "), "\n")
}

# Apply sample restrictions
cps_analysis <- cps %>%
  filter(
    age >= 18, age <= 64,
    !is.na(earnweek), earnweek > 0,
    earnweek < 2885
  )

cat("After restrictions:", format(nrow(cps_analysis), big.mark = ","), "observations\n")

# Create female indicator
if (!"female" %in% names(cps_analysis)) {
  cps_analysis <- cps_analysis %>%
    mutate(female = as.integer(sex == 2))
}

# Merge treatment
cps_analysis <- cps_analysis %>%
  left_join(treatment_dates %>% select(stfips, treatment_year, threshold),
            by = c("statefip" = "stfips")) %>%
  mutate(
    ever_treated = !is.na(treatment_year),
    treated = ever_treated & year >= treatment_year,
    treatment_year = ifelse(is.na(treatment_year), 0, treatment_year),
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

# Get state names
state_names <- tibble(
  statefip = c(1:56),
  state_name = state.name[match(c(state.abb, "DC")[1:56], c(state.abb, "DC"))]
) %>% filter(!is.na(state_name))

cps_analysis <- cps_analysis %>%
  left_join(state_names, by = "statefip")

cat("Treatment summary:\n")
print(cps_analysis %>%
        group_by(cohort) %>%
        summarise(n = n(), n_states = n_distinct(statefip)))

# Save cleaned data
saveRDS(cps_analysis, "data/cps_analysis.rds")
cat("Saved: data/cps_analysis.rds\n")

# ============================================================================
# 4. Create State-Year Panel
# ============================================================================

cat("\n4. Creating state-year panel...\n")

state_year <- cps_analysis %>%
  group_by(statefip, state_name, year, treatment_year, ever_treated, treated, cohort) %>%
  summarise(
    mean_earnweek = mean(earnweek, na.rm = TRUE),
    mean_log_earn = mean(log_earnweek, na.rm = TRUE),
    mean_earn_male = mean(log_earnweek[female == 0], na.rm = TRUE),
    mean_earn_female = mean(log_earnweek[female == 1], na.rm = TRUE),
    gender_gap = mean_earn_male - mean_earn_female,
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(event_time = ifelse(ever_treated, year - treatment_year, NA_integer_))

saveRDS(state_year, "data/state_year_panel.rds")
cat("Saved: data/state_year_panel.rds\n")
cat("State-year observations:", nrow(state_year), "\n")

# ============================================================================
# 5. Main DiD Analysis
# ============================================================================

cat("\n5. Running main DiD analysis...\n")

# Prepare for did package
cps_did <- cps_analysis %>%
  mutate(id = row_number(), G = treatment_year)

# Callaway-Sant'Anna estimation
# CPS is repeated cross-sections, not panel, so set panel = FALSE
cat("Running Callaway-Sant'Anna (repeated cross-sections)...\n")
cs_att <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did,
  control_group = "notyettreated",
  clustervars = "statefip",
  panel = FALSE,  # Critical for repeated cross-section data
  allow_unbalanced_panel = TRUE,
  bstrap = TRUE,
  biters = 500
)

# Aggregate
es_att <- aggte(cs_att, type = "dynamic", balance_e = -3)
overall_att <- aggte(cs_att, type = "simple")

cat("\nOverall ATT:\n")
cat("  Estimate:", round(overall_att$overall.att, 4), "\n")
cat("  SE:", round(overall_att$overall.se, 4), "\n")
cat("  95% CI: [", round(overall_att$overall.att - 1.96 * overall_att$overall.se, 4),
    ",", round(overall_att$overall.att + 1.96 * overall_att$overall.se, 4), "]\n")

# Save results
results <- list(
  cs_att = cs_att,
  es_att = es_att,
  overall_att = overall_att
)
saveRDS(results, "data/main_results.rds")

# ============================================================================
# 6. Sun-Abraham for Comparison
# ============================================================================

cat("\n6. Running Sun-Abraham...\n")

cps_did <- cps_did %>%
  mutate(cohort_year = ifelse(G > 0, G, Inf))

sa_model <- feols(
  log_earnweek ~ sunab(cohort_year, year) | statefip + year,
  data = cps_did %>% filter(is.finite(cohort_year) | G == 0),
  cluster = ~statefip
)

cat("Sun-Abraham summary:\n")
print(summary(sa_model, agg = "ATT"))

# ============================================================================
# 7. Heterogeneity Analysis
# ============================================================================

cat("\n7. Running heterogeneity analysis...\n")

# By gender
cs_male <- att_gt(
  yname = "log_earnweek", tname = "year", idname = "id", gname = "G",
  data = cps_did %>% filter(female == 0),
  control_group = "notyettreated", clustervars = "statefip",
  panel = FALSE, allow_unbalanced_panel = TRUE, bstrap = TRUE, biters = 200
)
cs_female <- att_gt(
  yname = "log_earnweek", tname = "year", idname = "id", gname = "G",
  data = cps_did %>% filter(female == 1),
  control_group = "notyettreated", clustervars = "statefip",
  panel = FALSE, allow_unbalanced_panel = TRUE, bstrap = TRUE, biters = 200
)

overall_male <- aggte(cs_male, type = "simple")
overall_female <- aggte(cs_female, type = "simple")

cat("\nHeterogeneity by gender:\n")
cat("  Male ATT:", round(overall_male$overall.att, 4),
    "(SE:", round(overall_male$overall.se, 4), ")\n")
cat("  Female ATT:", round(overall_female$overall.att, 4),
    "(SE:", round(overall_female$overall.se, 4), ")\n")

# Save heterogeneity
results$het_male <- overall_male
results$het_female <- overall_female
saveRDS(results, "data/main_results.rds")

# ============================================================================
# 8. Create Figures
# ============================================================================

cat("\n8. Creating figures...\n")

# Figure 1: Adoption Map
cat("  Figure 1: Adoption map\n")

states_sf <- states(cb = TRUE, class = "sf") %>%
  filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"))

treatment_map <- cps_analysis %>%
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
       subtitle = "Laws requiring salary range disclosure in job postings") +
  theme_void() +
  theme(legend.position = "bottom")

ggsave("figures/fig1_adoption_map.pdf", fig1, width = 10, height = 7)
ggsave("figures/fig1_adoption_map.png", fig1, width = 10, height = 7, dpi = 300)

# Figure 2: Event Study
cat("  Figure 2: Event study\n")

es_df <- tibble(
  event_time = es_att$egt,
  estimate = es_att$att.egt,
  se = es_att$se.egt
) %>%
  filter(!is.na(estimate)) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

fig2 <- ggplot(es_df, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "solid", color = "grey30") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = apep_colors["treated"]) +
  geom_point(size = 3, color = apep_colors["treated"]) +
  scale_x_continuous(breaks = seq(-5, 4, 1)) +
  labs(
    title = "Effect of Salary Transparency Laws on Log Weekly Earnings",
    subtitle = "Callaway-Sant'Anna event study estimates",
    x = "Years Relative to Treatment",
    y = "ATT (Log Points)",
    caption = "Note: 95% confidence intervals. State-clustered standard errors."
  ) +
  theme_apep()

ggsave("figures/fig2_event_study.pdf", fig2, width = 10, height = 6)
ggsave("figures/fig2_event_study.png", fig2, width = 10, height = 6, dpi = 300)

# Figure 3: Cohort Trends
cat("  Figure 3: Cohort trends\n")

cohort_trends <- state_year %>%
  group_by(cohort, year) %>%
  summarise(mean_earn = mean(mean_log_earn, na.rm = TRUE),
            se = sd(mean_log_earn, na.rm = TRUE) / sqrt(n()),
            .groups = "drop") %>%
  filter(cohort %in% c("2021", "2023", "2024", "Never treated"))

fig3 <- ggplot(cohort_trends, aes(x = year, y = mean_earn, color = cohort)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c("2021" = "#1a9850", "2023" = "#91cf60",
                                 "2024" = "#d9ef8b", "Never treated" = "#d73027")) +
  labs(
    title = "Average Log Weekly Earnings by Treatment Cohort",
    x = "Year", y = "Log Weekly Earnings", color = "Cohort"
  ) +
  theme_apep()

ggsave("figures/fig3_cohort_trends.pdf", fig3, width = 10, height = 6)
ggsave("figures/fig3_cohort_trends.png", fig3, width = 10, height = 6, dpi = 300)

# Figure 4: Gender Gap Over Time
cat("  Figure 4: Gender gap trends\n")

gap_trends <- state_year %>%
  group_by(ever_treated, year) %>%
  summarise(gap = mean(gender_gap, na.rm = TRUE), .groups = "drop") %>%
  mutate(group = ifelse(ever_treated, "Treated", "Control"))

fig4 <- ggplot(gap_trends, aes(x = year, y = gap, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Treated" = apep_colors["treated"],
                                 "Control" = apep_colors["control"])) +
  labs(
    title = "Gender Wage Gap Over Time",
    subtitle = "Male-female log wage differential",
    x = "Year", y = "Gender Gap (Log Points)", color = NULL
  ) +
  theme_apep()

ggsave("figures/fig4_gender_gap_trends.pdf", fig4, width = 9, height = 6)
ggsave("figures/fig4_gender_gap_trends.png", fig4, width = 9, height = 6, dpi = 300)

# Figure 5: Heterogeneity
cat("  Figure 5: Heterogeneity\n")

het_df <- tibble(
  Group = c("All Workers", "Male", "Female"),
  ATT = c(overall_att$overall.att, overall_male$overall.att, overall_female$overall.att),
  SE = c(overall_att$overall.se, overall_male$overall.se, overall_female$overall.se)
) %>%
  mutate(ci_lower = ATT - 1.96 * SE, ci_upper = ATT + 1.96 * SE,
         Group = factor(Group, levels = rev(c("All Workers", "Male", "Female"))))

fig5 <- ggplot(het_df, aes(x = ATT, y = Group)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = apep_colors["treated"]) +
  geom_point(size = 3, color = apep_colors["treated"]) +
  labs(
    title = "Heterogeneous Treatment Effects",
    x = "ATT (Log Points)", y = NULL
  ) +
  theme_apep()

ggsave("figures/fig5_heterogeneity.pdf", fig5, width = 8, height = 4)
ggsave("figures/fig5_heterogeneity.png", fig5, width = 8, height = 4, dpi = 300)

cat("\nFigures saved to figures/\n")

# ============================================================================
# 9. Create Tables
# ============================================================================

cat("\n9. Creating tables...\n")

# Table 1: Summary Statistics
summ_stats <- cps_analysis %>%
  group_by(ever_treated) %>%
  summarise(
    mean_earn = mean(earnweek, na.rm = TRUE),
    mean_log = mean(log_earnweek, na.rm = TRUE),
    pct_female = mean(female, na.rm = TRUE) * 100,
    mean_age = mean(age, na.rm = TRUE),
    n = n()
  ) %>%
  mutate(group = ifelse(ever_treated, "Treated", "Control"))

write_csv(summ_stats, "tables/table1_summary.csv")

# Table 2: Main Results
main_table <- tibble(
  Specification = c("Overall ATT", "Event t=0", "Event t=1", "Event t=2"),
  Estimate = c(overall_att$overall.att,
               es_att$att.egt[es_att$egt == 0],
               es_att$att.egt[es_att$egt == 1],
               es_att$att.egt[es_att$egt == 2]),
  SE = c(overall_att$overall.se,
         es_att$se.egt[es_att$egt == 0],
         es_att$se.egt[es_att$egt == 1],
         es_att$se.egt[es_att$egt == 2])
) %>%
  mutate(CI_lower = Estimate - 1.96 * SE, CI_upper = Estimate + 1.96 * SE)

write_csv(main_table, "tables/table2_main_results.csv")

# Table 3: Heterogeneity
het_table <- tibble(
  Subgroup = c("All Workers", "Male", "Female"),
  ATT = c(overall_att$overall.att, overall_male$overall.att, overall_female$overall.att),
  SE = c(overall_att$overall.se, overall_male$overall.se, overall_female$overall.se)
)

write_csv(het_table, "tables/table3_heterogeneity.csv")

cat("Tables saved to tables/\n")

# ============================================================================
# 10. Summary
# ============================================================================

cat("\n============================================\n")
cat("ANALYSIS COMPLETE\n")
cat("============================================\n")
cat("\nKey Results:\n")
cat("  Overall ATT:", round(overall_att$overall.att, 4),
    "(SE:", round(overall_att$overall.se, 4), ")\n")
cat("  Male ATT:", round(overall_male$overall.att, 4),
    "(SE:", round(overall_male$overall.se, 4), ")\n")
cat("  Female ATT:", round(overall_female$overall.att, 4),
    "(SE:", round(overall_female$overall.se, 4), ")\n")

cat("\nFiles created:\n")
cat("  Data: data/cps_analysis.rds, data/state_year_panel.rds, data/main_results.rds\n")
cat("  Figures: figures/fig1-5 (.pdf and .png)\n")
cat("  Tables: tables/table1-3.csv\n")
