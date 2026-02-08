## 02_clean_data.R — Clean BFS data and build analysis panel
## Paper 110: Recreational Marijuana and Business Formation

source("00_packages.R")

# ──────────────────────────────────────────────────────────────
# 1. Load raw BFS data
# ──────────────────────────────────────────────────────────────
cat("Loading BFS monthly data...\n")
bfs_raw <- read_csv(file.path(DATA_DIR, "bfs_monthly.csv"), show_col_types = FALSE)

# Reshape monthly columns to long format
months <- c("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec")

bfs_long <- bfs_raw %>%
  pivot_longer(
    cols = all_of(months),
    names_to = "month_name",
    values_to = "applications"
  ) %>%
  mutate(
    month = match(month_name, months),
    applications = as.numeric(applications)
  ) %>%
  filter(!is.na(applications)) %>%
  rename(
    sa_flag = sa,
    naics_sector = naics_sector,
    series_code = series,
    state_abbr = geo
  ) %>%
  mutate(year = as.integer(year))

cat("  BFS long format:", nrow(bfs_long), "rows\n")

# ──────────────────────────────────────────────────────────────
# 2. Filter to analysis sample
# ──────────────────────────────────────────────────────────────

# Keep: not seasonally adjusted, total + sector-level BA_BA
# Geographic: US states only (2-letter codes, exclude US, regional)
state_codes <- c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                 "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                 "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                 "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                 "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")

bfs_analysis <- bfs_long %>%
  filter(
    sa_flag == "U",        # Not seasonally adjusted
    state_abbr %in% state_codes,
    year >= 2005,          # Start from 2005 for clean pre-period
    year <= 2024           # Through 2024
  )

cat("  Analysis sample:", nrow(bfs_analysis), "rows\n")
cat("  States:", n_distinct(bfs_analysis$state_abbr), "\n")
cat("  Years:", min(bfs_analysis$year), "-", max(bfs_analysis$year), "\n")
cat("  Series:", paste(unique(bfs_analysis$series_code), collapse = ", "), "\n")

# ──────────────────────────────────────────────────────────────
# 3. Aggregate to annual state-sector level
# ──────────────────────────────────────────────────────────────
cat("Aggregating to annual state-sector panels...\n")

# Annual totals by state, sector, series
bfs_annual <- bfs_analysis %>%
  group_by(state_abbr, year, naics_sector, series_code) %>%
  summarise(
    annual_applications = sum(applications, na.rm = TRUE),
    months_observed = n(),
    .groups = "drop"
  ) %>%
  # Only keep state-years with 12 months of data
  filter(months_observed == 12)

cat("  Annual panel:", nrow(bfs_annual), "rows\n")

# ──────────────────────────────────────────────────────────────
# 4. Merge treatment timing
# ──────────────────────────────────────────────────────────────
cat("Merging treatment timing...\n")
treatment <- read_csv(file.path(DATA_DIR, "treatment_timing.csv"), show_col_types = FALSE)
medical_mj <- read_csv(file.path(DATA_DIR, "medical_marijuana.csv"), show_col_types = FALSE)

bfs_annual <- bfs_annual %>%
  left_join(
    treatment %>% select(state_abbr, retail_year),
    by = "state_abbr"
  ) %>%
  mutate(
    # Treatment indicator: 1 if year >= first retail sales year
    treated = if_else(!is.na(retail_year) & year >= retail_year, 1L, 0L),
    # Cohort indicator for CS estimator (0 = never treated)
    first_treat = if_else(!is.na(retail_year), retail_year, 0L),
    # Ever treated
    ever_treated = if_else(!is.na(retail_year), 1L, 0L)
  )

# Add medical marijuana indicator
bfs_annual <- bfs_annual %>%
  left_join(medical_mj, by = "state_abbr") %>%
  mutate(
    has_medical = if_else(!is.na(medical_year) & year >= medical_year, 1L, 0L)
  )

# ──────────────────────────────────────────────────────────────
# 5. Merge population and compute per-capita rates
# ──────────────────────────────────────────────────────────────
cat("Merging population data...\n")
pop <- read_csv(file.path(DATA_DIR, "state_population.csv"), show_col_types = FALSE) %>%
  select(state_abbr, year, population)

# Interpolate missing years (2020 ACS not released due to COVID; 2024 not yet available)
# For each state, linearly interpolate missing years
all_state_years <- expand.grid(
  state_abbr = unique(bfs_annual$state_abbr),
  year = 2005:2024,
  stringsAsFactors = FALSE
) %>% as_tibble()

