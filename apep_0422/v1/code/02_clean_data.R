## ============================================================================
## 02_clean_data.R — Construct treatment variable and analysis dataset
## Paper: Can Clean Cooking Save Lives? (apep_0422)
## ============================================================================

source(file.path(dirname(sys.frame(1)$ofile), "00_packages.R"))

# ── 1. Load and reshape NFHS district data ───────────────────────────────────
nfhs_raw <- fread(file.path(data_dir, "nfhs_district_raw.csv"))

# Key indicators for our analysis
fuel_indicators <- c(
  "Households using clean fuel for cooking (%)"
)

health_indicators <- c(
  "Prevalence of diarrhoea in the 2 weeks preceding the survey (%)",
  "Children under 5 years who are stunted (height for age) (%)",
  "Children under 5 years who are underweight (weight for age) (%)",
  "Children under 5 years who are wasted (weight for height) (%)",
  "Children age 12-23 months who received most of their vaccinations in a public health facility (%)"
)

# ARI indicator — look for it in the data
ari_candidates <- c(
  "Children under 5 years who had symptoms of ARI in the 2 weeks preceding the survey (%)",
  "Prevalence of symptoms of acute respiratory infection (ARI) in the 2 weeks preceding the survey (%)"
)

anemia_indicators <- c(
  "All women age 15-49 years who are anaemic (%)",
  "Children age 6-59 months who are anaemic (%)"
)

education_indicators <- c(
  "Female population age 6 years and above who ever attended school (%)",
  "Women who are literate (%)",
  "Women with 10 or more years of schooling (%)"
)

sanitation_indicators <- c(
  "Population living in households that use an improved sanitation facility (%)"
)

water_indicators <- c(
  "Population living in households with an improved drinkingwater source (%)"
)

other_indicators <- c(
  "Population living in households with electricity (%)",
  "Institutional births (%)",
  "Children age 12-23 months fully vaccinated based on information from either vaccination card or mother's recall (%)"
)

all_indicators <- c(fuel_indicators, health_indicators, ari_candidates,
                    anemia_indicators, education_indicators, sanitation_indicators,
                    water_indicators, other_indicators)

# Check which indicators exist in data
existing <- intersect(all_indicators, unique(nfhs_raw$Indicator))
cat("Matched", length(existing), "of", length(all_indicators), "requested indicators\n")

# Also search for ARI-related indicators
ari_found <- grep("ARI|respiratory|acute resp", unique(nfhs_raw$Indicator),
                  value = TRUE, ignore.case = TRUE)
cat("ARI-related indicators found:", paste(ari_found, collapse = " | "), "\n")

# Filter to our indicators
nfhs <- nfhs_raw[Indicator %in% existing]

# Create short variable names
nfhs[, var_name := fcase(
  Indicator == fuel_indicators[1], "clean_fuel",
  Indicator == health_indicators[1], "diarrhea_prev",
  Indicator == health_indicators[2], "stunting",
  Indicator == health_indicators[3], "underweight",
  Indicator == health_indicators[4], "wasting",
  grepl("ARI|acute resp", Indicator, ignore.case = TRUE), "ari",
  Indicator == anemia_indicators[1], "women_anemia",
  Indicator == anemia_indicators[2], "child_anemia",
  Indicator == education_indicators[1], "female_school",
  Indicator == education_indicators[2], "female_literate",
  Indicator == education_indicators[3], "female_10yr_school",
  Indicator == sanitation_indicators[1], "improved_sanitation",
  Indicator == water_indicators[1], "improved_water",
  Indicator == other_indicators[1], "electricity",
  Indicator == other_indicators[2], "institutional_births",
  Indicator == other_indicators[3], "full_vaccination",
  default = NA_character_
)]

# Drop unmatched
nfhs <- nfhs[!is.na(var_name)]

# Convert to numeric
nfhs[, nfhs5_val := suppressWarnings(as.numeric(`NFHS 5`))]
nfhs[, nfhs4_val := suppressWarnings(as.numeric(`NFHS 4`))]
nfhs[, change := nfhs5_val - nfhs4_val]

# ── 2. Reshape to wide format (one row per district) ────────────────────────
district_wide <- dcast(nfhs,
  State + ST_CEN_CD + District + DISTRICT + DT_CEN_CD ~ var_name,
  value.var = c("nfhs4_val", "nfhs5_val", "change"),
  fun.aggregate = function(x) x[1])

setnames(district_wide, "ST_CEN_CD", "state_code")
setnames(district_wide, "DT_CEN_CD", "district_code")

cat("District-wide dataset:", nrow(district_wide), "districts\n")

# ── 3. Construct treatment intensity variable ────────────────────────────────
# Treatment exposure = 1 - (NFHS-4 clean fuel %) / 100
# Higher values = lower baseline clean fuel → more Ujjwala eligibility/treatment

district_wide[, ujjwala_exposure := (100 - nfhs4_val_clean_fuel) / 100]

