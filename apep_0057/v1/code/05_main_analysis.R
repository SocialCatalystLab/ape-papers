# =============================================================================
# Paper 73: Main Analysis - Social Networks and Shock Propagation
# =============================================================================
# Research Question: Do economic shocks propagate through social networks?
# Method: Shift-share design using Facebook SCI as exposure weights
# =============================================================================

library(tidyverse)
library(data.table)
library(fixest)  # For robust SEs and fixed effects

setwd("/Users/dyanag/auto-policy-evals")

# -----------------------------------------------------------------------------
# 1. LOAD AND PREPARE DATA
# -----------------------------------------------------------------------------

cat("=== LOADING DATA ===\n")

# Load SCI summary
county_sci <- fread("output/paper_73/data/county_sci_summary.csv")
county_sci[, fips := sprintf("%05d", user_fips)]
county_sci[, state_fips := substr(fips, 1, 2)]

# Load full SCI matrix
cat("Loading SCI matrix...\n")
sci_raw <- fread(
  "output/paper_73/data/gadm1_nuts3_counties-gadm1_nuts3_counties - FB Social Connectedness Index - October 2021.tsv",
  sep = "\t",
  header = TRUE
)

# Filter to US, extract FIPS, remove self-connections
sci_us <- sci_raw[grepl("^USA", user_loc) & grepl("^USA", fr_loc)]
sci_us[, user_fips := sprintf("%05d", as.integer(substr(user_loc, 4, 8)))]
sci_us[, fr_fips := sprintf("%05d", as.integer(substr(fr_loc, 4, 8)))]
sci_us <- sci_us[user_fips != fr_fips]

# Normalize weights
sci_us[, total_sci := sum(scaled_sci), by = user_fips]
sci_us[, weight := scaled_sci / total_sci]

rm(sci_raw)
gc()

cat(sprintf("SCI matrix: %s connections\n", format(nrow(sci_us), big.mark = ",")))

# -----------------------------------------------------------------------------
# 2. DOWNLOAD ECONOMIC DATA (ACS 5-year for full coverage)
# -----------------------------------------------------------------------------

cat("\n=== DOWNLOADING ECONOMIC DATA ===\n")

get_acs5_data <- function(year) {
  api_url <- sprintf("https://api.census.gov/data/%d/acs/acs5", year)
  vars <- "NAME,B23025_005E,B23025_003E,B19013_001E,B01003_001E,B15003_022E,B15003_001E"
  full_url <- paste0(api_url, "?get=", vars, "&for=county:*")

  tryCatch({
    data <- jsonlite::fromJSON(full_url)
    df <- as.data.frame(data[-1, ])
    colnames(df) <- c("name", "unemployed", "employed", "med_income",
                      "population", "bachelors", "pop_25plus", "state", "county")
    df$fips <- paste0(df$state, df$county)
    df <- df %>%
      mutate(across(c(unemployed, employed, med_income, population, bachelors, pop_25plus),
                    as.numeric)) %>%
      mutate(
        unemp_rate = unemployed / (unemployed + employed) * 100,
        college_share = bachelors / pop_25plus * 100,
        log_pop = log(pmax(population, 1))
      )
    df$year <- year
    return(df)
  }, error = function(e) {
    cat(sprintf("Error for year %d: %s\n", year, e$message))
    return(NULL)
  })
}

# Get 2019 (pre-COVID) and 2021 (COVID impact)
cat("Downloading 2019 ACS 5-year...\n")
acs_2019 <- get_acs5_data(2019)
cat(sprintf("  %d counties\n", nrow(acs_2019)))

cat("Downloading 2021 ACS 5-year...\n")
acs_2021 <- get_acs5_data(2021)
cat(sprintf("  %d counties\n", nrow(acs_2021)))

# Merge and calculate changes
econ_data <- merge(
  acs_2019[, c("fips", "unemp_rate", "med_income", "population", "college_share", "log_pop")],
  acs_2021[, c("fips", "unemp_rate", "med_income")],
  by = "fips",
  suffixes = c("_2019", "_2021")
)

econ_data$unemp_shock <- econ_data$unemp_rate_2021 - econ_data$unemp_rate_2019
econ_data$income_change <- (econ_data$med_income_2021 - econ_data$med_income_2019) / econ_data$med_income_2019 * 100

cat(sprintf("Economic data: %d counties with pre/post\n", nrow(econ_data)))

# -----------------------------------------------------------------------------
# 3. COMPUTE NETWORK SHOCK EXPOSURE
# -----------------------------------------------------------------------------

cat("\n=== COMPUTING NETWORK EXPOSURE ===\n")

# Merge shocks into SCI matrix
sci_with_shock <- merge(
  sci_us[, .(user_fips, fr_fips, weight, scaled_sci)],
  econ_data[, c("fips", "unemp_shock")],
  by.x = "fr_fips",
  by.y = "fips"
)

# Compute exposure measures
exposure <- sci_with_shock[, .(
  # Main exposure: SCI-weighted mean of friends' shocks
  network_exposure = sum(weight * unemp_shock, na.rm = TRUE),

  # Leave-out-state exposure (exclude same-state connections)
  n_connections = .N
), by = user_fips]

# Also compute leave-out-state exposure
sci_with_shock[, user_state := substr(user_fips, 1, 2)]
sci_with_shock[, fr_state := substr(fr_fips, 1, 2)]

leave_out_exposure <- sci_with_shock[user_state != fr_state, .(
  leave_out_exposure = weighted.mean(unemp_shock, scaled_sci, na.rm = TRUE)
), by = user_fips]

