# ==============================================================================
# 08_gender_analysis.R
# Gender Analysis: How Men and Women Experience Self-Employment Differently
# Revision of apep_0173
# ==============================================================================

source("00_packages.R")

# Load analysis data
cps <- readRDS(file.path(data_dir, "cps_analysis.rds"))

cat("Loaded", nrow(cps), "observations for gender analysis.\n")

# ==============================================================================
# Prepare data
# ==============================================================================

# State FIPS codes and names
state_info <- tibble(
  state = c("06", "48", "12", "36", "17", "39", "42", "13", "37", "26"),
  state_name = c("California", "Texas", "Florida", "New York", "Illinois",
                 "Ohio", "Pennsylvania", "Georgia", "North Carolina", "Michigan"),
  state_abbr = c("CA", "TX", "FL", "NY", "IL", "OH", "PA", "GA", "NC", "MI")
)

cps_complete <- cps %>%
  filter(
    !is.na(multiple_jobs),
    !is.na(age),
    !is.na(female),
    !is.na(college),
    !is.na(married),
    !is.na(homeowner),
    !is.na(log_earnings)
  ) %>%
  mutate(
    race_white = as.integer(race == "White"),
    race_black = as.integer(race == "Black"),
    race_hispanic = as.integer(race == "Hispanic"),
    race_asian = as.integer(race == "Asian"),
    age_sq = age^2,
    gender = ifelse(female == 1, "Women", "Men")
  )

cat("Complete cases:", nrow(cps_complete), "\n")
cat("Men:", sum(cps_complete$female == 0), "\n")
cat("Women:", sum(cps_complete$female == 1), "\n")

# Covariates (excluding female since we stratify by it)
covariates_no_gender <- c(
  "age", "age_sq", "college", "married",
  "race_white", "race_black", "race_hispanic", "race_asian",
  "homeowner", "covid_period"
)

# ==============================================================================
# Helper function for gender-specific IPW estimation
# ==============================================================================

estimate_gender_effect <- function(data, treatment_var = "multiple_jobs",
                                   outcome_var = "log_earnings",
                                   covariates = covariates_no_gender) {

  n_total <- nrow(data)
  n_treated <- sum(data[[treatment_var]] == 1, na.rm = TRUE)
  n_control <- sum(data[[treatment_var]] == 0, na.rm = TRUE)

  if (n_treated < 100 || n_control < 500) {
    return(tibble(
      estimate = NA_real_,
      se = NA_real_,
      ci_lower = NA_real_,
      ci_upper = NA_real_,
      n = n_total,
      n_treated = n_treated,
      n_control = n_control,
      converged = FALSE
    ))
  }

  ps_formula <- as.formula(paste(
    treatment_var, "~",
    paste(covariates, collapse = " + ")
  ))

  tryCatch({
    ps_fit <- weightit(
      ps_formula,
      data = data,
      method = "ps",
      estimand = "ATE"
    )

    data$ipw <- pmin(ps_fit$weights, quantile(ps_fit$weights, 0.99, na.rm = TRUE))

    outcome_formula <- as.formula(paste(outcome_var, "~", treatment_var))
    m <- lm(outcome_formula, data = data, weights = ipw)

    est <- coef(m)[treatment_var]
    se <- sqrt(sandwich::vcovHC(m, type = "HC1")[treatment_var, treatment_var])
    ci <- est + c(-1.96, 1.96) * se

    tibble(
      estimate = est,
      se = se,
      ci_lower = ci[1],
      ci_upper = ci[2],
      n = n_total,
      n_treated = n_treated,
      n_control = n_control,
      converged = TRUE
    )
  }, error = function(e) {
    tibble(
      estimate = NA_real_,
      se = NA_real_,
      ci_lower = NA_real_,
      ci_upper = NA_real_,
      n = n_total,
      n_treated = n_treated,
      n_control = n_control,
      converged = FALSE
    )
  })
}

# ==============================================================================
# PART 1: Aggregate Self-Employment Effects by Gender
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 1: AGGREGATE SELF-EMPLOYMENT EFFECTS BY GENDER\n")
cat(strrep("=", 70), "\n")

gender_aggregate_results <- list()

for (g in c("Men", "Women")) {
  gender_data <- cps_complete %>% filter(gender == g)

  cat("\n--- Gender:", g, "---\n")
  cat("N =", nrow(gender_data), "\n")
  cat("Self-employed:", sum(gender_data$multiple_jobs == 1), "\n")

  result <- estimate_gender_effect(gender_data)
  result$gender <- g
  result$type <- "Aggregate"

  gender_aggregate_results[[g]] <- result

  if (result$converged) {
    cat("Estimate:", round(result$estimate, 4),
        "[95% CI:", round(result$ci_lower, 4), ",", round(result$ci_upper, 4), "]\n")
  }
}

