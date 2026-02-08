# =============================================================================
# Paper 110: The Price of Distance
# 05_main_analysis.R - Main regression analysis
# =============================================================================

source(here::here("output/paper_110/code/00_packages.R"))

# =============================================================================
# 1. Load Analysis Data
# =============================================================================

analysis_data <- readRDS(file.path(data_dir, "analysis_data.rds"))
message("Loaded ", nrow(analysis_data), " crashes for analysis")

# =============================================================================
# 2. Main Specification: Alcohol Crashes ~ Drive Time
# =============================================================================

# Filter to crashes with valid drive time
analysis_clean <- analysis_data %>%
  filter(
    !is.na(drive_time_min),
    !is.na(alcohol_involved),
    drive_time_min > 0,
    drive_time_min < 600  # Exclude unreasonable values (>10 hours)
  )

message("Clean sample: ", nrow(analysis_clean), " crashes")

# -----------------------------------------------------------------------------
# Model 1: Simple OLS with state and year FE
# -----------------------------------------------------------------------------

model_1 <- feols(
  alcohol_involved ~ log(drive_time_min) |
    state_abbr + year,
  data = analysis_clean,
  cluster = ~state_abbr
)

# -----------------------------------------------------------------------------
# Model 2: Add year-month FE for finer temporal controls
# -----------------------------------------------------------------------------

model_2 <- feols(
  alcohol_involved ~ log(drive_time_min) |
    state_abbr + year_month,
  data = analysis_clean,
  cluster = ~state_abbr
)

# -----------------------------------------------------------------------------
# Model 3: Add distance to state border as control
# (would need to compute this - placeholder for now)
# -----------------------------------------------------------------------------

model_3 <- feols(
  alcohol_involved ~ log(drive_time_min) + I(drive_time_min^2) |
    state_abbr + year,
  data = analysis_clean,
  cluster = ~state_abbr
)

# -----------------------------------------------------------------------------
# Model 4: Restrict to border regions (within 200km of legal state)
# -----------------------------------------------------------------------------

border_sample <- analysis_clean %>%
  filter(dist_to_disp_km <= 200)

model_4 <- feols(
  alcohol_involved ~ log(drive_time_min) |
    state_abbr + year,
  data = border_sample,
  cluster = ~state_abbr
)

# =============================================================================
# 3. Results Table
# =============================================================================

main_results <- list(
  "Full Sample" = model_1,
  "Year-Month FE" = model_2,
  "Quadratic" = model_3,
  "Border Only" = model_4
)

# Print results
etable(main_results,
       se.below = TRUE,
       digits = 4,
       signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1))

# Save coefficients
main_coefs <- map_dfr(names(main_results), function(nm) {
  mod <- main_results[[nm]]
  tidy_mod <- broom::tidy(mod, conf.int = TRUE)
  tidy_mod$model <- nm
  tidy_mod
}) %>%
  filter(term == "log(drive_time_min)")

message("\n=== Main Coefficient on log(Drive Time) ===")
print(main_coefs %>% select(model, estimate, std.error, p.value))

# =============================================================================
# 4. Placebo: Pre-Period (2012-2013)
# =============================================================================

pre_period <- analysis_clean %>%
  filter(year <= 2013)

if (nrow(pre_period) > 100) {
  model_placebo <- feols(
    alcohol_involved ~ log(drive_time_min) |
      state_abbr,
    data = pre_period,
    cluster = ~state_abbr
  )

  message("\n=== Placebo: Pre-Period (2012-2013) ===")
  etable(model_placebo, digits = 4)
} else {
  message("Insufficient pre-period observations for placebo test")
}

# =============================================================================
# 5. Placebo: Non-Alcohol Crashes
# =============================================================================

model_non_alcohol <- feols(
  I(!alcohol_involved) ~ log(drive_time_min) |
    state_abbr + year,
  data = analysis_clean,
  cluster = ~state_abbr
)

message("\n=== Placebo: Non-Alcohol Crashes ===")
etable(model_non_alcohol, digits = 4)

# =============================================================================
# 6. Heterogeneity: By Distance Band
# =============================================================================

# Create distance bands
analysis_clean <- analysis_clean %>%
  mutate(
    dist_band = case_when(
      dist_to_disp_km <= 50 ~ "0-50km",
      dist_to_disp_km <= 100 ~ "50-100km",
      dist_to_disp_km <= 200 ~ "100-200km",
      TRUE ~ ">200km"
    ),
    dist_band = factor(dist_band, levels = c("0-50km", "50-100km", "100-200km", ">200km"))
  )

# Run by band
hetero_results <- analysis_clean %>%
  group_by(dist_band) %>%
  group_map(~ {
    if (nrow(.x) < 100) return(NULL)
    feols(alcohol_involved ~ log(drive_time_min) | state_abbr + year,
          data = .x, cluster = ~state_abbr)
  })

names(hetero_results) <- levels(analysis_clean$dist_band)
hetero_results <- compact(hetero_results)

message("\n=== Heterogeneity by Distance Band ===")
etable(hetero_results, digits = 4)

# =============================================================================
# 7. Heterogeneity: Nighttime vs Daytime
# =============================================================================

model_night <- feols(
  alcohol_involved ~ log(drive_time_min) |
    state_abbr + year,
  data = filter(analysis_clean, nighttime == TRUE),
  cluster = ~state_abbr
)

model_day <- feols(
  alcohol_involved ~ log(drive_time_min) |
    state_abbr + year,
  data = filter(analysis_clean, nighttime == FALSE),
  cluster = ~state_abbr
)

message("\n=== Heterogeneity: Nighttime vs Daytime ===")
etable(list("Nighttime" = model_night, "Daytime" = model_day), digits = 4)

# =============================================================================
# 8. Save Results
# =============================================================================

# Save all models
results_list <- list(
  main = main_results,
  placebo_pre = if (exists("model_placebo")) model_placebo else NULL,
  placebo_non_alcohol = model_non_alcohol,
  hetero_distance = hetero_results,
  hetero_time = list(night = model_night, day = model_day)
)

saveRDS(results_list, file.path(data_dir, "regression_results.rds"))
message("\nSaved results to: ", file.path(data_dir, "regression_results.rds"))
