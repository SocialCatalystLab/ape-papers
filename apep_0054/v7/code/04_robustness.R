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
# Robustness 3: Border Event Study (RDD × Event Study)
# =============================================================================
# Shows the border gap (treated - control) at each event time
# This is "RDD meets Event Study" - the spatial discontinuity over time

cat("\n=== Border Event Study (RDD × Event Study) ===\n")

# Get cohort for each pair
pair_cohorts <- qwi_border %>%
  filter(side == "treated") %>%
  distinct(pair_id, cohort)

# Create event-time border data
border_event <- qwi_border %>%
  left_join(pair_cohorts, by = "pair_id", suffix = c("", "_pair")) %>%
  mutate(
    event_time = qtr_num - cohort_pair,
    is_treated_side = as.numeric(side == "treated")
  ) %>%
  filter(event_time >= -12 & event_time <= 8)

# Estimate border gap at each event time
# With pair + event_time FE, coefficient shows treated-control difference
# relative to event time -1
border_event <- border_event %>%
  mutate(event_time_factor = factor(event_time))

border_es <- feols(
  log_earn_hire ~ i(event_time_factor, is_treated_side, ref = "-1") | pair_id + event_time_factor,
  data = border_event,
  cluster = ~pair_id
)

cat("Border Event Study (ref = event time -1):\n")
cat("Coefficients show border gap relative to period -1\n\n")

# Extract and format results
es_coefs <- coef(border_es)
es_ses <- se(border_es)
es_event_times <- as.numeric(gsub("event_time_factor::(-?[0-9]+):is_treated_side", "\\1", names(es_coefs)))

border_es_results <- tibble(
  event_time = es_event_times,
  coef = es_coefs,
  se = es_ses,
  ci_lower = coef - 1.96 * se,
  ci_upper = coef + 1.96 * se
) %>%
  arrange(event_time)

print(border_es_results)

# Also compute the raw border gap at each event time (for plotting)
border_gap_raw <- border_event %>%
  group_by(event_time, side) %>%
  summarise(mean_log = mean(log_earn_hire, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = side, values_from = mean_log) %>%
  mutate(
    border_gap = treated - control,
    border_gap_pct = (exp(border_gap) - 1) * 100
  )

cat("\n=== Raw Border Gap by Event Time ===\n")
print(border_gap_raw)

# Summary statistics
pre_gap <- border_gap_raw %>% filter(event_time < 0) %>% pull(border_gap) %>% mean()
post_gap <- border_gap_raw %>% filter(event_time >= 0) %>% pull(border_gap) %>% mean()
did_gap <- post_gap - pre_gap

cat("\nAverage pre-treatment gap:", round(pre_gap, 4), "(", round((exp(pre_gap)-1)*100, 1), "%)\n")
cat("Average post-treatment gap:", round(post_gap, 4), "(", round((exp(post_gap)-1)*100, 1), "%)\n")
cat("DiD (change in gap):", round(did_gap, 4), "(", round((exp(did_gap)-1)*100, 1), "%)\n")

saveRDS(border_es, "data/border_event_study.rds")
saveRDS(border_es_results, "data/border_es_results.rds")
saveRDS(border_gap_raw, "data/border_gap_raw.rds")

# =============================================================================
# Robustness 4: Placebo Tests
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