gender_aggregate_df <- bind_rows(gender_aggregate_results)

# Test for gender difference
diff_gender <- gender_aggregate_results[["Men"]]$estimate - gender_aggregate_results[["Women"]]$estimate
se_diff <- sqrt(gender_aggregate_results[["Men"]]$se^2 + gender_aggregate_results[["Women"]]$se^2)
p_diff <- 2 * pnorm(-abs(diff_gender / se_diff))

cat("\n=== Gender Difference Test ===\n")
cat("Difference (Men - Women):", round(diff_gender, 4), "\n")
cat("SE:", round(se_diff, 4), "\n")
cat("p-value:", round(p_diff, 4), "\n")

# ==============================================================================
# PART 2: Incorporated Effects by Gender
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 2: INCORPORATED SELF-EMPLOYMENT EFFECTS BY GENDER\n")
cat(strrep("=", 70), "\n")

gender_inc_results <- list()

for (g in c("Men", "Women")) {
  gender_data <- cps_complete %>%
    filter(gender == g) %>%
    filter(multiple_jobs == 0 | incorporated == 1) %>%
    mutate(treatment = incorporated)

  cat("\n--- Gender:", g, "(Incorporated) ---\n")
  cat("N =", nrow(gender_data), ", N incorporated =", sum(gender_data$treatment), "\n")

  result <- estimate_gender_effect(gender_data, treatment_var = "treatment")
  result$gender <- g
  result$type <- "Incorporated"

  gender_inc_results[[g]] <- result

  if (result$converged) {
    cat("Estimate:", round(result$estimate, 4),
        "[95% CI:", round(result$ci_lower, 4), ",", round(result$ci_upper, 4), "]\n")
  }
}

gender_inc_df <- bind_rows(gender_inc_results)

# ==============================================================================
# PART 3: Unincorporated Effects by Gender
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 3: UNINCORPORATED SELF-EMPLOYMENT EFFECTS BY GENDER\n")
cat(strrep("=", 70), "\n")

gender_uninc_results <- list()

for (g in c("Men", "Women")) {
  gender_data <- cps_complete %>%
    filter(gender == g) %>%
    filter(multiple_jobs == 0 | unincorporated == 1) %>%
    mutate(treatment = unincorporated)

  cat("\n--- Gender:", g, "(Unincorporated) ---\n")
  cat("N =", nrow(gender_data), ", N unincorporated =", sum(gender_data$treatment), "\n")

  result <- estimate_gender_effect(gender_data, treatment_var = "treatment")
  result$gender <- g
  result$type <- "Unincorporated"

  gender_uninc_results[[g]] <- result

  if (result$converged) {
    cat("Estimate:", round(result$estimate, 4),
        "[95% CI:", round(result$ci_lower, 4), ",", round(result$ci_upper, 4), "]\n")
  }
}

gender_uninc_df <- bind_rows(gender_uninc_results)

# ==============================================================================
# PART 4: Gender × State Analysis
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 4: GENDER × STATE ANALYSIS\n")
cat(strrep("=", 70), "\n")

gender_state_results <- list()

# Standardize state codes and filter to known states
cps_state <- cps_complete %>%
  mutate(state = as.character(as.integer(state))) %>%
  filter(state %in% state_info$state)

for (g in c("Men", "Women")) {
  for (i in 1:nrow(state_info)) {
    st <- state_info$state[i]
    state_name_val <- state_info$state_name[i]
    state_abbr_val <- state_info$state_abbr[i]

    gs_data <- cps_state %>%
      filter(gender == g, state == st)

    key <- paste(g, st, sep = "_")

    if (nrow(gs_data) < 1000) {
      cat("Skipping", g, "-", state_name_val, "(insufficient sample)\n")
      next
    }

    result <- estimate_gender_effect(gs_data)
    result$gender <- g
    result$state <- st
    result$state_name <- state_name_val
    result$state_abbr <- state_abbr_val
    result$type <- "Aggregate"

    gender_state_results[[key]] <- result

    if (result$converged) {
      cat(g, "-", state_name_val, ":", round(result$estimate, 4), "\n")
    }
  }
}

gender_state_df <- bind_rows(gender_state_results)

# ==============================================================================
# PART 5: Gender × Education × Incorporation
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 5: GENDER × EDUCATION × INCORPORATION (Triple Interaction)\n")
cat(strrep("=", 70), "\n")

triple_results <- list()

