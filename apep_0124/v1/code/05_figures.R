# =============================================================================
# 05_figures.R
# Generate publication-quality figures
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load data
# =============================================================================

cat("Loading data...\n")

focal_votes <- read_csv("../data/rdd_focal_votes.csv", show_col_types = FALSE)
muni_turnout <- read_csv("../data/muni_year_turnout.csv", show_col_types = FALSE)

# Reconstruct analysis data
# First select only the columns we need from muni_turnout to avoid name conflicts
muni_future <- muni_turnout %>%
  select(muni_id, future_year = vote_year, subsequent_turnout = avg_turnout)

focal_with_outcome <- focal_votes %>%
  left_join(
    muni_future,
    by = "muni_id",
    relationship = "many-to-many"
  ) %>%
  filter(future_year > vote_year, future_year <= vote_year + 3) %>%
  group_by(vote_proposal_id, muni_id, vote_date, vote_year,
           yes_pct, running_var, local_win, turnout_pct, eligible_voters,
           kanton_name, language_region, policy_domain) %>%
  summarise(
    subsequent_turnout = mean(subsequent_turnout, na.rm = TRUE),
    n_future_years = n(),
    .groups = "drop"
  ) %>%
  filter(!is.na(subsequent_turnout))

results <- readRDS("../data/rdd_results.rds")

# =============================================================================
# Figure 1: Distribution of Running Variable
# =============================================================================

cat("Creating Figure 1: Running variable distribution...\n")

fig1 <- focal_with_outcome %>%
  ggplot(aes(x = running_var)) +
  geom_histogram(
    binwidth = 2,
    fill = "steelblue",
    color = "white",
    alpha = 0.8
  ) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  labs(
    title = "Distribution of Municipal Vote Share",
    subtitle = "Running variable: Yes vote share minus 50%",
    x = "Distance from 50% Threshold (percentage points)",
    y = "Number of Municipality-Referendum Observations"
  ) +
  theme_apep() +
  annotate("text", x = -25, y = Inf, label = "Local\nLosers",
           hjust = 0.5, vjust = 1.5, size = 4, color = "gray40") +
  annotate("text", x = 25, y = Inf, label = "Local\nWinners",
           hjust = 0.5, vjust = 1.5, size = 4, color = "gray40")

ggsave("../figures/fig1_running_variable_distribution.pdf", fig1,
       width = 8, height = 5, dpi = 300)

# =============================================================================
# Figure 2: RDD Plot - Discontinuity in Subsequent Turnout
# =============================================================================

cat("Creating Figure 2: RDD discontinuity plot...\n")

