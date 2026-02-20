## 03_main_analysis.R — Main RDD analysis for PMGSY dynamic effects
## APEP-0429

source("00_packages.R")
load("../data/analysis_data.RData")

cat("=== MAIN RDD ANALYSIS ===\n\n")

## ── 1. McCrary Manipulation Test ────────────────────────────────────
cat("--- McCrary Density Test ---\n")
mccrary <- rddensity(X = sample$pop_centered, c = 0)
cat("T-statistic:", round(mccrary$test$t_jk, 3), "\n")
cat("P-value:", round(mccrary$test$p_jk, 4), "\n")
if (mccrary$test$p_jk > 0.05) {
  cat("PASS: No evidence of manipulation at threshold\n\n")
} else {
  cat("NOTE: Significant density discontinuity detected\n\n")
}

## ── 2. Cross-Sectional RDD at Key Years ─────────────────────────────
cat("--- Cross-Sectional RDD Results ---\n\n")

## Function to run RDD for a given outcome
run_rdd <- function(y, x, label) {
  valid <- !is.na(y) & !is.na(x)
  if (sum(valid) < 100) return(NULL)
  tryCatch({
    fit <- rdrobust(y[valid], x[valid], c = 0)
    data.table(
      outcome = label,
      estimate = fit$coef[1],  # Conventional
      se = fit$se[3],          # Robust
      ci_lo = fit$ci[3, 1],    # Robust CI
      ci_hi = fit$ci[3, 2],
      p_value = fit$pv[3],     # Robust p-value
      bw_left = fit$bws[1, 1],
      bw_right = fit$bws[1, 2],
      n_left = fit$N_h[1],
      n_right = fit$N_h[2],
      n_eff = fit$N_h[1] + fit$N_h[2]
    )
  }, error = function(e) {
    cat("  Error for", label, ":", e$message, "\n")
    return(NULL)
  })
}

## Run RDD for nightlights at key years
## Use asinh transform for nightlights
key_results <- list()

## DMSP years: pre-treatment (1994-2000), post-treatment (2001-2013)
dmsp_years <- c(1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010, 2012, 2013)
for (yr in dmsp_years) {
  col <- paste0("dmsp_", yr)
  if (col %in% names(sample)) {
    y <- asinh(sample[[col]])
    res <- run_rdd(y, sample$pop_centered, paste0("DMSP ", yr))
    if (!is.null(res)) key_results[[length(key_results) + 1]] <- res
  }
}

## VIIRS years: 2012-2023
viirs_years <- c(2012, 2014, 2016, 2018, 2020, 2022, 2023)
for (yr in viirs_years) {
  col <- paste0("viirs_", yr)
  if (col %in% names(sample)) {
    y <- asinh(sample[[col]])
    res <- run_rdd(y, sample$pop_centered, paste0("VIIRS ", yr))
    if (!is.null(res)) key_results[[length(key_results) + 1]] <- res
  }
}

rdd_results <- rbindlist(key_results)
cat("\nRDD Results (asinh nightlights):\n")
print(rdd_results[, .(outcome, estimate = round(estimate, 4),
                       se = round(se, 4), p_value = round(p_value, 4),
                       n_eff)])

## ── 3. Dynamic Treatment Effects (Year-by-Year RDD) ─────────────────
cat("\n--- Dynamic Treatment Effects ---\n")

## All DMSP years
all_dmsp_years <- 1994:2013
dynamic_dmsp <- list()
for (yr in all_dmsp_years) {
  col <- paste0("dmsp_", yr)
  if (col %in% names(sample)) {
    y <- asinh(sample[[col]])
    res <- run_rdd(y, sample$pop_centered, paste0("DMSP_", yr))
    if (!is.null(res)) {
      res$year <- yr
      res$sensor <- "DMSP"
      dynamic_dmsp[[length(dynamic_dmsp) + 1]] <- res
    }
  }
}
dynamic_dmsp <- rbindlist(dynamic_dmsp)

## All VIIRS years
all_viirs_years <- 2012:2023
dynamic_viirs <- list()
for (yr in all_viirs_years) {
  col <- paste0("viirs_", yr)
  if (col %in% names(sample)) {
    y <- asinh(sample[[col]])
    res <- run_rdd(y, sample$pop_centered, paste0("VIIRS_", yr))
    if (!is.null(res)) {
      res$year <- yr
      res$sensor <- "VIIRS"
      dynamic_viirs[[length(dynamic_viirs) + 1]] <- res
    }
  }
}
dynamic_viirs <- rbindlist(dynamic_viirs)

dynamic_all <- rbind(dynamic_dmsp, dynamic_viirs)

cat("\nDynamic RDD estimates:\n")
print(dynamic_all[, .(year, sensor, estimate = round(estimate, 4),
                       se = round(se, 4), p_value = round(p_value, 4))])

## ── 4. Census Outcome RDD (2001 → 2011 Changes) ────────────────────
cat("\n--- Census Outcome RDD ---\n")

## Literacy rate change
sample[, lit_change := lit_rate_11 - lit_rate_01]
## Agricultural share change
sample[, ag_change := ag_share_11 - ag_share_01]
## Population growth
sample[, pop_growth := log(pop11 / pmax(pop01, 1))]
## Worker share change
sample[, worker_change := worker_share_11 - worker_share_01]

census_results <- list()
for (var in c("lit_change", "ag_change", "pop_growth", "worker_change")) {
  y <- sample[[var]]
  res <- run_rdd(y, sample$pop_centered, var)
  if (!is.null(res)) census_results[[length(census_results) + 1]] <- res
}
census_results <- rbindlist(census_results)
cat("\nCensus Change RDD:\n")
print(census_results[, .(outcome, estimate = round(estimate, 4),
                          se = round(se, 4), p_value = round(p_value, 4))])

## ── 5. Covariate Balance at Threshold ──────────────────────────────
cat("\n--- Covariate Balance (1991 Census) ---\n")
balance_vars <- c("pop91", "lit_rate_91")
balance_results <- list()
for (var in balance_vars) {
  y <- sample[[var]]
  res <- run_rdd(y, sample$pop_centered, paste0("balance_", var))
  if (!is.null(res)) balance_results[[length(balance_results) + 1]] <- res
}

## 2001 covariates that should be smooth (structural, not outcome)
for (var in c("female_share_01", "sc_share_01", "st_share_01")) {
  y <- sample[[var]]
  res <- run_rdd(y, sample$pop_centered, paste0("balance_", var))
  if (!is.null(res)) balance_results[[length(balance_results) + 1]] <- res
}

balance_results <- rbindlist(balance_results)
cat("\nBalance test results:\n")
print(balance_results[, .(outcome, estimate = round(estimate, 4),
                           se = round(se, 4), p_value = round(p_value, 4))])

## ── Save all results ────────────────────────────────────────────────
save(mccrary, rdd_results, dynamic_all, census_results, balance_results,
     file = "../data/main_results.RData")
cat("\n=== All main results saved ===\n")
