# =============================================================================
# 04b_randomization_inference.R
# Randomization Inference for Auto-IRA Analysis
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Motivation
# -----------------------------------------------------------------------------

# With only 11 treated states, standard asymptotic inference may be unreliable.
# Randomization inference provides exact p-values by comparing the observed
# treatment effect to the distribution of effects under random treatment
# assignment.
#
# Procedure:
# 1. Estimate actual ATT from observed treatment timing
# 2. Randomly reassign treatment years 1000+ times
# 3. Re-estimate ATT under each permutation
# 4. p-value = share of permuted ATTs >= actual ATT

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cat("Loading cleaned data...\n")
df <- readRDS(file.path(data_dir, "cps_asec_clean.rds"))

# Collapse to state-year
df_state_year <- df %>%
  group_by(statefip, year, first_treat) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    n_obs = n(),
    sum_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.numeric(factor(statefip)),
    first_treat = replace_na(first_treat, 0)
  )

# Actual treatment timing
actual_treatment <- df_state_year %>%
  filter(first_treat > 0) %>%
  distinct(statefip, first_treat) %>%
  arrange(first_treat)

n_treated <- nrow(actual_treatment)
cat("Number of treated states:", n_treated, "\n")
print(actual_treatment)

# Get set of treatment years used in actual data
treatment_years <- sort(unique(actual_treatment$first_treat))
cat("\nTreatment years:", paste(treatment_years, collapse = ", "), "\n")

# -----------------------------------------------------------------------------
# Actual ATT Estimate
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ACTUAL TREATMENT EFFECT\n")
cat(rep("=", 60), "\n\n")

# Simple TWFE for speed
df_state_year <- df_state_year %>%
  mutate(post = ifelse(first_treat > 0 & year >= first_treat, 1, 0))

actual_model <- feols(
  pension_rate ~ post | state_id + year,
  data = df_state_year,
  cluster = ~statefip
)

actual_att <- coef(actual_model)["post"]
cat("Actual ATT:", round(actual_att, 5), "\n")

# -----------------------------------------------------------------------------
# Randomization Inference
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("RANDOMIZATION INFERENCE\n")
cat(rep("=", 60), "\n\n")

set.seed(42)
n_perms <- 2000

cat("Running", n_perms, "permutations...\n")

# Get all state FIPs
all_states <- unique(df_state_year$statefip)

# Store permuted ATTs
perm_atts <- numeric(n_perms)

pb <- txtProgressBar(min = 0, max = n_perms, style = 3)

for (i in 1:n_perms) {
  # Randomly select which states are treated
  perm_treated_states <- sample(all_states, n_treated)

  # Randomly assign treatment years (from actual distribution)
  perm_treat_years <- sample(treatment_years, n_treated, replace = TRUE)

  # Create permuted treatment assignment
  perm_treat_lookup <- tibble(
    statefip = perm_treated_states,
    perm_first_treat = perm_treat_years
  )

  # Merge with data
  df_perm <- df_state_year %>%
    left_join(perm_treat_lookup, by = "statefip") %>%
    mutate(
      perm_first_treat = replace_na(perm_first_treat, 0),
      perm_post = ifelse(perm_first_treat > 0 & year >= perm_first_treat, 1, 0)
    )

  # Estimate permuted ATT
  perm_model <- feols(
    pension_rate ~ perm_post | state_id + year,
    data = df_perm,
    warn = FALSE
  )

  perm_atts[i] <- coef(perm_model)["perm_post"]

  setTxtProgressBar(pb, i)
}

close(pb)

# -----------------------------------------------------------------------------
# Compute p-values
# -----------------------------------------------------------------------------

cat("\n\nComputing p-values...\n")

# Two-sided p-value
p_twosided <- mean(abs(perm_atts) >= abs(actual_att))

# One-sided p-values
p_right <- mean(perm_atts >= actual_att)  # H1: effect > 0
p_left <- mean(perm_atts <= actual_att)   # H1: effect < 0

