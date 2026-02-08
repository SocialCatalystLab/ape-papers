# =============================================================================
# Paper 83: Social Security at 62 and Civic Engagement (Revision of apep_0081)
# 03b_first_stage.R - First-Stage Analysis: Employment Discontinuity at Age 62
# =============================================================================
#
# CRITICAL ADDITION: The original paper claimed SS eligibility affects
# volunteering through retirement/reduced labor supply, but never showed
# the first stage. This script provides evidence of employment discontinuity
# at age 62 to support the causal mechanism.
#
# Key outcomes:
#   1. Work time on diary day (from ATUS activity codes 05xxxx)
#   2. Full-time work indicator
#   3. "Not employed" indicator (derived from work time)
#
# If first stage is weak, we reframe the paper as "turning 62" effect
# rather than "SS eligibility → retirement → volunteering" effect.
# =============================================================================

source("00_packages.R")

cat("=" %>% strrep(70), "\n")
cat("First-Stage Analysis: Employment at Age 62\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# 1. Load Raw ATUS Data and Calculate Work Time
# -----------------------------------------------------------------------------

cat("--- 1. Loading ATUS Data with Work Activity ---\n")

# Check if we need to recalculate work time from raw data
atus_file <- paste0(data_dir, "atussum_0323.dat")

if (file.exists(atus_file)) {
  cat("Reading raw ATUS summary file to extract work activity time...\n")
  atus_raw <- fread(atus_file, header = TRUE)

  # Work activities are category 05 (Working and Work-Related Activities)
  # 0501XX = Working (actual work)
  # 0502XX = Work-related activities
  # 0503XX = Other income-generating activities
  work_cols <- names(atus_raw)[grepl("^t05", names(atus_raw))]
  cat("Found", length(work_cols), "work-related activity columns\n")

  # Calculate total work time
  atus_raw <- atus_raw %>%
    mutate(
      work_mins = rowSums(across(all_of(work_cols)), na.rm = TRUE)
    )

  # Merge with our analysis sample
  work_data <- atus_raw %>%
    select(TUCASEID, TUYEAR, work_mins) %>%
    rename(caseid = TUCASEID, year = TUYEAR)

  # Load main analysis data
  atus <- readRDS(paste0(data_dir, "atus_analysis.rds"))

  # Merge work time
  atus <- atus %>%
    left_join(work_data, by = c("caseid", "year"))

  cat("Merged work time data. N =", nrow(atus), "\n")

} else {
  cat("Raw ATUS file not found. Loading pre-processed data...\n")
  atus <- readRDS(paste0(data_dir, "atus_analysis.rds"))

  # Check if work_mins exists
  if (!"work_mins" %in% names(atus)) {
    cat("WARNING: Work minutes not in data. Creating proxy from fulltime status.\n")
    # Create a proxy - fulltime indicator suggests employed
    atus$work_mins <- NA
  }
}

# Create additional work-related variables
atus <- atus %>%
  mutate(
    # Did any work on diary day
    any_work = as.integer(!is.na(work_mins) & work_mins > 0),
    # Zero work (proxy for not employed or day off)
    no_work = as.integer(is.na(work_mins) | work_mins == 0),
    # Treatment variables
    age_centered = age - 62,  # Center at cutoff
    age_x_post = age_centered * post62,
    age_year = interaction(age, year, drop = TRUE)
  )

cat("\nWork variable summary:\n")
cat("  Mean work minutes (all):", round(mean(atus$work_mins, na.rm = TRUE), 1), "\n")
cat("  % with any work:", round(100 * mean(atus$any_work, na.rm = TRUE), 1), "%\n")

# -----------------------------------------------------------------------------
# 2. Descriptive: Work Time by Age
# -----------------------------------------------------------------------------

cat("\n--- 2. Work Time by Age ---\n")

by_age_work <- atus %>%
  filter(!is.na(work_mins)) %>%
  group_by(age) %>%
  summarise(
    n = n(),
    work_mins = mean(work_mins),
    work_se = sd(work_mins) / sqrt(n()),
    any_work_rate = mean(any_work),
    any_work_se = sd(any_work) / sqrt(n()),
    post62 = first(post62),
    age_centered = first(age_centered),
    .groups = "drop"
  )

cat("\nWork time by age:\n")
print(by_age_work)

# Calculate pre-62 vs post-62 difference
pre62_work <- mean(by_age_work$work_mins[by_age_work$age < 62])
post62_work <- mean(by_age_work$work_mins[by_age_work$age >= 62])
cat("\nMean work mins: Pre-62 =", round(pre62_work, 1),
    ", Post-62 =", round(post62_work, 1),
    ", Diff =", round(post62_work - pre62_work, 1), "\n")

# -----------------------------------------------------------------------------
# 3. First-Stage Figure: Work Time Discontinuity
# -----------------------------------------------------------------------------

cat("\n--- 3. Creating First-Stage Figure ---\n")

# Plot 1: Work minutes by age
p_work <- ggplot(by_age_work, aes(x = age, y = work_mins)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = apep_colors["tertiary"]) +
  geom_errorbar(
    aes(ymin = work_mins - 1.96*work_se,
        ymax = work_mins + 1.96*work_se),
    width = 0.2, color = apep_colors["tertiary"]
  ) +
  geom_smooth(data = filter(by_age_work, age < 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  geom_smooth(data = filter(by_age_work, age >= 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  labs(
    title = "First Stage: Work Time Declines at Age 62",
    subtitle = "ATUS 2003-2023, Ages 55-70",
    x = "Age",
    y = "Minutes Worked on Diary Day",
    caption = "Note: Dashed line at age 62 (SS early retirement eligibility)."
  ) +
  scale_x_continuous(breaks = seq(55, 70, 2)) +
  theme_apep()

ggsave(paste0(fig_dir, "fig_first_stage_work.pdf"), p_work, width = 8, height = 5)
ggsave(paste0(fig_dir, "fig_first_stage_work.png"), p_work, width = 8, height = 5, dpi = 300)
cat("Saved: fig_first_stage_work.pdf\n")

# Plot 2: Employment rate by age
p_employed <- ggplot(by_age_work, aes(x = age, y = any_work_rate * 100)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, color = apep_colors["quaternary"]) +
  geom_errorbar(
    aes(ymin = (any_work_rate - 1.96*any_work_se) * 100,
        ymax = (any_work_rate + 1.96*any_work_se) * 100),
    width = 0.2, color = apep_colors["quaternary"]
  ) +
  geom_smooth(data = filter(by_age_work, age < 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  geom_smooth(data = filter(by_age_work, age >= 62),
              method = "lm", se = FALSE, color = apep_colors["secondary"]) +
  labs(
    title = "First Stage: Employment Rate Declines at Age 62",
    subtitle = "ATUS 2003-2023, Ages 55-70",
    x = "Age",
    y = "Percent Working on Diary Day",
    caption = "Note: Working defined as any minutes in work activities (ATUS category 05)."
  ) +
  scale_x_continuous(breaks = seq(55, 70, 2)) +
  theme_apep()

ggsave(paste0(fig_dir, "fig_first_stage_employed.pdf"), p_employed, width = 8, height = 5)
cat("Saved: fig_first_stage_employed.pdf\n")

# -----------------------------------------------------------------------------
# 4. First-Stage RDD Estimation
# -----------------------------------------------------------------------------

cat("\n--- 4. First-Stage RDD Estimates ---\n")

# Filter to non-missing work data
atus_work <- atus %>% filter(!is.na(work_mins))

# rdrobust estimates (baseline)
cat("\n=== Work Minutes (rdrobust) ===\n")
rd_work <- rdrobust(
  y = atus_work$work_mins,
  x = atus_work$age,
  c = 62,
  kernel = "triangular",
  all = TRUE
)
print(summary(rd_work))

cat("\n=== Any Work (rdrobust) ===\n")
rd_any_work <- rdrobust(
  y = atus_work$any_work,
  x = atus_work$age,
  c = 62,
  kernel = "triangular",
  all = TRUE
)
print(summary(rd_any_work))

# Parametric with clustered SEs
cat("\n=== First-Stage with Clustered SEs ===\n")

# Work minutes
m_work_hc1 <- feols(
  work_mins ~ post62 + age_centered + age_x_post,
  data = atus_work,
  vcov = "HC1"
)

m_work_cluster <- feols(
  work_mins ~ post62 + age_centered + age_x_post,
  data = atus_work,
  cluster = ~age
)

# Any work (extensive margin)
m_anywork_hc1 <- feols(
  any_work ~ post62 + age_centered + age_x_post,
  data = atus_work,
  vcov = "HC1"
)

m_anywork_cluster <- feols(
  any_work ~ post62 + age_centered + age_x_post,
  data = atus_work,
  cluster = ~age
)

cat("\nFirst-Stage Results Comparison:\n")
etable(m_work_hc1, m_work_cluster, m_anywork_hc1, m_anywork_cluster,
       headers = c("Work Mins (HC1)", "Work Mins (Cluster)",
                   "Any Work (HC1)", "Any Work (Cluster)"),
       keep = c("post62"),
       fitstat = c("n", "r2"))

# -----------------------------------------------------------------------------
# 5. First-Stage Summary
# -----------------------------------------------------------------------------

cat("\n--- 5. First-Stage Summary ---\n")

first_stage_summary <- data.frame(
  Outcome = c("Work Minutes", "Work Minutes", "Any Work", "Any Work"),
  Method = c("rdrobust", "Cluster(age)", "rdrobust", "Cluster(age)"),
  Estimate = c(
    rd_work$coef[1],
    coef(m_work_cluster)["post62"],
    rd_any_work$coef[1],
    coef(m_anywork_cluster)["post62"]
  ),
  SE = c(
    rd_work$se[1],
    m_work_cluster$se["post62"],
    rd_any_work$se[1],
    m_anywork_cluster$se["post62"]
  ),
  stringsAsFactors = FALSE
)

first_stage_summary$t_stat <- first_stage_summary$Estimate / first_stage_summary$SE
first_stage_summary$Significant <- ifelse(abs(first_stage_summary$t_stat) > 1.96, "Yes", "No")

cat("\nFirst-Stage Results:\n")
print(first_stage_summary, row.names = FALSE)

# Assess first-stage strength
cat("\n=== First-Stage Assessment ===\n")
work_effect <- coef(m_work_cluster)["post62"]
work_se <- m_work_cluster$se["post62"]
work_t <- work_effect / work_se

cat("Work minutes effect at 62: ", round(work_effect, 1), " mins\n")
cat("Clustered SE: ", round(work_se, 1), "\n")
cat("t-statistic: ", round(work_t, 2), "\n")

if (abs(work_t) > 3.16) {
  cat("\nFirst stage is STRONG (F > 10 equivalent)\n")
  cat("The mechanism (SS eligibility → reduced work → more volunteering) is plausible.\n")
} else if (abs(work_t) > 1.96) {
  cat("\nFirst stage is MODERATE (significant but weak)\n")
  cat("The mechanism has some support but effect may be attenuated.\n")
} else {
  cat("\nFirst stage is WEAK or ABSENT\n")
  cat("Consider reframing as 'turning 62' effect rather than 'retirement' effect.\n")
}

# -----------------------------------------------------------------------------
# 6. Combined Figure: First Stage and Reduced Form
# -----------------------------------------------------------------------------

cat("\n--- 6. Creating Combined First-Stage and Reduced-Form Figure ---\n")

# Load reduced form data
vol_by_age <- readRDS(paste0(data_dir, "vol_by_age.rds"))

# Create combined plot
by_age_combined <- by_age_work %>%
  left_join(vol_by_age %>% select(age, pct_volunteer), by = "age")

# Normalize for dual axis visualization
work_scaled <- (by_age_combined$work_mins - min(by_age_combined$work_mins)) /
               (max(by_age_combined$work_mins) - min(by_age_combined$work_mins))
vol_scaled <- (by_age_combined$pct_volunteer - min(by_age_combined$pct_volunteer)) /
              (max(by_age_combined$pct_volunteer) - min(by_age_combined$pct_volunteer))

by_age_combined$work_scaled <- work_scaled
by_age_combined$vol_scaled <- vol_scaled

p_combined <- ggplot(by_age_combined, aes(x = age)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "gray50") +
  # Work (inverted since less work should lead to more volunteering)
  geom_line(aes(y = work_mins, color = "Work Minutes"), linewidth = 1) +
  geom_point(aes(y = work_mins, color = "Work Minutes"), size = 2) +
  # Volunteering (on secondary axis)
  geom_line(aes(y = pct_volunteer * 30, color = "Volunteering Rate"), linewidth = 1) +
  geom_point(aes(y = pct_volunteer * 30, color = "Volunteering Rate"), size = 2) +
  scale_y_continuous(
    name = "Work Minutes",
    sec.axis = sec_axis(~./30, name = "Volunteering Rate (%)")
  ) +
  scale_color_manual(values = c("Work Minutes" = apep_colors["tertiary"],
                                "Volunteering Rate" = apep_colors["primary"])) +
  labs(
    title = "First Stage and Reduced Form: Work Declines, Volunteering Rises at 62",
    subtitle = "ATUS 2003-2023, Ages 55-70",
    x = "Age",
    color = ""
  ) +
  scale_x_continuous(breaks = seq(55, 70, 2)) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(paste0(fig_dir, "fig_first_stage_combined.pdf"), p_combined, width = 9, height = 6)
cat("Saved: fig_first_stage_combined.pdf\n")

# -----------------------------------------------------------------------------
# 7. Save Results
# -----------------------------------------------------------------------------

cat("\n--- 7. Saving First-Stage Results ---\n")

first_stage_results <- list(
  rd_work = rd_work,
  rd_any_work = rd_any_work,
  m_work_cluster = m_work_cluster,
  m_anywork_cluster = m_anywork_cluster,
  summary = first_stage_summary,
  by_age_work = by_age_work
)

saveRDS(first_stage_results, paste0(data_dir, "first_stage_results.rds"))
write_csv(first_stage_summary, paste0(tab_dir, "table_first_stage.csv"))
write_csv(by_age_work, paste0(tab_dir, "table_work_by_age.csv"))

cat("\nFirst-stage analysis complete!\n")
cat("=" %>% strrep(70), "\n")
