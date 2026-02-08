################################################################################
# 02_clean_data.R — Data Cleaning and Panel Construction
# Paper: Digital Exodus or Digital Magnet?
################################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "00_packages.R"), "00_packages.R"))

cat("=== Building analysis panels ===\n")

###############################################################################
# 1. Load raw data
###############################################################################

privacy_laws <- read_csv(file.path(DATA_DIR, "privacy_law_dates.csv"),
                         show_col_types = FALSE)
state_fips   <- read_csv(file.path(DATA_DIR, "state_fips.csv"),
                         show_col_types = FALSE)
qcew_raw     <- read_csv(file.path(DATA_DIR, "qcew_raw.csv"),
                         show_col_types = FALSE)
bfs_raw      <- read_csv(file.path(DATA_DIR, "bfs_monthly.csv"),
                         show_col_types = FALSE)

cat("Loaded: QCEW", nrow(qcew_raw), "rows, BFS", nrow(bfs_raw), "rows\n")

###############################################################################
# 2. Clean QCEW — State × Quarter × Industry panel
###############################################################################

cat("\n--- Cleaning QCEW ---\n")

# Extract state FIPS (first 2 digits of area_fips)
qcew <- qcew_raw %>%
  mutate(
    state_fips = substr(area_fips, 1, 2),
    # Average monthly employment for the quarter
    avg_emp = (month1_emplvl + month2_emplvl + month3_emplvl) / 3,
    # Average weekly wage
    avg_weekly_wage = avg_wkly_wage,
    # Quarterly establishments
    estabs = qtrly_estabs,
    # Total quarterly wages (millions)
    total_wages_mil = total_qtrly_wages / 1e6,
    # Year-quarter numeric (e.g., 2020.0 = Q1, 2020.25 = Q2, etc.)
    yearqtr = year + (quarter - 1) / 4
  ) %>%
  # Keep only state-level aggregate (agglvl 54 = state-industry 3-digit, 56 = 4-digit)
  filter(
    !is.na(avg_emp),
    avg_emp > 0,
    state_fips != "00"  # Remove US total if present
  ) %>%
  # Merge state abbreviations
  left_join(state_fips %>% select(state_abbr, fips),
            by = c("state_fips" = "fips")) %>%
  filter(!is.na(state_abbr))

cat("QCEW after cleaning:", nrow(qcew), "rows\n")
cat("States:", length(unique(qcew$state_abbr)), "\n")
cat("Industries:", paste(unique(qcew$industry), collapse = ", "), "\n")

###############################################################################
# 3. Merge QCEW with treatment indicators
###############################################################################

cat("\n--- Merging treatment indicators ---\n")

# Create treatment status for each state-quarter
qcew_panel <- qcew %>%
  left_join(
    privacy_laws %>% select(state_abbr, effective_date, treat_yearqtr),
    by = "state_abbr"
  ) %>%
  mutate(
    # Binary treatment: 1 if privacy law is effective
    treated_state = ifelse(!is.na(effective_date), 1, 0),
    post = ifelse(!is.na(treat_yearqtr) & yearqtr >= treat_yearqtr, 1, 0),
    treat = treated_state * post,
    # Log outcomes
    log_emp = log(avg_emp + 1),
    log_wage = log(avg_weekly_wage + 1),
    log_estabs = log(estabs + 1),
    log_wages_total = log(total_wages_mil + 0.001),
    # Treatment cohort (year of first treatment quarter)
    cohort = ifelse(treated_state == 1,
                    floor(treat_yearqtr),
                    0),
    # Relative time (quarters since treatment)
    rel_time = ifelse(treated_state == 1,
                      round((yearqtr - treat_yearqtr) * 4),
                      NA_real_),
    # State numeric ID for FE
    state_id = as.numeric(as.factor(state_abbr)),
    # Time numeric ID for FE
    time_id = as.numeric(as.factor(yearqtr))
  )

cat("Panel dimensions:", nrow(qcew_panel), "rows\n")
cat("Treated states:", sum(qcew_panel$treated_state == 1 & qcew_panel$quarter == 1 & qcew_panel$year == 2024) /
      length(unique(qcew_panel$industry)), "\n")
cat("Control states:", sum(qcew_panel$treated_state == 0 & qcew_panel$quarter == 1 & qcew_panel$year == 2024) /
      length(unique(qcew_panel$industry)), "\n")

###############################################################################
# 4. Create industry-specific panels
###############################################################################

cat("\n--- Creating industry panels ---\n")

