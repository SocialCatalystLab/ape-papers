###############################################################################
# 02_clean_data.R — Construct analysis variables
# Paper: Social Insurance Thresholds and Late-Career Underemployment
# APEP-0440
###############################################################################

source("00_packages.R")

cat("=== Loading Raw Data ===\n")
dt <- as.data.table(read_parquet("../data/acs_pums_raw.parquet"))
cat(sprintf("Loaded %s observations\n", format(nrow(dt), big.mark = ",")))

# === 1. Clean and recode core variables ===
cat("\n=== Cleaning Core Variables ===\n")

# Convert to numeric where needed
dt[, AGEP := as.integer(AGEP)]
dt[, WKHP := as.integer(WKHP)]
dt[, PINCP := as.numeric(PINCP)]
dt[, PWGTP := as.integer(PWGTP)]
dt[, SEX := as.integer(SEX)]
dt[, SCHL := as.integer(SCHL)]
dt[, OCCP := as.character(OCCP)]
dt[, ST := as.integer(ST)]
dt[, ESR := as.integer(ESR)]

# Employment status
# ESR: 1=employed at work, 2=employed absent, 3=unemployed,
#      4=armed forces at work, 5=armed forces absent, 6=not in LF
dt[, employed := ESR %in% c(1L, 2L)]
dt[, in_labor_force := ESR %in% c(1L, 2L, 3L)]

# Sex
dt[, female := as.integer(SEX == 2L)]

# Race categories
dt[, RAC1P := as.integer(RAC1P)]
dt[, race_cat := fcase(
  RAC1P == 1L, "White",
  RAC1P == 2L, "Black",
  RAC1P == 6L, "Asian",
  default = "Other"
)]

# Hispanic indicator
dt[, HISP := as.integer(HISP)]
dt[, hispanic := as.integer(HISP > 1L)]

# Education categories
# SCHL: 21=Bachelor's, 22=Master's, 23=Professional, 24=Doctorate
dt[, educ_cat := fcase(
  SCHL <= 15L, "Less than HS",
  SCHL %in% 16:17, "HS diploma/GED",
  SCHL %in% 18:20, "Some college/Associate's",
  SCHL == 21L, "Bachelor's",
  SCHL >= 22L, "Graduate degree",
  default = "Unknown"
)]
dt[, has_bachelors := as.integer(SCHL >= 21L)]
dt[, has_graduate := as.integer(SCHL >= 22L)]
dt[, educ_years := fcase(
  SCHL <= 11L, 0L,   # No schooling to grade 5
  SCHL == 12L, 6L,   # Grade 6
  SCHL == 13L, 7L,
  SCHL == 14L, 8L,
  SCHL == 15L, 10L,  # Some HS
  SCHL == 16L, 12L,  # HS diploma
  SCHL == 17L, 12L,  # GED
  SCHL == 18L, 13L,  # Some college < 1 yr
  SCHL == 19L, 14L,  # Some college 1+ yr
  SCHL == 20L, 14L,  # Associate's
  SCHL == 21L, 16L,  # Bachelor's
  SCHL == 22L, 18L,  # Master's
  SCHL == 23L, 20L,  # Professional
  SCHL == 24L, 20L,  # Doctorate
  default = 12L
)]

# Insurance type indicators
dt[, HINS1 := as.integer(HINS1)]
dt[, HINS2 := as.integer(HINS2)]
dt[, has_employer_ins := as.integer(HINS1 == 1L)]
dt[, has_medicare := as.integer(HINS2 == 1L)]

# Class of worker
dt[, COW := as.integer(COW)]
dt[, self_employed := as.integer(COW %in% c(6L, 7L))]

# Helper: weighted median (defined before first use in O*NET section)
weighted.median <- function(x, w, na.rm = FALSE) {
  if (na.rm) {
    keep <- !is.na(x) & !is.na(w)
    x <- x[keep]; w <- w[keep]
  }
  if (length(x) == 0) return(NA_real_)
  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  cum_w <- cumsum(w) / sum(w)
  x[which(cum_w >= 0.5)[1]]
}

