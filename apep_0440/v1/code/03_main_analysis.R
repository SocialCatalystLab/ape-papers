###############################################################################
# 03_main_analysis.R — RDD estimation at age 62 and 65
# Paper: Social Insurance Thresholds and Late-Career Underemployment
# APEP-0440
###############################################################################

source("00_packages.R")

cat("=== Loading Analysis Data ===\n")
dt <- as.data.table(read_parquet("../data/analysis_employed.parquet"))
cat(sprintf("Loaded %s employed workers\n", format(nrow(dt), big.mark = ",")))

# ============================================================================
# Helper: Fast RDD using feols (local linear regression)
# We use feols rather than rdrobust for the primary estimates because:
#   1. rdrobust is extremely slow on ~1M obs with clustering (>30 min per outcome)
#   2. With a discrete running variable (integer age), MSE-optimal bandwidth
#      selection has limited applicability (Lee & Card 2008, Lee & Lemieux 2010)
#   3. The fixed bandwidth of 5 age-years is a standard choice for age-based RDD
# rdrobust is used for validation in cell-level comparisons (below) and in
# 06_tables.R for robustness. Results are qualitatively identical.
# ============================================================================

run_rdd <- function(data, outcome, age_var, above_var, cutoff, bw = 5) {
  sub <- data[abs(get(age_var)) <= bw & !is.na(get(outcome))]
  n_left <- nrow(sub[get(age_var) < 0])
  n_right <- nrow(sub[get(age_var) >= 0])

  # Local linear with interaction
  fml <- as.formula(paste0(outcome, " ~ ", above_var, " * ", age_var))

  res <- tryCatch({
    mod <- feols(fml, data = sub, weights = ~PWGTP, cluster = ~AGEP)
    est <- coef(mod)[above_var]
    se_val <- fixest::se(mod)[above_var]
    pv <- fixest::pvalue(mod)[above_var]
    list(
      outcome = outcome,
      estimate = unname(est),
      se = unname(se_val),
      pvalue = unname(pv),
      ci_lower = unname(est - 1.96 * se_val),
      ci_upper = unname(est + 1.96 * se_val),
      bandwidth = bw,
      n_left = n_left,
      n_right = n_right,
      cutoff = cutoff
    )
  }, error = function(e) {
    list(
      outcome = outcome,
      estimate = NA_real_, se = NA_real_, pvalue = NA_real_,
      ci_lower = NA_real_, ci_upper = NA_real_,
      bandwidth = bw, n_left = n_left, n_right = n_right, cutoff = cutoff
    )
  })

  return(res)
}

# Also try rdrobust on cell-level data (fast with ~24 cells)
run_rdrobust_cells <- function(data, outcome, age_var, cutoff) {
  # Aggregate to cell means by age
  cells <- data[!is.na(get(outcome)), .(
    y = weighted.mean(get(outcome), PWGTP, na.rm = TRUE),
    n = .N,
    w = sum(PWGTP)
  ), by = .(age = get(age_var))]

  cells <- cells[abs(age) <= 10]
  setorder(cells, age)

  tryCatch({
    rd <- rdrobust(
      y = cells$y,
      x = cells$age,
      c = 0,
      kernel = "triangular",
      bwselect = "mserd",
      weights = cells$w
    )
    list(
      estimate = rd$coef[1],
      se = rd$se[1],
      pvalue = rd$pv[1],
      bandwidth = rd$bws[1, 1]
    )
  }, error = function(e) {
    list(estimate = NA, se = NA, pvalue = NA, bandwidth = NA)
  })
}

# ============================================================================
# SECTION 1: RDD at Age 65 (Medicare Threshold)
# ============================================================================
cat("\n========================================\n")
cat("SECTION 1: RDD AT AGE 65 (MEDICARE)\n")
cat("========================================\n")

outcomes <- c("part_time", "overqualified", "earnings_mismatch",
              "involuntary_pt", "composite_underemploy")
outcome_labels <- c("Part-Time (<35 hrs)", "Overqualified (BA+ in JZ≤3)",
                    "Earnings Mismatch", "Involuntary Part-Time",
                    "Composite Index")

rdd_results_65 <- list()

