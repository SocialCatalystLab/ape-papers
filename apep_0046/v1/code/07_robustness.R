# ==============================================================================
# Paper 63: State EITC and Single Mothers' Self-Employment
# 07_robustness.R - Robustness checks and sensitivity analysis
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Load data
# ==============================================================================

main_sample <- read_csv(file.path(data_path, "cps_main_sample.csv"), show_col_types = FALSE)
state_eitc <- read_csv(file.path(data_path, "state_eitc_panel.csv"), show_col_types = FALSE)

message(sprintf("Main sample: %s observations", format(nrow(main_sample), big.mark = ",")))

# ==============================================================================
# 1. Sun-Abraham Estimator via fixest::sunab()
# ==============================================================================

message("\n=== Sun-Abraham Estimator ===")

# Need cohort variable for sunab
main_sample <- main_sample %>%
  mutate(
    # cohort = first year of treatment (Inf for never-treated)
    cohort_sa = cohort,
    # For sunab, never-treated must be coded as 0 or specific value
    cohort_sa = ifelse(is.infinite(cohort_sa) | is.na(cohort_sa), 10000, cohort_sa)
  )

# Sun-Abraham estimator
sa_model <- feols(
  self_employed ~ sunab(cohort_sa, year, ref.p = -1, ref.c = 10000) +
    age + I(age^2) + low_education + n_children_u18 | statefip + year,
  data = main_sample,
  weights = ~weight,
  cluster = ~statefip
)

# Extract event study coefficients
sa_coefs <- as.data.frame(coeftable(sa_model)) %>%
  rownames_to_column("term") %>%
  filter(str_detect(term, "year::")) %>%
  mutate(
    event_time = as.numeric(str_extract(term, "-?\\d+")),
    estimate = Estimate,
    std_error = `Std. Error`,
    ci_lower = estimate - 1.96 * std_error,
    ci_upper = estimate + 1.96 * std_error,
    estimator = "Sun-Abraham"
  )

# Add reference period
sa_coefs <- bind_rows(
  sa_coefs,
  tibble(event_time = -1, estimate = 0, std_error = 0, ci_lower = 0, ci_upper = 0, estimator = "Sun-Abraham")
) %>%
  arrange(event_time) %>%
  filter(event_time >= -5, event_time <= 5)

print(sa_coefs %>% select(event_time, estimate, std_error))

# Aggregate ATT from Sun-Abraham
# Get post-treatment coefficients and average them
post_coefs <- sa_coefs %>% filter(event_time >= 0)
sa_att <- mean(post_coefs$estimate)
sa_att_se <- sqrt(mean(post_coefs$std_error^2))  # Simplified SE
message(sprintf("\nSun-Abraham Average Post-Treatment Effect: %.4f (approx SE: %.4f)",
                sa_att, sa_att_se))

# ==============================================================================
# 2. Compare TWFE vs Sun-Abraham Event Studies
# ==============================================================================

message("\n=== Comparing TWFE vs Sun-Abraham ===")

# Load TWFE coefficients
twfe_coefs <- read_csv(file.path(data_path, "event_study_coefs.csv"), show_col_types = FALSE) %>%
  select(event_time, estimate, std_error = std_error, ci_lower, ci_upper) %>%
  mutate(estimator = "TWFE")

# Combine for comparison plot
combined_coefs <- bind_rows(
  twfe_coefs %>% filter(event_time >= -5, event_time <= 5),
  sa_coefs %>% select(event_time, estimate, std_error, ci_lower, ci_upper, estimator)
)

# Save combined coefficients
write_csv(combined_coefs, file.path(data_path, "event_study_comparison.csv"))

