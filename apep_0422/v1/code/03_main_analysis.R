## ============================================================================
## 03_main_analysis.R — Primary regressions
## Paper: Can Clean Cooking Save Lives? (apep_0422)
## ============================================================================

source(file.path(dirname(sys.frame(1)$ofile), "00_packages.R"))

district <- fread(file.path(data_dir, "district_analysis.csv"))
panel    <- fread(file.path(data_dir, "panel_analysis.csv"))

cat("=== Main Analysis ===\n")
cat("Districts:", nrow(district), "\n")
cat("Panel rows:", nrow(panel), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════════
# ANALYSIS A: First Stage — Ujjwala Exposure → Clean Fuel Adoption
# ═══════════════════════════════════════════════════════════════════════════════

cat("── A. First Stage: Exposure → Δ Clean Fuel ──\n")

# A1: Bivariate
fs1 <- lm(delta_clean_fuel ~ ujjwala_exposure, data = district)
# A2: With controls
fs2 <- lm(delta_clean_fuel ~ ujjwala_exposure + baseline_electricity +
             baseline_sanitation + baseline_water + baseline_female_literate,
           data = district)
# A3: State FE
fs3 <- lm(delta_clean_fuel ~ ujjwala_exposure + baseline_electricity +
             baseline_sanitation + baseline_water + baseline_female_literate +
             factor(state_code), data = district)

cat("First stage (no controls):\n")
cat("  β =", round(coef(fs1)["ujjwala_exposure"], 2),
    ", SE =", round(sqrt(vcovHC(fs1, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 2),
    ", N =", nobs(fs1), "\n")
cat("First stage (with controls):\n")
cat("  β =", round(coef(fs2)["ujjwala_exposure"], 2),
    ", SE =", round(sqrt(vcovHC(fs2, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 2),
    ", N =", nobs(fs2), "\n")
cat("First stage (state FE):\n")
cat("  β =", round(coef(fs3)["ujjwala_exposure"], 2),
    ", SE =", round(sqrt(vcovHC(fs3, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 2),
    ", N =", nobs(fs3), "\n")

# F-statistic for first stage (use feols for cleaner computation)
fs3_fe <- feols(delta_clean_fuel ~ ujjwala_exposure + baseline_electricity +
                  baseline_sanitation + baseline_water + baseline_female_literate |
                  state_code, data = district, se = "hetero")
cat("  First-stage F (feols, state FE):", round(fitstat(fs3_fe, "f")$f$stat, 1), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════════
# ANALYSIS B: Reduced Form — Ujjwala Exposure → Health Outcomes
# ═══════════════════════════════════════════════════════════════════════════════

cat("── B. Reduced Form: Exposure → Health Outcomes ──\n")

# B1: Diarrhea prevalence (expected: negative β)
rf_diarrhea_1 <- lm(delta_diarrhea ~ ujjwala_exposure, data = district)
rf_diarrhea_2 <- lm(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
                       baseline_sanitation + baseline_water + baseline_female_literate,
                     data = district)
rf_diarrhea_3 <- lm(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
                       baseline_sanitation + baseline_water + baseline_female_literate +
                       factor(state_code), data = district)

cat("Diarrhea (no controls):\n")
cat("  β =", round(coef(rf_diarrhea_1)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(rf_diarrhea_1, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    ", N =", nobs(rf_diarrhea_1), "\n")
cat("Diarrhea (state FE):\n")
cat("  β =", round(coef(rf_diarrhea_3)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(rf_diarrhea_3, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    ", N =", nobs(rf_diarrhea_3), "\n")

# B2: Stunting
rf_stunting_1 <- lm(delta_stunting ~ ujjwala_exposure, data = district)
rf_stunting_2 <- lm(delta_stunting ~ ujjwala_exposure + baseline_electricity +
                       baseline_sanitation + baseline_water + baseline_female_literate,
                     data = district)
rf_stunting_3 <- lm(delta_stunting ~ ujjwala_exposure + baseline_electricity +
                       baseline_sanitation + baseline_water + baseline_female_literate +
                       factor(state_code), data = district)

cat("Stunting (no controls):\n")
cat("  β =", round(coef(rf_stunting_1)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(rf_stunting_1, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    ", N =", nobs(rf_stunting_1), "\n")
cat("Stunting (state FE):\n")
cat("  β =", round(coef(rf_stunting_3)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(rf_stunting_3, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    ", N =", nobs(rf_stunting_3), "\n")

# B3: Underweight
rf_under_1 <- lm(delta_underweight ~ ujjwala_exposure, data = district)
rf_under_3 <- lm(delta_underweight ~ ujjwala_exposure + baseline_electricity +
                    baseline_sanitation + baseline_water + baseline_female_literate +
                    factor(state_code), data = district)
cat("Underweight (state FE):\n")
cat("  β =", round(coef(rf_under_3)["ujjwala_exposure"], 3),
    ", SE =", round(sqrt(vcovHC(rf_under_3, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    ", N =", nobs(rf_under_3), "\n\n")

# B4: Anemia (if available)
rf_anemia_w3 <- NULL
if ("delta_women_anemia" %in% names(district)) {
  rf_anemia_w1 <- lm(delta_women_anemia ~ ujjwala_exposure, data = district)
  rf_anemia_w3 <- lm(delta_women_anemia ~ ujjwala_exposure + baseline_electricity +
                        baseline_sanitation + baseline_water + baseline_female_literate +
                        factor(state_code), data = district)
  cat("Women's anemia (state FE):\n")
  cat("  β =", round(coef(rf_anemia_w3)["ujjwala_exposure"], 3),
      ", SE =", round(sqrt(vcovHC(rf_anemia_w3, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
      ", N =", nobs(rf_anemia_w3), "\n")
}

rf_anemia_c3 <- NULL
if ("delta_child_anemia" %in% names(district)) {
  rf_anemia_c3 <- lm(delta_child_anemia ~ ujjwala_exposure + baseline_electricity +
                        baseline_sanitation + baseline_water + baseline_female_literate +
                        factor(state_code), data = district)
  cat("Child anemia (state FE):\n")
  cat("  β =", round(coef(rf_anemia_c3)["ujjwala_exposure"], 3),
      ", SE =", round(sqrt(vcovHC(rf_anemia_c3, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
      ", N =", nobs(rf_anemia_c3), "\n\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# ANALYSIS C: Panel DiD with fixest (2-period)
# ═══════════════════════════════════════════════════════════════════════════════

cat("── C. Panel DiD (2-period, district FE) ──\n")

# Clean fuel (first stage in panel)
panel_fuel <- panel[outcome_var == "clean_fuel" & !is.na(outcome) & !is.na(ujjwala_exposure)]
did_fuel <- feols(outcome ~ ujjwala_exposure:post_ujjwala | district_id + period,
                  data = panel_fuel, cluster = ~state_code)
cat("Clean fuel DiD:\n")
print(summary(did_fuel))

# Diarrhea
panel_diarrhea <- panel[outcome_var == "diarrhea_prev" & !is.na(outcome) & !is.na(ujjwala_exposure)]
did_diarrhea <- feols(outcome ~ ujjwala_exposure:post_ujjwala | district_id + period,
                      data = panel_diarrhea, cluster = ~state_code)
cat("\nDiarrhea DiD:\n")
print(summary(did_diarrhea))

# Stunting
panel_stunting <- panel[outcome_var == "stunting" & !is.na(outcome) & !is.na(ujjwala_exposure)]
did_stunting <- feols(outcome ~ ujjwala_exposure:post_ujjwala | district_id + period,
                      data = panel_stunting, cluster = ~state_code)
cat("\nStunting DiD:\n")
print(summary(did_stunting))

# Female school attendance
panel_fschool <- panel[outcome_var == "female_school" & !is.na(outcome) & !is.na(ujjwala_exposure)]
did_fschool <- feols(outcome ~ ujjwala_exposure:post_ujjwala | district_id + period,
                     data = panel_fschool, cluster = ~state_code)
cat("\nFemale school DiD:\n")
print(summary(did_fschool))

# ═══════════════════════════════════════════════════════════════════════════════
# ANALYSIS D: IV — Baseline Fuel Gap → Δ Clean Fuel → Δ Health
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── D. IV Estimates ──\n")

# IV: Diarrhea (use | state_code | syntax to absorb FE properly)
iv_diarrhea <- feols(delta_diarrhea ~ baseline_electricity + baseline_sanitation +
                       baseline_water | state_code |
                       delta_clean_fuel ~ ujjwala_exposure,
                     data = district, se = "hetero")
cat("IV: Δ clean fuel → Δ diarrhea:\n")
print(summary(iv_diarrhea))
cat("  First-stage F:", round(fitstat(iv_diarrhea, "ivf")$ivf1$stat, 1), "\n")

# IV: Stunting
iv_stunting <- feols(delta_stunting ~ baseline_electricity + baseline_sanitation +
                       baseline_water | state_code |
                       delta_clean_fuel ~ ujjwala_exposure,
                     data = district, se = "hetero")
cat("\nIV: Δ clean fuel → Δ stunting:\n")
print(summary(iv_stunting))
cat("  First-stage F:", round(fitstat(iv_stunting, "ivf")$ivf1$stat, 1), "\n")

# ═══════════════════════════════════════════════════════════════════════════════
# ANALYSIS E: Heterogeneity by Exposure Tercile
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n── E. Heterogeneity by Exposure Tercile ──\n")

het_fuel <- feols(outcome ~ exposure_tercile:post_ujjwala | district_id + period,
                  data = panel_fuel[!is.na(exposure_tercile)],
                  cluster = ~state_code)
cat("Clean fuel by tercile:\n")
print(summary(het_fuel))

het_diarrhea <- feols(outcome ~ exposure_tercile:post_ujjwala | district_id + period,
                      data = panel_diarrhea[!is.na(exposure_tercile)],
                      cluster = ~state_code)
cat("\nDiarrhea by tercile:\n")
print(summary(het_diarrhea))

# ═══════════════════════════════════════════════════════════════════════════════
# Save regression objects
# ═══════════════════════════════════════════════════════════════════════════════

save(fs1, fs2, fs3,
     rf_diarrhea_1, rf_diarrhea_2, rf_diarrhea_3,
     rf_stunting_1, rf_stunting_2, rf_stunting_3,
     rf_under_1, rf_under_3,
     rf_anemia_w3, rf_anemia_c3,
     did_fuel, did_diarrhea, did_stunting, did_fschool,
     iv_diarrhea, iv_stunting,
     het_fuel, het_diarrhea,
     file = file.path(data_dir, "regression_objects.RData"))

cat("\nRegression objects saved.\n")
cat("=== Main Analysis Complete ===\n")
