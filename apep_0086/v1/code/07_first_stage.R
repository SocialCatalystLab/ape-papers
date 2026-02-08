## 07_first_stage.R — First-Stage Analysis: PDMP Mandates and Opioid Prescribing
## Paper 109: Must-Access PDMP Mandates and Employment
##
## This script estimates the first-stage effect of must-access PDMP mandates
## on opioid prescribing rates using Callaway-Sant'Anna DiD.
##
## Data source: CDC U.S. State Opioid Dispensing Rates (per 100 persons)
##   https://archive.cdc.gov/www_cdc_gov/drugoverdose/rxrate-maps/
##   https://www.cdc.gov/overdose-prevention/data-research/facts-stats/opioid-dispensing-rate-maps.html
##   Source: IQVIA Xponent database, retail (non-hospital) pharmacies

library(did)
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(fixest)

cat("=== 07_first_stage.R: First-Stage Analysis ===\n")
cat("Estimating effect of must-access PDMP mandates on opioid prescribing rates\n\n")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
base_dir   <- file.path(getwd(), "..")
data_dir   <- file.path(base_dir, "data")
fig_dir    <- file.path(base_dir, "figures")
tab_dir    <- file.path(base_dir, "tables")

dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# ---------------------------------------------------------------------------
# APEP ggplot theme
# ---------------------------------------------------------------------------
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 11, color = "gray30"),
      legend.position = "bottom"
    )
}

# ---------------------------------------------------------------------------
# 1. Load existing analysis panel
# ---------------------------------------------------------------------------
cat("Loading analysis panel...\n")
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))
cat(sprintf("  Panel: %d obs, %d states, years %d-%d\n",
            nrow(panel), length(unique(panel$statefip)),
            min(panel$year), max(panel$year)))

# ---------------------------------------------------------------------------
# 2. CDC Opioid Prescribing Rate Data (dispensing rate per 100 persons)
# ---------------------------------------------------------------------------
# Data extracted from CDC archived state-level dispensing rate pages:
#   https://archive.cdc.gov/www_cdc_gov/drugoverdose/rxrate-maps/stateYYYY.html
# Source: IQVIA Xponent database
# Note: 2006-2018 use pharmacy location; 2019+ use prescriber location
#
# We embed the CDC data directly because:
#   (a) The CDC does not provide a single downloadable CSV spanning all years
#   (b) The archived pages contain data tables but no API endpoint
#   (c) Embedding ensures exact reproducibility without network dependency

cat("Building CDC opioid prescribing rate dataset...\n")

# State abbreviation lookup
state_name_to_abbr <- c(
  "Alabama" = "AL", "Alaska" = "AK", "Arizona" = "AZ", "Arkansas" = "AR",

"California" = "CA", "Colorado" = "CO", "Connecticut" = "CT", "Delaware" = "DE",
  "District of Columbia" = "DC", "Florida" = "FL", "Georgia" = "GA",
  "Hawaii" = "HI", "Idaho" = "ID", "Illinois" = "IL", "Indiana" = "IN",
  "Iowa" = "IA", "Kansas" = "KS", "Kentucky" = "KY", "Louisiana" = "LA",
  "Maine" = "ME", "Maryland" = "MD", "Massachusetts" = "MA", "Michigan" = "MI",
  "Minnesota" = "MN", "Mississippi" = "MS", "Missouri" = "MO", "Montana" = "MT",
  "Nebraska" = "NE", "Nevada" = "NV", "New Hampshire" = "NH",
  "New Jersey" = "NJ", "New Mexico" = "NM", "New York" = "NY",
  "North Carolina" = "NC", "North Dakota" = "ND", "Ohio" = "OH",
  "Oklahoma" = "OK", "Oregon" = "OR", "Pennsylvania" = "PA",
  "Rhode Island" = "RI", "South Carolina" = "SC", "South Dakota" = "SD",
  "Tennessee" = "TN", "Texas" = "TX", "Utah" = "UT", "Vermont" = "VT",
  "Virginia" = "VA", "Washington" = "WA", "West Virginia" = "WV",
  "Wisconsin" = "WI", "Wyoming" = "WY"
)

# --- CDC data by year (dispensing rate per 100 persons) ---
# Each vector: rates in alphabetical order by state (AL, AK, AZ, AR, CA, CO, CT, DE, DC, FL,
#   GA, HI, ID, IL, IN, IA, KS, KY, LA, ME, MD, MA, MI, MN, MS, MO, MT, NE, NV, NH,
#   NJ, NM, NY, NC, ND, OH, OK, OR, PA, RI, SC, SD, TN, TX, UT, VT, VA, WA, WV, WI, WY)

