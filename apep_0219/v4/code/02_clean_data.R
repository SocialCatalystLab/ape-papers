################################################################################
# 02_clean_data.R — Construct analysis dataset for ARC RDD
# ARC Distressed County Designation RDD (apep_0217)
################################################################################

source("00_packages.R")

data_dir <- "../data"

################################################################################
# 1. Load all data sources
################################################################################

arc_panel <- readRDS(file.path(data_dir, "arc_panel_raw.rds"))
bea_income <- tryCatch(readRDS(file.path(data_dir, "bea_income.rds")), error = function(e) NULL)
pop_panel <- tryCatch(readRDS(file.path(data_dir, "pop_county.rds")), error = function(e) NULL)
saipe_panel <- tryCatch(readRDS(file.path(data_dir, "saipe_county.rds")), error = function(e) NULL)

cat("=== Building Analysis Dataset ===\n")
cat(sprintf("ARC panel: %d county-years\n", nrow(arc_panel)))

################################################################################
# 2. Construct the running variable
################################################################################

# For each fiscal year, identify the CIV threshold for "Distressed" designation
# Distressed = worst 10% nationally among ~3,110 US counties
# The threshold is the CIV value at which status switches from At-Risk to Distressed

arc_panel <- arc_panel %>%
  mutate(
    distressed = as.integer(grepl("Distressed", status, ignore.case = TRUE)),
    at_risk = as.integer(grepl("At-Risk|At Risk", status, ignore.case = TRUE)),
    transitional = as.integer(grepl("Transitional", status, ignore.case = TRUE)),
    competitive = as.integer(grepl("Competitive", status, ignore.case = TRUE)),
    attainment = as.integer(grepl("Attainment", status, ignore.case = TRUE))
  )

# Find the threshold CIV for each fiscal year
# Threshold = midpoint between max CIV of At-Risk and min CIV of Distressed
thresholds <- arc_panel %>%
  group_by(fiscal_year) %>%
  summarize(
    max_at_risk_civ = max(civ[at_risk == 1], na.rm = TRUE),
    min_distressed_civ = min(civ[distressed == 1], na.rm = TRUE),
    threshold_civ = (max(civ[at_risk == 1], na.rm = TRUE) +
                       min(civ[distressed == 1], na.rm = TRUE)) / 2,
    n_distressed = sum(distressed),
    n_at_risk = sum(at_risk),
    n_total = n(),
    .groups = "drop"
  )

cat("\nCIV Thresholds by Fiscal Year:\n")
print(thresholds %>% select(fiscal_year, threshold_civ, min_distressed_civ,
                             max_at_risk_civ, n_distressed))

# Merge thresholds and construct centered running variable
arc_panel <- arc_panel %>%
  left_join(thresholds %>% select(fiscal_year, threshold_civ), by = "fiscal_year") %>%
  mutate(
    civ_centered = civ - threshold_civ
  )

################################################################################
# 3. Merge outcome data
################################################################################

# Map ARC fiscal year to data year
# ARC FY uses 3-year lagged data, so outcomes are better measured in the FY year itself
# FY2014 uses 2009-2011 unemp data but the designation applies in FY2014
# For outcomes, we want the year AFTER designation: fiscal_year → outcome year

# Merge BEA personal income
if (!is.null(bea_income) && nrow(bea_income) > 0) {
  # BEA data year = fiscal_year (the year the designation is active)
  arc_panel <- arc_panel %>%
    left_join(bea_income %>% rename(fiscal_year = year), by = c("fips", "fiscal_year"))
  cat(sprintf("Merged BEA income: %d non-missing\n",
              sum(!is.na(arc_panel$personal_income_k))))
}

# Merge population data
if (!is.null(pop_panel) && nrow(pop_panel) > 0) {
  arc_panel <- arc_panel %>%
    left_join(pop_panel %>% rename(fiscal_year = year), by = c("fips", "fiscal_year"))
  cat(sprintf("Merged population: %d non-missing\n",
              sum(!is.na(arc_panel$population))))
}

# Merge SAIPE
if (!is.null(saipe_panel) && nrow(saipe_panel) > 0) {
  arc_panel <- arc_panel %>%
    left_join(saipe_panel %>%
                select(fips, fiscal_year = year, poverty_rate_saipe, median_income),
              by = c("fips", "fiscal_year"))
}

################################################################################
# 4. Construct additional variables
################################################################################

arc_panel <- arc_panel %>%
  mutate(
    # Per capita personal income (thousands)
    pc_income = if ("personal_income_k" %in% names(.)) {
      personal_income_k / (population / 1000)
    } else NA_real_,

    # State FIPS
    state_fips = str_sub(fips, 1, 2),

    # Log outcomes
    log_pcmi = log(pcmi),
    log_unemp = log(pmax(unemp_rate_arc, 0.1)),
    log_poverty = log(pmax(poverty_rate_arc, 0.1))
  )

# Create county numeric ID for fixed effects
arc_panel <- arc_panel %>%
  mutate(county_id = as.integer(as.factor(fips)))

################################################################################
# 5. Restrict to bandwidth around threshold
################################################################################

# Main bandwidth: ±30 CIV points (generous for exploration)
# rdrobust will select optimal bandwidth for estimation

arc_analysis <- arc_panel %>%
  filter(abs(civ_centered) <= 50) %>%  # Wide window for plotting
  arrange(fips, fiscal_year)

cat(sprintf("\nAnalysis sample (|CIV - threshold| ≤ 50): %d county-years\n", nrow(arc_analysis)))
cat(sprintf("  Distressed: %d  At-Risk: %d  Other: %d\n",
            sum(arc_analysis$distressed == 1),
            sum(arc_analysis$at_risk == 1),
            nrow(arc_analysis) - sum(arc_analysis$distressed == 1) - sum(arc_analysis$at_risk == 1)))

################################################################################
# 6. Summary statistics
################################################################################

cat("\n=== Summary Statistics ===\n")

# Full sample
cat("\nFull ARC Panel:\n")
arc_panel %>%
  summarize(
    N = n(),
    Counties = n_distinct(fips),
    Years = n_distinct(fiscal_year),
    Mean_CIV = mean(civ, na.rm = TRUE),
    SD_CIV = sd(civ, na.rm = TRUE),
    Mean_Unemp = mean(unemp_rate_arc, na.rm = TRUE),
    Mean_PCMI = mean(pcmi, na.rm = TRUE),
    Mean_Poverty = mean(poverty_rate_arc, na.rm = TRUE),
    Pct_Distressed = mean(distressed) * 100
  ) %>%
  print()

# Near threshold (±15 CIV)
cat("\nNear Threshold (|CIV - c| ≤ 15):\n")
arc_panel %>%
  filter(abs(civ_centered) <= 15) %>%
  group_by(distressed) %>%
  summarize(
    N = n(),
    Mean_CIV = mean(civ, na.rm = TRUE),
    Mean_Unemp = mean(unemp_rate_arc, na.rm = TRUE),
    Mean_PCMI = mean(pcmi, na.rm = TRUE),
    Mean_Poverty = mean(poverty_rate_arc, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

################################################################################
# 7. Save analysis datasets
################################################################################

saveRDS(arc_panel, file.path(data_dir, "arc_panel_full.rds"))
saveRDS(arc_analysis, file.path(data_dir, "arc_analysis.rds"))
saveRDS(thresholds, file.path(data_dir, "arc_thresholds.rds"))

cat("\n=== Data Cleaning Complete ===\n")
cat(sprintf("Full panel: %d county-years saved\n", nrow(arc_panel)))
cat(sprintf("Analysis sample: %d county-years saved\n", nrow(arc_analysis)))