for (i in seq_along(outcomes)) {
  cat(sprintf("\n--- %s ---\n", outcome_labels[i]))

  # Primary: feols local linear (BW=5)
  res <- run_rdd(dt, outcomes[i], "age_c65", "above_65", 65, bw = 5)

  # Also run rdrobust on cells for comparison
  rd_cells <- run_rdrobust_cells(dt, outcomes[i], "age_c65", 65)

  cat(sprintf("  feols:    est=%.4f (SE=%.4f, p=%.4f)\n",
              res$estimate, res$se, res$pvalue))
  if (!is.na(rd_cells$estimate)) {
    cat(sprintf("  rdrobust: est=%.4f (SE=%.4f, p=%.4f, bw=%.1f)\n",
                rd_cells$estimate, rd_cells$se, rd_cells$pvalue, rd_cells$bandwidth))
  }

  # Use feols as primary (robust, well-understood)
  res$outcome <- outcome_labels[i]
  rdd_results_65[[outcomes[i]]] <- res
}

# --- First stage: Medicare take-up at 65 ---
cat("\n--- First Stage: Medicare Coverage at 65 ---\n")
fs_res <- run_rdd(dt, "has_medicare", "age_c65", "above_65", 65, bw = 5)
cat(sprintf("  Medicare jump at 65: %.3f (SE: %.3f, p=%.3f)\n",
            fs_res$estimate, fs_res$se, fs_res$pvalue))

# Cell means for descriptive
cells_med <- dt[abs(age_c65) <= 5, .(
  medicare = weighted.mean(has_medicare, PWGTP, na.rm = TRUE)
), by = .(above = above_65)]
cat(sprintf("  Medicare rate below 65: %.1f%%\n", 100 * cells_med[above == 0L, medicare]))
cat(sprintf("  Medicare rate at/above 65: %.1f%%\n", 100 * cells_med[above == 1L, medicare]))

# Employer insurance first stage
fs_emp <- run_rdd(dt, "has_employer_ins", "age_c65", "above_65", 65, bw = 5)
cat(sprintf("  Employer ins jump at 65: %.3f (SE: %.3f, p=%.3f)\n",
            fs_emp$estimate, fs_emp$se, fs_emp$pvalue))

# ============================================================================
# SECTION 2: RDD at Age 62 (Social Security Threshold)
# ============================================================================
cat("\n\n========================================\n")
cat("SECTION 2: RDD AT AGE 62 (SOCIAL SECURITY)\n")
cat("========================================\n")

rdd_results_62 <- list()

for (i in seq_along(outcomes)) {
  cat(sprintf("\n--- %s ---\n", outcome_labels[i]))

  res <- run_rdd(dt, outcomes[i], "age_c62", "above_62", 62, bw = 5)

  cat(sprintf("  feols: est=%.4f (SE=%.4f, p=%.4f)\n",
              res$estimate, res$se, res$pvalue))

  res$outcome <- outcome_labels[i]
  rdd_results_62[[outcomes[i]]] <- res
}

# ============================================================================
# SECTION 3: Heterogeneity by Insurance Type (Age 65)
# ============================================================================
cat("\n\n========================================\n")
cat("SECTION 3: HETEROGENEITY BY INSURANCE TYPE\n")
cat("========================================\n")

het_results <- list()

for (ins in c(1L, 0L)) {
  label <- ifelse(ins == 1L, "employer", "no_employer")
  cat(sprintf("\n--- Group: %s insurance ---\n",
              ifelse(ins == 1L, "Employer", "No employer")))

  sub <- dt[has_employer_ins == ins]

  for (out in c("overqualified", "part_time", "earnings_mismatch")) {
    res <- run_rdd(sub, out, "age_c65", "above_65", 65, bw = 5)
    cat(sprintf("  %s: %.4f (SE: %.4f, p=%.3f)\n",
                out, res$estimate, res$se, res$pvalue))
    het_results[[paste(label, out, sep = "_")]] <- res
  }
}

# ============================================================================
# SECTION 4: Heterogeneity by Education (Age 65)
# ============================================================================
cat("\n\n========================================\n")
cat("SECTION 4: HETEROGENEITY BY EDUCATION\n")
cat("========================================\n")