states_alpha <- c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                  "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                  "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                  "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                  "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")

# 2006
rates_2006 <- c(115.6, 63.4, 74.3, 98.3, 51.0, 62.2, 64.7, 86.6, 31.7, 79.7,
                79.8, 42.3, 75.6, 55.6, 94.3, 59.3, 77.5, 122.6, 109.2, 83.6,
                60.1, 66.0, 80.2, 50.3, 102.7, 80.5, 79.1, 64.3, 87.7, 75.0,
                54.7, 61.8, 44.2, 85.2, 56.0, 87.7, 108.7, 91.0, 69.5, 78.7,
                90.4, 50.0, 124.8, 66.8, 87.0, 56.9, 67.2, 80.8, 129.9, 64.7, 79.9)

# 2007
rates_2007 <- c(120.3, 66.6, 77.8, 108.2, 53.6, 65.9, 67.5, 92.3, 41.2, 82.2,
                82.5, 44.5, 78.8, 59.2, 99.7, 57.1, 80.6, 130.8, 110.1, 85.4,
                63.3, 68.2, 85.6, 53.7, 109.9, 84.3, 81.1, 65.1, 90.2, 78.5,
                57.2, 69.0, 46.1, 87.5, 59.3, 92.7, 114.4, 95.5, 73.7, 82.2,
                91.7, 49.9, 128.8, 71.2, 89.8, 56.0, 70.1, 84.4, 135.1, 69.2, 80.8)

# 2008
rates_2008 <- c(126.1, 68.5, 80.9, 112.1, 55.1, 67.7, 68.7, 95.4, 34.5, 84.3,
                86.3, 46.6, 82.7, 60.2, 103.3, 59.1, 82.7, 136.6, 113.7, 88.7,
                65.5, 69.2, 89.9, 56.5, 113.2, 86.8, 85.3, 66.2, 97.0, 81.7,
                59.5, 71.4, 48.4, 88.6, 61.7, 97.5, 111.3, 99.1, 76.5, 82.9,
                94.1, 52.1, 132.9, 71.3, 91.3, 56.5, 73.0, 86.6, 145.5, 70.6, 81.0)

# 2009
rates_2009 <- c(131.6, 67.3, 84.2, 116.0, 55.6, 69.8, 68.1, 97.5, 34.4, 86.3,
                88.2, 47.8, 85.2, 61.0, 105.6, 60.4, 82.8, 135.2, 113.0, 87.9,
                66.9, 68.9, 91.6, 58.6, 117.3, 88.5, 85.8, 66.4, 94.0, 81.5,
                59.9, 75.3, 49.5, 89.3, 60.3, 100.4, 115.0, 99.3, 78.1, 82.5,
                95.8, 52.3, 138.4, 71.8, 86.9, 54.5, 74.1, 86.1, 146.9, 71.9, 81.0)

# 2010
rates_2010 <- c(134.3, 68.4, 88.5, 120.8, 55.8, 72.0, 68.6, 101.1, 37.1, 87.6,
                90.2, 50.1, 88.6, 63.1, 107.1, 62.3, 86.1, 136.5, 112.6, 92.8,
                71.2, 67.9, 96.0, 59.0, 118.1, 91.0, 87.2, 69.0, 97.3, 81.6,
                61.0, 81.9, 51.0, 93.1, 63.0, 102.4, 119.6, 101.2, 81.0, 82.7,
                98.6, 54.0, 140.0, 73.0, 86.6, 54.1, 75.5, 85.0, 143.1, 74.4, 80.4)

# 2011
rates_2011 <- c(136.6, 68.0, 88.6, 115.2, 55.9, 73.0, 69.1, 99.7, 39.8, 83.5,
                88.6, 50.1, 91.4, 64.3, 106.7, 64.0, 87.8, 137.0, 111.7, 93.1,
                72.9, 65.9, 98.8, 60.0, 117.2, 91.6, 85.3, 68.8, 100.3, 80.9,
                61.5, 81.6, 51.1, 93.5, 61.3, 101.5, 122.3, 100.7, 81.7, 82.5,
                96.8, 55.1, 138.5, 72.0, 85.2, 53.6, 76.6, 81.6, 139.6, 75.2, 78.2)

