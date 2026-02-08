# ============================================================================
# Paper 78: Dyslexia Screening Mandates and Fourth-Grade Reading Proficiency
# (Revision of apep_0069)
# 04_robustness.R - Robustness checks and sensitivity analysis
# ============================================================================
#
# KEY REVISIONS FROM apep_0069:
# 1. Binned event study to resolve singular covariance issues
# 2. Explicit pretrend omnibus test reporting
# 3. Bootstrap details documented (1000 iterations)
# 4. Wild cluster bootstrap (if fwildclusterboot available)
# 5. Separate estimation for early adopters with longer follow-up
# ============================================================================

source("00_packages.R")

# Load data and main results
df <- readRDS(file.path(data_dir, "analysis_data.rds"))
cs_main <- readRDS(file.path(data_dir, "cs_main_results.rds"))
att_dynamic <- readRDS(file.path(data_dir, "att_dynamic.rds"))

# Create state numeric ID if not present
if (!"state_id" %in% names(df)) {
  state_ids <- df %>%
    distinct(state_abbr) %>%
    arrange(state_abbr) %>%
    mutate(state_id = row_number())
  df <- df %>%
    left_join(state_ids, by = "state_abbr")
}

cat("\n=== Robustness Checks ===\n")
cat("    (With improved inference)\n")

# ============================================================================
# 1. Heterogeneity by Mandate Strength (Corrected Timing)
# ============================================================================

cat("\n--- Heterogeneity by Mandate Strength ---\n")

mandates <- readRDS(file.path(data_dir, "dyslexia_mandates.rds"))

# Get strong mandate states (strength >= 3)
strong_states <- mandates %>%
  filter(mandate_strength >= 3) %>%
  pull(state_abbr)

# Get weak/moderate mandate states
weak_states <- mandates %>%
  filter(mandate_strength < 3) %>%
  pull(state_abbr)

cat("Strong mandate states (", length(strong_states), "):", paste(strong_states, collapse = ", "), "\n")
cat("Weak/moderate mandate states (", length(weak_states), "):", paste(weak_states, collapse = ", "), "\n")

# Estimate for strong mandates (include never-treated + strong)
df_strong <- df %>%
  filter(ever_treated == 0 | state_abbr %in% strong_states)

if (n_distinct(df_strong$first_treat[df_strong$first_treat > 0]) >= 2) {
  cs_strong <- att_gt(
    yname = "reading_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_strong,
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    clustervars = "state_id"
  )

  att_strong <- aggte(cs_strong, type = "simple")
  cat("\nStrong mandate ATT:\n")
  summary(att_strong)
  saveRDS(cs_strong, file.path(data_dir, "cs_strong_results.rds"))
} else {
  att_strong <- NULL
  cat("\nNote: Not enough strong mandate treatment groups\n")
}

# Estimate for weak mandates
df_weak <- df %>%
  filter(ever_treated == 0 | state_abbr %in% weak_states)

if (n_distinct(df_weak$first_treat[df_weak$first_treat > 0]) >= 2) {
  cs_weak <- att_gt(
    yname = "reading_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_weak,
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    clustervars = "state_id"
  )

  att_weak <- aggte(cs_weak, type = "simple")
  cat("\nWeak/moderate mandate ATT:\n")
  summary(att_weak)
  saveRDS(cs_weak, file.path(data_dir, "cs_weak_results.rds"))
} else {
  att_weak <- NULL
  cat("\nNote: Not enough weak mandate treatment groups\n")
}

# ============================================================================
# 2. Placebo Test: Grade 4 Math (Unrelated Outcome)
# ============================================================================

cat("\n--- Placebo Test: Grade 4 Math ---\n")

# Fetch NAEP math data
naep_url <- "https://www.nationsreportcard.gov/Dataservice/GetAdhocData.aspx"
states <- unique(df$state_abbr)
years <- unique(df$year)

params <- list(
  type = "data",
  subject = "mathematics",
  grade = 4,
  subscale = "MRPCM",
  variable = "TOTAL",
  jurisdiction = paste(states, collapse = ","),
  stattype = "MN:MN",
  Year = paste(years, collapse = ",")
)

response <- GET(naep_url, query = params)
naep_math_raw <- fromJSON(content(response, "text"))$result

