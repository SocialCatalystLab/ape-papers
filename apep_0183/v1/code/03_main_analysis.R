# =============================================================================
# 03_main_analysis.R
# Difference-in-Discontinuities Analysis of Marijuana Legalization
# =============================================================================

source("00_packages.R")

# Load data
qwi_border <- readRDS(file.path(data_dir, "qwi_border.rds"))
treatment_dates <- readRDS(file.path(data_dir, "treatment_dates.rds"))

cat("=== Data Loaded ===\n")
cat("Observations:", nrow(qwi_border), "\n")
cat("Border pairs:", length(unique(qwi_border$border_pair)), "\n")

# =============================================================================
# 1. MAIN SPECIFICATION: Difference-in-Discontinuities
# =============================================================================

cat("\n=== 1. MAIN DIDISC ESTIMATION ===\n")

# Filter to within bandwidth (100km) and aggregate industry
analysis_sample <- qwi_border %>%
  filter(in_bandwidth, industry == "00") %>%
  mutate(
    # dist_km is already computed (negative = treated side, positive = control)
    dist_km2 = dist_km^2,
    # Interactions for DiDisc
    treat_post = treated * post,
    treat_dist = treated * dist_km,
    treat_post_dist = treated * post * dist_km
  )

cat("Analysis sample (100km bandwidth):", nrow(analysis_sample), "\n")
cat("Counties:", length(unique(analysis_sample$county_fips)), "\n")

# DiDisc specification with border-pair × quarter FE
didisc_main <- feols(
  log_earn_hire ~ treated + post + treat_post +
    dist_km + I(dist_km^2) +
    dist_km:post + I(dist_km^2):post +
    treated:dist_km + treated:I(dist_km^2) +
    treat_post_dist + treated:I(dist_km^2):post |
    border_pair^quarter,
  data = analysis_sample,
  cluster = ~border_pair
)

cat("\n--- DiDisc Main Result (All Borders) ---\n")
summary(didisc_main)

# Extract treatment effect
tau_main <- coef(didisc_main)["treat_post"]
se_main <- sqrt(vcov(didisc_main)["treat_post", "treat_post"])
cat(sprintf("\nTreatment effect (tau): %.4f (SE: %.4f)\n", tau_main, se_main))
cat(sprintf("95%% CI: [%.4f, %.4f]\n", tau_main - 1.96*se_main, tau_main + 1.96*se_main))

# =============================================================================
# 2. EVENT STUDY: Dynamic Effects
# =============================================================================

cat("\n=== 2. EVENT STUDY ===\n")

# Bin event time
analysis_sample <- analysis_sample %>%
  mutate(
    event_bin = case_when(
      event_time < -12 ~ -12,
      event_time > 12 ~ 12,
      TRUE ~ event_time
    ),
    event_bin = factor(event_bin, levels = -12:12)
  )

# Event study with border-pair × quarter FE
event_study <- feols(
  log_earn_hire ~ i(event_bin, treated, ref = -1) +
    dist_km + I(dist_km^2) +
    treated:dist_km + treated:I(dist_km^2) |
    border_pair^quarter,
  data = analysis_sample,
  cluster = ~border_pair
)

cat("\n--- Event Study Coefficients ---\n")
summary(event_study)

# Extract event study coefficients
es_coefs <- as.data.frame(coef(event_study)) %>%
  rownames_to_column("term") %>%
  filter(grepl("event_bin", term)) %>%
  mutate(
    event_time = as.numeric(gsub("event_bin::(-?\\d+):treated", "\\1", term)),
    coef = `coef(event_study)`,
    se = sqrt(diag(vcov(event_study)))[term]
  ) %>%
  select(event_time, coef, se) %>%
  add_row(event_time = -1, coef = 0, se = 0)  # Reference period

# Save event study results
saveRDS(es_coefs, file.path(data_dir, "event_study_results.rds"))

# =============================================================================
# 3. PLACEBO TESTS: Pre-Treatment Discontinuity Changes
# =============================================================================

cat("\n=== 3. PLACEBO TESTS ===\n")

# For each pre-treatment quarter, estimate the "discontinuity change"
# relative to 2 quarters earlier

pre_treatment <- analysis_sample %>%
  filter(event_time < 0, event_time >= -20)

placebo_results <- list()

for (e in seq(-18, -2, by = 2)) {
  # Window: e-2 to e (change in discontinuity)
  window_data <- pre_treatment %>%
    filter(event_time >= e - 2, event_time <= e) %>%
    mutate(
      pseudo_post = event_time == e,
      pseudo_treat_post = treated * pseudo_post
    )

  if (nrow(window_data) < 100) next

  placebo_reg <- tryCatch({
    feols(
      log_earn_hire ~ treated + pseudo_post + pseudo_treat_post +
        dist_km + treated:dist_km |
        border_pair,
      data = window_data,
      cluster = ~border_pair
    )
  }, error = function(e) NULL)

  if (!is.null(placebo_reg)) {
    tau_placebo <- coef(placebo_reg)["pseudo_treat_post"]
    se_placebo <- sqrt(vcov(placebo_reg)["pseudo_treat_post", "pseudo_treat_post"])

    placebo_results[[length(placebo_results) + 1]] <- tibble(
      event_time = e,
      tau = tau_placebo,
      se = se_placebo,
      t_stat = tau_placebo / se_placebo,
      p_value = 2 * pt(-abs(tau_placebo / se_placebo), df = nrow(window_data) - 6)
    )
  }
}

