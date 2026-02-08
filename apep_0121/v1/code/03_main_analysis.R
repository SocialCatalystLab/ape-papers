# ==============================================================================
# 03_main_analysis.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Main DiD analysis — CS-DiD, TWFE, Sun-Abraham, event studies
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================================\n")
cat("  03_main_analysis.R: Main estimation\n")
cat("========================================================\n\n")

# ==============================================================================
# SECTION 1: Load data
# ==============================================================================

cat("--- Loading analysis panel ---\n")

panel <- read.csv(file.path(DATA_DIR, "analysis_panel.csv"),
                  stringsAsFactors = FALSE)
cat("  Loaded:", nrow(panel), "obs,", length(unique(panel$state_fips)), "states,",
    length(unique(panel$year)), "years\n")

# Verify key variables exist
stopifnot(all(c("pct_with_parents", "year", "state_fips", "first_treat",
                "treated") %in% names(panel)))

# Quick summary
n_treated <- sum(panel$first_treat > 0 & !duplicated(panel$state_fips))
n_never   <- sum(panel$first_treat == 0 & !duplicated(panel$state_fips))
cat("  Treated states:", n_treated, "| Never-treated:", n_never, "\n\n")

# ==============================================================================
# SECTION 2: Treatment rollout plot
# ==============================================================================

cat("--- Treatment rollout ---\n")

rollout <- panel %>%
  filter(first_treat > 0) %>%
  select(state_fips, state_abbr, first_treat) %>%
  distinct() %>%
  count(first_treat, name = "n_states")

cat("  Newly treated states by year:\n")
for (i in seq_len(nrow(rollout))) {
  cat(sprintf("    %d: %d states\n", rollout$first_treat[i], rollout$n_states[i]))
}

p_rollout <- ggplot(rollout, aes(x = first_treat, y = n_states)) +
  geom_col(fill = apep_colors[1], width = 0.7, alpha = 0.85) +
  geom_text(aes(label = n_states), vjust = -0.5, size = 3.5, fontface = "bold") +
  scale_x_continuous(breaks = rollout$first_treat) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Treatment Rollout: State Minimum Wage Exceeds Federal + $1.00",
    x = "Year First Treated",
    y = "Number of Newly Treated States"
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig_treatment_rollout.pdf"), p_rollout,
       width = 7, height = 5, device = "pdf")
cat("  Saved: fig_treatment_rollout.pdf\n\n")

# ==============================================================================
# SECTION 3: Raw trends — treated vs. control
# ==============================================================================

cat("--- Raw trends ---\n")

# Classify states by ever-treated status
panel <- panel %>%
  mutate(group = ifelse(first_treat > 0, "Treated (ever)", "Never-treated"))

trends <- panel %>%
  group_by(year, group) %>%
  summarise(
    pct_with_parents = mean(pct_with_parents, na.rm = TRUE),
    pct_independent  = mean(pct_independent, na.rm = TRUE),
    .groups = "drop"
  )

# Median treatment year for vertical reference line
median_treat_year <- panel %>%
  filter(first_treat > 0) %>%
  select(state_fips, first_treat) %>%
  distinct() %>%
  summarise(med = median(first_treat)) %>%
  pull(med)

cat("  Median treatment year:", median_treat_year, "\n")

