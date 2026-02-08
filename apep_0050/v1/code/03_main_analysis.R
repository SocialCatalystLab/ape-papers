# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 03_main_analysis.R - Main DiD Analysis
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# Load Data
# ============================================================================

message("Loading analysis data...")
cps <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")

message("Individual observations: ", format(nrow(cps), big.mark = ","))
message("State-year observations: ", nrow(state_year))

# ============================================================================
# A) Treatment Timing & Design Mapping (DiD Checklist Step 1-3)
# ============================================================================

message("\n=== A) Treatment Timing & Design Mapping ===")

# Step 1: Plot treatment rollout
treatment_rollout <- state_year %>%
  filter(ever_treated) %>%
  distinct(statefip, state_name, treatment_year, cohort) %>%
  arrange(treatment_year)

message("\nTreatment rollout:")
print(treatment_rollout)

# Step 2: Document cohort sizes
cohort_sizes <- state_year %>%
  filter(year == 2020) %>%  # Pre-treatment year
  group_by(cohort) %>%
  summarise(
    n_states = n(),
    total_obs = sum(n_obs),
    .groups = "drop"
  )

message("\nCohort sizes (based on 2020):")
print(cohort_sizes)

# Step 3: Plot average outcomes by cohort (done in figures script)

# ============================================================================
# B) Callaway-Sant'Anna DiD (Main Specification)
# ============================================================================

message("\n=== B) Callaway-Sant'Anna DiD ===")

# Prepare data for did package
# Requires: individual ID, time, group (treatment timing), outcome
cps_did <- cps %>%
  # Create numeric ID for each observation
  mutate(
    id = row_number(),
    # Group variable: treatment year (0 for never treated)
    G = treatment_year
  ) %>%
  # Keep relevant variables
  select(id, statefip, year, G, log_earnweek, earnwt,
         female, age, educ_cat, race_eth, fulltime)

# Callaway-Sant'Anna estimation
# Using not-yet-treated as control group (more conservative)
message("Running Callaway-Sant'Anna estimation...")

cs_att <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did,
  control_group = "notyettreated",  # Not-yet-treated as controls
  anticipation = 0,
  weightsname = "earnwt",
  clustervars = "statefip",
  base_period = "varying",  # Use period just before treatment
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

# Save raw results
saveRDS(cs_att, "data/cs_att_results.rds")

# Aggregate to event study
es_att <- aggte(cs_att, type = "dynamic", balance_e = -4)
message("\nEvent Study ATT:")
print(summary(es_att))

# Aggregate to overall ATT
overall_att <- aggte(cs_att, type = "simple")
message("\nOverall ATT:")
print(summary(overall_att))

# ============================================================================
# C) Alternative Estimators (Robustness)
# ============================================================================

message("\n=== C) Alternative Estimators ===")

# C.1) Sun-Abraham via fixest
message("Running Sun-Abraham estimation...")

# Create event time indicators
cps_did <- cps_did %>%
  mutate(
    event_time = ifelse(G > 0, year - G, NA_integer_),
    # Cohort variable for sunab
    cohort_year = ifelse(G > 0, G, NA_integer_)
  )

# Sun-Abraham with fixest
sa_model <- feols(
  log_earnweek ~ sunab(cohort_year, year) |
    statefip + year,
  data = cps_did,
  weights = ~earnwt,
  cluster = ~statefip
)

message("\nSun-Abraham results:")
print(summary(sa_model))

# C.2) Gardner Two-Stage
message("Running Gardner two-stage estimation...")

did2s_model <- did2s(
  data = cps_did %>% filter(!is.na(cohort_year) | G == 0),
  yname = "log_earnweek",
  first_stage = ~ 0 | statefip + year,
  second_stage = ~ i(event_time, ref = -1),
  treatment = "G",
  cluster_var = "statefip",
  weights = "earnwt"
)

message("\nGardner two-stage results:")
print(summary(did2s_model))

# ============================================================================
# D) Gender Wage Gap Analysis
# ============================================================================

message("\n=== D) Gender Wage Gap Analysis ===")

