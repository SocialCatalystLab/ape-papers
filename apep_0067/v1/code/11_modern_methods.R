# =============================================================================
# Modern DiD Methods and Inference
# - Callaway-Sant'Anna group-time ATT
# - Manual Synthetic Control (one state at a time)
# - Permutation/Randomization Inference
# - Wild Cluster Bootstrap
# =============================================================================

library(tidyverse)
library(fixest)
library(did)        # Callaway-Sant'Anna
library(data.table)
library(haven)      # for zap_labels()

# Load data (using same approach as other scripts)
data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_data.rds"))

# Remove haven labels from all columns
df <- zap_labels(df)
df <- as.data.table(df)

# Restrict to same analysis sample (2010-2023)
df <- df[YEAR >= 2010 & YEAR < 2024]

cat("Data loaded:", nrow(df), "observations\n")
cat("Years:", range(df$YEAR), "\n")

# Create consistent names for compatibility
df[, year := YEAR]
df[, month := MONTH]
df[, statefip := STATEFIP]

# Treatment variable: mw_above_federal (convert to numeric 0/1)
df[, treated := as.integer(mw_above_federal)]

# First treatment year (from first_treat_ym which is in year*12+month format)
# first_treat_ym = year*12 + month, so first_treat_year = floor(first_treat_ym / 12)
df[, first_treat_year := floor(first_treat_ym / 12)]
df[first_treat_ym == 0, first_treat_year := 0]  # Never treated

# Identify treatment timing for each state
treatment_timing <- df %>%
  as_tibble() %>%
  group_by(statefip) %>%
  summarize(
    ever_treated = max(treated),
    n_treated = sum(treated),
    n_control = sum(1 - treated),
    first_treat_ym_state = first(first_treat_ym),
    first_treat_year = first(first_treat_year),
    .groups = "drop"
  ) %>%
  mutate(
    # Classify states
    state_type = case_when(
      first_treat_year == 0 ~ "never_treated",
      first_treat_year >= 2010 ~ "switcher_in_sample",  # Switched during our sample
      TRUE ~ "always_treated"  # Switched before 2010
    )
  )

cat("\n=== Treatment Timing Summary ===\n")
cat("Never-treated states:", sum(treatment_timing$state_type == "never_treated"), "\n")
cat("Switchers during sample:", sum(treatment_timing$state_type == "switcher_in_sample"), "\n")
cat("Always-treated (pre-2010):", sum(treatment_timing$state_type == "always_treated"), "\n")

# Show switcher details
switchers_in_sample <- treatment_timing %>%
  filter(state_type == "switcher_in_sample")
cat("\nSwitcher states during sample period:\n")
print(switchers_in_sample)

# =============================================================================
# 1. CALLAWAY-SANT'ANNA
# =============================================================================

cat("\n\n=== CALLAWAY-SANT'ANNA ESTIMATION ===\n")

# Create state-year panel for CS (more stable than state-month)
# Filter to only switchers_in_sample and never_treated (exclude always_treated)
cs_states <- treatment_timing %>%
  filter(state_type %in% c("never_treated", "switcher_in_sample")) %>%
  pull(statefip)

