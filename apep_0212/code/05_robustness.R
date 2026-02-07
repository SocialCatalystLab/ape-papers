# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 05_robustness.R - Full robustness battery
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================\n")
cat("  05_robustness.R\n")
cat("========================================\n\n")

# ==============================================================================
# 1. LOAD DATA AND MAIN RESULTS
# ==============================================================================
cat("=== Loading Data ===\n")

df <- arrow::read_parquet("data/analysis_panel.parquet")

# Load main C-S results
load("data/cs_results.RData")

cat(sprintf("  Rows: %s\n", format(nrow(df), big.mark = ",")))
cat(sprintf("  Places: %s\n", format(n_distinct(df$place_id), big.mark = ",")))
cat(sprintf("  States (clusters): %d\n", n_distinct(df$state_fips)))

# Ensure output directories
dir.create("tables", showWarnings = FALSE, recursive = TRUE)
dir.create("data", showWarnings = FALSE, recursive = TRUE)

# Prepare did data (same as 04_main_analysis.R)
did_data <- df %>%
  filter(!is.na(log_income)) %>%
  mutate(
    gname = as.numeric(ifelse(treated, treat_year, 0)),
    id = as.numeric(factor(place_id))
  )

# Ensure log variables exist
if (!"log_pop" %in% names(did_data) && "population" %in% names(did_data)) {
  did_data$log_pop <- log(did_data$population + 1)
}
if (!"log_income" %in% names(did_data) && "median_income" %in% names(did_data)) {
  did_data$log_income <- log(did_data$median_income + 1)
}

xformla <- ~ log_pop + log_income + pct_college + pct_white + median_age

n_clusters <- n_distinct(did_data$state_fips)
n_treated <- n_distinct(did_data$place_id[did_data$treated])
n_control <- n_distinct(did_data$place_id[!did_data$treated])

# ==============================================================================
# 2. HONESTDID (RAMBACHAN-ROTH) SENSITIVITY BOUNDS
# ==============================================================================
cat("\n=== HonestDiD Sensitivity Analysis ===\n")

honestdid_results <- list()
Mvec <- seq(0, 0.5, by = 0.05)

run_honestdid <- function(cs_obj, outcome_name) {
  cat(sprintf("  Running HonestDiD for %s...\n", outcome_name))

  tryCatch({
    # Need the event study aggregation
    es <- aggte(cs_obj, type = "dynamic", na.rm = TRUE)

    n_pre <- sum(es$egt < 0)
    n_post <- sum(es$egt >= 0)

    if (n_pre < 1 || n_post < 1) {
      cat(sprintf("    Insufficient pre/post periods (pre=%d, post=%d)\n", n_pre, n_post))
      return(NULL)
    }

    # Construct variance-covariance matrix
    # HonestDiD needs the full betahat (pre + post) and sigma
    betahat <- es$att.egt
    se_vec <- es$se.egt

    # Approximate sigma as diagonal (conservative — ignores covariance)
    sigma <- diag(se_vec^2)

    # Sensitivity analysis: smoothness restriction (relative magnitudes)
    honest_rm <- HonestDiD::createSensitivityResults(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = n_pre,
      numPostPeriods = n_post,
      Mvec = Mvec,
      l_vec = rep(1 / n_post, n_post)  # Average post-treatment effect
    )

    cat(sprintf("    HonestDiD complete: %d M values\n", nrow(honest_rm)))
    cat(sprintf("    At M=0: [%.5f, %.5f]\n", honest_rm$lb[1], honest_rm$ub[1]))
    cat(sprintf("    At M=0.5: [%.5f, %.5f]\n",
                honest_rm$lb[nrow(honest_rm)], honest_rm$ub[nrow(honest_rm)]))

    # Check: does CI include zero?
    honest_rm$includes_zero <- (honest_rm$lb <= 0 & honest_rm$ub >= 0)
    honest_rm$outcome <- outcome_name

    return(honest_rm)
  }, error = function(e) {
    cat(sprintf("    HonestDiD FAILED for %s: %s\n", outcome_name, e$message))
    return(NULL)
  })
}

# Run for individualizing and binding
for (outcome in c("individualizing", "binding")) {
  if (!is.null(cs_objects[[outcome]])) {
    honestdid_results[[outcome]] <- run_honestdid(cs_objects[[outcome]], outcome)
  } else {
    cat(sprintf("  No C-S object for %s, skipping HonestDiD\n", outcome))
  }
}

