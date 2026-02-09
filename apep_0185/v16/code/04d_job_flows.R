################################################################################
# 04d_job_flows.R
# Job Flow Mechanism Analysis
#
# Tests whether network MW exposure affects the composition of labor market
# adjustment: does exposure increase hiring? reduce separations?
#
# QWI variables:
#   HirA  = All hires (new + recall)
#   Sep   = Separations
#   FrmJbC = Firm job creation (expanding/opening firms)
#   FrmJbD = Firm job destruction (contracting/closing firms)
#
# Theoretical predictions under information transmission:
#   - Higher reservation wages → employers raise wages to attract → more hires
#   - Better matches → reduced separations (lower turnover)
#   - Net positive job flows
################################################################################

source("00_packages.R")

cat("=== Job Flow Mechanism Analysis ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")

# Check which job flow variables are available
jf_vars <- intersect(c("hira", "sep", "frmjbc", "frmjbd"), names(panel))
cat("Available job flow variables:", paste(jf_vars, collapse = ", "), "\n")

if (length(jf_vars) == 0) {
  cat("WARNING: No job flow variables found in analysis panel.\n")
  cat("Run 01_fetch_data.R and 02_clean_data.R to fetch QWI job flow data.\n")
  saveRDS(list(has_job_flows = FALSE), "../data/job_flow_results.rds")
  cat("Saved empty job_flow_results.rds\n")
  cat("=== Job Flow Analysis Complete (no data) ===\n")
  q(save = "no")
}

# Filter to complete cases
panel_jf <- panel %>%
  filter(!is.na(network_mw_pop) & !is.na(network_mw_pop_out_state) &
         !is.na(state_fips))

# Report coverage
cat("\nJob flow data coverage:\n")
for (v in jf_vars) {
  non_na <- sum(!is.na(panel_jf[[v]]) & panel_jf[[v]] > 0)
  total <- nrow(panel_jf)
  cat("  ", v, ":", format(non_na, big.mark = ","), "/", format(total, big.mark = ","),
      "(", round(100 * non_na / total, 1), "%)\n")
}

# ============================================================================
# 2. OLS and 2SLS for Each Job Flow Outcome
# ============================================================================

cat("\n2. Running regressions for job flow outcomes...\n\n")

outcomes <- list()

# Log hires
if ("log_hira" %in% names(panel_jf)) {
  outcomes[["log_hira"]] <- list(
    label = "Log Hires (HirA)",
    var = "log_hira",
    prediction = "Positive (information → higher reservation wages → more hiring)"
  )
}

# Log separations
if ("log_sep" %in% names(panel_jf)) {
  outcomes[["log_sep"]] <- list(
    label = "Log Separations (Sep)",
    var = "log_sep",
    prediction = "Negative (better matches → less turnover)"
  )
}

# Hire rate
if ("hire_rate" %in% names(panel_jf)) {
  outcomes[["hire_rate"]] <- list(
    label = "Hire Rate (HirA/Emp)",
    var = "hire_rate",
    prediction = "Positive (increased hiring relative to stock)"
  )
}

# Separation rate
if ("sep_rate" %in% names(panel_jf)) {
  outcomes[["sep_rate"]] <- list(
    label = "Separation Rate (Sep/Emp)",
    var = "sep_rate",
    prediction = "Negative (reduced turnover)"
  )
}

# Log firm job creation
if ("log_frmjbc" %in% names(panel_jf)) {
  outcomes[["log_frmjbc"]] <- list(
    label = "Log Firm Job Creation",
    var = "log_frmjbc",
    prediction = "Positive (firms expand to attract workers)"
  )
}

# Log firm job destruction
if ("log_frmjbd" %in% names(panel_jf)) {
  outcomes[["log_frmjbd"]] <- list(
    label = "Log Firm Job Destruction",
    var = "log_frmjbd",
    prediction = "Ambiguous"
  )
}

