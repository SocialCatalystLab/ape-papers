##############################################################################
# 02_clean_data.R — Construct treatment variables and analysis dataset
# APEP-0222 v2: Educational Content Restriction Laws and Teacher Labor Markets
# Revision: primary panel = NAICS 6111 (K-12 Schools)
##############################################################################

source("00_packages.R")

cat("=== Constructing analysis dataset ===\n")

# Load raw QWI data
qwi_raw <- readRDS("../data/qwi_raw.rds")

# ============================================================================
# TREATMENT CODING: Educational Content Restriction Laws
# ============================================================================
# Sources: PEN America Index of Educational Gag Orders, Heritage Foundation,
#          UCLA CRT Forward Tracking Project, Chalkbeat CRT Map
#
# Inclusion criteria: State-level law or binding executive order that restricts
# K-12 instruction on race, gender, or "divisive concepts." Must be enacted
# (signed by governor or issued as executive order), not just introduced.
#
# Treatment timing: Quarter in which the law becomes effective.
# ============================================================================

treatment_laws <- tribble(
  ~state_fips, ~state_name,    ~bill,           ~signed_date,   ~effective_date, ~stringency,
  "16",        "Idaho",        "HB 377",        "2021-04-28",   "2021-07-01",    "strong",
  "40",        "Oklahoma",     "HB 1775",       "2021-05-07",   "2021-07-01",    "strong",
  "47",        "Tennessee",    "SB 623/HB 580", "2021-05-25",   "2021-07-01",    "strong",
  "19",        "Iowa",         "HF 802",        "2021-06-08",   "2021-07-01",    "strong",
  "48",        "Texas",        "HB 3979",       "2021-06-15",   "2021-09-01",    "moderate",
  "45",        "South Carolina","Budget Proviso","2021-06-29",  "2021-07-01",    "weak",
  "33",        "New Hampshire","HB 2",          "2021-06-25",   "2021-11-01",    "strong",
  "04",        "Arizona",      "HB 2906",       "2021-07-09",   "2021-09-29",    "moderate",
  "38",        "North Dakota", "HB 1508",       "2021-04-19",   "2021-08-01",    "moderate",
  "12",        "Florida",      "HB 7 (STOP WOKE)","2022-03-22","2022-07-01",    "strong",
  "13",        "Georgia",      "HB 1084",       "2022-04-28",   "2022-07-01",    "moderate",
  "28",        "Mississippi",  "SB 2113",       "2022-03-14",   "2022-07-01",    "moderate",
  "01",        "Alabama",      "HB 312",        "2022-04-14",   "2022-07-01",    "moderate",
  "46",        "South Dakota", "EO 2022-02",    "2022-04-05",   "2022-04-05",    "weak",
  "51",        "Virginia",     "EO 1",          "2022-01-15",   "2022-01-15",    "weak",
  "49",        "Utah",         "HB 427",        "2022-03-23",   "2022-05-04",    "moderate",
  "22",        "Louisiana",    "HB 122",        "2022-06-15",   "2022-08-01",    "moderate",
  "54",        "West Virginia","HB 2595",       "2022-03-10",   "2022-06-07",    "moderate",
  "05",        "Arkansas",     "SB 294/EO",     "2023-03-08",   "2023-08-01",    "strong",
  "18",        "Indiana",      "HB 1608",       "2023-05-01",   "2023-07-01",    "moderate",
  "21",        "Kentucky",     "SB 150",        "2023-03-29",   "2023-06-29",    "moderate",
  "30",        "Montana",      "HB 30",         "2023-02-17",   "2023-07-01",    "weak",
  "37",        "North Carolina","HB 823",       "2023-10-11",   "2023-10-11",    "moderate"
)

