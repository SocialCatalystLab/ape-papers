# =============================================================================
# Paper 73: Economic Correlations with SCI Diversity
# =============================================================================

library(tidyverse)
library(data.table)

setwd("/Users/dyanag/auto-policy-evals")

# Load county SCI summary
county_sci <- fread("output/paper_73/data/county_sci_summary.csv")

# Convert FIPS to character with zero padding
county_sci[, fips := sprintf("%05d", user_fips)]

cat(sprintf("SCI data: %d counties\n", nrow(county_sci)))

# -----------------------------------------------------------------------------
# Download Census ACS data
# -----------------------------------------------------------------------------

cat("Downloading Census ACS 2021 data...\n")

api_url <- "https://api.census.gov/data/2021/acs/acs5"
vars <- "NAME,B19013_001E,B01003_001E,B25077_001E,B23025_005E,B23025_003E,B15003_022E,B15003_001E"
full_url <- paste0(api_url, "?get=", vars, "&for=county:*")

census_data <- jsonlite::fromJSON(full_url)
census_df <- as.data.frame(census_data[-1, ])
colnames(census_df) <- c("name", "med_income", "population", "med_home_value",
                          "unemployed", "employed", "bachelors", "pop_25plus",
                          "state", "county")

# Create FIPS code
census_df$fips <- paste0(census_df$state, census_df$county)

# Convert to numeric
census_df <- census_df %>%
  mutate(across(c(med_income, population, med_home_value, unemployed,
                  employed, bachelors, pop_25plus), as.numeric))

# Calculate derived measures
census_df <- census_df %>%
  mutate(
    unemp_rate = unemployed / (unemployed + employed) * 100,
    college_share = bachelors / pop_25plus * 100,
    log_income = log(pmax(med_income, 1)),
    log_pop = log(pmax(population, 1)),
    log_home_value = log(pmax(med_home_value, 1))
  )

cat(sprintf("Census data: %d counties\n", nrow(census_df)))

# -----------------------------------------------------------------------------
# Merge datasets
# -----------------------------------------------------------------------------

merged <- merge(
  as.data.frame(county_sci),
  census_df[, c("fips", "name", "med_income", "population", "med_home_value",
                "unemp_rate", "college_share", "log_income", "log_pop", "log_home_value")],
  by = "fips",
  all.x = TRUE
)

cat(sprintf("Merged: %d counties with SCI, %d with Census data\n",
            nrow(merged), sum(!is.na(merged$med_income))))

# Save merged
fwrite(merged, "output/paper_73/data/county_sci_census.csv")

# -----------------------------------------------------------------------------
# Correlation analysis
# -----------------------------------------------------------------------------

cat("\n=== KEY CORRELATIONS ===\n\n")

# Drop rows with missing values for correlation
merged_clean <- merged %>% filter(!is.na(med_income) & !is.na(diversity))

# Key correlations with diversity
cat("SCI DIVERSITY correlations:\n")
cat(sprintf("  ~ Median Income:    r = %.3f  (p < %.3e)\n",
            cor(merged_clean$diversity, merged_clean$med_income),
            cor.test(merged_clean$diversity, merged_clean$med_income)$p.value))
cat(sprintf("  ~ College Share:    r = %.3f  (p < %.3e)\n",
            cor(merged_clean$diversity, merged_clean$college_share),
            cor.test(merged_clean$diversity, merged_clean$college_share)$p.value))
cat(sprintf("  ~ Unemployment:     r = %.3f  (p < %.3e)\n",
            cor(merged_clean$diversity, merged_clean$unemp_rate),
            cor.test(merged_clean$diversity, merged_clean$unemp_rate)$p.value))
cat(sprintf("  ~ Home Value:       r = %.3f  (p < %.3e)\n",
            cor(merged_clean$diversity, merged_clean$med_home_value, use = "complete.obs"),
            cor.test(merged_clean$diversity, merged_clean$med_home_value)$p.value))
cat(sprintf("  ~ Population (log): r = %.3f  (p < %.3e)\n",
            cor(merged_clean$diversity, merged_clean$log_pop),
            cor.test(merged_clean$diversity, merged_clean$log_pop)$p.value))

# Out-of-state share correlations
cat("\nOUT-OF-STATE SHARE correlations:\n")
cat(sprintf("  ~ Median Income:    r = %.3f\n",
            cor(merged_clean$out_of_state_share, merged_clean$med_income)))
cat(sprintf("  ~ College Share:    r = %.3f\n",
            cor(merged_clean$out_of_state_share, merged_clean$college_share)))
cat(sprintf("  ~ Population (log): r = %.3f\n",
            cor(merged_clean$out_of_state_share, merged_clean$log_pop)))

# Self-share (insularity) correlations
cat("\nSELF-SHARE (insularity) correlations:\n")
cat(sprintf("  ~ Median Income:    r = %.3f\n",
            cor(merged_clean$self_share, merged_clean$med_income)))
cat(sprintf("  ~ College Share:    r = %.3f\n",
            cor(merged_clean$self_share, merged_clean$college_share)))
cat(sprintf("  ~ Population (log): r = %.3f\n",
            cor(merged_clean$self_share, merged_clean$log_pop)))

# -----------------------------------------------------------------------------
# Regression analysis
# -----------------------------------------------------------------------------

cat("\n=== REGRESSION: Income ~ SCI Diversity ===\n")

# Simple regression
model1 <- lm(log_income ~ diversity, data = merged_clean)
cat("\nModel 1: log(income) ~ diversity\n")
print(summary(model1))

# Control for population
model2 <- lm(log_income ~ diversity + log_pop, data = merged_clean)
cat("\nModel 2: log(income) ~ diversity + log(population)\n")
print(summary(model2))

# Full model
model3 <- lm(log_income ~ diversity + log_pop + college_share, data = merged_clean)
cat("\nModel 3: log(income) ~ diversity + log(population) + college_share\n")
print(summary(model3))

# -----------------------------------------------------------------------------
# Quintile analysis
# -----------------------------------------------------------------------------

cat("\n=== QUINTILE ANALYSIS ===\n")

merged_clean <- merged_clean %>%
  mutate(diversity_quintile = ntile(diversity, 5))

quintile_summary <- merged_clean %>%
  group_by(diversity_quintile) %>%
  summarize(
    n = n(),
    mean_diversity = mean(diversity),
    mean_income = mean(med_income, na.rm = TRUE),
    mean_college = mean(college_share, na.rm = TRUE),
    mean_unemp = mean(unemp_rate, na.rm = TRUE),
    mean_home_value = mean(med_home_value, na.rm = TRUE),
    mean_pop = mean(population, na.rm = TRUE)
  )

print(quintile_summary)

# Difference between Q5 and Q1
q1 <- quintile_summary %>% filter(diversity_quintile == 1)
q5 <- quintile_summary %>% filter(diversity_quintile == 5)

cat("\n=== Q5 vs Q1 DIFFERENCES ===\n")
cat(sprintf("Income difference: $%,.0f (%.1f%% higher)\n",
            q5$mean_income - q1$mean_income,
            (q5$mean_income - q1$mean_income) / q1$mean_income * 100))
cat(sprintf("College share difference: %.1f pp\n",
            q5$mean_college - q1$mean_college))
cat(sprintf("Unemployment difference: %.2f pp\n",
            q5$mean_unemp - q1$mean_unemp))

cat("\nDone!\n")