# Net job creation rate
if ("net_job_creation_rate" %in% names(panel_jf)) {
  outcomes[["net_job_creation_rate"]] <- list(
    label = "Net Job Creation Rate",
    var = "net_job_creation_rate",
    prediction = "Positive (net job growth)"
  )
}

jf_results <- list()

for (outcome_name in names(outcomes)) {
  o <- outcomes[[outcome_name]]
  cat("  ", o$label, "\n")
  cat("    Prediction:", o$prediction, "\n")

  # Filter to non-missing
  panel_o <- panel_jf %>% filter(!is.na(.data[[o$var]]))
  cat("    N:", format(nrow(panel_o), big.mark = ","), "\n")

  if (nrow(panel_o) < 5000) {
    cat("    SKIPPING: too few observations\n\n")
    next
  }

  # OLS
  ols_formula <- as.formula(paste(o$var, "~ network_mw_pop | county_fips + state_fips^yearq"))
  ols_fit <- tryCatch({
    feols(ols_formula, data = panel_o, cluster = ~state_fips)
  }, error = function(e) NULL)

  # 2SLS
  iv_formula <- as.formula(paste(o$var, "~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state"))
  iv_fit <- tryCatch({
    feols(iv_formula, data = panel_o, cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(ols_fit)) {
    cat("    OLS: β =", round(coef(ols_fit)[1], 4),
        "(SE:", round(se(ols_fit)[1], 4),
        ", p =", round(fixest::pvalue(ols_fit)[1], 4), ")\n")
  }
  if (!is.null(iv_fit)) {
    cat("    2SLS: β =", round(coef(iv_fit)[1], 4),
        "(SE:", round(se(iv_fit)[1], 4),
        ", p =", round(fixest::pvalue(iv_fit)[1], 4), ")\n")
  }
  cat("\n")

  jf_results[[outcome_name]] <- list(
    label = o$label,
    prediction = o$prediction,
    n_obs = nrow(panel_o),
    ols = ols_fit,
    iv = iv_fit
  )
}

# ============================================================================
# 3. Summary Table
# ============================================================================

cat("╔══════════════════════════════════════════════════════════════════╗\n")
cat("║  JOB FLOW RESULTS SUMMARY                                       ║\n")
cat("╚══════════════════════════════════════════════════════════════════╝\n\n")

cat(sprintf("%-25s %10s %10s %10s %10s\n",
            "Outcome", "OLS", "p", "2SLS", "p"))
cat(paste(rep("─", 70), collapse = ""), "\n")

for (r_name in names(jf_results)) {
  r <- jf_results[[r_name]]
  ols_c <- if (!is.null(r$ols)) round(coef(r$ols)[1], 4) else NA
  ols_p <- if (!is.null(r$ols)) round(fixest::pvalue(r$ols)[1], 4) else NA
  iv_c <- if (!is.null(r$iv)) round(coef(r$iv)[1], 4) else NA
  iv_p <- if (!is.null(r$iv)) round(fixest::pvalue(r$iv)[1], 4) else NA

  cat(sprintf("%-25s %10s %10s %10s %10s\n",
              r$label,
              ifelse(is.na(ols_c), "---", sprintf("%.4f", ols_c)),
              ifelse(is.na(ols_p), "---", sprintf("%.4f", ols_p)),
              ifelse(is.na(iv_c), "---", sprintf("%.4f", iv_c)),
              ifelse(is.na(iv_p), "---", sprintf("%.4f", iv_p))))
}

# ============================================================================
# 4. Save Results
# ============================================================================

cat("\n4. Saving job flow results...\n")

saveRDS(list(
  has_job_flows = TRUE,
  results = jf_results,
  coverage = sapply(jf_vars, function(v) {
    mean(!is.na(panel_jf[[v]]) & panel_jf[[v]] > 0, na.rm = TRUE)
  })
), "../data/job_flow_results.rds")

cat("  Saved job_flow_results.rds\n")

cat("\n=== Job Flow Analysis Complete ===\n")