# 2012
rates_2012 <- c(143.8, 66.8, 85.3, 121.8, 56.4, 73.5, 69.3, 94.0, 40.3, 75.9,
                89.4, 50.4, 92.0, 66.1, 110.5, 74.1, 90.3, 127.9, 113.0, 89.7,
                72.2, 65.7, 100.7, 60.9, 121.8, 95.4, 87.7, 73.2, 98.9, 83.7,
                60.1, 76.8, 51.8, 98.6, 62.1, 97.5, 127.4, 98.7, 83.3, 83.2,
                104.0, 60.1, 136.1, 73.4, 84.5, 54.6, 79.6, 78.7, 136.9, 76.8, 80.5)

# 2013
rates_2013 <- c(142.4, 63.7, 80.4, 120.9, 54.4, 71.2, 67.4, 92.7, 41.1, 73.5,
                86.6, 49.4, 89.2, 63.7, 106.3, 72.2, 88.7, 111.7, 112.4, 85.9,
                69.0, 63.0, 98.9, 58.3, 119.6, 93.3, 84.2, 71.3, 91.1, 82.0,
                58.3, 71.4, 46.7, 96.7, 60.1, 93.1, 123.3, 94.2, 81.6, 76.9,
                103.0, 60.6, 127.1, 70.0, 82.1, 52.2, 76.6, 75.2, 129.0, 73.8, 81.5)

# 2014
rates_2014 <- c(135.2, 62.7, 79.7, 123.2, 52.7, 69.6, 66.0, 91.0, 40.1, 71.4,
                83.8, 47.7, 87.4, 62.3, 96.7, 72.3, 86.5, 110.0, 108.9, 82.4,
                67.6, 59.6, 98.0, 56.6, 116.3, 90.7, 80.1, 70.1, 90.1, 79.6,
                57.2, 71.5, 43.9, 93.7, 58.1, 89.5, 110.9, 91.9, 79.9, 72.8,
                101.3, 61.7, 121.3, 67.0, 78.8, 50.4, 73.5, 74.2, 126.4, 71.9, 80.9)

# 2015
rates_2015 <- c(125.0, 60.8, 75.5, 117.2, 47.7, 65.1, 62.3, 84.4, 35.7, 67.1,
                79.4, 44.3, 81.9, 59.1, 89.1, 68.6, 80.5, 102.6, 100.4, 76.5,
                63.0, 54.0, 90.5, 52.1, 110.9, 84.5, 73.3, 65.5, 85.4, 74.8,
                56.0, 69.8, 45.1, 88.4, 53.0, 82.7, 104.4, 84.2, 75.5, 65.7,
                95.1, 59.1, 114.9, 59.8, 74.4, 60.1, 68.1, 69.8, 111.3, 67.5, 75.4)

# 2016
rates_2016 <- c(121.0, 58.9, 70.2, 114.6, 44.8, 59.8, 55.9, 79.2, 32.5, 66.6,
                77.8, 41.9, 77.6, 56.8, 83.9, 64.0, 76.9, 97.2, 98.1, 66.9,
                58.7, 47.1, 84.9, 46.9, 105.6, 80.4, 69.8, 62.8, 80.7, 64.3,
                52.6, 65.1, 42.7, 82.5, 47.8, 75.3, 97.9, 76.3, 69.5, 60.3,
                89.4, 54.8, 107.5, 57.6, 70.4, 58.6, 63.4, 64.9, 96.0, 62.2, 71.1)

# 2017
rates_2017 <- c(108.8, 52.0, 60.8, 106.1, 39.8, 52.4, 48.6, 68.6, 28.4, 61.5,
                71.3, 38.2, 70.3, 51.4, 75.7, 56.7, 70.3, 88.1, 89.8, 55.5,
                52.0, 40.0, 75.5, 40.8, 93.4, 72.2, 61.3, 56.6, 73.2, 52.5,
                45.0, 56.4, 38.3, 72.2, 41.7, 63.8, 88.6, 65.8, 58.3, 51.4,
                79.8, 48.8, 95.2, 52.2, 63.8, 50.0, 53.3, 57.1, 82.2, 52.7, 64.4)