# === 2. Construct O*NET-based overqualification measure ===
cat("\n=== Constructing Overqualification Measures ===\n")

# Load O*NET Job Zones
jz <- NULL

# Try Excel first
if (file.exists("../data/onet_job_zones.xlsx")) {
  tryCatch({
    jz <- as.data.table(read_excel("../data/onet_job_zones.xlsx"))
    cat("  Loaded O*NET Job Zones from Excel\n")
  }, error = function(e) {
    cat(sprintf("  Could not read Excel: %s\n", e$message))
  })
}

# Try text format
if (is.null(jz) && file.exists("../data/onet_job_zones.txt")) {
  jz <- fread("../data/onet_job_zones.txt", sep = "\t")
  cat("  Loaded O*NET Job Zones from text\n")
}

# If O*NET data unavailable, construct approximate Job Zones from occupation codes
if (is.null(jz) || nrow(jz) == 0) {
  cat("  O*NET data not available. Using education-based occupation classification.\n")
  cat("  Constructing Job Zones from ACS data (modal education by occupation).\n")

  # Compute modal education level for each occupation
  # This gives us an empirical measure of typical education in each occupation
  occ_educ <- dt[employed == TRUE & !is.na(OCCP) & OCCP != "",
                 .(median_educ_years = weighted.median(educ_years, w = PWGTP, na.rm = TRUE),
                   mean_educ_years = weighted.mean(educ_years, w = PWGTP, na.rm = TRUE),
                   n_workers = .N),
                 by = OCCP]

  # Assign Job Zones based on median education
  occ_educ[, job_zone := fcase(
    median_educ_years <= 11, 1L,   # Little or no preparation
    median_educ_years <= 12, 2L,   # Some preparation (HS)
    median_educ_years <= 14, 3L,   # Medium preparation (some college)
    median_educ_years <= 16, 4L,   # Considerable preparation (bachelor's)
    median_educ_years > 16, 5L,    # Extensive preparation (graduate+)
    default = 3L
  )]

  # Merge back
  dt <- merge(dt, occ_educ[, .(OCCP, job_zone, median_educ_years)],
              by = "OCCP", all.x = TRUE)

} else {
  # Parse O*NET Job Zones and merge via SOC code
  # O*NET uses SOC codes (e.g., "11-1011.00"); ACS uses OCCP codes
  # We need a crosswalk: extract 6-digit SOC from O*NET, map to ACS OCCP

  # Standardize column names
  jz_names <- tolower(names(jz))
  names(jz) <- jz_names

  # Find the SOC code and Job Zone columns
  soc_col <- grep("o\\*net|soc|code", jz_names, value = TRUE)[1]
  jz_col <- grep("zone", jz_names, value = TRUE)[1]

  if (!is.na(soc_col) && !is.na(jz_col)) {
    jz[, soc_6digit := gsub("\\..*", "", get(soc_col))]  # Strip minor code
    jz[, job_zone := as.integer(get(jz_col))]

    # For now, use occupation-level median education as the primary measure
    # (more robust than relying on imperfect SOC-OCCP crosswalk)
    occ_educ <- dt[employed == TRUE & !is.na(OCCP) & OCCP != "",
                   .(median_educ_years = weighted.mean(educ_years, w = PWGTP, na.rm = TRUE),
                     n_workers = .N),
                   by = OCCP]

    occ_educ[, job_zone := fcase(
      median_educ_years <= 11, 1L,
      median_educ_years <= 12, 2L,
      median_educ_years <= 14, 3L,
      median_educ_years <= 16, 4L,
      median_educ_years > 16, 5L,
      default = 3L
    )]

    dt <- merge(dt, occ_educ[, .(OCCP, job_zone, median_educ_years)],
                by = "OCCP", all.x = TRUE)
  }
}

# === 3. Construct underemployment outcome variables ===
cat("\n=== Constructing Underemployment Measures ===\n")

# Restrict to employed workers for outcome construction
dt_emp <- dt[employed == TRUE]

