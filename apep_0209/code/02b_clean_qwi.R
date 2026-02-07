################################################################################
# 02b_clean_qwi.R
# Salary Transparency Laws and Labor Market Dynamics
#
# Cleans QWI data and constructs analysis panel
# Unit: state x quarter x sex x industry -> analysis-ready panel
#
# --- Input/Output Provenance ---
# INPUTS:
#   data/qwi_raw.rds              <- 01b_fetch_qwi.R
#   data/transparency_laws.rds    <- 00_policy_data.R
# OUTPUTS:
#   data/qwi_panel.rds            (state x quarter x sex x industry panel)
#   data/qwi_agg.rds              (state x quarter aggregate, sex=0, industry=00)
#   data/qwi_gender_gap.rds       (state x quarter x industry gender gap panel)
################################################################################

source("code/00_packages.R")

cat("=== Cleaning QWI Data ===\n\n")

# ============================================================================
# 1. Load Raw Data
# ============================================================================

qwi_raw <- readRDS("data/qwi_raw.rds")
laws <- readRDS("data/transparency_laws.rds")

cat("Raw QWI:", nrow(qwi_raw), "rows\n")
cat("Columns:", paste(names(qwi_raw), collapse = ", "), "\n\n")

# ============================================================================
# 2. Clean and Type-Convert
# ============================================================================

# Convert numeric variables from character
numeric_vars <- c("Emp", "EarnS", "HirA", "Sep", "FrmJbC", "FrmJbLs",
                   "Payroll", "TurnOvrS")

# Standardize column names (Census API returns varying case)
names(qwi_raw) <- tolower(names(qwi_raw))

# Fix column name mapping (raw data has: state, year, quarter, sex)
qwi <- qwi_raw %>%
  rename(
    statefip = state,
    sex_code = sex
  ) %>%
  mutate(
    statefip = as.integer(statefip),
    year = as.integer(year),
    quarter = as.integer(quarter),
    sex_code = as.integer(sex_code),
    # Convert all numeric vars
    across(any_of(tolower(numeric_vars)), ~ as.numeric(.x))
  )

cat("After type conversion:", nrow(qwi), "rows\n")
cat("States:", n_distinct(qwi$statefip), "\n")
cat("Years:", min(qwi$year), "-", max(qwi$year), "\n")
cat("Industries:", n_distinct(qwi$industry), "\n")
cat("Sex codes:", paste(sort(unique(qwi$sex_code)), collapse = ", "), "\n\n")

# ============================================================================
# 3. Construct Time Variables
# ============================================================================

qwi <- qwi %>%
  mutate(
    # Sequential quarter number for panel estimation
    quarter_num = (year - min(year)) * 4 + quarter,
    # Date for plotting
    date = as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01"))
  )

cat("Quarter range:", min(qwi$quarter_num), "-", max(qwi$quarter_num), "\n")

# ============================================================================
# 4. Merge Treatment Timing
# ============================================================================

# Create quarterly treatment timing
# For QWI, treatment starts in the first quarter the law is effective
law_timing <- laws %>%
  select(statefip, first_treat, effective_date) %>%
  mutate(
    # First treated quarter: quarter when law takes effect
    first_treat_year_q = case_when(
      first_treat == 0 ~ 0L,
      TRUE ~ as.integer(first_treat)
    ),
    # Quarterly treatment: which quarter within the year
    first_treat_qtr = case_when(
      first_treat == 0 ~ 0L,
      is.na(effective_date) ~ 1L,
      TRUE ~ as.integer(ceiling(as.integer(format(effective_date, "%m")) / 3))
    ),
    # Sequential quarter number for first treatment
    first_treat_quarter_num = case_when(
      first_treat == 0 ~ 0L,
      TRUE ~ as.integer((first_treat_year_q - 2012L) * 4L + first_treat_qtr)
    )
  )

qwi <- qwi %>%
  left_join(law_timing, by = "statefip") %>%
  mutate(
    # Treatment indicators
    ever_treated = first_treat > 0,
    post = case_when(
      first_treat == 0 ~ FALSE,
      first_treat > max(year) ~ FALSE,  # Laws outside sample (IL, MD, MN)
      TRUE ~ quarter_num >= first_treat_quarter_num
    ),
    treat_post = ever_treated & post,
    # Event time in quarters
    event_quarter = case_when(
      first_treat == 0 ~ NA_integer_,
      TRUE ~ quarter_num - first_treat_quarter_num
    ),
    # Cohort group for Callaway-Sant'Anna (use quarterly numbering)
    g = case_when(
      first_treat == 0 ~ 0L,
      first_treat > max(year) ~ 0L,  # Not-yet-treated = 0
      TRUE ~ first_treat_quarter_num
    )
  )

# Mark in-sample treated (exclude IL, MD, MN with first_treat >= 2025)
qwi <- qwi %>%
  mutate(
    in_sample_treated = first_treat > 0 & first_treat <= 2024
  )

cat("\nTreatment summary:\n")
cat("In-sample treated states:", n_distinct(qwi$statefip[qwi$in_sample_treated]), "\n")
cat("Never-treated states:", n_distinct(qwi$statefip[qwi$first_treat == 0]), "\n")
cat("Treated post observations:", sum(qwi$treat_post, na.rm = TRUE), "\n")

# ============================================================================
# 5. Construct Outcome Variables
# ============================================================================

