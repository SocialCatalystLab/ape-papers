# ============================================================================
# 06_tables.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Table generation
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("\n=== Loading data for tables ===\n")

analysis_2023 <- read_csv("../data/processed/analysis_2023.csv", show_col_types = FALSE)
analysis_panel <- read_csv("../data/processed/analysis_panel.csv", show_col_types = FALSE)
schools <- read_csv("../data/processed/schools_clean.csv", show_col_types = FALSE)

# ============================================================================
# TABLE 1: Summary Statistics
# ============================================================================

cat("\n=== Table 1: Summary Statistics ===\n")

# Panel A: Municipality-level outcomes
panel_a <- analysis_2023 |>
  summarise(
    across(
      c(merit_all, merit_municipal, merit_friskola, salsa_deviation,
        school_access_2km, teachers_qualified, student_teacher_ratio),
      list(
        mean = ~mean(.x, na.rm = TRUE),
        sd = ~sd(.x, na.rm = TRUE),
        min = ~min(.x, na.rm = TRUE),
        max = ~max(.x, na.rm = TRUE),
        n = ~sum(!is.na(.x))
      )
    )
  ) |>
  pivot_longer(everything()) |>
  separate(name, into = c("variable", "statistic"), sep = "_(?=[^_]+$)") |>
  pivot_wider(names_from = statistic, values_from = value) |>
  mutate(
    variable = case_when(
      variable == "merit_all" ~ "Merit Points (All Schools)",
      variable == "merit_municipal" ~ "Merit Points (Municipal)",
      variable == "merit_friskola" ~ "Merit Points (Friskola)",
      variable == "salsa_deviation" ~ "SALSA Deviation (%)",
      variable == "school_access_2km" ~ "School Accessibility (%)",
      variable == "teachers_qualified" ~ "Qualified Teachers (%)",
      variable == "student_teacher" ~ "Student-Teacher Ratio"
    )
  )

# Panel B: School characteristics
panel_b <- schools |>
  summarise(
    n_schools = n(),
    n_municipal = sum(school_type == "Municipal"),
    n_friskola = sum(school_type == "Private (friskola)"),
    pct_municipal = mean(school_type == "Municipal") * 100,
    pct_friskola = mean(school_type == "Private (friskola)") * 100,
    n_with_coords = sum(!coord_suspicious),
    pct_with_coords = mean(!coord_suspicious) * 100
  )

# Save as CSV
write_csv(panel_a, "../tables/table1_summary_outcomes.csv")
write_csv(panel_b, "../tables/table1_summary_schools.csv")

cat("  Table 1 saved\n")

# ============================================================================
# TABLE 2: Balance at Threshold
# ============================================================================

cat("\n=== Table 2: Balance Test ===\n")