# Measure 1: Involuntary part-time (working < 35 hours)
# ACS doesn't have explicit "wants full-time" variable
# Proxy: working < 35 hours among those in the labor force
dt_emp[, part_time := as.integer(WKHP < 35)]
dt_emp[, full_time := as.integer(WKHP >= 35)]

# For involuntary PT, use income as proxy: PT workers with income
# below median for their age-education group likely want more hours
dt_emp[, inc_below_median := {
  med_inc <- median(PINCP[PINCP > 0], na.rm = TRUE)
  as.integer(PINCP < med_inc & PINCP > 0)
}, by = .(educ_cat, cut(AGEP, breaks = c(52, 57, 62, 67, 72, 76)))]

# Involuntary PT proxy: works part-time AND income below group median
dt_emp[, involuntary_pt := as.integer(part_time == 1L & inc_below_median == 1L)]

# Measure 2: Overqualification (education-occupation mismatch)
# Worker has bachelor's+ but works in occupation requiring less than bachelor's (Job Zone ≤ 3)
dt_emp[, overqualified := as.integer(has_bachelors == 1L & !is.na(job_zone) & job_zone <= 3L)]

# Alternative: graduate degree holder in job zone ≤ 3
dt_emp[, severe_overqual := as.integer(has_graduate == 1L & !is.na(job_zone) & job_zone <= 3L)]

# Measure 3: Education-occupation mismatch (continuous)
# Difference between worker's education years and occupation's typical education
dt_emp[, educ_mismatch := educ_years - fifelse(is.na(median_educ_years), educ_years, median_educ_years)]
dt_emp[, positive_mismatch := pmax(educ_mismatch, 0)]  # Only overeducation

# Measure 4: Earnings mismatch
# Worker earns below 25th percentile for their education level (among employed)
dt_emp[, earnings_mismatch := {
  p25 <- quantile(PINCP[PINCP > 0], 0.25, na.rm = TRUE)
  as.integer(PINCP > 0 & PINCP < p25)
}, by = educ_cat]

# Measure 5: Composite underemployment index
# Standardize each measure and average
dt_emp[, z_pt := (part_time - mean(part_time, na.rm = TRUE)) / sd(part_time, na.rm = TRUE)]
dt_emp[, z_overqual := (overqualified - mean(overqualified, na.rm = TRUE)) / sd(overqualified, na.rm = TRUE)]
dt_emp[, z_earnings := (earnings_mismatch - mean(earnings_mismatch, na.rm = TRUE)) / sd(earnings_mismatch, na.rm = TRUE)]
dt_emp[, composite_underemploy := (z_pt + z_overqual + z_earnings) / 3]

# === 4. Construct RDD variables ===
cat("\n=== Constructing RDD Variables ===\n")

# Centered age variables for each cutoff
dt_emp[, age_c62 := AGEP - 62L]  # Centered at SS threshold
dt_emp[, age_c65 := AGEP - 65L]  # Centered at Medicare threshold

# Treatment indicators
dt_emp[, above_62 := as.integer(AGEP >= 62L)]
dt_emp[, above_65 := as.integer(AGEP >= 65L)]

# Bandwidth indicators
dt_emp[, in_bw5_62 := as.integer(abs(age_c62) <= 5)]
dt_emp[, in_bw10_62 := as.integer(abs(age_c62) <= 10)]
dt_emp[, in_bw5_65 := as.integer(abs(age_c65) <= 5)]
dt_emp[, in_bw10_65 := as.integer(abs(age_c65) <= 10)]

# === 5. Summary statistics ===
cat("\n=== Summary Statistics ===\n")

cat(sprintf("Total employed workers aged 52-75: %s\n",
            format(nrow(dt_emp), big.mark = ",")))
cat(sprintf("  With bachelor's+: %s (%.1f%%)\n",
            format(sum(dt_emp$has_bachelors), big.mark = ","),
            100 * mean(dt_emp$has_bachelors)))
cat(sprintf("  Part-time (<35 hrs): %.1f%%\n",
            100 * weighted.mean(dt_emp$part_time, dt_emp$PWGTP, na.rm = TRUE)))