# Convert dates and compute treatment quarter
treatment_laws <- treatment_laws %>%
  mutate(
    effective_date = as.Date(effective_date),
    treat_year = year(effective_date),
    treat_quarter = quarter(effective_date),
    first_full_q_year = ifelse(
      day(effective_date) <= 15 & month(effective_date) %in% c(1, 4, 7, 10),
      treat_year,
      ifelse(treat_quarter == 4, treat_year + 1, treat_year)
    ),
    first_full_q = ifelse(
      day(effective_date) <= 15 & month(effective_date) %in% c(1, 4, 7, 10),
      treat_quarter,
      ifelse(treat_quarter == 4, 1, treat_quarter + 1)
    ),
    treat_yq = first_full_q_year + (first_full_q - 1) / 4,
    cohort_label = paste0(first_full_q_year, "Q", first_full_q),
    stringency_score = case_when(
      stringency == "strong" ~ 3L,
      stringency == "moderate" ~ 2L,
      stringency == "weak" ~ 1L
    )
  )

cat(sprintf("Treatment database: %d states\n", nrow(treatment_laws)))
cat("Treatment cohorts:\n")
print(table(treatment_laws$cohort_label))

# Save treatment data
saveRDS(treatment_laws, "../data/treatment_laws.rds")
write_csv(treatment_laws, "../data/treatment_laws.csv")

# ============================================================================
# MERGE TREATMENT WITH QWI DATA
# ============================================================================

panel <- qwi_raw %>%
  left_join(
    treatment_laws %>% select(state_fips, treat_yq, stringency, stringency_score,
                               cohort_label, first_full_q_year, first_full_q),
    by = "state_fips"
  ) %>%
  mutate(
    treated_state = !is.na(treat_yq),
    post = ifelse(treated_state, time_q >= treat_yq, FALSE),
    treat = as.integer(treated_state & post),
    first_treat_q = ifelse(treated_state, treat_yq, 0),
    time_int = (year - 2015) * 4 + quarter,
    first_treat_int = ifelse(treated_state, (first_full_q_year - 2015) * 4 + first_full_q, 0),
    log_emp = log(Emp + 1),
    sep_rate = Sep / (Emp + 1),
    hire_rate = HirA / (Emp + 1),
    log_earn = log(EarnS + 1),
    state_id = as.integer(factor(state_fips))
  )

cat(sprintf("\nPanel dataset: %d observations\n", nrow(panel)))
cat(sprintf("States: %d total, %d treated, %d never-treated\n",
            n_distinct(panel$state_fips),
            n_distinct(panel$state_fips[panel$treated_state]),
            n_distinct(panel$state_fips[!panel$treated_state])))

# ============================================================================
# CREATE INDUSTRY-SPECIFIC PANELS
# ============================================================================

# PRIMARY: K-12 Schools (NAICS 6111)
edu_panel <- panel %>% filter(industry == "6111")

# BROAD Education (NAICS 61) — for robustness comparison with v1
edu_broad_panel <- panel %>% filter(industry == "61")

# Colleges/Universities (NAICS 6112) — for decomposition
college_panel <- panel %>% filter(industry == "6112")

# Healthcare
hc_panel <- panel %>% filter(industry == "62")

# Report suppression at 4-digit level
n_k12_total <- n_distinct(paste(edu_panel$state_fips, edu_panel$time_int))
n_k12_valid <- edu_panel %>% filter(!is.na(Emp), Emp > 0) %>%
  distinct(state_fips, time_int) %>% nrow()
n_k12_suppressed <- n_k12_total - n_k12_valid
cat(sprintf("\nK-12 panel (NAICS 6111): %d obs total, %d valid, %d suppressed (%.1f%%)\n",
            nrow(edu_panel), n_k12_valid, n_k12_suppressed,
            100 * n_k12_suppressed / max(n_k12_total, 1)))
cat(sprintf("Broad education (NAICS 61): %d obs\n", nrow(edu_broad_panel)))
cat(sprintf("College (NAICS 6112): %d obs\n", nrow(college_panel)))
cat(sprintf("Healthcare (NAICS 62): %d obs\n", nrow(hc_panel)))

# ============================================================================
# TRIPLE-DIFF: K-12 (6111) vs HEALTHCARE (62)
# ============================================================================

triple_diff <- panel %>%
  filter(industry %in% c("6111", "62")) %>%
  mutate(
    is_education = as.integer(industry == "6111"),
    DDD = treat * is_education
  )

