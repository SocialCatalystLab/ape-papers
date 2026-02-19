###############################################################################
# 03_main_analysis.R — Main regressions: MW spillovers on graduate earnings
# APEP-0372: Minimum Wage Spillovers to College Graduate Earnings
###############################################################################

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE)

###############################################################################
# 1. Load analysis data
###############################################################################

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
df_cip <- readRDS(file.path(data_dir, "analysis_cip.rds"))

cat(sprintf("Analysis data: %d rows\n", nrow(df)))
cat(sprintf("CIP data: %d rows\n", nrow(df_cip)))

###############################################################################
# 2. Summary Statistics (Table 1)
###############################################################################

cat("\n=== Summary Statistics ===\n")

# Panel A: By degree group
sum_stats <- df %>%
  filter(degree_group %in% c("Certificate", "Associate", "Bachelor's")) %>%
  group_by(degree_group) %>%
  summarise(
    N = n(),
    `N (Y1 P25)` = sum(!is.na(y1_p25)),
    Institutions = n_distinct(inst_id),
    States = n_distinct(state_fips),
    Cohorts = n_distinct(cohort),
    `Y1 P25 ($)` = mean(y1_p25, na.rm = TRUE),
    `Y1 P50 ($)` = mean(y1_p50, na.rm = TRUE),
    `Y1 P75 ($)` = mean(y1_p75, na.rm = TRUE),
    `Y5 P50 ($)` = mean(y5_p50, na.rm = TRUE),
    `MW Annual ($)` = mean(mw_annual, na.rm = TRUE),
    `P25/MW Ratio` = mean(y1_p25 / mw_annual, na.rm = TRUE),
    .groups = "drop"
  )

print(sum_stats)

