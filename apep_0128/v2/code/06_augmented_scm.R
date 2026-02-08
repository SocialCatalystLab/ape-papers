# ==============================================================================
# 06_augmented_scm.R
# National-Level Complement: Augmented SCM, SDID, and NNLS SCM
# Country-level evidence to complement sub-national DiD
# ==============================================================================

source("00_packages.R")

cat("=== 06_augmented_scm.R: National-Level Complement ===\n")

panel_national <- readRDS("../data/processed/panel_national.rds")

cat(sprintf("National panel: %d obs, %d countries, %d quarters\n",
            nrow(panel_national),
            n_distinct(panel_national$country),
            n_distinct(panel_national$date)))

# ------------------------------------------------------------------------------
# 1. Augmented SCM (Ben-Michael et al. 2021)
# ------------------------------------------------------------------------------
cat("\n--- 1. Augmented Synthetic Control ---\n")

# Prepare data for augsynth
national_panel <- panel_national %>%
  mutate(
    unit = as.numeric(as.factor(country)),
    time = as.numeric(as.factor(date)),
    trt = ifelse(country == "Netherlands" & post, 1, 0)
  )

tryCatch({
  asc <- augsynth(
    hpi_norm ~ trt,
    unit = country,
    time = date,
    data = national_panel,
    progfunc = "Ridge",
    scm = TRUE
  )

  cat("\nAugmented SCM summary:\n")
  asc_summ <- summary(asc)
  print(asc_summ)

  saveRDS(list(asc = asc, asc_summ = asc_summ), "../data/processed/augsynth_results.rds")

}, error = function(e) {
  cat("augsynth error:", conditionMessage(e), "\n")
  cat("Proceeding to NNLS fallback...\n")
  saveRDS(list(error = conditionMessage(e)), "../data/processed/augsynth_results.rds")
})

# ------------------------------------------------------------------------------
# 2. Synthetic DiD (Arkhangelsky et al. 2021)
# ------------------------------------------------------------------------------
cat("\n--- 2. Synthetic Difference-in-Differences ---\n")

tryCatch({
  sdid <- augsynth(
    hpi_norm ~ trt,
    unit = country,
    time = date,
    data = national_panel,
    progfunc = "none",
    scm = TRUE,
    fixedeff = TRUE  # Makes it SDID
  )

  cat("\nSDID summary:\n")
  sdid_summ <- summary(sdid)
  print(sdid_summ)

  saveRDS(list(sdid = sdid, sdid_summ = sdid_summ), "../data/processed/sdid_results.rds")

}, error = function(e) {
  cat("SDID error:", conditionMessage(e), "\n")
  saveRDS(list(error = conditionMessage(e)), "../data/processed/sdid_results.rds")
})

# ------------------------------------------------------------------------------
# 3. Original NNLS SCM (Baseline Comparison)
# ------------------------------------------------------------------------------
cat("\n--- 3. NNLS Synthetic Control ---\n")

# Filter to analysis period
pre_start <- as.Date("2010-01-01")
post_start <- as.Date("2019-04-01")

national_analysis <- panel_national %>%
  filter(date >= pre_start) %>%
  arrange(country, date)

# Create outcome matrix (wide format: rows = dates, columns = countries)
Y <- national_analysis %>%
  select(country, date, hpi_norm) %>%
  pivot_wider(names_from = country, values_from = hpi_norm) %>%
  arrange(date)

dates <- Y$date
Y <- as.matrix(Y[, -1])

# Treated unit
y_treated <- Y[, "Netherlands"]
Y_donors <- Y[, colnames(Y) != "Netherlands"]

# Pre-treatment period
pre_mask <- dates < post_start
y_pre <- y_treated[pre_mask]
Y_donors_pre <- Y_donors[pre_mask, ]

# NNLS weights
fit <- nnls::nnls(Y_donors_pre, y_pre)
w <- fit$x / sum(fit$x)
names(w) <- colnames(Y_donors)

# Synthetic control
y_synth <- Y_donors %*% w

# Treatment gaps
gaps <- y_treated - as.numeric(y_synth)

# Pre-treatment fit
pre_rmse <- sqrt(mean(gaps[pre_mask]^2))
pre_r2 <- 1 - sum(gaps[pre_mask]^2) / sum((y_pre - mean(y_pre))^2)

# Post-treatment ATT
post_mask <- dates >= post_start
att <- mean(gaps[post_mask])
att_se <- sd(gaps[post_mask]) / sqrt(sum(post_mask))

cat(sprintf("Pre-treatment RMSE: %.2f\n", pre_rmse))
cat(sprintf("Pre-treatment R-squared: %.3f\n", pre_r2))
cat(sprintf("ATT: %.2f (SE: %.2f)\n", att, att_se))
cat(sprintf("Weights: %s\n",
            paste(sprintf("%s=%.3f", names(w)[w > 0.01], w[w > 0.01]), collapse = ", ")))

saveRDS(list(
  weights = w, gaps = gaps, dates = dates, y_treated = y_treated,
  y_synth = as.numeric(y_synth), pre_rmse = pre_rmse, pre_r2 = pre_r2,
  att = att, att_se = att_se, pre_mask = pre_mask, post_mask = post_mask
), "../data/processed/nnls_scm_results.rds")

# ------------------------------------------------------------------------------
# 4. In-Space Placebo Tests for NNLS SCM
# ------------------------------------------------------------------------------
cat("\n--- 4. NNLS Placebo Tests ---\n")

donor_names <- colnames(Y_donors)
placebo_gaps <- list()

for (placebo_unit in donor_names) {
  # Placebo treated
  y_placebo <- Y[, placebo_unit]
  # Donors: all others including Netherlands
  Y_placebo_donors <- Y[, colnames(Y) != placebo_unit]

  y_placebo_pre <- y_placebo[pre_mask]
  Y_placebo_donors_pre <- Y_placebo_donors[pre_mask, ]

  tryCatch({
    fit_p <- nnls::nnls(Y_placebo_donors_pre, y_placebo_pre)
    w_p <- fit_p$x / sum(fit_p$x)
    y_p_synth <- Y_placebo_donors %*% w_p
    placebo_gaps[[placebo_unit]] <- y_placebo - as.numeric(y_p_synth)
  }, error = function(e) {
    cat(sprintf("  Placebo failed for %s: %s\n", placebo_unit, conditionMessage(e)))
  })
}

# p-value: fraction of placebos with |ATT| >= Netherlands |ATT|
placebo_atts <- sapply(placebo_gaps, function(g) mean(g[post_mask]))
nl_rank <- sum(abs(placebo_atts) >= abs(att)) + 1
nl_pvalue <- nl_rank / (length(placebo_atts) + 1)

cat(sprintf("Netherlands ATT: %.2f\n", att))
cat(sprintf("Netherlands rank: %d of %d\n", nl_rank, length(placebo_atts) + 1))
cat(sprintf("Exact p-value: %.3f\n", nl_pvalue))

saveRDS(list(
  placebo_gaps = placebo_gaps,
  placebo_atts = placebo_atts,
  nl_rank = nl_rank,
  nl_pvalue = nl_pvalue,
  dates = dates,
  pre_mask = pre_mask,
  post_mask = post_mask
), "../data/processed/nnls_placebo_results.rds")

cat("\n=== National-level analysis complete ===\n")