cat("\nRandomization Inference Results:\n")
cat("  Actual ATT:", round(actual_att, 5), "\n")
cat("  Mean permuted ATT:", round(mean(perm_atts), 5), "\n")
cat("  SD permuted ATT:", round(sd(perm_atts), 5), "\n")
cat("\n  p-value (two-sided):", round(p_twosided, 4), "\n")
cat("  p-value (right-sided, H1: effect > 0):", round(p_right, 4), "\n")
cat("  p-value (left-sided, H1: effect < 0):", round(p_left, 4), "\n")

# Percentiles of permutation distribution
cat("\n  Permutation distribution percentiles:\n")
cat("    5th percentile:", round(quantile(perm_atts, 0.05), 5), "\n")
cat("    25th percentile:", round(quantile(perm_atts, 0.25), 5), "\n")
cat("    50th percentile:", round(quantile(perm_atts, 0.50), 5), "\n")
cat("    75th percentile:", round(quantile(perm_atts, 0.75), 5), "\n")
cat("    95th percentile:", round(quantile(perm_atts, 0.95), 5), "\n")

# Fisher exact CI (invert the test)
ci_lower <- quantile(perm_atts, 0.025)
ci_upper <- quantile(perm_atts, 0.975)

cat("\n  95% randomization interval: [", round(ci_lower, 5), ",",
    round(ci_upper, 5), "]\n")

# -----------------------------------------------------------------------------
# Visualization
# -----------------------------------------------------------------------------

cat("\nCreating visualization...\n")

perm_df <- tibble(att = perm_atts)

fig_ri <- ggplot(perm_df, aes(x = att)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50,
                 fill = "grey70", color = "grey50", alpha = 0.8) +
  geom_vline(xintercept = actual_att, color = apep_colors[1],
             linewidth = 1.2, linetype = "solid") +
  geom_vline(xintercept = 0, color = "grey40",
             linewidth = 0.8, linetype = "dashed") +
  annotate("text", x = actual_att, y = Inf,
           label = paste0("Actual ATT = ", round(actual_att, 4)),
           hjust = -0.1, vjust = 1.5, color = apep_colors[1], size = 4) +
  annotate("text", x = max(perm_atts) * 0.7, y = Inf,
           label = paste0("p = ", round(p_twosided, 3), " (two-sided)"),
           hjust = 0, vjust = 3, size = 4) +
  labs(
    title = "Randomization Inference: Distribution of Permuted Treatment Effects",
    subtitle = paste0(n_perms, " permutations of treatment assignment across states"),
    x = "Average Treatment Effect (ATT)",
    y = "Density",
    caption = "Note: Vertical blue line shows actual ATT. Dashed line at zero."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_randomization_inference.pdf"), fig_ri,
       width = 9, height = 6)
ggsave(file.path(fig_dir, "fig_randomization_inference.png"), fig_ri,
       width = 9, height = 6, dpi = 300)

cat("Saved: fig_randomization_inference.pdf\n")

# -----------------------------------------------------------------------------
# Randomization Inference for DDD (if data exists)
# -----------------------------------------------------------------------------

