###############################################################################
# 04_robustness.R — Robustness checks and falsification tests
# APEP-0372: Minimum Wage Spillovers to College Graduate Earnings
###############################################################################

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
df_cip <- readRDS(file.path(data_dir, "analysis_cip.rds"))

df_ba <- df %>%
  filter(degree_group == "Bachelor's", !is.na(ln_y1_p25)) %>%
  mutate(region_cohort = paste(region, cohort, sep = "_"))

###############################################################################
# 1. Falsification: Lead MW test
###############################################################################

cat("=== Falsification: Lead Minimum Wage ===\n")

# Check if FUTURE MW predicts CURRENT earnings
# Merge lead MW (next cohort's MW) onto current cohort
df_lead <- df_ba %>%
  arrange(inst_id, cohort) %>%
  group_by(inst_id) %>%
  mutate(
    ln_mw_lead = lead(ln_mw, 1),
    ln_mw_lag = lag(ln_mw, 1)
  ) %>%
  ungroup() %>%
  filter(!is.na(ln_mw_lead))

m_lead <- feols(ln_y1_p25 ~ ln_mw + ln_mw_lead + unemp_avg + ln_income | inst_id + cohort,
                data = df_lead, cluster = "state_fips")

cat(sprintf("  Current MW: β = %.4f (SE = %.4f, p = %.4f)\n",
            coef(m_lead)["ln_mw"], se(m_lead)["ln_mw"], fixest::pvalue(m_lead)["ln_mw"]))
cat(sprintf("  Lead MW: β = %.4f (SE = %.4f, p = %.4f)\n",
            coef(m_lead)["ln_mw_lead"], se(m_lead)["ln_mw_lead"], fixest::pvalue(m_lead)["ln_mw_lead"]))
cat("  (If lead MW is significant, pre-trends are violated)\n")

###############################################################################
# 2. Jackknife by state
###############################################################################

cat("\n=== Jackknife by State ===\n")

states <- unique(df_ba$state_fips)
jackknife_betas <- numeric(length(states))

for (i in seq_along(states)) {
  df_jk <- df_ba %>% filter(state_fips != states[i])
  m_jk <- tryCatch(
    feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
          data = df_jk, cluster = "state_fips"),
    error = function(e) NULL
  )
  if (!is.null(m_jk)) {
    jackknife_betas[i] <- coef(m_jk)["ln_mw"]
  } else {
    jackknife_betas[i] <- NA
  }
}

cat(sprintf("  Full sample β: %.4f\n", coef(m_lead)["ln_mw"]))
cat(sprintf("  Jackknife range: [%.4f, %.4f]\n",
            min(jackknife_betas, na.rm = TRUE), max(jackknife_betas, na.rm = TRUE)))
cat(sprintf("  Jackknife mean: %.4f\n", mean(jackknife_betas, na.rm = TRUE)))

###############################################################################
# 3. Region × Cohort FE (absorb regional trends)
###############################################################################

cat("\n=== Region × Cohort FE ===\n")

m_rc_p25 <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + region_cohort,
                  data = df_ba, cluster = "state_fips")
m_rc_p50 <- feols(ln_y1_p50 ~ ln_mw + unemp_avg + ln_income | inst_id + region_cohort,
                  data = df_ba, cluster = "state_fips")
m_rc_p75 <- feols(ln_y1_p75 ~ ln_mw + unemp_avg + ln_income | inst_id + region_cohort,
                  data = df_ba, cluster = "state_fips")

cat(sprintf("  P25: β = %.4f (SE = %.4f)\n", coef(m_rc_p25)["ln_mw"], se(m_rc_p25)["ln_mw"]))
cat(sprintf("  P50: β = %.4f (SE = %.4f)\n", coef(m_rc_p50)["ln_mw"], se(m_rc_p50)["ln_mw"]))
cat(sprintf("  P75: β = %.4f (SE = %.4f)\n", coef(m_rc_p75)["ln_mw"], se(m_rc_p75)["ln_mw"]))

###############################################################################
# 4. Binary treatment: Above-median MW increase
###############################################################################

cat("\n=== Binary Treatment: High MW States ===\n")

# Compute total MW change per state across sample period
mw_change_total <- df_ba %>%
  group_by(state_fips) %>%
  summarise(
    mw_first = first(mw_avg[cohort == min(cohort)]),
    mw_last = last(mw_avg[cohort == max(cohort)]),
    mw_total_change = mw_last - mw_first,
    .groups = "drop"
  )

median_change <- median(mw_change_total$mw_total_change, na.rm = TRUE)
cat(sprintf("  Median MW change: $%.2f\n", median_change))

high_mw_states <- mw_change_total %>%
  filter(mw_total_change > median_change) %>%
  pull(state_fips)

cat(sprintf("  High MW states: %d\n", length(high_mw_states)))

df_ba <- df_ba %>%
  mutate(high_mw = as.integer(state_fips %in% high_mw_states))

# Simple DiD with high_mw × post (cohort >= 2010)
df_ba <- df_ba %>%
  mutate(
    post_2010 = as.integer(cohort >= 2010),
    high_mw_post = high_mw * post_2010
  )

m_binary <- feols(ln_y1_p25 ~ high_mw_post + unemp_avg + ln_income | inst_id + cohort,
                  data = df_ba, cluster = "state_fips")

cat(sprintf("  High MW × Post: β = %.4f (SE = %.4f, p = %.4f)\n",
            coef(m_binary)["high_mw_post"], se(m_binary)["high_mw_post"],
            fixest::pvalue(m_binary)["high_mw_post"]))