cat("\nUjjwala Exposure (1 - baseline clean fuel) distribution:\n")
cat("  Mean:", round(mean(district_wide$ujjwala_exposure, na.rm = TRUE), 3), "\n")
cat("  SD:  ", round(sd(district_wide$ujjwala_exposure, na.rm = TRUE), 3), "\n")
cat("  Min: ", round(min(district_wide$ujjwala_exposure, na.rm = TRUE), 3), "\n")
cat("  Max: ", round(max(district_wide$ujjwala_exposure, na.rm = TRUE), 3), "\n")
cat("  N non-missing:", sum(!is.na(district_wide$ujjwala_exposure)), "\n")

# Create exposure terciles
district_wide[, exposure_tercile := cut(ujjwala_exposure,
  breaks = quantile(ujjwala_exposure, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
  labels = c("Low Exposure", "Medium Exposure", "High Exposure"),
  include.lowest = TRUE)]

# ── 4. Construct first-difference outcomes ───────────────────────────────────
# Fuel outcome (first stage)
district_wide[, delta_clean_fuel := change_clean_fuel]

# Health outcomes
district_wide[, delta_diarrhea := change_diarrhea_prev]
district_wide[, delta_stunting := change_stunting]
district_wide[, delta_underweight := change_underweight]

# Try ARI
if ("change_ari" %in% names(district_wide)) {
  district_wide[, delta_ari := change_ari]
  cat("ARI outcome: available\n")
} else {
  cat("ARI outcome: NOT available in NFHS factsheets\n")
}

# Anemia outcomes
if ("change_women_anemia" %in% names(district_wide)) {
  district_wide[, delta_women_anemia := change_women_anemia]
  cat("Women's anemia: available\n")
}
if ("change_child_anemia" %in% names(district_wide)) {
  district_wide[, delta_child_anemia := change_child_anemia]
  cat("Child anemia: available\n")
}

# Education outcomes
district_wide[, delta_female_school := change_female_school]
district_wide[, delta_female_literate := change_female_literate]

# Placebo outcomes
district_wide[, delta_vaccination := change_full_vaccination]
district_wide[, delta_institutional_births := change_institutional_births]

# Sanitation (SBM confound)
district_wide[, delta_sanitation := change_improved_sanitation]
district_wide[, delta_water := change_improved_water]

# ── 5. Construct baseline controls ──────────────────────────────────────────
district_wide[, baseline_electricity := nfhs4_val_electricity / 100]
district_wide[, baseline_sanitation := nfhs4_val_improved_sanitation / 100]
district_wide[, baseline_water := nfhs4_val_improved_water / 100]
district_wide[, baseline_female_literate := nfhs4_val_female_literate / 100]
district_wide[, baseline_institutional_births := nfhs4_val_institutional_births / 100]

# Placebo treatment variables
district_wide[, electricity_gap := (100 - nfhs4_val_electricity) / 100]
district_wide[, sanitation_gap := (100 - nfhs4_val_improved_sanitation) / 100]
district_wide[, water_gap := (100 - nfhs4_val_improved_water) / 100]

# ── 6. Long panel format ───────────────────────────────────────────────────
outcome_vars <- c("clean_fuel", "diarrhea_prev", "stunting", "underweight",
                  "wasting", "female_school", "female_literate", "female_10yr_school",
                  "improved_sanitation", "improved_water", "electricity",
                  "institutional_births", "full_vaccination")

# Add anemia if available
if ("nfhs4_val_women_anemia" %in% names(district_wide)) {
  outcome_vars <- c(outcome_vars, "women_anemia")
}
if ("nfhs4_val_child_anemia" %in% names(district_wide)) {
  outcome_vars <- c(outcome_vars, "child_anemia")
}

panel_list <- list()
for (v in outcome_vars) {
  nfhs4_col <- paste0("nfhs4_val_", v)
  nfhs5_col <- paste0("nfhs5_val_", v)

  if (nfhs4_col %in% names(district_wide) & nfhs5_col %in% names(district_wide)) {
    dt_pre <- district_wide[, .(
      state_code, district_code, State, District,
      ujjwala_exposure, exposure_tercile,
      period = 0L, year = 2016L,
      outcome = get(nfhs4_col)
    )]
    dt_pre[, outcome_var := v]

    dt_post <- district_wide[, .(
      state_code, district_code, State, District,
      ujjwala_exposure, exposure_tercile,
      period = 1L, year = 2020L,
      outcome = get(nfhs5_col)
    )]
    dt_post[, outcome_var := v]

    panel_list[[length(panel_list) + 1]] <- rbind(dt_pre, dt_post)
  }
}

panel_long <- rbindlist(panel_list)
panel_long[, post_ujjwala := as.integer(period == 1)]
panel_long[, district_id := paste0(state_code, "_", district_code)]

cat("\nPanel dataset:", nrow(panel_long), "rows\n")
cat("  Districts:", length(unique(panel_long$district_id)), "\n")
cat("  Periods:  ", length(unique(panel_long$period)), "\n")
cat("  Outcomes: ", length(unique(panel_long$outcome_var)), "\n")

# ── 7. Save analysis datasets ───────────────────────────────────────────────
fwrite(district_wide, file.path(data_dir, "district_analysis.csv"))
fwrite(panel_long, file.path(data_dir, "panel_analysis.csv"))

cat("\nSaved: district_analysis.csv (", nrow(district_wide), "rows)\n")
cat("Saved: panel_analysis.csv (", nrow(panel_long), "rows)\n")
