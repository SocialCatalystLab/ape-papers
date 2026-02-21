## ============================================================
## 04_robustness.R — RDD validity and robustness checks
## McCrary density test, covariate balance, placebo cutoffs,
## bandwidth sensitivity, donut hole, kernel sensitivity
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
dir.create("../tables", showWarnings = FALSE)

cat("=== ROBUSTNESS CHECKS ===\n\n")

## ----------------------------------------------------------
## 1. McCrary Density Test
## ----------------------------------------------------------

cat("--- 1. McCrary Density Test ---\n")
dens <- rddensity(X = df$pop_centered, c = 0)
cat("  T-statistic:", round(dens$test$t_jk, 4), "\n")
cat("  P-value:", round(dens$test$p_jk, 4), "\n")
if (dens$test$p_jk > 0.05) {
  cat("  RESULT: No evidence of manipulation (p > 0.05)\n")
} else {
  cat("  RESULT: Evidence of sorting at threshold (p < 0.05)\n")
}

saveRDS(dens, "../data/density_test.rds")

## ----------------------------------------------------------
## 2. Covariate Balance at Threshold
## ----------------------------------------------------------

cat("\n--- 2. Covariate Balance ---\n")

# Pre-determined covariates (from 2011 census — before threshold change)
balance_vars <- list(
  "Pop 15-64 (2011)" = "P11_POP1564",
  "Female emp rate (2011)" = "female_emp_rate_2011",
  "Female LFPR (2011)" = "female_lfpr_2011",
  "Total emp rate (2011)" = "total_emp_rate_2011",
  "Density (hab/km2)" = "densite",
  "Altitude (m)" = "altitude_moyenne"
)

# Add altitude if available
if (!"altitude_moyenne" %in% names(df)) {
  balance_vars[["Altitude (m)"]] <- NULL
}

balance_results <- data.frame()

