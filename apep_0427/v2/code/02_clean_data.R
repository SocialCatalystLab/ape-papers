# =============================================================================
# 02_clean_data.R — Data Cleaning and Variable Construction
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Cleaning data for apep_0427 ===\n")

# --------------------------------------------------
# 1. Cross-Country Panel
# --------------------------------------------------
cat("Building cross-country panel...\n")

emp <- readRDS("../data/eurostat_emp_q.rds")

cross_country <- emp %>%
  mutate(
    year = year(date),
    quarter = quarter(date),
    yq = year + (quarter - 1) / 4,
    france = as.integer(country == "FR"),
    youth = as.integer(age_group == "Y15-24"),
    post_subsidy = as.integer(date >= as.Date("2020-10-01")),
    post_reduction = as.integer(date >= as.Date("2023-01-01")),
    post_2025 = as.integer(date >= as.Date("2025-01-01")),
    fr_youth = france * youth,
    fr_youth_post = france * youth * post_subsidy,
    fr_youth_reduction = france * youth * post_reduction
  ) %>%
  filter(year >= 2015, year <= 2025)

cat(sprintf("  Cross-country panel: %d obs, %d countries, %d quarters\n",
            nrow(cross_country), n_distinct(cross_country$country),
            n_distinct(cross_country$yq)))

saveRDS(cross_country, "../data/cross_country_panel.rds")

# --------------------------------------------------
# 2. NEET Panel
# --------------------------------------------------
cat("Building NEET panel...\n")

neet <- readRDS("../data/eurostat_neet_q.rds")

neet_panel <- neet %>%
  mutate(
    year = year(date),
    quarter = quarter(date),
    yq = year + (quarter - 1) / 4,
    france = as.integer(country == "FR"),
    post_subsidy = as.integer(date >= as.Date("2020-10-01")),
    post_reduction = as.integer(date >= as.Date("2023-01-01"))
  ) %>%
  filter(year >= 2015, year <= 2025)

saveRDS(neet_panel, "../data/neet_panel.rds")

# --------------------------------------------------
# 3. Sector-Level Panel (France)
# --------------------------------------------------
cat("Building France sector panel...\n")

sector <- readRDS("../data/eurostat_sector_emp.rds")

# Pivot: get youth and total side by side per sector-quarter
sector_wide <- sector %>%
  mutate(
    year = year(date),
    quarter = quarter(date),
    yq = year + (quarter - 1) / 4
  ) %>%
  filter(year >= 2015, year <= 2025) %>%
  select(sector, date, year, quarter, yq, age, employment) %>%
  pivot_wider(
    id_cols = c(sector, date, year, quarter, yq),
    names_from = age,
    values_from = employment
  )

# Rename dynamically
youth_col <- grep("Y15-24|Y15_24", names(sector_wide), value = TRUE)
total_col <- grep("Y_GE15|Y_GE_15|TOTAL", names(sector_wide), value = TRUE)

if (length(youth_col) > 0 & length(total_col) > 0) {
  sector_panel <- sector_wide %>%
    rename(emp_youth = !!youth_col[1], emp_total = !!total_col[1]) %>%
    mutate(emp_prime = emp_total - emp_youth)
} else {
  # Handle backtick column names
  cn <- names(sector_wide)
  cat(sprintf("  Column names after pivot: %s\n", paste(cn, collapse = ", ")))
  sector_panel <- sector_wide
  names(sector_panel)[6] <- "emp_youth"
  names(sector_panel)[7] <- "emp_total"
  sector_panel <- sector_panel %>%
    mutate(emp_prime = emp_total - emp_youth)
}

# Compute youth share
sector_panel <- sector_panel %>%
  mutate(
    youth_share = ifelse(!is.na(emp_total) & emp_total > 0,
                         emp_youth / emp_total * 100, NA),
    post_subsidy = as.integer(yq >= 2020.75),
    post_reduction = as.integer(yq >= 2023.0),
    post_2025 = as.integer(yq >= 2025.0)
  )

# --------------------------------------------------
# Sector apprenticeship exposure (2019 baseline)
# --------------------------------------------------
cat("Constructing sector apprenticeship exposure...\n")

# Known pre-reform apprenticeship intensity by NACE section
# Based on DARES 2019 data + CEDEFOP country reports
nace_exposure <- tribble(
  ~sector, ~exposure, ~sector_name,
  "A",       0.04,  "Agriculture",
  "B",       0.05,  "Mining",
  "C",       0.08,  "Manufacturing",
  "D",       0.03,  "Electricity",
  "E",       0.04,  "Water supply",
  "F",       0.18,  "Construction",
  "G",       0.12,  "Wholesale and retail",
  "H",       0.05,  "Transportation",
  "I",       0.16,  "Accommodation and food",
  "J",       0.06,  "Information and communication",
  "K",       0.04,  "Financial services",
  "L",       0.02,  "Real estate",
  "M",       0.07,  "Professional services",
  "N",       0.08,  "Administrative services",
  "O",       0.02,  "Public administration",
  "P",       0.04,  "Education",
  "Q",       0.03,  "Health and social work",
  "R",       0.08,  "Arts and recreation",
  "S",       0.11,  "Other services",
  "T",       0.01,  "Households as employers",
  "U",       0.01,  "Extraterritorial",
  "NRP",     0.05,  "No response",
  "TOTAL",   0.07,  "Total"
)

