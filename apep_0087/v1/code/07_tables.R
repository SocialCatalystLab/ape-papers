# =============================================================================
# Paper 110: The Price of Distance
# 07_tables.R - Generate all tables for the paper
# =============================================================================

source(here::here("output/paper_110/code/00_packages.R"))

# =============================================================================
# Load Data
# =============================================================================

analysis_data <- readRDS(file.path(data_dir, "analysis_data.rds"))

# Load results if available
results_file <- file.path(data_dir, "regression_results.rds")
if (file.exists(results_file)) {
  results <- readRDS(results_file)
}

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

message("Creating Table 1: Summary Statistics...")

# Panel A: Crashes by State Type
panel_a <- analysis_data %>%
  group_by(legal_state) %>%
  summarize(
    `Total Crashes` = n(),
    `Alcohol-Involved (%)` = mean(alcohol_involved, na.rm = TRUE) * 100,
    `Mean Drive Time (min)` = mean(drive_time_min, na.rm = TRUE),
    `Median Drive Time (min)` = median(drive_time_min, na.rm = TRUE),
    `Geocoded (%)` = mean(has_coords, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(State_Type = ifelse(legal_state, "Legal States", "Illegal States")) %>%
  select(State_Type, everything(), -legal_state)

# Panel B: By State
panel_b <- analysis_data %>%
  filter(!legal_state) %>%  # Focus on illegal states (our sample)
  group_by(state_abbr) %>%
  summarize(
    N = n(),
    `Alcohol (%)` = round(mean(alcohol_involved, na.rm = TRUE) * 100, 1),
    `Mean Drive (min)` = round(mean(drive_time_min, na.rm = TRUE), 0),
    `Nearest Legal` = first(na.omit(nearest_disp_state)),
    .groups = "drop"
  ) %>%
  arrange(desc(N))

# Panel C: By Year
panel_c <- analysis_data %>%
  filter(!legal_state) %>%
  group_by(year) %>%
  summarize(
    N = n(),
    `Alcohol (%)` = round(mean(alcohol_involved, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )

# Write to CSV for LaTeX
fwrite(panel_a, file.path(tab_dir, "tab1_panel_a.csv"))
fwrite(panel_b, file.path(tab_dir, "tab1_panel_b.csv"))
fwrite(panel_c, file.path(tab_dir, "tab1_panel_c.csv"))

message("  Saved table 1 panels to CSV")

# =============================================================================
# Table 2: Main Regression Results
# =============================================================================

if (exists("results") && !is.null(results$main)) {
  message("Creating Table 2: Main Results...")

  # Create modelsummary table
  main_table <- modelsummary(
    results$main,
    output = "latex",
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    coef_map = c(
      "log(drive_time_min)" = "log(Drive Time)",
      "I(drive_time_min^2)" = "Drive Time²"
    ),
    gof_map = c(
      "nobs" = "Observations",
      "r.squared" = "R²",
      "FE: state_abbr" = "State FE",
      "FE: year" = "Year FE",
      "FE: year_month" = "Year-Month FE"
    ),
    title = "Effect of Drive Time to Dispensary on Alcohol-Involved Fatal Crashes",
    notes = "Standard errors clustered at state level in parentheses."
  )

  # Save as .tex file
  writeLines(main_table, file.path(tab_dir, "tab2_main_results.tex"))
  message("  Saved tab2_main_results.tex")

  # Also save as CSV for easy reading
  main_coefs <- map_dfr(names(results$main), function(nm) {
    mod <- results$main[[nm]]
    tidy_mod <- broom::tidy(mod, conf.int = TRUE)
    tidy_mod$model <- nm
    tidy_mod
  }) %>%
    filter(grepl("drive_time", term))

  fwrite(main_coefs, file.path(tab_dir, "tab2_coefficients.csv"))
}

# =============================================================================
# Table 3: Placebo Tests
# =============================================================================

message("Creating Table 3: Placebo Tests...")

if (exists("results")) {
  placebo_models <- list()

  if (!is.null(results$placebo_pre)) {
    placebo_models[["Pre-Period (2012-13)"]] <- results$placebo_pre
  }

  if (!is.null(results$placebo_non_alcohol)) {
    placebo_models[["Non-Alcohol Crashes"]] <- results$placebo_non_alcohol
  }

  if (length(placebo_models) > 0) {
    placebo_table <- modelsummary(
      placebo_models,
      output = "latex",
      stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
      title = "Placebo Tests: Pre-Period and Non-Alcohol Crashes",
      notes = "Coefficients should be near zero if identification is valid."
    )

    writeLines(placebo_table, file.path(tab_dir, "tab3_placebo.tex"))
    message("  Saved tab3_placebo.tex")
  }
}

# =============================================================================
# Table 4: Heterogeneity Results
# =============================================================================

message("Creating Table 4: Heterogeneity...")

if (exists("results") && !is.null(results$hetero_distance)) {
  hetero_table <- modelsummary(
    results$hetero_distance,
    output = "latex",
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    title = "Heterogeneity by Distance to Legal State Border",
    notes = "Effects should be stronger closer to border where cross-border purchasing is feasible."
  )

  writeLines(hetero_table, file.path(tab_dir, "tab4_heterogeneity.tex"))
  message("  Saved tab4_heterogeneity.tex")
}

# =============================================================================
# Table 5: Robustness - Alternative Specifications
# =============================================================================

message("Creating Table 5: Robustness...")

# Will be populated during robustness analysis
# For now, create placeholder structure

robustness_notes <- "
Table 5: Robustness Checks

To be added:
1. Poisson regression (count outcome)
2. County-level aggregation
3. Conley spatial HAC standard errors
4. Wild cluster bootstrap
5. Different drive time thresholds
6. Event study by border pair
"

writeLines(robustness_notes, file.path(tab_dir, "tab5_robustness_notes.txt"))

# =============================================================================
# Summary
# =============================================================================

message("\n=== Tables Complete ===")
message("Saved to: ", tab_dir)
list.files(tab_dir)
