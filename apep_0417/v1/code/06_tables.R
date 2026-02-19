## ============================================================
## 06_tables.R — All tables for the paper
## Paper: Where Medicaid Goes Dark (apep_0371)
## ============================================================

source("00_packages.R")

cat("\n=== Load Data ===\n")
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
robustness <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))
unwinding <- readRDS(file.path(DATA_DIR, "unwinding_treatment.rds"))

panel <- panel[!is.na(total_pop) & total_pop > 0 &
               state_fips %in% sprintf("%02d", c(1:56))]

cat("\n=== Table 1: Summary Statistics ===\n")

sumstats_spec <- panel[, .(
  `County-Quarters` = format(.N, big.mark = ","),
  `Counties` = format(uniqueN(county_fips), big.mark = ","),
  `Mean Providers` = sprintf("%.1f", mean(n_providers)),
  `SD` = sprintf("%.1f", sd(n_providers)),
  `\\% Zero` = sprintf("%.1f", 100 * mean(n_providers == 0)),
  `Per 10K Pop` = sprintf("%.2f", mean(providers_per_10k, na.rm = TRUE)),
  `\\% Desert` = sprintf("%.1f", 100 * mean(is_desert, na.rm = TRUE))
), by = .(Specialty = specialty)]

sumstats_spec <- sumstats_spec[order(-as.numeric(gsub(",", "", `County-Quarters`)))]

# LaTeX table
tab1_latex <- kbl(sumstats_spec, format = "latex", booktabs = TRUE,
                   escape = FALSE, align = c("l", rep("r", 7)),
                   caption = "Summary Statistics by Specialty",
                   label = "tab:sumstats") |>
  kable_styling(latex_options = c("scale_down")) |>
  footnote(general = "Sample: US county $\\\\times$ specialty $\\\\times$ quarter observations, 2018Q1--2024Q3. Active providers defined as billing $\\\\geq$4 Medicaid claims per quarter. Desert: $<$1 active provider per 10,000 county population.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab1_latex, file.path(TAB_DIR, "tab1_sumstats.tex"))
cat("  Saved tab1_sumstats.tex\n")

cat("\n=== Table 2: Provider Trends by Specialty and Year ===\n")

# Extract quarter-of-year (1-4) from quarter string
panel[, qtr_of_year := as.integer(substr(quarter, 6, 6))]

# Use only Q1-Q3 for all years so comparison is fair (2024 only has Q1-Q3)
trends <- panel[qtr_of_year <= 3, .(
  providers = sum(n_providers)
), by = .(specialty, year)]

trends_wide <- dcast(trends, specialty ~ year, value.var = "providers")

# Add change column (comparing Q1-Q3 of first year to Q1-Q3 of last year)
year_cols <- setdiff(names(trends_wide), "specialty")
first_year <- year_cols[1]
last_year <- year_cols[length(year_cols)]
trends_wide[, `Change (\\%)` := sprintf("%.1f",
  100 * (get(last_year) / get(first_year) - 1))]

tab2_latex <- kbl(trends_wide, format = "latex", booktabs = TRUE,
                   escape = FALSE, align = c("l", rep("r", ncol(trends_wide) - 1)),
                   caption = "Active Medicaid Providers by Specialty and Year",
                   label = "tab:trends",
                   format.args = list(big.mark = ",")) |>
  kable_styling(latex_options = c("scale_down")) |>
  footnote(general = "Providers with $\\\\geq$4 Medicaid claims per quarter. Sum across Q1--Q3 county-quarter observations in each year (Q4 excluded for comparability since 2024 data ends at Q3).",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab2_latex, file.path(TAB_DIR, "tab2_trends.tex"))
cat("  Saved tab2_trends.tex\n")

cat("\n=== Table 3: Main DiD Results ===\n")

# Build regression table from results
panel[, treat_intensity := post_unwind * net_disenroll_pct / 100]

m1 <- results$m1  # Pooled
m3 <- results$m3  # Desert indicator
m4_u <- results$m4_urban
m4_r <- results$m4_rural

# Specialty-specific from m2
m2 <- results$m2

# Compile by-specialty results
spec_rows <- lapply(names(m2), function(nm) {
  data.table(
    Specialty = gsub("sample\\.var: specialty; sample: ", "", nm),
    Estimate = sprintf("%.4f", coef(m2[[nm]])["treat_intensity"]),
    SE = sprintf("(%.4f)", se(m2[[nm]])["treat_intensity"]),
    Stars = ifelse(fixest::pvalue(m2[[nm]])["treat_intensity"] < 0.01, "***",
            ifelse(fixest::pvalue(m2[[nm]])["treat_intensity"] < 0.05, "**",
            ifelse(fixest::pvalue(m2[[nm]])["treat_intensity"] < 0.10, "*", ""))),
    N = format(nobs(m2[[nm]]), big.mark = ",")
  )
})
# Add pooled row first
pooled_row <- data.table(
  Specialty = "\\textit{Pooled (all specialties)}",
  Estimate = sprintf("%.4f", coef(m1)["treat_intensity"]),
  SE = sprintf("(%.4f)", se(m1)["treat_intensity"]),
  Stars = ifelse(fixest::pvalue(m1)["treat_intensity"] < 0.01, "***",
          ifelse(fixest::pvalue(m1)["treat_intensity"] < 0.05, "**",
          ifelse(fixest::pvalue(m1)["treat_intensity"] < 0.10, "*", ""))),
  N = format(nobs(m1), big.mark = ",")
)
spec_table <- rbind(pooled_row, rbindlist(spec_rows))

tab3_latex <- kbl(spec_table, format = "latex", booktabs = TRUE,
                   escape = FALSE, align = c("l", "r", "r", "c", "r"),
                   caption = "Effect of Medicaid Unwinding on Provider Supply by Specialty",
                   label = "tab:main_by_spec") |>
  kable_styling() |>
  footnote(general = "Dependent variable: $\\\\log$(active providers + 1). Treatment: post-unwinding $\\\\times$ net disenrollment rate. All models include county$\\\\times$specialty and quarter fixed effects. Standard errors clustered at the state level (51 clusters). * p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab3_latex, file.path(TAB_DIR, "tab3_main_by_specialty.tex"))
cat("  Saved tab3_main_by_specialty.tex\n")

cat("\n=== Table 4: Robustness Checks ===\n")

# Compile robustness table
rob_rows <- data.table(
  Specification = c(
    "Main (≥4 claims/qtr)",
    "Tight threshold (≥12 claims/qtr)",
    "Binary treatment (early vs. late)",
    "With Medicaid share × time",
    "Placebo (fake 2021Q2 treatment)"
  ),
  Estimate = c(
    sprintf("%.4f", coef(results$m1)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$rob1_tight)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$rob3_binary)["treat_binary"]),
    sprintf("%.4f", coef(robustness$rob4_controls)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$placebo)["fake_treat"])
  ),
  SE = c(
    sprintf("(%.4f)", se(results$m1)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$rob1_tight)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$rob3_binary)["treat_binary"]),
    sprintf("(%.4f)", se(robustness$rob4_controls)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$placebo)["fake_treat"])
  ),
  N = c(
    format(nobs(results$m1), big.mark = ","),
    format(nobs(robustness$rob1_tight), big.mark = ","),
    format(nobs(robustness$rob3_binary), big.mark = ","),
    format(nobs(robustness$rob4_controls), big.mark = ","),
    format(nobs(robustness$placebo), big.mark = ",")
  )
)

