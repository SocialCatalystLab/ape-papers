# ============================================================================
# 03_descriptives.R
# Salary Transparency Laws and the Gender Wage Gap
# Descriptive Statistics and Balance Tables
# ============================================================================
#
# --- Input/Output Provenance ---
# INPUTS:
#   data/cps_analysis.rds          <- 02_clean_data.R (individual-level analysis data)
#   data/state_year_panel.rds      <- 02_clean_data.R (state-year aggregates)
#   data/transparency_laws.rds     <- 00_policy_data.R (treatment timing + citations)
# OUTPUTS:
#   data/descriptive_stats.rds     (summary statistics by treatment/gender)
#   figures/fig1_policy_map.pdf    (geographic adoption map)
#   figures/fig2_wage_trends.pdf   (wage trends by treatment status)
#   figures/fig3_gap_trends.pdf    (gender wage gap trends)
#   figures/fig4_cohort_trends.pdf (cohort-specific wage trends)
# ============================================================================

source("code/00_packages.R")

# Load cleaned data
df <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
transparency_laws <- readRDS("data/transparency_laws.rds")

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("Creating summary statistics table...\n")

# Overall summary
overall_stats <- df %>%
  summarize(
    `Hourly Wage ($)` = sprintf("%.2f (%.2f)", mean(hourly_wage), sd(hourly_wage)),
    `Log Hourly Wage` = sprintf("%.2f (%.2f)", mean(log_hourly_wage), sd(log_hourly_wage)),
    `Female (%)` = sprintf("%.1f", mean(female) * 100),
    `Age (years)` = sprintf("%.1f (%.1f)", mean(AGE), sd(AGE)),
    `College+ (%)` = sprintf("%.1f", mean(educ_cat %in% c("BA or higher", "Graduate degree")) * 100),
    `Full-time (%)` = sprintf("%.1f", mean(fulltime) * 100),
    `Married (%)` = sprintf("%.1f", mean(married) * 100),
    `Metropolitan (%)` = sprintf("%.1f", mean(metro) * 100),
    `High-bargaining Occ (%)` = sprintf("%.1f", mean(high_bargaining) * 100),
    N = format(n(), big.mark = ",")
  )

# By treatment status (pre-treatment period only)
by_treatment <- df %>%
  filter(income_year < 2021) %>%  # Pre-treatment for all
  group_by(ever_treated) %>%
  summarize(
    `Hourly Wage ($)` = sprintf("%.2f (%.2f)", mean(hourly_wage), sd(hourly_wage)),
    `Log Hourly Wage` = sprintf("%.2f (%.2f)", mean(log_hourly_wage), sd(log_hourly_wage)),
    `Female (%)` = sprintf("%.1f", mean(female) * 100),
    `Age (years)` = sprintf("%.1f (%.1f)", mean(AGE), sd(AGE)),
    `College+ (%)` = sprintf("%.1f", mean(educ_cat %in% c("BA or higher", "Graduate degree")) * 100),
    `Full-time (%)` = sprintf("%.1f", mean(fulltime) * 100),
    `Married (%)` = sprintf("%.1f", mean(married) * 100),
    `Metropolitan (%)` = sprintf("%.1f", mean(metro) * 100),
    `High-bargaining Occ (%)` = sprintf("%.1f", mean(high_bargaining) * 100),
    N = format(n(), big.mark = ","),
    .groups = "drop"
  ) %>%
  mutate(Group = ifelse(ever_treated == 1, "Treated States", "Control States")) %>%
  select(Group, everything(), -ever_treated)

# By gender
by_gender <- df %>%
  group_by(female) %>%
  summarize(
    `Hourly Wage ($)` = sprintf("%.2f (%.2f)", mean(hourly_wage), sd(hourly_wage)),
    `Log Hourly Wage` = sprintf("%.2f (%.2f)", mean(log_hourly_wage), sd(log_hourly_wage)),
    `Age (years)` = sprintf("%.1f (%.1f)", mean(AGE), sd(AGE)),
    `College+ (%)` = sprintf("%.1f", mean(educ_cat %in% c("BA or higher", "Graduate degree")) * 100),
    `Full-time (%)` = sprintf("%.1f", mean(fulltime) * 100),
    `Married (%)` = sprintf("%.1f", mean(married) * 100),
    N = format(n(), big.mark = ","),
    .groups = "drop"
  ) %>%
  mutate(Gender = ifelse(female == 1, "Female", "Male")) %>%
  select(Gender, everything(), -female)

print(by_treatment)
print(by_gender)

