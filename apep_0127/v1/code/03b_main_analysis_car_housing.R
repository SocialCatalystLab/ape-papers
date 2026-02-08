# ============================================================================
# 03b_main_analysis_car_housing.R
# Car Ownership, Housing Tenure, and Educational Achievement in Sweden
# Main regression analysis
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("\n=== Loading merged data ===\n")

analysis_data <- read_csv("../data/processed/analysis_merged.csv", show_col_types = FALSE)
cat("  Observations:", nrow(analysis_data), "\n")
cat("  Municipalities:", n_distinct(analysis_data$municipality_id), "\n")
cat("  Years:", paste(unique(analysis_data$year), collapse = ", "), "\n")

# ============================================================================
# 2. SUMMARY STATISTICS
# ============================================================================

cat("\n=== Summary Statistics ===\n")

# Key variables summary
summary_stats <- analysis_data |>
  filter(year == 2015) |>
  summarise(
    across(
      c(merit_excl_new, cars_per_1000, rental_housing_pct, owner_housing_pct,
        coop_housing_pct, teachers_qualified, student_teacher_ratio),
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
      variable == "merit_excl" ~ "Merit Points (excl. new arrivals)",
      variable == "cars_per" ~ "Cars per 1000 inhabitants",
      variable == "rental_housing" ~ "Rental housing (%)",
      variable == "owner_housing" ~ "Owner-occupied (%)",
      variable == "coop_housing" ~ "Cooperative housing (%)",
      variable == "teachers" ~ "Teachers with qualification (%)",
      variable == "student_teacher" ~ "Student-teacher ratio",
      TRUE ~ variable
    )
  )

cat("\nSummary Statistics (2015):\n")
print(summary_stats)

write_csv(summary_stats, "../tables/table1_summary_stats.csv")

# ============================================================================
# 3. CORRELATION ANALYSIS
# ============================================================================

cat("\n=== Correlation Analysis ===\n")

# Select numeric variables for correlation
cor_vars <- analysis_data |>
  filter(year == 2015) |>
  select(merit_excl_new, cars_per_1000, rental_housing_pct, owner_housing_pct,
         coop_housing_pct, teachers_qualified)

# Correlation matrix
cor_matrix <- cor(cor_vars, use = "pairwise.complete.obs")

cat("\nCorrelation Matrix:\n")
print(round(cor_matrix, 3))

# Save correlation matrix
write.csv(cor_matrix, "../tables/table2_correlations.csv")

# ============================================================================
# 4. REGRESSION ANALYSIS
# ============================================================================

cat("\n=== Regression Analysis ===\n")

# Model 1: Bivariate - car ownership only
model1 <- lm(merit_excl_new ~ cars_per_1000, data = analysis_data)

# Model 2: Add housing tenure
model2 <- lm(merit_excl_new ~ cars_per_1000 + rental_housing_pct, data = analysis_data)

# Model 3: Add teacher qualifications
model3 <- lm(merit_excl_new ~ cars_per_1000 + rental_housing_pct + teachers_qualified,
             data = analysis_data)

# Model 4: Add county fixed effects
model4 <- lm(merit_excl_new ~ cars_per_1000 + rental_housing_pct + teachers_qualified +
             factor(county_code),
             data = analysis_data)

# Model 5: Full model with year FE
model5 <- lm(merit_excl_new ~ cars_per_1000 + rental_housing_pct + teachers_qualified +
             factor(county_code) + factor(year),
             data = analysis_data)

cat("\n=== Model 1: Bivariate (Car ownership) ===\n")
print(summary(model1))

cat("\n=== Model 2: + Housing tenure ===\n")
print(summary(model2))

cat("\n=== Model 3: + Teacher qualifications ===\n")
print(summary(model3))

cat("\n=== Model 4: + County FE ===\n")
# Print just coefficients of interest
coef4 <- summary(model4)$coefficients
print(coef4[1:4, ])