# Create binned scatterplot
bins <- focal_with_outcome %>%
  mutate(bin = cut(running_var, breaks = seq(-50, 50, by = 2))) %>%
  group_by(bin) %>%
  summarise(
    running_var_mean = mean(running_var, na.rm = TRUE),
    outcome_mean = mean(subsequent_turnout, na.rm = TRUE),
    outcome_se = sd(subsequent_turnout, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(!is.na(running_var_mean))

# Local polynomial fits
loess_left <- loess(subsequent_turnout ~ running_var,
                    data = focal_with_outcome %>% filter(running_var < 0))
loess_right <- loess(subsequent_turnout ~ running_var,
                     data = focal_with_outcome %>% filter(running_var >= 0))

# Prediction data
pred_left <- tibble(running_var = seq(-40, -0.1, by = 0.5)) %>%
  mutate(fitted = predict(loess_left, newdata = .))
pred_right <- tibble(running_var = seq(0.1, 40, by = 0.5)) %>%
  mutate(fitted = predict(loess_right, newdata = .))

fig2 <- ggplot() +
  geom_point(data = bins,
             aes(x = running_var_mean, y = outcome_mean),
             size = 2, alpha = 0.7, color = "steelblue") +
  geom_line(data = pred_left,
            aes(x = running_var, y = fitted),
            color = "darkblue", linewidth = 1) +
  geom_line(data = pred_right,
            aes(x = running_var, y = fitted),
            color = "darkblue", linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
  labs(
    title = "Effect of Local Referendum Loss on Subsequent Turnout",
    subtitle = "Binned scatterplot with local polynomial fits",
    x = "Distance from 50% Threshold (percentage points)",
    y = "Average Turnout in Subsequent Referendums (%)"
  ) +
  theme_apep() +
  coord_cartesian(xlim = c(-40, 40))

ggsave("../figures/fig2_rdd_discontinuity.pdf", fig2,
       width = 8, height = 6, dpi = 300)

# =============================================================================
# Figure 3: McCrary Density Plot
# =============================================================================

cat("Creating Figure 3: McCrary density test...\n")

# Get density test from rddensity
density_test <- rddensity(X = focal_with_outcome$running_var, c = 0)

# Manual density plot
fig3 <- focal_with_outcome %>%
  ggplot(aes(x = running_var)) +
  geom_density(fill = "steelblue", alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  labs(
    title = "Density of Running Variable Near Cutoff",
    subtitle = paste0("McCrary test p-value: ",
                      round(density_test$test$p_jk, 3)),
    x = "Distance from 50% Threshold (percentage points)",
    y = "Density"
  ) +
  theme_apep() +
  coord_cartesian(xlim = c(-30, 30))

ggsave("../figures/fig3_mccrary_density.pdf", fig3,
       width = 8, height = 5, dpi = 300)

# =============================================================================
# Figure 4: Covariate Balance
# =============================================================================

cat("Creating Figure 4: Covariate balance...\n")

# Test multiple covariates at cutoff
covariates <- c("turnout_pct", "eligible_voters")

balance_results <- map_dfr(covariates, function(cov) {
  y <- focal_with_outcome[[cov]]
  if (cov == "eligible_voters") y <- log(y + 1)

  result <- tryCatch({
    rdrobust(y = y, x = focal_with_outcome$running_var, c = 0)
  }, error = function(e) NULL)

  if (is.null(result)) {
    return(tibble(covariate = cov, estimate = NA, se = NA))
  }

  tibble(
    covariate = cov,
    estimate = result$coef["Conventional"],
    se = result$se["Robust"],
    ci_low = result$ci["Robust", 1],
    ci_high = result$ci["Robust", 2]
  )
})

fig4 <- balance_results %>%
  filter(!is.na(estimate)) %>%
  mutate(covariate = case_when(
    covariate == "turnout_pct" ~ "Focal Vote Turnout",
    covariate == "eligible_voters" ~ "Log(Eligible Voters)",
    TRUE ~ covariate
  )) %>%
  ggplot(aes(x = covariate, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high),
                width = 0.2, color = "steelblue") +
  coord_flip() +
  labs(
    title = "Covariate Balance at RDD Cutoff",
    subtitle = "RD estimates with 95% confidence intervals",
    x = "",
    y = "Discontinuity Estimate"
  ) +
  theme_apep()

ggsave("../figures/fig4_covariate_balance.pdf", fig4,
       width = 7, height = 4, dpi = 300)

# =============================================================================
# Figure 5: Bandwidth Sensitivity
# =============================================================================

cat("Creating Figure 5: Bandwidth sensitivity...\n")

bw_sensitivity <- read_csv("../tables/rdd_bandwidth_sensitivity.csv", show_col_types = FALSE)

fig5 <- bw_sensitivity %>%
  ggplot(aes(x = bandwidth, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(aes(ymin = estimate - 1.96 * se_robust,
                    ymax = estimate + 1.96 * se_robust),
                width = 0.5, color = "steelblue") +
  geom_vline(xintercept = bw_sensitivity$bandwidth[bw_sensitivity$bw_factor == 1],
             linetype = "dotted", color = "red") +
  labs(
    title = "Bandwidth Sensitivity Analysis",
    subtitle = "Red line indicates MSE-optimal bandwidth",
    x = "Bandwidth (percentage points)",
    y = "RD Estimate"
  ) +
  theme_apep()

ggsave("../figures/fig5_bandwidth_sensitivity.pdf", fig5,
       width = 7, height = 5, dpi = 300)

# =============================================================================
# Figure 6: Placebo Tests
# =============================================================================

cat("Creating Figure 6: Placebo cutoffs...\n")

placebo <- read_csv("../tables/rdd_placebo_tests.csv", show_col_types = FALSE) %>%
  filter(!is.na(estimate))

# Add true cutoff result
true_result <- results$primary

all_cutoffs <- bind_rows(
  placebo %>% select(cutoff, estimate, pvalue),
  tibble(cutoff = 0, estimate = true_result$estimate, pvalue = true_result$pvalue)
) %>%
  mutate(is_true = cutoff == 0)

fig6 <- all_cutoffs %>%
  ggplot(aes(x = cutoff, y = estimate, color = is_true)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 4) +
  scale_color_manual(values = c("FALSE" = "gray60", "TRUE" = "red"),
                     guide = "none") +
  labs(
    title = "Placebo Tests at Alternative Cutoffs",
    subtitle = "Red point indicates true cutoff at 50%",
    x = "Cutoff Location (distance from 50%)",
    y = "RD Estimate"
  ) +
  theme_apep()

ggsave("../figures/fig6_placebo_cutoffs.pdf", fig6,
       width = 7, height = 5, dpi = 300)

# =============================================================================
# Summary
# =============================================================================

cat("\n=== FIGURES SAVED ===\n")
cat("fig1_running_variable_distribution.pdf\n")
cat("fig2_rdd_discontinuity.pdf\n")
cat("fig3_mccrary_density.pdf\n")
cat("fig4_covariate_balance.pdf\n")
cat("fig5_bandwidth_sensitivity.pdf\n")
cat("fig6_placebo_cutoffs.pdf\n")
cat("\nDone.\n")
