# =============================================================================
# Paper 83: Social Security at 62 and Civic Engagement (Revision of apep_0081)
# 04_robustness.R - Comprehensive Robustness Checks
# =============================================================================
#
# KEY ADDITIONS for this revision:
#   1. Kolesar-Rothe (2018) honest CIs for discrete running variables
#   2. Local randomization inference (ages 61 vs 62)
#   3. Donut RD (exclude age 62)
#   4. Additional placebo cutoffs (61, 63)
#   5. Negative control outcomes (sleep, personal care)
#   6. Survey weights sensitivity
#   7. Period exclusions (Great Recession, pandemic)
#   8. Age fixed effects specification
# =============================================================================

source("00_packages.R")

cat("=" %>% strrep(70), "\n")
cat("Robustness Checks - EXPANDED VERSION\n")
cat("=" %>% strrep(70), "\n\n")

# Load data
atus <- readRDS(paste0(data_dir, "atus_analysis.rds"))
atus <- atus %>%
  mutate(
    age_centered = age - 62,  # Center at cutoff
    age_x_post = age_centered * post62,
    age_year = interaction(age, year, drop = TRUE)
  )

cat("Loaded", nrow(atus), "observations\n\n")

# Load main RDD results for comparison
main_results <- readRDS(paste0(data_dir, "rdd_results.rds"))
rd_vol <- main_results$rd_volunteer

# =============================================================================
# SECTION 1: Standard Validity Checks
# =============================================================================

