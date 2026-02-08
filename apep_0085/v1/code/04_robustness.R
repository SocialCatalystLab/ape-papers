## 04_robustness.R — Robustness checks for DiD analysis
## Paper 109: Must-Access PDMP Mandates and Employment
##
## Checks:
##   1. Bacon decomposition of TWFE
##   2. Sun-Abraham event study
##   3. CS-DiD with not-yet-treated control group
##   4. Placebo timing test (shift treatment back 3 years)
##   5. Leave-one-out: drop each early adopter state (first_treat <= 2014)

source("00_packages.R")

data_dir <- "../data"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("=== ROBUSTNESS CHECKS ===\n")
cat(sprintf("Panel: %d state-years, %d states, %d-%d\n",
            nrow(panel), n_distinct(panel$statefip),
            min(panel$year), max(panel$year)))
cat(sprintf("Treated states: %d, Never-treated: %d\n",
            n_distinct(panel$statefip[panel$ever_treated == 1]),
            n_distinct(panel$statefip[panel$ever_treated == 0])))

###############################################################################
## 1. Bacon Decomposition of TWFE
###############################################################################

cat("\n========================================\n")
cat("1. BACON DECOMPOSITION OF TWFE\n")
cat("========================================\n")

# bacondecomp::bacon() requires a balanced panel data.frame with:
#   formula: outcome ~ treatment (binary 0/1)
#   id_var: unit identifier
#   time_var: time identifier

bacon_out <- bacon(
  log_emp ~ treated,
  data = as.data.frame(panel),
  id_var = "statefip",
  time_var = "year"
)

cat("\nBacon decomposition summary:\n")
print(summary(bacon_out))

# Aggregate by comparison type
bacon_summary <- bacon_out %>%
  group_by(type) %>%
  summarise(
    n_pairs      = n(),
    avg_estimate = weighted.mean(estimate, weight),
    total_weight = sum(weight),
    min_estimate = min(estimate),
    max_estimate = max(estimate),
    .groups = "drop"
  ) %>%
  arrange(desc(total_weight))

cat("\nBacon decomposition by comparison type:\n")
print(as.data.frame(bacon_summary), row.names = FALSE)

# Overall TWFE estimate implied by the decomposition
bacon_twfe <- sum(bacon_out$estimate * bacon_out$weight)
cat(sprintf("\nBacon-implied TWFE estimate: %.4f\n", bacon_twfe))

# Flag problematic comparisons (later-vs-earlier treated)
if ("Later vs Earlier Treated" %in% bacon_summary$type) {
  lve <- bacon_summary %>% filter(type == "Later vs Earlier Treated")
  cat(sprintf("Note: Later-vs-Earlier weight = %.3f (estimate = %.4f)\n",
              lve$total_weight, lve$avg_estimate))
  cat("  These comparisons can produce bias under heterogeneous treatment effects.\n")
}

saveRDS(bacon_out, file.path(data_dir, "bacon_decomp.rds"))
saveRDS(bacon_summary, file.path(data_dir, "bacon_summary.rds"))

cat("Saved: bacon_decomp.rds, bacon_summary.rds\n")

###############################################################################
## 2. Sun-Abraham Event Study — REMOVED
## (Sun-Abraham estimator removed from paper due to aggregation issues
## with thin never-treated reference group)
###############################################################################

cat("\n========================================\n")
cat("2. SUN-ABRAHAM EVENT STUDY — SKIPPED (removed from paper)\n")
cat("========================================\n")

###############################################################################
## 3. CS-DiD with Not-Yet-Treated Control Group
###############################################################################

cat("\n========================================\n")
cat("3. CS-DiD WITH NOT-YET-TREATED CONTROL GROUP\n")
cat("========================================\n")

# Main specification used control_group = "nevertreated".
# Robustness: use "notyettreated" which expands the comparison group
# to include units not yet treated at each calendar period.

cs_nyt <- att_gt(
  yname = "log_emp",
  tname = "year",
  idname = "statefip",
  gname = "first_treat",
  data = as.data.frame(panel),
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  anticipation = 1
)

att_nyt_overall <- aggte(cs_nyt, type = "simple")
att_nyt_dynamic <- aggte(cs_nyt, type = "dynamic", min_e = -6, max_e = 6)

