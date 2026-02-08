# 02_clean_data.R — Build state-year panel from pre-fetched data
# Paper 113: RPS and Electricity Sector Employment

source("00_packages.R")

# ==============================================================================
# Load data
# ==============================================================================

pums_elec <- readRDS("../data/pums_electricity.rds")
pums_util <- readRDS("../data/pums_utilities.rds")
state_agg <- readRDS("../data/state_aggregates.rds")
state_industry <- readRDS("../data/state_industry.rds")
rps_policy <- readRDS("../data/rps_policy.rds")

# Load supplemental population data for 2005-2010
agg_supp <- read.csv("../data/state_year_agg_supplement.csv", stringsAsFactors = FALSE)

cat(sprintf("Electricity PUMS: %s records\n", format(nrow(pums_elec), big.mark = ",")))

# ==============================================================================
# Step 1: Aggregate electricity sector employment by state-year
# ==============================================================================

cat("Aggregating electricity employment by state-year...\n")

elec_by_state <- pums_elec %>%
  mutate(
    state_fips = sprintf("%02d", as.integer(state)),
    weight = as.numeric(PWGTP),
    age = as.numeric(AGEP),
    employed = ESR %in% c("1", "2"),
    wages = as.numeric(WAGP),
    female = SEX == "2"
  ) %>%
  filter(age >= 16, age <= 64, employed) %>%
  group_by(state_fips, year) %>%
  summarise(
    elec_employed = sum(weight, na.rm = TRUE),
    elec_avg_wages = weighted.mean(wages[!is.na(wages) & wages > 0],
                                    weight[!is.na(wages) & wages > 0],
                                    na.rm = TRUE),
    elec_pct_female = weighted.mean(female, weight, na.rm = TRUE) * 100,
    n_elec_obs = n(),
    .groups = "drop"
  )

cat(sprintf("Electricity state-year cells: %d\n", nrow(elec_by_state)))

# ==============================================================================
# Step 2: Aggregate utility sector employment by state-year
# ==============================================================================

cat("Aggregating utility employment by state-year...\n")

util_by_state <- pums_util %>%
  mutate(
    state_fips = sprintf("%02d", as.integer(state)),
    weight = as.numeric(PWGTP),
    age = as.numeric(AGEP),
    employed = ESR %in% c("1", "2")
  ) %>%
  filter(age >= 16, age <= 64, employed) %>%
  group_by(state_fips, year) %>%
  summarise(
    util_employed = sum(weight, na.rm = TRUE),
    n_util_obs = n(),
    .groups = "drop"
  )

# ==============================================================================
# Step 3: Process state-level aggregate data (total employment, population)
# ==============================================================================

cat("Processing state-level aggregates...\n")

# Combine main aggregates (2011-2023) with supplemental (2005-2010)
state_totals_main <- state_agg %>%
  mutate(
    state_fips = sprintf("%02d", as.integer(state_fips)),
    total_pop = as.numeric(total_pop),
    pop_16plus = as.numeric(pop_16plus),
    employed_civilian = as.numeric(employed_civilian),
    unemployed = as.numeric(unemployed)
  ) %>%
  filter(!is.na(total_pop)) %>%
  select(state_fips, year, total_pop, pop_16plus, employed_civilian, unemployed)

state_totals_supp <- agg_supp %>%
  mutate(
    state_fips = sprintf("%02d", as.integer(state_fips)),
    total_pop = as.numeric(total_pop),
    pop_16plus = as.numeric(pop_16plus),
    employed_civilian = as.numeric(employed_civilian),
    unemployed = as.numeric(unemployed)
  ) %>%
  filter(!is.na(total_pop)) %>%
  select(state_fips, year, total_pop, pop_16plus, employed_civilian, unemployed)

state_totals <- bind_rows(state_totals_main, state_totals_supp) %>%
  distinct(state_fips, year, .keep_all = TRUE)

cat(sprintf("State-year aggregates: %d total (main: %d, supplement: %d)\n",
            nrow(state_totals), nrow(state_totals_main), nrow(state_totals_supp)))

# ==============================================================================
# Step 4: Process manufacturing employment (for placebo)
# ==============================================================================

cat("Processing manufacturing employment...\n")

mfg_data <- state_industry %>%
  mutate(
    state_fips = sprintf("%02d", as.integer(state_fips)),
    manufacturing = as.numeric(manufacturing),
    employed_16plus = as.numeric(employed_16plus)
  ) %>%
  filter(!is.na(manufacturing)) %>%
  select(state_fips, year, manufacturing, employed_16plus)