placebo_df <- bind_rows(placebo_results)

cat("\n--- Placebo Results (Pre-Treatment Windows) ---\n")
print(placebo_df)

# Joint F-test of all placebos
cat("\nJoint test of pre-treatment discontinuity changes:\n")
cat(sprintf("Mean placebo effect: %.4f\n", mean(placebo_df$tau)))
cat(sprintf("SD of placebo effects: %.4f\n", sd(placebo_df$tau)))

# Save placebo results
saveRDS(placebo_df, file.path(data_dir, "placebo_results.rds"))

# =============================================================================
# 4. SPATIAL RDD DIAGNOSTIC
# =============================================================================

cat("\n=== 4. SPATIAL RDD DIAGNOSTIC (Post-Treatment Only) ===\n")

post_sample <- analysis_sample %>%
  filter(post)

# RDD at the border (within post period)
rdd_post <- feols(
  log_earn_hire ~ treated + dist_km + I(dist_km^2) +
    treated:dist_km + treated:I(dist_km^2) |
    border_pair + quarter,
  data = post_sample,
  cluster = ~border_pair
)

cat("\n--- Spatial RDD (Post-Treatment) ---\n")
summary(rdd_post)

# McCrary density test at border
cat("\n--- McCrary-Style Density Check ---\n")

density_check <- analysis_sample %>%
  filter(post) %>%
  group_by(treated) %>%
  summarise(
    n = n(),
    mean_dist = mean(dist_to_border),
    .groups = "drop"
  )

print(density_check)

# =============================================================================
# 5. BANDWIDTH SENSITIVITY
# =============================================================================

cat("\n=== 5. BANDWIDTH SENSITIVITY ===\n")

bandwidths <- c(25, 50, 75, 100, 125, 150, 200)
bw_results <- list()

for (bw in bandwidths) {
  bw_sample <- qwi_border %>%
    filter(dist_to_border <= bw, industry == "00") %>%
    mutate(
      # dist_km already exists in data
      treat_post = treated * post
    )

  bw_reg <- tryCatch({
    feols(
      log_earn_hire ~ treated + post + treat_post + dist_km + treated:dist_km |
        border_pair^quarter,
      data = bw_sample,
      cluster = ~border_pair
    )
  }, error = function(e) NULL)

  if (!is.null(bw_reg)) {
    bw_results[[length(bw_results) + 1]] <- tibble(
      bandwidth = bw,
      tau = coef(bw_reg)["treat_post"],
      se = sqrt(vcov(bw_reg)["treat_post", "treat_post"]),
      n_obs = nrow(bw_sample),
      n_counties = n_distinct(bw_sample$county_fips)
    )
  }
}

bw_df <- bind_rows(bw_results)
cat("\n--- Bandwidth Sensitivity ---\n")
print(bw_df)

saveRDS(bw_df, file.path(data_dir, "bandwidth_sensitivity.rds"))

# =============================================================================
# 6. BORDER-BY-BORDER ESTIMATES
# =============================================================================

cat("\n=== 6. BORDER-BY-BORDER HETEROGENEITY ===\n")

border_results <- list()

for (bp in unique(analysis_sample$border_pair)) {
  bp_sample <- analysis_sample %>%
    filter(border_pair == bp)

  if (nrow(bp_sample) < 100) next

  bp_reg <- tryCatch({
    feols(
      log_earn_hire ~ treated + post + treated:post + dist_km + treated:dist_km |
        quarter,
      data = bp_sample,
      cluster = ~county_fips
    )
  }, error = function(e) NULL)

  if (!is.null(bp_reg) && "treated:post" %in% names(coef(bp_reg))) {
    border_results[[length(border_results) + 1]] <- tibble(
      border_pair = bp,
      tau = coef(bp_reg)["treated:post"],
      se = sqrt(vcov(bp_reg)["treated:post", "treated:post"]),
      n_obs = nrow(bp_sample)
    )
  }
}

if (length(border_results) > 0) {
  border_df <- bind_rows(border_results) %>%
    mutate(
      ci_low = tau - 1.96 * se,
      ci_high = tau + 1.96 * se
    )
  cat("\n--- Effects by Border Pair ---\n")
  print(border_df %>% arrange(tau))
  saveRDS(border_df, file.path(data_dir, "border_heterogeneity.rds"))
} else {
  cat("\nNo border pairs with sufficient sample size\n")
  border_df <- tibble()
}

# =============================================================================
# 7. SAVE MAIN RESULTS
# =============================================================================

main_results <- list(
  didisc = didisc_main,
  event_study = event_study,
  tau_main = tau_main,
  se_main = se_main,
  bandwidth_sensitivity = bw_df,
  border_heterogeneity = border_df,
  placebo = placebo_df
)

saveRDS(main_results, file.path(data_dir, "main_results.rds"))

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
cat(sprintf("DiDisc estimate: %.3f (SE: %.3f)\n", tau_main, se_main))
cat(sprintf("95%% CI: [%.3f, %.3f]\n", tau_main - 1.96*se_main, tau_main + 1.96*se_main))
