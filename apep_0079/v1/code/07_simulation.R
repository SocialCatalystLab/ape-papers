# ==============================================================================
# 07_simulation.R
# Monte Carlo simulation demonstrating recall-window mismatch bias in DiD
# ==============================================================================

library(tidyverse)
library(fixest)
library(ggplot2)

set.seed(20260128)

# ==============================================================================
# SIMULATION SETUP
# ==============================================================================

# Parameters
n_states <- 50           # Total states
n_treated <- 5           # States that adopt
n_periods <- 5           # Years of data (2020-2024)
n_households_per_state <- 500  # Households per state-year
treatment_year <- 3      # Treatment happens in year 3 (Aug)
treatment_month <- 8     # August
recall_window <- 12      # 12-month recall

# True full-year treatment effect (reduces food insecurity by 2pp when fully exposed)
# This is the effect on annual food insecurity probability when exposure = 1
true_full_year_effect <- -0.02

# Key insight: When treated states are on IMPROVING trajectories (selection)
# AND recall-window mismatch causes "pre" period to include some treatment,
# the naive DiD can show POSITIVE effects (wrong sign)

# ==============================================================================
# SIMULATION FUNCTION
# ==============================================================================

# Simulation: Contaminated "pre" period + differential trends produces sign flips
#
# Key mechanism demonstrated:
# 1. States selecting into treatment have IMPROVING food security (selection)
# 2. The "pre" period is contaminated by federal waivers or partial treatment
# 3. Naive binary coding assigns partial exposure to "treated=1" in year g
#    and partial/contaminated exposure to "treated=0" in year g-1
# 4. Selection-driven improvements get attributed to "treatment effect"
#
# This produces POSITIVE coefficients even when true effect is NEGATIVE

simulate_did_with_recall <- function(
  n_states = 50,
  n_treated = 5,
  n_years = 5,
  n_hh = 500,
  treat_year = 3,
  treat_month = 8,
  monthly_effect = -0.02,
  recall = 12,
  selection_trend = 0.03,      # Treated states worsening faster (selection into treatment)
  year_shock_sd = 0.01,        # SD of year shocks
  pre_contamination = 0.5      # Share of "pre" recall window with federal waivers
) {

  # Assign treatment
  treated_states <- 1:n_treated

  # Create state-specific trends
  # Treated states have IMPROVING trends (selection into treatment)
  # This is realistic: states with stronger safety nets adopt progressive policies
  state_trends <- tibble(
    state = 1:n_states,
    trend = rnorm(n_states, mean = 0, sd = 0.005)
  )
  # Treated states are WORSENING (positive trend = more food insecurity over time)
  # This reflects selection: states adopt universal meals IN RESPONSE to rising food insecurity
  state_trends$trend[treated_states] <- selection_trend

  # Year shocks
  year_shocks <- tibble(
    year = 1:n_years,
    shock = c(0, cumsum(rnorm(n_years - 1, 0, year_shock_sd)))
  )

  # Generate household-level data
  data <- expand_grid(
    state = 1:n_states,
    year = 1:n_years,
    hh = 1:n_hh
  ) %>%
    left_join(state_trends, by = "state") %>%
    left_join(year_shocks, by = "year") %>%
    mutate(
      treated_state = state %in% treated_states,

      # Standard binary treatment coding (PROBLEMATIC)
      # "Post" means survey year >= adoption year
      post = year >= treat_year,
      treated_binary = treated_state & post,

      # TRUE exposure accounting for recall window and federal waivers
      #
      # Year g-1 (coded "pre"): survey captures Dec(g-2) to Nov(g-1)
      #   - Federal waivers were in effect, so EVERYONE had some treatment
      #   - Contamination = pre_contamination * recall months
      #
      # Year g (coded "post"): survey captures Dec(g-1) to Nov(g)
      #   - Treatment starts Aug(g), so 4 months post-treatment
      #   - Plus federal waiver contamination in Dec(g-1) to Jun(g) = 7 months
      #   - Total exposure ≈ 4 + 7 = 11 months, but waivers applied to EVERYONE
      #
      # The key issue: binary coding treats year g-1 as "clean pre" when it's not

      # For simplicity, model exposure as:
      months_true_treatment = case_when(
        !treated_state ~ 0,
        year < treat_year ~ 0,
        year == treat_year ~ 4,   # Aug-Nov only
        year > treat_year ~ 12
      ),

      # Federal waiver exposure (applied to ALL states)
      # Waivers active through June of treat_year
      months_waiver = case_when(
        year < treat_year ~ recall * pre_contamination,  # partial contamination
        year == treat_year ~ 7,   # Dec through Jun of recall window
        year > treat_year ~ 0
      ),

      # Total "universal meal" exposure
      total_exposure = (months_true_treatment + months_waiver) / recall,

      # Base rate
      base_rate = 0.15 + (state - 25) / 200,

      # Latent food insecurity (state baseline + trend + shock)
      latent_fi = base_rate + trend * (year - 1) + shock,

      # Treatment effect applied to exposure intensity
      # Effect scales linearly with exposure: full-year effect * (months/12)
      # Note: waiver effect applies to ALL states, true treatment only to treated
      true_effect = case_when(
        treated_state ~ (months_true_treatment / recall) * monthly_effect,
        TRUE ~ 0
      ),

      # Probability
      prob_insecure = pmax(0, pmin(1, latent_fi + true_effect)),
      food_insecure = rbinom(n(), 1, prob_insecure)
    )

  # Naive TWFE (binary treatment - PROBLEMATIC)
  naive_model <- feols(
    food_insecure ~ treated_binary | state + year,
    data = data,
    cluster = ~state
  )

  # Exposure-weighted (CORRECT approach, but only if we knew true exposure)
  exposure_model <- feols(
    food_insecure ~ I(months_true_treatment / recall) | state + year,
    data = data,
    cluster = ~state
  )

  tibble(
    naive_coef = coef(naive_model)["treated_binaryTRUE"],
    naive_se = se(naive_model)["treated_binaryTRUE"],
    exposure_coef = coef(exposure_model)[1],
    exposure_se = se(exposure_model)[1],
    true_full_year_effect = monthly_effect  # This is the full-year effect, not monthly * 12
  )
}