# Information sector (NAICS 51) — primary outcome
info_panel <- qcew_panel %>% filter(industry == "Information")
cat("Information panel:", nrow(info_panel), "state-quarters\n")

# Software Publishers (NAICS 5112) — privacy-enhancing proxy
sw_panel <- qcew_panel %>% filter(industry == "Software Publishers")
cat("Software panel:", nrow(sw_panel), "state-quarters\n")

# Computer Systems Design (NAICS 5415) — compliance/consulting
cs_panel <- qcew_panel %>% filter(industry == "Computer Systems Design")
cat("Comp Sys Design panel:", nrow(cs_panel), "state-quarters\n")

# Finance & Insurance (NAICS 52) — placebo
fin_panel <- qcew_panel %>% filter(industry == "Finance & Insurance")
cat("Finance panel:", nrow(fin_panel), "state-quarters\n")

# Construction (NAICS 23) — placebo
constr_panel <- qcew_panel %>% filter(industry == "Construction")
cat("Construction panel:", nrow(constr_panel), "state-quarters\n")

###############################################################################
# 5. Clean BFS — State × Month business applications
###############################################################################

cat("\n--- Cleaning BFS ---\n")

# BFS structure: sa, naics_sector, series, geo, year, jan...dec
# We want: unadjusted (U), business applications (BA_BA), state-level
bfs_state <- bfs_raw %>%
  filter(
    sa == "U",           # Unadjusted
    series == "BA_BA",   # Business applications
    !geo %in% c("US", "NO", "MW", "SO", "WE")  # Exclude national/regional
  ) %>%
  # Pivot months to long format
  pivot_longer(
    cols = jan:dec,
    names_to = "month_name",
    values_to = "applications_raw"
  ) %>%
  mutate(
    # Convert to numeric (D = disclosure suppressed → NA)
    applications = suppressWarnings(as.numeric(applications_raw)),
    month_num = match(month_name, tolower(month.abb)),
    date = ymd(paste(year, month_num, "01", sep = "-")),
    state_abbr = geo,
    # Quarter
    qtr = quarter(date),
    yearqtr = year + (qtr - 1) / 4
  ) %>%
  filter(!is.na(applications), year >= 2015,
         !state_abbr %in% c("PR", "GU", "VI", "AS", "MP"))  # Exclude territories

# Aggregate to quarterly for consistency with QCEW
# Truncate to 2024Q4 to match QCEW sample window
bfs_quarterly <- bfs_state %>%
  filter(yearqtr <= 2024.75) %>%
  group_by(state_abbr, year, qtr, yearqtr, naics_sector) %>%
  summarize(
    total_apps = sum(applications, na.rm = TRUE),
    avg_monthly_apps = mean(applications, na.rm = TRUE),
    .groups = "drop"
  )

# Merge treatment
bfs_panel <- bfs_quarterly %>%
  left_join(
    privacy_laws %>% select(state_abbr, effective_date, treat_yearqtr),
    by = "state_abbr"
  ) %>%
  mutate(
    treated_state = ifelse(!is.na(effective_date), 1, 0),
    post = ifelse(!is.na(treat_yearqtr) & yearqtr >= treat_yearqtr, 1, 0),
    treat = treated_state * post,
    log_apps = log(total_apps + 1),
    cohort = ifelse(treated_state == 1, floor(treat_yearqtr), 0),
    rel_time = ifelse(treated_state == 1,
                      round((yearqtr - treat_yearqtr) * 4), NA_real_),
    state_id = as.numeric(as.factor(state_abbr)),
    time_id = as.numeric(as.factor(yearqtr))
  )

cat("BFS panel:", nrow(bfs_panel), "rows\n")
cat("NAICS sectors:", paste(unique(bfs_panel$naics_sector), collapse = ", "), "\n")

# Key BFS sectors for analysis
bfs_total <- bfs_panel %>% filter(naics_sector == "TOTAL")
bfs_info  <- bfs_panel %>% filter(naics_sector == "NAICS51")
bfs_prof  <- bfs_panel %>% filter(naics_sector == "NAICS54")  # Professional/Technical

cat("BFS Total apps panel:", nrow(bfs_total), "rows\n")
cat("BFS Info sector panel:", nrow(bfs_info), "rows\n")
cat("BFS Professional panel:", nrow(bfs_prof), "rows\n")

###############################################################################
# 6. Clean IRS SOI Migration Data
###############################################################################

cat("\n--- Cleaning IRS migration data ---\n")

irs_files <- list.files(DATA_DIR, pattern = "irs_inflow_.*\\.csv", full.names = TRUE)

