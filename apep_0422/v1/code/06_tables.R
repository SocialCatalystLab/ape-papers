## ============================================================================
## 06_tables.R — All table generation
## Paper: Can Clean Cooking Save Lives? (apep_0422)
## ============================================================================

source(file.path(dirname(sys.frame(1)$ofile), "00_packages.R"))

district <- fread(file.path(data_dir, "district_analysis.csv"))
panel    <- fread(file.path(data_dir, "panel_analysis.csv"))
load(file.path(data_dir, "regression_objects.RData"))
load(file.path(data_dir, "robustness_objects.RData"))

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 1: Summary Statistics
# ═══════════════════════════════════════════════════════════════════════════════

cat("=== Table 1: Summary Statistics ===\n\n")

summ_vars <- c("nfhs4_val_clean_fuel", "nfhs5_val_clean_fuel", "delta_clean_fuel",
               "nfhs4_val_diarrhea_prev", "nfhs5_val_diarrhea_prev", "delta_diarrhea",
               "nfhs4_val_stunting", "nfhs5_val_stunting", "delta_stunting",
               "nfhs4_val_underweight", "nfhs5_val_underweight", "delta_underweight",
               "nfhs4_val_female_school", "nfhs5_val_female_school", "delta_female_school",
               "ujjwala_exposure")

summ_labels <- c("Clean fuel (NFHS-4)", "Clean fuel (NFHS-5)", "Δ Clean fuel",
                 "Diarrhea (NFHS-4)", "Diarrhea (NFHS-5)", "Δ Diarrhea",
                 "Stunting (NFHS-4)", "Stunting (NFHS-5)", "Δ Stunting",
                 "Underweight (NFHS-4)", "Underweight (NFHS-5)", "Δ Underweight",
                 "Female school (NFHS-4)", "Female school (NFHS-5)", "Δ Female school",
                 "Ujjwala exposure")

summ_table <- data.table(
  Variable = summ_labels,
  N = sapply(summ_vars, function(v) sum(!is.na(district[[v]]))),
  Mean = sapply(summ_vars, function(v) round(mean(district[[v]], na.rm = TRUE), 2)),
  SD = sapply(summ_vars, function(v) round(sd(district[[v]], na.rm = TRUE), 2)),
  Min = sapply(summ_vars, function(v) round(min(district[[v]], na.rm = TRUE), 2)),
  Max = sapply(summ_vars, function(v) round(max(district[[v]], na.rm = TRUE), 2))
)

print(summ_table)