if (file.exists(file.path(data_dir, "ddd_full.rds"))) {

  cat("\n", rep("=", 60), "\n")
  cat("RANDOMIZATION INFERENCE FOR DDD\n")
  cat(rep("=", 60), "\n\n")

  # Load DDD model to get actual coefficient
  ddd_model <- readRDS(file.path(data_dir, "ddd_full.rds"))
  actual_ddd_att <- coef(ddd_model)["treat_post_small"]

  cat("Actual DDD ATT:", round(actual_ddd_att, 5), "\n")
  cat("Running", n_perms, "permutations for DDD...\n")

  # Load cell-level data
  df_cells <- df %>%
    filter(!is.na(small_firm)) %>%
    group_by(statefip, year, first_treat, small_firm) %>%
    summarise(
      pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
      sum_weight = sum(weight, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      state_id = as.numeric(factor(statefip)),
      first_treat = replace_na(first_treat, 0),
      state_firmsize = paste(statefip, small_firm, sep = "_"),
      year_firmsize = paste(year, small_firm, sep = "_")
    )

  perm_ddd_atts <- numeric(n_perms)
  pb <- txtProgressBar(min = 0, max = n_perms, style = 3)

  for (i in 1:n_perms) {
    # Randomly select treated states
    perm_treated_states <- sample(all_states, n_treated)
    perm_treat_years <- sample(treatment_years, n_treated, replace = TRUE)

    perm_treat_lookup <- tibble(
      statefip = perm_treated_states,
      perm_first_treat = perm_treat_years
    )

    df_perm <- df_cells %>%
      left_join(perm_treat_lookup, by = "statefip") %>%
      mutate(
        perm_first_treat = replace_na(perm_first_treat, 0),
        perm_treated = ifelse(perm_first_treat > 0, 1, 0),
        perm_post = ifelse(perm_first_treat > 0 & year >= perm_first_treat, 1, 0),
        perm_treat_post_small = perm_treated * perm_post * small_firm
      )

    # Estimate permuted DDD
    perm_ddd <- try(feols(
      pension_rate ~ perm_treat_post_small | state_firmsize + year_firmsize,
      data = df_perm,
      weights = ~sum_weight,
      warn = FALSE
    ), silent = TRUE)

    if (!inherits(perm_ddd, "try-error")) {
      perm_ddd_atts[i] <- coef(perm_ddd)["perm_treat_post_small"]
    } else {
      perm_ddd_atts[i] <- NA
    }

    setTxtProgressBar(pb, i)
  }
  close(pb)

  # Remove failed permutations
  perm_ddd_atts <- perm_ddd_atts[!is.na(perm_ddd_atts)]

  # p-values
  p_ddd_twosided <- mean(abs(perm_ddd_atts) >= abs(actual_ddd_att))
  p_ddd_right <- mean(perm_ddd_atts >= actual_ddd_att)

  cat("\n\nDDD Randomization Inference Results:\n")
  cat("  Actual DDD ATT:", round(actual_ddd_att, 5), "\n")
  cat("  Mean permuted DDD ATT:", round(mean(perm_ddd_atts), 5), "\n")
  cat("  p-value (two-sided):", round(p_ddd_twosided, 4), "\n")
  cat("  p-value (right-sided):", round(p_ddd_right, 4), "\n")

  # Save DDD permutation results
  ddd_perm_results <- tibble(
    actual_att = actual_ddd_att,
    mean_perm_att = mean(perm_ddd_atts),
    sd_perm_att = sd(perm_ddd_atts),
    p_twosided = p_ddd_twosided,
    p_right = p_ddd_right,
    n_perms = length(perm_ddd_atts)
  )
  write_csv(ddd_perm_results, file.path(data_dir, "ri_ddd_results.csv"))
}

# -----------------------------------------------------------------------------
# Save Results
# -----------------------------------------------------------------------------

ri_results <- tibble(
  actual_att = actual_att,
  mean_perm_att = mean(perm_atts),
  sd_perm_att = sd(perm_atts),
  p_twosided = p_twosided,
  p_right = p_right,
  p_left = p_left,
  ci_lower = ci_lower,
  ci_upper = ci_upper,
  n_perms = n_perms
)

write_csv(ri_results, file.path(data_dir, "randomization_inference_results.csv"))
saveRDS(perm_atts, file.path(data_dir, "permuted_atts.rds"))

cat("\n", rep("=", 60), "\n")
cat("RANDOMIZATION INFERENCE COMPLETE\n")
cat(rep("=", 60), "\n")
cat("\nResults saved to:", data_dir, "\n")
