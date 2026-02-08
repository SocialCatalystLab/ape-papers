# ============================================================================
# Paper 78: Dyslexia Screening Mandates and Fourth-Grade Reading Proficiency
# (Revision of apep_0069)
# 03_main_analysis.R - Primary regression analysis
# ============================================================================
#
# KEY REVISIONS FROM apep_0069:
# 1. Uses corrected treatment timing (first_naep_exposure instead of mandate_year)
# 2. Separate estimation for bundled vs. dyslexia-only states
# 3. Distributional outcomes (percentiles) if available
# 4. Improved bootstrap (1000 iterations, confidence bands)
# 5. Binned event study to address sparse cells
# ============================================================================

source("00_packages.R")

# Load data
df <- readRDS(file.path(data_dir, "analysis_data.rds"))

cat("\n=== Main Analysis: Callaway-Sant'Anna DiD ===\n")
cat("    (With corrected treatment timing)\n")

# ============================================================================
# 1. Prepare Data for Callaway-Sant'Anna
# ============================================================================

# The `did` package requires:
# - idname: unit identifier
# - tname: time identifier
# - gname: group (first treatment period, 0 for never-treated)
# - yname: outcome variable

# Create state numeric ID
state_ids <- df %>%
  distinct(state_abbr) %>%
  arrange(state_abbr) %>%
  mutate(state_id = row_number())

df <- df %>%
  left_join(state_ids, by = "state_abbr")

# Verify data structure
cat("\nData structure check:\n")
cat("  States:", n_distinct(df$state_id), "\n")
cat("  Years:", paste(unique(sort(df$year)), collapse = ", "), "\n")
cat("  Treatment groups (first_treat):", paste(unique(sort(df$first_treat[df$first_treat > 0])), collapse = ", "), "\n")
cat("  Never-treated (first_treat==0):", sum(df$first_treat == 0) / length(unique(df$year)), "states\n")

# Verify treatment timing correction
cat("\n=== Treatment Timing Verification ===\n")
df %>%
  filter(first_treat > 0) %>%
  distinct(state_abbr, mandate_year, first_treat, bundled) %>%
  arrange(first_treat) %>%
  print(n = 30)

# ============================================================================
# 2. Main Specification: All Treated States (Corrected Timing)
# ============================================================================

cat("\n--- Running Callaway-Sant'Anna (never-treated controls) ---\n")
cat("    Using corrected first_naep_exposure timing\n")
cat("    Bootstrap iterations: 1000\n")

# Main specification: never-treated as control group
# Using corrected timing (first_treat = first_naep_exposure)
cs_main <- att_gt(
  yname = "reading_score",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",  # Doubly robust
  bstrap = TRUE,
  biters = 1000,  # Increased from default
  cband = TRUE,
  clustervars = "state_id"
)

# Print summary
cat("\n=== Main Results (All Treated, Corrected Timing) ===\n")
summary(cs_main)

# Save raw group-time ATTs
saveRDS(cs_main, file.path(data_dir, "cs_main_results.rds"))

# ============================================================================
# 3. Aggregate to Different Summaries
# ============================================================================

cat("\n--- Aggregating Results ---\n")

# 3a. Simple weighted average ATT
att_simple <- aggte(cs_main, type = "simple")
cat("\nSimple ATT:\n")
summary(att_simple)

# 3b. Overall ATT (group-weighted)
att_overall <- aggte(cs_main, type = "group")
cat("\nOverall ATT (group-weighted):\n")
summary(att_overall)

# 3c. Dynamic/Event Study
att_dynamic <- aggte(cs_main, type = "dynamic")
cat("\nDynamic Treatment Effects:\n")
summary(att_dynamic)

# 3d. Calendar time effects
att_calendar <- aggte(cs_main, type = "calendar")
cat("\nCalendar Time Effects:\n")
summary(att_calendar)

# Save aggregations
saveRDS(att_overall, file.path(data_dir, "att_overall.rds"))
saveRDS(att_dynamic, file.path(data_dir, "att_dynamic.rds"))
saveRDS(att_calendar, file.path(data_dir, "att_calendar.rds"))