# Create comparison plot
fig_comparison <- ggplot(combined_coefs, aes(x = event_time, y = estimate, color = estimator, shape = estimator)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray70") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, position = position_dodge(0.3)) +
  geom_point(size = 3, position = position_dodge(0.3)) +
  scale_color_manual(values = c("TWFE" = apep_colors[1], "Sun-Abraham" = apep_colors[2]), name = "") +
  scale_shape_manual(values = c("TWFE" = 16, "Sun-Abraham" = 17), name = "") +
  scale_x_continuous(breaks = seq(-5, 5, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Event Study: TWFE vs. Sun-Abraham Estimator",
    subtitle = "Effect of State EITC on Self-Employment, Single Mothers 18-55",
    x = "Years Relative to State EITC Adoption",
    y = "Effect on Self-Employment Rate",
    caption = "Notes: 95% confidence intervals shown. Reference period is t=-1.\nSun-Abraham allows for heterogeneous treatment effects across cohorts."
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.15))

ggsave(file.path(fig_path, "fig5_twfe_vs_sunab.pdf"), fig_comparison, width = 9, height = 6)
ggsave(file.path(fig_path, "fig5_twfe_vs_sunab.png"), fig_comparison, width = 9, height = 6, dpi = 300)

message("Figure 5 saved: TWFE vs Sun-Abraham comparison")

# ==============================================================================
# 3. Pre-Trends Test
# ==============================================================================

message("\n=== Formal Pre-Trends Test ===")

# F-test on pre-treatment coefficients
pre_coefs <- twfe_coefs %>% filter(event_time < -1, event_time >= -5)

# Calculate F-statistic (joint test that all pre-treatment coefs = 0)
# Using Wald test
pre_estimates <- pre_coefs$estimate
pre_var <- diag(pre_coefs$std_error^2)  # Simplified - assumes independence

# Wald statistic
wald_stat <- sum((pre_estimates / pre_coefs$std_error)^2)
p_value <- 1 - pchisq(wald_stat, df = length(pre_estimates))

message(sprintf("Pre-trends Wald test: chi-sq = %.2f, df = %d, p = %.4f",
                wald_stat, length(pre_estimates), p_value))

# ==============================================================================
# 4. Treatment Timing Decomposition
# ==============================================================================

message("\n=== Treatment Timing Decomposition ===")

# Count observations by cohort
cohort_table <- main_sample %>%
  mutate(cohort_group = case_when(
    is.infinite(cohort) | is.na(cohort) ~ "Never Treated",
    cohort < 2014 ~ "Before 2014",
    cohort >= 2014 & cohort <= 2017 ~ "2014-2017",
    cohort >= 2018 & cohort <= 2020 ~ "2018-2020",
    cohort >= 2021 ~ "2021+"
  )) %>%
  group_by(cohort_group) %>%
  summarise(
    n_obs = n(),
    n_states = n_distinct(statefip),
    mean_self_emp = mean(self_employed, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  arrange(match(cohort_group, c("Never Treated", "Before 2014", "2014-2017", "2018-2020", "2021+")))

print(cohort_table)

# Save timing table
write_csv(cohort_table, file.path(data_path, "cohort_timing.csv"))

# ==============================================================================
# 5. Employment Composition Test
# ==============================================================================

message("\n=== Employment Composition Test ===")

# Create wage employment indicator (employed but not self-employed)
main_sample <- main_sample %>%
  mutate(wage_employed = ifelse(employed == 1 & self_employed == 0, 1, 0))

# Model: Effect on wage employment
wage_model <- feols(
  wage_employed ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 + has_young_children | statefip + year,
  data = main_sample,
  weights = ~weight,
  cluster = ~statefip
)

# Model: Effect on any employment
emp_model <- feols(
  employed ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 + has_young_children | statefip + year,
  data = main_sample,
  weights = ~weight,
  cluster = ~statefip
)

message("Effect on Wage Employment:")
print(etable(wage_model, keep = "has_state_eitc", se.below = TRUE))

message("\nEffect on Any Employment:")
print(etable(emp_model, keep = "has_state_eitc", se.below = TRUE))

# ==============================================================================
# 6. Additional Robustness: Drop Early Adopters, Drop 2020
# ==============================================================================

message("\n=== Additional Robustness Checks ===")

# Drop states with EITC before 2014 (no pre-period in our data)
robust_sample <- main_sample %>%
  filter(cohort >= 2016 | is.infinite(cohort) | is.na(cohort))

robust_model1 <- feols(
  self_employed ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 | statefip + year,
  data = robust_sample,
  weights = ~weight,
  cluster = ~statefip
)

message("Robustness: Drop states with EITC before 2016")
print(etable(robust_model1, keep = "has_state_eitc", se.below = TRUE))

# Drop 2020 (COVID)
robust_sample2 <- main_sample %>%
  filter(year != 2020)

robust_model2 <- feols(
  self_employed ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 | statefip + year,
  data = robust_sample2,
  weights = ~weight,
  cluster = ~statefip
)

message("\nRobustness: Drop 2020 (COVID year)")
print(etable(robust_model2, keep = "has_state_eitc", se.below = TRUE))

# Restrict to prime-age (25-54)
robust_sample3 <- main_sample %>%
  filter(age >= 25, age <= 54)

robust_model3 <- feols(
  self_employed ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 | statefip + year,
  data = robust_sample3,
  weights = ~weight,
  cluster = ~statefip
)

message("\nRobustness: Restrict to ages 25-54")
print(etable(robust_model3, keep = "has_state_eitc", se.below = TRUE))

# ==============================================================================
# 7. Save all robustness results
# ==============================================================================

robustness_results <- tibble(
  specification = c("Main (TWFE)", "Sun-Abraham ATT", "Drop pre-2016 adopters",
                    "Drop 2020", "Ages 25-54", "Wage employment", "Any employment"),
  estimate = c(
    coef(feols(self_employed ~ has_state_eitc | statefip + year, data = main_sample,
               weights = ~weight, cluster = ~statefip))["has_state_eitc"],
    sa_att,
    coef(robust_model1)["has_state_eitc"],
    coef(robust_model2)["has_state_eitc"],
    coef(robust_model3)["has_state_eitc"],
    coef(wage_model)["has_state_eitc"],
    coef(emp_model)["has_state_eitc"]
  ),
  std_error = c(
    se(feols(self_employed ~ has_state_eitc | statefip + year, data = main_sample,
             weights = ~weight, cluster = ~statefip))["has_state_eitc"],
    sa_att_se,
    se(robust_model1)["has_state_eitc"],
    se(robust_model2)["has_state_eitc"],
    se(robust_model3)["has_state_eitc"],
    se(wage_model)["has_state_eitc"],
    se(emp_model)["has_state_eitc"]
  )
)

robustness_results <- robustness_results %>%
  mutate(
    ci_lower = estimate - 1.96 * std_error,
    ci_upper = estimate + 1.96 * std_error,
    significant = ifelse(ci_lower > 0 | ci_upper < 0, "Yes", "No")
  )

print(robustness_results)
write_csv(robustness_results, file.path(data_path, "robustness_results.csv"))

message("\nAll robustness results saved to: ", data_path)