# 2018
rates_2018 <- c(97.5, 44.9, 50.7, 93.5, 35.1, 45.1, 43.0, 60.6, 25.0, 53.7,
                63.2, 33.4, 61.9, 45.2, 65.8, 49.3, 64.3, 79.5, 79.4, 48.1,
                45.1, 35.3, 62.7, 35.5, 76.8, 63.4, 54.0, 50.6, 55.5, 46.1,
                38.9, 49.4, 34.0, 61.5, 37.4, 53.5, 79.1, 57.3, 49.9, 43.0,
                69.2, 42.6, 81.8, 47.2, 57.1, 42.4, 44.8, 49.3, 69.3, 45.8, 57.1)

# 2019 (note: methodology changed from pharmacy to prescriber location)
rates_2019 <- c(85.8, 39.1, 44.1, 80.9, 30.9, 40.0, 40.5, 51.6, 39.9, 45.4,
                57.9, 30.3, 53.4, 43.1, 60.4, 43.0, 63.7, 72.3, 74.6, 44.1,
                42.3, 35.4, 58.0, 32.1, 67.0, 58.3, 48.2, 50.3, 49.4, 38.1,
                34.8, 43.4, 34.8, 56.7, 38.8, 50.8, 66.0, 49.1, 47.0, 40.3,
                60.4, 43.9, 74.6, 42.1, 51.4, 36.9, 40.7, 42.7, 59.4, 42.5, 49.7)

# --- For 2020-2022: CDC interactive maps only (no archived tables available) ---
# We interpolate 2020-2022 using the known national trends:
#   2019: 46.7 national avg (from CDC)
#   2020: 43.3 national avg (from CDC reports)
#   2021: 41.2 national avg (from CDC reports)
#   2022: 39.2 national avg (from CDC reports)
#   2023: 37.5 national avg (from CDC)
# We apply state-specific scaling based on 2017-2019 decline trajectories
# These are estimates pending access to the full CDC interactive data tables

cat("  Computing 2020-2022 estimates from CDC national trends...\n")

# Annual national decline factors (relative to 2019)
decline_2020 <- 43.3 / 46.7  # ~0.927
decline_2021 <- 41.2 / 46.7  # ~0.882
decline_2022 <- 39.2 / 46.7  # ~0.839

# State-specific adjustment: use each state's own 2017-2019 trend
state_trend <- (rates_2019 - rates_2017) / 2  # annual change 2017-2019

# 2020-2022 projections using state trends anchored to CDC national totals
rates_2020 <- pmax(rates_2019 + state_trend * 1 * (decline_2020 / ((rates_2019 + state_trend) / rates_2019)),
                   rates_2019 * decline_2020)
rates_2021 <- pmax(rates_2019 + state_trend * 2 * (decline_2021 / ((rates_2019 + state_trend * 2) / rates_2019)),
                   rates_2019 * decline_2021)
rates_2022 <- pmax(rates_2019 + state_trend * 3 * (decline_2022 / ((rates_2019 + state_trend * 3) / rates_2019)),
                   rates_2019 * decline_2022)

# Rescale to match CDC national averages
rates_2020 <- rates_2020 * (43.3 / mean(rates_2020))
rates_2021 <- rates_2021 * (41.2 / mean(rates_2021))
rates_2022 <- rates_2022 * (39.2 / mean(rates_2022))

# Round to 1 decimal
rates_2020 <- round(rates_2020, 1)
rates_2021 <- round(rates_2021, 1)
rates_2022 <- round(rates_2022, 1)

# Assemble into a long data frame
all_years <- list(
  "2006" = rates_2006, "2007" = rates_2007, "2008" = rates_2008,
  "2009" = rates_2009, "2010" = rates_2010, "2011" = rates_2011,
  "2012" = rates_2012, "2013" = rates_2013, "2014" = rates_2014,
  "2015" = rates_2015, "2016" = rates_2016, "2017" = rates_2017,
  "2018" = rates_2018, "2019" = rates_2019, "2020" = rates_2020,
  "2021" = rates_2021, "2022" = rates_2022
)

cdc_rx <- do.call(rbind, lapply(names(all_years), function(yr) {
  data.frame(
    state_abbr = states_alpha,
    year = as.integer(yr),
    opioid_rx_rate = all_years[[yr]],
    stringsAsFactors = FALSE
  )
}))

# Flag which years are directly from CDC vs estimated
cdc_rx$cdc_source <- ifelse(cdc_rx$year <= 2019, "CDC archived tables", "Estimated from CDC trends")

cat(sprintf("  CDC prescribing data: %d state-years (%d states, %d-%d)\n",
            nrow(cdc_rx), length(unique(cdc_rx$state_abbr)),
            min(cdc_rx$year), max(cdc_rx$year)))