# Save HonestDiD results
save(honestdid_results, file = "data/honestdid_results.RData")
cat("  Saved: data/honestdid_results.RData\n")

# Also save as CSV for reference
honestdid_csv <- map_dfr(names(honestdid_results), function(outcome) {
  res <- honestdid_results[[outcome]]
  if (is.null(res)) return(tibble())
  res %>%
    as_tibble() %>%
    mutate(outcome = outcome)
})

if (nrow(honestdid_csv) > 0) {
  write_csv(honestdid_csv, "tables/honestdid_bounds.csv")
  cat("  Saved: tables/honestdid_bounds.csv\n")
}

# ==============================================================================
# 3. MINIMUM DETECTABLE EFFECT (MDE) AT 80% POWER
# ==============================================================================
cat("\n=== Minimum Detectable Effect ===\n")

mde_results <- map_dfr(c("individualizing", "binding", "universalism_index", "log_univ_comm"),
function(outcome) {
  att <- att_simple[[outcome]]
  if (is.null(att)) return(tibble(outcome = outcome))

  se_att <- att$overall.se
  att_val <- att$overall.att
  outcome_sd <- sd(df[[outcome]], na.rm = TRUE)

  # MDE at 80% power: 2.8 * SE (= z_alpha/2 + z_beta = 1.96 + 0.84)
  mde_raw <- 2.8 * se_att
  mde_sd <- mde_raw / outcome_sd  # in SD units

  # Also compute for 90% power: 3.24 * SE
  mde_90_raw <- 3.24 * se_att
  mde_90_sd <- mde_90_raw / outcome_sd

  cat(sprintf("  %s:\n", outcome))
  cat(sprintf("    SE(ATT) = %.5f\n", se_att))
  cat(sprintf("    MDE (80%% power) = %.5f (= %.3f SD)\n", mde_raw, mde_sd))
  cat(sprintf("    MDE (90%% power) = %.5f (= %.3f SD)\n", mde_90_raw, mde_90_sd))
  cat(sprintf("    Actual ATT = %.5f (= %.3f SD)\n", att_val, att_val / outcome_sd))

  tibble(
    outcome = outcome,
    SE_ATT = se_att,
    outcome_SD = outcome_sd,
    ATT = att_val,
    ATT_SD_units = att_val / outcome_sd,
    MDE_80_raw = mde_raw,
    MDE_80_SD = mde_sd,
    MDE_90_raw = mde_90_raw,
    MDE_90_SD = mde_90_sd,
    powered_80 = abs(att_val) >= mde_raw,
    powered_90 = abs(att_val) >= mde_90_raw,
    N = nrow(df),
    N_clusters = n_clusters,
    N_treated = n_treated
  )
})

cat("\n  MDE Summary:\n")
print(mde_results %>% select(outcome, ATT_SD_units, MDE_80_SD, MDE_90_SD, powered_80),
      width = Inf)

write_csv(mde_results, "tables/mde_results.csv")
cat("  Saved: tables/mde_results.csv\n")

# ==============================================================================
# 4. EQUIVALENCE TESTS (TOST)
# ==============================================================================
cat("\n=== Equivalence Tests (TOST) ===\n")

equiv_bounds <- c(0.05, 0.10, 0.15)  # in SD units

equiv_results <- expand_grid(
  outcome = c("individualizing", "binding", "universalism_index", "log_univ_comm"),
  bound_sd = equiv_bounds
) %>%
  pmap_dfr(function(outcome, bound_sd) {
    att <- att_simple[[outcome]]
    if (is.null(att)) {
      return(tibble(outcome = outcome, bound_sd = bound_sd))
    }

    att_val <- att$overall.att
    se_val <- att$overall.se
    outcome_sd <- sd(df[[outcome]], na.rm = TRUE)

    # Convert bound from SD to raw units
    bound_raw <- bound_sd * outcome_sd

    # TOST: two one-sided tests
    # H0_1: ATT <= -bound   vs H1_1: ATT > -bound
    # H0_2: ATT >= +bound   vs H1_2: ATT < +bound
    z_lower <- (att_val - (-bound_raw)) / se_val  # should be positive to reject
    z_upper <- (att_val - bound_raw) / se_val      # should be negative to reject

    p_lower <- 1 - pnorm(z_lower)   # p-value for lower test
    p_upper <- pnorm(z_upper)       # p-value for upper test

    # TOST p-value = max of two one-sided p-values
    p_tost <- max(p_lower, p_upper)
    equivalent <- p_tost < 0.05

    tibble(
      outcome = outcome,
      bound_sd = bound_sd,
      bound_raw = bound_raw,
      ATT = att_val,
      SE = se_val,
      z_lower = z_lower,
      z_upper = z_upper,
      p_lower = p_lower,
      p_upper = p_upper,
      p_TOST = p_tost,
      equivalent_05 = equivalent
    )
  })

