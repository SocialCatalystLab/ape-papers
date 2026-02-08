# =============================================================================
# Paper 73: Shift-Share Design - Do Economic Shocks Spread Through Social Networks?
# =============================================================================

library(tidyverse)
library(data.table)

setwd("/Users/dyanag/auto-policy-evals")

# Load SCI data
county_sci <- fread("output/paper_73/data/county_sci_summary.csv")
county_sci[, fips := sprintf("%05d", user_fips)]

# Load full SCI matrix for computing exposure
cat("Reading full SCI matrix...\n")
sci_raw <- fread(
  "output/paper_73/data/gadm1_nuts3_counties-gadm1_nuts3_counties - FB Social Connectedness Index - October 2021.tsv",
  sep = "\t",
  header = TRUE
)

# Filter to US-to-US
sci_us <- sci_raw[grepl("^USA", user_loc) & grepl("^USA", fr_loc)]
sci_us[, user_fips := sprintf("%05d", as.integer(substr(user_loc, 4, 8)))]
sci_us[, fr_fips := sprintf("%05d", as.integer(substr(fr_loc, 4, 8)))]

# Remove self-connections
sci_us <- sci_us[user_fips != fr_fips]

cat(sprintf("SCI connections: %s (excluding self)\n", format(nrow(sci_us), big.mark = ",")))

# Normalize SCI weights for each county (so they sum to 1)
sci_us[, total_sci := sum(scaled_sci), by = user_fips]
sci_us[, weight := scaled_sci / total_sci]

# -----------------------------------------------------------------------------
# Download economic shock data: Great Recession unemployment change
# -----------------------------------------------------------------------------

cat("\nDownloading unemployment data for Great Recession analysis...\n")

# BLS LAUS data via Census API (county unemployment)
# We'll use a simpler approach - Census API for unemployment rates

# Get 2007 and 2010 unemployment from ACS
get_acs_unemployment <- function(year) {
  api_url <- sprintf("https://api.census.gov/data/%d/acs/acs1", year)
  vars <- "B23025_005E,B23025_003E"  # Unemployed, Employed
  full_url <- paste0(api_url, "?get=NAME,", vars, "&for=county:*")

  tryCatch({
    data <- jsonlite::fromJSON(full_url)
    df <- as.data.frame(data[-1, ])
    colnames(df) <- c("name", "unemployed", "employed", "state", "county")
    df$fips <- paste0(df$state, df$county)
    df$unemployed <- as.numeric(df$unemployed)
    df$employed <- as.numeric(df$employed)
    df$unemp_rate <- df$unemployed / (df$unemployed + df$employed) * 100
    df$year <- year
    return(df[, c("fips", "unemp_rate", "year")])
  }, error = function(e) {
    cat(sprintf("Error for year %d: %s\n", year, e$message))
    return(NULL)
  })
}

# 2007 (pre-recession) and 2010 (post-recession)
unemp_2007 <- get_acs_unemployment(2007)
unemp_2010 <- get_acs_unemployment(2010)
unemp_2019 <- get_acs_unemployment(2019)  # Pre-COVID
unemp_2021 <- get_acs_unemployment(2021)  # COVID impact

# Alternative: Use 2019 vs 2021 for COVID shock analysis
cat(sprintf("2007 data: %d counties\n", ifelse(is.null(unemp_2007), 0, nrow(unemp_2007))))
cat(sprintf("2010 data: %d counties\n", ifelse(is.null(unemp_2010), 0, nrow(unemp_2010))))
cat(sprintf("2019 data: %d counties\n", ifelse(is.null(unemp_2019), 0, nrow(unemp_2019))))
cat(sprintf("2021 data: %d counties\n", ifelse(is.null(unemp_2021), 0, nrow(unemp_2021))))