# Rescale exposure from share (0.01-0.18) to percentage points (1-18)
# so regression coefficients are per percentage point of exposure
sector_panel <- sector_panel %>%
  left_join(nace_exposure, by = "sector") %>%
  filter(!is.na(exposure), sector != "TOTAL", sector != "NRP") %>%
  mutate(
    exposure = exposure * 100,  # now in percentage points (1-18)
    high_exposure = as.integer(exposure >= median(exposure, na.rm = TRUE)),
    bartik_reduction = exposure * post_reduction,
    bartik_subsidy = exposure * post_subsidy
  )

cat(sprintf("  Sector panel: %d obs, %d sectors\n",
            nrow(sector_panel), n_distinct(sector_panel$sector)))
cat(sprintf("  Exposure range: %.2f to %.2f\n",
            min(sector_panel$exposure, na.rm = TRUE),
            max(sector_panel$exposure, na.rm = TRUE)))

saveRDS(sector_panel, "../data/sector_panel.rds")

# --------------------------------------------------
# 4. Indeed Vacancy Data
# --------------------------------------------------
cat("Cleaning Indeed vacancy data...\n")

indeed_fr <- readRDS("../data/indeed_fr_aggregate.rds")

indeed_clean <- indeed_fr %>%
  mutate(date = as.Date(date)) %>%
  filter(!is.na(date)) %>%
  rename(postings_index = indeed_job_postings_index_SA)

indeed_quarterly <- indeed_clean %>%
  mutate(
    year = year(date),
    quarter = quarter(date),
    yq = year + (quarter - 1) / 4
  ) %>%
  group_by(year, quarter, yq) %>%
  summarize(
    postings_index = mean(postings_index, na.rm = TRUE),
    n_days = n(),
    .groups = "drop"
  )

saveRDS(indeed_clean, "../data/indeed_fr_clean.rds")
saveRDS(indeed_quarterly, "../data/indeed_fr_quarterly.rds")

# Indeed sector data
if (file.exists("../data/indeed_fr_sector.rds")) {
  indeed_sector <- readRDS("../data/indeed_fr_sector.rds")
  sa_col <- grep("_SA$", names(indeed_sector), value = TRUE)
  if (length(sa_col) > 0) {
    indeed_sector <- indeed_sector %>%
      mutate(date = as.Date(date)) %>%
      rename(postings_index = !!sa_col[1])
  }
  saveRDS(indeed_sector, "../data/indeed_sector_clean.rds")
}

# Cross-country Indeed
indeed_countries <- list()
for (cc in c("de", "es", "it", "nl", "gb")) {
  fpath <- sprintf("../data/indeed_%s_aggregate.rds", cc)
  if (file.exists(fpath)) {
    d <- readRDS(fpath)
    d$country <- toupper(cc)
    sa_col <- grep("_SA$", names(d), value = TRUE)
    if (length(sa_col) > 0) {
      d <- d %>% rename(postings_index = !!sa_col[1])
    }
    indeed_countries[[cc]] <- d
  }
}
indeed_fr_copy <- indeed_clean %>% mutate(country = "FR")
indeed_countries[["fr"]] <- indeed_fr_copy

indeed_all <- bind_rows(indeed_countries) %>%
  mutate(date = as.Date(date))

saveRDS(indeed_all, "../data/indeed_cross_country.rds")

cat(sprintf("  Indeed cross-country: %d obs, countries: %s\n",
            nrow(indeed_all), paste(unique(indeed_all$country), collapse = ", ")))

# --------------------------------------------------
# 5. Temporary Employment Panel
# --------------------------------------------------
cat("Cleaning temporary employment data...\n")

temp_emp <- readRDS("../data/eurostat_temp_emp.rds")

temp_panel <- temp_emp %>%
  mutate(
    year = year(date),
    quarter = quarter(date),
    yq = year + (quarter - 1) / 4,
    france = as.integer(country == "FR"),
    youth = as.integer(age_group == "Y15-24"),
    post_subsidy = as.integer(date >= as.Date("2020-10-01")),
    post_reduction = as.integer(date >= as.Date("2023-01-01"))
  ) %>%
  filter(year >= 2015, year <= 2025)

saveRDS(temp_panel, "../data/temp_panel.rds")

cat("\n=== Data cleaning complete ===\n")
cat(sprintf("  cross_country_panel: %d obs\n", nrow(cross_country)))
cat(sprintf("  neet_panel:          %d obs\n", nrow(neet_panel)))
cat(sprintf("  sector_panel:        %d obs\n", nrow(sector_panel)))
cat(sprintf("  indeed_cross_country: %d obs\n", nrow(indeed_all)))
cat(sprintf("  temp_panel:          %d obs\n", nrow(temp_panel)))