# Quick summary
cat("\n  National average opioid prescribing rate by year:\n")
national_avg <- cdc_rx %>%
  group_by(year, cdc_source) %>%
  summarize(mean_rate = round(mean(opioid_rx_rate), 1), .groups = "drop")
for (i in seq_len(nrow(national_avg))) {
  cat(sprintf("    %d: %.1f per 100 [%s]\n",
              national_avg$year[i], national_avg$mean_rate[i], national_avg$cdc_source[i]))
}

# ---------------------------------------------------------------------------
# 3. Merge with analysis panel
# ---------------------------------------------------------------------------
cat("\nMerging prescribing data with analysis panel...\n")

# Drop DC from prescribing data (not in panel)
cdc_rx <- cdc_rx %>% filter(state_abbr != "DC")

panel_rx <- panel %>%
  left_join(cdc_rx, by = c("state_abbr", "year"))

# Check merge success
n_merged <- sum(!is.na(panel_rx$opioid_rx_rate))
n_total  <- nrow(panel_rx)
cat(sprintf("  Merged: %d/%d observations have prescribing data (%.1f%%)\n",
            n_merged, n_total, 100 * n_merged / n_total))

if (n_merged == 0) {
  stop("No prescribing data merged. Check state_abbr and year alignment.")
}

# Report any missing
missing_states <- panel_rx %>%
  filter(is.na(opioid_rx_rate)) %>%
  distinct(state_abbr, year)
if (nrow(missing_states) > 0) {
  cat(sprintf("  WARNING: %d state-year observations missing prescribing data\n",
              nrow(missing_states)))
  # Drop observations with missing prescribing data
  panel_rx <- panel_rx %>% filter(!is.na(opioid_rx_rate))
  cat(sprintf("  After dropping missing: %d observations\n", nrow(panel_rx)))
}

# Create log prescribing rate for robustness
panel_rx$log_rx_rate <- log(panel_rx$opioid_rx_rate)

# ---------------------------------------------------------------------------
# 4. CS-DiD on opioid prescribing rate
# ---------------------------------------------------------------------------
cat("\n=== Callaway-Sant'Anna DiD: Opioid Prescribing Rate ===\n")
cat("  Outcome: Opioid dispensing rate per 100 persons\n")
cat("  Treatment: Must-access PDMP mandate (first_treat)\n")
cat("  Comparison: Never-treated states\n")
cat("  Anticipation: 1 year\n")
cat("  Bootstrap: Multiplier, 1000 iterations\n\n")

set.seed(20240109)

cs_rx <- tryCatch({
  att_gt(
    yname  = "opioid_rx_rate",
    tname  = "year",
    idname = "statefip",
    gname  = "first_treat",
    data   = panel_rx,
    control_group = "nevertreated",
    est_method    = "dr",
    bstrap        = TRUE,
    cband         = TRUE,
    biters        = 1000,
    anticipation  = 1
  )
}, error = function(e) {
  cat("ERROR in att_gt():", conditionMessage(e), "\n")
  cat("Attempting with notyettreated comparison group...\n")
  att_gt(
    yname  = "opioid_rx_rate",
    tname  = "year",
    idname = "statefip",
    gname  = "first_treat",
    data   = panel_rx,
    control_group = "notyettreated",
    est_method    = "dr",
    bstrap        = TRUE,
    cband         = TRUE,
    biters        = 1000,
    anticipation  = 1
  )
})

cat("CS-DiD ATT(g,t) estimation complete.\n\n")

# --- Overall ATT ---
att_overall_rx <- aggte(cs_rx, type = "simple")
cat(sprintf("Overall ATT (opioid rx rate): %.3f (SE: %.3f)\n",
            att_overall_rx$overall.att, att_overall_rx$overall.se))
p_val <- 2 * pnorm(-abs(att_overall_rx$overall.att / att_overall_rx$overall.se))
cat(sprintf("  p-value: %.4f\n", p_val))
cat(sprintf("  95%% CI: [%.3f, %.3f]\n",
            att_overall_rx$overall.att - 1.96 * att_overall_rx$overall.se,
            att_overall_rx$overall.att + 1.96 * att_overall_rx$overall.se))

# --- Group-level ATT ---
att_group_rx <- aggte(cs_rx, type = "group")
cat("\nGroup-level ATT:\n")
summary(att_group_rx)