# ==============================================================================
# Step 5: Merge into state-year panel
# ==============================================================================

cat("Building state-year panel...\n")

# Create full state-year grid (excluding 2020 - no ACS data)
all_years <- c(2005:2019, 2021:2023)
all_states <- unique(rps_policy$state_fips)

panel_grid <- expand.grid(
  state_fips = all_states,
  year = all_years,
  stringsAsFactors = FALSE
)

# Merge all components
panel <- panel_grid %>%
  left_join(elec_by_state, by = c("state_fips", "year")) %>%
  left_join(util_by_state, by = c("state_fips", "year")) %>%
  left_join(state_totals, by = c("state_fips", "year")) %>%
  left_join(mfg_data, by = c("state_fips", "year")) %>%
  left_join(rps_policy %>% select(state_fips, state_abbr, state_name,
                                    rps_first_binding, treatment_year, ever_treated,
                                    rps_target_2025),
            by = "state_fips") %>%
  mutate(
    # Fill missing employment with 0 (small states may have no PUMS elec workers)
    elec_employed = ifelse(is.na(elec_employed), 0, elec_employed),
    util_employed = ifelse(is.na(util_employed), 0, util_employed),
    n_elec_obs = ifelse(is.na(n_elec_obs), 0, n_elec_obs),
    # Employment rates per 1,000 total population
    # Use total_pop as denominator (available for all years 2005-2023)
    elec_emp_rate = ifelse(!is.na(total_pop) & total_pop > 0,
                            (elec_employed / total_pop) * 1000, NA),
    util_emp_rate = ifelse(!is.na(total_pop) & total_pop > 0,
                            (util_employed / total_pop) * 1000, NA),
    total_emp_rate = ifelse(!is.na(total_pop) & total_pop > 0 & !is.na(employed_civilian),
                             (employed_civilian / total_pop) * 1000, NA),
    mfg_emp_rate = ifelse(!is.na(total_pop) & total_pop > 0 & !is.na(manufacturing),
                           (manufacturing / total_pop) * 1000, NA),
    # Log employment
    log_elec_emp = log(elec_employed + 1),
    log_util_emp = log(util_employed + 1),
    # Treatment indicators
    treated = ifelse(is.na(rps_first_binding), 0L,
                     ifelse(year >= rps_first_binding, 1L, 0L)),
    event_time = ifelse(is.na(rps_first_binding), NA_integer_,
                        as.integer(year - rps_first_binding)),
    cohort = treatment_year,
    # Census region
    region = case_when(
      state_fips %in% c("09","23","25","33","44","50","34","36","42") ~ "Northeast",
      state_fips %in% c("17","18","26","39","55","19","20","27","29","31","38","46") ~ "Midwest",
      state_fips %in% c("10","11","12","13","24","37","45","51","54","01","21","28","47","05","22","40","48") ~ "South",
      state_fips %in% c("04","08","16","30","32","35","49","56","02","06","15","41","53") ~ "West",
      TRUE ~ "Other"
    )
  )

# ==============================================================================
# Summary
# ==============================================================================

cat("\n=== Panel Summary ===\n")
cat(sprintf("States: %d\n", n_distinct(panel$state_fips)))
cat(sprintf("Years: %s\n", paste(range(panel$year), collapse = "-")))
cat(sprintf("State-year obs: %d\n", nrow(panel)))
cat(sprintf("With elec emp rate: %d\n", sum(!is.na(panel$elec_emp_rate))))
cat(sprintf("With total emp rate: %d\n", sum(!is.na(panel$total_emp_rate))))

rps_summary <- panel %>%
  filter(!duplicated(state_fips)) %>%
  summarise(treated = sum(ever_treated), untreated = sum(!ever_treated))
cat(sprintf("RPS: %d treated, %d never-treated\n", rps_summary$treated, rps_summary$untreated))

cat(sprintf("Mean elec emp rate (per 1,000 pop): %.3f\n",
            mean(panel$elec_emp_rate, na.rm = TRUE)))
cat(sprintf("SD elec emp rate: %.3f\n", sd(panel$elec_emp_rate, na.rm = TRUE)))
cat(sprintf("Mean elec workers per state-year: %s\n",
            format(round(mean(panel$elec_employed, na.rm = TRUE)), big.mark = ",")))

# Save
saveRDS(panel, "../data/panel.rds")
write.csv(panel, "../data/panel.csv", row.names = FALSE)
cat("\nSaved: data/panel.rds, data/panel.csv\n")

cat("\n=== Data cleaning complete ===\n")