pop_full <- all_state_years %>%
  left_join(pop, by = c("state_abbr", "year")) %>%
  group_by(state_abbr) %>%
  arrange(year) %>%
  mutate(population = approx(year[!is.na(population)], population[!is.na(population)],
                             xout = year, rule = 2)$y) %>%
  ungroup()

cat("  Population filled:", sum(!is.na(pop_full$population)), "of", nrow(pop_full), "state-years\n")

bfs_annual <- bfs_annual %>%
  left_join(pop_full, by = c("state_abbr", "year"))

# Compute per-capita rate (per 100,000 population)
bfs_annual <- bfs_annual %>%
  mutate(
    apps_per_100k = annual_applications / population * 100000,
    log_apps = log(annual_applications + 1),
    log_apps_pc = log(apps_per_100k + 0.01)
  )

# ──────────────────────────────────────────────────────────────
# 6. Note: NAICS sector breakdowns only available at national level
#    State-level BFS data has TOTAL only. No DDD possible.
# ──────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────
# 7. Create state-year total panel (for DiD without sector dimension)
# ──────────────────────────────────────────────────────────────
cat("Creating state-year total panel...\n")

state_year <- bfs_annual %>%
  filter(naics_sector == "TOTAL", series_code == "BA_BA") %>%
  select(state_abbr, year, annual_applications, apps_per_100k,
         log_apps, log_apps_pc, treated, first_treat, ever_treated,
         has_medical, population, months_observed)

cat("  State-year panel:", nrow(state_year), "obs\n")
cat("  Treated obs:", sum(state_year$treated), "\n")
cat("  Cohorts:", paste(sort(unique(state_year$first_treat[state_year$first_treat > 0])), collapse = ", "), "\n")

# Also create panels for HBA, WBA, and CBA
state_year_hba <- bfs_annual %>%
  filter(naics_sector == "TOTAL", series_code == "BA_HBA") %>%
  select(state_abbr, year, annual_applications, apps_per_100k,
         log_apps, log_apps_pc, treated, first_treat, ever_treated,
         has_medical, population)

state_year_wba <- bfs_annual %>%
  filter(naics_sector == "TOTAL", series_code == "BA_WBA") %>%
  select(state_abbr, year, annual_applications, apps_per_100k,
         log_apps, log_apps_pc, treated, first_treat, ever_treated,
         has_medical, population)

state_year_cba <- bfs_annual %>%
  filter(naics_sector == "TOTAL", series_code == "BA_CBA") %>%
  select(state_abbr, year, annual_applications, apps_per_100k,
         log_apps, log_apps_pc, treated, first_treat, ever_treated,
         has_medical, population)

# Also create business formations panel (actual employer firms formed within 4 quarters)
state_year_bf <- bfs_annual %>%
  filter(naics_sector == "TOTAL", series_code == "BF_BF8Q") %>%
  select(state_abbr, year, annual_applications, apps_per_100k,
         log_apps, log_apps_pc, treated, first_treat, ever_treated,
         has_medical, population)

cat("  HBA panel:", nrow(state_year_hba), "obs\n")
cat("  WBA panel:", nrow(state_year_wba), "obs\n")
cat("  CBA panel:", nrow(state_year_cba), "obs\n")
cat("  BF panel:", nrow(state_year_bf), "obs\n")

# ──────────────────────────────────────────────────────────────
# 9. Save analysis datasets
# ──────────────────────────────────────────────────────────────
cat("Saving analysis datasets...\n")
write_csv(state_year, file.path(DATA_DIR, "panel_state_year.csv"))
write_csv(state_year_hba, file.path(DATA_DIR, "panel_state_year_hba.csv"))
write_csv(state_year_wba, file.path(DATA_DIR, "panel_state_year_wba.csv"))
write_csv(state_year_cba, file.path(DATA_DIR, "panel_state_year_cba.csv"))
write_csv(state_year_bf, file.path(DATA_DIR, "panel_state_year_bf.csv"))

cat("\n=== Data cleaning complete ===\n")
cat("  state_year panel:", nrow(state_year), "observations\n")
cat("  HBA panel:", nrow(state_year_hba), "observations\n")
cat("  WBA panel:", nrow(state_year_wba), "observations\n")
cat("  CBA panel:", nrow(state_year_cba), "observations\n")
cat("  BF panel:", nrow(state_year_bf), "observations\n")