# ============================================================================
# Table 2: Treatment Timing and State Characteristics
# ============================================================================

cat("\nCreating treatment timing table...\n")

treatment_table <- transparency_laws %>%
  filter(first_treat > 0) %>%  # Only treated states
  select(state, effective_date, first_treat, employer_threshold) %>%
  arrange(effective_date) %>%
  mutate(
    `Effective Date` = format(effective_date, "%B %d, %Y"),
    `First Income Year` = first_treat,
    `Employer Threshold` = employer_threshold
  ) %>%
  select(State = state, `Effective Date`, `First Income Year`, `Employer Threshold`)

print(treatment_table)

# ============================================================================
# Figure 1: Policy Adoption Map
# ============================================================================

cat("\nCreating policy adoption map...\n")

# Get state boundaries
states <- states(cb = TRUE) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))  # Lower 48

# Prepare mapping data
map_data <- states %>%
  mutate(statefip = as.integer(STATEFP)) %>%
  left_join(
    transparency_laws %>% select(statefip, first_treat),
    by = "statefip"
  ) %>%
  mutate(
    treatment_status = case_when(
      first_treat == 2021 ~ "2021 (Pioneer)",
      first_treat == 2022 ~ "2022",
      first_treat == 2023 ~ "2023",
      first_treat == 2024 ~ "2024",
      first_treat >= 2025 ~ "2025+",
      TRUE ~ "No Law (Control)"
    ),
    treatment_status = factor(treatment_status,
                              levels = c("2021 (Pioneer)", "2022", "2023",
                                        "2024", "2025+", "No Law (Control)"))
  )

# Create map
p_map <- ggplot(map_data) +
  geom_sf(aes(fill = treatment_status), color = "white", linewidth = 0.2) +
  scale_fill_manual(
    name = "First Treated Year",
    values = c(
      "2021 (Pioneer)" = "#08306b",
      "2022" = "#2171b5",
      "2023" = "#4292c6",
      "2024" = "#6baed6",
      "2025+" = "#c6dbef",
      "No Law (Control)" = "grey85"
    ),
    na.value = "grey85"
  ) +
  labs(
    title = "Staggered Adoption of Salary Transparency Laws",
    subtitle = "State laws requiring salary range disclosure in job postings, 2021-2025",
    caption = "Note: Shows first income year affected. Grey states serve as control group."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.size = unit(0.8, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0.5, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("figures/fig1_policy_map.pdf", p_map, width = 10, height = 7)
ggsave("figures/fig1_policy_map.png", p_map, width = 10, height = 7, dpi = 300)

cat("Saved figures/fig1_policy_map.pdf\n")

# ============================================================================
# Figure 2: Wage Trends by Treatment Status
# ============================================================================

cat("\nCreating wage trends figure...\n")

# Calculate trends by treatment status and year
trends <- df %>%
  group_by(income_year, ever_treated) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    se = sqrt(sum(ASECWT^2 * (hourly_wage - mean_wage)^2) / sum(ASECWT)^2),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    group = factor(ifelse(ever_treated == 1, "Treated States", "Control States"),
                   levels = c("Treated States", "Control States"))
  )

# First treatment year
first_treat_year <- 2021

p_trends <- ggplot(trends, aes(x = income_year, y = mean_wage, color = group)) +
  geom_vline(xintercept = first_treat_year - 0.5, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  geom_ribbon(aes(ymin = mean_wage - 1.96 * se, ymax = mean_wage + 1.96 * se,
                  fill = group), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  annotate("text", x = first_treat_year + 0.1, y = max(trends$mean_wage) * 0.98,
           label = "First Treatment\n(Colorado)", hjust = 0, size = 3,
           color = "grey40", fontface = "italic") +
  scale_color_manual(values = c("Treated States" = color_treated,
                                "Control States" = color_control)) +
  scale_fill_manual(values = c("Treated States" = color_treated,
                               "Control States" = color_control)) +
  scale_x_continuous(breaks = 2014:2023) +
  labs(
    title = "Mean Hourly Wage by Treatment Status",
    subtitle = "Treated vs. control states, 2014-2023",
    x = "Income Year",
    y = "Mean Hourly Wage ($)",
    color = NULL, fill = NULL,
    caption = "Note: Shaded areas show 95% confidence intervals. Vertical line marks first treatment."
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.85))

ggsave("figures/fig2_wage_trends.pdf", p_trends, width = 9, height = 6)
ggsave("figures/fig2_wage_trends.png", p_trends, width = 9, height = 6, dpi = 300)

cat("Saved figures/fig2_wage_trends.pdf\n")

# ============================================================================
# Figure 3: Gender Wage Gap Trends
# ============================================================================

cat("\nCreating gender wage gap trends figure...\n")

gap_trends <- df %>%
  group_by(income_year, ever_treated, female) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = female, values_from = mean_wage,
              names_prefix = "wage_") %>%
  mutate(
    wage_gap = wage_0 - wage_1,  # Male - Female
    wage_gap_pct = (wage_0 - wage_1) / wage_0 * 100,
    group = factor(ifelse(ever_treated == 1, "Treated States", "Control States"),
                   levels = c("Treated States", "Control States"))
  )

p_gap <- ggplot(gap_trends, aes(x = income_year, y = wage_gap_pct, color = group)) +
  geom_vline(xintercept = first_treat_year - 0.5, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("Treated States" = color_treated,
                                "Control States" = color_control)) +
  scale_x_continuous(breaks = 2014:2023) +
  labs(
    title = "Gender Wage Gap by Treatment Status",
    subtitle = "Male-female wage gap as percentage of male wages",
    x = "Income Year",
    y = "Gender Wage Gap (%)",
    color = NULL,
    caption = "Note: Gap = (Male wage - Female wage) / Male wage. Lower values indicate smaller gap."
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.85))