# Save Table 1
sink(file.path(tables_dir, "table1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Degree Level}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & Certificate & Associate & Bachelor's \\\\\n")
cat("\\hline\n")

for (var in c("N (Y1 P25)", "Institutions", "States", "Cohorts")) {
  vals <- sapply(c("Certificate", "Associate", "Bachelor's"), function(g) {
    v <- sum_stats %>% filter(degree_group == g) %>% pull(!!sym(var))
    if (length(v) == 0) return("--")
    formatC(v, format = "d", big.mark = ",")
  })
  cat(sprintf("%s & %s & %s & %s \\\\\n", var, vals[1], vals[2], vals[3]))
}

cat("\\hline\n")
cat("\\multicolumn{4}{l}{\\textit{Mean Earnings (\\$2023)}} \\\\\n")

for (var in c("Y1 P25 ($)", "Y1 P50 ($)", "Y1 P75 ($)", "Y5 P50 ($)")) {
  vals <- sapply(c("Certificate", "Associate", "Bachelor's"), function(g) {
    v <- sum_stats %>% filter(degree_group == g) %>% pull(!!sym(var))
    if (length(v) == 0) return("--")
    formatC(round(v), format = "d", big.mark = ",")
  })
  label <- gsub(" \\(\\$\\)", "", var)
  cat(sprintf("%s & %s & %s & %s \\\\\n", label, vals[1], vals[2], vals[3]))
}

cat("\\hline\n")
vals_mw <- sapply(c("Certificate", "Associate", "Bachelor's"), function(g) {
  v <- sum_stats %>% filter(degree_group == g) %>% pull(`MW Annual ($)`)
  if (length(v) == 0) return("--")
  formatC(round(v), format = "d", big.mark = ",")
})
cat(sprintf("MW Annual & %s & %s & %s \\\\\n", vals_mw[1], vals_mw[2], vals_mw[3]))

vals_ratio <- sapply(c("Certificate", "Associate", "Bachelor's"), function(g) {
  v <- sum_stats %>% filter(degree_group == g) %>% pull(`P25/MW Ratio`)
  if (length(v) == 0) return("--")
  sprintf("%.2f", v)
})
cat(sprintf("P25/MW Ratio & %s & %s & %s \\\\\n", vals_ratio[1], vals_ratio[2], vals_ratio[3]))

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Data from Census PSEO Time Series (2001--2019 cohorts). ")
cat("Earnings measured in 2023 dollars. MW Annual is the annualized effective state ")
cat("minimum wage (40 hrs/week $\\times$ 52 weeks). P25/MW Ratio is the ratio of ")
cat("mean 25th percentile first-year earnings to annualized MW.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

###############################################################################
# 3. Main Regressions — TWFE (Table 2)
###############################################################################

cat("\n=== Main TWFE Regressions ===\n")

# Focus on bachelor's first (largest sample)
df_ba <- df %>% filter(degree_group == "Bachelor's", !is.na(ln_y1_p25))

cat(sprintf("Bachelor's sample: %d obs, %d inst, %d states\n",
            nrow(df_ba), n_distinct(df_ba$inst_id), n_distinct(df_ba$state_fips)))

# Specification 1: Institution + Cohort FE only
m1_p25 <- feols(ln_y1_p25 ~ ln_mw | inst_id + cohort, data = df_ba, cluster = "state_fips")
m1_p50 <- feols(ln_y1_p50 ~ ln_mw | inst_id + cohort, data = df_ba, cluster = "state_fips")
m1_p75 <- feols(ln_y1_p75 ~ ln_mw | inst_id + cohort, data = df_ba, cluster = "state_fips")

cat("\n--- Bachelor's: Baseline TWFE ---\n")
cat(sprintf("  P25: β = %.4f (SE = %.4f)\n", coef(m1_p25)["ln_mw"], se(m1_p25)["ln_mw"]))
cat(sprintf("  P50: β = %.4f (SE = %.4f)\n", coef(m1_p50)["ln_mw"], se(m1_p50)["ln_mw"]))
cat(sprintf("  P75: β = %.4f (SE = %.4f)\n", coef(m1_p75)["ln_mw"], se(m1_p75)["ln_mw"]))

# Specification 2: Add state controls
m2_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
                data = df_ba, cluster = "state_fips")
m2_p50 <- feols(ln_y1_p50 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
                data = df_ba, cluster = "state_fips")
m2_p75 <- feols(ln_y1_p75 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
                data = df_ba, cluster = "state_fips")

cat("\n--- Bachelor's: With State Controls ---\n")
cat(sprintf("  P25: β = %.4f (SE = %.4f)\n", coef(m2_p25)["ln_mw"], se(m2_p25)["ln_mw"]))
cat(sprintf("  P50: β = %.4f (SE = %.4f)\n", coef(m2_p50)["ln_mw"], se(m2_p50)["ln_mw"]))
cat(sprintf("  P75: β = %.4f (SE = %.4f)\n", coef(m2_p75)["ln_mw"], se(m2_p75)["ln_mw"]))

# Specification 3: Region × Cohort FE
df_ba <- df_ba %>% mutate(region_cohort = paste(region, cohort, sep = "_"))

m3_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + region_cohort,
                data = df_ba, cluster = "state_fips")
m3_p50 <- feols(ln_y1_p50 ~ ln_mw + unemp_avg + ln_income | inst_id + region_cohort,
                data = df_ba, cluster = "state_fips")
m3_p75 <- feols(ln_y1_p75 ~ ln_mw + unemp_avg + ln_income | inst_id + region_cohort,
                data = df_ba, cluster = "state_fips")

cat("\n--- Bachelor's: Region × Cohort FE ---\n")
cat(sprintf("  P25: β = %.4f (SE = %.4f)\n", coef(m3_p25)["ln_mw"], se(m3_p25)["ln_mw"]))
cat(sprintf("  P50: β = %.4f (SE = %.4f)\n", coef(m3_p50)["ln_mw"], se(m3_p50)["ln_mw"]))
cat(sprintf("  P75: β = %.4f (SE = %.4f)\n", coef(m3_p75)["ln_mw"], se(m3_p75)["ln_mw"]))

###############################################################################
# 4. By Degree Level (Table 3)
###############################################################################

cat("\n=== By Degree Level ===\n")

degree_results <- list()

