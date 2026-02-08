# ============================================================================
# Paper 64: The Pence Effect
# 02_main_analysis.R - Triple-Difference Analysis
# ============================================================================

source("code/00_packages.R")

library(fixest)
library(tidyverse)

cat("Running main analysis...\n")

# ============================================================================
# Load Data
# ============================================================================

emp_data <- readRDS("data/employment_data.rds")
industry_harassment <- readRDS("data/industry_harassment.rds")

# Merge harassment rates
emp_data <- emp_data %>%
  left_join(
    industry_harassment %>% select(naics, harassment_rate, log_harassment_rate),
    by = "naics"
  )

cat(sprintf("Analysis dataset: %d observations\n", nrow(emp_data)))

# ============================================================================
# Create Analysis Variables
# ============================================================================

# Collapse to quarterly for stability
emp_quarterly <- emp_data %>%
  mutate(quarter = ceiling(month / 3)) %>%
  group_by(state_fips, naics, year, quarter, female, high_harassment,
           harassment_rate, log_harassment_rate) %>%
  summarise(
    employment = mean(employment, na.rm = TRUE),
    hires = sum(hires, na.rm = TRUE),
    separations = sum(separations, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    # Time indicators
    yearqtr = year + (quarter - 1) / 4,
    post_metoo = as.integer(yearqtr >= 2017.75),

    # Event time (quarters relative to Q4 2017)
    event_time = round((yearqtr - 2017.75) * 4),

    # Interaction terms
    female_x_high = female * high_harassment,
    female_x_post = female * post_metoo,
    high_x_post = high_harassment * post_metoo,
    DDD_term = female * high_harassment * post_metoo,

    # State-industry cluster
    state_industry = paste(state_fips, naics, sep = "_"),

    # Log outcomes
    log_employment = log(employment + 1),
    log_hires = log(hires + 1)
  )

cat(sprintf("Quarterly dataset: %d observations\n", nrow(emp_quarterly)))

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("\n=== Table 1: Summary Statistics ===\n")

summary_stats <- emp_quarterly %>%
  group_by(female, high_harassment, post_metoo) %>%
  summarise(
    N = n(),
    mean_emp = mean(employment),
    sd_emp = sd(employment),
    mean_hires = mean(hires),
    sd_hires = sd(hires),
    .groups = "drop"
  ) %>%
  mutate(
    Group = case_when(
      female == 0 & high_harassment == 0 ~ "Male, Low Harassment",
      female == 0 & high_harassment == 1 ~ "Male, High Harassment",
      female == 1 & high_harassment == 0 ~ "Female, Low Harassment",
      female == 1 & high_harassment == 1 ~ "Female, High Harassment"
    ),
    Period = ifelse(post_metoo == 0, "Pre-MeToo (2014-2017)", "Post-MeToo (2018-2023)")
  )

print(summary_stats %>% select(Group, Period, N, mean_emp, sd_emp, mean_hires))

# Save for table
saveRDS(summary_stats, "data/summary_stats.rds")

# ============================================================================
# Table 2: Triple-Difference Estimates
# ============================================================================

cat("\n=== Table 2: Triple-Difference Regressions ===\n")

# Model 1: Basic DDD
m1 <- feols(
  log_employment ~ female_x_high + female_x_post + high_x_post + DDD_term |
    state_fips + naics + yearqtr,
  data = emp_quarterly,
  cluster = ~state_industry
)

# Model 2: Add state×time FE
m2 <- feols(
  log_employment ~ female_x_high + female_x_post + high_x_post + DDD_term |
    state_fips^yearqtr + naics,
  data = emp_quarterly,
  cluster = ~state_industry
)

# Model 3: Add industry×time FE
m3 <- feols(
  log_employment ~ female_x_high + female_x_post + high_x_post + DDD_term |
    state_fips + naics^yearqtr,
  data = emp_quarterly,
  cluster = ~state_industry
)

# Model 4: Most saturated (state×time + industry×gender)
m4 <- feols(
  log_employment ~ DDD_term |
    state_fips^yearqtr + naics^female + female^yearqtr + naics^yearqtr,
  data = emp_quarterly,
  cluster = ~state_industry
)

# Model 5: Continuous harassment rate
m5 <- feols(
  log_employment ~ female * log_harassment_rate * post_metoo |
    state_fips^yearqtr + naics,
  data = emp_quarterly,
  cluster = ~state_industry
)

# Print results
cat("\nModel 1: Basic DDD\n")
print(summary(m1))

cat("\nModel 4: Saturated FE\n")
print(summary(m4))

# Create table
etable(m1, m2, m3, m4, m5,
       dict = c(
         DDD_term = "Female $\\times$ High Harass. $\\times$ Post",
         female_x_high = "Female $\\times$ High Harassment",
         female_x_post = "Female $\\times$ Post-MeToo",
         high_x_post = "High Harassment $\\times$ Post-MeToo",
         "female:log_harassment_rate:post_metoo" = "Female $\\times$ Log(Harass. Rate) $\\times$ Post"
       ),
       fitstat = ~ r2 + n,
       se.below = TRUE,
       file = "figures/table2_ddd_results.tex")

cat("\nTable saved to figures/table2_ddd_results.tex\n")

# Save models
saveRDS(list(m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5), "data/ddd_models.rds")

# ============================================================================
# Figure 3: Event Study
# ============================================================================

cat("\n=== Creating Event Study Plot ===\n")

# Run event study regression
# Omit event_time = -1 as reference
emp_quarterly_es <- emp_quarterly %>%
  filter(event_time >= -12, event_time <= 24) %>%
  mutate(
    event_time_factor = factor(event_time),
    event_time_factor = relevel(event_time_factor, ref = "-1")
  )

es_model <- feols(
  log_employment ~ i(event_time_factor, female_x_high, ref = "-1") |
    state_fips^yearqtr + naics^female,
  data = emp_quarterly_es,
  cluster = ~state_industry
)

# Extract coefficients
es_coefs <- coeftable(es_model) %>%
  as.data.frame() %>%
  rownames_to_column("term") %>%
  filter(str_detect(term, "event_time_factor")) %>%
  mutate(
    event_time = as.numeric(str_extract(term, "-?\\d+"))
  ) %>%
  arrange(event_time)

# Add reference period (0 by construction)
es_coefs <- bind_rows(
  es_coefs,
  tibble(term = "ref", Estimate = 0, `Std. Error` = 0, event_time = -1)
) %>%
  arrange(event_time) %>%
  rename(coef = Estimate, se = `Std. Error`)

# Create plot
es_plot <- ggplot(es_coefs, aes(x = event_time, y = coef)) +
  # Confidence interval ribbon
  geom_ribbon(
    aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
    fill = apep_colors[1], alpha = 0.2
  ) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.8) +
  # Annotation
  annotate("text", x = 5, y = max(es_coefs$coef, na.rm = TRUE) * 0.9,
           label = "MeToo\n(Oct 2017)", hjust = 0, size = 3.5, color = "grey40") +
  # Labels
  labs(
    title = "Event Study: Female Employment in High-Harassment Industries",
    subtitle = "Triple-difference coefficients relative to Q3 2017",
    x = "Quarters Relative to #MeToo (Q4 2017)",
    y = "Log Employment (DDD Coefficient)",
    caption = "Note: Shaded region shows 95% CI. Reference period is t = -1."
  ) +
  scale_x_continuous(breaks = seq(-12, 24, 4)) +
  theme_apep()

