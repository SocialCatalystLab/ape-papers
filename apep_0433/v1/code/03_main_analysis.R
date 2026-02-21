## ============================================================
## 03_main_analysis.R — RDD estimation
## Sharp RDD at the 1,000-inhabitant threshold
## with mass points handling
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
dir.create("../tables", showWarnings = FALSE)

cat("=== MAIN RDD ANALYSIS ===\n")
cat("N =", nrow(df), "communes\n\n")

## ----------------------------------------------------------
## 1. First Stage: Female councillor share
## ----------------------------------------------------------

cat("--- First Stage: Female Councillor Share ---\n\n")

# A. With mass points adjustment
cat("A. rdrobust with masspoints='adjust':\n")
rd_first <- rdrobust(y = df$female_share, x = df$pop_centered, c = 0,
                     kernel = "triangular", p = 1, bwselect = "cerrd",
                     masspoints = "adjust")
cat("  Bandwidth:", round(rd_first$bws[1, 1]), "\n")
cat("  N left:", rd_first$N_h[1], " N right:", rd_first$N_h[2], "\n")
cat("  Estimate:", round(rd_first$coef[1], 4), "\n")
cat("  Robust p:", round(rd_first$pv[3], 4), "\n")

# B. Manual bandwidths for first stage
cat("\nB. Manual bandwidth analysis:\n")
for (bw in c(100, 200, 300, 500)) {
  sub <- df %>% filter(abs(pop_centered) <= bw)
  mod <- lm(female_share ~ above_threshold + pop_centered +
              I(above_threshold * pop_centered), data = sub)
  se <- sqrt(vcovHC(mod, type = "HC1")[2, 2])
  cat("  BW=", bw, ": coef=", round(coef(mod)[2], 4),
      " SE=", round(se, 4),
      " N=", nrow(sub), "\n")
}

# C. Means comparison near threshold
cat("\nC. Simple means comparison (+/- 100, 200, 500):\n")
for (w in c(100, 200, 500)) {
  near <- df %>% filter(abs(pop_centered) <= w)
  m_above <- mean(near$female_share[near$above_threshold == 1])
  m_below <- mean(near$female_share[near$above_threshold == 0])
  cat("  Window=", w, ": above=", round(m_above, 4),
      " below=", round(m_below, 4),
      " diff=", round(m_above - m_below, 4), "\n")
}

saveRDS(rd_first, "../data/rd_first_stage.rds")

## ----------------------------------------------------------
## 2. Main Outcomes: RDD with manual bandwidth choices
## ----------------------------------------------------------

cat("\n--- Main Outcomes ---\n")

outcomes <- list(
  list(name = "Female Employment Rate", var = "female_emp_rate"),
  list(name = "Female LFPR", var = "female_lfpr"),
  list(name = "Male Employment Rate", var = "male_emp_rate"),
  list(name = "Gender Employment Gap", var = "gender_emp_gap"),
  list(name = "Female Share of Employment", var = "female_share_employed"),
  list(name = "Total Employment Rate", var = "total_emp_rate"),
  list(name = "Unemployment Rate", var = "unemployment_rate")
)

results <- list()

for (out in outcomes) {
  y <- df[[out$var]]
  valid <- !is.na(y) & is.finite(y)

  cat("\n===", out$name, "===\n")

  # rdrobust with mass points adjustment
  rd <- tryCatch(
    rdrobust(y = y[valid], x = df$pop_centered[valid], c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) { cat("  rdrobust error:", e$message, "\n"); NULL }
  )

  if (!is.null(rd)) {
    cat("  rdrobust: BW=", round(rd$bws[1, 1]),
        " coef=", round(rd$coef[1], 4),
        " robust_SE=", round(rd$se[3], 4),
        " p=", round(rd$pv[3], 4), "\n")

    results[[out$var]] <- list(
      name = out$name,
      coef_conv = rd$coef[1],
      se_conv = rd$se[1],
      coef_bc = rd$coef[2],
      se_robust = rd$se[3],
      pv_robust = rd$pv[3],
      bw = rd$bws[1, 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2],
      ci_lower = rd$ci[3, 1],
      ci_upper = rd$ci[3, 2]
    )
  }

  # Manual bandwidths for robustness
  for (bw in c(200, 300, 500)) {
    sub <- df[valid, ] %>% filter(abs(pop_centered) <= bw)
    if (nrow(sub) < 50) next
    mod <- lm(as.formula(paste(out$var,
      "~ above_threshold + pop_centered + I(above_threshold*pop_centered)")),
      data = sub)
    se <- sqrt(vcovHC(mod, type = "HC1")[2, 2])
    pv <- 2 * pnorm(-abs(coef(mod)[2] / se))
    cat("  BW=", bw, ": coef=", round(coef(mod)[2], 4),
        " SE=", round(se, 4),
        " p=", round(pv, 4),
        " N=", nrow(sub), "\n")
  }
}

saveRDS(results, "../data/rd_results.rds")

## ----------------------------------------------------------
## 3. Pre-treatment placebo (2011 — before threshold change)
## ----------------------------------------------------------

cat("\n--- Pre-treatment Placebo: 2011 outcomes ---\n")

pre_vars <- c("female_emp_rate_2011", "female_lfpr_2011",
              "total_emp_rate_2011")

for (v in pre_vars) {
  if (!v %in% names(df)) next
  y <- df[[v]]
  valid <- !is.na(y) & is.finite(y)

  rd_pre <- tryCatch(
    rdrobust(y = y[valid], x = df$pop_centered[valid], c = 0,
             kernel = "triangular", p = 1, bwselect = "cerrd",
             masspoints = "adjust"),
    error = function(e) NULL
  )
  if (!is.null(rd_pre)) {
    cat("  ", v, ": coef=", round(rd_pre$coef[1], 4),
        " SE=", round(rd_pre$se[3], 4),
        " p=", round(rd_pre$pv[3], 4), "\n")
  }
}

## ----------------------------------------------------------
## 4. Heterogeneity: Urban vs Rural
## ----------------------------------------------------------

cat("\n--- Heterogeneity: Urban vs Rural ---\n")

# Use grille_densite as urban/rural indicator
if ("grille_densite" %in% names(df)) {
  # grille_densite: 1 = dense, 7 = very sparse
  df$rural <- ifelse(df$grille_densite >= 4, 1, 0)

  for (type in c("Urban (dense)", "Rural (sparse)")) {
    sub <- if (type == "Urban (dense)") df[df$rural == 0, ] else df[df$rural == 1, ]
    valid <- !is.na(sub$female_emp_rate) & is.finite(sub$female_emp_rate)

    if (sum(valid) < 200) {
      cat("  ", type, ": too few obs (", sum(valid), ")\n")
      next
    }

    rd_het <- tryCatch(
      rdrobust(y = sub$female_emp_rate[valid],
               x = sub$pop_centered[valid], c = 0,
               kernel = "triangular", p = 1, bwselect = "cerrd",
               masspoints = "adjust"),
      error = function(e) NULL
    )
    if (!is.null(rd_het)) {
      cat("  ", type, ": coef=", round(rd_het$coef[1], 4),
          " SE=", round(rd_het$se[3], 4),
          " p=", round(rd_het$pv[3], 4),
          " N=", rd_het$N_h[1] + rd_het$N_h[2], "\n")
    }
  }
}

cat("\nMain analysis complete.\n")