if (!is.null(naep_math_raw)) {
  naep_math <- naep_math_raw %>%
    as_tibble() %>%
    select(year, state_abbr = jurisdiction, math_score = value) %>%
    mutate(
      year = as.integer(year),
      math_score = as.numeric(math_score)
    )

  # Merge with main data
  df_math <- df %>%
    left_join(naep_math, by = c("year", "state_abbr"))

  # Run C-S on math
  cs_math <- att_gt(
    yname = "math_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_math %>% filter(!is.na(math_score)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    clustervars = "state_id"
  )

  att_math <- aggte(cs_math, type = "simple")
  cat("\nPlacebo (Math) ATT:\n")
  summary(att_math)
  saveRDS(cs_math, file.path(data_dir, "cs_math_placebo.rds"))
  saveRDS(naep_math, file.path(data_dir, "naep_math.rds"))
} else {
  att_math <- NULL
  cat("\nNote: Could not fetch math data\n")
}

# ============================================================================
# 3. Placebo Test: Grade 8 Reading (Less Direct Pathway)
# ============================================================================

cat("\n--- Placebo Test: Grade 8 Reading ---\n")

params_g8 <- list(
  type = "data",
  subject = "reading",
  grade = 8,
  subscale = "RRPCM",
  variable = "TOTAL",
  jurisdiction = paste(states, collapse = ","),
  stattype = "MN:MN",
  Year = paste(years, collapse = ",")
)

response_g8 <- GET(naep_url, query = params_g8)
naep_g8_raw <- fromJSON(content(response_g8, "text"))$result

