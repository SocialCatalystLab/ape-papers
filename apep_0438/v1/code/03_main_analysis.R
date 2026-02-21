###############################################################################
# 03_main_analysis.R — Primary spatial RDD and DiDisc estimates
# Paper: Secret Ballots and Women's Political Voice (apep_0438)
###############################################################################

# Source packages from same directory
script_args <- commandArgs(trailingOnly = FALSE)
script_path <- grep("--file=", script_args, value = TRUE)
if (length(script_path) > 0) {
  script_dir_local <- dirname(normalizePath(sub("--file=", "", script_path)))
} else {
  script_dir_local <- getwd()
}
source(file.path(script_dir_local, "00_packages.R"))

cat("\n=== PHASE 3: MAIN ANALYSIS ===\n\n")

# --- Load data ---------------------------------------------------------------
panel       <- readRDS(file.path(data_dir, "panel.rds"))
ar_ai_panel <- readRDS(file.path(data_dir, "ar_ai_panel.rds"))

results <- list()

# ============================================================================
# 1. Descriptive statistics
# ============================================================================
cat("Computing descriptive statistics...\n")

# Summary by border pair and treatment status
desc_stats <- panel %>%
  group_by(border_pair, no_landsgemeinde) %>%
  summarise(
    n_gemeinden = n_distinct(gem_id),
    n_votes     = n_distinct(vote_id),
    mean_yes    = mean(yes_share, na.rm = TRUE),
    sd_yes      = sd(yes_share, na.rm = TRUE),
    mean_turnout = mean(turnout, na.rm = TRUE),
    .groups = "drop"
  )

cat("  Descriptive stats by border pair:\n")
print(as.data.frame(desc_stats))

results$desc_stats <- desc_stats

# ============================================================================
# 2. Cross-sectional Spatial RDD: Pooled post-1997 gender referendums
# ============================================================================
cat("\n--- Cross-sectional RDD: Gender referendums at all borders ---\n")

# Pool across border pairs, restrict to gender-related referendums post-1997
rdd_gender_sample <- panel %>%
  filter(gender_related, votedate >= as.Date("1997-01-01"))

if (nrow(rdd_gender_sample) > 30) {
  # Collapse to Gemeinde-level means (average yes-share across gender votes)
  rdd_gender_gem <- rdd_gender_sample %>%
    group_by(gem_id, signed_dist, border_pair, no_landsgemeinde) %>%
    summarise(
      yes_share = mean(yes_share, na.rm = TRUE),
      turnout   = mean(turnout, na.rm = TRUE),
      n_votes   = n(),
      .groups = "drop"
    )

  cat("  RDD sample (Gemeinde-level):", nrow(rdd_gender_gem), "\n")

  # rdrobust estimation
  rdd_gender <- tryCatch({
    rdrobust(
      y = rdd_gender_gem$yes_share,
      x = rdd_gender_gem$signed_dist,
      c = 0
    )
  }, error = function(e) {
    cat("  rdrobust failed:", e$message, "\n")
    NULL
  })

  if (!is.null(rdd_gender)) {
    cat("\n  === RDD: Gender Referendum Yes-Share ===\n")
    cat("  Estimate:", round(rdd_gender$coef[1], 4), "\n")
    cat("  Robust CI:", round(rdd_gender$ci[3, ], 4), "\n")
    cat("  Robust p:", round(rdd_gender$pv[3], 4), "\n")
    cat("  Bandwidth:", round(rdd_gender$bws[1, 1], 2), "km\n")
    cat("  N (left/right):", rdd_gender$N_h, "\n")
    results$rdd_gender <- rdd_gender
  }
} else {
  cat("  Insufficient gender referendum observations for RDD\n")
}

# ============================================================================
# 3. Cross-sectional RDD: Turnout (all referendums, post-1997)
# ============================================================================
cat("\n--- Cross-sectional RDD: Turnout at all borders ---\n")

rdd_turnout_sample <- panel %>%
  filter(votedate >= as.Date("1997-01-01")) %>%
  group_by(gem_id, signed_dist, border_pair, no_landsgemeinde) %>%
  summarise(
    turnout = mean(turnout, na.rm = TRUE),
    n_votes = n(),
    .groups = "drop"
  )

rdd_turnout <- tryCatch({
  rdrobust(
    y = rdd_turnout_sample$turnout,
    x = rdd_turnout_sample$signed_dist,
    c = 0
  )
}, error = function(e) {
  cat("  rdrobust failed:", e$message, "\n")
  NULL
})

if (!is.null(rdd_turnout)) {
  cat("\n  === RDD: Turnout ===\n")
  cat("  Estimate:", round(rdd_turnout$coef[1], 4), "\n")
  cat("  Robust p:", round(rdd_turnout$pv[3], 4), "\n")
  cat("  Bandwidth:", round(rdd_turnout$bws[1, 1], 2), "km\n")
  results$rdd_turnout <- rdd_turnout
}

# ============================================================================
# 4. DiDisc at AR-AI Border: The Core Test
# ============================================================================
cat("\n--- DiDisc at AR-AI Border ---\n")

# The key identification:
# Pre-1997: Both AR and AI had Landsgemeinde → no discontinuity at border
# Post-1997: AR abolished → discontinuity emerges if institution matters