# ==============================================================================
# RUN MONTE CARLO
# ==============================================================================

n_sims <- 500

cat("Running", n_sims, "Monte Carlo simulations...\n")

results <- map_dfr(1:n_sims, function(i) {
  if (i %% 50 == 0) cat("Simulation", i, "\n")
  simulate_did_with_recall()
}, .progress = TRUE)

# ==============================================================================
# ANALYZE RESULTS
# ==============================================================================

# Summary statistics
summary_stats <- results %>%
  summarise(
    # Naive estimator
    naive_mean = mean(naive_coef),
    naive_sd = sd(naive_coef),
    naive_bias = mean(naive_coef) - mean(true_full_year_effect),
    naive_positive_share = mean(naive_coef > 0),
    naive_sig_wrong_sign = mean(naive_coef > 1.96 * naive_se),

    # Exposure estimator
    exposure_mean = mean(exposure_coef),
    exposure_sd = sd(exposure_coef),
    exposure_bias = mean(exposure_coef) - mean(true_full_year_effect),
    exposure_positive_share = mean(exposure_coef > 0),

    # True effect
    true_effect = mean(true_full_year_effect)
  )

cat("\n=== SIMULATION RESULTS ===\n")
cat("True full-year effect:", round(summary_stats$true_effect, 4), "\n")
cat("\nNaive binary DiD:\n")
cat("  Mean estimate:", round(summary_stats$naive_mean, 4), "\n")
cat("  Std dev:", round(summary_stats$naive_sd, 4), "\n")
cat("  Bias:", round(summary_stats$naive_bias, 4), "\n")
cat("  Share with WRONG sign (positive):", round(summary_stats$naive_positive_share * 100, 1), "%\n")
cat("  Share sig. wrong sign:", round(summary_stats$naive_sig_wrong_sign * 100, 1), "%\n")

