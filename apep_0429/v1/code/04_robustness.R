## 04_robustness.R — Robustness checks for PMGSY RDD
## APEP-0429

source("00_packages.R")
load("../data/analysis_data.RData")
load("../data/main_results.RData")

cat("=== ROBUSTNESS CHECKS ===\n\n")

## Helper function
run_rdd <- function(y, x, label) {
  valid <- !is.na(y) & !is.na(x)
  if (sum(valid) < 100) return(NULL)
  tryCatch({
    fit <- rdrobust(y[valid], x[valid], c = 0)
    data.table(outcome = label, estimate = fit$coef[1], se = fit$se[3],
               ci_lo = fit$ci[3, 1], ci_hi = fit$ci[3, 2],
               p_value = fit$pv[3], bw = fit$bws[1, 1],
               n_eff = fit$N_h[1] + fit$N_h[2])
  }, error = function(e) NULL)
}

## ── 1. Donut RDD (exclude villages within ±25 of 500) ──────────────
cat("--- Donut RDD (exclude ±25 of threshold) ---\n")
donut <- sample[abs(pop_centered) > 25]
cat("Donut sample:", nrow(donut), "villages (removed",
    nrow(sample) - nrow(donut), "heaped observations)\n")

donut_results <- list()
for (yr in c(1998, 2000, 2005, 2010, 2013)) {
  col <- paste0("dmsp_", yr)
  if (col %in% names(donut)) {
    res <- run_rdd(asinh(donut[[col]]), donut$pop_centered, paste0("donut_dmsp_", yr))
    if (!is.null(res)) donut_results[[length(donut_results) + 1]] <- res
  }
}
for (yr in c(2015, 2018, 2021, 2023)) {
  col <- paste0("viirs_", yr)
  if (col %in% names(donut)) {
    res <- run_rdd(asinh(donut[[col]]), donut$pop_centered, paste0("donut_viirs_", yr))
    if (!is.null(res)) donut_results[[length(donut_results) + 1]] <- res
  }
}
donut_results <- rbindlist(donut_results)
cat("\nDonut RDD Results:\n")
print(donut_results[, .(outcome, estimate = round(estimate, 4),
                         p_value = round(p_value, 4))])

## ── 2. Bandwidth Sensitivity ────────────────────────────────────────
cat("\n--- Bandwidth Sensitivity (VIIRS 2020) ---\n")
y_2020 <- asinh(sample$viirs_2020)
valid <- !is.na(y_2020) & !is.na(sample$pop_centered)

## Get optimal bandwidth first
fit_opt <- rdrobust(y_2020[valid], sample$pop_centered[valid], c = 0)
h_opt <- fit_opt$bws[1, 1]
cat("MSE-optimal bandwidth:", round(h_opt, 1), "\n")

bw_results <- list()
for (bw_mult in c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)) {
  h <- h_opt * bw_mult
  tryCatch({
    fit <- rdrobust(y_2020[valid], sample$pop_centered[valid], c = 0, h = h)
    bw_results[[length(bw_results) + 1]] <- data.table(
      bw_mult = bw_mult, h = round(h, 1),
      estimate = fit$coef[1], se = fit$se[3],
      p_value = fit$pv[3], n_eff = fit$N_h[1] + fit$N_h[2]
    )
  }, error = function(e) NULL)
}
bw_results <- rbindlist(bw_results)
cat("\nBandwidth sensitivity:\n")
print(bw_results[, .(bw_mult, h, estimate = round(estimate, 4),
                      p_value = round(p_value, 4), n_eff)])

## ── 3. Polynomial Order ─────────────────────────────────────────────
cat("\n--- Polynomial Order (VIIRS 2020) ---\n")
poly_results <- list()
for (p in 1:3) {
  tryCatch({
    fit <- rdrobust(y_2020[valid], sample$pop_centered[valid], c = 0, p = p)
    poly_results[[length(poly_results) + 1]] <- data.table(
      poly = p, estimate = fit$coef[1], se = fit$se[3],
      p_value = fit$pv[3], n_eff = fit$N_h[1] + fit$N_h[2])
  }, error = function(e) NULL)
}
poly_results <- rbindlist(poly_results)
cat("\nPolynomial order sensitivity:\n")
print(poly_results[, .(poly, estimate = round(estimate, 4),
                        p_value = round(p_value, 4))])

## ── 4. Placebo Thresholds ───────────────────────────────────────────
cat("\n--- Placebo Thresholds (VIIRS 2020) ---\n")
placebo_results <- list()
for (cutoff in c(200, 300, 400, 600, 700, 800)) {
  x_shifted <- sample$pop01 - cutoff
  tryCatch({
    fit <- rdrobust(y_2020[valid], x_shifted[valid], c = 0)
    placebo_results[[length(placebo_results) + 1]] <- data.table(
      threshold = cutoff, estimate = fit$coef[1], se = fit$se[3],
      p_value = fit$pv[3])
  }, error = function(e) NULL)
}
placebo_results <- rbindlist(placebo_results)
cat("\nPlacebo threshold results:\n")
print(placebo_results[, .(threshold, estimate = round(estimate, 4),
                           p_value = round(p_value, 4))])

## ── 5. Log Transform (alternative to asinh) ─────────────────────────
cat("\n--- Log Transform (VIIRS 2020, drop zeros) ---\n")
y_log <- log(sample$viirs_2020 + 1)
valid_log <- !is.na(y_log) & !is.na(sample$pop_centered) & is.finite(y_log)
fit_log <- rdrobust(y_log[valid_log], sample$pop_centered[valid_log], c = 0)
cat("Log(VIIRS+1) 2020: estimate =", round(fit_log$coef[1], 4),
    ", p =", round(fit_log$pv[3], 4), "\n")

## ── 6. Heterogeneity by baseline nightlights ────────────────────────
cat("\n--- Heterogeneity: High vs Low Baseline Nightlights ---\n")
sample[, high_baseline := dmsp_2000 > median(dmsp_2000, na.rm = TRUE)]

for (grp in c(TRUE, FALSE)) {
  sub <- sample[high_baseline == grp]
  y_sub <- asinh(sub$viirs_2020)
  valid_sub <- !is.na(y_sub) & !is.na(sub$pop_centered)
  if (sum(valid_sub) > 500) {
    fit_sub <- rdrobust(y_sub[valid_sub], sub$pop_centered[valid_sub], c = 0)
    cat("  High baseline =", grp, ": estimate =", round(fit_sub$coef[1], 4),
        ", p =", round(fit_sub$pv[3], 4), "\n")
  }
}

## ── 7. State fixed effects (parametric check) ──────────────────────
cat("\n--- Parametric RDD with State FE ---\n")
sample_narrow <- sample[abs(pop_centered) <= 200]
sample_narrow[, state := pc11_state_id]
fit_fe <- feols(asinh(viirs_2020) ~ eligible + pop_centered +
                  eligible:pop_centered | state,
                data = sample_narrow, vcov = ~pc11_district_id)
cat("Parametric RDD (±200, state FE):\n")
cat("  eligible:", round(coef(fit_fe)["eligible"], 4),
    "  SE:", round(se(fit_fe)["eligible"], 4), "\n")

## ── Save robustness results ─────────────────────────────────────────
save(donut_results, bw_results, poly_results, placebo_results,
     file = "../data/robustness_results.RData")
cat("\n=== Robustness results saved ===\n")