for (dg in c("Certificate", "Associate", "Bachelor's")) {
  df_sub <- df %>% filter(degree_group == dg, !is.na(ln_y1_p25))
  if (nrow(df_sub) < 50 || n_distinct(df_sub$inst_id) < 10) {
    cat(sprintf("  %s: Insufficient data (%d obs)\n", dg, nrow(df_sub)))
    next
  }

  m_p25 <- tryCatch(
    feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
          data = df_sub, cluster = "state_fips"),
    error = function(e) NULL
  )
  m_p50 <- tryCatch(
    feols(ln_y1_p50 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
          data = df_sub, cluster = "state_fips"),
    error = function(e) NULL
  )
  m_p75 <- tryCatch(
    feols(ln_y1_p75 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
          data = df_sub, cluster = "state_fips"),
    error = function(e) NULL
  )

  if (!is.null(m_p25)) {
    degree_results[[dg]] <- list(
      degree = dg, n = nrow(df_sub),
      n_inst = n_distinct(df_sub$inst_id),
      n_states = n_distinct(df_sub$state_fips),
      p25_beta = coef(m_p25)["ln_mw"], p25_se = se(m_p25)["ln_mw"],
      p50_beta = if(!is.null(m_p50)) coef(m_p50)["ln_mw"] else NA,
      p50_se = if(!is.null(m_p50)) se(m_p50)["ln_mw"] else NA,
      p75_beta = if(!is.null(m_p75)) coef(m_p75)["ln_mw"] else NA,
      p75_se = if(!is.null(m_p75)) se(m_p75)["ln_mw"] else NA
    )
    cat(sprintf("  %s: P25 β=%.4f (%.4f), P50 β=%.4f (%.4f), P75 β=%.4f (%.4f) [N=%d]\n",
                dg,
                degree_results[[dg]]$p25_beta, degree_results[[dg]]$p25_se,
                degree_results[[dg]]$p50_beta, degree_results[[dg]]$p50_se,
                degree_results[[dg]]$p75_beta, degree_results[[dg]]$p75_se,
                nrow(df_sub)))
  }
}

###############################################################################
# 5. By Time Horizon (Y1, Y5, Y10)
###############################################################################

cat("\n=== Time Horizon Analysis (Bachelor's) ===\n")

horizon_results <- list()

for (horizon in c("y1", "y5", "y10")) {
  for (pctile in c("p25", "p50", "p75")) {
    yvar <- paste0("ln_", horizon, "_", pctile)
    df_h <- df_ba %>% filter(!is.na(!!sym(yvar)))

    if (nrow(df_h) < 50) {
      cat(sprintf("  %s_%s: Insufficient data (%d obs)\n", horizon, pctile, nrow(df_h)))
      next
    }

    m <- tryCatch(
      feols(as.formula(paste(yvar, "~ ln_mw + unemp_avg + ln_income | inst_id + cohort")),
            data = df_h, cluster = "state_fips"),
      error = function(e) NULL
    )

    if (!is.null(m)) {
      key <- paste(horizon, pctile, sep = "_")
      horizon_results[[key]] <- list(
        horizon = horizon, pctile = pctile,
        beta = coef(m)["ln_mw"], se = se(m)["ln_mw"],
        n = nrow(df_h)
      )
      cat(sprintf("  %s_%s: β = %.4f (SE = %.4f), N = %d\n",
                  horizon, pctile, coef(m)["ln_mw"], se(m)["ln_mw"], nrow(df_h)))
    }
  }
}

###############################################################################
# 6. CIP-Level Heterogeneity (Bachelor's only)
###############################################################################

cat("\n=== CIP-Level Heterogeneity ===\n")

cip_results <- list()

for (wg in c("Low-wage", "Mid-wage", "High-wage")) {
  df_sub <- df_cip %>%
    filter(wage_group == wg, !is.na(ln_y1_p25)) %>%
    mutate(inst_cip = paste(inst_id, cip2, sep = "_"))

  if (nrow(df_sub) < 100 || n_distinct(df_sub$inst_cip) < 20) {
    cat(sprintf("  %s: Insufficient data (%d obs)\n", wg, nrow(df_sub)))
    next
  }

  m <- tryCatch(
    feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_cip + cohort,
          data = df_sub, cluster = "state_fips"),
    error = function(e) NULL
  )

  if (!is.null(m)) {
    cip_results[[wg]] <- list(
      group = wg, beta = coef(m)["ln_mw"], se = se(m)["ln_mw"],
      n = nrow(df_sub), n_units = n_distinct(df_sub$inst_cip)
    )
    cat(sprintf("  %s: β = %.4f (SE = %.4f), N = %d, Units = %d\n",
                wg, coef(m)["ln_mw"], se(m)["ln_mw"], nrow(df_sub),
                n_distinct(df_sub$inst_cip)))
  }
}