# Use the available data
if (!is.null(unemp_2019) && !is.null(unemp_2021)) {
  cat("\nUsing 2019-2021 (COVID shock) for analysis\n")

  # Merge pre and post
  unemp_change <- merge(
    unemp_2019[, c("fips", "unemp_rate")],
    unemp_2021[, c("fips", "unemp_rate")],
    by = "fips",
    suffixes = c("_2019", "_2021")
  )

  # Calculate shock (change in unemployment)
  unemp_change$shock <- unemp_change$unemp_rate_2021 - unemp_change$unemp_rate_2019

  cat(sprintf("Counties with shock data: %d\n", nrow(unemp_change)))

  # -----------------------------------------------------------------------------
  # Compute SCI-weighted exposure to shocks
  # -----------------------------------------------------------------------------

  cat("\nComputing SCI-weighted exposure to unemployment shocks...\n")

  # Merge shock data with SCI matrix
  sci_with_shock <- merge(
    sci_us[, .(user_fips, fr_fips, weight)],
    unemp_change[, c("fips", "shock")],
    by.x = "fr_fips",
    by.y = "fips",
    all.x = FALSE
  )

  # Compute exposure: sum of (weight * friend's shock)
  exposure <- sci_with_shock[, .(
    network_shock_exposure = sum(weight * shock, na.rm = TRUE),
    n_connected = .N
  ), by = user_fips]

  cat(sprintf("Counties with exposure computed: %d\n", nrow(exposure)))

  # Merge exposure with own outcomes
  analysis_data <- merge(
    exposure,
    unemp_change,
    by.x = "user_fips",
    by.y = "fips"
  )

  # Also merge in county characteristics
  analysis_data <- merge(
    analysis_data,
    county_sci[, .(fips, diversity, out_of_state_share, self_share, log_total_sci)],
    by.x = "user_fips",
    by.y = "fips"
  )

  cat(sprintf("Analysis dataset: %d counties\n", nrow(analysis_data)))

  # -----------------------------------------------------------------------------
  # Key Analysis: Does network exposure predict own outcomes?
  # -----------------------------------------------------------------------------

  cat("\n=== KEY RESULTS: Network Shock Exposure ===\n\n")

  # Summary statistics
  cat("Summary of network exposure:\n")
  print(summary(analysis_data$network_shock_exposure))

  cat("\nSummary of own shock:\n")
  print(summary(analysis_data$shock))

  # Correlation
  cor_test <- cor.test(analysis_data$shock, analysis_data$network_shock_exposure)
  cat(sprintf("\nCorrelation (own shock ~ network exposure): r = %.3f (p = %.2e)\n",
              cor_test$estimate, cor_test$p.value))

  # Regression
  cat("\n=== REGRESSION: Own Shock ~ Network Exposure ===\n")

  model1 <- lm(shock ~ network_shock_exposure, data = analysis_data)
  cat("\nModel 1: shock ~ network_exposure\n")
  print(summary(model1))

  model2 <- lm(shock ~ network_shock_exposure + diversity + log_total_sci,
               data = analysis_data)
  cat("\nModel 2: shock ~ network_exposure + diversity + log(total_sci)\n")
  print(summary(model2))

  # Binned scatter
  cat("\n=== BINNED ANALYSIS ===\n")

  analysis_data <- analysis_data %>%
    mutate(exposure_quintile = ntile(network_shock_exposure, 5))

  quintile_summary <- analysis_data %>%
    group_by(exposure_quintile) %>%
    summarize(
      n = n(),
      mean_exposure = mean(network_shock_exposure),
      mean_own_shock = mean(shock),
      mean_unemp_2019 = mean(unemp_rate_2019),
      mean_unemp_2021 = mean(unemp_rate_2021)
    )

  print(quintile_summary)

  # Save analysis data
  fwrite(analysis_data, "output/paper_73/data/shift_share_analysis.csv")

  cat("\n=== KEY FINDING ===\n")
  q1 <- quintile_summary %>% filter(exposure_quintile == 1)
  q5 <- quintile_summary %>% filter(exposure_quintile == 5)
  cat(sprintf("Q5 exposure (high) mean own shock: %.2f pp\n", q5$mean_own_shock))
  cat(sprintf("Q1 exposure (low) mean own shock: %.2f pp\n", q1$mean_own_shock))
  cat(sprintf("Difference: %.2f pp\n", q5$mean_own_shock - q1$mean_own_shock))

} else {
  cat("Could not download unemployment data for both periods.\n")
}

cat("\nDone!\n")