# Panel A: Living with parents
p_trend_a <- ggplot(trends, aes(x = year, y = pct_with_parents,
                                color = group, linetype = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = median_treat_year, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  scale_color_manual(values = c("Treated (ever)" = apep_colors[1],
                                "Never-treated"  = apep_colors[2])) +
  scale_linetype_manual(values = c("Treated (ever)" = "solid",
                                   "Never-treated"  = "dashed")) +
  labs(
    title = "A: Young Adults Living with Parents (18\u201334)",
    x = "Year", y = "Percent Living with Parents",
    color = NULL, linetype = NULL
  ) +
  theme_apep()

# Panel B: Independent living
p_trend_b <- ggplot(trends, aes(x = year, y = pct_independent,
                                color = group, linetype = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = median_treat_year, linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  scale_color_manual(values = c("Treated (ever)" = apep_colors[1],
                                "Never-treated"  = apep_colors[2])) +
  scale_linetype_manual(values = c("Treated (ever)" = "solid",
                                   "Never-treated"  = "dashed")) +
  labs(
    title = "B: Young Adults Living Independently (18\u201334)",
    x = "Year", y = "Percent Independent",
    color = NULL, linetype = NULL
  ) +
  theme_apep()

p_trends <- p_trend_a / p_trend_b +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig_raw_trends.pdf"), p_trends,
       width = 7, height = 9, device = "pdf")
cat("  Saved: fig_raw_trends.pdf\n\n")

# ==============================================================================
# SECTION 4: Callaway-Sant'Anna (2021) — Group-Time ATTs
# ==============================================================================

cat("--- Callaway-Sant'Anna estimation ---\n")

cs_out <- att_gt(
  yname       = "pct_with_parents",
  tname       = "year",
  idname      = "state_fips",
  gname       = "first_treat",
  data        = panel,
  control_group = "nevertreated",
  base_period   = "universal",
  print_details = FALSE
)

cat("  CS-DiD group-time ATTs estimated\n")
cat("  Number of group-time estimates:", length(cs_out$att), "\n")
cat("  Groups:", paste(sort(unique(cs_out$group)), collapse = ", "), "\n\n")

# Save CS results
saveRDS(cs_out, file.path(DATA_DIR, "cs_out.rds"))
cat("  Saved: cs_out.rds\n")

# ==============================================================================
# SECTION 5: Event study aggregation
# ==============================================================================

cat("\n--- Event study aggregation ---\n")

es <- aggte(cs_out, type = "dynamic")

cat("  Event study estimates:\n")
cat(sprintf("  %-8s %10s %10s %10s\n", "e", "ATT(e)", "SE", "p-val"))
cat(paste(rep("-", 42), collapse = ""), "\n")
for (i in seq_along(es$egt)) {
  pval <- 2 * pnorm(-abs(es$att.egt[i] / es$se.egt[i]))
  cat(sprintf("  %-8d %10.4f %10.4f %10.4f\n",
              es$egt[i], es$att.egt[i], es$se.egt[i], pval))
}

# Save event study
saveRDS(es, file.path(DATA_DIR, "cs_event_study.rds"))
cat("\n  Saved: cs_event_study.rds\n")

# Pre-trends test: joint significance of pre-treatment coefficients
pre_idx <- which(es$egt < 0)
if (length(pre_idx) > 1 && !is.null(es$V.egt)) {
  tryCatch({
    pre_att <- es$att.egt[pre_idx]
    pre_V   <- es$V.egt[pre_idx, pre_idx, drop = FALSE]

    # Wald test for joint significance
    if (all(diag(pre_V) > 0)) {
      wald_stat <- as.numeric(t(pre_att) %*% solve(pre_V) %*% pre_att)
      wald_df   <- length(pre_att)
      wald_pval <- 1 - pchisq(wald_stat, df = wald_df)
      cat(sprintf("\n  Pre-trends Wald test: chi2(%d) = %.3f, p = %.4f\n",
                  wald_df, wald_stat, wald_pval))
      if (wald_pval > 0.05) {
        cat("  => Cannot reject parallel trends (p > 0.05)\n")
      } else {
        cat("  => WARNING: Pre-trends test rejects at 5% level\n")
      }
    }
  }, error = function(e) {
    cat("\n  Pre-trends Wald test skipped (singular covariance matrix).\n")
  })
} else {
  cat("\n  Pre-trends Wald test skipped (insufficient pre-periods or NULL variance matrix).\n")
}

# ==============================================================================
# SECTION 6: Overall ATT (simple aggregation)
# ==============================================================================

cat("\n--- Overall ATT ---\n")

att_overall <- aggte(cs_out, type = "simple")

cat(sprintf("  Overall ATT:   %.4f\n", att_overall$overall.att))
cat(sprintf("  SE:            %.4f\n", att_overall$overall.se))
ci_lo <- att_overall$overall.att - 1.96 * att_overall$overall.se
ci_hi <- att_overall$overall.att + 1.96 * att_overall$overall.se
cat(sprintf("  95%% CI:        [%.4f, %.4f]\n", ci_lo, ci_hi))
pval_overall <- 2 * pnorm(-abs(att_overall$overall.att / att_overall$overall.se))
cat(sprintf("  p-value:       %.4f\n", pval_overall))

# Save overall ATT
saveRDS(att_overall, file.path(DATA_DIR, "cs_overall_att.rds"))
cat("  Saved: cs_overall_att.rds\n")

# Group-level aggregation
att_group <- aggte(cs_out, type = "group")
cat("\n  Group-level ATTs:\n")
cat(sprintf("  %-8s %10s %10s\n", "Group", "ATT", "SE"))
cat(paste(rep("-", 30), collapse = ""), "\n")
for (i in seq_along(att_group$egt)) {
  cat(sprintf("  %-8d %10.4f %10.4f\n",
              att_group$egt[i], att_group$att.egt[i], att_group$se.egt[i]))
}

saveRDS(att_group, file.path(DATA_DIR, "cs_group_att.rds"))
cat("  Saved: cs_group_att.rds\n")

# ==============================================================================
# SECTION 7: TWFE for comparison
# ==============================================================================

cat("\n--- TWFE estimation ---\n")

twfe <- feols(pct_with_parents ~ treated | state_fips + year,
              data = panel, cluster = ~state_fips)

cat("  TWFE coefficient on 'treated':\n")
cat(sprintf("    Estimate:  %.4f\n", coef(twfe)["treated"]))
cat(sprintf("    SE:        %.4f\n", se(twfe)["treated"]))
cat(sprintf("    t-stat:    %.4f\n", tstat(twfe)["treated"]))
cat(sprintf("    p-value:   %.4f\n", fixest::pvalue(twfe)["treated"]))
cat(sprintf("    N:         %d\n", nobs(twfe)))
cat(sprintf("    R-sq:      %.4f\n", r2(twfe, type = "r2")))

# Save TWFE
saveRDS(twfe, file.path(DATA_DIR, "twfe_model.rds"))
cat("  Saved: twfe_model.rds\n")

# ==============================================================================
# SECTION 8: Sun-Abraham (2021) — Interaction-weighted estimator
# ==============================================================================

cat("\n--- Sun-Abraham estimation ---\n")

# Sun-Abraham requires first_treat = large number for never-treated (not 0)
panel_sa <- panel %>%
  mutate(first_treat_sa = ifelse(first_treat == 0, 10000, first_treat))

sa <- feols(
  pct_with_parents ~ sunab(first_treat_sa, year) | state_fips + year,
  data    = panel_sa,
  cluster = ~state_fips
)

cat("  Sun-Abraham estimation complete\n")
cat(sprintf("    N:         %d\n", nobs(sa)))

# Overall ATT from Sun-Abraham (average of post-treatment estimates)
sa_coefs   <- coef(sa)
sa_ses     <- se(sa)
sa_names   <- names(sa_coefs)

# Extract post-treatment (relative time >= 0) coefficients
# sunab names look like "year::XXXX:first_treat_sa"
post_coefs <- sa_coefs[grepl("::", sa_names)]
if (length(post_coefs) > 0) {
  sa_att <- mean(post_coefs)
  cat(sprintf("    Mean post-treatment ATT: %.4f\n", sa_att))
}

# Save Sun-Abraham
saveRDS(sa, file.path(DATA_DIR, "sa_model.rds"))
cat("  Saved: sa_model.rds\n")

# ==============================================================================
# SECTION 9: CS-DiD with covariates
# ==============================================================================

cat("\n--- CS-DiD with covariates ---\n")

# Check for missing controls and handle
panel_cov <- panel %>%
  filter(!is.na(unemployment_rate) & !is.na(log_rent))

cat("  Observations with non-missing controls:", nrow(panel_cov), "\n")

cs_cov <- tryCatch({
  att_gt(
    yname       = "pct_with_parents",
    tname       = "year",
    idname      = "state_fips",
    gname       = "first_treat",
    data        = panel_cov,
    xformla     = ~ unemployment_rate + log_rent,
    control_group = "nevertreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  WARNING: CS-DiD with covariates failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_cov)) {
  att_cov <- aggte(cs_cov, type = "simple")
  cat(sprintf("  Overall ATT (with controls): %.4f (SE: %.4f)\n",
              att_cov$overall.att, att_cov$overall.se))

  saveRDS(cs_cov, file.path(DATA_DIR, "cs_cov_out.rds"))
  saveRDS(att_cov, file.path(DATA_DIR, "cs_cov_att.rds"))
  cat("  Saved: cs_cov_out.rds, cs_cov_att.rds\n")
}

# ==============================================================================
# SECTION 10: CS-DiD for alternative outcome (pct_independent)
# ==============================================================================

cat("\n--- CS-DiD for pct_independent ---\n")

cs_indep <- att_gt(
  yname       = "pct_independent",
  tname       = "year",
  idname      = "state_fips",
  gname       = "first_treat",
  data        = panel,
  control_group = "nevertreated",
  base_period   = "universal",
  print_details = FALSE
)

att_indep <- aggte(cs_indep, type = "simple")
cat(sprintf("  Overall ATT (pct_independent): %.4f (SE: %.4f)\n",
            att_indep$overall.att, att_indep$overall.se))

es_indep <- aggte(cs_indep, type = "dynamic")

saveRDS(cs_indep,  file.path(DATA_DIR, "cs_indep_out.rds"))
saveRDS(att_indep, file.path(DATA_DIR, "cs_indep_att.rds"))
saveRDS(es_indep,  file.path(DATA_DIR, "cs_indep_es.rds"))
cat("  Saved: cs_indep_out.rds, cs_indep_att.rds, cs_indep_es.rds\n")

# ==============================================================================
# SECTION 11: Summary of main results
# ==============================================================================

cat("\n========================================================\n")
cat("  SUMMARY OF MAIN RESULTS\n")
cat("========================================================\n\n")

results_summary <- data.frame(
  Estimator = c("CS-DiD (Overall ATT)",
                "CS-DiD (with controls)",
                "TWFE",
                "Sun-Abraham",
                "CS-DiD (pct_independent)"),
  Estimate = c(att_overall$overall.att,
               ifelse(!is.null(cs_cov), att_cov$overall.att, NA),
               coef(twfe)["treated"],
               ifelse(length(post_coefs) > 0, sa_att, NA),
               att_indep$overall.att),
  SE = c(att_overall$overall.se,
         ifelse(!is.null(cs_cov), att_cov$overall.se, NA),
         se(twfe)["treated"],
         NA,
         att_indep$overall.se),
  stringsAsFactors = FALSE
)

cat(sprintf("  %-30s %10s %10s\n", "Estimator", "Estimate", "SE"))
cat(paste(rep("-", 54), collapse = ""), "\n")
for (i in seq_len(nrow(results_summary))) {
  cat(sprintf("  %-30s %10.4f %10.4f\n",
              results_summary$Estimator[i],
              results_summary$Estimate[i],
              ifelse(is.na(results_summary$SE[i]), 0, results_summary$SE[i])))
}

# Save summary
saveRDS(results_summary, file.path(DATA_DIR, "main_results_summary.rds"))
write.csv(results_summary, file.path(DATA_DIR, "main_results_summary.csv"),
          row.names = FALSE)
cat("\n  Saved: main_results_summary.rds, main_results_summary.csv\n")

cat("\n========================================================\n")
cat("  03_main_analysis.R completed successfully.\n")
cat("========================================================\n")