cat("\n=== Model 5: Full model ===\n")
coef5 <- summary(model5)$coefficients
print(coef5[1:4, ])

# ============================================================================
# 5. CREATE REGRESSION TABLE
# ============================================================================

cat("\n=== Creating regression table ===\n")

# Simpler approach: create table directly
reg_table <- tibble(
  model = c("(1) Bivariate", "(2) + Housing", "(3) + Teachers", "(4) + County FE", "(5) Full"),
  n = c(length(model1$residuals), length(model2$residuals), length(model3$residuals),
        length(model4$residuals), length(model5$residuals)),
  r_squared = c(summary(model1)$r.squared, summary(model2)$r.squared, summary(model3)$r.squared,
                summary(model4)$r.squared, summary(model5)$r.squared),
  car_coef = c(coef(model1)["cars_per_1000"], coef(model2)["cars_per_1000"],
               coef(model3)["cars_per_1000"], coef(model4)["cars_per_1000"],
               coef(model5)["cars_per_1000"]),
  rental_coef = c(NA, coef(model2)["rental_housing_pct"], coef(model3)["rental_housing_pct"],
                  coef(model4)["rental_housing_pct"], coef(model5)["rental_housing_pct"]),
  teacher_coef = c(NA, NA, coef(model3)["teachers_qualified"],
                   coef(model4)["teachers_qualified"], coef(model5)["teachers_qualified"])
)

cat("\nRegression Results Summary:\n")
print(reg_table)

write_csv(reg_table, "../tables/table3_regression.csv")

# ============================================================================
# 6. HETEROGENEITY ANALYSIS
# ============================================================================

cat("\n=== Heterogeneity Analysis ===\n")

# By car ownership tercile
cat("\nMerit points by car ownership tercile:\n")
analysis_data |>
  filter(year == 2015) |>
  group_by(car_ownership_tercile) |>
  summarise(
    n = n(),
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    sd_merit = sd(merit_excl_new, na.rm = TRUE),
    mean_cars = mean(cars_per_1000, na.rm = TRUE),
    .groups = "drop"
  ) |>
  print()

# By housing dominant type
cat("\nMerit points by housing type:\n")
analysis_data |>
  filter(year == 2015) |>
  group_by(housing_dominant) |>
  summarise(
    n = n(),
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    sd_merit = sd(merit_excl_new, na.rm = TRUE),
    mean_rental = mean(rental_housing_pct, na.rm = TRUE),
    .groups = "drop"
  ) |>
  print()

# By urban proxy
cat("\nMerit points by urbanity (car-based proxy):\n")
analysis_data |>
  filter(year == 2015) |>
  group_by(urban_proxy) |>
  summarise(
    n = n(),
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    mean_cars = mean(cars_per_1000, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(mean_cars) |>
  print()

# ============================================================================
# 7. COUNTY-LEVEL ANALYSIS
# ============================================================================

cat("\n=== County-Level Analysis ===\n")

county_summary <- analysis_data |>
  filter(year == 2015) |>
  group_by(county_name) |>
  summarise(
    n_municipalities = n(),
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    mean_cars = mean(cars_per_1000, na.rm = TRUE),
    mean_rental = mean(rental_housing_pct, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(mean_merit))

cat("\nCounty summary (top 10 by merit):\n")
print(county_summary |> head(10))

write_csv(county_summary, "../tables/county_summary.csv")

# ============================================================================
# 8. SAVE RESULTS
# ============================================================================

cat("\n=== Analysis Complete ===\n")

# Save analysis dataset with predictions
analysis_data <- analysis_data |>
  mutate(
    predicted_merit = predict(model3, newdata = analysis_data),
    residual_merit = merit_excl_new - predicted_merit
  )

write_csv(analysis_data, "../data/processed/analysis_with_predictions.csv")

cat("Results saved to ../tables/\n")
cat("Analysis data with predictions saved.\n")