ggsave("figures/fig3_gap_trends.pdf", p_gap, width = 9, height = 6)
ggsave("figures/fig3_gap_trends.png", p_gap, width = 9, height = 6, dpi = 300)

cat("Saved figures/fig3_gap_trends.pdf\n")

# ============================================================================
# Figure 4: Cohort-Specific Wage Trends
# ============================================================================

cat("\nCreating cohort-specific trends figure...\n")

# Group by treatment cohort
cohort_trends <- df %>%
  mutate(
    cohort = case_when(
      first_treat == 0 ~ "Never Treated",
      first_treat == 2021 ~ "2021 Cohort",
      first_treat == 2022 ~ "2022 Cohort",
      first_treat == 2023 ~ "2023 Cohort",
      first_treat >= 2024 ~ "2024+ Cohort"
    )
  ) %>%
  filter(!is.na(cohort)) %>%
  group_by(income_year, cohort, first_treat) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(cohort = factor(cohort, levels = c("2021 Cohort", "2022 Cohort",
                                            "2023 Cohort", "2024+ Cohort",
                                            "Never Treated")))

# Get treatment timing for vertical lines
cohort_timing <- cohort_trends %>%
  filter(first_treat > 0) %>%
  distinct(cohort, first_treat)

p_cohorts <- ggplot(cohort_trends, aes(x = income_year, y = mean_wage, color = cohort)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  # Add vertical lines for each cohort's treatment
  geom_vline(data = cohort_timing,
             aes(xintercept = first_treat - 0.5, color = cohort),
             linetype = "dashed", alpha = 0.5) +
  scale_color_manual(values = c(
    "2021 Cohort" = "#08306b",
    "2022 Cohort" = "#2171b5",
    "2023 Cohort" = "#4292c6",
    "2024+ Cohort" = "#6baed6",
    "Never Treated" = "grey50"
  )) +
  scale_x_continuous(breaks = 2014:2023) +
  labs(
    title = "Wage Trends by Treatment Cohort",
    subtitle = "Dashed lines indicate treatment timing for each cohort",
    x = "Income Year",
    y = "Mean Hourly Wage ($)",
    color = "Cohort"
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave("figures/fig4_cohort_trends.pdf", p_cohorts, width = 10, height = 6)
ggsave("figures/fig4_cohort_trends.png", p_cohorts, width = 10, height = 6, dpi = 300)

cat("Saved figures/fig4_cohort_trends.pdf\n")

# ============================================================================
# Save Descriptive Statistics
# ============================================================================

desc_stats <- list(
  overall = overall_stats,
  by_treatment = by_treatment,
  by_gender = by_gender,
  treatment_table = treatment_table
)

saveRDS(desc_stats, "data/descriptive_stats.rds")

cat("\n==== Descriptives Complete ====\n")
cat("Created:\n")
cat("  - figures/fig1_policy_map.pdf\n")
cat("  - figures/fig2_wage_trends.pdf\n")
cat("  - figures/fig3_gap_trends.pdf\n")
cat("  - figures/fig4_cohort_trends.pdf\n")
cat("  - data/descriptive_stats.rds\n")
cat("\nNext step: Run 04_main_analysis.R\n")
