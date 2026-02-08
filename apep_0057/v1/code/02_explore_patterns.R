# =============================================================================
# Paper 73: Explore SCI Patterns and Merge with Outcomes
# =============================================================================

library(tidyverse)
library(data.table)

setwd("/Users/dyanag/auto-policy-evals")

# Load county SCI summary
county_sci <- fread("output/paper_73/data/county_sci_summary.csv")

# Add state FIPS
county_sci[, state_fips := substr(user_fips, 1, 2)]

# State name lookup
state_names <- data.frame(
  state_fips = c("01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
                 "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
                 "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
                 "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
                 "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56",
                 "72", "78"),
  state_name = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY",
                 "PR", "VI")
)

county_sci <- merge(county_sci, state_names, by = "state_fips", all.x = TRUE)

# -----------------------------------------------------------------------------
# Extreme counties
# -----------------------------------------------------------------------------

cat("\n=== MOST INSULAR COUNTIES (highest self_share) ===\n")
print(county_sci[order(-self_share)][1:15, .(user_fips, state_name, self_share, out_of_state_share, diversity)])

cat("\n=== MOST CONNECTED COUNTIES (lowest self_share) ===\n")
print(county_sci[order(self_share)][1:15, .(user_fips, state_name, self_share, out_of_state_share, diversity)])

cat("\n=== MOST GEOGRAPHICALLY DIVERSE (highest diversity) ===\n")
print(county_sci[order(-diversity)][1:15, .(user_fips, state_name, self_share, out_of_state_share, diversity)])

cat("\n=== LEAST GEOGRAPHICALLY DIVERSE (lowest diversity) ===\n")
print(county_sci[order(diversity)][1:15, .(user_fips, state_name, self_share, out_of_state_share, diversity)])

# -----------------------------------------------------------------------------
# State-level patterns
# -----------------------------------------------------------------------------

state_summary <- county_sci[, .(
  n_counties = .N,
  mean_self_share = mean(self_share, na.rm = TRUE),
  mean_out_of_state = mean(out_of_state_share, na.rm = TRUE),
  mean_diversity = mean(diversity, na.rm = TRUE)
), by = state_name]

cat("\n=== STATE AVERAGES (sorted by diversity) ===\n")
print(state_summary[order(-mean_diversity)])

# -----------------------------------------------------------------------------
# Download and merge economic data from Census API (county-level)
# -----------------------------------------------------------------------------

cat("\n\nDownloading county-level economic data from Census API...\n")

# ACS 5-year estimates 2021 - key variables
# B19013_001E = Median household income
# B01003_001E = Total population
# B25077_001E = Median home value
# B23025_005E = Unemployed (in labor force)
# B23025_003E = Employed
# B15003_022E = Bachelor's degree
# B15003_001E = Total 25+

api_url <- "https://api.census.gov/data/2021/acs/acs5"

# Get data for all counties
vars <- "NAME,B19013_001E,B01003_001E,B25077_001E,B23025_005E,B23025_003E,B15003_022E,B15003_001E"
full_url <- paste0(api_url, "?get=", vars, "&for=county:*")

tryCatch({
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
      log_income = log(med_income),
      log_pop = log(population)
    )

  cat(sprintf("Downloaded data for %d counties\n", nrow(census_df)))

  # Merge with SCI data
  merged <- merge(
    county_sci,
    census_df[, c("fips", "name", "med_income", "population", "med_home_value",
                  "unemp_rate", "college_share", "log_income", "log_pop")],
    by.x = "user_fips", by.y = "fips",
    all.x = TRUE
  )

  cat(sprintf("Merged: %d counties with both SCI and Census data\n", sum(!is.na(merged$med_income))))

  # Save merged data
  fwrite(merged, "output/paper_73/data/county_sci_census.csv")

  # -----------------------------------------------------------------------------
  # Key correlations
  # -----------------------------------------------------------------------------

  cat("\n=== CORRELATIONS: SCI Diversity vs. Economic Outcomes ===\n")

  vars_to_correlate <- c("diversity", "out_of_state_share", "self_share",
                         "med_income", "college_share", "unemp_rate",
                         "med_home_value", "log_pop")

  cor_matrix <- cor(merged[, ..vars_to_correlate], use = "complete.obs")
  print(round(cor_matrix, 3))

  # Focus on diversity correlations
  cat("\n=== KEY FINDING: Diversity correlations ===\n")
  cat(sprintf("Diversity ~ Median Income: r = %.3f\n",
              cor(merged$diversity, merged$med_income, use = "complete.obs")))
  cat(sprintf("Diversity ~ College Share: r = %.3f\n",
              cor(merged$diversity, merged$college_share, use = "complete.obs")))
  cat(sprintf("Diversity ~ Unemployment: r = %.3f\n",
              cor(merged$diversity, merged$unemp_rate, use = "complete.obs")))
  cat(sprintf("Diversity ~ Population: r = %.3f\n",
              cor(merged$diversity, merged$log_pop, use = "complete.obs")))

}, error = function(e) {
  cat(sprintf("Error downloading Census data: %s\n", e$message))
})

cat("\nDone!\n")