ggsave("figures/figure3_event_study.pdf", es_plot, width = 10, height = 6)
ggsave("figures/figure3_event_study.png", es_plot, width = 10, height = 6, dpi = 300)

cat("Event study saved to figures/figure3_event_study.pdf\n")

# ============================================================================
# Table 3: Heterogeneity by Industry
# ============================================================================

cat("\n=== Table 3: Heterogeneity by Specific Industry ===\n")

# Industry-specific effects
industry_effects <- emp_quarterly %>%
  group_by(naics) %>%
  nest() %>%
  mutate(
    model = map(data, ~feols(
      log_employment ~ female * post_metoo | state_fips + yearqtr,
      data = ., cluster = ~state_fips
    )),
    coef = map_dbl(model, ~coef(.)[["female:post_metoo"]]),
    se = map_dbl(model, ~se(.)[["female:post_metoo"]])
  ) %>%
  select(naics, coef, se) %>%
  left_join(industry_harassment %>% select(naics, industry_name, harassment_rate), by = "naics") %>%
  arrange(desc(harassment_rate))

print(industry_effects)
saveRDS(industry_effects, "data/industry_effects.rds")

# ============================================================================
# Save Key Results
# ============================================================================

# Extract main DDD coefficient for reporting
main_coef <- coef(m4)[["DDD_term"]]
main_se <- se(m4)[["DDD_term"]]

results_summary <- list(
  main_coef = main_coef,
  main_se = main_se,
  main_tstat = main_coef / main_se,
  main_pvalue = 2 * pt(-abs(main_coef / main_se), df = m4$nobs - 1),
  n_obs = m4$nobs,
  r2 = fitstat(m4, "r2")[[1]]
)

saveRDS(results_summary, "data/results_summary.rds")

cat("\n=== Main Result ===\n")
cat(sprintf("DDD coefficient: %.4f (SE: %.4f)\n", main_coef, main_se))
cat(sprintf("t-statistic: %.2f\n", main_coef / main_se))
cat(sprintf("N: %d observations\n", m4$nobs))

cat("\nMain analysis complete!\n")