ri_note <- sprintf("Randomization inference (500 permutations of treatment timing across states) yields p = %.3f for the main specification.",
                   robustness$ri_pvalue)

tab4_latex <- kbl(rob_rows, format = "latex", booktabs = TRUE,
                   escape = FALSE,
                   caption = "Robustness Checks",
                   label = "tab:robustness") |>
  kable_styling() |>
  footnote(general = paste0("All models include county$\\\\times$specialty and quarter fixed effects with state-clustered standard errors (51 clusters). ", ri_note),
           escape = FALSE, threeparttable = TRUE)

writeLines(tab4_latex, file.path(TAB_DIR, "tab4_robustness.tex"))
cat("  Saved tab4_robustness.tex\n")

cat("\n=== Table 5: Desert County Counts by Specialty ===\n")

# Pre vs post unwinding desert counts
desert_counts <- panel[, .(
  pct_desert = 100 * mean(is_desert, na.rm = TRUE),
  n_desert = sum(is_desert, na.rm = TRUE),
  n_total = sum(!is.na(is_desert))
), by = .(specialty, period = ifelse(quarter < "2023Q2", "Pre-Unwinding (2018Q1-2023Q1)",
                                      "Post-Unwinding (2023Q2-2024Q3)"))]

# Also compute overall for consistency with Table 1
desert_overall <- panel[, .(
  pct_desert = 100 * mean(is_desert, na.rm = TRUE)
), by = .(specialty)]

desert_wide <- dcast(desert_counts, specialty ~ period, value.var = "pct_desert")
desert_wide <- merge(desert_wide, desert_overall, by = "specialty")
setnames(desert_wide, "pct_desert", "Overall")

# Reorder columns
setcolorder(desert_wide, c("specialty", "Pre-Unwinding (2018Q1-2023Q1)",
                            "Post-Unwinding (2023Q2-2024Q3)", "Overall"))

tab5_latex <- kbl(desert_wide, format = "latex", booktabs = TRUE,
                   digits = 1,
                   caption = "Percentage of County-Quarters in Desert Status, Pre vs. Post Unwinding",
                   label = "tab:desert_counts") |>
  kable_styling() |>
  footnote(general = "Desert: county-specialty-quarter with $<$1 active Medicaid provider per 10,000 population. Overall column is the unweighted mean across all quarters.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab5_latex, file.path(TAB_DIR, "tab5_desert_counts.tex"))
cat("  Saved tab5_desert_counts.tex\n")

cat("\nAll tables saved to:", TAB_DIR, "\n")