# Compare municipalities above vs below threshold
balance_data <- analysis_2023 |>
  mutate(below_threshold = running_var < 0) |>
  group_by(below_threshold) |>
  summarise(
    n = n(),
    merit_all = mean(merit_all, na.rm = TRUE),
    merit_municipal = mean(merit_municipal, na.rm = TRUE),
    teachers_qualified = mean(teachers_qualified, na.rm = TRUE),
    student_teacher_ratio = mean(student_teacher_ratio, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(group = ifelse(below_threshold, "Below Threshold (Treatment)", "Above Threshold (Control)"))

# T-tests for balance
balance_tests <- analysis_2023 |>
  mutate(below_threshold = running_var < 0)

ttest_results <- tribble(
  ~variable, ~t_stat, ~p_value,
  "Teachers Qualified",
    t.test(teachers_qualified ~ below_threshold, data = balance_tests)$statistic,
    t.test(teachers_qualified ~ below_threshold, data = balance_tests)$p.value,
  "Student-Teacher Ratio",
    t.test(student_teacher_ratio ~ below_threshold, data = balance_tests)$statistic,
    t.test(student_teacher_ratio ~ below_threshold, data = balance_tests)$p.value
)

write_csv(balance_data, "../tables/table2_balance.csv")
write_csv(ttest_results, "../tables/table2_balance_tests.csv")

cat("  Table 2 saved\n")

# ============================================================================
# TABLE 3: Main RDD Results
# ============================================================================

cat("\n=== Table 3: Main Results ===\n")

# Load main results
main_results_file <- "../tables/rdd_main_results.csv"
if (file.exists(main_results_file)) {
  main_results <- read_csv(main_results_file, show_col_types = FALSE)

  # Format for publication
  main_results_formatted <- main_results |>
    mutate(
      estimate_se = sprintf("%.2f (%.2f)", estimate, se),
      ci = sprintf("[%.2f, %.2f]", ci_lower, ci_upper),
      stars = case_when(
        p_value < 0.01 ~ "***",
        p_value < 0.05 ~ "**",
        p_value < 0.10 ~ "*",
        TRUE ~ ""
      ),
      n_effective = paste(n_left, "+", n_right)
    ) |>
    select(outcome, estimate_se, ci, stars, bandwidth, n_effective)

  write_csv(main_results_formatted, "../tables/table3_main_results.csv")
  cat("  Table 3 saved\n")
} else {
  cat("  Table 3 skipped (no main results)\n")
}

# ============================================================================
# TABLE 4: Robustness - Bandwidth Sensitivity
# ============================================================================

cat("\n=== Table 4: Bandwidth Sensitivity ===\n")

bw_file <- "../tables/robustness_bandwidth.csv"
if (file.exists(bw_file)) {
  bw_results <- read_csv(bw_file, show_col_types = FALSE)

  bw_formatted <- bw_results |>
    mutate(
      estimate_se = sprintf("%.2f (%.2f)", estimate, se),
      stars = case_when(
        p_value < 0.01 ~ "***",
        p_value < 0.05 ~ "**",
        p_value < 0.10 ~ "*",
        TRUE ~ ""
      )
    ) |>
    select(bandwidth_multiplier, bandwidth, estimate_se, stars, n_left, n_right)

  write_csv(bw_formatted, "../tables/table4_bandwidth.csv")
  cat("  Table 4 saved\n")
} else {
  cat("  Table 4 skipped\n")
}

# ============================================================================
# TABLE 5: Placebo Tests
# ============================================================================

cat("\n=== Table 5: Placebo Tests ===\n")

placebo_file <- "../tables/robustness_placebo.csv"
if (file.exists(placebo_file)) {
  placebo_results <- read_csv(placebo_file, show_col_types = FALSE)

  placebo_formatted <- placebo_results |>
    mutate(
      estimate_se = sprintf("%.2f (%.2f)", estimate, se),
      stars = case_when(
        p_value < 0.01 ~ "***",
        p_value < 0.05 ~ "**",
        p_value < 0.10 ~ "*",
        TRUE ~ ""
      )
    ) |>
    select(placebo_cutoff, estimate_se, stars, p_value)

  write_csv(placebo_formatted, "../tables/table5_placebo.csv")
  cat("  Table 5 saved\n")
} else {
  cat("  Table 5 skipped\n")
}

# ============================================================================
# TABLE 6: Heterogeneity by Municipality Type
# ============================================================================

cat("\n=== Table 6: Heterogeneity ===\n")

hetero_file <- "../tables/robustness_heterogeneity.csv"
if (file.exists(hetero_file)) {
  hetero_results <- read_csv(hetero_file, show_col_types = FALSE)

  hetero_formatted <- hetero_results |>
    mutate(
      estimate_se = sprintf("%.2f (%.2f)", estimate, se),
      stars = case_when(
        p_value < 0.01 ~ "***",
        p_value < 0.05 ~ "**",
        p_value < 0.10 ~ "*",
        TRUE ~ ""
      )
    ) |>
    select(urban_type, n, estimate_se, stars, p_value)

  write_csv(hetero_formatted, "../tables/table6_heterogeneity.csv")
  cat("  Table 6 saved\n")
} else {
  cat("  Table 6 skipped\n")
}

# ============================================================================
# TABLE A1: Skolskjuts Thresholds by Municipality
# ============================================================================

cat("\n=== Table A1: Threshold Data ===\n")

thresholds <- read_csv("../data/processed/skolskjuts_thresholds.csv", show_col_types = FALSE)
write_csv(thresholds, "../tables/tableA1_thresholds.csv")
cat("  Table A1 saved\n")

# ============================================================================
# TABLE A2: Data Sources
# ============================================================================

cat("\n=== Table A2: Data Sources ===\n")

data_sources <- tribble(
  ~source, ~description, ~variables, ~years, ~url,
  "Kolada", "Municipal KPI database", "Merit points, school accessibility, teacher qualifications", "2015-2024", "api.kolada.se",
  "SCB Open Geodata", "Geographic boundaries", "DeSO, municipality boundaries", "2018-2025", "geodata.scb.se",
  "Skolenhetsregistret", "School unit registry", "School locations, types, grade levels", "2024", "api.skolverket.se",
  "Municipal websites", "Policy documentation", "Skolskjuts distance thresholds", "2024", "Various"
)

write_csv(data_sources, "../tables/tableA2_data_sources.csv")
cat("  Table A2 saved\n")

# ============================================================================
# GENERATE LATEX TABLES
# ============================================================================

cat("\n=== Generating LaTeX tables ===\n")

# Table 1: Summary Statistics (LaTeX)
if (exists("panel_a")) {
  latex_table1 <- panel_a |>
    mutate(
      mean = sprintf("%.2f", mean),
      sd = sprintf("%.2f", sd),
      min = sprintf("%.2f", min),
      max = sprintf("%.2f", max),
      n = sprintf("%.0f", n)
    ) |>
    kbl(
      format = "latex",
      booktabs = TRUE,
      col.names = c("Variable", "Mean", "SD", "Min", "Max", "N"),
      caption = "Summary Statistics: Municipality-Level Outcomes (2023)",
      label = "tab:summary"
    ) |>
    kable_styling(latex_options = c("hold_position"))

  writeLines(latex_table1, "../tables/table1_summary.tex")
  cat("  table1_summary.tex saved\n")
}

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n=== Tables generated ===\n")
table_files <- list.files("../tables", pattern = "\\.(csv|tex)$", full.names = FALSE)
for (f in table_files) {
  cat("  ", f, "\n")
}

cat("\nTable generation complete.\n")