cat("\n  Equivalence Test Results:\n")
equiv_results %>%
  select(outcome, bound_sd, ATT, p_TOST, equivalent_05) %>%
  mutate(ATT = round(ATT, 5), p_TOST = round(p_TOST, 4)) %>%
  print(n = Inf)

write_csv(equiv_results, "tables/equivalence_tests.csv")
cat("  Saved: tables/equivalence_tests.csv\n")

# ==============================================================================
# 5. ALTERNATIVE THRESHOLDS: 60%, 65%, 75%, 80%
# ==============================================================================
cat("\n=== Alternative Broadband Thresholds ===\n")

alt_thresholds <- c(0.60, 0.65, 0.75, 0.80)

run_cs_threshold <- function(data, threshold, outcome, biters = 300) {
  # Redefine treatment timing based on alternative threshold
  treat_timing_alt <- data %>%
    filter(broadband_rate >= threshold) %>%
    group_by(place_id) %>%
    summarise(treat_year_alt = min(year), .groups = "drop")

  df_alt <- data %>%
    select(-any_of(c("gname"))) %>%
    left_join(treat_timing_alt, by = "place_id") %>%
    mutate(
      gname_alt = as.numeric(ifelse(!is.na(treat_year_alt), treat_year_alt, 0)),
      id_alt = as.numeric(factor(place_id))
    )

  n_tr <- sum(df_alt$gname_alt > 0) / n_distinct(df_alt$year[df_alt$gname_alt > 0])
  n_tr_places <- n_distinct(df_alt$place_id[df_alt$gname_alt > 0])

  cs <- att_gt(
    yname = outcome,
    tname = "year",
    idname = "id_alt",
    gname = "gname_alt",
    data = df_alt,
    control_group = "notyettreated",
    est_method = "reg",
    xformla = xformla,
    clustervars = "state_fips",
    anticipation = 1,
    bstrap = TRUE,
    biters = biters,
    print_details = FALSE
  )

  att <- aggte(cs, type = "simple", na.rm = TRUE)

  tibble(
    threshold = threshold,
    outcome = outcome,
    ATT = att$overall.att,
    SE = att$overall.se,
    CI_lower = att$overall.att - 1.96 * att$overall.se,
    CI_upper = att$overall.att + 1.96 * att$overall.se,
    p_value = 2 * (1 - pnorm(abs(att$overall.att / att$overall.se))),
    N_treated_places = n_tr_places,
    N = nrow(df_alt),
    N_clusters = n_distinct(df_alt$state_fips)
  )
}

alt_threshold_results <- list()

for (thresh in alt_thresholds) {
  for (outcome in c("individualizing", "binding")) {
    cat(sprintf("  Threshold %.0f%%, %s... ", thresh * 100, outcome))

    result <- tryCatch({
      run_cs_threshold(did_data, thresh, outcome, biters = 300)
    }, error = function(e) {
      cat(sprintf("FAILED: %s\n", e$message))
      tibble(
        threshold = thresh, outcome = outcome,
        ATT = NA, SE = NA, CI_lower = NA, CI_upper = NA,
        p_value = NA, N_treated_places = NA, N = nrow(did_data),
        N_clusters = n_clusters
      )
    })

    if (!is.na(result$ATT[1])) {
      cat(sprintf("ATT = %.5f (SE = %.5f)\n", result$ATT, result$SE))
    }

    alt_threshold_results[[paste0(thresh, "_", outcome)]] <- result
  }
}

# Add the main 70% threshold results for comparison
for (outcome in c("individualizing", "binding")) {
  att <- att_simple[[outcome]]
  if (!is.null(att)) {
    alt_threshold_results[[paste0("0.7_", outcome)]] <- tibble(
      threshold = 0.70,
      outcome = outcome,
      ATT = att$overall.att,
      SE = att$overall.se,
      CI_lower = att$overall.att - 1.96 * att$overall.se,
      CI_upper = att$overall.att + 1.96 * att$overall.se,
      p_value = 2 * (1 - pnorm(abs(att$overall.att / att$overall.se))),
      N_treated_places = n_treated,
      N = nrow(did_data),
      N_clusters = n_clusters
    )
  }
}

