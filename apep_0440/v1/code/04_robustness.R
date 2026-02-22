###############################################################################
# 04_robustness.R — Robustness checks for dual RDD
# Paper: Social Insurance Thresholds and Late-Career Underemployment
# APEP-0440
###############################################################################

source("00_packages.R")

cat("=== Loading Analysis Data ===\n")
dt <- as.data.table(read_parquet("../data/analysis_employed.parquet"))

# Helper: fast parametric RDD via feols
run_rdd <- function(data, outcome, age_var, above_var, bw = 5) {
  sub <- data[abs(get(age_var)) <= bw & !is.na(get(outcome))]
  fml <- as.formula(paste0(outcome, " ~ ", above_var, " * ", age_var))
  mod <- feols(fml, data = sub, weights = ~PWGTP, cluster = ~AGEP)
  list(
    estimate = unname(coef(mod)[above_var]),
    se = unname(fixest::se(mod)[above_var]),
    pvalue = unname(fixest::pvalue(mod)[above_var]),
    n = nrow(sub)
  )
}

# ============================================================================
# 1. BANDWIDTH SENSITIVITY
# ============================================================================
cat("\n=== 1. Bandwidth Sensitivity ===\n")

bw_results <- list()
bandwidths <- c(3, 4, 5, 7, 10)

for (cutoff in c(62, 65)) {
  age_var <- paste0("age_c", cutoff)
  above_var <- paste0("above_", cutoff)
  cat(sprintf("\nCutoff: Age %d\n", cutoff))

  for (bw in bandwidths) {
    res <- run_rdd(dt, "overqualified", age_var, above_var, bw)
    cat(sprintf("  BW=%d: est=%.4f (SE=%.4f, p=%.3f, n=%d)\n",
                bw, res$estimate, res$se, res$pvalue, res$n))
    bw_results[[paste(cutoff, bw)]] <- data.table(
      cutoff = cutoff, bandwidth = bw,
      estimate = res$estimate, se = res$se, pvalue = res$pvalue, n = res$n
    )
  }
}

bw_dt <- rbindlist(bw_results)
fwrite(bw_dt, "../data/robustness_bandwidth.csv")

# ============================================================================
# 2. POLYNOMIAL ORDER (Linear vs Quadratic)
# ============================================================================
cat("\n=== 2. Polynomial Order Sensitivity ===\n")

poly_results <- list()

for (cutoff in c(62, 65)) {
  age_var <- paste0("age_c", cutoff)
  above_var <- paste0("above_", cutoff)
  sub <- dt[abs(get(age_var)) <= 5]  # BW=5 to match baseline

  # Order 1 (linear)
  mod1 <- feols(
    as.formula(paste0("overqualified ~ ", above_var, " * ", age_var)),
    data = sub, weights = ~PWGTP, cluster = ~AGEP
  )

  # Order 2 (quadratic)
  sub[, age_sq := get(age_var)^2]
  mod2 <- feols(
    as.formula(paste0("overqualified ~ ", above_var, " * ", age_var, " + ", above_var, ":age_sq")),
    data = sub, weights = ~PWGTP, cluster = ~AGEP
  )

  for (p in 1:2) {
    mod <- if (p == 1) mod1 else mod2
    cat(sprintf("  Age %d, p=%d: est=%.4f (SE=%.4f, p=%.3f)\n",
                cutoff, p, coef(mod)[above_var], fixest::se(mod)[above_var], fixest::pvalue(mod)[above_var]))
    poly_results[[paste(cutoff, p)]] <- data.table(
      cutoff = cutoff, poly_order = p,
      estimate = unname(coef(mod)[above_var]),
      se = unname(fixest::se(mod)[above_var]),
      pvalue = unname(fixest::pvalue(mod)[above_var])
    )
  }
}

poly_dt <- rbindlist(poly_results)
fwrite(poly_dt, "../data/robustness_polynomial.csv")

# ============================================================================
# 3. KERNEL SENSITIVITY (Triangular vs Uniform weighting)
# ============================================================================
cat("\n=== 3. Kernel Sensitivity ===\n")

kernel_results <- list()

