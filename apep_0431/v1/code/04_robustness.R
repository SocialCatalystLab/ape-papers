## ────────────────────────────────────────────────────────────────────────────
## 04_robustness.R — Robustness checks for PMGSY gender RDD
## ────────────────────────────────────────────────────────────────────────────

source("00_packages.R")
load("../data/analysis_data.RData")
load("../data/main_results.RData")

df <- panel[special_state == FALSE & !is.na(pop2001) & pop2001 > 0]

# ════════════════════════════════════════════════════════════════════════════
# 1. BANDWIDTH SENSITIVITY
# ════════════════════════════════════════════════════════════════════════════
cat("=== Bandwidth Sensitivity ===\n")

# Primary outcome: change in female non-ag share
y_main <- df$d_nonag_share_f
x_main <- df$pop2001
valid <- !is.na(y_main) & !is.na(x_main)

# Get optimal bandwidth first
rd_opt <- rdrobust(y = y_main[valid], x = x_main[valid], c = 500)
h_opt <- rd_opt$bws[1, 1]

bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
bw_results <- data.table(
  multiplier = bw_multipliers,
  bandwidth = h_opt * bw_multipliers,
  estimate = NA_real_,
  se_robust = NA_real_,
  p_value = NA_real_,
  n_eff = NA_integer_
)

for (j in seq_along(bw_multipliers)) {
  h <- h_opt * bw_multipliers[j]
  tryCatch({
    rd <- rdrobust(y = y_main[valid], x = x_main[valid], c = 500, h = h)
    bw_results[j, `:=`(
      estimate = rd$coef[1],
      se_robust = rd$se[3],
      p_value = rd$pv[3],
      n_eff = rd$N_h[1] + rd$N_h[2]
    )]
    cat(sprintf("  h = %.0f (%.1fx opt): coef = %.4f, p = %.4f\n",
                h, bw_multipliers[j], rd$coef[1], rd$pv[3]))
  }, error = function(e) {
    cat(sprintf("  h = %.0f: FAILED\n", h))
  })
}

# ════════════════════════════════════════════════════════════════════════════
# 2. POLYNOMIAL ORDER
# ════════════════════════════════════════════════════════════════════════════
cat("\n=== Polynomial Order Sensitivity ===\n")

poly_results <- data.table(
  order = 1:3,
  estimate = NA_real_,
  se_robust = NA_real_,
  p_value = NA_real_,
  n_eff = NA_integer_
)

for (p in 1:3) {
  tryCatch({
    rd <- rdrobust(y = y_main[valid], x = x_main[valid], c = 500, p = p)
    poly_results[p, `:=`(
      estimate = rd$coef[1],
      se_robust = rd$se[3],
      p_value = rd$pv[3],
      n_eff = rd$N_h[1] + rd$N_h[2]
    )]
    cat(sprintf("  Order %d: coef = %.4f, p = %.4f\n", p, rd$coef[1], rd$pv[3]))
  }, error = function(e) {
    cat(sprintf("  Order %d: FAILED\n", p))
  })
}

# ════════════════════════════════════════════════════════════════════════════
# 3. DONUT HOLE (Exclude villages with pop near 500)
# ════════════════════════════════════════════════════════════════════════════
cat("\n=== Donut Hole (Exclude pop = 495-505) ===\n")

donut_sizes <- c(5, 10, 20)
donut_results <- data.table(
  donut = donut_sizes,
  estimate = NA_real_,
  se_robust = NA_real_,
  p_value = NA_real_,
  n_dropped = NA_integer_,
  n_eff = NA_integer_
)

for (d in seq_along(donut_sizes)) {
  hole <- donut_sizes[d]
  donut_valid <- valid & abs(x_main - 500) >= hole
  n_dropped <- sum(valid) - sum(donut_valid)
  tryCatch({
    rd <- rdrobust(y = y_main[donut_valid], x = x_main[donut_valid], c = 500)
    donut_results[d, `:=`(
      estimate = rd$coef[1],
      se_robust = rd$se[3],
      p_value = rd$pv[3],
      n_dropped = n_dropped,
      n_eff = rd$N_h[1] + rd$N_h[2]
    )]
    cat(sprintf("  Donut ±%d: coef = %.4f, p = %.4f (dropped %d)\n",
                hole, rd$coef[1], rd$pv[3], n_dropped))
  }, error = function(e) {
    cat(sprintf("  Donut ±%d: FAILED\n", hole))
  })
}

# ════════════════════════════════════════════════════════════════════════════
# 4. PLACEBO THRESHOLDS
# ════════════════════════════════════════════════════════════════════════════
cat("\n=== Placebo Thresholds ===\n")

placebo_cutoffs <- c(300, 400, 600, 700, 800)
placebo_results <- data.table(
  cutoff = placebo_cutoffs,
  estimate = NA_real_,
  se_robust = NA_real_,
  p_value = NA_real_
)

for (k in seq_along(placebo_cutoffs)) {
  c_val <- placebo_cutoffs[k]
  tryCatch({
    rd <- rdrobust(y = y_main[valid], x = x_main[valid], c = c_val)
    placebo_results[k, `:=`(
      estimate = rd$coef[1],
      se_robust = rd$se[3],
      p_value = rd$pv[3]
    )]
    cat(sprintf("  Cutoff %d: coef = %.4f, p = %.4f %s\n",
                c_val, rd$coef[1], rd$pv[3],
                ifelse(rd$pv[3] < 0.05, "*** (potential concern)", "")))
  }, error = function(e) {
    cat(sprintf("  Cutoff %d: FAILED\n", c_val))
  })
}