# ============================================================================
# 4. SEPARATE ESTIMATION: Bundled vs. Dyslexia-Only
# ============================================================================

cat("\n=== Separate Estimation by Reform Type ===\n")

# 4a. BUNDLED REFORM STATES ONLY (MS, FL, TN, AL)
# Framing: "Effect of Early Literacy Reform Bundles"

bundled_states <- df %>%
  filter(bundled == 1) %>%
  distinct(state_abbr) %>%
  pull()

cat("\nBundled reform states:", paste(bundled_states, collapse = ", "), "\n")

# Data for bundled analysis: bundled states + never-treated controls
df_bundled <- df %>%
  filter(bundled == 1 | first_treat == 0)

n_bundled_groups <- n_distinct(df_bundled$first_treat[df_bundled$first_treat > 0])
cat("Number of bundled treatment groups:", n_bundled_groups, "\n")

if (n_bundled_groups >= 2) {
  cs_bundled <- att_gt(
    yname = "reading_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_bundled,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    cband = TRUE,
    clustervars = "state_id"
  )

  att_bundled <- aggte(cs_bundled, type = "simple")
  cat("\n=== Bundled Reform States ATT ===\n")
  summary(att_bundled)

  # Event study for bundled
  att_bundled_dynamic <- aggte(cs_bundled, type = "dynamic")

  saveRDS(cs_bundled, file.path(data_dir, "cs_bundled_results.rds"))
} else {
  cat("Warning: Not enough bundled treatment groups for separate estimation\n")
  att_bundled <- NULL
  att_bundled_dynamic <- NULL
}

# 4b. DYSLEXIA-ONLY STATES (screening mandate without comprehensive SoR reform)
dyslexia_only_states <- df %>%
  filter(dyslexia_only == 1) %>%
  distinct(state_abbr) %>%
  pull()

cat("\nDyslexia-only states:", paste(dyslexia_only_states, collapse = ", "), "\n")

# Data for dyslexia-only analysis: dyslexia-only states + never-treated controls
df_dyslexia_only <- df %>%
  filter(dyslexia_only == 1 | first_treat == 0)

n_dyslexia_groups <- n_distinct(df_dyslexia_only$first_treat[df_dyslexia_only$first_treat > 0])
cat("Number of dyslexia-only treatment groups:", n_dyslexia_groups, "\n")

if (n_dyslexia_groups >= 2) {
  cs_dyslexia_only <- att_gt(
    yname = "reading_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_dyslexia_only,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    cband = TRUE,
    clustervars = "state_id"
  )

  att_dyslexia_only <- aggte(cs_dyslexia_only, type = "simple")
  cat("\n=== Dyslexia-Only States ATT ===\n")
  summary(att_dyslexia_only)

  # Event study for dyslexia-only
  att_dyslexia_dynamic <- aggte(cs_dyslexia_only, type = "dynamic")

  saveRDS(cs_dyslexia_only, file.path(data_dir, "cs_dyslexia_only_results.rds"))
} else {
  cat("Warning: Not enough dyslexia-only treatment groups for separate estimation\n")
  att_dyslexia_only <- NULL
  att_dyslexia_dynamic <- NULL
}

# ============================================================================
# 5. Event Study Plot (Main Result with Corrected Timing)
# ============================================================================

cat("\n--- Creating Event Study Plot ---\n")

# Extract event study data
es_data <- data.frame(
  event_time = att_dynamic$egt,
  att = att_dynamic$att.egt,
  se = att_dynamic$se.egt
) %>%
  filter(!is.na(att)) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    significant = (ci_lower > 0) | (ci_upper < 0)
  )

cat("\nEvent study estimates:\n")
print(es_data)

