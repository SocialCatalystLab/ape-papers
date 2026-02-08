# ============================================================================
# Paper 64: The Pence Effect
# 03_figures.R - Create All Publication-Ready Figures
# ============================================================================

source("code/00_packages.R")

library(tidyverse)
library(patchwork)

cat("Creating publication-ready figures...\n")

# ============================================================================
# Load Data
# ============================================================================

emp_data <- readRDS("data/employment_data.rds")
industry_harassment <- readRDS("data/industry_harassment.rds")
industry_effects <- readRDS("data/industry_effects.rds")
summary_stats <- readRDS("data/summary_stats.rds")

# ============================================================================
# Figure 1: Harassment Rates by Industry
# ============================================================================

cat("Creating Figure 1: Industry harassment rates...\n")

fig1 <- industry_harassment %>%
  mutate(
    industry_name = fct_reorder(industry_name, harassment_rate),
    fill_color = ifelse(high_harassment, "High", "Low")
  ) %>%
  ggplot(aes(x = harassment_rate, y = industry_name, fill = fill_color)) +
  geom_col(width = 0.7) +
  geom_vline(
    xintercept = median(industry_harassment$harassment_rate),
    linetype = "dashed", color = "grey40"
  ) +
  scale_fill_manual(
    values = c("High" = apep_colors[2], "Low" = apep_colors[1]),
    name = "Harassment Classification"
  ) +
  labs(
    title = "Sexual Harassment Charge Rates by Industry",
    subtitle = "EEOC charges per 10,000 employees, 2010-2016 average",
    x = "Harassment Charge Rate (per 10,000 employees)",
    y = NULL,
    caption = "Source: EEOC Enforcement Statistics. Dashed line shows median rate."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("figures/figure1_harassment_rates.pdf", fig1, width = 10, height = 8)
ggsave("figures/figure1_harassment_rates.png", fig1, width = 10, height = 8, dpi = 300)

# ============================================================================
# Figure 2: Employment Trends by Industry Type and Gender
# ============================================================================

cat("Creating Figure 2: Employment trends...\n")

# Aggregate to quarterly trends
trends_data <- emp_data %>%
  mutate(
    quarter = ceiling(month / 3),
    yearqtr = year + (quarter - 1) / 4,
    group = case_when(
      female == 0 & high_harassment == 0 ~ "Male, Low Harassment",
      female == 0 & high_harassment == 1 ~ "Male, High Harassment",
      female == 1 & high_harassment == 0 ~ "Female, Low Harassment",
      female == 1 & high_harassment == 1 ~ "Female, High Harassment"
    )
  ) %>%
  group_by(yearqtr, group) %>%
  summarise(
    employment = sum(employment),
    .groups = "drop"
  ) %>%
  # Normalize to Q1 2014 = 100
  group_by(group) %>%
  mutate(
    employment_index = 100 * employment / employment[yearqtr == min(yearqtr)]
  ) %>%
  ungroup()

fig2 <- ggplot(trends_data, aes(x = yearqtr, y = employment_index, color = group)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 2017.75, linetype = "dotted", color = "grey40", linewidth = 0.8) +
  annotate("text", x = 2018, y = max(trends_data$employment_index) * 0.98,
           label = "#MeToo\n(Oct 2017)", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(
    values = c(
      "Female, High Harassment" = apep_colors[2],
      "Female, Low Harassment" = apep_colors[1],
      "Male, High Harassment" = apep_colors[4],
      "Male, Low Harassment" = apep_colors[6]
    ),
    name = NULL
  ) +
  labs(
    title = "Employment Trends by Industry Type and Gender",
    subtitle = "Indexed to Q1 2014 = 100",
    x = "Year",
    y = "Employment Index (Q1 2014 = 100)",
    caption = "Note: High-harassment industries include accommodation, retail, healthcare, arts, and administrative services."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("figures/figure2_employment_trends.pdf", fig2, width = 10, height = 6)
ggsave("figures/figure2_employment_trends.png", fig2, width = 10, height = 6, dpi = 300)

# ============================================================================
# Figure 4: Industry-Specific Effects
# ============================================================================

cat("Creating Figure 4: Industry heterogeneity...\n")

fig4 <- industry_effects %>%
  mutate(
    industry_name = fct_reorder(industry_name, coef),
    significant = abs(coef / se) > 1.96,
    fill_color = case_when(
      coef < 0 & significant ~ "Negative (p<0.05)",
      coef > 0 & significant ~ "Positive (p<0.05)",
      TRUE ~ "Not Significant"
    )
  ) %>%
  ggplot(aes(x = coef, y = industry_name, fill = fill_color)) +
  geom_col(width = 0.7) +
  geom_errorbar(aes(xmin = coef - 1.96*se, xmax = coef + 1.96*se),
                width = 0.3, color = "grey30") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_fill_manual(
    values = c(
      "Negative (p<0.05)" = apep_colors[2],
      "Positive (p<0.05)" = apep_colors[3],
      "Not Significant" = "grey70"
    ),
    name = "Effect"
  ) +
  labs(
    title = "Female Employment Effect by Industry",
    subtitle = "Difference-in-differences coefficient (Female × Post-MeToo)",
    x = "Log Employment Effect",
    y = NULL,
    caption = "Note: Error bars show 95% confidence intervals. Clustered standard errors at state level."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("figures/figure4_industry_effects.pdf", fig4, width = 10, height = 8)
ggsave("figures/figure4_industry_effects.png", fig4, width = 10, height = 8, dpi = 300)

# ============================================================================
# Figure 5: Pre-Trends Validation
# ============================================================================

cat("Creating Figure 5: Pre-trends validation...\n")

# Calculate quarterly means for pre-trends
pretrends_data <- emp_data %>%
  filter(year >= 2014, year <= 2017, month <= 9 | year < 2017) %>%  # Pre-MeToo only
  mutate(
    quarter = ceiling(month / 3),
    yearqtr = year + (quarter - 1) / 4,
    group = case_when(
      female == 1 & high_harassment == 1 ~ "Treated (F, High Harass)",
      TRUE ~ "Control (All Others)"
    )
  ) %>%
  group_by(yearqtr, group) %>%
  summarise(
    mean_emp = mean(employment),
    .groups = "drop"
  ) %>%
  group_by(group) %>%
  mutate(
    emp_normalized = mean_emp / mean_emp[yearqtr == min(yearqtr)] * 100
  ) %>%
  ungroup()

fig5 <- ggplot(pretrends_data, aes(x = yearqtr, y = emp_normalized, color = group)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(
    values = c(
      "Treated (F, High Harass)" = apep_colors[2],
      "Control (All Others)" = apep_colors[1]
    ),
    name = NULL
  ) +
  labs(
    title = "Pre-Treatment Parallel Trends Test",
    subtitle = "Employment trends before #MeToo (Q1 2014 - Q3 2017)",
    x = "Year-Quarter",
    y = "Normalized Employment (Q1 2014 = 100)",
    caption = "Note: Parallel pre-trends support the identifying assumption."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("figures/figure5_pretrends.pdf", fig5, width = 9, height = 6)
ggsave("figures/figure5_pretrends.png", fig5, width = 9, height = 6, dpi = 300)

# ============================================================================
# Figure 6: Dose-Response by Harassment Rate
# ============================================================================

cat("Creating Figure 6: Dose-response...\n")

fig6 <- industry_effects %>%
  ggplot(aes(x = harassment_rate, y = coef)) +
  geom_point(aes(size = abs(coef/se)), alpha = 0.7, color = apep_colors[1]) +
  geom_smooth(method = "lm", se = TRUE, color = apep_colors[2], fill = apep_colors[2], alpha = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  # Label key industries
  geom_text(
    data = . %>% filter(naics %in% c("72", "62", "52")),
    aes(label = industry_name),
    hjust = 0, nudge_x = 0.1, size = 3
  ) +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  labs(
    title = "Dose-Response: Female Employment Effect by Harassment Exposure",
    subtitle = "Each point is an industry; size reflects statistical precision",
    x = "Harassment Charge Rate (per 10,000 employees)",
    y = "Female × Post-MeToo Effect on Log Employment",
    caption = "Note: Line shows linear fit. Higher harassment exposure associated with larger employment decline."
  ) +
  theme_apep()

ggsave("figures/figure6_dose_response.pdf", fig6, width = 10, height = 7)
ggsave("figures/figure6_dose_response.png", fig6, width = 10, height = 7, dpi = 300)

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Figures Created ===\n")
cat("1. figure1_harassment_rates.pdf - Industry harassment classification\n")
cat("2. figure2_employment_trends.pdf - Parallel trends\n")
cat("3. figure3_event_study.pdf - Event study (from main analysis)\n")
cat("4. figure4_industry_effects.pdf - Heterogeneity by industry\n")
cat("5. figure5_pretrends.pdf - Pre-trends validation\n")
cat("6. figure6_dose_response.pdf - Dose-response relationship\n")

cat("\nAll figures saved to figures/\n")