for (cutoff in c(62, 65)) {
  age_var <- paste0("age_c", cutoff)
  above_var <- paste0("above_", cutoff)
  sub <- dt[abs(get(age_var)) <= 5]  # BW=5 to match baseline
  bw <- 5

  # Uniform: equal weights within bandwidth (just use PWGTP)
  mod_unif <- feols(
    as.formula(paste0("overqualified ~ ", above_var, " * ", age_var)),
    data = sub, weights = ~PWGTP, cluster = ~AGEP
  )

  # Triangular: weight by (1 - |x|/bw) * PWGTP
  sub[, tri_wt := (1 - abs(get(age_var)) / bw) * PWGTP]
  mod_tri <- feols(
    as.formula(paste0("overqualified ~ ", above_var, " * ", age_var)),
    data = sub, weights = ~tri_wt, cluster = ~AGEP
  )

  for (kern in c("triangular", "uniform")) {
    mod <- if (kern == "triangular") mod_tri else mod_unif
    cat(sprintf("  Age %d, %s: est=%.4f (SE=%.4f)\n",
                cutoff, kern, coef(mod)[above_var], fixest::se(mod)[above_var]))
    kernel_results[[paste(cutoff, kern)]] <- data.table(
      cutoff = cutoff, kernel = kern,
      estimate = unname(coef(mod)[above_var]),
      se = unname(fixest::se(mod)[above_var]),
      pvalue = unname(fixest::pvalue(mod)[above_var])
    )
  }
}

kernel_dt <- rbindlist(kernel_results)
fwrite(kernel_dt, "../data/robustness_kernel.csv")

# ============================================================================
# 4. PLACEBO CUTOFFS
# ============================================================================
cat("\n=== 4. Placebo Cutoffs ===\n")

placebo_ages <- c(55, 57, 58, 60, 63, 67, 69, 70, 73)
placebo_results <- list()

for (fake_c in placebo_ages) {
  dt[, age_fake := AGEP - fake_c]
  dt[, above_fake := as.integer(AGEP >= fake_c)]
  sub <- dt[abs(age_fake) <= 5]

  mod <- feols(overqualified ~ above_fake * age_fake,
               data = sub, weights = ~PWGTP, cluster = ~AGEP)

  est <- unname(coef(mod)["above_fake"])
  se_val <- unname(fixest::se(mod)["above_fake"])
  pv <- unname(fixest::pvalue(mod)["above_fake"])

  sig <- ifelse(pv < 0.05, " ***", "")
  cat(sprintf("  Placebo at %d: est=%.4f (SE=%.4f, p=%.3f)%s\n",
              fake_c, est, se_val, pv, sig))

  placebo_results[[as.character(fake_c)]] <- data.table(
    cutoff = fake_c, estimate = est, se = se_val, pvalue = pv,
    is_real = fake_c %in% c(62, 65)
  )
}

# Add real cutoffs for comparison
for (real_c in c(62, 65)) {
  res <- run_rdd(dt, "overqualified", paste0("age_c", real_c),
                 paste0("above_", real_c), bw = 5)
  placebo_results[[as.character(real_c)]] <- data.table(
    cutoff = real_c, estimate = res$estimate, se = res$se,
    pvalue = res$pvalue, is_real = TRUE
  )
}

placebo_dt <- rbindlist(placebo_results)
fwrite(placebo_dt, "../data/robustness_placebo.csv")

# ============================================================================
# 5. DONUT RDD (Exclude threshold age)
# ============================================================================
cat("\n=== 5. Donut RDD ===\n")

donut_results <- list()

for (cutoff in c(62, 65)) {
  age_var <- paste0("age_c", cutoff)
  above_var <- paste0("above_", cutoff)
  sub <- dt[abs(get(age_var)) <= 7 & get(age_var) != 0]

  mod <- feols(
    as.formula(paste0("overqualified ~ ", above_var, " * ", age_var)),
    data = sub, weights = ~PWGTP, cluster = ~AGEP
  )

  cat(sprintf("  Donut at %d: est=%.4f (SE=%.4f, p=%.3f)\n",
              cutoff, coef(mod)[above_var], fixest::se(mod)[above_var], fixest::pvalue(mod)[above_var]))

  donut_results[[as.character(cutoff)]] <- data.table(
    cutoff = cutoff,
    estimate = unname(coef(mod)[above_var]),
    se = unname(fixest::se(mod)[above_var]),
    pvalue = unname(fixest::pvalue(mod)[above_var])
  )
}

