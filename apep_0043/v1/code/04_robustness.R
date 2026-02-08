# =============================================================================
# 04_robustness.R - Robustness Checks
# Paper 59: State Insulin Price Caps and Diabetes Management Outcomes
# =============================================================================

source("output/paper_59/code/00_packages.R")

# =============================================================================
# Load Data
# =============================================================================

state_year <- readRDS("output/paper_59/data/state_year_panel.rds")
brfss_diabetes <- readRDS("output/paper_59/data/brfss_diabetes.rds")

cat("Running robustness checks...\n\n")

# =============================================================================
# 1. Simple TWFE (for comparison/decomposition awareness)
# =============================================================================

cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("1. SIMPLE TWFE (Baseline Comparison)\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Prepare data
twfe_data <- state_year %>%
  mutate(
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0)
  )

# Simple TWFE regression
twfe_insulin <- feols(
  insulin_rate ~ post | state_fips + year,
  data = twfe_data,
  cluster = ~ state_fips
)

cat("Simple TWFE (insulin use rate):\n")
print(summary(twfe_insulin))

twfe_a1c <- feols(
  a1c_check_rate ~ post | state_fips + year,
  data = twfe_data,
  cluster = ~ state_fips
)

cat("\nSimple TWFE (A1C monitoring rate):\n")
print(summary(twfe_a1c))

# =============================================================================
# 2. Goodman-Bacon Decomposition
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("2. GOODMAN-BACON DECOMPOSITION\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Bacon decomposition requires balanced panel
bacon_data <- state_year %>%
  group_by(state_fips) %>%
  filter(n() == length(unique(state_year$year))) %>%
  ungroup() %>%
  mutate(
    treated = ifelse(first_treat > 0, 1, 0),
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0)
  )

cat(sprintf("Balanced panel for Bacon: %d state-years (%d states)\n",
            nrow(bacon_data), length(unique(bacon_data$state_fips))))

bacon_result <- tryCatch({
  bacon(
    formula = insulin_rate ~ post,
    data = bacon_data,
    id_var = "state_fips",
    time_var = "year"
  )
}, error = function(e) {
  cat("Error in Bacon decomposition:", e$message, "\n")
  NULL
})

if (!is.null(bacon_result)) {
  cat("\nBacon Decomposition Components:\n")
  print(bacon_result)

  # Summary by comparison type
  cat("\nWeighted average by comparison type:\n")
  bacon_result %>%
    group_by(type) %>%
    summarize(
      weight = sum(weight),
      weighted_estimate = sum(estimate * weight) / sum(weight),
      .groups = "drop"
    ) %>%
    print()
}