# ════════════════════════════════════════════════════════════════════════════
# 5. HETEROGENEITY BY REGION
# ════════════════════════════════════════════════════════════════════════════
cat("\n=== Heterogeneity by Region ===\n")

# Define regions based on state codes
# Hindi belt / North: UP(09), Bihar(10), MP(23), Rajasthan(08), Jharkhand(20),
#                     Chhattisgarh(22), Haryana(06)
# South: AP(28), Karnataka(29), Kerala(32), TN(33), Telangana(36)
# East: WB(19), Odisha(21)
# West: Gujarat(24), Maharashtra(27), Goa(30)

north_states <- c("06", "08", "09", "10", "20", "22", "23")
south_states <- c("28", "29", "32", "33", "36")
east_states <- c("19", "21")
west_states <- c("24", "27", "30")

df[, region := fifelse(pc11_state_id %in% north_states, "North",
                fifelse(pc11_state_id %in% south_states, "South",
                fifelse(pc11_state_id %in% east_states, "East",
                fifelse(pc11_state_id %in% west_states, "West", "Other"))))]

region_results <- data.table(
  region = c("North", "South", "East", "West"),
  estimate_f = NA_real_, se_f = NA_real_, p_f = NA_real_,
  estimate_m = NA_real_, se_m = NA_real_, p_m = NA_real_,
  n = NA_integer_
)

for (r in c("North", "South", "East", "West")) {
  sub <- df[region == r]
  cat(sprintf("  %s (N=%d):\n", r, nrow(sub)))
  idx <- which(region_results$region == r)
  region_results[idx, n := nrow(sub)]

  for (gender in c("f", "m")) {
    var <- paste0("d_nonag_share_", gender)
    y <- sub[[var]]
    x <- sub$pop2001
    v <- !is.na(y) & !is.na(x)
    if (sum(v) < 100) {
      cat(sprintf("    %s: insufficient obs\n", gender))
      next
    }
    tryCatch({
      rd <- rdrobust(y = y[v], x = x[v], c = 500)
      if (gender == "f") {
        region_results[idx, `:=`(estimate_f = rd$coef[1], se_f = rd$se[3], p_f = rd$pv[3])]
      } else {
        region_results[idx, `:=`(estimate_m = rd$coef[1], se_m = rd$se[3], p_m = rd$pv[3])]
      }
      cat(sprintf("    %s: coef = %.4f, p = %.4f\n",
                  toupper(gender), rd$coef[1], rd$pv[3]))
    }, error = function(e) {
      cat(sprintf("    %s: FAILED\n", toupper(gender)))
    })
  }
}

# ════════════════════════════════════════════════════════════════════════════
# 6. SPECIAL CATEGORY STATES (Threshold = 250)
# ════════════════════════════════════════════════════════════════════════════
cat("\n=== Special Category States (Threshold = 250) ===\n")

df_special <- panel[special_state == TRUE & !is.na(pop2001) & pop2001 > 0]
cat("  Observations:", nrow(df_special), "\n")

special_results <- data.table(
  outcome = c("d_nonag_share_f", "d_nonag_share_m"),
  estimate = NA_real_, se = NA_real_, p = NA_real_
)

for (i in 1:2) {
  var <- special_results$outcome[i]
  y <- df_special[[var]]
  x <- df_special$pop2001
  v <- !is.na(y) & !is.na(x)
  if (sum(v) < 100) next
  tryCatch({
    rd <- rdrobust(y = y[v], x = x[v], c = 250)
    special_results[i, `:=`(estimate = rd$coef[1], se = rd$se[3], p = rd$pv[3])]
    cat(sprintf("  %s: coef = %.4f, p = %.4f\n", var, rd$coef[1], rd$pv[3]))
  }, error = function(e) {
    cat(sprintf("  %s: FAILED\n", var))
  })
}

# ════════════════════════════════════════════════════════════════════════════
# 7. RANDOMIZATION INFERENCE
# ════════════════════════════════════════════════════════════════════════════
cat("\n=== Randomization Inference (500 permutations) ===\n")

set.seed(20260220)
n_perm <- 500
y_ri <- y_main[valid]
x_ri <- x_main[valid]
obs_rd <- rdrobust(y = y_ri, x = x_ri, c = 500)
obs_coef <- obs_rd$coef[1]

perm_coefs <- numeric(n_perm)
for (s in 1:n_perm) {
  y_shuf <- sample(y_ri)
  tryCatch({
    rd_perm <- rdrobust(y = y_shuf, x = x_ri, c = 500)
    perm_coefs[s] <- rd_perm$coef[1]
  }, error = function(e) {
    perm_coefs[s] <- NA
  })
  if (s %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", s, n_perm))
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pvalue <- mean(abs(perm_coefs) >= abs(obs_coef))
cat(sprintf("  Observed coef: %.4f\n", obs_coef))
cat(sprintf("  RI p-value (two-sided): %.4f\n", ri_pvalue))

ri_result <- list(obs_coef = obs_coef, ri_pvalue = ri_pvalue,
                  n_perms = length(perm_coefs))

# ── Save robustness results ─────────────────────────────────────────────────
save(bw_results, poly_results, donut_results, placebo_results,
     region_results, special_results, ri_result,
     file = "../data/robustness_results.RData")

cat("\nRobustness results saved to data/robustness_results.RData\n")