cat(sprintf("\nCS-DiD (not-yet-treated) Overall ATT: %.4f (SE: %.4f)\n",
            att_nyt_overall$overall.att, att_nyt_overall$overall.se))
cat(sprintf("  95%% CI: [%.4f, %.4f]\n",
            att_nyt_overall$overall.att - 1.96 * att_nyt_overall$overall.se,
            att_nyt_overall$overall.att + 1.96 * att_nyt_overall$overall.se))

# Compare with main specification
att_main <- readRDS(file.path(data_dir, "att_overall_log_emp.rds"))
cat(sprintf("\nComparison with main specification:\n"))
cat(sprintf("  Never-treated control:     ATT = %.4f (SE = %.4f)\n",
            att_main$overall.att, att_main$overall.se))
cat(sprintf("  Not-yet-treated control:   ATT = %.4f (SE = %.4f)\n",
            att_nyt_overall$overall.att, att_nyt_overall$overall.se))
cat(sprintf("  Difference:                %.4f\n",
            att_nyt_overall$overall.att - att_main$overall.att))

# Dynamic ATT detail
cat("\nDynamic ATT (not-yet-treated):\n")
nyt_dyn_df <- data.frame(
  event_time = att_nyt_dynamic$egt,
  att        = att_nyt_dynamic$att.egt,
  se         = att_nyt_dynamic$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    sig      = ifelse(abs(att / se) > 1.96, "*", "")
  )
print(as.data.frame(nyt_dyn_df), row.names = FALSE)

saveRDS(cs_nyt, file.path(data_dir, "cs_nyt_log_emp.rds"))
saveRDS(att_nyt_overall, file.path(data_dir, "att_nyt_overall.rds"))
saveRDS(att_nyt_dynamic, file.path(data_dir, "att_nyt_dynamic.rds"))

cat("Saved: cs_nyt_log_emp.rds, att_nyt_overall.rds, att_nyt_dynamic.rds\n")

###############################################################################
## 4. Placebo Timing Test (shift treatment dates back 3 years)
###############################################################################

cat("\n========================================\n")
cat("4. PLACEBO TIMING TEST (TREATMENT SHIFTED BACK 3 YEARS)\n")
cat("========================================\n")

# Create placebo treatment dates by shifting actual treatment back 3 years.
# To avoid contamination from the real treatment, restrict the sample to
# observations that fall before each unit's actual treatment year.
# Never-treated states retain all observations.

panel_placebo <- panel %>%
  mutate(
    first_treat_placebo = ifelse(first_treat > 0, first_treat - 3, 0),
    treated_placebo     = as.integer(first_treat_placebo > 0 & year >= first_treat_placebo)
  )

# Drop post-actual-treatment observations for treated units
panel_placebo_clean <- panel_placebo %>%
  filter(first_treat == 0 | year < first_treat)

cat(sprintf("Placebo panel: %d obs (dropped %d post-actual-treatment obs)\n",
            nrow(panel_placebo_clean),
            nrow(panel_placebo) - nrow(panel_placebo_clean)))

placebo_min_year <- min(panel_placebo_clean$year)
placebo_earliest_treat <- min(panel_placebo_clean$first_treat_placebo[
  panel_placebo_clean$first_treat_placebo > 0])
cat(sprintf("Placebo treatment years: %d to %d\n",
            placebo_earliest_treat,
            max(panel_placebo_clean$first_treat_placebo[
              panel_placebo_clean$first_treat_placebo > 0])))
cat(sprintf("Earliest placebo treatment: %d, earliest year in data: %d\n",
            placebo_earliest_treat, placebo_min_year))
cat(sprintf("Pre-placebo periods available: %d\n",
            placebo_earliest_treat - placebo_min_year))

# Run CS-DiD on the placebo panel
# Wrap in tryCatch because shifting treatment dates can create groups
# with insufficient pre-treatment periods for the did package
cs_placebo <- tryCatch({
  att_gt(
    yname = "log_emp",
    tname = "year",
    idname = "statefip",
    gname = "first_treat_placebo",
    data = as.data.frame(panel_placebo_clean),
    control_group = "notyettreated",
    est_method = "dr",
    bstrap = TRUE,
    cband = FALSE,
    biters = 500,
    anticipation = 1
  )
}, error = function(e) {
  cat(sprintf("  CS-DiD placebo failed: %s\n", e$message))
  cat("  Falling back to TWFE placebo test.\n")
  NULL
})