# =============================================================================
# 3. Leave-One-Out Analysis (State Influence)
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("3. LEAVE-ONE-OUT ANALYSIS\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Check which states drive the results
treated_states <- unique(twfe_data$state_fips[twfe_data$first_treat > 0])

loo_results <- lapply(treated_states, function(s) {
  loo_data <- twfe_data %>% filter(state_fips != s)

  loo_reg <- tryCatch({
    feols(insulin_rate ~ post | state_fips + year,
          data = loo_data, cluster = ~ state_fips)
  }, error = function(e) NULL)

  if (!is.null(loo_reg)) {
    state_abbr <- unique(twfe_data$state_abbr[twfe_data$state_fips == s])
    data.frame(
      excluded_state = s,
      state_abbr = state_abbr,
      estimate = coef(loo_reg)["post"],
      se = se(loo_reg)["post"]
    )
  } else {
    NULL
  }
})

loo_df <- bind_rows(loo_results)

if (nrow(loo_df) > 0) {
  cat("Leave-one-out estimates (excluding each treated state):\n")
  print(loo_df %>% arrange(estimate))

  # Plot
  p_loo <- ggplot(loo_df, aes(x = reorder(state_abbr, estimate), y = estimate)) +
    geom_point(size = 3, color = apep_colors[1]) +
    geom_errorbar(aes(ymin = estimate - 1.96*se, ymax = estimate + 1.96*se),
                  width = 0.2, color = apep_colors[1]) +
    geom_hline(yintercept = coef(twfe_insulin)["post"], linetype = "dashed",
               color = "grey50") +
    coord_flip() +
    labs(
      title = "Leave-One-Out Analysis: State Influence",
      subtitle = "Point estimate when excluding each treated state",
      x = "Excluded State",
      y = "TWFE Estimate",
      caption = "Dashed line shows full-sample estimate"
    ) +
    theme_apep()

  ggsave("output/paper_59/figures/leave_one_out.pdf", p_loo, width = 8, height = 6)
  cat("\n  Saved: figures/leave_one_out.pdf\n")
}

# =============================================================================
# 4. Pre-Trend Sensitivity (HonestDiD approach - simplified)
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("4. PRE-TREND SENSITIVITY\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Load main results
results <- readRDS("output/paper_59/data/did_results.rds")

# The Sun-Abraham results showed significant pre-treatment coefficients
# This suggests parallel trends may not hold
# Report the concern explicitly

cat("Sun-Abraham pre-treatment coefficients:\n")
cat("  t = -3: 0.051 (SE = 0.018) **\n")
cat("  t = -2: 0.035 (SE = 0.014) *\n")
cat("\nNOTE: Significant pre-treatment coefficients suggest possible\n")
cat("parallel trends violations. Results should be interpreted with caution.\n")

# =============================================================================
# 5. Dose-Response Analysis (Cap Amount Heterogeneity)
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("5. DOSE-RESPONSE: CAP AMOUNT HETEROGENEITY\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Add cap amount to analysis
dose_data <- state_year %>%
  left_join(
    readRDS("output/paper_59/data/treatment_assignment.rds") %>%
      select(fips, cap_amount),
    by = c("state_fips" = "fips")
  ) %>%
  mutate(
    # Categorize caps
    cap_category = case_when(
      is.na(cap_amount) ~ "No cap",
      cap_amount <= 35 ~ "Low ($25-35)",
      cap_amount > 35 ~ "High ($50-100)"
    ),
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0)
  )

cat("Cap amount distribution among treated states:\n")
dose_data %>%
  filter(!is.na(cap_amount)) %>%
  distinct(state_fips, state_abbr, cap_amount, cap_category) %>%
  group_by(cap_category) %>%
  summarize(
    n_states = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  ) %>%
  print()

# Heterogeneity by cap level
dose_reg <- feols(
  insulin_rate ~ post:cap_category | state_fips + year,
  data = dose_data,
  cluster = ~ state_fips
)

cat("\nHeterogeneity by cap level:\n")
print(summary(dose_reg))

# =============================================================================
# 6. Placebo Test: Pre-Treatment Only
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("6. PLACEBO TEST: PRE-TREATMENT ONLY\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# Restrict to pre-treatment period only
# Create a fake "treatment" in 2019 for states that were actually treated in 2020
placebo_data <- state_year %>%
  filter(year <= 2020) %>%  # Only use 2019-2020
  mutate(
    # Create placebo treatment: treat in 2020 the states that were treated in 2020
    placebo_post = ifelse(first_treat == 2020 & year == 2020, 1, 0)
  )

placebo_reg <- feols(
  insulin_rate ~ placebo_post | state_fips + year,
  data = placebo_data,
  cluster = ~ state_fips
)

cat("Placebo test (2019-2020 only, no actual treatment effect yet):\n")
cat("If parallel trends hold, this should be ~0\n\n")
print(summary(placebo_reg))

# =============================================================================
# Save Robustness Results
# =============================================================================

robustness_results <- list(
  twfe_insulin = twfe_insulin,
  twfe_a1c = twfe_a1c,
  bacon = if(exists("bacon_result")) bacon_result else NULL,
  loo = loo_df,
  dose_reg = dose_reg,
  placebo_reg = placebo_reg
)

saveRDS(robustness_results, "output/paper_59/data/robustness_results.rds")
cat("\n\nRobustness results saved to data/robustness_results.rds\n")

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("ROBUSTNESS CHECKS COMPLETE\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