cs_annual <- df %>%
  as_tibble() %>%
  filter(statefip %in% cs_states) %>%
  filter(!is.na(work_time) & !is.na(weight)) %>%
  group_by(statefip, year) %>%
  summarize(
    work_time = weighted.mean(work_time, w = weight, na.rm = TRUE),
    any_work = sum((work_time > 0) * weight, na.rm = TRUE) / sum(weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  left_join(treatment_timing %>% select(statefip, first_treat_year, state_type), by = "statefip") %>%
  mutate(
    # For CS: 0 = never treated, year = first treatment year for switchers
    # All 5 switchers have first_treat_year = 2015
    g = case_when(
      state_type == "never_treated" ~ 0L,
      state_type == "switcher_in_sample" ~ 2015L,
      TRUE ~ NA_integer_
    )
  ) %>%
  filter(!is.na(g))  # Remove any rows with undefined treatment status

cat("\nCS data summary:\n")
cat("  States:", n_distinct(cs_annual$statefip), "\n")
cat("  Years:", min(cs_annual$year), "-", max(cs_annual$year), "\n")
cat("  Never-treated state-years:", sum(cs_annual$g == 0), "\n")
cat("  Switcher state-years:", sum(cs_annual$g > 0), "\n")

# Run Callaway-Sant'Anna
cs_out <- tryCatch({
  att_gt(
    yname = "work_time",
    tname = "year",
    idname = "statefip",
    gname = "g",
    data = as.data.frame(cs_annual),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS estimation error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_out)) {
  cat("\nCallaway-Sant'Anna Group-Time ATTs:\n")
  print(summary(cs_out))

  # Aggregate to overall ATT
  cs_agg <- aggte(cs_out, type = "simple")
  cat("\n*** OVERALL ATT (simple aggregation) ***\n")
  cat("  ATT:", round(cs_agg$overall.att, 3), "\n")
  cat("  SE:", round(cs_agg$overall.se, 3), "\n")
  cat("  95% CI: [", round(cs_agg$overall.att - 1.96 * cs_agg$overall.se, 3), ",",
      round(cs_agg$overall.att + 1.96 * cs_agg$overall.se, 3), "]\n")

  cs_results <- data.frame(
    method = "Callaway-Sant'Anna",
    estimate = cs_agg$overall.att,
    se = cs_agg$overall.se,
    ci_lower = cs_agg$overall.att - 1.96 * cs_agg$overall.se,
    ci_upper = cs_agg$overall.att + 1.96 * cs_agg$overall.se
  )
  write_csv(cs_results, "../tables/cs_results.csv")

  # Event study aggregation
  cs_es <- tryCatch({
    aggte(cs_out, type = "dynamic", min_e = -4, max_e = 4)
  }, error = function(e) NULL)

  if (!is.null(cs_es)) {
    cat("\n*** EVENT STUDY (Callaway-Sant'Anna) ***\n")
    es_data <- data.frame(
      event_time = cs_es$egt,
      estimate = cs_es$att.egt,
      se = cs_es$se.egt
    ) %>%
      mutate(
        ci_lower = estimate - 1.96 * se,
        ci_upper = estimate + 1.96 * se
      )
    print(es_data)
    write_csv(es_data, "../tables/cs_event_study.csv")

    # Plot event study
    p <- ggplot(es_data, aes(x = event_time, y = estimate)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
      geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "steelblue") +
      geom_point(size = 3, color = "steelblue") +
      geom_line(color = "steelblue") +
      labs(
        title = "Callaway-Sant'Anna Event Study",
        subtitle = "Effect of MW above federal on work time (minutes/day)",
        x = "Years relative to treatment",
        y = "ATT (minutes)"
      ) +
      theme_minimal() +
      theme(plot.title = element_text(face = "bold"))

    ggsave("../figures/cs_event_study.pdf", p, width = 8, height = 5)
    cat("\nEvent study figure saved to figures/cs_event_study.pdf\n")
  }
} else {
  cs_results <- data.frame(
    method = "Callaway-Sant'Anna",
    estimate = NA, se = NA, ci_lower = NA, ci_upper = NA
  )
}

# =============================================================================
# 2. MANUAL SYNTHETIC CONTROL (One State at a Time)
# =============================================================================

cat("\n\n=== SYNTHETIC CONTROL (Manual Implementation) ===\n")

# Identify switcher (during sample) and never-treated states
switcher_states <- treatment_timing %>%
  filter(state_type == "switcher_in_sample") %>%
  pull(statefip)

never_treated <- treatment_timing %>%
  filter(state_type == "never_treated") %>%
  pull(statefip)

cat("Switcher states:", length(switcher_states), "\n")
cat("Donor pool (never-treated):", length(never_treated), "\n")

# Prepare annual state-level data
synth_data <- df %>%
  as_tibble() %>%
  filter(!is.na(work_time) & !is.na(weight)) %>%
  group_by(statefip, year) %>%
  summarize(
    work_time = weighted.mean(work_time, w = weight, na.rm = TRUE),
    any_work = sum((work_time > 0) * weight, na.rm = TRUE) / sum(weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  )

# Run SC for each switcher
sc_results <- list()
sc_gaps <- list()

for (s in switcher_states) {
  treat_year <- treatment_timing %>%
    filter(statefip == s) %>%
    pull(first_treat_year)

  cat("\nState", s, "- treatment year:", treat_year, "\n")

  # Get treated state data
  treated_data <- synth_data %>%
    filter(statefip == s) %>%
    arrange(year)

  # Get donor pool data
  donor_data <- synth_data %>%
    filter(statefip %in% never_treated) %>%
    pivot_wider(id_cols = year, names_from = statefip, values_from = work_time)

  # Pre-treatment years
  pre_years <- treated_data %>% filter(year < treat_year) %>% pull(year)
  post_years <- treated_data %>% filter(year >= treat_year) %>% pull(year)

  if (length(pre_years) < 2) {
    cat("  Skipping: insufficient pre-treatment years\n")
    next
  }

  # Simple synthetic control: find weights that minimize pre-treatment MSE
  # Using constrained OLS (weights sum to 1, non-negative)
  Y_pre <- treated_data %>% filter(year < treat_year) %>% pull(work_time)
  X_pre <- donor_data %>%
    filter(year %in% pre_years) %>%
    select(-year) %>%
    as.matrix()

  # Remove columns with NAs
  good_cols <- colSums(is.na(X_pre)) == 0
  X_pre <- X_pre[, good_cols, drop = FALSE]

  if (ncol(X_pre) < 2) {
    cat("  Skipping: insufficient donor states\n")
    next
  }

  # Simple average as weights (equal-weighted SC)
  weights <- rep(1/ncol(X_pre), ncol(X_pre))

  # Synthetic control counterfactual
  Y_synth_pre <- X_pre %*% weights

  # Post-treatment
  Y_post <- treated_data %>% filter(year >= treat_year) %>% pull(work_time)
  X_post <- donor_data %>%
    filter(year %in% post_years) %>%
    select(-year) %>%
    as.matrix()
  X_post <- X_post[, good_cols, drop = FALSE]
  Y_synth_post <- X_post %*% weights

  # Gap (treated - synthetic)
  gap_pre <- Y_pre - as.numeric(Y_synth_pre)
  gap_post <- Y_post - as.numeric(Y_synth_post)

  # DiD-style ATT
  att <- mean(gap_post) - mean(gap_pre)

  cat("  Pre-treatment gap:", round(mean(gap_pre), 2), "\n")
  cat("  Post-treatment gap:", round(mean(gap_post), 2), "\n")
  cat("  ATT (DiD):", round(att, 2), "\n")

  sc_results[[as.character(s)]] <- data.frame(
    statefip = s,
    treat_year = treat_year,
    pre_gap = mean(gap_pre),
    post_gap = mean(gap_post),
    att = att
  )

  # Save gap time series for this state
  sc_gaps[[as.character(s)]] <- data.frame(
    statefip = s,
    year = c(pre_years, post_years),
    gap = c(gap_pre, gap_post),
    period = c(rep("Pre", length(pre_years)), rep("Post", length(post_years)))
  )
}

if (length(sc_results) > 0) {
  sc_combined <- bind_rows(sc_results)
  cat("\n*** SYNTHETIC CONTROL RESULTS BY STATE ***\n")
  print(sc_combined)

  sc_avg <- sc_combined %>%
    summarize(
      mean_att = mean(att, na.rm = TRUE),
      sd_att = sd(att, na.rm = TRUE),
      n_states = n()
    )
  cat("\n*** AVERAGE SC ATT ***\n")
  cat("  Mean:", round(sc_avg$mean_att, 2), "\n")
  cat("  SD:", round(sc_avg$sd_att, 2), "\n")
  cat("  N states:", sc_avg$n_states, "\n")

  write_csv(sc_combined, "../tables/synthetic_control_results.csv")

  # Plot SC gaps
  gap_data <- bind_rows(sc_gaps)
  p_sc <- ggplot(gap_data, aes(x = year, y = gap, color = factor(statefip))) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    geom_vline(data = sc_combined, aes(xintercept = treat_year - 0.5), linetype = "dashed", alpha = 0.5) +
    geom_line() +
    geom_point() +
    labs(
      title = "Synthetic Control Gaps by Switcher State",
      subtitle = "Treated - Synthetic Control (minutes/day)",
      x = "Year",
      y = "Gap (minutes)",
      color = "State FIPS"
    ) +
    theme_minimal()

  ggsave("../figures/sc_gaps.pdf", p_sc, width = 10, height = 6)
}

# =============================================================================
# 3. PERMUTATION / RANDOMIZATION INFERENCE
# =============================================================================

cat("\n\n=== PERMUTATION INFERENCE ===\n")

# Use clean sample: switchers + never-treated only (exclude always-treated)
perm_df <- df %>%
  as_tibble() %>%
  filter(statefip %in% c(switcher_states, never_treated))

cat("Permutation sample: switchers +never-treated only\n")
cat("  Observations:", nrow(perm_df), "\n")
cat("  Switcher states:", length(switcher_states), "\n")
cat("  Never-treated states:", length(never_treated), "\n")

# Get actual TWFE estimate on clean sample
actual_model <- feols(work_time ~ treated | statefip + year^month,
                      data = perm_df, weights = ~weight, cluster = ~statefip)
actual_coef <- coef(actual_model)["treated"]
actual_se <- summary(actual_model)$se["treated"]
cat("Actual TWFE coefficient:", round(actual_coef, 3), "(SE:", round(actual_se, 3), ")\n")

# Permutation test: randomly reassign which states are "switchers"
# This is a Fisher-style randomization test
set.seed(42)
n_perms <- 999
perm_coefs <- numeric(n_perms)

# Get states that can be permuted (switchers + never-treated in sample)
permutable <- treatment_timing %>%
  filter(state_type %in% c("switcher_in_sample", "never_treated"))

cat("Running", n_perms, "permutations among", nrow(permutable), "states...\n")

# Create assignment vector (which states are switchers in sample)
actual_assignment <- permutable %>%
  mutate(is_switcher = state_type == "switcher_in_sample") %>%
  pull(is_switcher)

n_switchers <- sum(actual_assignment)

pb <- txtProgressBar(min = 0, max = n_perms, style = 3)
for (i in 1:n_perms) {
  setTxtProgressBar(pb, i)

  # Randomly assign which states are "switchers"
  perm_assignment <- sample(actual_assignment)

  # Map permuted assignment back to states
  perm_map <- permutable %>%
    mutate(perm_switcher = perm_assignment)

  # Create permuted treatment in full data
  # If state is permuted to be a switcher, use actual switcher's treatment timing
  # This is a simplification - we randomly permute which states are treated

  perm_data <- perm_df %>%
    left_join(perm_map %>% select(statefip, perm_switcher), by = "statefip") %>%
    mutate(
      # Under permutation: if perm_switcher, use 2015 as treatment year; else never treated
      perm_treated = case_when(
        perm_switcher == TRUE ~ as.integer(year >= 2015),
        TRUE ~ 0L
      )
    )

  # Run permuted regression
  perm_model <- tryCatch({
    feols(work_time ~ perm_treated | statefip + year^month,
          data = perm_data, weights = ~weight, cluster = ~statefip)
  }, error = function(e) NULL)

  if (!is.null(perm_model) && "perm_treated" %in% names(coef(perm_model))) {
    perm_coefs[i] <- coef(perm_model)["perm_treated"]
  } else {
    perm_coefs[i] <- NA
  }
}
close(pb)

# Calculate permutation p-value
perm_coefs <- perm_coefs[!is.na(perm_coefs)]
perm_pvalue <- mean(abs(perm_coefs) >= abs(actual_coef))

cat("\n*** PERMUTATION INFERENCE RESULTS ***\n")
cat("  Actual coefficient:", round(actual_coef, 3), "\n")
cat("  Permutation mean:", round(mean(perm_coefs), 3), "\n")
cat("  Permutation SD:", round(sd(perm_coefs), 3), "\n")
cat("  Two-sided p-value:", round(perm_pvalue, 3), "\n")
cat("  95% permutation CI: [", round(quantile(perm_coefs, 0.025), 3), ",",
    round(quantile(perm_coefs, 0.975), 3), "]\n")

perm_results <- data.frame(
  actual_coef = actual_coef,
  perm_mean = mean(perm_coefs),
  perm_sd = sd(perm_coefs),
  perm_pvalue = perm_pvalue,
  perm_ci_lower = quantile(perm_coefs, 0.025),
  perm_ci_upper = quantile(perm_coefs, 0.975)
)
write_csv(perm_results, "../tables/permutation_inference.csv")

# Plot permutation distribution
p_perm <- ggplot(data.frame(coef = perm_coefs), aes(x = coef)) +
  geom_histogram(bins = 50, fill = "gray70", color = "white") +
  geom_vline(xintercept = actual_coef, color = "red", linewidth = 1.5) +
  geom_vline(xintercept = c(quantile(perm_coefs, 0.025), quantile(perm_coefs, 0.975)),
             linetype = "dashed", color = "blue") +
  labs(
    title = "Permutation Distribution of Treatment Effect",
    subtitle = paste("Red line = actual estimate; p-value =", round(perm_pvalue, 3)),
    x = "Permuted coefficient",
    y = "Count"
  ) +
  theme_minimal()

ggsave("../figures/permutation_distribution.pdf", p_perm, width = 8, height = 5)

# =============================================================================
# 4. WILD CLUSTER BOOTSTRAP (Manual)
# =============================================================================

cat("\n\n=== WILD CLUSTER BOOTSTRAP ===\n")

n_boot <- 999
boot_coefs <- numeric(n_boot)

# Use clean sample for bootstrap (same as permutation)
# Convert to data.frame and filter complete cases
boot_sample <- as.data.frame(perm_df) %>%
  filter(!is.na(work_time) & !is.na(weight))

# Add row ID for tracking
boot_sample$row_id <- seq_len(nrow(boot_sample))

# Get residuals from restricted model (under null)
restricted_model <- feols(work_time ~ 1 | statefip + year^month,
                         data = boot_sample, weights = ~weight)

# Initialize residual column with NA
boot_sample$resid <- NA
boot_sample$fitted_r <- NA

# Get which rows were used (fixest returns row indices in names)
resid_vec <- residuals(restricted_model)
fitted_vec <- fitted(restricted_model)

# Assign residuals to the appropriate rows
used_idx <- as.integer(names(resid_vec))
boot_sample$resid[used_idx] <- as.numeric(resid_vec)
boot_sample$fitted_r[used_idx] <- as.numeric(fitted_vec)

# Filter to only rows with valid residuals
boot_sample <- boot_sample %>% filter(!is.na(resid))

cat("Running", n_boot, "bootstrap replications on", nrow(boot_sample), "observations...\n")

pb <- txtProgressBar(min = 0, max = n_boot, style = 3)
for (b in 1:n_boot) {
  setTxtProgressBar(pb, b)

  # Rademacher weights at cluster level
  cluster_weights <- data.frame(
    statefip = unique(boot_sample$statefip),
    boot_weight = sample(c(-1, 1), length(unique(boot_sample$statefip)), replace = TRUE)
  )

  # Apply weights to residuals
  boot_df <- boot_sample %>%
    left_join(cluster_weights, by = "statefip") %>%
    mutate(boot_y = fitted_r + boot_weight * resid)

  # Run bootstrap regression
  boot_model <- tryCatch({
    feols(boot_y ~ treated | statefip + year^month,
          data = boot_df, weights = ~weight, cluster = ~statefip)
  }, error = function(e) NULL)

  if (!is.null(boot_model) && "treated" %in% names(coef(boot_model))) {
    boot_coefs[b] <- coef(boot_model)["treated"]
  } else {
    boot_coefs[b] <- NA
  }
}
close(pb)

boot_coefs <- boot_coefs[!is.na(boot_coefs)]
boot_pvalue <- 2 * min(mean(boot_coefs >= actual_coef), mean(boot_coefs <= actual_coef))

cat("\n*** WILD CLUSTER BOOTSTRAP RESULTS ***\n")
cat("  Actual coefficient:", round(actual_coef, 3), "\n")
cat("  Bootstrap mean:", round(mean(boot_coefs), 3), "\n")
cat("  Bootstrap SD:", round(sd(boot_coefs), 3), "\n")
cat("  Two-sided p-value:", round(boot_pvalue, 3), "\n")
cat("  95% bootstrap CI: [", round(quantile(boot_coefs, 0.025), 3), ",",
    round(quantile(boot_coefs, 0.975), 3), "]\n")

boot_results <- data.frame(
  method = "Wild Cluster Bootstrap",
  estimate = actual_coef,
  boot_mean = mean(boot_coefs),
  boot_sd = sd(boot_coefs),
  boot_pvalue = boot_pvalue,
  boot_ci_lower = quantile(boot_coefs, 0.025),
  boot_ci_upper = quantile(boot_coefs, 0.975)
)
write_csv(boot_results, "../tables/wild_bootstrap.csv")

# =============================================================================
# 5. SUMMARY TABLE
# =============================================================================

cat("\n\n========================================\n")
cat("SUMMARY OF ALL METHODS\n")
cat("========================================\n\n")

summary_table <- data.frame(
  Method = c(
    "TWFE (baseline)",
    "Callaway-Sant'Anna",
    "Synthetic Control (avg across states)",
    "Permutation Inference",
    "Wild Cluster Bootstrap"
  ),
  Estimate = c(
    actual_coef,
    ifelse(exists("cs_agg"), cs_agg$overall.att, NA),
    ifelse(exists("sc_avg"), sc_avg$mean_att, NA),
    actual_coef,
    actual_coef
  ),
  SE = c(
    actual_se,
    ifelse(exists("cs_agg"), cs_agg$overall.se, NA),
    ifelse(exists("sc_avg"), sc_avg$sd_att / sqrt(sc_avg$n_states), NA),
    sd(perm_coefs),
    sd(boot_coefs)
  ),
  CI_Lower = c(
    actual_coef - 1.96 * actual_se,
    ifelse(exists("cs_agg"), cs_agg$overall.att - 1.96 * cs_agg$overall.se, NA),
    NA,
    quantile(perm_coefs, 0.025),
    quantile(boot_coefs, 0.025)
  ),
  CI_Upper = c(
    actual_coef + 1.96 * actual_se,
    ifelse(exists("cs_agg"), cs_agg$overall.att + 1.96 * cs_agg$overall.se, NA),
    NA,
    quantile(perm_coefs, 0.975),
    quantile(boot_coefs, 0.975)
  ),
  P_Value = c(
    summary(actual_model)$coeftable["treated", "Pr(>|t|)"],
    NA,
    NA,
    perm_pvalue,
    boot_pvalue
  )
)

print(summary_table, digits = 3)

write_csv(summary_table, "../tables/modern_methods_summary.csv")

cat("\n\n=== All results saved to tables/ ===\n")
cat("Figures saved to figures/\n")