alt_threshold_table <- bind_rows(alt_threshold_results) %>%
  arrange(outcome, threshold)

cat("\n  Alternative Threshold Results:\n")
alt_threshold_table %>%
  mutate(ATT = round(ATT, 5), SE = round(SE, 5), p_value = round(p_value, 4)) %>%
  print(n = Inf, width = Inf)

write_csv(alt_threshold_table, "tables/alt_thresholds.csv")
cat("  Saved: tables/alt_thresholds.csv\n")

# ==============================================================================
# 6. SUN-ABRAHAM ESTIMATOR (from fixest)
# ==============================================================================
cat("\n=== Sun-Abraham Estimator ===\n")

sa_results <- list()

for (outcome in c("individualizing", "binding", "universalism_index", "log_univ_comm")) {
  cat(sprintf("  Sun-Abraham: %s... ", outcome))

  sa_results[[outcome]] <- tryCatch({
    fml <- as.formula(paste0(outcome, " ~ sunab(treat_year, year) | place_id + year"))
    sa <- feols(fml, data = df %>% filter(treated), cluster = ~state_fips)
    cat("OK\n")
    sa
  }, error = function(e) {
    cat(sprintf("FAILED: %s\n", e$message))
    # Try with full sample using Inf for never-treated
    tryCatch({
      df_sa <- df %>%
        mutate(treat_year_sa = ifelse(treated, treat_year, 10000))
      fml <- as.formula(paste0(outcome, " ~ sunab(treat_year_sa, year) | place_id + year"))
      sa <- feols(fml, data = df_sa, cluster = ~state_fips)
      cat("  (succeeded with full sample)\n")
      sa
    }, error = function(e2) {
      cat(sprintf("  ALSO FAILED: %s\n", e2$message))
      NULL
    })
  })
}

# Extract Sun-Abraham coefficients
sa_table <- map_dfr(names(sa_results), function(outcome) {
  m <- sa_results[[outcome]]
  if (is.null(m)) return(tibble(outcome = outcome))

  # Get the overall ATT (average of post-treatment coefficients)
  coefs <- coef(m)
  ses <- se(m)
  pvals <- fixest::pvalue(m)

  # The sunab() function labels coefficients by event time
  coef_names <- names(coefs)

  # Extract the aggregate ATT from fixest's summary
  agg_result <- tryCatch({
    agg <- aggregate(m, agg = "ATT")
    # aggregate returns a fixest object; extract ATT coefficient
    att_val <- coef(agg)[1]
    se_val <- se(agg)[1]
    p_val <- fixest::pvalue(agg)[1]
    tibble(
      outcome = outcome,
      estimator = "Sun-Abraham",
      ATT = as.numeric(att_val),
      SE = as.numeric(se_val),
      CI_lower = as.numeric(att_val) - 1.96 * as.numeric(se_val),
      CI_upper = as.numeric(att_val) + 1.96 * as.numeric(se_val),
      p_value = as.numeric(p_val),
      N = m$nobs,
      N_clusters = tryCatch(m$summary_flags$n_clusters, error = function(e) NA)
    )
  }, error = function(e) NULL)

  if (!is.null(agg_result)) {
    agg_result
  } else {
    # Fallback: manual average of post-period coefficients
    post_coefs <- coefs[grepl("year::", coef_names)]
    if (length(post_coefs) > 0) {
      att_mean <- mean(post_coefs)
      tibble(
        outcome = outcome,
        estimator = "Sun-Abraham",
        ATT = att_mean,
        SE = NA,
        CI_lower = NA, CI_upper = NA,
        p_value = NA,
        N = m$nobs,
        N_clusters = NA
      )
    } else {
      tibble(outcome = outcome, estimator = "Sun-Abraham")
    }
  }
})

cat("\n  Sun-Abraham Results:\n")
sa_table %>%
  mutate(across(where(is.numeric), ~round(., 5))) %>%
  print(n = Inf, width = Inf)

write_csv(sa_table, "tables/sun_abraham.csv")
cat("  Saved: tables/sun_abraham.csv\n")

# ==============================================================================
# 7. CONTINUOUS TREATMENT (DOSE-RESPONSE)
# ==============================================================================
cat("\n=== Continuous Treatment (Dose-Response) ===\n")

dose_results <- list()