exposure <- merge(exposure, leave_out_exposure, by = "user_fips", all.x = TRUE)

cat(sprintf("Exposure computed for %d counties\n", nrow(exposure)))

# -----------------------------------------------------------------------------
# 4. BUILD ANALYSIS DATASET
# -----------------------------------------------------------------------------

cat("\n=== BUILDING ANALYSIS DATA ===\n")

# Merge all datasets
analysis <- merge(econ_data, exposure, by.x = "fips", by.y = "user_fips")
analysis <- merge(analysis, county_sci[, .(fips, diversity, out_of_state_share, self_share,
                                            total_sci, state_fips)], by = "fips")

# Standardize key variables for interpretation
analysis$network_exposure_std <- scale(analysis$network_exposure)[,1]
analysis$diversity_std <- scale(analysis$diversity)[,1]
analysis$log_pop_std <- scale(analysis$log_pop)[,1]

cat(sprintf("Final analysis sample: %d counties\n", nrow(analysis)))

# Save analysis data
fwrite(analysis, "output/paper_73/data/analysis_final.csv")

# -----------------------------------------------------------------------------
# 5. SUMMARY STATISTICS
# -----------------------------------------------------------------------------

cat("\n=== SUMMARY STATISTICS ===\n")

summary_vars <- c("unemp_shock", "network_exposure", "leave_out_exposure",
                  "diversity", "log_pop", "college_share")

summary_stats <- analysis %>%
  select(all_of(summary_vars)) %>%
  summarise(across(everything(), list(
    mean = ~mean(.x, na.rm = TRUE),
    sd = ~sd(.x, na.rm = TRUE),
    min = ~min(.x, na.rm = TRUE),
    max = ~max(.x, na.rm = TRUE)
  ))) %>%
  pivot_longer(everything(),
               names_to = c("variable", "stat"),
               names_pattern = "(.*)_(.*)") %>%
  pivot_wider(names_from = stat, values_from = value)

print(summary_stats)

# -----------------------------------------------------------------------------
# 6. MAIN REGRESSION RESULTS
# -----------------------------------------------------------------------------

cat("\n=== MAIN REGRESSION RESULTS ===\n")

# Model 1: Simple OLS
cat("\n--- Model 1: Bivariate ---\n")
model1 <- feols(unemp_shock ~ network_exposure_std, data = analysis)
print(summary(model1))

# Model 2: Control for population and education
cat("\n--- Model 2: With Controls ---\n")
model2 <- feols(unemp_shock ~ network_exposure_std + log_pop_std + college_share,
                data = analysis)
print(summary(model2))

# Model 3: Control for network characteristics
cat("\n--- Model 3: With Network Controls ---\n")
model3 <- feols(unemp_shock ~ network_exposure_std + log_pop_std + college_share +
                  diversity_std, data = analysis)
print(summary(model3))

# Model 4: State fixed effects
cat("\n--- Model 4: State Fixed Effects ---\n")
model4 <- feols(unemp_shock ~ network_exposure_std + log_pop_std + college_share |
                  state_fips, data = analysis)
print(summary(model4))

# Model 5: Leave-out-state exposure (more credible)
cat("\n--- Model 5: Leave-Out-State Exposure ---\n")
analysis$leave_out_std <- scale(analysis$leave_out_exposure)[,1]
model5 <- feols(unemp_shock ~ leave_out_std + log_pop_std + college_share |
                  state_fips, data = analysis)
print(summary(model5))

# -----------------------------------------------------------------------------
# 7. QUINTILE ANALYSIS
# -----------------------------------------------------------------------------

cat("\n=== QUINTILE ANALYSIS ===\n")

analysis <- analysis %>%
  mutate(exposure_quintile = ntile(network_exposure, 5))

quintile_results <- analysis %>%
  group_by(exposure_quintile) %>%
  summarize(
    n = n(),
    mean_exposure = mean(network_exposure),
    mean_own_shock = mean(unemp_shock),
    se_shock = sd(unemp_shock) / sqrt(n()),
    mean_unemp_2019 = mean(unemp_rate_2019),
    mean_pop = mean(population),
    mean_diversity = mean(diversity)
  )

print(quintile_results)

# Save for plotting
fwrite(quintile_results, "output/paper_73/data/quintile_results.csv")

# Difference between Q5 and Q1
q1_shock <- quintile_results$mean_own_shock[1]
q5_shock <- quintile_results$mean_own_shock[5]

cat(sprintf("\n=== KEY FINDING ===\n"))
cat(sprintf("Q1 (lowest network exposure): %.2f pp unemployment increase\n", q1_shock))
cat(sprintf("Q5 (highest network exposure): %.2f pp unemployment increase\n", q5_shock))
cat(sprintf("Difference: %.2f pp\n", q5_shock - q1_shock))

# -----------------------------------------------------------------------------
# 8. ROBUSTNESS: GEOGRAPHIC CONTROLS
# -----------------------------------------------------------------------------

cat("\n=== ROBUSTNESS: GEOGRAPHIC PROXIMITY ===\n")

# The concern: SCI reflects geographic proximity, and nearby counties may have
# correlated shocks regardless of social networks

# We partially address this with state FE and leave-out-state exposure
# Additional robustness: within-state variation only

cat("Within-state analysis (variation within states only):\n")
model_within <- feols(unemp_shock ~ network_exposure_std + log_pop_std + college_share |
                        state_fips, data = analysis, cluster = ~state_fips)
print(summary(model_within))

cat("\nDone! Results saved to output/paper_73/data/\n")