for (g in c("Men", "Women")) {
  for (educ_level in c(0, 1)) {
    for (selfemp_type in c("Incorporated", "Unincorporated")) {

      educ_label <- ifelse(educ_level == 1, "College", "No college")

      if (selfemp_type == "Incorporated") {
        subset_data <- cps_complete %>%
          filter(gender == g, college == educ_level) %>%
          filter(multiple_jobs == 0 | incorporated == 1) %>%
          mutate(treatment = incorporated)
      } else {
        subset_data <- cps_complete %>%
          filter(gender == g, college == educ_level) %>%
          filter(multiple_jobs == 0 | unincorporated == 1) %>%
          mutate(treatment = unincorporated)
      }

      label <- paste(g, educ_label, selfemp_type, sep = " x ")
      cat("\n--- Subgroup:", label, "---\n")
      cat("N =", nrow(subset_data), ", N treated =", sum(subset_data$treatment), "\n")

      if (sum(subset_data$treatment) < 200) {
        cat("Insufficient treated sample.\n")
        next
      }

      result <- estimate_gender_effect(
        subset_data,
        treatment_var = "treatment",
        covariates = setdiff(covariates_no_gender, "college")
      )
      result$gender <- g
      result$education <- educ_label
      result$selfemp_type <- selfemp_type
      result$subgroup <- label

      triple_results[[label]] <- result

      if (result$converged) {
        cat("Estimate:", round(result$estimate, 4),
            "[95% CI:", round(result$ci_lower, 4), ",", round(result$ci_upper, 4), "]\n")
      }
    }
  }
}

triple_df <- bind_rows(triple_results)

# ==============================================================================
# Combine all gender results
# ==============================================================================

gender_results <- bind_rows(
  gender_aggregate_df,
  gender_inc_df,
  gender_uninc_df
)

# ==============================================================================
# Summary Statistics by Gender
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("GENDER SUMMARY STATISTICS\n")
cat(strrep("=", 70), "\n")

gender_summary <- cps_complete %>%
  group_by(gender) %>%
  summarise(
    n = n(),
    pct_selfemp = mean(multiple_jobs) * 100,
    pct_incorporated = mean(incorporated, na.rm = TRUE) * 100,
    pct_unincorporated = mean(unincorporated, na.rm = TRUE) * 100,
    mean_earnings = mean(exp(log_earnings), na.rm = TRUE),
    mean_log_earnings = mean(log_earnings, na.rm = TRUE),
    pct_college = mean(college) * 100,
    mean_age = mean(age),
    .groups = "drop"
  )

print(gender_summary)

# SE rates by gender
cat("\nSelf-employment rates by gender:\n")
cat("Men:", round(gender_summary$pct_selfemp[gender_summary$gender == "Men"], 2), "%\n")
cat("Women:", round(gender_summary$pct_selfemp[gender_summary$gender == "Women"], 2), "%\n")

# Among SE, incorporation rates
se_data <- cps_complete %>% filter(multiple_jobs == 1)
inc_by_gender <- se_data %>%
  group_by(gender) %>%
  summarise(
    n_se = n(),
    pct_incorporated = mean(incorporated, na.rm = TRUE) * 100,
    .groups = "drop"
  )

cat("\nAmong self-employed, incorporation rates:\n")
print(inc_by_gender)

# ==============================================================================
# Save results
# ==============================================================================

saveRDS(gender_results, file.path(data_dir, "gender_results.rds"))
saveRDS(gender_state_df, file.path(data_dir, "gender_state_results.rds"))
saveRDS(triple_df, file.path(data_dir, "gender_educ_type_results.rds"))
saveRDS(gender_summary, file.path(data_dir, "gender_summary.rds"))

cat("\n", strrep("=", 70), "\n")
cat("GENDER ANALYSIS COMPLETE\n")
cat(strrep("=", 70), "\n")

# ==============================================================================
# Key Findings Summary
# ==============================================================================

cat("\n=== KEY GENDER FINDINGS ===\n")

cat("\n1. Aggregate SE penalty:\n")
cat("   Men:", round(gender_aggregate_results[["Men"]]$estimate, 4), "log points\n")
cat("   Women:", round(gender_aggregate_results[["Women"]]$estimate, 4), "log points\n")
cat("   Gender gap:", round(diff_gender, 4), "(p =", round(p_diff, 4), ")\n")

cat("\n2. Incorporated SE effect:\n")
cat("   Men:", round(gender_inc_results[["Men"]]$estimate, 4), "log points\n")
cat("   Women:", round(gender_inc_results[["Women"]]$estimate, 4), "log points\n")

cat("\n3. Unincorporated SE penalty:\n")
cat("   Men:", round(gender_uninc_results[["Men"]]$estimate, 4), "log points\n")
cat("   Women:", round(gender_uninc_results[["Women"]]$estimate, 4), "log points\n")

cat("\n4. Composition differences:\n")
cat("   Self-employment rates: Men =", round(gender_summary$pct_selfemp[gender_summary$gender == "Men"], 1),
    "%, Women =", round(gender_summary$pct_selfemp[gender_summary$gender == "Women"], 1), "%\n")