donut_dt <- rbindlist(donut_results)
fwrite(donut_dt, "../data/robustness_donut.csv")

# ============================================================================
# 6. COVARIATE BALANCE AT CUTOFFS
# ============================================================================
cat("\n=== 6. Covariate Balance ===\n")

covariates <- c("female", "has_bachelors", "hispanic", "self_employed")
cov_labels <- c("Female", "Bachelor's+", "Hispanic", "Self-Employed")
balance_results <- list()

for (cutoff in c(62, 65)) {
  age_var <- paste0("age_c", cutoff)
  above_var <- paste0("above_", cutoff)

  for (j in seq_along(covariates)) {
    res <- run_rdd(dt, covariates[j], age_var, above_var, bw = 5)

    sig <- ifelse(res$pvalue < 0.05, " ***", "")
    cat(sprintf("  Age %d, %s: %.4f (p=%.3f)%s\n",
                cutoff, cov_labels[j], res$estimate, res$pvalue, sig))

    balance_results[[paste(cutoff, covariates[j])]] <- data.table(
      cutoff = cutoff, covariate = cov_labels[j],
      estimate = res$estimate, se = res$se, pvalue = res$pvalue
    )
  }
}

balance_dt <- rbindlist(balance_results)
fwrite(balance_dt, "../data/robustness_balance.csv")

# ============================================================================
# 7. YEAR-BY-YEAR STABILITY
# ============================================================================
cat("\n=== 7. Year-by-Year Estimates ===\n")

yearly_results <- list()

for (yr in sort(unique(dt$year))) {
  sub <- dt[year == yr]
  res <- run_rdd(sub, "overqualified", "age_c65", "above_65", bw = 5)

  cat(sprintf("  %d: est=%.4f (SE=%.4f, p=%.3f)\n",
              yr, res$estimate, res$se, res$pvalue))

  yearly_results[[as.character(yr)]] <- data.table(
    year = yr, estimate = res$estimate, se = res$se, pvalue = res$pvalue
  )
}

yearly_dt <- rbindlist(yearly_results)
fwrite(yearly_dt, "../data/robustness_yearly.csv")

# ============================================================================
# 8. ALTERNATIVE OUTCOMES
# ============================================================================
cat("\n=== 8. Alternative Outcome Measures ===\n")

# Part-time at age 65 (bandwidth sensitivity)
cat("\nPart-time at age 65 (varying BW):\n")
for (bw in c(3, 5, 7)) {
  res <- run_rdd(dt, "part_time", "age_c65", "above_65", bw)
  cat(sprintf("  BW=%d: est=%.4f (SE=%.4f, p=%.3f)\n",
              bw, res$estimate, res$se, res$pvalue))
}

# Involuntary PT at age 65
cat("\nInvoluntary PT at age 65 (varying BW):\n")
for (bw in c(3, 5, 7)) {
  res <- run_rdd(dt, "involuntary_pt", "age_c65", "above_65", bw)
  cat(sprintf("  BW=%d: est=%.4f (SE=%.4f, p=%.3f)\n",
              bw, res$estimate, res$se, res$pvalue))
}

# Severe overqualification (graduate degree in JZ ≤ 3)
cat("\nSevere overqualification (graduate degree in JZ ≤ 3):\n")
for (cutoff in c(62, 65)) {
  sub <- dt[has_graduate == 1L]
  age_var <- paste0("age_c", cutoff)
  above_var <- paste0("above_", cutoff)
  res <- run_rdd(sub, "severe_overqual", age_var, above_var, bw = 5)
  cat(sprintf("  Age %d: est=%.4f (SE=%.4f, p=%.3f)\n",
              cutoff, res$estimate, res$se, res$pvalue))
}

cat("\n=== All Robustness Checks Complete ===\n")