for (outcome in c("individualizing", "binding", "universalism_index", "log_univ_comm")) {
  cat(sprintf("  Dose-response: %s... ", outcome))

  dose_results[[outcome]] <- tryCatch({
    fml <- as.formula(paste0(outcome, " ~ broadband_rate | place_id + year"))
    feols(fml, data = df, cluster = ~state_fips)
  }, error = function(e) {
    cat(sprintf("FAILED: %s\n", e$message))
    NULL
  })

  if (!is.null(dose_results[[outcome]])) {
    m <- dose_results[[outcome]]
    cat(sprintf("coef = %.5f (SE = %.5f, p = %.4f)\n",
                coef(m)["broadband_rate"],
                se(m)["broadband_rate"],
                fixest::pvalue(m)["broadband_rate"]))
  }
}

# Print joint table
valid_dose <- dose_results[!sapply(dose_results, is.null)]
if (length(valid_dose) > 0) {
  cat("\n  Continuous Treatment TWFE:\n")
  etable(valid_dose,
         headers = names(valid_dose),
         fitstat = ~ r2 + n)
}

dose_table <- map_dfr(names(dose_results), function(outcome) {
  m <- dose_results[[outcome]]
  if (is.null(m)) return(tibble(outcome = outcome))

  tibble(
    outcome = outcome,
    estimator = "TWFE (continuous)",
    coef = coef(m)["broadband_rate"],
    SE = se(m)["broadband_rate"],
    CI_lower = coef(m)["broadband_rate"] - 1.96 * se(m)["broadband_rate"],
    CI_upper = coef(m)["broadband_rate"] + 1.96 * se(m)["broadband_rate"],
    p_value = fixest::pvalue(m)["broadband_rate"],
    N = m$nobs,
    N_clusters = n_clusters,
    R2_within = fixest::r2(m, "wr2")
  )
})

write_csv(dose_table, "tables/continuous_treatment.csv")
cat("  Saved: tables/continuous_treatment.csv\n")

# ==============================================================================
# 8. PLACEBO OUTCOMES
# ==============================================================================
cat("\n=== Placebo Outcomes ===\n")

placebo_vars <- c("n_total_words", "n_meetings", "moral_intensity")
placebo_vars <- placebo_vars[placebo_vars %in% names(did_data)]

cat(sprintf("  Available placebo variables: %s\n", paste(placebo_vars, collapse = ", ")))

placebo_results <- map_dfr(placebo_vars, function(pvar) {
  cat(sprintf("  Placebo: %s... ", pvar))

  result <- tryCatch({
    cs_placebo <- att_gt(
      yname = pvar,
      tname = "year",
      idname = "id",
      gname = "gname",
      data = did_data,
      control_group = "notyettreated",
      est_method = "reg",
      xformla = xformla,
      clustervars = "state_fips",
      anticipation = 1,
      bstrap = TRUE,
      biters = 500,
      print_details = FALSE
    )

    att_placebo <- aggte(cs_placebo, type = "simple", na.rm = TRUE)
    att_val <- att_placebo$overall.att
    se_val <- att_placebo$overall.se
    p_val <- 2 * (1 - pnorm(abs(att_val / se_val)))

    cat(sprintf("ATT = %.4f (SE = %.4f, p = %.4f)\n", att_val, se_val, p_val))

    tibble(
      outcome = pvar,
      type = "placebo",
      ATT = att_val,
      SE = se_val,
      CI_lower = att_val - 1.96 * se_val,
      CI_upper = att_val + 1.96 * se_val,
      p_value = p_val,
      N = nrow(did_data),
      N_clusters = n_clusters,
      N_treated = n_treated,
      pass_placebo = p_val > 0.10  # Should NOT be significant
    )
  }, error = function(e) {
    cat(sprintf("FAILED: %s\n", e$message))
    tibble(
      outcome = pvar, type = "placebo",
      ATT = NA, SE = NA, CI_lower = NA, CI_upper = NA,
      p_value = NA, N = nrow(did_data), N_clusters = n_clusters,
      N_treated = n_treated, pass_placebo = NA
    )
  })

  result
})

cat("\n  Placebo Results:\n")
placebo_results %>%
  mutate(ATT = round(ATT, 4), SE = round(SE, 4), p_value = round(p_value, 4)) %>%
  print(width = Inf)

write_csv(placebo_results, "tables/placebo_outcomes.csv")
cat("  Saved: tables/placebo_outcomes.csv\n")

# ==============================================================================
# 9. ATTRITION CHECK
# ==============================================================================
cat("\n=== Attrition Check ===\n")

# Does treatment predict exit from the sample?
# Construct: for each place, is it present in all years?

all_years <- sort(unique(df$year))
n_years_total <- length(all_years)

