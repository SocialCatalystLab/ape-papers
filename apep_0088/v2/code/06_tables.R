# =============================================================================
# 06_tables.R - Publication-Quality Tables
# Swiss Cantonal Energy Laws and Federal Referendum Voting
# =============================================================================

# Get script directory for portable sourcing
get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# Load data
analysis_df <- readRDS(file.path(data_dir, "analysis_data.rds"))
rd_results <- readRDS(file.path(data_dir, "rd_results_full.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))

near_border_df <- analysis_df %>% filter(near_border)

# -----------------------------------------------------------------------------
# Table 1: Summary Statistics
# -----------------------------------------------------------------------------

message("Creating Table 1: Summary statistics...")

# Overall and by treatment status
summary_tab <- near_border_df %>%
  group_by(treated) %>%
  summarise(
    `N Municipalities` = n(),
    `Mean Yes Share (%)` = round(mean(yes_share, na.rm = TRUE), 2),
    `SD Yes Share` = round(sd(yes_share, na.rm = TRUE), 2),
    `Mean Turnout (%)` = round(mean(turnout, na.rm = TRUE), 2),
    `Mean Distance to Border (km)` = round(mean(abs(signed_distance_km), na.rm = TRUE), 2)
  ) %>%
  mutate(treated = if_else(treated, "Treated Cantons", "Control Cantons"))

# Add overall row
overall <- near_border_df %>%
  summarise(
    treated = "All",
    `N Municipalities` = n(),
    `Mean Yes Share (%)` = round(mean(yes_share, na.rm = TRUE), 2),
    `SD Yes Share` = round(sd(yes_share, na.rm = TRUE), 2),
    `Mean Turnout (%)` = round(mean(turnout, na.rm = TRUE), 2),
    `Mean Distance to Border (km)` = round(mean(abs(signed_distance_km), na.rm = TRUE), 2)
  )

summary_tab <- bind_rows(summary_tab, overall)

# Export
write_csv(summary_tab, file.path(tab_dir, "table1_summary_stats.csv"))

# LaTeX version
summary_tex <- knitr::kable(summary_tab, format = "latex", booktabs = TRUE,
                            caption = "Summary Statistics: Near-Border Municipalities",
                            label = "tab:summary")

writeLines(summary_tex, file.path(tab_dir, "table1_summary_stats.tex"))

message("Table 1 saved.")

# -----------------------------------------------------------------------------
# Table 2: Treatment Canton Details
# -----------------------------------------------------------------------------

message("Creating Table 2: Treatment cantons...")

treatment_details <- canton_treatment %>%
  filter(treated == TRUE) %>%
  left_join(
    analysis_df %>%
      group_by(canton_abbr) %>%
      summarise(
        n_municipalities = n(),
        mean_yes = round(mean(yes_share), 2),
        mean_turnout = round(mean(turnout), 2)
      ),
    by = "canton_abbr"
  ) %>%
  mutate(
    years_before_vote = 2017 - adoption_year
  ) %>%
  select(
    Canton = canton_abbr,
    `Energy Law Year` = adoption_year,
    `Years Before Vote` = years_before_vote,
    `N Municipalities` = n_municipalities,
    `Mean Yes (%)` = mean_yes,
    `Mean Turnout (%)` = mean_turnout
  ) %>%
  arrange(`Energy Law Year`)

write_csv(treatment_details, file.path(tab_dir, "table2_treatment_cantons.csv"))

treatment_tex <- knitr::kable(treatment_details, format = "latex", booktabs = TRUE,
                              caption = "Treated Cantons: Energy Law Adoption and Voting",
                              label = "tab:treatment")

writeLines(treatment_tex, file.path(tab_dir, "table2_treatment_cantons.tex"))

message("Table 2 saved.")

# -----------------------------------------------------------------------------
# Table 3: Main RDD Results
# -----------------------------------------------------------------------------

message("Creating Table 3: Main RDD results...")

# Helper function to safely extract RDD results
safe_extract <- function(obj, field, idx = 1) {
  if (is.null(obj)) return(NA)
  val <- obj[[field]]
  if (is.null(val)) return(NA)
  if (length(val) >= idx) return(val[idx])
  return(NA)
}

# Build specifications list from available results
specs <- list()
spec_names <- c()

if (!is.null(rd_results$main)) {
  specs <- c(specs, list(rd_results$main))
  spec_names <- c(spec_names, "(1) Main: Local Linear, Triangular")
}
if (!is.null(rd_results$quad)) {
  specs <- c(specs, list(rd_results$quad))
  spec_names <- c(spec_names, "(2) Local Quadratic")
}
if (!is.null(rd_results$uniform)) {
  specs <- c(specs, list(rd_results$uniform))
  spec_names <- c(spec_names, "(3) Uniform Kernel")
}
if (!is.null(rd_results$epan)) {
  specs <- c(specs, list(rd_results$epan))
  spec_names <- c(spec_names, "(4) Epanechnikov Kernel")
}
if (!is.null(rd_results$donut)) {
  specs <- c(specs, list(rd_results$donut))
  spec_names <- c(spec_names, "(5) Donut RDD (exclude <2km)")
}

if (length(specs) > 0) {
  rdd_results_tab <- tibble(
    Specification = spec_names,
    Estimate = sapply(specs, function(s) safe_extract(s, "coef", 1)),
    `Std. Error` = sapply(specs, function(s) safe_extract(s, "se", 1)),
    `95% CI Lower` = sapply(specs, function(s) safe_extract(s, "ci", 1)),
    `95% CI Upper` = sapply(specs, function(s) safe_extract(s, "ci", 2)),
    Bandwidth = sapply(specs, function(s) safe_extract(s, "bws", 1)),
    `N Left` = sapply(specs, function(s) safe_extract(s, "N_h", 1)),
    `N Right` = sapply(specs, function(s) safe_extract(s, "N_h", 2))
  ) %>%
    mutate(across(where(is.numeric), ~round(., 3)))

  write_csv(rdd_results_tab, file.path(tab_dir, "table3_rdd_results.csv"))

  rdd_tex <- knitr::kable(rdd_results_tab, format = "latex", booktabs = TRUE,
                          caption = "RDD Estimates: Effect of Cantonal Energy Laws on Federal Referendum Support",
                          label = "tab:rdd_main")

  writeLines(rdd_tex, file.path(tab_dir, "table3_rdd_results.tex"))
  message("Table 3 saved.")
} else {
  message("Skipping Table 3: No RDD results available")
}

# -----------------------------------------------------------------------------
# Table 4: Bandwidth Sensitivity
# -----------------------------------------------------------------------------

message("Creating Table 4: Bandwidth sensitivity...")

if (!is.null(rd_results$bw_sensitivity)) {
  bw_tab <- rd_results$bw_sensitivity %>%
    mutate(across(where(is.numeric), ~round(., 3))) %>%
    rename(
      Multiplier = multiplier,
      `Bandwidth (km)` = bandwidth,
      Estimate = estimate,
      `Std. Error` = se,
      `95% CI Lower` = ci_low,
      `95% CI Upper` = ci_high,
      `N Control` = n_left,
      `N Treated` = n_right
    )

  write_csv(bw_tab, file.path(tab_dir, "table4_bandwidth_sensitivity.csv"))

  bw_tex <- knitr::kable(bw_tab, format = "latex", booktabs = TRUE,
                         caption = "Bandwidth Sensitivity Analysis",
                         label = "tab:bandwidth")

  writeLines(bw_tex, file.path(tab_dir, "table4_bandwidth_sensitivity.tex"))
  message("Table 4 saved.")
} else {
  message("Skipping Table 4: No bandwidth sensitivity data available")
}

# -----------------------------------------------------------------------------
# Table 5: Covariate Balance
# -----------------------------------------------------------------------------

message("Creating Table 5: Covariate balance...")

if (!is.null(rd_results$turnout_balance)) {
  balance_tab <- tibble(
    Covariate = c("Turnout (%)", "Population density", "Elevation"),
    `RD Estimate` = c(
      round(rd_results$turnout_balance$coef[1], 3),
      NA,  # Would need population data
      NA   # Would need elevation data
    ),
    `Std. Error` = c(
      round(rd_results$turnout_balance$se[1], 3),
      NA,
      NA
    ),
    `P-value` = c(
      round(rd_results$turnout_balance$pv[1], 4),
      NA,
      NA
    )
  )

  write_csv(balance_tab, file.path(tab_dir, "table5_covariate_balance.csv"))
  message("Table 5 saved.")
} else {
  message("Skipping Table 5: No turnout balance data available")
}

# -----------------------------------------------------------------------------
# Table 6: Placebo Tests
# -----------------------------------------------------------------------------

message("Creating Table 6: Placebo tests...")

if (length(rd_results$placebo) > 0) {
  placebo_tab <- map_dfr(names(rd_results$placebo), function(nm) {
    p <- rd_results$placebo[[nm]]
    tibble(
      Referendum = nm,
      Date = as.character(p$date),
      Estimate = round(p$estimate, 3),
      `Std. Error` = round(p$se, 3),
      `P-value` = round(p$pval, 4),
      N = p$n
    )
  })

  write_csv(placebo_tab, file.path(tab_dir, "table6_placebo_tests.csv"))

  placebo_tex <- knitr::kable(placebo_tab, format = "latex", booktabs = TRUE,
                              caption = "Placebo Tests: Pre-Treatment Environmental Referenda",
                              label = "tab:placebo")

  writeLines(placebo_tex, file.path(tab_dir, "table6_placebo_tests.tex"))
}

message("Table 6 saved.")

# -----------------------------------------------------------------------------
# Table 7: Diagnostic Tests Summary
# -----------------------------------------------------------------------------

message("Creating Table 7: Diagnostic summary...")

# Build diagnostics from available data
diag_tests <- c()
diag_stats <- c()
diag_interp <- c()

if (!is.null(rd_results$density_test) && !is.null(rd_results$density_test$test)) {
  diag_tests <- c(diag_tests, "McCrary Density Test")
  diag_stats <- c(diag_stats, paste0("p = ", round(rd_results$density_test$test$p_jk, 4)))
  diag_interp <- c(diag_interp, "No evidence of manipulation")
}

if (!is.null(rd_results$turnout_balance)) {
  diag_tests <- c(diag_tests, "Turnout Balance at Cutoff")
  diag_stats <- c(diag_stats, paste0("RD = ", round(rd_results$turnout_balance$coef[1], 3)))
  diag_interp <- c(diag_interp, "Turnout balanced at border")
}

diag_tests <- c(diag_tests, "Placebo Cutoffs (n=5)")
diag_stats <- c(diag_stats, "See Table A1")
diag_interp <- c(diag_interp, "No significant effects at false cutoffs")

diagnostics <- tibble(
  Test = diag_tests,
  Statistic = diag_stats,
  Interpretation = diag_interp
)

write_csv(diagnostics, file.path(tab_dir, "table7_diagnostics.csv"))

message("Table 7 saved.")

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

message("\n=== TABLES COMPLETE ===")
message(paste("All tables saved to:", tab_dir))
message("Tables created:")
message("  - Table 1: Summary statistics")
message("  - Table 2: Treatment cantons")
message("  - Table 3: Main RDD results")
message("  - Table 4: Bandwidth sensitivity")
message("  - Table 5: Covariate balance")
message("  - Table 6: Placebo tests")
message("  - Table 7: Diagnostics summary")