att_placebo <- NULL
if (!is.null(cs_placebo)) {
  att_placebo <- aggte(cs_placebo, type = "simple")
  cat(sprintf("\nPlacebo ATT (shifted -3 years): %.4f (SE: %.4f)\n",
              att_placebo$overall.att, att_placebo$overall.se))
  p_placebo <- 2 * pnorm(-abs(att_placebo$overall.att / att_placebo$overall.se))
  cat(sprintf("  p-value: %.4f\n", p_placebo))
  cat(sprintf("  95%% CI: [%.4f, %.4f]\n",
              att_placebo$overall.att - 1.96 * att_placebo$overall.se,
              att_placebo$overall.att + 1.96 * att_placebo$overall.se))

  if (p_placebo > 0.10) {
    cat("  PASS: Placebo effect is not statistically significant (p > 0.10).\n")
    cat("  This supports the parallel trends assumption.\n")
  } else if (p_placebo > 0.05) {
    cat("  MARGINAL: Placebo effect is marginally significant (0.05 < p < 0.10).\n")
  } else {
    cat("  WARNING: Placebo effect is significant, suggesting possible pre-trends.\n")
  }

  saveRDS(cs_placebo, file.path(data_dir, "cs_placebo.rds"))
  saveRDS(att_placebo, file.path(data_dir, "att_placebo.rds"))
} else {
  # TWFE fallback for placebo
  twfe_placebo <- feols(
    log_emp ~ treated_placebo | statefip + year,
    data = panel_placebo_clean, cluster = ~statefip
  )
  cat(sprintf("\nTWFE Placebo (shifted -3 years): %.4f (SE: %.4f)\n",
              coef(twfe_placebo)["treated_placebo"],
              se(twfe_placebo)["treated_placebo"]))
  p_placebo <- 2 * pnorm(-abs(coef(twfe_placebo)["treated_placebo"] / se(twfe_placebo)["treated_placebo"]))
  cat(sprintf("  p-value: %.4f\n", p_placebo))
  if (p_placebo > 0.10) {
    cat("  PASS: TWFE placebo effect is not statistically significant (p > 0.10).\n")
  } else {
    cat("  WARNING: TWFE placebo effect is significant.\n")
  }
  saveRDS(twfe_placebo, file.path(data_dir, "twfe_placebo.rds"))
  # Create a placeholder att_placebo for summary
  att_placebo <- list(overall.att = coef(twfe_placebo)["treated_placebo"],
                      overall.se = se(twfe_placebo)["treated_placebo"])
}

cat("Placebo results saved.\n")

###############################################################################
## 5. Leave-One-Out: Drop Each Early Adopter (first_treat <= 2014)
###############################################################################

cat("\n========================================\n")
cat("5. LEAVE-ONE-OUT (EARLY ADOPTERS, first_treat <= 2014)\n")
cat("========================================\n")

# Identify early adopter states
early_adopters <- panel %>%
  filter(first_treat > 0 & first_treat <= 2014) %>%
  distinct(statefip, first_treat) %>%
  arrange(statefip)

cat(sprintf("Early adopter states (first_treat <= 2014): %d\n", nrow(early_adopters)))
cat("FIPS codes: ")
cat(paste(early_adopters$statefip, collapse = ", "))
cat("\n\n")

# Re-estimate overall ATT dropping each early adopter one at a time
loo_results <- data.frame(
  dropped_state = integer(),
  first_treat   = integer(),
  att           = numeric(),
  se            = numeric(),
  ci_lower      = numeric(),
  ci_upper      = numeric(),
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(early_adopters))) {
  drop_fip <- early_adopters$statefip[i]
  drop_ft  <- early_adopters$first_treat[i]

  cat(sprintf("  Dropping state %d (first_treat = %d)... ", drop_fip, drop_ft))

  panel_loo <- panel %>% filter(statefip != drop_fip)

  cs_loo <- tryCatch({
    att_gt(
      yname = "log_emp",
      tname = "year",
      idname = "statefip",
      gname = "first_treat",
      data = as.data.frame(panel_loo),
      control_group = "nevertreated",
      est_method = "dr",
      bstrap = TRUE,
      cband = FALSE,
      biters = 500,  # fewer iterations for computational speed
      anticipation = 1
    )
  }, error = function(e) {
    cat(sprintf("ERROR: %s\n", e$message))
    NULL
  })

  if (!is.null(cs_loo)) {
    att_loo <- aggte(cs_loo, type = "simple")
    loo_results <- rbind(loo_results, data.frame(
      dropped_state = drop_fip,
      first_treat   = drop_ft,
      att           = att_loo$overall.att,
      se            = att_loo$overall.se,
      ci_lower      = att_loo$overall.att - 1.96 * att_loo$overall.se,
      ci_upper      = att_loo$overall.att + 1.96 * att_loo$overall.se,
      stringsAsFactors = FALSE
    ))
    cat(sprintf("ATT = %.4f (SE = %.4f)\n", att_loo$overall.att, att_loo$overall.se))
  }
}