###############################################################################
# 7. Save regression output
###############################################################################

cat("\n=== Saving Results ===\n")

results <- list(
  main_ba = list(m1_p25 = m1_p25, m1_p50 = m1_p50, m1_p75 = m1_p75,
                 m2_p25 = m2_p25, m2_p50 = m2_p50, m2_p75 = m2_p75,
                 m3_p25 = m3_p25, m3_p50 = m3_p50, m3_p75 = m3_p75),
  degree_results = degree_results,
  horizon_results = horizon_results,
  cip_results = cip_results
)

saveRDS(results, file.path(data_dir, "regression_results.rds"))

# Generate Table 2 (Main results)
sink(file.path(tables_dir, "table2_main.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Minimum Wage on Bachelor's Degree Graduate Earnings}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\hline\\hline\n")
cat(" & \\multicolumn{2}{c}{P25} & \\multicolumn{2}{c}{P50} & \\multicolumn{2}{c}{P75} \\\\\n")
cat(" & (1) & (2) & (3) & (4) & (5) & (6) \\\\\n")
cat("\\hline\n")

# Row for ln(MW) coefficient
format_coef <- function(m) sprintf("%.4f", coef(m)["ln_mw"])
format_se <- function(m) sprintf("(%.4f)", se(m)["ln_mw"])
format_stars <- function(m) {
  p <- fixest::pvalue(m)["ln_mw"]
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

cat(sprintf("$\\ln(MW)$ & %s%s & %s%s & %s%s & %s%s & %s%s & %s%s \\\\\n",
            format_coef(m1_p25), format_stars(m1_p25),
            format_coef(m2_p25), format_stars(m2_p25),
            format_coef(m1_p50), format_stars(m1_p50),
            format_coef(m2_p50), format_stars(m2_p50),
            format_coef(m1_p75), format_stars(m1_p75),
            format_coef(m2_p75), format_stars(m2_p75)))

cat(sprintf(" & %s & %s & %s & %s & %s & %s \\\\\n",
            format_se(m1_p25), format_se(m2_p25),
            format_se(m1_p50), format_se(m2_p50),
            format_se(m1_p75), format_se(m2_p75)))

cat("\\hline\n")
cat("State controls & No & Yes & No & Yes & No & Yes \\\\\n")
cat("Institution FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n")
cat("Cohort FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n")

cat(sprintf("Observations & %s & %s & %s & %s & %s & %s \\\\\n",
            formatC(m1_p25$nobs, big.mark = ","),
            formatC(m2_p25$nobs, big.mark = ","),
            formatC(m1_p50$nobs, big.mark = ","),
            formatC(m2_p50$nobs, big.mark = ","),
            formatC(m1_p75$nobs, big.mark = ","),
            formatC(m2_p75$nobs, big.mark = ",")))

cat(sprintf("Clusters (states) & %d & %d & %d & %d & %d & %d \\\\\n",
            n_distinct(df_ba$state_fips), n_distinct(df_ba$state_fips),
            n_distinct(df_ba$state_fips), n_distinct(df_ba$state_fips),
            n_distinct(df_ba$state_fips), n_distinct(df_ba$state_fips)))

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Dependent variables are log earnings at the 25th, 50th, and 75th percentiles, ")
cat("measured one year after graduation. $\\ln(MW)$ is the log of the average effective state ")
cat("minimum wage during the 3-year graduation cohort window. State controls include the ")
cat("unemployment rate and log per capita income averaged over the cohort window. ")
cat("Standard errors clustered at the state level in parentheses. ")
cat("$^{***}$, $^{**}$, $^{*}$ denote significance at the 1\\%, 5\\%, and 10\\% levels.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("All results saved.\n")