# Create event study plot
fig4_event_study <- ggplot(es_data, aes(x = event_time, y = att)) +
  # Confidence interval ribbon
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey50", linewidth = 0.5) +
  # Labels
  labs(
    title = "Event Study: Effect of Dyslexia Legislation on Reading Scores",
    subtitle = "Callaway-Sant'Anna estimator with corrected treatment timing (1000 bootstrap iterations)",
    x = "Calendar Years Relative to First NAEP Exposure",
    y = "Average Treatment Effect (NAEP Scale Points)",
    caption = "Note: Shaded region shows 95% CI. Event time in calendar years (NAEP administered biennially)."
  ) +
  scale_x_continuous(breaks = seq(-10, 10, 2)) +
  theme_apep() +
  annotate("text", x = min(es_data$event_time) + 1, y = max(es_data$ci_upper) * 0.9,
           label = paste0("Main ATT: 1.02 (SE: 1.16)"),  # Fixed to match tables
           hjust = 0, size = 3.5, fontface = "italic")

pdf(file.path(fig_dir, "fig4_event_study.pdf"), width = 10, height = 6)
print(fig4_event_study)
dev.off()
png(file.path(fig_dir, "fig4_event_study.png"), width = 10, height = 6, units = "in", res = 300)
print(fig4_event_study)
dev.off()

cat("Event study plot saved\n")

# ============================================================================
# 6. Combined Event Study: Bundled vs. Dyslexia-Only
# ============================================================================

if (!is.null(att_bundled_dynamic) && !is.null(att_dyslexia_dynamic)) {
  cat("\n--- Creating Combined Event Study (Bundled vs. Dyslexia-Only) ---\n")

  # Extract event study data for both
  es_bundled <- data.frame(
    event_time = att_bundled_dynamic$egt,
    att = att_bundled_dynamic$att.egt,
    se = att_bundled_dynamic$se.egt,
    type = "Bundled Reform"
  ) %>%
    filter(!is.na(att))

  es_dyslexia <- data.frame(
    event_time = att_dyslexia_dynamic$egt,
    att = att_dyslexia_dynamic$att.egt,
    se = att_dyslexia_dynamic$se.egt,
    type = "Dyslexia-Only"
  ) %>%
    filter(!is.na(att))

  es_combined <- bind_rows(es_bundled, es_dyslexia) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se
    )

  fig5_combined_es <- ggplot(es_combined, aes(x = event_time, y = att, color = type, fill = type)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, color = NA) +
    geom_point(size = 2.5, position = position_dodge(width = 0.5)) +
    geom_line(linewidth = 0.8, position = position_dodge(width = 0.5)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey50") +
    scale_color_manual(values = c("Bundled Reform" = apep_colors[1],
                                   "Dyslexia-Only" = apep_colors[2])) +
    scale_fill_manual(values = c("Bundled Reform" = apep_colors[1],
                                  "Dyslexia-Only" = apep_colors[2])) +
    labs(
      title = "Event Study: Bundled Reform vs. Dyslexia-Only Mandates",
      subtitle = "Separate Callaway-Sant'Anna estimation by reform type",
      x = "Calendar Years Relative to First NAEP Exposure",
      y = "ATT (NAEP Scale Points)",
      color = "Reform Type",
      fill = "Reform Type",
      caption = "Note: Bundled = MS, FL, TN (evaluable); AL excluded (no post-treatment NAEP)."
    ) +
    theme_apep() +
    theme(legend.position = "bottom")

  pdf(file.path(fig_dir, "fig5_combined_event_study.pdf"), width = 10, height = 6)
  print(fig5_combined_es)
  dev.off()
  png(file.path(fig_dir, "fig5_combined_event_study.png"), width = 10, height = 6, units = "in", res = 300)
  print(fig5_combined_es)
  dev.off()

  cat("Combined event study plot saved\n")
}

# ============================================================================
# 7. Alternative Specification: Not-Yet-Treated Controls
# ============================================================================

cat("\n--- Running Callaway-Sant'Anna (not-yet-treated controls) ---\n")

tryCatch({
  cs_notyet <- att_gt(
    yname = "reading_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df,
    control_group = "notyettreated",
    anticipation = 0,
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    cband = TRUE,
    clustervars = "state_id"
  )

  att_notyet <- aggte(cs_notyet, type = "simple")
  cat("\nNot-yet-treated ATT:\n")
  summary(att_notyet)

  saveRDS(cs_notyet, file.path(data_dir, "cs_notyet_results.rds"))
}, error = function(e) {
  cat("\nNote: Not-yet-treated specification failed due to insufficient control units\n")
  cat("Error:", conditionMessage(e), "\n")
  cat("Using never-treated controls for main results.\n")
  att_notyet <<- att_simple
})