cat(sprintf("  Overqualified (BA+ in JZ≤3): %.1f%%\n",
            100 * weighted.mean(dt_emp$overqualified, dt_emp$PWGTP, na.rm = TRUE)))
cat(sprintf("  Has employer insurance: %.1f%%\n",
            100 * weighted.mean(dt_emp$has_employer_ins, dt_emp$PWGTP, na.rm = TRUE)))
cat(sprintf("  Has Medicare: %.1f%%\n",
            100 * weighted.mean(dt_emp$has_medicare, dt_emp$PWGTP, na.rm = TRUE)))

# Age distribution
cat("\nObservations by age (employed workers):\n")
age_tab <- dt_emp[, .(n = .N, wt_n = sum(PWGTP)), by = AGEP][order(AGEP)]
print(age_tab)

# === 6. Save analysis dataset ===
cat("\n=== Saving Analysis Dataset ===\n")

# Save employed workers dataset
write_parquet(dt_emp, "../data/analysis_employed.parquet")
cat(sprintf("  Saved: data/analysis_employed.parquet (%s obs)\n",
            format(nrow(dt_emp), big.mark = ",")))

# Save full dataset (including non-employed, for extensive margin analysis)
write_parquet(dt, "../data/analysis_full.parquet")
cat(sprintf("  Saved: data/analysis_full.parquet (%s obs)\n",
            format(nrow(dt), big.mark = ",")))

# Save age-level cell means for RDD plotting
cells_62 <- dt_emp[in_bw10_62 == 1L,
  .(part_time_rate = weighted.mean(part_time, PWGTP, na.rm = TRUE),
    overqual_rate = weighted.mean(overqualified, PWGTP, na.rm = TRUE),
    earnings_mismatch_rate = weighted.mean(earnings_mismatch, PWGTP, na.rm = TRUE),
    involuntary_pt_rate = weighted.mean(involuntary_pt, PWGTP, na.rm = TRUE),
    composite = weighted.mean(composite_underemploy, PWGTP, na.rm = TRUE),
    mean_hours = weighted.mean(WKHP, PWGTP, na.rm = TRUE),
    pct_employer_ins = weighted.mean(has_employer_ins, PWGTP, na.rm = TRUE),
    pct_medicare = weighted.mean(has_medicare, PWGTP, na.rm = TRUE),
    pct_female = weighted.mean(female, PWGTP, na.rm = TRUE),
    pct_bachelors = weighted.mean(has_bachelors, PWGTP, na.rm = TRUE),
    mean_income = weighted.mean(PINCP, PWGTP, na.rm = TRUE),
    n = .N,
    wt_n = sum(PWGTP)),
  by = AGEP]

cells_65 <- dt_emp[in_bw10_65 == 1L,
  .(part_time_rate = weighted.mean(part_time, PWGTP, na.rm = TRUE),
    overqual_rate = weighted.mean(overqualified, PWGTP, na.rm = TRUE),
    earnings_mismatch_rate = weighted.mean(earnings_mismatch, PWGTP, na.rm = TRUE),
    involuntary_pt_rate = weighted.mean(involuntary_pt, PWGTP, na.rm = TRUE),
    composite = weighted.mean(composite_underemploy, PWGTP, na.rm = TRUE),
    mean_hours = weighted.mean(WKHP, PWGTP, na.rm = TRUE),
    pct_employer_ins = weighted.mean(has_employer_ins, PWGTP, na.rm = TRUE),
    pct_medicare = weighted.mean(has_medicare, PWGTP, na.rm = TRUE),
    pct_female = weighted.mean(female, PWGTP, na.rm = TRUE),
    pct_bachelors = weighted.mean(has_bachelors, PWGTP, na.rm = TRUE),
    mean_income = weighted.mean(PINCP, PWGTP, na.rm = TRUE),
    n = .N,
    wt_n = sum(PWGTP)),
  by = AGEP]

fwrite(cells_62, "../data/cells_age62.csv")
fwrite(cells_65, "../data/cells_age65.csv")
cat("  Saved: data/cells_age62.csv, data/cells_age65.csv\n")

cat("\n=== Data Cleaning Complete ===\n")