# --- Dynamic ATT (event study) ---
att_dynamic_rx <- aggte(cs_rx, type = "dynamic", min_e = -6, max_e = 6)
cat("\nDynamic ATT (event study):\n")
summary(att_dynamic_rx)

# --- Also run on log prescribing rate ---
cat("\n=== CS-DiD: Log Opioid Prescribing Rate ===\n")

cs_log_rx <- tryCatch({
  att_gt(
    yname  = "log_rx_rate",
    tname  = "year",
    idname = "statefip",
    gname  = "first_treat",
    data   = panel_rx,
    control_group = "nevertreated",
    est_method    = "dr",
    bstrap        = TRUE,
    cband         = TRUE,
    biters        = 1000,
    anticipation  = 1
  )
}, error = function(e) {
  cat("ERROR in log rx att_gt():", conditionMessage(e), "\n")
  NULL
})

att_overall_log_rx <- NULL
att_dynamic_log_rx <- NULL
if (!is.null(cs_log_rx)) {
  att_overall_log_rx <- aggte(cs_log_rx, type = "simple")
  cat(sprintf("Overall ATT (log rx rate): %.4f (SE: %.4f)\n",
              att_overall_log_rx$overall.att, att_overall_log_rx$overall.se))
  p_val_log <- 2 * pnorm(-abs(att_overall_log_rx$overall.att / att_overall_log_rx$overall.se))
  cat(sprintf("  p-value: %.4f  [%.1f%% change]\n",
              p_val_log, 100 * (exp(att_overall_log_rx$overall.att) - 1)))

  att_dynamic_log_rx <- aggte(cs_log_rx, type = "dynamic", min_e = -6, max_e = 6)
}

# --- TWFE comparison ---
cat("\n=== TWFE Comparison: Opioid Prescribing Rate ===\n")
twfe_rx <- feols(opioid_rx_rate ~ treated | statefip + year,
                 data = panel_rx, cluster = ~statefip)
cat(sprintf("TWFE coefficient: %.3f (SE: %.3f)\n",
            coef(twfe_rx)["treated"], se(twfe_rx)["treated"]))

twfe_log_rx <- feols(log_rx_rate ~ treated | statefip + year,
                     data = panel_rx, cluster = ~statefip)
cat(sprintf("TWFE log coefficient: %.4f (SE: %.4f)  [%.1f%% change]\n",
            coef(twfe_log_rx)["treated"], se(twfe_log_rx)["treated"],
            100 * (exp(coef(twfe_log_rx)["treated"]) - 1)))

# ---------------------------------------------------------------------------
# 5. Event-study plot
# ---------------------------------------------------------------------------
cat("\n=== Creating event-study plot ===\n")

es_data <- data.frame(
  e     = att_dynamic_rx$egt,
  att   = att_dynamic_rx$att.egt,
  se    = att_dynamic_rx$se.egt
) %>%
  mutate(
    ci_lo = att - 1.96 * se,
    ci_hi = att + 1.96 * se,
    post  = e >= 0
  )

p_es <- ggplot(es_data, aes(x = e, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.8) +
  geom_point(aes(shape = post), color = "steelblue", size = 2.5, fill = "steelblue") +
  scale_shape_manual(values = c("FALSE" = 1, "TRUE" = 16), guide = "none") +
  annotate("text", x = -3.5, y = max(es_data$ci_hi) * 0.9,
           label = "Pre-treatment", size = 3.5, color = "gray40") +
  annotate("text", x = 3, y = max(es_data$ci_hi) * 0.9,
           label = "Post-treatment", size = 3.5, color = "gray40") +
  labs(
    title    = "First Stage: Must-Access PDMP Mandates and Opioid Prescribing",
    subtitle = sprintf("CS-DiD event study | Overall ATT = %.1f (SE = %.1f) prescriptions per 100",
                       att_overall_rx$overall.att, att_overall_rx$overall.se),
    x = "Years Relative to PDMP Mandate",
    y = "ATT: Opioid Dispensing Rate\n(prescriptions per 100 persons)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_first_stage_event_study.pdf"),
       p_es, width = 8, height = 5.5, device = cairo_pdf)
cat(sprintf("  Saved: %s\n", file.path(fig_dir, "fig_first_stage_event_study.pdf")))

# ---------------------------------------------------------------------------
# 6. Save results
# ---------------------------------------------------------------------------
cat("\n=== Saving results ===\n")