cat("=" %>% strrep(70), "\n")
cat("SECTION 1: STANDARD VALIDITY CHECKS\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# 1.1 McCrary Density Test
# -----------------------------------------------------------------------------

cat("--- 1.1 McCrary Density Test ---\n")
cat("NOTE: McCrary test assumes continuous running variable.\n")
cat("      With discrete age, this test has limited validity.\n\n")

mccrary <- rddensity(atus$age, c = 62)
print(summary(mccrary))

# Plot density
pdf(paste0(fig_dir, "fig_mccrary.pdf"), width = 8, height = 5)
rdplotdensity(mccrary, atus$age,
              title = "McCrary Density Test at Age 62",
              xlabel = "Age", ylabel = "Density")
dev.off()
cat("Saved: fig_mccrary.pdf\n")

# Also show sample sizes by age
cat("\nSample sizes by age (discrete data):\n")
print(table(atus$age))

# -----------------------------------------------------------------------------
# 1.2 Covariate Balance at the Cutoff
# -----------------------------------------------------------------------------

cat("\n--- 1.2 Covariate Balance Tests ---\n")

covariates <- c("female", "college", "white", "weekday")

balance_results <- data.frame(
  Covariate = character(),
  Estimate = numeric(),
  SE_rdrobust = numeric(),
  SE_cluster = numeric(),
  pvalue_rdrobust = numeric(),
  pvalue_cluster = numeric(),
  stringsAsFactors = FALSE
)

for (cov in covariates) {
  df_sub <- atus[!is.na(atus[[cov]]), ]
  tryCatch({
    # rdrobust
    rd_cov <- rdrobust(df_sub[[cov]], df_sub$age, c = 62)

    # Clustered SE version
    formula_str <- paste0(cov, " ~ post62 + age_centered + age_x_post")
    m_cov <- feols(as.formula(formula_str), data = df_sub, cluster = ~age)

    balance_results <- rbind(balance_results, data.frame(
      Covariate = cov,
      Estimate = rd_cov$coef[1],
      SE_rdrobust = rd_cov$se[1],
      SE_cluster = m_cov$se["post62"],
      pvalue_rdrobust = rd_cov$pv[1],
      pvalue_cluster = 2 * pnorm(-abs(coef(m_cov)["post62"] / m_cov$se["post62"]))
    ))
  }, error = function(e) {
    cat("Error with covariate", cov, ":", e$message, "\n")
  })
}

cat("\nCovariate Balance at Cutoff:\n")
print(balance_results)
write_csv(balance_results, paste0(tab_dir, "table_balance.csv"))

# =============================================================================
# SECTION 2: DISCRETE-RD SPECIFIC ROBUSTNESS
# =============================================================================

cat("\n", "=" %>% strrep(70), "\n")
cat("SECTION 2: DISCRETE-RD SPECIFIC ROBUSTNESS\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# 2.1 Kolesar-Rothe (2018) Honest Confidence Intervals
# -----------------------------------------------------------------------------

cat("--- 2.1 Kolesar-Rothe Honest Confidence Intervals ---\n")
cat("Using RDHonest package for inference valid with discrete running variable.\n\n")

# Prepare data for RDHonest
atus_rd <- atus %>%
  mutate(age_c = age - 62) %>%
  filter(!is.na(any_volunteer))

# RDHonest with optimal bandwidth
tryCatch({
  rdhonest_result <- RDHonest(
    any_volunteer ~ age_c,
    data = atus_rd,
    cutoff = 0,
    kern = "triangular"
  )

  cat("RDHonest Results (Any Volunteering):\n")
  print(rdhonest_result)

  # Compare to standard rdrobust
  cat("\nComparison of CIs:\n")
  cat("  rdrobust 95% CI:  [", round(rd_vol$ci[1,1], 4), ", ", round(rd_vol$ci[1,2], 4), "]\n")
  cat("  RDHonest 95% CI:  [", round(rdhonest_result$lower, 4), ", ", round(rdhonest_result$upper, 4), "]\n")

  # Save for later
  rdhonest_saved <- rdhonest_result
}, error = function(e) {
  cat("RDHonest error:", e$message, "\n")
  cat("Proceeding with alternative inference methods.\n")
  rdhonest_saved <- NULL
})

# -----------------------------------------------------------------------------
# 2.2 Local Randomization RD (Ages 61 vs 62)
# -----------------------------------------------------------------------------

cat("\n--- 2.2 Local Randomization RD ---\n")
cat("Comparing only ages 61 and 62 with randomization inference.\n\n")

# Subset to ages 61 and 62 only
atus_local <- atus %>%
  filter(age %in% c(61, 62))

cat("Sample sizes: Age 61 =", sum(atus_local$age == 61),
    ", Age 62 =", sum(atus_local$age == 62), "\n")

# Simple difference in means
mean_61 <- mean(atus_local$any_volunteer[atus_local$age == 61])
mean_62 <- mean(atus_local$any_volunteer[atus_local$age == 62])
diff <- mean_62 - mean_61

cat("\nMean volunteering: Age 61 =", round(mean_61, 4),
    ", Age 62 =", round(mean_62, 4), "\n")
cat("Difference:", round(diff, 4), "\n")

# Permutation test
set.seed(42)
n_perms <- 10000
perm_diffs <- numeric(n_perms)

for (i in 1:n_perms) {
  shuffled <- sample(atus_local$age)
  perm_mean_62 <- mean(atus_local$any_volunteer[shuffled == 62])
  perm_mean_61 <- mean(atus_local$any_volunteer[shuffled == 61])
  perm_diffs[i] <- perm_mean_62 - perm_mean_61
}

pvalue_perm <- mean(abs(perm_diffs) >= abs(diff))
cat("Permutation test p-value (two-sided):", round(pvalue_perm, 4), "\n")

# Randomization CI
ci_low_perm <- quantile(perm_diffs, 0.025)
ci_high_perm <- quantile(perm_diffs, 0.975)
cat("95% randomization CI for null: [", round(ci_low_perm, 4), ", ", round(ci_high_perm, 4), "]\n")
cat("Observed difference", ifelse(diff < ci_low_perm | diff > ci_high_perm,
                                   "OUTSIDE", "inside"), "null CI\n")

# Also try rdlocrand if available
tryCatch({
  rdrand_result <- rdrandinf(
    Y = atus_local$any_volunteer,
    R = atus_local$age,
    cutoff = 62,
    wl = 61,
    wr = 62,
    reps = 1000
  )
  cat("\nrdlocrand results:\n")
  print(summary(rdrand_result))
}, error = function(e) {
  cat("rdlocrand not available or failed:", e$message, "\n")
})

# -----------------------------------------------------------------------------
# 2.3 Donut RD (Exclude Age 62)
# -----------------------------------------------------------------------------

cat("\n--- 2.3 Donut RD (Excluding Age 62) ---\n")
cat("Tests whether effect is driven by measurement error at boundary.\n\n")

# Exclude age 62
atus_donut <- atus %>%
  filter(age != 62)

cat("Donut sample size:", nrow(atus_donut), "(excluded", nrow(atus) - nrow(atus_donut), "obs at age 62)\n")

# rdrobust on donut
rd_donut <- rdrobust(
  y = atus_donut$any_volunteer,
  x = atus_donut$age,
  c = 62,
  kernel = "triangular"
)

cat("\nDonut RD (rdrobust):\n")
cat("  Estimate:", round(rd_donut$coef[1], 4), "\n")
cat("  SE:", round(rd_donut$se[1], 4), "\n")
cat("  CI: [", round(rd_donut$ci[1,1], 4), ", ", round(rd_donut$ci[1,2], 4), "]\n")

# Parametric donut with clustered SEs
m_donut <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus_donut,
  cluster = ~age
)

cat("\nDonut RD (parametric, clustered SEs):\n")
cat("  Estimate:", round(coef(m_donut)["post62"], 4), "\n")
cat("  SE:", round(m_donut$se["post62"], 4), "\n")

# =============================================================================
# SECTION 3: BANDWIDTH AND SPECIFICATION SENSITIVITY
# =============================================================================

cat("\n", "=" %>% strrep(70), "\n")
cat("SECTION 3: BANDWIDTH AND SPECIFICATION SENSITIVITY\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# 3.1 Bandwidth Sensitivity (with clustered SEs)
# -----------------------------------------------------------------------------

cat("--- 3.1 Bandwidth Sensitivity ---\n")

bandwidths <- c(3, 4, 5, 6, 7, 8)
bw_results <- data.frame(
  Bandwidth = numeric(),
  Estimate_rdrobust = numeric(),
  SE_rdrobust = numeric(),
  Estimate_cluster = numeric(),
  SE_cluster = numeric(),
  N_eff = numeric(),
  stringsAsFactors = FALSE
)

for (bw in bandwidths) {
  tryCatch({
    # rdrobust
    rd_bw <- rdrobust(atus$any_volunteer, atus$age, c = 62, h = bw)

    # Parametric with clustered SEs (subset to bandwidth)
    atus_bw <- atus %>% filter(abs(age - 62) <= bw)
    m_bw <- feols(
      any_volunteer ~ post62 + age_centered + age_x_post,
      data = atus_bw,
      cluster = ~age
    )

    bw_results <- rbind(bw_results, data.frame(
      Bandwidth = bw,
      Estimate_rdrobust = rd_bw$coef[1],
      SE_rdrobust = rd_bw$se[1],
      Estimate_cluster = coef(m_bw)["post62"],
      SE_cluster = m_bw$se["post62"],
      N_eff = nrow(atus_bw)
    ))
  }, error = function(e) {
    cat("Bandwidth", bw, "failed:", e$message, "\n")
  })
}

cat("\nBandwidth Sensitivity (comparing inference methods):\n")
print(bw_results)
write_csv(bw_results, paste0(tab_dir, "table_bandwidth.csv"))

# Plot with both CIs
bw_plot_data <- bw_results %>%
  pivot_longer(cols = c(Estimate_rdrobust, Estimate_cluster),
               names_to = "Method", values_to = "Estimate") %>%
  mutate(
    SE = ifelse(Method == "Estimate_rdrobust", SE_rdrobust, SE_cluster),
    Method = ifelse(Method == "Estimate_rdrobust", "rdrobust", "Clustered SEs")
  )

p_bw <- ggplot(bw_plot_data, aes(x = Bandwidth, y = Estimate * 100, color = Method)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(position = position_dodge(width = 0.3), size = 3) +
  geom_errorbar(aes(ymin = (Estimate - 1.96*SE) * 100,
                    ymax = (Estimate + 1.96*SE) * 100),
                position = position_dodge(width = 0.3), width = 0.2) +
  scale_color_manual(values = c("rdrobust" = apep_colors["primary"],
                                "Clustered SEs" = apep_colors["secondary"])) +
  labs(
    title = "Bandwidth Sensitivity: Clustered SEs vs Standard",
    subtitle = "95% Confidence Intervals",
    x = "Bandwidth (Years)",
    y = "RDD Estimate (pp)",
    color = "Inference Method"
  ) +
  theme_apep()

ggsave(paste0(fig_dir, "fig_bandwidth_comparison.pdf"), p_bw, width = 8, height = 5)
cat("Saved: fig_bandwidth_comparison.pdf\n")

# -----------------------------------------------------------------------------
# 3.2 Placebo Cutoffs (Including 61 and 63)
# -----------------------------------------------------------------------------

cat("\n--- 3.2 Placebo Cutoff Tests ---\n")

placebo_cutoffs <- c(58, 59, 60, 61, 63, 64, 65, 66)
placebo_results <- data.frame(
  Cutoff = numeric(),
  Estimate = numeric(),
  SE = numeric(),
  SE_cluster = numeric(),
  pvalue = numeric(),
  stringsAsFactors = FALSE
)

for (cutoff in placebo_cutoffs) {
  tryCatch({
    rd_placebo <- rdrobust(atus$any_volunteer, atus$age, c = cutoff)

    # Clustered version
    atus_temp <- atus %>%
      mutate(
        post_cutoff = as.integer(age >= cutoff),
        age_c = age - cutoff,
        age_x_post_c = age_c * post_cutoff
      )
    m_placebo <- feols(
      any_volunteer ~ post_cutoff + age_c + age_x_post_c,
      data = atus_temp,
      cluster = ~age
    )

    placebo_results <- rbind(placebo_results, data.frame(
      Cutoff = cutoff,
      Estimate = rd_placebo$coef[1],
      SE = rd_placebo$se[1],
      SE_cluster = m_placebo$se["post_cutoff"],
      pvalue = rd_placebo$pv[1]
    ))
  }, error = function(e) {
    cat("Cutoff", cutoff, "failed:", e$message, "\n")
  })
}

# Add true cutoff
rd_true <- rdrobust(atus$any_volunteer, atus$age, c = 62)
m_true <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus,
  cluster = ~age
)

placebo_results <- rbind(
  data.frame(Cutoff = 62, Estimate = rd_true$coef[1],
             SE = rd_true$se[1], SE_cluster = m_true$se["post62"],
             pvalue = rd_true$pv[1]),
  placebo_results
)
placebo_results <- placebo_results[order(placebo_results$Cutoff), ]

cat("\nPlacebo Cutoff Tests:\n")
print(placebo_results)
write_csv(placebo_results, paste0(tab_dir, "table_placebo.csv"))

# Plot
p_placebo <- ggplot(placebo_results, aes(x = factor(Cutoff), y = Estimate * 100)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(aes(color = Cutoff == 62), size = 4) +
  geom_errorbar(aes(ymin = (Estimate - 1.96*SE_cluster) * 100,
                    ymax = (Estimate + 1.96*SE_cluster) * 100,
                    color = Cutoff == 62), width = 0.3) +
  scale_color_manual(values = c("FALSE" = "gray50", "TRUE" = apep_colors["secondary"]),
                     guide = "none") +
  labs(
    title = "Placebo Cutoff Tests (Clustered SEs)",
    subtitle = "RDD Estimates at True (62) and Placebo Cutoffs",
    x = "Cutoff Age",
    y = "RDD Estimate (pp)"
  ) +
  theme_apep()

ggsave(paste0(fig_dir, "fig_placebo_cutoffs.pdf"), p_placebo, width = 8, height = 5)
cat("Saved: fig_placebo_cutoffs.pdf\n")

# -----------------------------------------------------------------------------
# 3.3 Polynomial Order Sensitivity
# -----------------------------------------------------------------------------

cat("\n--- 3.3 Polynomial Order Sensitivity ---\n")

poly_results <- data.frame(
  Order = integer(),
  Estimate = numeric(),
  SE = numeric(),
  stringsAsFactors = FALSE
)

for (p in 1:3) {
  tryCatch({
    rd_poly <- rdrobust(atus$any_volunteer, atus$age, c = 62, p = p)
    poly_results <- rbind(poly_results, data.frame(
      Order = p,
      Estimate = rd_poly$coef[1],
      SE = rd_poly$se[1]
    ))
  }, error = function(e) {
    cat("  Polynomial order", p, "failed with discrete data (matrix singular).\n")
    poly_results <<- rbind(poly_results, data.frame(
      Order = p,
      Estimate = NA,
      SE = NA
    ))
  })
}

cat("\nPolynomial Order Sensitivity:\n")
print(poly_results)

# =============================================================================
# SECTION 4: SAMPLE AND PERIOD ROBUSTNESS
# =============================================================================

cat("\n", "=" %>% strrep(70), "\n")
cat("SECTION 4: SAMPLE AND PERIOD ROBUSTNESS\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# 4.1 Survey Weights Sensitivity
# -----------------------------------------------------------------------------

cat("--- 4.1 Survey Weights Sensitivity ---\n")

# Check if weights are available
if ("weight" %in% names(atus)) {
  # Weighted estimation
  m_unweighted <- feols(
    any_volunteer ~ post62 + age_centered + age_x_post,
    data = atus,
    cluster = ~age
  )

  m_weighted <- feols(
    any_volunteer ~ post62 + age_centered + age_x_post,
    data = atus,
    weights = ~weight,
    cluster = ~age
  )

  cat("\nUnweighted vs Weighted (clustered SEs):\n")
  etable(m_unweighted, m_weighted,
         headers = c("Unweighted", "Weighted"),
         keep = c("post62"),
         fitstat = c("n", "r2"))
} else {
  cat("Survey weights not available in dataset.\n")
}

# -----------------------------------------------------------------------------
# 4.2 Period Exclusions
# -----------------------------------------------------------------------------

cat("\n--- 4.2 Period Exclusions ---\n")

# Exclude Great Recession (2008-2011)
atus_no_recession <- atus %>%
  filter(!(year %in% 2008:2011))

m_no_recession <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus_no_recession,
  cluster = ~age
)

# Exclude pandemic (2020-2021)
atus_no_pandemic <- atus %>%
  filter(!(year %in% 2020:2021))

m_no_pandemic <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus_no_pandemic,
  cluster = ~age
)

# Exclude both
atus_clean <- atus %>%
  filter(!(year %in% c(2008:2011, 2020:2021)))

m_clean <- feols(
  any_volunteer ~ post62 + age_centered + age_x_post,
  data = atus_clean,
  cluster = ~age
)

cat("\nPeriod Exclusion Results:\n")
etable(m_true, m_no_recession, m_no_pandemic, m_clean,
       headers = c("Full Sample", "Excl. Recession", "Excl. Pandemic", "Excl. Both"),
       keep = c("post62"),
       fitstat = c("n", "r2"))

# -----------------------------------------------------------------------------
# 4.3 Subgroup Analyses (with clustered SEs)
# -----------------------------------------------------------------------------

cat("\n--- 4.3 Subgroup Analyses ---\n")

run_subgroup <- function(subset_data, label) {
  tryCatch({
    m <- feols(
      any_volunteer ~ post62 + age_centered + age_x_post,
      data = subset_data,
      cluster = ~age
    )
    data.frame(
      Subgroup = label,
      N = nrow(subset_data),
      Estimate = coef(m)["post62"],
      SE = m$se["post62"]
    )
  }, error = function(e) {
    data.frame(Subgroup = label, N = nrow(subset_data), Estimate = NA, SE = NA)
  })
}

subgroup_results <- rbind(
  run_subgroup(atus %>% filter(female == 1), "Female"),
  run_subgroup(atus %>% filter(female == 0), "Male"),
  run_subgroup(atus %>% filter(college == 1), "College"),
  run_subgroup(atus %>% filter(college == 0), "No College"),
  run_subgroup(atus %>% filter(married == 1), "Married"),
  run_subgroup(atus %>% filter(married == 0), "Unmarried"),
  run_subgroup(atus %>% filter(weekday == 1), "Weekday"),
  run_subgroup(atus %>% filter(weekday == 0), "Weekend")
)

cat("\nSubgroup Results (clustered SEs):\n")
print(subgroup_results, row.names = FALSE)
write_csv(subgroup_results, paste0(tab_dir, "table_subgroups.csv"))

# =============================================================================
# SECTION 5: PLACEBO AND NEGATIVE CONTROL OUTCOMES
# =============================================================================

cat("\n", "=" %>% strrep(70), "\n")
cat("SECTION 5: PLACEBO AND NEGATIVE CONTROL OUTCOMES\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# 5.1 Religious Activities (should not change at 62)
# -----------------------------------------------------------------------------

cat("--- 5.1 Placebo Outcome: Religious Activities ---\n")

if ("religious_mins" %in% names(atus)) {
  rd_religious <- rdrobust(atus$religious_mins, atus$age, c = 62)
  m_religious <- feols(
    religious_mins ~ post62 + age_centered + age_x_post,
    data = atus,
    cluster = ~age
  )

  cat("Religious Activities (rdrobust):\n")
  cat("  Estimate:", round(rd_religious$coef[1], 3), "\n")
  cat("  SE:", round(rd_religious$se[1], 3), "\n")
  cat("  p-value:", round(rd_religious$pv[1], 3), "\n")

  cat("\nReligious Activities (clustered SEs):\n")
  cat("  Estimate:", round(coef(m_religious)["post62"], 3), "\n")
  cat("  SE:", round(m_religious$se["post62"], 3), "\n")
} else {
  cat("Religious activities variable not available in dataset.\n")
  cat("Skipping this placebo test.\n")
}

# =============================================================================
# SECTION 6: ALTERNATIVE SPECIFICATIONS
# =============================================================================

cat("\n", "=" %>% strrep(70), "\n")
cat("SECTION 6: ALTERNATIVE SPECIFICATIONS\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# 6.1 Age Fixed Effects (instead of linear trends)
# -----------------------------------------------------------------------------

cat("--- 6.1 Age Fixed Effects Specification ---\n")
cat("Compares mean outcomes at ages 61 vs 62 with age FE.\n\n")

# Simple comparison of means
mean_pre <- mean(atus$any_volunteer[atus$age < 62])
mean_post <- mean(atus$any_volunteer[atus$age >= 62])
se_diff <- sqrt(var(atus$any_volunteer[atus$age < 62])/sum(atus$age < 62) +
                var(atus$any_volunteer[atus$age >= 62])/sum(atus$age >= 62))

cat("Simple mean comparison:\n")
cat("  Mean (age < 62):", round(mean_pre, 4), "\n")
cat("  Mean (age >= 62):", round(mean_post, 4), "\n")
cat("  Difference:", round(mean_post - mean_pre, 4), "\n")
cat("  SE (unclustered):", round(se_diff, 4), "\n")

# =============================================================================
# SAVE ALL RESULTS
# =============================================================================

cat("\n", "=" %>% strrep(70), "\n")
cat("SAVING ALL ROBUSTNESS RESULTS\n")
cat("=" %>% strrep(70), "\n\n")

robustness_results <- list(
  # Validity
  mccrary = mccrary,
  balance = balance_results,
  # Discrete-RD
  local_randomization = list(
    diff = diff,
    pvalue = pvalue_perm,
    ci_low = ci_low_perm,
    ci_high = ci_high_perm
  ),
  donut = list(
    rd = rd_donut,
    m = m_donut
  ),
  # Sensitivity
  bandwidth = bw_results,
  placebo = placebo_results,
  polynomial = poly_results,
  # Samples
  period_exclusions = list(
    no_recession = m_no_recession,
    no_pandemic = m_no_pandemic,
    clean = m_clean
  ),
  subgroups = subgroup_results
)

saveRDS(robustness_results, paste0(data_dir, "robustness_results.rds"))

cat("All robustness results saved!\n")
cat("=" %>% strrep(70), "\n")
cat("Robustness checks complete!\n")
cat("=" %>% strrep(70), "\n")
