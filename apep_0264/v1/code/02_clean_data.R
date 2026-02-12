## 02_clean_data.R — Construct analysis panel
## Paper: "The Quiet Life Goes Macro" (apep_0243)

source("00_packages.R")

cat("=== CONSTRUCTING ANALYSIS PANEL ===\n")

# ============================================================
# Load raw data
# ============================================================

treatment <- readRDS("../data/treatment_dates.rds")
state_gdp <- readRDS("../data/state_gdp.rds")
state_comp <- readRDS("../data/state_comp.rds")
cbp_raw <- readRDS("../data/cbp_raw.rds")
state_pop <- readRDS("../data/state_pop.rds")

# Try loading BDS
bds_available <- file.exists("../data/bds_raw.rds")
if (bds_available) {
  bds_raw <- readRDS("../data/bds_raw.rds")
  cat("BDS data available.\n")
} else {
  cat("BDS data not available — constructing dynamism from CBP.\n")
}

# ============================================================
# 1. Clean CBP data: establishment counts and employment
# ============================================================

cbp_clean <- cbp_raw %>%
  rename(state_fips = state) %>%
  select(state_fips, year, ESTAB, EMP, PAYANN) %>%
  filter(!is.na(ESTAB), ESTAB > 0) %>%
  mutate(
    year = as.integer(year),
    avg_estab_size = EMP / ESTAB,
    payroll_per_worker = PAYANN / EMP
  )

cat(sprintf("CBP: %d state-year obs, years %d-%d\n",
            nrow(cbp_clean), min(cbp_clean$year), max(cbp_clean$year)))

# Compute establishment entry rate proxy:
# Net entry rate = (ESTAB_t - ESTAB_{t-1}) / ESTAB_{t-1}
cbp_dynamics <- cbp_clean %>%
  arrange(state_fips, year) %>%
  group_by(state_fips) %>%
  mutate(
    estab_lag = lag(ESTAB),
    emp_lag = lag(EMP),
    net_entry_rate = (ESTAB - estab_lag) / estab_lag,
    emp_growth = (EMP - emp_lag) / emp_lag
  ) %>%
  ungroup()

# ============================================================
# 2. Clean BDS data (if available)
# ============================================================

if (bds_available) {
  bds_clean <- bds_raw %>%
    rename(state_fips = state) %>%
    mutate(
      year = as.integer(year),
      FIRM = as.integer(FIRM),
      ESTAB = as.integer(ESTAB),
      ESTABS_ENTRY = as.integer(ESTABS_ENTRY),
      ESTABS_EXIT = as.integer(ESTABS_EXIT),
      JOB_CREATION = as.numeric(JOB_CREATION),
      JOB_DESTRUCTION = as.numeric(JOB_DESTRUCTION),
      EMP = as.integer(EMP)
    ) %>%
    filter(!is.na(ESTAB), ESTAB > 0) %>%
    mutate(
      entry_rate = ESTABS_ENTRY / ESTAB,
      exit_rate = ESTABS_EXIT / ESTAB,
      job_creation_rate = JOB_CREATION / EMP,
      job_destruction_rate = JOB_DESTRUCTION / EMP,
      net_job_creation_rate = (JOB_CREATION - JOB_DESTRUCTION) / EMP,
      reallocation_rate = (JOB_CREATION + JOB_DESTRUCTION) / EMP
    )

  cat(sprintf("BDS: %d state-year obs, years %d-%d\n",
              nrow(bds_clean), min(bds_clean$year), max(bds_clean$year)))
}

# ============================================================
# 3. Construct labor share from CBP payroll + nominal GDP
# ============================================================

# CBP PAYANN = total annual payroll in thousands of dollars
# FRED nominal GDP = millions of dollars
# Labor share = (PAYANN * 1000) / (nominal_gdp * 1e6)
# = PAYANN / (nominal_gdp * 1000)

# Aggregate CBP payroll by state-year
state_payroll <- cbp_clean %>%
  group_by(state_fips, year) %>%
  summarise(total_payroll = sum(PAYANN, na.rm = TRUE), .groups = "drop")