###############################################################################
# 5. Y5 and Y10 horizons (persistence test)
###############################################################################

cat("\n=== Persistence: Y5 and Y10 ===\n")

for (horizon in c("y5", "y10")) {
  for (pctile in c("p25", "p50")) {
    yvar <- paste0("ln_", horizon, "_", pctile)
    df_h <- df_ba %>% filter(!is.na(!!sym(yvar)))

    if (nrow(df_h) < 50) {
      cat(sprintf("  %s_%s: Insufficient data\n", horizon, pctile))
      next
    }

    m <- tryCatch(
      feols(as.formula(paste(yvar, "~ ln_mw + unemp_avg + ln_income | inst_id + cohort")),
            data = df_h, cluster = "state_fips"),
      error = function(e) NULL
    )

    if (!is.null(m)) {
      cat(sprintf("  %s_%s: β = %.4f (SE = %.4f, p = %.4f), N = %d\n",
                  horizon, pctile, coef(m)["ln_mw"], se(m)["ln_mw"],
                  fixest::pvalue(m)["ln_mw"], nrow(df_h)))
    }
  }
}

###############################################################################
# 6. Graduate degree as placebo
###############################################################################

cat("\n=== Placebo: Graduate Degrees ===\n")

df_grad <- df %>%
  filter(degree_group == "Graduate", !is.na(ln_y1_p25))

if (nrow(df_grad) > 50) {
  m_grad_p25 <- tryCatch(
    feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
          data = df_grad, cluster = "state_fips"),
    error = function(e) NULL
  )

  if (!is.null(m_grad_p25)) {
    cat(sprintf("  Graduate P25: β = %.4f (SE = %.4f, p = %.4f)\n",
                coef(m_grad_p25)["ln_mw"], se(m_grad_p25)["ln_mw"],
                fixest::pvalue(m_grad_p25)["ln_mw"]))
  }
} else {
  cat("  Insufficient graduate data\n")
}

###############################################################################
# 7. Save robustness results
###############################################################################

rob_results <- list(
  lead_test = m_lead,
  jackknife_betas = jackknife_betas,
  jackknife_states = states,
  region_cohort = list(p25 = m_rc_p25, p50 = m_rc_p50, p75 = m_rc_p75),
  binary = m_binary,
  median_change = median_change,
  high_mw_states = high_mw_states
)

saveRDS(rob_results, file.path(data_dir, "robustness_results.rds"))

# Generate Table 4 (Robustness)
sink(file.path(tables_dir, "table4_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks: Bachelor's Degree P25 Earnings}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & Baseline & Region$\\times$Cohort & Lead Test & Binary \\\\\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat("\\hline\n")

# Baseline
base_m <- feols(ln_y1_p25 ~ ln_mw + unemp_avg + ln_income | inst_id + cohort,
                data = df_ba, cluster = "state_fips")

cat(sprintf("$\\ln(MW)$ & %.4f%s & %.4f%s & %.4f%s & \\\\\n",
            coef(base_m)["ln_mw"],
            ifelse(fixest::pvalue(base_m)["ln_mw"] < 0.05, "**", ifelse(fixest::pvalue(base_m)["ln_mw"] < 0.1, "*", "")),
            coef(m_rc_p25)["ln_mw"],
            ifelse(fixest::pvalue(m_rc_p25)["ln_mw"] < 0.05, "**", ifelse(fixest::pvalue(m_rc_p25)["ln_mw"] < 0.1, "*", "")),
            coef(m_lead)["ln_mw"],
            ifelse(fixest::pvalue(m_lead)["ln_mw"] < 0.05, "**", ifelse(fixest::pvalue(m_lead)["ln_mw"] < 0.1, "*", ""))))

cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) & \\\\\n",
            se(base_m)["ln_mw"], se(m_rc_p25)["ln_mw"], se(m_lead)["ln_mw"]))

cat(sprintf("$\\ln(MW_{t+1})$ & & & %.4f%s & \\\\\n",
            coef(m_lead)["ln_mw_lead"],
            ifelse(fixest::pvalue(m_lead)["ln_mw_lead"] < 0.05, "**", "")))
cat(sprintf(" & & & (%.4f) & \\\\\n", se(m_lead)["ln_mw_lead"]))

cat(sprintf("High MW $\\times$ Post & & & & %.4f%s \\\\\n",
            coef(m_binary)["high_mw_post"],
            ifelse(fixest::pvalue(m_binary)["high_mw_post"] < 0.05, "**", "")))
cat(sprintf(" & & & & (%.4f) \\\\\n", se(m_binary)["high_mw_post"]))

cat("\\hline\n")
cat("State controls & Yes & Yes & Yes & Yes \\\\\n")
cat("Institution FE & Yes & Yes & Yes & Yes \\\\\n")
cat("Cohort FE & Yes & Region$\\times$Cohort & Yes & Yes \\\\\n")
cat(sprintf("Observations & %s & %s & %s & %s \\\\\n",
            formatC(base_m$nobs, big.mark = ","),
            formatC(m_rc_p25$nobs, big.mark = ","),
            formatC(m_lead$nobs, big.mark = ","),
            formatC(m_binary$nobs, big.mark = ",")))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Dependent variable is log 25th percentile first-year earnings for bachelor's degree graduates. ")
cat("Column (1) is the baseline specification. Column (2) replaces cohort FE with region $\\times$ cohort FE. ")
cat("Column (3) adds lead (next-cohort) MW as a falsification test. Column (4) uses a binary treatment: ")
cat("states with above-median total MW increases $\\times$ post-2010 indicator. ")
cat("Standard errors clustered at the state level.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\nRobustness analysis complete.\n")
