# ==============================================================================
# 07_state_analysis.R
# State-by-State Analysis: The Atlas of Self-Employment in America
# Revision of apep_0173
# ==============================================================================

source("00_packages.R")

# Load analysis data
cps <- readRDS(file.path(data_dir, "cps_analysis.rds"))

cat("Loaded", nrow(cps), "observations for state analysis.\n")

# ==============================================================================
# Prepare data for state analysis
# ==============================================================================

# State FIPS codes and names for 10 sample states
state_info <- tibble(
  state_fips = c("06", "48", "12", "36", "17", "39", "42", "13", "37", "26"),
  state_name = c("California", "Texas", "Florida", "New York", "Illinois",
                 "Ohio", "Pennsylvania", "Georgia", "North Carolina", "Michigan"),
  state_abbr = c("CA", "TX", "FL", "NY", "IL", "OH", "PA", "GA", "NC", "MI"),
  region = c("West", "South", "South", "Northeast", "Midwest",
             "Midwest", "Northeast", "South", "South", "Midwest")
)

# Standardize state codes (remove leading zeros for matching)
state_info <- state_info %>%
  mutate(state = as.character(as.integer(state_fips)))

cps_complete <- cps %>%
  filter(
    !is.na(multiple_jobs),
    !is.na(age),
    !is.na(female),
    !is.na(college),
    !is.na(married),
    !is.na(homeowner),
    !is.na(log_earnings),
    !is.na(state)
  ) %>%
  mutate(
    # Standardize state codes
    state = as.character(as.integer(state)),
    race_white = as.integer(race == "White"),
    race_black = as.integer(race == "Black"),
    race_hispanic = as.integer(race == "Hispanic"),
    race_asian = as.integer(race == "Asian"),
    age_sq = age^2
  ) %>%
  # Keep only states in our sample
  filter(state %in% state_info$state)

cat("Complete cases:", nrow(cps_complete), "\n")
cat("States in data:", length(unique(cps_complete$state)), "\n")

# Define covariates (without state - estimating within state)
covariates <- c(
  "age", "age_sq", "female", "college", "married",
  "race_white", "race_black", "race_hispanic", "race_asian",
  "homeowner", "covid_period"
)

# ==============================================================================
# Helper function for state-level IPW estimation
# ==============================================================================