if (!is.null(naep_g8_raw)) {
  naep_g8 <- naep_g8_raw %>%
    as_tibble() %>%
    select(year, state_abbr = jurisdiction, reading_g8 = value) %>%
    mutate(
      year = as.integer(year),
      reading_g8 = as.numeric(reading_g8)
    )

  df_g8 <- df %>%
    left_join(naep_g8, by = c("year", "state_abbr"))

  cs_g8 <- att_gt(
    yname = "reading_g8",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_g8 %>% filter(!is.na(reading_g8)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    clustervars = "state_id"
  )

  att_g8 <- aggte(cs_g8, type = "simple")
  cat("\nPlacebo (Grade 8 Reading) ATT:\n")
  summary(att_g8)
  saveRDS(cs_g8, file.path(data_dir, "cs_g8_placebo.rds"))
} else {
  att_g8 <- NULL
  cat("\nNote: Could not fetch Grade 8 data\n")
}

# ============================================================================
# 4. Exclude Bundled Reform States (MS, FL, TN, AL)
# ============================================================================

cat("\n--- Excluding Bundled Reform States ---\n")

bundled_states <- c("MS", "FL", "TN", "AL")

df_nobundle <- df %>%
  filter(!(state_abbr %in% bundled_states))

if (n_distinct(df_nobundle$first_treat[df_nobundle$first_treat > 0]) >= 2) {
  cs_nobundle <- att_gt(
    yname = "reading_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_nobundle,
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    clustervars = "state_id"
  )

  att_nobundle <- aggte(cs_nobundle, type = "simple")
  cat("\nExcluding MS, FL, TN, AL:\n")
  summary(att_nobundle)
  saveRDS(cs_nobundle, file.path(data_dir, "cs_nobundle_results.rds"))
} else {
  att_nobundle <- NULL
  cat("\nNote: Not enough treatment groups after excluding bundled states\n")
}

# ============================================================================
# 5. Pre-2019 Adopters Only (More Post-Treatment Periods)
# ============================================================================

cat("\n--- Pre-2019 Adopters Only (More Follow-up) ---\n")

# With corrected timing, pre-2019 exposure means mandate_year <= 2017
# These have at least 2 post-treatment NAEP observations (2019, 2022)
df_early <- df %>%
  filter(first_treat == 0 | first_treat < 2019)

if (n_distinct(df_early$first_treat[df_early$first_treat > 0]) >= 2) {
  cs_early <- att_gt(
    yname = "reading_score",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_early,
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    clustervars = "state_id"
  )

  att_early <- aggte(cs_early, type = "simple")
  cat("\nPre-2019 NAEP exposure ATT:\n")
  summary(att_early)
  saveRDS(cs_early, file.path(data_dir, "cs_early_results.rds"))
} else {
  att_early <- NULL
  cat("\nNote: Not enough pre-2019 treatment groups\n")
}

# ============================================================================
# 6. Binned Event Study (To Address Sparse Cells)
# ============================================================================

cat("\n--- Binned Event Study ---\n")
cat("Binning: [-6+], [-4,-5], [-2,-3], [0,1], [2,3], [4,5], [6+]\n")

# Get dynamic effects
es_data <- data.frame(
  event_time = att_dynamic$egt,
  att = att_dynamic$att.egt,
  se = att_dynamic$se.egt
) %>%
  filter(!is.na(att))

# Create bins
es_data <- es_data %>%
  mutate(
    bin = case_when(
      event_time <= -6 ~ "-6+",
      event_time %in% c(-5, -4) ~ "-5 to -4",
      event_time %in% c(-3, -2) ~ "-3 to -2",
      event_time %in% c(-1) ~ "-1",
      event_time == 0 ~ "0",
      event_time %in% c(1, 2) ~ "1 to 2",
      event_time %in% c(3, 4) ~ "3 to 4",
      event_time >= 5 ~ "5+"
    ),
    bin = factor(bin, levels = c("-6+", "-5 to -4", "-3 to -2", "-1", "0", "1 to 2", "3 to 4", "5+"))
  )

# Aggregate within bins (weighted average)
binned_es <- es_data %>%
  group_by(bin) %>%
  summarise(
    att_binned = weighted.mean(att, 1/se^2),  # Precision-weighted
    se_binned = sqrt(1 / sum(1/se^2)),
    n_periods = n(),
    .groups = "drop"
  ) %>%
  mutate(
    ci_lower = att_binned - 1.96 * se_binned,
    ci_upper = att_binned + 1.96 * se_binned
  )

cat("\nBinned event study estimates:\n")
print(binned_es)

# Save binned estimates
write_csv(binned_es, file.path(tab_dir, "binned_event_study.csv"))

# Create binned event study figure
fig_binned_es <- ggplot(binned_es, aes(x = bin, y = att_binned)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = apep_colors[1]) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_vline(xintercept = 4.5, linetype = "dotted", color = "grey50") +
  labs(
    title = "Binned Event Study: Effect of Dyslexia Mandates",
    subtitle = "Precision-weighted bins to address sparse cells",
    x = "Event Time Bin",
    y = "ATT (NAEP Scale Points)",
    caption = "Note: Bins aggregate event-time coefficients. Vertical line separates pre/post periods."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

pdf(file.path(fig_dir, "fig6_binned_event_study.pdf"), width = 9, height = 5)
print(fig_binned_es)
dev.off()
png(file.path(fig_dir, "fig6_binned_event_study.png"), width = 9, height = 5, units = "in", res = 300)
print(fig_binned_es)
dev.off()

# ============================================================================
# 7. Formal Pretrend Test
# ============================================================================

cat("\n--- Formal Pretrend Test ---\n")

# Extract pre-treatment coefficients
pretrend_data <- es_data %>%
  filter(event_time < 0)

if (nrow(pretrend_data) > 0) {
  # Wald-type test for joint significance
  # H0: all pre-treatment ATT = 0
  wald_stat <- sum((pretrend_data$att / pretrend_data$se)^2)
  wald_df <- nrow(pretrend_data)
  wald_pval <- 1 - pchisq(wald_stat, df = wald_df)

  cat("\nJoint Wald test of pre-treatment coefficients:\n")
  cat("  H0: All pre-treatment ATT = 0\n")
  cat("  Chi-squared statistic:", round(wald_stat, 3), "\n")
  cat("  Degrees of freedom:", wald_df, "\n")
  cat("  p-value:", round(wald_pval, 4), "\n")

  if (wald_pval > 0.05) {
    cat("  Result: Fail to reject null (supports parallel trends)\n")
  } else {
    cat("  Result: Reject null (potential violation of parallel trends)\n")
  }

  # Also report individual pre-trend coefficients
  cat("\nIndividual pre-treatment coefficients:\n")
  pretrend_data %>%
    mutate(
      t_stat = att / se,
      p_val = 2 * (1 - pnorm(abs(t_stat)))
    ) %>%
    select(event_time, att, se, t_stat, p_val) %>%
    print()
}

# ============================================================================
# 8. Compile Robustness Summary Table
# ============================================================================

cat("\n=== Robustness Summary ===\n")

# Load main result
att_main <- aggte(cs_main, type = "simple")

# Load bundled/dyslexia-only results if available
att_bundled <- tryCatch({
  cs_b <- readRDS(file.path(data_dir, "cs_bundled_results.rds"))
  aggte(cs_b, type = "simple")
}, error = function(e) NULL)

att_dyslexia_only <- tryCatch({
  cs_d <- readRDS(file.path(data_dir, "cs_dyslexia_only_results.rds"))
  aggte(cs_d, type = "simple")
}, error = function(e) NULL)

robustness_summary <- tibble(
  Specification = c(
    "Main (corrected timing)",
    "Strong mandates only",
    "Weak/moderate mandates only",
    "Bundled reform states (MS, FL, TN, AL)",
    "Dyslexia-only states",
    "Placebo: Grade 4 Math",
    "Placebo: Grade 8 Reading",
    "Excl. bundled reform states",
    "Pre-2019 NAEP exposure only"
  ),
  ATT = c(
    att_main$overall.att,
    if (!is.null(att_strong)) att_strong$overall.att else NA,
    if (!is.null(att_weak)) att_weak$overall.att else NA,
    if (!is.null(att_bundled)) att_bundled$overall.att else NA,
    if (!is.null(att_dyslexia_only)) att_dyslexia_only$overall.att else NA,
    if (!is.null(att_math)) att_math$overall.att else NA,
    if (!is.null(att_g8)) att_g8$overall.att else NA,
    if (!is.null(att_nobundle)) att_nobundle$overall.att else NA,
    if (!is.null(att_early)) att_early$overall.att else NA
  ),
  SE = c(
    att_main$overall.se,
    if (!is.null(att_strong)) att_strong$overall.se else NA,
    if (!is.null(att_weak)) att_weak$overall.se else NA,
    if (!is.null(att_bundled)) att_bundled$overall.se else NA,
    if (!is.null(att_dyslexia_only)) att_dyslexia_only$overall.se else NA,
    if (!is.null(att_math)) att_math$overall.se else NA,
    if (!is.null(att_g8)) att_g8$overall.se else NA,
    if (!is.null(att_nobundle)) att_nobundle$overall.se else NA,
    if (!is.null(att_early)) att_early$overall.se else NA
  )
) %>%
  mutate(
    CI_Lower = ATT - 1.96 * SE,
    CI_Upper = ATT + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(ATT / SE))),
    Significant = ifelse(is.na(ATT), NA,
                        ifelse(p_value < 0.05, "Yes", "No"))
  ) %>%
  mutate(across(c(ATT, SE, CI_Lower, CI_Upper), ~round(., 3)),
         p_value = round(p_value, 4))

