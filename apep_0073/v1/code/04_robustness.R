# ==============================================================================
# APEP Paper 93: SNAP Work Requirements and Employment
# 04_robustness.R - Robustness checks
# ==============================================================================

source("00_packages.R")

# Load data
state_year <- readRDS("../data/state_year.rds")
pums_merged <- readRDS("../data/pums_merged.rds")

# ------------------------------------------------------------------------------
# 1. Placebo Test: Adults 50-64 (exempt from ABAWD)
# ------------------------------------------------------------------------------

cat("\n=== Placebo: Exempt Adults 50-64 ===\n")

placebo_sample <- pums_merged %>%
  filter(exempt_age == 1) %>%
  filter(!is.na(employed)) %>%
  filter(!is.na(waiver))

placebo_state_year <- placebo_sample %>%
  group_by(ST, year, first_treat, treated, work_req) %>%
  summarize(
    employed = weighted.mean(employed, w = PWGTP, na.rm = TRUE),
    n_obs = n(),
    pop = sum(PWGTP),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(ST)),
    G = first_treat
  )

# Run CS on placebo sample
cs_placebo <- att_gt(
  yname = "employed",
  tname = "year",
  idname = "state_id",
  gname = "G",
  data = placebo_state_year,
  control_group = "nevertreated",
  weightsname = "pop",
  clustervars = "state_id",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

att_placebo <- aggte(cs_placebo, type = "simple")
cat("\nPlacebo (50-64) ATT:\n")
print(att_placebo)

saveRDS(cs_placebo, "../data/cs_placebo.rds")

# ------------------------------------------------------------------------------
# 2. Triple Difference: ABAWD-eligible vs Exempt
# ------------------------------------------------------------------------------

cat("\n=== Triple Difference ===\n")

# Create combined sample
triple_sample <- pums_merged %>%
  filter(AGEP >= 18 & AGEP <= 64) %>%
  filter(has_disability == 0) %>%
  filter(!is.na(employed)) %>%
  filter(!is.na(waiver)) %>%
  mutate(
    abawd = abawd_eligible
  )

triple_state_year <- triple_sample %>%
  group_by(ST, year, first_treat, treated, work_req, abawd) %>%
  summarize(
    employed = weighted.mean(employed, w = PWGTP, na.rm = TRUE),
    pop = sum(PWGTP),
    .groups = "drop"
  )

# Triple diff regression
triple_diff <- feols(
  employed ~ treated * abawd | ST + year + ST:abawd + year:abawd,
  data = triple_state_year,
  weights = ~pop,
  cluster = ~ST
)

cat("\nTriple Difference Results:\n")
summary(triple_diff)

saveRDS(triple_diff, "../data/triple_diff.rds")

# ------------------------------------------------------------------------------
# 3. Heterogeneity by Education
# ------------------------------------------------------------------------------

cat("\n=== Heterogeneity by Education ===\n")

# Low education sample (less than HS or HS only)
low_educ_sample <- pums_merged %>%
  filter(abawd_eligible == 1) %>%
  filter(less_than_hs == 1 | hs_only == 1) %>%
  filter(!is.na(employed)) %>%
  filter(!is.na(waiver))

low_educ_sy <- low_educ_sample %>%
  group_by(ST, year, first_treat, treated) %>%
  summarize(
    employed = weighted.mean(employed, w = PWGTP, na.rm = TRUE),
    pop = sum(PWGTP),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(ST)),
    G = first_treat
  )

cs_low_educ <- att_gt(
  yname = "employed",
  tname = "year",
  idname = "state_id",
  gname = "G",
  data = low_educ_sy,
  control_group = "nevertreated",
  weightsname = "pop",
  clustervars = "state_id",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

att_low_educ <- aggte(cs_low_educ, type = "simple")
cat("\nLow Education ATT:\n")
print(att_low_educ)

saveRDS(cs_low_educ, "../data/cs_low_educ.rds")

# ------------------------------------------------------------------------------
# 4. Heterogeneity by Age
# ------------------------------------------------------------------------------

cat("\n=== Heterogeneity by Age ===\n")

# Young adults (18-29)
young_sample <- pums_merged %>%
  filter(AGEP >= 18 & AGEP <= 29) %>%
  filter(has_disability == 0) %>%
  filter(!is.na(employed)) %>%
  filter(!is.na(waiver))

young_sy <- young_sample %>%
  group_by(ST, year, first_treat, treated) %>%
  summarize(
    employed = weighted.mean(employed, w = PWGTP, na.rm = TRUE),
    pop = sum(PWGTP),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(ST)),
    G = first_treat
  )

cs_young <- att_gt(
  yname = "employed",
  tname = "year",
  idname = "state_id",
  gname = "G",
  data = young_sy,
  control_group = "nevertreated",
  weightsname = "pop",
  clustervars = "state_id",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

att_young <- aggte(cs_young, type = "simple")
cat("\nYoung Adults (18-29) ATT:\n")
print(att_young)

saveRDS(cs_young, "../data/cs_young.rds")

cat("\n=== Robustness Checks Complete ===\n")