estimate_state_effect <- function(data, treatment_var = "multiple_jobs",
                                  outcome_var = "log_earnings") {

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
# PART 1: State-Level Aggregate Self-Employment Effects
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 1: STATE-LEVEL AGGREGATE SELF-EMPLOYMENT EFFECTS\n")
cat(strrep("=", 70), "\n")

state_aggregate_results <- list()

for (st in state_info$state) {
  state_data <- cps_complete %>% filter(state == st)
  st_info <- state_info %>% filter(state == st)
  state_name_val <- st_info$state_name[1]
  state_abbr_val <- st_info$state_abbr[1]

  cat("\n--- State:", state_name_val, "(", st, ") ---\n")
  cat("N =", nrow(state_data), "\n")

  if (nrow(state_data) < 1000) {
    cat("Insufficient sample size.\n")
    next
  }

  result <- estimate_state_effect(state_data)
  result$state <- st
  result$state_name <- state_name_val
  result$state_abbr <- state_abbr_val
  result$type <- "Aggregate"

  state_aggregate_results[[st]] <- result

  if (result$converged) {
    cat("Estimate:", round(result$estimate, 4),
        "[95% CI:", round(result$ci_lower, 4), ",", round(result$ci_upper, 4), "]\n")
  } else {
    cat("Estimation failed or insufficient sample\n")
  }
}

state_aggregate_df <- bind_rows(state_aggregate_results)

# ==============================================================================
# PART 2: State-Level Incorporated Effects
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 2: STATE-LEVEL INCORPORATED SELF-EMPLOYMENT EFFECTS\n")
cat(strrep("=", 70), "\n")

state_inc_results <- list()

for (st in state_info$state) {
  # Filter to wage workers and incorporated only
  state_data <- cps_complete %>%
    filter(state == st) %>%
    filter(multiple_jobs == 0 | incorporated == 1) %>%
    mutate(treatment = incorporated)

  st_info <- state_info %>% filter(state == st)
  state_name_val <- st_info$state_name[1]
  state_abbr_val <- st_info$state_abbr[1]

  cat("\n--- State:", state_name_val, "(Incorporated) ---\n")
  cat("N =", nrow(state_data), ", N incorporated =", sum(state_data$treatment), "\n")

  result <- estimate_state_effect(state_data, treatment_var = "treatment")
  result$state <- st
  result$state_name <- state_name_val
  result$state_abbr <- state_abbr_val
  result$type <- "Incorporated"

  state_inc_results[[st]] <- result

  if (result$converged) {
    cat("Estimate:", round(result$estimate, 4),
        "[95% CI:", round(result$ci_lower, 4), ",", round(result$ci_upper, 4), "]\n")
  }
}

state_inc_df <- bind_rows(state_inc_results)

# ==============================================================================
# PART 3: State-Level Unincorporated Effects
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 3: STATE-LEVEL UNINCORPORATED SELF-EMPLOYMENT EFFECTS\n")
cat(strrep("=", 70), "\n")

state_uninc_results <- list()

for (st in state_info$state) {
  # Filter to wage workers and unincorporated only
  state_data <- cps_complete %>%
    filter(state == st) %>%
    filter(multiple_jobs == 0 | unincorporated == 1) %>%
    mutate(treatment = unincorporated)

  st_info <- state_info %>% filter(state == st)
  state_name_val <- st_info$state_name[1]
  state_abbr_val <- st_info$state_abbr[1]

  cat("\n--- State:", state_name_val, "(Unincorporated) ---\n")
  cat("N =", nrow(state_data), ", N unincorporated =", sum(state_data$treatment), "\n")

  result <- estimate_state_effect(state_data, treatment_var = "treatment")
  result$state <- st
  result$state_name <- state_name_val
  result$state_abbr <- state_abbr_val
  result$type <- "Unincorporated"

  state_uninc_results[[st]] <- result

  if (result$converged) {
    cat("Estimate:", round(result$estimate, 4),
        "[95% CI:", round(result$ci_lower, 4), ",", round(result$ci_upper, 4), "]\n")
  }
}

state_uninc_df <- bind_rows(state_uninc_results)

# ==============================================================================
# Combine all state results
# ==============================================================================

state_results <- bind_rows(
  state_aggregate_df,
  state_inc_df,
  state_uninc_df
)

# ==============================================================================
# Summary Table
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("STATE-LEVEL RESULTS SUMMARY\n")
cat(strrep("=", 70), "\n")

summary_table <- state_results %>%
  filter(converged) %>%
  select(state_name, state_abbr, type, estimate, ci_lower, ci_upper, n_treated) %>%
  pivot_wider(
    names_from = type,
    values_from = c(estimate, ci_lower, ci_upper, n_treated),
    names_glue = "{type}_{.value}"
  ) %>%
  arrange(desc(Aggregate_estimate))

cat("\nOrdered by aggregate SE penalty (least to most severe):\n")
print(summary_table %>% select(state_name, Aggregate_estimate, Incorporated_estimate, Unincorporated_estimate))

# ==============================================================================
# Save results
# ==============================================================================

saveRDS(state_results, file.path(data_dir, "state_results.rds"))
saveRDS(summary_table, file.path(data_dir, "state_summary_table.rds"))

cat("\n", strrep("=", 70), "\n")
cat("STATE ANALYSIS COMPLETE\n")
cat(strrep("=", 70), "\n")

# Print key findings
cat("\n=== KEY STATE-LEVEL FINDINGS ===\n")

agg_range <- state_aggregate_df %>% filter(converged) %>% summarise(
  min_est = min(estimate, na.rm = TRUE),
  max_est = max(estimate, na.rm = TRUE),
  min_state = state_name[which.min(estimate)],
  max_state = state_name[which.max(estimate)]
)

cat("\n1. Aggregate SE penalty ranges from",
    round(agg_range$max_est, 3), "(", agg_range$max_state, ") to",
    round(agg_range$min_est, 3), "(", agg_range$min_state, ")\n")

inc_range <- state_inc_df %>% filter(converged) %>% summarise(
  min_est = min(estimate, na.rm = TRUE),
  max_est = max(estimate, na.rm = TRUE),
  min_state = state_name[which.min(estimate)],
  max_state = state_name[which.max(estimate)]
)

cat("\n2. Incorporated effect ranges from",
    round(inc_range$min_est, 3), "(", inc_range$min_state, ") to",
    round(inc_range$max_est, 3), "(", inc_range$max_state, ")\n")

uninc_range <- state_uninc_df %>% filter(converged) %>% summarise(
  min_est = min(estimate, na.rm = TRUE),
  max_est = max(estimate, na.rm = TRUE),
  min_state = state_name[which.min(estimate)],
  max_state = state_name[which.max(estimate)]
)

cat("\n3. Unincorporated penalty ranges from",
    round(uninc_range$max_est, 3), "(", uninc_range$max_state, ") to",
    round(uninc_range$min_est, 3), "(", uninc_range$min_state, ")\n")
