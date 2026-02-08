# =============================================================================
# 03_main_analysis.R
# Main Analysis: Staggered DiD with Callaway-Sant'Anna
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Data
# =============================================================================

qwi <- readRDS("data/qwi_analysis.rds")
cat("Loaded QWI analysis data:", nrow(qwi), "observations\n")

# =============================================================================
# Prepare Data for Callaway-Sant'Anna
# =============================================================================

# Create county-quarter panel
# Collapse sex-specific data to county-quarter level for main specification
qwi_panel <- qwi %>%
  group_by(county_fips, state_fips, year, quarter, qtr_num, cohort,
           treated_state, state_abbr) %>%
  summarise(
    EarnHirAS = weighted.mean(EarnHirAS, Emp, na.rm = TRUE),
    EarnS = weighted.mean(EarnS, Emp, na.rm = TRUE),
    total_emp = sum(Emp, na.rm = TRUE),
    total_hires = sum(HirA, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_earn = log(EarnS)
  ) %>%
  # Create numeric ID for county (required by did package)
  mutate(county_id = as.numeric(factor(county_fips)))

cat("County-quarter panel:", nrow(qwi_panel), "observations\n")
cat("Counties:", n_distinct(qwi_panel$county_fips), "\n")
cat("Quarters:", n_distinct(qwi_panel$qtr_num), "\n")

# =============================================================================
# Specification 1: Overall ATT (Callaway-Sant'Anna)
# =============================================================================

cat("\n=== Callaway-Sant'Anna: Overall ATT ===\n")

# Set up the data
cs_data <- qwi_panel %>%
  filter(!is.na(log_earn_hire), is.finite(log_earn_hire)) %>%
  # Ensure cohort = 0 for never-treated
  mutate(cohort = if_else(is.na(cohort) | cohort == 0, 0, cohort))

# Set seed for reproducible bootstrap
set.seed(20240203)

# Run Callaway-Sant'Anna
cs_result <- att_gt(
  yname = "log_earn_hire",
  tname = "qtr_num",
  idname = "county_id",
  gname = "cohort",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",  # Doubly robust
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  clustervars = "state_fips",
  print_details = FALSE
)

# Aggregate to overall ATT
att_overall <- aggte(cs_result, type = "simple", na.rm = TRUE)
print(summary(att_overall))

# Save for tables
saveRDS(cs_result, "data/cs_result.rds")
saveRDS(att_overall, "data/att_overall.rds")

# =============================================================================
# Specification 2: Event Study (Dynamic Effects)
# =============================================================================

cat("\n=== Event Study ===\n")

att_dynamic <- aggte(cs_result, type = "dynamic", na.rm = TRUE,
                     min_e = -12, max_e = 8)
print(summary(att_dynamic))

saveRDS(att_dynamic, "data/att_dynamic.rds")

# =============================================================================
# Specification 3: By Sex (DDD-style)
# =============================================================================

cat("\n=== Analysis by Sex ===\n")

# Run separately for each sex
results_by_sex <- list()

# Set seed for reproducible bootstrap in sex-specific analysis
set.seed(20240203)

for (sx in c("1", "2")) {
  sex_label <- if_else(sx == "1", "Male", "Female")
  cat("Running for:", sex_label, "\n")

  cs_data_sex <- qwi %>%
    filter(sex == sx, !is.na(log_earn_hire), is.finite(log_earn_hire)) %>%
    mutate(
      cohort = if_else(is.na(cohort) | cohort == 0, 0, cohort),
      county_id = as.numeric(factor(county_fips))
    )

  cs_sex <- att_gt(
    yname = "log_earn_hire",
    tname = "qtr_num",
    idname = "county_id",
    gname = "cohort",
    data = cs_data_sex,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000,
    clustervars = "state_fips",
    print_details = FALSE
  )

  att_sex <- aggte(cs_sex, type = "simple", na.rm = TRUE)
  results_by_sex[[sex_label]] <- att_sex

  cat(sex_label, "ATT:", round(att_sex$overall.att, 4),
      "SE:", round(att_sex$overall.se, 4), "\n")
}

saveRDS(results_by_sex, "data/results_by_sex.rds")

# =============================================================================
# Specification 4: TWFE Comparison (fixest)
# =============================================================================

cat("\n=== TWFE Comparison (for reference) ===\n")

# Create post indicator for TWFE
qwi_panel <- qwi_panel %>%
  mutate(post = cohort > 0 & qtr_num >= cohort)

# Standard TWFE for comparison
twfe_result <- feols(
  log_earn_hire ~ post | county_fips + qtr_num,
  data = qwi_panel,
  cluster = "state_fips"
)

print(summary(twfe_result))
saveRDS(twfe_result, "data/twfe_result.rds")

# Sun-Abraham for heterogeneity-robust TWFE
# Create cohort factor for sunab
qwi_panel_sa <- qwi_panel %>%
  mutate(
    cohort_sa = if_else(cohort == 0, Inf, cohort)  # sunab uses Inf for never-treated
  )

sa_result <- feols(
  log_earn_hire ~ sunab(cohort_sa, qtr_num) | county_fips + qtr_num,
  data = qwi_panel_sa,
  cluster = "state_fips"
)

print(summary(sa_result))
saveRDS(sa_result, "data/sa_result.rds")

# =============================================================================
# Summary Table
# =============================================================================

cat("\n=== Results Summary ===\n")

results_table <- tibble(
  Specification = c(
    "Callaway-Sant'Anna (Overall)",
    "TWFE",
    "Sun-Abraham",
    "C-S: Male",
    "C-S: Female"
  ),
  ATT = c(
    att_overall$overall.att,
    coef(twfe_result)["postTRUE"],
    mean(coef(sa_result)[grep("cohort_sa", names(coef(sa_result)))]),
    results_by_sex$Male$overall.att,
    results_by_sex$Female$overall.att
  ),
  SE = c(
    att_overall$overall.se,
    se(twfe_result)["postTRUE"],
    NA,  # Complex for SA
    results_by_sex$Male$overall.se,
    results_by_sex$Female$overall.se
  )
)

print(results_table)

# Gender gap effect (difference in ATT)
gender_gap_effect <- results_by_sex$Female$overall.att - results_by_sex$Male$overall.att
cat("\nGender gap effect (Female - Male):", round(gender_gap_effect, 4), "\n")
cat("Interpretation: Negative = gap narrowing (women's wages fell less)\n")

saveRDS(results_table, "data/results_table.rds")

cat("\n=== Main Analysis Complete ===\n")