first_stage_results <- list(
  cs_rx           = cs_rx,
  att_overall_rx  = att_overall_rx,
  att_group_rx    = att_group_rx,
  att_dynamic_rx  = att_dynamic_rx,
  cs_log_rx       = cs_log_rx,
  att_overall_log_rx = att_overall_log_rx,
  att_dynamic_log_rx = att_dynamic_log_rx,
  twfe_rx         = twfe_rx,
  twfe_log_rx     = twfe_log_rx,
  cdc_rx_data     = cdc_rx,
  panel_rx        = panel_rx,
  es_plot_data    = es_data
)

saveRDS(first_stage_results, file.path(data_dir, "first_stage_att.rds"))
cat(sprintf("  Saved: %s\n", file.path(data_dir, "first_stage_att.rds")))

# ---------------------------------------------------------------------------
# 7. LaTeX table
# ---------------------------------------------------------------------------
cat("\n=== Generating LaTeX table ===\n")

# Build results table
tbl_rows <- data.frame(
  Specification = character(),
  Outcome       = character(),
  ATT           = character(),
  SE            = character(),
  CI_95         = character(),
  stringsAsFactors = FALSE
)

# Row 1: CS-DiD on level
tbl_rows <- rbind(tbl_rows, data.frame(
  Specification = "Callaway-Sant'Anna",
  Outcome       = "Rx rate per 100",
  ATT           = sprintf("%.2f", att_overall_rx$overall.att),
  SE            = sprintf("(%.2f)", att_overall_rx$overall.se),
  CI_95         = sprintf("[%.2f, %.2f]",
                          att_overall_rx$overall.att - 1.96 * att_overall_rx$overall.se,
                          att_overall_rx$overall.att + 1.96 * att_overall_rx$overall.se),
  stringsAsFactors = FALSE
))

# Row 2: CS-DiD on log
if (!is.null(att_overall_log_rx)) {
  tbl_rows <- rbind(tbl_rows, data.frame(
    Specification = "Callaway-Sant'Anna",
    Outcome       = "Log(Rx rate)",
    ATT           = sprintf("%.4f", att_overall_log_rx$overall.att),
    SE            = sprintf("(%.4f)", att_overall_log_rx$overall.se),
    CI_95         = sprintf("[%.4f, %.4f]",
                            att_overall_log_rx$overall.att - 1.96 * att_overall_log_rx$overall.se,
                            att_overall_log_rx$overall.att + 1.96 * att_overall_log_rx$overall.se),
    stringsAsFactors = FALSE
  ))
}

# Row 3: TWFE level
tbl_rows <- rbind(tbl_rows, data.frame(
  Specification = "TWFE",
  Outcome       = "Rx rate per 100",
  ATT           = sprintf("%.2f", coef(twfe_rx)["treated"]),
  SE            = sprintf("(%.2f)", se(twfe_rx)["treated"]),
  CI_95         = sprintf("[%.2f, %.2f]",
                          coef(twfe_rx)["treated"] - 1.96 * se(twfe_rx)["treated"],
                          coef(twfe_rx)["treated"] + 1.96 * se(twfe_rx)["treated"]),
  stringsAsFactors = FALSE
))

# Row 4: TWFE log
tbl_rows <- rbind(tbl_rows, data.frame(
  Specification = "TWFE",
  Outcome       = "Log(Rx rate)",
  ATT           = sprintf("%.4f", coef(twfe_log_rx)["treated"]),
  SE            = sprintf("(%.4f)", se(twfe_log_rx)["treated"]),
  CI_95         = sprintf("[%.4f, %.4f]",
                          coef(twfe_log_rx)["treated"] - 1.96 * se(twfe_log_rx)["treated"],
                          coef(twfe_log_rx)["treated"] + 1.96 * se(twfe_log_rx)["treated"]),
  stringsAsFactors = FALSE
))

# Group ATT rows
cat("  Adding group-level ATT to table...\n")
grp_df <- data.frame(
  group = att_group_rx$egt,
  att   = att_group_rx$att.egt,
  se    = att_group_rx$se.egt
)

# Write LaTeX
tex_file <- file.path(tab_dir, "first_stage_results.tex")
sink(tex_file)

cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{First Stage: Effect of Must-Access PDMP Mandates on Opioid Prescribing}\n")
cat("\\label{tab:first_stage}\n")
cat("\\small\n")
cat("\\begin{tabular}{llccc}\n")
cat("\\toprule\n")
cat("Specification & Outcome & ATT & SE & 95\\% CI \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Overall ATT}} \\\\\n")
for (i in seq_len(nrow(tbl_rows))) {
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n",
              tbl_rows$Specification[i], tbl_rows$Outcome[i],
              tbl_rows$ATT[i], tbl_rows$SE[i], tbl_rows$CI_95[i]))
}

cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Group-level ATT (CS-DiD, Rx rate per 100)}} \\\\\n")
for (i in seq_len(nrow(grp_df))) {
  p_grp <- 2 * pnorm(-abs(grp_df$att[i] / grp_df$se[i]))
  stars <- ifelse(p_grp < 0.01, "***", ifelse(p_grp < 0.05, "**", ifelse(p_grp < 0.1, "*", "")))
  cat(sprintf("Cohort %d & Rx rate per 100 & %.2f%s & (%.2f) & [%.2f, %.2f] \\\\\n",
              grp_df$group[i], grp_df$att[i], stars, grp_df$se[i],
              grp_df$att[i] - 1.96 * grp_df$se[i],
              grp_df$att[i] + 1.96 * grp_df$se[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")

# Notes
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3cm}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} This table reports first-stage estimates of the effect of must-access PDMP mandates\n")
cat("on opioid prescribing rates (dispensing rate per 100 persons). Panel~A shows overall ATT estimates\n")
cat("from both Callaway-Sant'Anna (2021) and two-way fixed effects specifications. Panel~B reports\n")
cat("cohort-specific ATT estimates from the CS-DiD estimator. The comparison group consists of\n")
cat("never-treated states. Standard errors are computed via multiplier bootstrap (1,000 iterations)\n")
cat("with one year of anticipation. Opioid prescribing data from CDC/IQVIA Xponent (2006--2019\n")
cat("from archived CDC tables; 2020--2022 estimated from CDC national trends).\n")
cat("$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{minipage}\n")

cat("\\end{table}\n")
sink()
cat(sprintf("  Saved: %s\n", tex_file))

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
cat("\n========================================\n")
cat("FIRST-STAGE RESULTS SUMMARY\n")
cat("========================================\n")
cat(sprintf("CS-DiD ATT (Rx rate):     %+.2f (%.2f), p=%.4f\n",
            att_overall_rx$overall.att, att_overall_rx$overall.se, p_val))
if (!is.null(att_overall_log_rx)) {
  p_val_log <- 2 * pnorm(-abs(att_overall_log_rx$overall.att / att_overall_log_rx$overall.se))
  cat(sprintf("CS-DiD ATT (log Rx rate): %+.4f (%.4f), p=%.4f  [%.1f%%]\n",
              att_overall_log_rx$overall.att, att_overall_log_rx$overall.se,
              p_val_log, 100 * (exp(att_overall_log_rx$overall.att) - 1)))
}
cat(sprintf("TWFE (Rx rate):           %+.2f (%.2f)\n",
            coef(twfe_rx)["treated"], se(twfe_rx)["treated"]))
cat(sprintf("TWFE (log Rx rate):       %+.4f (%.4f)  [%.1f%%]\n",
            coef(twfe_log_rx)["treated"], se(twfe_log_rx)["treated"],
            100 * (exp(coef(twfe_log_rx)["treated"]) - 1)))

cat("\nPre-treatment trend test (dynamic ATT, e < 0):\n")
pre_es <- es_data %>% filter(e < 0)
cat(sprintf("  Pre-treatment ATTs: %s\n",
            paste(sprintf("e=%d: %.2f", pre_es$e, pre_es$att), collapse = ", ")))
pre_joint_stat <- sum((pre_es$att / pre_es$se)^2)
pre_joint_p <- 1 - pchisq(pre_joint_stat, df = nrow(pre_es))
cat(sprintf("  Joint test (chi-sq): stat=%.2f, df=%d, p=%.4f\n",
            pre_joint_stat, nrow(pre_es), pre_joint_p))

cat("\nData sources:\n")
cat("  2006-2019: CDC archived state opioid dispensing rate tables (IQVIA Xponent)\n")
cat("  2020-2022: Estimated from CDC national averages with state-specific trends\n")
cat("========================================\n")
cat("\nOutputs saved:\n")
cat(sprintf("  Data:   %s\n", file.path(data_dir, "first_stage_att.rds")))
cat(sprintf("  Figure: %s\n", file.path(fig_dir, "fig_first_stage_event_study.pdf")))
cat(sprintf("  Table:  %s\n", tex_file))
cat("\n07_first_stage.R complete.\n")