attrition_data <- df %>%
  group_by(place_id) %>%
  summarise(
    n_years = n(),
    treated = first(treated),
    treat_year = first(treat_year),
    state_fips = first(state_fips),
    # Check if place appears in last year
    present_last = max(year) == max(all_years),
    # Fraction of possible years observed
    coverage = n() / n_years_total,
    balanced = (n() == n_years_total),
    .groups = "drop"
  )

cat(sprintf("  Total places: %d\n", nrow(attrition_data)))
cat(sprintf("  Balanced (all years): %d (%.1f%%)\n",
            sum(attrition_data$balanced),
            mean(attrition_data$balanced) * 100))

# Test 1: Does treatment predict balanced panel?
attrition_test1 <- tryCatch({
  glm(balanced ~ treated, data = attrition_data, family = binomial)
}, error = function(e) NULL)

# Test 2: Does treatment predict coverage fraction?
attrition_test2 <- tryCatch({
  lm(coverage ~ treated, data = attrition_data)
}, error = function(e) NULL)

# Test 3: TWFE — does treatment predict being observed next period?
# Create lead indicator
df_attrition_panel <- df %>%
  arrange(place_id, year) %>%
  group_by(place_id) %>%
  mutate(
    observed_next = as.numeric(lead(year) == year + 1),
    # If it's the last year, set to NA (cannot observe next)
    observed_next = ifelse(year == max(all_years), NA, observed_next)
  ) %>%
  ungroup()

attrition_test3 <- tryCatch({
  feols(observed_next ~ treat_post | place_id + year,
        data = df_attrition_panel, cluster = ~state_fips)
}, error = function(e) NULL)

# Compile results
attrition_table <- tibble(
  test = c(
    "Treatment -> Balanced Panel (logit)",
    "Treatment -> Coverage Fraction (OLS)",
    "Treatment -> Observed Next Year (TWFE)"
  ),
  coef = c(
    if (!is.null(attrition_test1)) coef(attrition_test1)["treatedTRUE"] else NA,
    if (!is.null(attrition_test2)) coef(attrition_test2)["treatedTRUE"] else NA,
    if (!is.null(attrition_test3)) coef(attrition_test3)["treat_post"] else NA
  ),
  SE = c(
    if (!is.null(attrition_test1)) summary(attrition_test1)$coefficients["treatedTRUE", "Std. Error"] else NA,
    if (!is.null(attrition_test2)) summary(attrition_test2)$coefficients["treatedTRUE", "Std. Error"] else NA,
    if (!is.null(attrition_test3)) se(attrition_test3)["treat_post"] else NA
  ),
  p_value = c(
    if (!is.null(attrition_test1)) summary(attrition_test1)$coefficients["treatedTRUE", "Pr(>|z|)"] else NA,
    if (!is.null(attrition_test2)) summary(attrition_test2)$coefficients["treatedTRUE", "Pr(>|t|)"] else NA,
    if (!is.null(attrition_test3)) fixest::pvalue(attrition_test3)["treat_post"] else NA
  ),
  N = c(
    nrow(attrition_data),
    nrow(attrition_data),
    if (!is.null(attrition_test3)) attrition_test3$nobs else NA
  ),
  N_clusters = c(
    n_distinct(attrition_data$state_fips),
    n_distinct(attrition_data$state_fips),
    n_clusters
  ),
  N_treated = c(
    sum(attrition_data$treated),
    sum(attrition_data$treated),
    n_treated
  )
) %>%
  mutate(
    CI_lower = coef - 1.96 * SE,
    CI_upper = coef + 1.96 * SE,
    pass_attrition = p_value > 0.10  # Should NOT be significant
  )

cat("\n  Attrition Test Results:\n")
attrition_table %>%
  mutate(across(where(is.numeric), ~round(., 4))) %>%
  print(width = Inf)

write_csv(attrition_table, "tables/attrition_check.csv")
cat("  Saved: tables/attrition_check.csv\n")

# ==============================================================================
# 10. COMPILE MASTER ROBUSTNESS SUMMARY
# ==============================================================================
cat("\n=== Compiling Robustness Summary ===\n")

# Save all robustness objects
save(
  honestdid_results,
  mde_results,
  equiv_results,
  alt_threshold_table,
  sa_results, sa_table,
  dose_results, dose_table,
  placebo_results,
  attrition_table,
  file = "data/robustness_results.RData"
)
cat("  Saved: data/robustness_results.RData\n")

cat("\n========================================\n")
cat("  05_robustness.R COMPLETE\n")
cat("========================================\n")