qwi <- qwi %>%
  mutate(
    # Log outcomes (add small constant for zeros)
    log_earns = log(pmax(earns, 1)),
    log_emp = log(pmax(emp, 1)),
    log_hira = log(pmax(hira, 1)),
    log_sep = log(pmax(sep, 1)),
    log_frmjbc = log(pmax(frmjbc, 1)),
    log_frmjbls = log(pmax(frmjbls, 1)),
    log_payroll = log(pmax(payroll, 1)),
    # Rates (per employee)
    hire_rate = ifelse(emp > 0, hira / emp, NA_real_),
    sep_rate = ifelse(emp > 0, sep / emp, NA_real_),
    net_job_creation_rate = ifelse(emp > 0, (frmjbc - frmjbls) / emp, NA_real_)
  )

# ============================================================================
# 6. Construct Industry Classifications
# ============================================================================

qwi <- qwi %>%
  mutate(
    industry_label = case_when(
      industry == "00" ~ "All Industries",
      industry == "44-45" ~ "Retail Trade",
      industry == "72" ~ "Accommodation & Food",
      industry == "52" ~ "Finance & Insurance",
      industry == "54" ~ "Professional Services",
      TRUE ~ industry
    ),
    high_bargaining = industry %in% c("52", "54"),
    low_bargaining = industry %in% c("44-45", "72"),
    is_aggregate = industry == "00"
  )

# ============================================================================
# 7. Create Aggregate Panel (state x quarter, sex=0, industry=00)
# ============================================================================

qwi_agg <- qwi %>%
  filter(sex_code == 0, industry == "00") %>%
  select(statefip, year, quarter, quarter_num, date,
         first_treat, first_treat_quarter_num, ever_treated, post, treat_post,
         event_quarter, g, in_sample_treated,
         emp, earns, hira, sep, frmjbc, frmjbls, payroll, turnovrs,
         log_earns, log_emp, log_hira, log_sep, log_frmjbc, log_frmjbls,
         log_payroll, hire_rate, sep_rate, net_job_creation_rate)

cat("\nAggregate panel (state x quarter):", nrow(qwi_agg), "rows\n")
cat("  States:", n_distinct(qwi_agg$statefip), "\n")
cat("  Quarters:", n_distinct(qwi_agg$quarter_num), "\n")

# ============================================================================
# 8. Create Gender Gap Panel
# ============================================================================

# Pivot sex-disaggregated data to compute gender gaps
qwi_by_sex <- qwi %>%
  filter(sex_code %in% c(1, 2)) %>%
  select(statefip, year, quarter, quarter_num, date, industry, industry_label,
         high_bargaining, low_bargaining, is_aggregate,
         first_treat, first_treat_quarter_num, ever_treated, post, treat_post,
         event_quarter, g, in_sample_treated,
         sex_code, earns, emp, hira, sep) %>%
  pivot_wider(
    names_from = sex_code,
    values_from = c(earns, emp, hira, sep),
    names_sep = "_"
  ) %>%
  mutate(
    # Gender gaps (male - female in logs)
    earns_gap = log(pmax(earns_1, 1)) - log(pmax(earns_2, 1)),
    # Gender ratios
    emp_ratio_f = ifelse(emp_1 + emp_2 > 0, emp_2 / (emp_1 + emp_2), NA_real_),
    # Separation rates by gender
    sep_rate_m = ifelse(emp_1 > 0, sep_1 / emp_1, NA_real_),
    sep_rate_f = ifelse(emp_2 > 0, sep_2 / emp_2, NA_real_),
    sep_rate_gap = sep_rate_f - sep_rate_m,
    # Hire rates by gender
    hire_rate_m = ifelse(emp_1 > 0, hira_1 / emp_1, NA_real_),
    hire_rate_f = ifelse(emp_2 > 0, hira_2 / emp_2, NA_real_),
    hire_rate_gap = hire_rate_f - hire_rate_m
  )

cat("\nGender gap panel:", nrow(qwi_by_sex), "rows\n")

# ============================================================================
# 9. Summary Statistics
# ============================================================================

cat("\n=== QWI Summary Statistics (Aggregate, Pre-Treatment 2012-2020) ===\n")
qwi_agg %>%
  filter(year <= 2020) %>%
  group_by(treated = in_sample_treated) %>%
  summarize(
    n_obs = n(),
    mean_emp = mean(emp, na.rm = TRUE),
    mean_earns = mean(earns, na.rm = TRUE),
    mean_hire_rate = mean(hire_rate, na.rm = TRUE),
    mean_sep_rate = mean(sep_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\n=== Gender Earnings Gap (Aggregate Industry, Pre-Treatment) ===\n")
qwi_by_sex %>%
  filter(is_aggregate, year <= 2020) %>%
  group_by(treated = in_sample_treated) %>%
  summarize(
    mean_gap = mean(earns_gap, na.rm = TRUE),
    sd_gap = sd(earns_gap, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

# ============================================================================
# 10. Save
# ============================================================================

saveRDS(qwi, "data/qwi_panel.rds")
saveRDS(qwi_agg, "data/qwi_agg.rds")
saveRDS(qwi_by_sex, "data/qwi_gender_gap.rds")

cat("\nSaved:\n")
cat("  data/qwi_panel.rds       (", nrow(qwi), " rows - full panel)\n")
cat("  data/qwi_agg.rds         (", nrow(qwi_agg), " rows - aggregate)\n")
cat("  data/qwi_gender_gap.rds  (", nrow(qwi_by_sex), " rows - gender gap)\n")
cat("\n=== QWI Cleaning Complete ===\n")