edu_hc_gap <- panel %>%
  filter(industry %in% c("6111", "62")) %>%
  select(state_fips, year, quarter, time_q, time_int, industry, Emp, EarnS, Sep, HirA, TurnOvrS,
         treated_state, post, treat, first_treat_int, stringency, stringency_score, state_id) %>%
  pivot_wider(
    names_from = industry,
    values_from = c(Emp, EarnS, Sep, HirA, TurnOvrS),
    names_sep = "_"
  ) %>%
  mutate(
    emp_gap = log(Emp_6111 + 1) - log(Emp_62 + 1),
    earn_gap = log(EarnS_6111 + 1) - log(EarnS_62 + 1),
    sep_gap = Sep_6111 / (Emp_6111 + 1) - Sep_62 / (Emp_62 + 1),
    hire_gap = HirA_6111 / (Emp_6111 + 1) - HirA_62 / (Emp_62 + 1)
  )

cat(sprintf("\nK-12 panel: %d obs\n", nrow(edu_panel)))
cat(sprintf("Triple-diff panel (6111 vs 62): %d obs\n", nrow(triple_diff)))

# ============================================================================
# FEMALE SHARE PANEL (sex-disaggregated 6111 data)
# ============================================================================

cat("\n--- Building female share panel ---\n")

if (file.exists("../data/qwi_k12_by_sex.rds")) {
  qwi_sex <- readRDS("../data/qwi_k12_by_sex.rds")

  female_share_panel <- qwi_sex %>%
    filter(!is.na(Emp), Emp > 0) %>%
    select(state_fips, year, quarter, sex_label, Emp) %>%
    pivot_wider(names_from = sex_label, values_from = Emp, names_prefix = "emp_") %>%
    filter(!is.na(emp_Female), !is.na(emp_Male)) %>%
    mutate(
      female_share = emp_Female / (emp_Female + emp_Male),
      time_int = (year - 2015) * 4 + quarter,
      time_q = year + (quarter - 1) / 4
    )

  female_share_panel <- female_share_panel %>%
    left_join(
      treatment_laws %>%
        mutate(first_treat_int_val = (first_full_q_year - 2015) * 4 + first_full_q) %>%
        select(state_fips, treat_yq, first_treat_int_val, stringency, stringency_score),
      by = "state_fips"
    ) %>%
    mutate(
      treated_state = !is.na(treat_yq),
      treat = as.integer(treated_state & time_q >= treat_yq),
      first_treat_int = ifelse(treated_state, first_treat_int_val, 0),
      state_id = as.integer(factor(state_fips))
    ) %>%
    select(-first_treat_int_val)

  saveRDS(female_share_panel, "../data/female_share_panel.rds")
  cat(sprintf("Female share panel: %d obs, mean = %.3f\n",
              nrow(female_share_panel), mean(female_share_panel$female_share, na.rm = TRUE)))
} else {
  cat("WARNING: qwi_k12_by_sex.rds not found.\n")
}

# ============================================================================
# SUMMARY STATISTICS
# ============================================================================

pre_stats <- edu_panel %>%
  filter(year <= 2020, !is.na(Emp), Emp > 0) %>%
  group_by(treated_state) %>%
  summarise(
    n_states = n_distinct(state_fips),
    mean_emp = mean(Emp, na.rm = TRUE),
    sd_emp = sd(Emp, na.rm = TRUE),
    mean_earn = mean(EarnS, na.rm = TRUE),
    mean_sep_rate = mean(Sep / (Emp + 1), na.rm = TRUE),
    mean_hire_rate = mean(HirA / (Emp + 1), na.rm = TRUE),
    mean_turnover = mean(TurnOvrS, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nPre-treatment summary (K-12 Schools, NAICS 6111):\n")
print(pre_stats)

# Save all datasets
saveRDS(panel, "../data/panel.rds")
saveRDS(edu_panel, "../data/edu_panel.rds")
saveRDS(edu_broad_panel, "../data/edu_broad_panel.rds")
saveRDS(college_panel, "../data/college_panel.rds")
saveRDS(hc_panel, "../data/hc_panel.rds")
saveRDS(triple_diff, "../data/triple_diff.rds")
saveRDS(edu_hc_gap, "../data/edu_hc_gap.rds")

cat("\n=== Data cleaning complete ===\n")