labor_share <- state_gdp %>%
  inner_join(state_payroll, by = c("state_fips", "year")) %>%
  mutate(
    # Both in compatible units: payroll in thousands $, GDP in millions $
    # labor_share = payroll($K) / GDP($M) * (1K/1M) = payroll / (GDP * 1000)
    labor_share = total_payroll / (nominal_gdp * 1000)
  )

# Check reasonable range (CBP payroll covers private sector only, so should be < 0.6)
labor_share <- labor_share %>%
  filter(labor_share > 0.05, labor_share < 0.8)

cat(sprintf("Labor share: %d state-year obs\n", nrow(labor_share)))

# ============================================================
# 4. Merge into analysis panel
# ============================================================

# Use CBP as the backbone (most complete for business dynamism outcomes)
panel <- cbp_dynamics %>%
  left_join(treatment %>% select(state_fips, bc_year, state_name, state_abbr),
            by = "state_fips") %>%
  left_join(labor_share %>% select(state_fips, year, total_payroll, nominal_gdp, labor_share),
            by = c("state_fips", "year")) %>%
  left_join(state_pop %>% select(state_fips, year, population),
            by = c("state_fips", "year")) %>%
  filter(!is.na(bc_year))  # Only states in our treatment/control set

# Add BDS measures if available
if (bds_available) {
  panel <- panel %>%
    left_join(
      bds_clean %>% select(state_fips, year, entry_rate, exit_rate,
                           job_creation_rate, job_destruction_rate,
                           reallocation_rate),
      by = c("state_fips", "year")
    )
}

# Create treatment indicators
panel <- panel %>%
  mutate(
    treated = as.integer(bc_year > 0),
    post = as.integer(bc_year > 0 & year >= bc_year),
    # For CS-DiD: first_treat = bc_year for treated, 0 for never-treated
    first_treat = bc_year,
    # Numeric state ID for CS-DiD
    state_id = as.integer(factor(state_fips)),
    # Event time
    event_time = ifelse(bc_year > 0, year - bc_year, NA_integer_),
    # Per-capita measures
    estab_per_cap = ESTAB / (population / 1e6),  # per million residents
    emp_per_cap = EMP / (population / 1e6)
  )

cat(sprintf("\nFinal panel: %d state-year observations\n", nrow(panel)))
cat(sprintf("  States: %d total (%d treated, %d never-treated)\n",
            n_distinct(panel$state_fips),
            sum(panel$treated[!duplicated(panel$state_fips)]),
            sum(!panel$treated[!duplicated(panel$state_fips)])))
cat(sprintf("  Years: %d to %d\n", min(panel$year), max(panel$year)))
cat(sprintf("  Outcome coverage:\n"))
cat(sprintf("    avg_estab_size: %d non-NA\n", sum(!is.na(panel$avg_estab_size))))
cat(sprintf("    net_entry_rate: %d non-NA\n", sum(!is.na(panel$net_entry_rate))))
cat(sprintf("    labor_share: %d non-NA\n", sum(!is.na(panel$labor_share))))
if (bds_available) {
  cat(sprintf("    entry_rate (BDS): %d non-NA\n", sum(!is.na(panel$entry_rate))))
}

# ============================================================
# 5. Summary statistics by treatment status
# ============================================================

summ <- panel %>%
  filter(year <= 1985) %>%  # Pre-treatment baseline
  group_by(treated) %>%
  summarise(
    n_states = n_distinct(state_fips),
    mean_estab = mean(ESTAB, na.rm = TRUE),
    mean_emp = mean(EMP, na.rm = TRUE),
    mean_size = mean(avg_estab_size, na.rm = TRUE),
    mean_ls = mean(labor_share, na.rm = TRUE),
    mean_pop = mean(population, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nPre-treatment balance (1985 and earlier):\n")
print(summ)

# Save
saveRDS(panel, "../data/analysis_panel.rds")
saveRDS(summ, "../data/summary_stats.rds")

cat("\n=== PANEL CONSTRUCTION COMPLETE ===\n")