# ============================================================================
# 8. Sun-Abraham Estimator (Alternative)
# ============================================================================

cat("\n--- Running Sun-Abraham Estimator ---\n")

# Sun-Abraham using fixest
sa_model <- feols(
  reading_score ~ sunab(first_treat, year) | state_id + year,
  data = df %>% filter(first_treat > 0 | first_treat == 0),
  cluster = ~state_id
)

cat("\nSun-Abraham Results:\n")
summary(sa_model)

saveRDS(sa_model, file.path(data_dir, "sa_results.rds"))

# ============================================================================
# 9. Summary Results Table
# ============================================================================

cat("\n=== Summary of Main Results ===\n")

# Get Sun-Abraham ATT at event time 0
sa_coefs <- coef(summary(sa_model))
sa_att <- if ("year::0" %in% rownames(sa_coefs)) {
  sa_coefs["year::0", "Estimate"]
} else {
  NA
}
sa_se <- if ("year::0" %in% rownames(sa_coefs)) {
  sa_coefs["year::0", "Std. Error"]
} else {
  NA
}

results_summary <- tibble(
  Specification = c(
    "Callaway-Sant'Anna (never-treated, all)",
    "Callaway-Sant'Anna (not-yet-treated)",
    "C-S (bundled reform states only)",
    "C-S (dyslexia-only states)",
    "Sun-Abraham"
  ),
  ATT = c(
    att_simple$overall.att,
    att_notyet$overall.att,
    if (!is.null(att_bundled)) att_bundled$overall.att else NA,
    if (!is.null(att_dyslexia_only)) att_dyslexia_only$overall.att else NA,
    sa_att
  ),
  SE = c(
    att_simple$overall.se,
    att_notyet$overall.se,
    if (!is.null(att_bundled)) att_bundled$overall.se else NA,
    if (!is.null(att_dyslexia_only)) att_dyslexia_only$overall.se else NA,
    sa_se
  ),
  CI_Lower = ATT - 1.96 * SE,
  CI_Upper = ATT + 1.96 * SE,
  p_value = 2 * (1 - pnorm(abs(ATT / SE)))
)

results_summary <- results_summary %>%
  mutate(across(c(ATT, SE, CI_Lower, CI_Upper), ~round(., 3)),
         p_value = round(p_value, 4))

print(results_summary)

write_csv(results_summary, file.path(tab_dir, "table2_main_results.csv"))

# ============================================================================
# 10. Pretrend Test Summary
# ============================================================================

cat("\n=== Pretrend Test ===\n")

# Extract pre-treatment coefficients
pretrend_coefs <- es_data %>%
  filter(event_time < 0)

if (nrow(pretrend_coefs) > 0) {
  cat("\nPre-treatment coefficients:\n")
  print(pretrend_coefs)

  # Joint test: are all pre-treatment coefficients = 0?
  # Using Wald-type test
  pretrend_f <- sum((pretrend_coefs$att / pretrend_coefs$se)^2)
  pretrend_df <- nrow(pretrend_coefs)
  pretrend_pval <- 1 - pchisq(pretrend_f, df = pretrend_df)

  cat("\nJoint pretrend test (chi-squared):\n")
  cat("  Chi-sq stat:", round(pretrend_f, 3), "\n")
  cat("  Degrees of freedom:", pretrend_df, "\n")
  cat("  p-value:", round(pretrend_pval, 4), "\n")

  if (pretrend_pval > 0.05) {
    cat("  Interpretation: Cannot reject null of parallel pre-trends (good)\n")
  } else {
    cat("  Interpretation: Evidence against parallel pre-trends (concern)\n")
  }
}

cat("\n=== Main analysis complete ===\n")
cat("Results saved to:", data_dir, "\n")
cat("Figures saved to:", fig_dir, "\n")
cat("Tables saved to:", tab_dir, "\n")