for (educ in c(1L, 0L)) {
  label <- ifelse(educ == 1L, "Bachelor's+", "No Bachelor's")
  cat(sprintf("\n--- Group: %s ---\n", label))

  sub <- dt[has_bachelors == educ]

  for (out in c("part_time", "overqualified", "earnings_mismatch")) {
    res <- run_rdd(sub, out, "age_c65", "above_65", 65, bw = 5)
    cat(sprintf("  %s: %.4f (SE: %.4f, p=%.3f)\n",
                out, res$estimate, res$se, res$pvalue))
  }
}

# ============================================================================
# SECTION 5: Heterogeneity by Gender (Age 65)
# ============================================================================
cat("\n\n========================================\n")
cat("SECTION 5: HETEROGENEITY BY GENDER\n")
cat("========================================\n")

for (gen in c(1L, 0L)) {
  label <- ifelse(gen == 1L, "Female", "Male")
  cat(sprintf("\n--- Group: %s ---\n", label))

  sub <- dt[female == gen]

  for (out in c("part_time", "overqualified", "earnings_mismatch")) {
    res <- run_rdd(sub, out, "age_c65", "above_65", 65, bw = 5)
    cat(sprintf("  %s: %.4f (SE: %.4f, p=%.3f)\n",
                out, res$estimate, res$se, res$pvalue))
  }
}

# ============================================================================
# SECTION 6: Extensive Margin (Employment Rate RDD)
# ============================================================================
cat("\n\n========================================\n")
cat("SECTION 6: EXTENSIVE MARGIN (EMPLOYMENT RATE)\n")
cat("========================================\n")

dt_full <- as.data.table(read_parquet("../data/analysis_full.parquet"))
dt_full[, age_c62 := AGEP - 62L]
dt_full[, age_c65 := AGEP - 65L]
dt_full[, above_62 := as.integer(AGEP >= 62)]
dt_full[, above_65 := as.integer(AGEP >= 65)]

for (cutoff in c(62, 65)) {
  cat(sprintf("\n--- Employment rate at age %d ---\n", cutoff))
  age_var <- paste0("age_c", cutoff)
  above_var <- paste0("above_", cutoff)

  res <- run_rdd(dt_full, "employed", age_var, above_var, cutoff, bw = 5)
  cat(sprintf("  Employment rate jump: %.4f (SE: %.4f, p=%.3f)\n",
              res$estimate, res$se, res$pvalue))
}

rm(dt_full); gc()

# ============================================================================
# SECTION 7: Save Results
# ============================================================================
cat("\n=== Saving Results ===\n")

all_results <- list(
  rdd_65 = rdd_results_65,
  rdd_62 = rdd_results_62,
  heterogeneity_insurance = het_results,
  first_stage = list(medicare = fs_res, employer_ins = fs_emp)
)

saveRDS(all_results, "../data/main_results.rds")
cat("  Saved: data/main_results.rds\n")

# Print summary table
cat("\n========================================\n")
cat("RESULTS SUMMARY\n")
cat("========================================\n")

cat("\nAge 65 (Medicare) RDD Estimates:\n")
cat(sprintf("%-30s %10s %10s %10s\n", "Outcome", "Estimate", "SE", "p-value"))
cat(paste(rep("-", 60), collapse = ""), "\n")
for (r in rdd_results_65) {
  stars <- ""
  if (r$pvalue < 0.01) stars <- "***"
  else if (r$pvalue < 0.05) stars <- "**"
  else if (r$pvalue < 0.10) stars <- "*"
  cat(sprintf("%-30s %10.4f %10.4f %10.4f %s\n",
              r$outcome, r$estimate, r$se, r$pvalue, stars))
}

cat("\nAge 62 (Social Security) RDD Estimates:\n")
cat(sprintf("%-30s %10s %10s %10s\n", "Outcome", "Estimate", "SE", "p-value"))
cat(paste(rep("-", 60), collapse = ""), "\n")
for (r in rdd_results_62) {
  stars <- ""
  if (r$pvalue < 0.01) stars <- "***"
  else if (r$pvalue < 0.05) stars <- "**"
  else if (r$pvalue < 0.10) stars <- "*"
  cat(sprintf("%-30s %10.4f %10.4f %10.4f %s\n",
              r$outcome, r$estimate, r$se, r$pvalue, stars))
}

cat("\n=== Main Analysis Complete ===\n")