# 4a. OLS DiDisc (parametric)
cat("  Running OLS DiDisc...\n")

didisc_ols <- tryCatch({
  feols(
    yes_share ~ ar_side * post_abolition + signed_dist +
      I(signed_dist^2) | vote_id,
    data = ar_ai_panel,
    vcov = ~gem_id
  )
}, error = function(e) {
  cat("  feols DiDisc failed:", e$message, "\n")
  # Fallback without FE
  tryCatch({
    feols(
      yes_share ~ ar_side * post_abolition + signed_dist,
      data = ar_ai_panel,
      vcov = ~gem_id
    )
  }, error = function(e2) {
    cat("  Fallback also failed:", e2$message, "\n")
    NULL
  })
})

if (!is.null(didisc_ols)) {
  cat("\n  === DiDisc OLS: AR-AI Border ===\n")
  print(summary(didisc_ols))
  results$didisc_ols <- didisc_ols
}

# 4b. DiDisc for gender-related referendums only
cat("\n  Running DiDisc for gender referendums only...\n")

ar_ai_gender <- ar_ai_panel %>% filter(gender_related)
cat("  Gender referendum obs in AR-AI:", nrow(ar_ai_gender), "\n")

if (nrow(ar_ai_gender) > 10) {
  didisc_gender <- tryCatch({
    feols(
      yes_share ~ ar_side * post_abolition + signed_dist | vote_id,
      data = ar_ai_gender,
      vcov = ~gem_id
    )
  }, error = function(e) {
    feols(
      yes_share ~ ar_side * post_abolition + signed_dist,
      data = ar_ai_gender,
      vcov = ~gem_id
    )
  })

  if (!is.null(didisc_gender)) {
    cat("\n  === DiDisc: Gender Referendums at AR-AI ===\n")
    print(summary(didisc_gender))
    results$didisc_gender <- didisc_gender
  }
}

# 4c. Pre-1997 placebo: should show NO discontinuity
cat("\n  Running pre-1997 placebo at AR-AI border...\n")

pre_1997 <- ar_ai_panel %>% filter(!post_abolition)
cat("  Pre-1997 observations:", nrow(pre_1997), "\n")

if (nrow(pre_1997) > 20) {
  pre_1997_gem <- pre_1997 %>%
    group_by(gem_id, signed_dist, ar_side) %>%
    summarise(yes_share = mean(yes_share, na.rm = TRUE), .groups = "drop")

  placebo_pre <- tryCatch({
    rdrobust(
      y = pre_1997_gem$yes_share,
      x = pre_1997_gem$signed_dist,
      c = 0
    )
  }, error = function(e) {
    cat("  rdrobust placebo failed:", e$message, "\n")
    NULL
  })

  if (!is.null(placebo_pre)) {
    cat("\n  === Pre-1997 Placebo: Should be NULL ===\n")
    cat("  Estimate:", round(placebo_pre$coef[1], 4), "\n")
    cat("  Robust p:", round(placebo_pre$pv[3], 4), "\n")
    results$placebo_pre <- placebo_pre
  }
}

# ============================================================================
# 5. Non-parametric DiDisc: RDD separately for pre and post periods
# ============================================================================
cat("\n--- Non-parametric DiDisc ---\n")

# RDD on post-1997 data
post_1997 <- ar_ai_panel %>% filter(post_abolition)
post_1997_gem <- post_1997 %>%
  group_by(gem_id, signed_dist, ar_side) %>%
  summarise(yes_share = mean(yes_share, na.rm = TRUE), .groups = "drop")

rdd_post <- tryCatch({
  rdrobust(
    y = post_1997_gem$yes_share,
    x = post_1997_gem$signed_dist,
    c = 0
  )
}, error = function(e) {
  cat("  Post-1997 RDD failed:", e$message, "\n")
  NULL
})

if (!is.null(rdd_post)) {
  cat("  Post-1997 RDD estimate:", round(rdd_post$coef[1], 4),
      "p =", round(rdd_post$pv[3], 4), "\n")
  results$rdd_post <- rdd_post
}

# ============================================================================
# 6. Placebo: Military/Tax referendums (should show NO effect)
# ============================================================================
cat("\n--- Placebo: Non-gender referendums ---\n")

if ("topic_type" %in% names(panel)) {
  placebo_topics <- panel %>%
    filter(border_pair == "AR-AI",
           topic_type %in% c("military", "tax"),
           votedate >= as.Date("1997-01-01")) %>%
    group_by(gem_id, signed_dist, no_landsgemeinde) %>%
    summarise(yes_share = mean(yes_share, na.rm = TRUE), .groups = "drop")

  if (nrow(placebo_topics) > 15) {
    rdd_placebo <- tryCatch({
      rdrobust(
        y = placebo_topics$yes_share,
        x = placebo_topics$signed_dist,
        c = 0
      )
    }, error = function(e) NULL)

    if (!is.null(rdd_placebo)) {
      cat("  Placebo (military/tax) estimate:", round(rdd_placebo$coef[1], 4),
          "p =", round(rdd_placebo$pv[3], 4), "\n")
      results$rdd_placebo <- rdd_placebo
    }
  } else {
    cat("  Insufficient placebo referendum observations\n")
  }
}

# ============================================================================
# 7. Save results
# ============================================================================
saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("\n✓ Main analysis complete. Results saved.\n")