for (name in names(balance_vars)) {
  var <- balance_vars[[name]]
  if (!var %in% names(df)) next

  y <- df[[var]]
  valid <- !is.na(y) & is.finite(y)
  if (sum(valid) < 500) next

  rd_bal <- tryCatch(
    rdrobust(y = y[valid], x = df$pop_centered[valid], c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )

  if (!is.null(rd_bal)) {
    cat("  ", name, ": coef=", round(rd_bal$coef[1], 4),
        " p=", round(rd_bal$pv[3], 4), "\n")

    balance_results <- rbind(balance_results, data.frame(
      variable = name,
      coef = rd_bal$coef[1],
      se = rd_bal$se[3],
      pvalue = rd_bal$pv[3],
      bw = rd_bal$bws[1, 1],
      n_obs = rd_bal$N_h[1] + rd_bal$N_h[2]
    ))
  }
}

saveRDS(balance_results, "../data/balance_results.rds")

## ----------------------------------------------------------
## 3. Placebo Cutoffs
## ----------------------------------------------------------

cat("\n--- 3. Placebo Cutoffs ---\n")

placebo_cuts <- c(500, 700, 800, 900, 1100, 1200, 1300, 1500, 2000)
placebo_results <- data.frame()

for (cut in placebo_cuts) {
  pop_c <- df$pop - cut
  valid <- !is.na(df$female_emp_rate) & is.finite(df$female_emp_rate)

  rd_p <- tryCatch(
    rdrobust(y = df$female_emp_rate[valid], x = pop_c[valid], c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )

  if (!is.null(rd_p)) {
    cat("  Cutoff=", cut, ": coef=", round(rd_p$coef[1], 4),
        " p=", round(rd_p$pv[3], 4), "\n")

    placebo_results <- rbind(placebo_results, data.frame(
      cutoff = cut,
      coef = rd_p$coef[1],
      se = rd_p$se[3],
      pvalue = rd_p$pv[3],
      bw = rd_p$bws[1, 1],
      is_real = (cut == 1000)
    ))
  }
}

# Also add the real cutoff
rd_real <- rdrobust(y = df$female_emp_rate[valid],
                    x = df$pop_centered[valid], c = 0,
                    kernel = "triangular", p = 1, bwselect = "cerrd",
                    masspoints = "adjust")
placebo_results <- rbind(placebo_results, data.frame(
  cutoff = 1000, coef = rd_real$coef[1], se = rd_real$se[3],
  pvalue = rd_real$pv[3], bw = rd_real$bws[1, 1], is_real = TRUE
))

saveRDS(placebo_results, "../data/placebo_results.rds")

## ----------------------------------------------------------
## 4. Bandwidth Sensitivity
## ----------------------------------------------------------

cat("\n--- 4. Bandwidth Sensitivity ---\n")

bw_results <- data.frame()
for (bw in seq(100, 800, by = 50)) {
  sub <- df %>% filter(abs(pop_centered) <= bw,
                        !is.na(female_emp_rate),
                        is.finite(female_emp_rate))
  if (nrow(sub) < 50) next

  mod <- lm(female_emp_rate ~ above_threshold + pop_centered +
              I(above_threshold * pop_centered), data = sub)
  se <- sqrt(vcovHC(mod, type = "HC1")[2, 2])

  bw_results <- rbind(bw_results, data.frame(
    bandwidth = bw,
    coef = coef(mod)[2],
    se = se,
    n = nrow(sub)
  ))

  if (bw %% 200 == 0) {
    cat("  BW=", bw, ": coef=", round(coef(mod)[2], 4),
        " SE=", round(se, 4), " N=", nrow(sub), "\n")
  }
}

saveRDS(bw_results, "../data/bw_sensitivity.rds")

## ----------------------------------------------------------
## 5. Donut Hole RDD
## ----------------------------------------------------------

cat("\n--- 5. Donut Hole RDD ---\n")

for (hole in c(10, 20, 50)) {
  sub <- df %>%
    filter(abs(pop_centered) >= hole,
           !is.na(female_emp_rate),
           is.finite(female_emp_rate))

  rd_donut <- tryCatch(
    rdrobust(y = sub$female_emp_rate, x = sub$pop_centered, c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )

  if (!is.null(rd_donut)) {
    cat("  Donut=", hole, ": coef=", round(rd_donut$coef[1], 4),
        " SE=", round(rd_donut$se[3], 4),
        " p=", round(rd_donut$pv[3], 4), "\n")
  }
}

## ----------------------------------------------------------
## 6. Polynomial Order Sensitivity
## ----------------------------------------------------------

cat("\n--- 6. Polynomial Order ---\n")

for (poly in 1:3) {
  valid <- !is.na(df$female_emp_rate) & is.finite(df$female_emp_rate)
  rd_poly <- tryCatch(
    rdrobust(y = df$female_emp_rate[valid],
             x = df$pop_centered[valid], c = 0,
             kernel = "triangular", p = poly, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )
  if (!is.null(rd_poly)) {
    cat("  p=", poly, ": coef=", round(rd_poly$coef[1], 4),
        " SE=", round(rd_poly$se[3], 4),
        " p-val=", round(rd_poly$pv[3], 4),
        " BW=", round(rd_poly$bws[1, 1]), "\n")
  }
}

## ----------------------------------------------------------
## 7. Kernel Sensitivity
## ----------------------------------------------------------

cat("\n--- 7. Kernel Choice ---\n")

for (kern in c("triangular", "uniform", "epanechnikov")) {
  valid <- !is.na(df$female_emp_rate) & is.finite(df$female_emp_rate)
  rd_kern <- tryCatch(
    rdrobust(y = df$female_emp_rate[valid],
             x = df$pop_centered[valid], c = 0,
             kernel = kern, p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )
  if (!is.null(rd_kern)) {
    cat("  ", kern, ": coef=", round(rd_kern$coef[1], 4),
        " SE=", round(rd_kern$se[3], 4),
        " p=", round(rd_kern$pv[3], 4), "\n")
  }
}

cat("\nRobustness checks complete.\n")
