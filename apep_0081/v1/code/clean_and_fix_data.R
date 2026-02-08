# =============================================================================
# Paper 108: Clean data and fix issues
# - Remove duplicates
# - Document actual data coverage
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load raw accident data
acc <- readRDS(file.path(dir_data_raw, "fars_accident_west.rds"))

cat("=== Original data ===\n")
cat("Total rows:", nrow(acc), "\n")
print(table(acc$year))

# Remove duplicates by st_case, state, year
acc_clean <- acc %>%
  distinct(st_case, state, year, .keep_all = TRUE)

cat("\n=== After deduplication ===\n")
cat("Total rows:", nrow(acc_clean), "\n")
print(table(acc_clean$year))

# Save cleaned data
saveRDS(acc_clean, file.path(dir_data_raw, "fars_accident_west_clean.rds"))

# Reload the main analysis file and fix
fars_original <- readRDS(file.path(dir_data, "fars_analysis_policy.rds"))

# Remove duplicates
fars_clean <- fars_original %>%
  distinct(st_case, state, year, .keep_all = TRUE)

cat("\n=== Analysis file after deduplication ===\n")
cat("Total rows:", nrow(fars_clean), "\n")
print(table(fars_clean$year))

# Also reload and fix the fixed version
fars_fixed <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed.rds"))
fars_fixed_clean <- fars_fixed %>%
  distinct(st_case, state, year, .keep_all = TRUE)

cat("\n=== Fixed analysis file after deduplication ===\n")
cat("Total rows:", nrow(fars_fixed_clean), "\n")
print(table(fars_fixed_clean$year))

# Save cleaned versions
saveRDS(fars_clean, file.path(dir_data, "fars_analysis_policy_clean.rds"))
saveRDS(fars_fixed_clean, file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))

cat("\n=== Data coverage summary ===\n")
cat("Years available: ", paste(unique(fars_fixed_clean$year), collapse=", "), "\n")
cat("Total unique crashes:", nrow(fars_fixed_clean), "\n")

# Summary by year
year_summary <- fars_fixed_clean %>%
  group_by(year) %>%
  summarise(
    crashes = n(),
    alc_involved = sum(alc_involved, na.rm=TRUE),
    pct_alc = round(100 * alc_involved / crashes, 1),
    thc_pos = sum(thc_positive_fixed, na.rm=TRUE),
    pct_thc = round(100 * thc_pos / crashes, 1)
  )
print(as.data.frame(year_summary))

message("\nCleaned data saved!")