# Write LaTeX table
sink(file.path(tab_dir, "tab1_summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lrrrrr}\n")
cat("\\hline\\hline\n")
cat("Variable & N & Mean & SD & Min & Max \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: Clean Fuel}} \\\\\n")
for (i in 1:3) {
  cat(summ_table$Variable[i], "&", summ_table$N[i], "&", summ_table$Mean[i], "&",
      summ_table$SD[i], "&", summ_table$Min[i], "&", summ_table$Max[i], "\\\\\n")
}
cat("\\multicolumn{6}{l}{\\textit{Panel B: Health Outcomes}} \\\\\n")
for (i in 4:12) {
  cat(summ_table$Variable[i], "&", summ_table$N[i], "&", summ_table$Mean[i], "&",
      summ_table$SD[i], "&", summ_table$Min[i], "&", summ_table$Max[i], "\\\\\n")
}
cat("\\multicolumn{6}{l}{\\textit{Panel C: Education}} \\\\\n")
for (i in 13:15) {
  cat(summ_table$Variable[i], "&", summ_table$N[i], "&", summ_table$Mean[i], "&",
      summ_table$SD[i], "&", summ_table$Min[i], "&", summ_table$Max[i], "\\\\\n")
}
cat("\\multicolumn{6}{l}{\\textit{Panel D: Treatment}} \\\\\n")
cat(summ_table$Variable[16], "&", summ_table$N[16], "&", summ_table$Mean[16], "&",
    summ_table$SD[16], "&", summ_table$Min[16], "&", summ_table$Max[16], "\\\\\n")
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\vspace{0.5em}\n")
cat("{\\small \\textit{Notes:} All variables in percentage points except Ujjwala exposure (0--1 scale). NFHS-4 refers to 2015-16; NFHS-5 refers to 2019-21. $\\Delta$ denotes NFHS-5 minus NFHS-4. Ujjwala exposure $= (100 - \\text{NFHS-4 clean fuel \\%}) / 100$.}\n")
cat("\\end{table}\n")
sink()
cat("Saved: tab1_summary_stats.tex\n")

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 2: First Stage — Ujjwala Exposure → Clean Fuel Change
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n=== Table 2: First Stage ===\n")

etable(feols(delta_clean_fuel ~ ujjwala_exposure, data = district, se = "hetero"),
       feols(delta_clean_fuel ~ ujjwala_exposure + baseline_electricity +
               baseline_sanitation + baseline_water + baseline_female_literate,
             data = district, se = "hetero"),
       feols(delta_clean_fuel ~ ujjwala_exposure + baseline_electricity +
               baseline_sanitation + baseline_water | state_code,
             data = district, se = "hetero"),
       tex = TRUE,
       file = file.path(tab_dir, "tab2_first_stage.tex"),
       title = "First Stage: Ujjwala Exposure and Clean Fuel Adoption",
       label = "tab:first_stage",
       headers = c("$\\Delta$ Clean Fuel", "$\\Delta$ Clean Fuel", "$\\Delta$ Clean Fuel"),
       dict = c(ujjwala_exposure = "Ujjwala exposure",
                baseline_electricity = "Baseline electricity",
                baseline_sanitation = "Baseline sanitation",
                baseline_water = "Baseline water access",
                baseline_female_literate = "Baseline female literacy"),
       notes = "HC1 robust standard errors in parentheses. Ujjwala exposure = (100 - NFHS-4 clean fuel \\%) / 100.")
cat("Saved: tab2_first_stage.tex\n")

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 3: Main Results — Reduced Form
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n=== Table 3: Reduced Form Results ===\n")

etable(feols(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
               baseline_sanitation + baseline_water + baseline_female_literate |
               state_code, data = district),
       feols(delta_stunting ~ ujjwala_exposure + baseline_electricity +
               baseline_sanitation + baseline_water + baseline_female_literate |
               state_code, data = district),
       feols(delta_underweight ~ ujjwala_exposure + baseline_electricity +
               baseline_sanitation + baseline_water + baseline_female_literate |
               state_code, data = district),
       tex = TRUE,
       file = file.path(tab_dir, "tab3_reduced_form.tex"),
       title = "Reduced Form: Ujjwala Exposure and Child Health Outcomes",
       label = "tab:reduced_form",
       headers = c("$\\Delta$ Diarrhea", "$\\Delta$ Stunting", "$\\Delta$ Underweight"),
       dict = c(ujjwala_exposure = "Ujjwala exposure",
                baseline_electricity = "Baseline electricity",
                baseline_sanitation = "Baseline sanitation",
                baseline_water = "Baseline water access",
                baseline_female_literate = "Baseline female literacy"),
       se = "hetero",
       notes = "HC1 robust standard errors in parentheses. State fixed effects included. Dependent variables: change in health indicator (pp) from NFHS-4 to NFHS-5.")
cat("Saved: tab3_reduced_form.tex\n")

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 4: Panel DiD Results
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n=== Table 4: Panel DiD ===\n")

etable(did_fuel, did_diarrhea, did_stunting,
       tex = TRUE,
       file = file.path(tab_dir, "tab4_panel_did.tex"),
       title = "Na\\\"ive Panel DiD (Without State$\\times$Period FE)",
       label = "tab:panel_did",
       headers = c("Clean Fuel", "Diarrhea", "Stunting"),
       dict = c("ujjwala_exposure:post_ujjwala" = "Exposure $\\times$ Post"),
       notes = "District and period FE included but not state$\\times$period interactions. Positive health coefficients reflect concentration of high-exposure districts in states with worst aggregate trends. See Section 5 for discussion.")
cat("Saved: tab4_panel_did.tex\n")

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 5: IV Results
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n=== Table 5: IV Estimates ===\n")

etable(iv_diarrhea, iv_stunting,
       tex = TRUE,
       file = file.path(tab_dir, "tab5_iv.tex"),
       title = "IV Estimates: Clean Fuel Adoption and Child Health",
       label = "tab:iv",
       headers = c("Diarrhea", "Stunting"),
       dict = c(delta_clean_fuel = "$\\Delta$ Clean fuel",
                fit_delta_clean_fuel = "$\\Delta$ Clean fuel",
                baseline_electricity = "Baseline electricity",
                baseline_sanitation = "Baseline sanitation",
                baseline_water = "Baseline water access"),
       se = "hetero",
       fitstat = ~ n + r2 + ivf,
       notes = "Instrument: baseline Ujjwala exposure. State FE and baseline controls included. HC1 robust SE.")
cat("Saved: tab5_iv.tex\n")

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 6: Robustness — Placebo Tests
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n=== Table 6: Placebo Tests ===\n")

placebo_table <- data.table(
  Test = c("Fuel gap → Δ Diarrhea (REAL)",
           "Electricity gap → Δ Diarrhea (PLACEBO TREATMENT)",
           "Fuel gap → Δ Vaccination (PLACEBO OUTCOME)",
           "Fuel gap → Δ Institutional births (PLACEBO OUTCOME)"),
  Coefficient = c(
    round(coef(lm(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
                    baseline_sanitation + baseline_water + baseline_female_literate +
                    factor(state_code), data = district))["ujjwala_exposure"], 3),
    round(coef(placebo_diarrhea)["electricity_gap"], 3),
    round(coef(placebo_vacc)["ujjwala_exposure"], 3),
    round(coef(placebo_inst_births)["ujjwala_exposure"], 3)
  ),
  SE = c(
    round(sqrt(vcovHC(lm(delta_diarrhea ~ ujjwala_exposure + baseline_electricity +
                           baseline_sanitation + baseline_water + baseline_female_literate +
                           factor(state_code), data = district), type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    round(sqrt(vcovHC(placebo_diarrhea, type = "HC1")["electricity_gap", "electricity_gap"]), 3),
    round(sqrt(vcovHC(placebo_vacc, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3),
    round(sqrt(vcovHC(placebo_inst_births, type = "HC1")["ujjwala_exposure", "ujjwala_exposure"]), 3)
  )
)

print(placebo_table)

# Write LaTeX
sink(file.path(tab_dir, "tab6_placebos.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Placebo Tests}\n")
cat("\\label{tab:placebos}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat("Test & Coefficient & SE \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(placebo_table)) {
  cat(placebo_table$Test[i], "&", placebo_table$Coefficient[i], "&",
      placebo_table$SE[i], "\\\\\n")
}
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\vspace{0.5em}\n")
cat("{\\small \\textit{Notes:} All specifications include state FE and baseline controls. HC1 robust SE. Row 1 is the real treatment effect. Rows 2--4 are placebos that should show null effects.}\n")
cat("\\end{table}\n")
sink()
cat("Saved: tab6_placebos.tex\n")

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 7: Horse Race
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n=== Table 7: Horse Race (controlling for concurrent program changes) ===\n")

# Construct delta variables for concurrent programs if not already present
if (!"delta_electricity" %in% names(district)) {
  district[, delta_electricity := nfhs5_val_electricity - nfhs4_val_electricity]
}
if (!"delta_sanitation" %in% names(district)) {
  district[, delta_sanitation := nfhs5_val_improved_sanitation - nfhs4_val_improved_sanitation]
}
if (!"delta_water" %in% names(district)) {
  district[, delta_water := nfhs5_val_improved_water - nfhs4_val_improved_water]
}

etable(feols(delta_diarrhea ~ ujjwala_exposure + delta_sanitation + delta_water |
               state_code, data = district),
       feols(delta_stunting ~ ujjwala_exposure + delta_sanitation + delta_water |
               state_code, data = district),
       feols(delta_underweight ~ ujjwala_exposure + delta_sanitation + delta_water |
               state_code, data = district),
       tex = TRUE,
       file = file.path(tab_dir, "tab7_horse_race.tex"),
       title = "Controlling for Concurrent Infrastructure Changes",
       label = "tab:horse_race",
       headers = c("$\\Delta$ Diarrhea", "$\\Delta$ Stunting", "$\\Delta$ Underweight"),
       dict = c(ujjwala_exposure = "Ujjwala exposure",
                delta_sanitation = "$\\Delta$ Sanitation",
                delta_water = "$\\Delta$ Water access"),
       se = "hetero",
       notes = "HC1 robust SE. State FE included. Controls for changes in sanitation and water coverage between NFHS rounds to address confounding from Swachh Bharat Mission and Jal Jeevan Mission.")
cat("Saved: tab7_horse_race.tex\n")

cat("\n=== All Tables Generated ===\n")