irs_inflows <- list()
for (f in irs_files) {
  yr <- as.numeric(str_extract(basename(f), "\\d{4}"))
  tryCatch({
    df <- read_csv(f, show_col_types = FALSE) %>%
      mutate(year = yr)
    irs_inflows[[length(irs_inflows) + 1]] <- df
  }, error = function(e) {
    cat("  Error reading", f, ":", e$message, "\n")
  })
}

if (length(irs_inflows) > 0) {
  irs_inflow <- bind_rows(irs_inflows) %>%
    # Keep state-to-state flows (exclude aggregates coded as 96, 97, 98)
    filter(
      y1_statefips %in% sprintf("%02d", 1:56),
      y2_statefips %in% sprintf("%02d", 1:56),
      y1_statefips != y2_statefips
    ) %>%
    rename(
      dest_fips = y2_statefips,
      origin_fips = y1_statefips,
      returns = n1,
      exemptions = n2,
      agi = AGI
    ) %>%
    # Merge state abbreviations
    left_join(state_fips %>% select(state_abbr, fips) %>% rename(dest_abbr = state_abbr),
              by = c("dest_fips" = "fips")) %>%
    left_join(state_fips %>% select(state_abbr, fips) %>% rename(origin_abbr = state_abbr),
              by = c("origin_fips" = "fips"))

  # Aggregate: net migration for each state-year
  irs_net <- irs_inflow %>%
    group_by(dest_abbr, year) %>%
    summarize(
      total_inflows = sum(returns, na.rm = TRUE),
      total_inflow_agi = sum(agi, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    rename(state_abbr = dest_abbr)

  # Also compute outflows
  irs_out <- irs_inflow %>%
    group_by(origin_abbr, year) %>%
    summarize(
      total_outflows = sum(returns, na.rm = TRUE),
      total_outflow_agi = sum(agi, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    rename(state_abbr = origin_abbr)

  irs_migration <- irs_net %>%
    left_join(irs_out, by = c("state_abbr", "year")) %>%
    mutate(
      net_migration = total_inflows - total_outflows,
      net_agi = total_inflow_agi - total_outflow_agi,
      net_migration_rate = net_migration / (total_inflows + total_outflows),
      log_net_agi = sign(net_agi) * log(abs(net_agi) + 1)
    ) %>%
    # Merge treatment
    left_join(
      privacy_laws %>%
        mutate(treat_year_irs = year(effective_date)) %>%
        select(state_abbr, treat_year_irs),
      by = "state_abbr"
    ) %>%
    mutate(
      treated_state = ifelse(!is.na(treat_year_irs), 1, 0),
      post = ifelse(!is.na(treat_year_irs) & year >= treat_year_irs, 1, 0),
      treat = treated_state * post
    )

  cat("IRS migration panel:", nrow(irs_migration), "rows\n")
  cat("Years:", paste(sort(unique(irs_migration$year)), collapse = ", "), "\n")
} else {
  cat("WARNING: No IRS migration data loaded\n")
  irs_migration <- tibble()
}

###############################################################################
# 7. Summary statistics
###############################################################################

cat("\n--- Summary statistics ---\n")

# QCEW summary by treatment status
qcew_summary <- qcew_panel %>%
  filter(industry == "Information") %>%
  group_by(treated_state) %>%
  summarize(
    n_states = n_distinct(state_abbr),
    mean_emp = mean(avg_emp, na.rm = TRUE),
    sd_emp = sd(avg_emp, na.rm = TRUE),
    mean_wage = mean(avg_weekly_wage, na.rm = TRUE),
    mean_estabs = mean(estabs, na.rm = TRUE),
    obs = n(),
    .groups = "drop"
  )

cat("\nQCEW Information Sector Summary:\n")
print(qcew_summary)

###############################################################################
# 8. Save analysis-ready datasets
###############################################################################

cat("\n--- Saving analysis datasets ---\n")

write_csv(qcew_panel, file.path(DATA_DIR, "qcew_panel.csv"))
write_csv(bfs_panel,  file.path(DATA_DIR, "bfs_panel.csv"))
if (nrow(irs_migration) > 0) {
  write_csv(irs_migration, file.path(DATA_DIR, "irs_migration_panel.csv"))
}

cat("Analysis datasets saved.\n")
cat("QCEW panel:", nrow(qcew_panel), "obs across",
    n_distinct(qcew_panel$state_abbr), "states,",
    n_distinct(qcew_panel$industry), "industries\n")
cat("BFS panel:", nrow(bfs_panel), "obs\n")
cat("IRS migration:", nrow(irs_migration), "obs\n")

cat("\n=== Data cleaning complete ===\n")
