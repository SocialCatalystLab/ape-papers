# =============================================================================
# 04_robustness.R
# Robustness Checks Including Border Discontinuity Design
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Data
# =============================================================================

qwi <- readRDS("data/qwi_analysis.rds")
qwi_border <- readRDS("data/qwi_border.rds")
border_pairs <- readRDS("data/border_pairs.rds")

cat("Full sample:", nrow(qwi), "observations\n")
cat("Border sample:", nrow(qwi_border), "observations\n")
cat("Border pairs:", nrow(border_pairs), "\n")

# =============================================================================
# Robustness 1: Border County-Pair Design
# =============================================================================
# Following Dube, Lester & Reich (2010) minimum wage methodology
# Compare counties on opposite sides of state borders

cat("\n=== Border County-Pair Design ===\n")

# Collapse to county-quarter-pair level
border_panel <- qwi_border %>%
  group_by(pair_id, county_fips, side, year, quarter, qtr_num) %>%
  summarise(
    EarnHirAS = weighted.mean(EarnHirAS, Emp, na.rm = TRUE),
    total_emp = sum(Emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    treated = side == "treated"
  )

# Get treatment timing for each pair
pair_timing <- qwi_border %>%
  filter(side == "treated") %>%
  select(pair_id, cohort) %>%
  distinct()

border_panel <- border_panel %>%
  left_join(pair_timing, by = "pair_id") %>%
  mutate(
    post = qtr_num >= cohort & treated,
    rel_qtr = if_else(treated, qtr_num - cohort, NA_real_)
  )

# Border DiD with pair × quarter fixed effects
border_did <- feols(
  log_earn_hire ~ post | pair_id^qtr_num,
  data = border_panel,
  cluster = ~pair_id
)

cat("Border DiD Result:\n")
print(summary(border_did))

saveRDS(border_did, "data/border_did.rds")

# =============================================================================
# Robustness 2: Border Design by Sex
# =============================================================================

cat("\n=== Border Design by Sex ===\n")

border_sex <- qwi_border %>%
  group_by(pair_id, county_fips, side, sex_label, year, quarter, qtr_num) %>%
  summarise(
    EarnHirAS = weighted.mean(EarnHirAS, Emp, na.rm = TRUE),
    total_emp = sum(Emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    treated = side == "treated"
  ) %>%
  left_join(pair_timing, by = "pair_id") %>%
  mutate(
    post = qtr_num >= cohort & treated,
    female = sex_label == "Female"
  )

# DDD: Border × Post × Female
border_ddd <- feols(
  log_earn_hire ~ post * female | pair_id^qtr_num^sex_label,
  data = border_sex,
  cluster = ~pair_id
)

cat("Border DDD (Gender Gap Effect):\n")
print(summary(border_ddd))

saveRDS(border_ddd, "data/border_ddd.rds")

# =============================================================================
# Robustness 3: Placebo Tests
# =============================================================================

cat("\n=== Placebo Tests ===\n")

# Placebo 1: Fake treatment 2 years earlier
qwi_placebo <- qwi %>%
  filter(qtr_num < min(cohort[cohort > 0], na.rm = TRUE)) %>%  # Pre-treatment only

mutate(
    fake_cohort = case_when(
      state_fips == "08" ~ 2019 * 4 + 1,  # CO: 2 years early
      state_fips == "09" ~ 2019 * 4 + 4,  # CT
      state_fips == "32" ~ 2019 * 4 + 4,  # NV
      TRUE ~ 0
    ),
    fake_post = qtr_num >= fake_cohort & fake_cohort > 0,
    county_id = as.numeric(factor(county_fips))
  )

placebo_twfe <- feols(
  log_earn_hire ~ fake_post | county_fips + qtr_num,
  data = qwi_placebo,
  cluster = "state_fips"
)

cat("Placebo (fake treatment 2 years early):\n")
print(summary(placebo_twfe))

saveRDS(placebo_twfe, "data/placebo_twfe.rds")

# =============================================================================
# Robustness 4: Alternative Control Groups (TWFE approach)
# =============================================================================

cat("\n=== Alternative Control Groups (TWFE) ===\n")

# Use TWFE with never-treated only as controls (simpler, more robust)
qwi_panel <- qwi %>%
  group_by(county_fips, state_fips, qtr_num, cohort) %>%
  summarise(
    log_earn_hire = log(weighted.mean(EarnHirAS, Emp, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(
    post = cohort > 0 & qtr_num >= cohort
  )

twfe_never <- feols(
  log_earn_hire ~ post | county_fips + qtr_num,
  data = qwi_panel,
  cluster = "state_fips"
)

cat("TWFE with all controls:\n")
print(summary(twfe_never))

saveRDS(twfe_never, "data/twfe_never.rds")

# =============================================================================
# Robustness 5: Exclude CA/WA (Largest States) - TWFE
# =============================================================================

cat("\n=== Exclude CA/WA (TWFE) ===\n")

qwi_no_cawa_panel <- qwi %>%
  filter(!state_fips %in% c("06", "53")) %>%
  group_by(county_fips, state_fips, qtr_num, cohort) %>%
  summarise(
    log_earn_hire = log(weighted.mean(EarnHirAS, Emp, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(post = cohort > 0 & qtr_num >= cohort)

twfe_no_cawa <- feols(
  log_earn_hire ~ post | county_fips + qtr_num,
  data = qwi_no_cawa_panel,
  cluster = "state_fips"
)

cat("TWFE excluding CA/WA:\n")
print(summary(twfe_no_cawa))

saveRDS(twfe_no_cawa, "data/twfe_no_cawa.rds")

# =============================================================================
# Summary of Robustness Results
# =============================================================================

cat("\n=== Robustness Summary ===\n")

robustness_table <- tibble(
  Specification = c(
    "Main (C-S)",
    "Border county-pairs",
    "TWFE (all controls)",
    "Exclude CA/WA (TWFE)",
    "Placebo (2 years early)"
  ),
  ATT = c(
    readRDS("data/att_overall.rds")$overall.att,
    coef(border_did)["postTRUE"],
    coef(twfe_never)["postTRUE"],
    coef(twfe_no_cawa)["postTRUE"],
    coef(placebo_twfe)["fake_postTRUE"]
  ),
  SE = c(
    readRDS("data/att_overall.rds")$overall.se,
    se(border_did)["postTRUE"],
    se(twfe_never)["postTRUE"],
    se(twfe_no_cawa)["postTRUE"],
    se(placebo_twfe)["fake_postTRUE"]
  )
) %>%
  mutate(
    t_stat = ATT / SE,
    significant = abs(t_stat) > 1.96
  )

print(robustness_table)

saveRDS(robustness_table, "data/robustness_table.rds")

cat("\n=== Robustness Checks Complete ===\n")