# Compute gender wage gap by state-year
# Run regression within each state-year cell
gender_gap_regs <- cps %>%
  group_by(statefip, year) %>%
  nest() %>%
  mutate(
    model = map(data, ~ lm(log_earnweek ~ female + age + I(age^2) +
                             factor(educ_cat) + factor(race_eth),
                           data = .x, weights = earnwt)),
    female_coef = map_dbl(model, ~ coef(.x)["female"]),
    female_se = map_dbl(model, ~ sqrt(vcov(.x)["female", "female"])),
    n = map_int(data, nrow)
  ) %>%
  select(statefip, year, female_coef, female_se, n) %>%
  ungroup()

# Merge with treatment info
gender_gap_panel <- gender_gap_regs %>%
  left_join(
    cps %>% distinct(statefip, treatment_year, ever_treated, cohort),
    by = "statefip"
  ) %>%
  mutate(
    treated = ever_treated & year >= treatment_year,
    event_time = ifelse(ever_treated, year - treatment_year, NA_integer_)
  )

# DiD on gender wage gap
gap_did <- feols(
  female_coef ~ treated | statefip + year,
  data = gender_gap_panel,
  weights = ~n,
  cluster = ~statefip
)

message("\nGender gap DiD:")
print(summary(gap_did))

# Event study on gender gap
gap_es <- feols(
  female_coef ~ sunab(treatment_year, year) | statefip + year,
  data = gender_gap_panel %>% filter(treatment_year > 0 | !ever_treated),
  weights = ~n,
  cluster = ~statefip
)

message("\nGender gap event study:")
print(summary(gap_es))

# Save gender gap results
saveRDS(gender_gap_panel, "data/gender_gap_panel.rds")

# ============================================================================
# E) Heterogeneity Analysis
# ============================================================================

message("\n=== E) Heterogeneity Analysis ===")

# E.1) By gender
cs_att_male <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did %>% filter(female == 0),
  control_group = "notyettreated",
  weightsname = "earnwt",
  clustervars = "statefip"
)

cs_att_female <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did %>% filter(female == 1),
  control_group = "notyettreated",
  weightsname = "earnwt",
  clustervars = "statefip"
)

overall_male <- aggte(cs_att_male, type = "simple")
overall_female <- aggte(cs_att_female, type = "simple")

message("\nHeterogeneity by gender:")
message("Male ATT: ", round(overall_male$overall.att, 4),
        " (SE: ", round(overall_male$overall.se, 4), ")")
message("Female ATT: ", round(overall_female$overall.att, 4),
        " (SE: ", round(overall_female$overall.se, 4), ")")

# E.2) By education
cs_att_college <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did %>% filter(educ_cat %in% c("Bachelor's", "Graduate")),
  control_group = "notyettreated",
  weightsname = "earnwt",
  clustervars = "statefip"
)

cs_att_nocollege <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did %>% filter(!educ_cat %in% c("Bachelor's", "Graduate")),
  control_group = "notyettreated",
  weightsname = "earnwt",
  clustervars = "statefip"
)

overall_college <- aggte(cs_att_college, type = "simple")
overall_nocollege <- aggte(cs_att_nocollege, type = "simple")

message("\nHeterogeneity by education:")
message("College+ ATT: ", round(overall_college$overall.att, 4),
        " (SE: ", round(overall_college$overall.se, 4), ")")
message("No college ATT: ", round(overall_nocollege$overall.att, 4),
        " (SE: ", round(overall_nocollege$overall.se, 4), ")")

# ============================================================================
# F) Save Results
# ============================================================================

results_list <- list(
  cs_att = cs_att,
  es_att = es_att,
  overall_att = overall_att,
  sa_model = sa_model,
  did2s_model = did2s_model,
  gap_did = gap_did,
  gap_es = gap_es,
  het_male = overall_male,
  het_female = overall_female,
  het_college = overall_college,
  het_nocollege = overall_nocollege
)

saveRDS(results_list, "data/main_results.rds")
message("\nSaved all results to data/main_results.rds")

message("\n=== Main Analysis Complete ===")