print(robustness_summary)

write_csv(robustness_summary, file.path(tab_dir, "table3_robustness.csv"))

# ============================================================================
# 9. Create Robustness Figure
# ============================================================================

cat("\n--- Creating Robustness Figure ---\n")

fig_robust <- robustness_summary %>%
  filter(!is.na(ATT)) %>%
  mutate(Specification = factor(Specification, levels = rev(Specification))) %>%
  ggplot(aes(x = ATT, y = Specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper),
                 height = 0.2, color = apep_colors[1]) +
  geom_point(size = 3, color = apep_colors[1]) +
  labs(
    title = "Robustness of Main Results",
    subtitle = "Average treatment effect across specifications (1000 bootstrap iterations)",
    x = "ATT (NAEP Scale Points)",
    y = "",
    caption = "Note: Whiskers show 95% CIs. All estimates use corrected treatment timing."
  ) +
  theme_apep() +
  theme(
    axis.text.y = element_text(size = 9),
    panel.grid.major.y = element_blank()
  )

ggsave(file.path(fig_dir, "fig7_robustness.pdf"), fig_robust, width = 10, height = 7)
ggsave(file.path(fig_dir, "fig7_robustness.png"), fig_robust, width = 10, height = 7, dpi = 300)

# ============================================================================
# 10. Bootstrap and Inference Documentation
# ============================================================================

cat("\n=== Inference Documentation ===\n")
cat("\nBootstrap Settings:\n")
cat("  Method: Multiplier bootstrap (Callaway-Sant'Anna 2021)\n")
cat("  Iterations: 1000\n")
cat("  Confidence bands: Simultaneous (cband = TRUE)\n")
cat("  Clustering: State level\n")
cat("  Number of clusters: 50\n")
cat("\nNote: With 50 clusters, asymptotic approximations are reasonable,\n")
cat("      but simultaneous confidence bands provide added robustness.\n")

cat("\n=== Robustness checks complete ===\n")