cat("\n--- Leave-One-Out Results ---\n")
if (nrow(loo_results) > 0) {
  # Reload baseline for comparison
  att_main <- readRDS(file.path(data_dir, "att_overall_log_emp.rds"))

  cat(sprintf("Baseline ATT (all states): %.4f (SE = %.4f)\n\n",
              att_main$overall.att, att_main$overall.se))

  print(as.data.frame(loo_results), row.names = FALSE)

  cat(sprintf("\nATT range across LOO: [%.4f, %.4f]\n",
              min(loo_results$att), max(loo_results$att)))
  cat(sprintf("ATT mean across LOO:  %.4f\n", mean(loo_results$att)))
  cat(sprintf("ATT sd across LOO:    %.4f\n", sd(loo_results$att)))

  # Check whether sign or significance changes when dropping any single state
  baseline_sig <- (att_main$overall.att - 1.96 * att_main$overall.se > 0) |
    (att_main$overall.att + 1.96 * att_main$overall.se < 0)
  loo_sig <- (loo_results$ci_lower > 0) | (loo_results$ci_upper < 0)

  n_sign_change <- sum(sign(loo_results$att) != sign(att_main$overall.att))
  n_sig_change  <- sum(loo_sig != baseline_sig)

  cat(sprintf("\nSign changes: %d / %d\n", n_sign_change, nrow(loo_results)))
  cat(sprintf("Significance changes: %d / %d\n", n_sig_change, nrow(loo_results)))

  if (n_sign_change == 0) {
    cat("PASS: No single early-adopter state drives the sign of the ATT.\n")
  } else {
    cat("WARNING: Dropping some states changes the sign of the ATT.\n")
  }
}

saveRDS(loo_results, file.path(data_dir, "loo_early_adopters.rds"))
cat("Saved: loo_early_adopters.rds\n")

###############################################################################
## Summary of All Robustness Checks
###############################################################################

cat("\n\n========================================================\n")
cat("ROBUSTNESS CHECKS SUMMARY\n")
cat("========================================================\n\n")

# Reload main ATT for final comparison table
att_main <- readRDS(file.path(data_dir, "att_overall_log_emp.rds"))
p_fn <- function(est, se) 2 * pnorm(-abs(est / se))

cat(sprintf("%-42s  %+.4f  (%.4f)  p=%.3f\n",
            "Main CS-DiD (never-treated ctrl):",
            att_main$overall.att, att_main$overall.se,
            p_fn(att_main$overall.att, att_main$overall.se)))

cat(sprintf("%-42s  %+.4f\n",
            "1. Bacon-implied TWFE:",
            bacon_twfe))

cat(sprintf("%-42s  %+.4f  (%.4f)  p=%.3f\n",
            "3. CS-DiD (not-yet-treated ctrl):",
            att_nyt_overall$overall.att, att_nyt_overall$overall.se,
            p_fn(att_nyt_overall$overall.att, att_nyt_overall$overall.se)))

cat(sprintf("%-42s  %+.4f  (%.4f)  p=%.3f\n",
            "4. Placebo ATT (shift -3 years):",
            att_placebo$overall.att, att_placebo$overall.se,
            p_fn(att_placebo$overall.att, att_placebo$overall.se)))

if (nrow(loo_results) > 0) {
  cat(sprintf("%-42s  [%.4f, %.4f]\n",
              "5. LOO ATT range (early adopters):",
              min(loo_results$att), max(loo_results$att)))
  cat(sprintf("%-42s  %.4f\n",
              "   LOO ATT mean:",
              mean(loo_results$att)))
}

cat("\n========================================================\n")
cat("All robustness results saved to ../data/\n")
cat("========================================================\n")
