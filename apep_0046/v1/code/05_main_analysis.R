# ==============================================================================
# Paper 63: State EITC and Single Mothers' Self-Employment
# 05_main_analysis.R - Main DiD analysis
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Load data
# ==============================================================================

main_sample <- read_csv(file.path(data_path, "cps_main_sample.csv"), show_col_types = FALSE)
restricted_sample <- read_csv(file.path(data_path, "cps_restricted_sample.csv"), show_col_types = FALSE)
placebo_childless <- read_csv(file.path(data_path, "cps_placebo_childless.csv"), show_col_types = FALSE)

message(sprintf("Main sample: %s observations", format(nrow(main_sample), big.mark = ",")))
message(sprintf("Restricted sample: %s observations", format(nrow(restricted_sample), big.mark = ",")))

# ==============================================================================
# Basic descriptive statistics
# ==============================================================================

message("\n=== Self-Employment by State EITC Status ===")

main_sample %>%
  group_by(has_state_eitc) %>%
  summarise(
    n = n(),
    pct_self_employed = weighted.mean(self_employed, weight, na.rm = TRUE) * 100,
    pct_employed = weighted.mean(employed, weight, na.rm = TRUE) * 100,
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    mean_children = weighted.mean(n_children_u18, weight, na.rm = TRUE)
  ) %>%
  print()

# ==============================================================================
# Main DiD Specification: TWFE with State and Year Fixed Effects
# ==============================================================================

message("\n=== Main DiD Results (TWFE) ===")

# Model 1: Basic TWFE
model1 <- feols(
  self_employed ~ has_state_eitc | statefip + year,
  data = main_sample,
  weights = ~weight,
  cluster = ~statefip
)

# Model 2: With individual controls
model2 <- feols(
  self_employed ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 + has_young_children | statefip + year,
  data = main_sample,
  weights = ~weight,
  cluster = ~statefip
)

# Model 3: Restricted sample (low education)
model3 <- feols(
  self_employed ~ has_state_eitc + age + I(age^2) +
    n_children_u18 + has_young_children | statefip + year,
  data = restricted_sample,
  weights = ~weight,
  cluster = ~statefip
)

# Display results
etable(model1, model2, model3,
       title = "Effect of State EITC on Self-Employment Among Single Mothers",
       headers = c("Basic", "With Controls", "Low Educ Sample"),
       se.below = TRUE,
       keep = "has_state_eitc")

# ==============================================================================
# Placebo Test: Childless Women
# ==============================================================================

message("\n=== Placebo Test: Childless Single Women ===")

placebo_model <- feols(
  self_employed ~ has_state_eitc + age + I(age^2) + low_education | statefip + year,
  data = placebo_childless,
  weights = ~weight,
  cluster = ~statefip
)

etable(placebo_model,
       title = "Placebo: Effect on Childless Single Women",
       se.below = TRUE,
       keep = "has_state_eitc")

# ==============================================================================
# Self-Employment Types: Incorporated vs Unincorporated
# ==============================================================================

message("\n=== Self-Employment by Type ===")

# Incorporated (harder to fake)
model_inc <- feols(
  self_emp_incorporated ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 | statefip + year,
  data = main_sample,
  weights = ~weight,
  cluster = ~statefip
)

# Unincorporated (easier to fake)
model_uninc <- feols(
  self_emp_unincorporated ~ has_state_eitc + age + I(age^2) + low_education +
    n_children_u18 | statefip + year,
  data = main_sample,
  weights = ~weight,
  cluster = ~statefip
)

etable(model_inc, model_uninc,
       title = "Effect by Self-Employment Type",
       headers = c("Incorporated", "Unincorporated"),
       se.below = TRUE,
       keep = "has_state_eitc")

# ==============================================================================
# Event Study (Pre-Trend Test)
# ==============================================================================

message("\n=== Event Study ===")

# Create event time variable
main_sample <- main_sample %>%
  mutate(
    event_time = year - cohort,
    event_time = case_when(
      is.na(event_time) | is.infinite(event_time) ~ -999,  # Never treated
      event_time < -5 ~ -5,   # Bin early periods
      event_time > 5 ~ 5,     # Bin late periods
      TRUE ~ event_time
    )
  )

# Event study regression with Sun-Abraham style interaction-weighted estimator
# Using reference period -1 (year before treatment)
event_study <- feols(
  self_employed ~ i(event_time, ref = -1) + age + I(age^2) + low_education +
    n_children_u18 | statefip + year,
  data = main_sample %>% filter(event_time != -999),  # Exclude never-treated for event study
  weights = ~weight,
  cluster = ~statefip
)

# Extract coefficients for plotting
event_coefs <- as.data.frame(coeftable(event_study)) %>%
  rownames_to_column("term") %>%
  filter(str_detect(term, "event_time")) %>%
  mutate(
    event_time = as.numeric(str_extract(term, "-?\\d+")),
    estimate = Estimate,
    std_error = `Std. Error`,
    ci_lower = estimate - 1.96 * std_error,
    ci_upper = estimate + 1.96 * std_error
  )

# Add reference period
event_coefs <- bind_rows(
  event_coefs,
  tibble(event_time = -1, estimate = 0, std_error = 0, ci_lower = 0, ci_upper = 0)
) %>%
  arrange(event_time)

print(event_coefs %>% select(event_time, estimate, std_error, ci_lower, ci_upper))

# ==============================================================================
# Save results
# ==============================================================================

# Save main results
results_list <- list(
  model1 = summary(model1),
  model2 = summary(model2),
  model3 = summary(model3),
  placebo = summary(placebo_model),
  model_inc = summary(model_inc),
  model_uninc = summary(model_uninc),
  event_study = summary(event_study)
)

saveRDS(results_list, file.path(data_path, "main_results.rds"))
write_csv(event_coefs, file.path(data_path, "event_study_coefs.csv"))

message("\nResults saved to: ", data_path)