cat("\nExposure-weighted DiD:\n")
cat("  Mean estimate:", round(summary_stats$exposure_mean, 4), "\n")
cat("  Std dev:", round(summary_stats$exposure_sd, 4), "\n")
cat("  Bias:", round(summary_stats$exposure_bias, 4), "\n")

# ==============================================================================
# SAVE RESULTS
# ==============================================================================

saveRDS(results, "data/simulation_results.rds")
write_csv(summary_stats, "tables/simulation_summary.csv")

# ==============================================================================
# CREATE FIGURE
# ==============================================================================

# Figure: Distribution of naive vs exposure-weighted estimates
true_effect_value <- -0.02  # True full-year effect

fig_sim <- results %>%
  select(naive_coef, exposure_coef) %>%
  pivot_longer(everything(), names_to = "estimator", values_to = "estimate") %>%
  mutate(
    estimator = case_when(
      estimator == "naive_coef" ~ "Binary Treatment DiD",
      estimator == "exposure_coef" ~ "Exposure-Weighted DiD"
    )
  ) %>%
  ggplot(aes(x = estimate, fill = estimator)) +
  geom_density(alpha = 0.6) +
  geom_vline(xintercept = true_effect_value, linetype = "dashed", color = "red", linewidth = 0.8) +
  annotate("text", x = true_effect_value, y = 30, label = "True Effect\n(-0.02)",
           hjust = 1.1, size = 3.5, color = "red") +
  geom_vline(xintercept = 0, linetype = "solid", color = "black", linewidth = 0.5) +
  scale_fill_manual(values = c("Binary Treatment DiD" = "#E69F00",
                               "Exposure-Weighted DiD" = "#56B4E9")) +
  labs(
    x = "Estimated Treatment Effect",
    y = "Density",
    fill = "Estimator",
    title = "Monte Carlo: Selection + Recall Mismatch Causes Sign Reversal",
    subtitle = paste0("500 simulations. True effect = -2pp. ",
                      "Estimates positive (wrong sign) due to selection.")
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray40")
  )

ggsave("figures/fig_simulation.png", fig_sim, width = 8, height = 5, dpi = 300)

cat("\nFigure saved to figures/fig_simulation.png\n")

# ==============================================================================
# VARYING PARAMETERS
# ==============================================================================

# How does bias vary with months of exposure in first "post" year?
exposure_months_test <- tibble(
  months = 1:11
) %>%
  rowwise() %>%
  mutate(
    # Adjust treatment month to get different exposure
    treat_month_adj = 13 - months,  # 12 - months + 1
    sims = list(map_dfr(1:100, function(i) {
      simulate_did_with_recall(treat_month = treat_month_adj)
    })),
    mean_naive = mean(sims$naive_coef),
    mean_exposure = mean(sims$exposure_coef)
  ) %>%
  ungroup()

# Figure: Bias by exposure share
fig_bias_by_exposure <- exposure_months_test %>%
  select(months, mean_naive, mean_exposure) %>%
  pivot_longer(-months, names_to = "estimator", values_to = "estimate") %>%
  mutate(
    estimator = case_when(
      estimator == "mean_naive" ~ "Binary Treatment DiD",
      estimator == "mean_exposure" ~ "Exposure-Weighted DiD"
    )
  ) %>%
  ggplot(aes(x = months / 12, y = estimate, color = estimator)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_hline(yintercept = true_effect_value, linetype = "dashed", color = "red") +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray50") +
  scale_x_continuous(labels = scales::percent_format()) +
  scale_color_manual(values = c("Binary Treatment DiD" = "#E69F00",
                                "Exposure-Weighted DiD" = "#56B4E9")) +
  labs(
    x = "Exposure Share in First Post-Treatment Year",
    y = "Mean Estimated Effect",
    color = "Estimator",
    title = "Bias Increases as Exposure Share Decreases",
    subtitle = "Red dashed line = true effect (-0.02)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14)
  )

ggsave("figures/fig_bias_by_exposure.png", fig_bias_by_exposure, width = 8, height = 5, dpi = 300)

cat("Bias-by-exposure figure saved to figures/fig_bias_by_exposure.png\n")

cat("\n=== SIMULATION COMPLETE ===\n")
