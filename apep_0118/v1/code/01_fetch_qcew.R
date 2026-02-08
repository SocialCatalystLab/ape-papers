# =============================================================================
# 01_fetch_qcew.R
# Fetch REAL QCEW data from BLS API
# Paper 117: Sports Betting Employment Effects
# =============================================================================
#
# IMPORTANT: This script fetches REAL data from the BLS QCEW API.
# NO SIMULATED OR SYNTHETIC DATA.
#
# API endpoint: https://data.bls.gov/cew/data/api/{YEAR}/a/industry/{NAICS}.csv
# =============================================================================

source("00_packages.R")

# =============================================================================
# Function to fetch QCEW data for a single year/industry
# =============================================================================

fetch_qcew_year <- function(year, industry = "7132") {
  url <- paste0("https://data.bls.gov/cew/data/api/", year, "/a/industry/", industry, ".csv")

  message(sprintf("Fetching QCEW data: year=%d, NAICS=%s", year, industry))
  message(sprintf("  URL: %s", url))

  tryCatch({
    # Read CSV directly from BLS API
    df <- read_csv(url, show_col_types = FALSE)

    message(sprintf("  Downloaded %d rows", nrow(df)))

    # Filter to state-level totals (private ownership, all sizes)
    # agglvl_code meanings for 4-digit NAICS:
    #   55 = State, by ownership (3-digit NAICS)
    #   56 = State, by ownership (4-digit NAICS)
    # own_code 5 = Private sector
    # size_code 0 = All establishment sizes

    df_state <- df %>%
      filter(
        own_code == 5,           # Private sector
        size_code == 0           # All establishment sizes
      ) %>%
      # Filter to state-level (area_fips length 5, first 2 digits are state)
      # State totals have agglvl_code 55 or 56
      filter(agglvl_code %in% c(55, 56)) %>%
      mutate(
        year = as.integer(year),
        state_fips = substr(area_fips, 1, 2),
        industry_code = industry
      ) %>%
      select(
        state_fips,
        year,
        industry_code,
        establishments = annual_avg_estabs,
        employment = annual_avg_emplvl,
        total_wages = total_annual_wages,
        avg_weekly_wage = annual_avg_wkly_wage
      )

    message(sprintf("  Filtered to %d state observations", nrow(df_state)))

    # Brief pause to respect API rate limits
    Sys.sleep(0.3)

    return(df_state)

  }, error = function(e) {
    message(sprintf("  ERROR: %s", conditionMessage(e)))
    return(NULL)
  })
}

# =============================================================================
# Fetch Gambling Industry (NAICS 7132) Data
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("FETCHING GAMBLING INDUSTRY DATA (NAICS 7132)")
message(paste(rep("=", 70), collapse = ""), "\n")

years <- 2010:2024

# Fetch gambling industry employment
gambling_list <- lapply(years, function(y) fetch_qcew_year(y, "7132"))
gambling_raw <- bind_rows(gambling_list)

message(sprintf("\nGambling industry: %d state-year observations", nrow(gambling_raw)))

# =============================================================================
# Fetch Placebo Industries
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("FETCHING PLACEBO INDUSTRIES")
message(paste(rep("=", 70), collapse = ""), "\n")

# Manufacturing (NAICS 31-33) - placebo
message("\n--- Manufacturing (NAICS 31-33) ---\n")
mfg_list <- lapply(years, function(y) fetch_qcew_year(y, "31-33"))
mfg_raw <- bind_rows(mfg_list)
message(sprintf("Manufacturing: %d state-year observations", nrow(mfg_raw)))

# Agriculture (NAICS 11) - placebo
message("\n--- Agriculture (NAICS 11) ---\n")
ag_list <- lapply(years, function(y) fetch_qcew_year(y, "11"))
ag_raw <- bind_rows(ag_list)
message(sprintf("Agriculture: %d state-year observations", nrow(ag_raw)))

# =============================================================================
# Combine and Save
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("SAVING DATA")
message(paste(rep("=", 70), collapse = ""), "\n")

# Combine all industries
qcew_all <- bind_rows(
  gambling_raw,
  mfg_raw,
  ag_raw
)

# Add state names
qcew_all <- qcew_all %>%
  left_join(state_fips %>% select(state_fips, state_abbr, state_name),
            by = "state_fips")

# Save
write_csv(qcew_all, "../data/qcew_all_industries.csv")
message("Saved: ../data/qcew_all_industries.csv")

# Also save gambling-only for main analysis
gambling_clean <- gambling_raw %>%
  left_join(state_fips %>% select(state_fips, state_abbr, state_name),
            by = "state_fips")

write_csv(gambling_clean, "../data/qcew_gambling.csv")
message("Saved: ../data/qcew_gambling.csv")

# =============================================================================
# Summary Statistics
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("SUMMARY STATISTICS")
message(paste(rep("=", 70), collapse = ""), "\n")

gambling_summary <- gambling_clean %>%
  group_by(year) %>%
  summarise(
    n_states = n_distinct(state_fips),
    total_employment = sum(employment, na.rm = TRUE),
    mean_employment = mean(employment, na.rm = TRUE),
    median_employment = median(employment, na.rm = TRUE),
    .groups = "drop"
  )

message("\nGambling industry employment by year:")
print(gambling_summary, n = 20)

message("\nTop 5 states by gambling employment (2023):")
gambling_clean %>%
  filter(year == 2023) %>%
  arrange(desc(employment)) %>%
  select(state_abbr, employment, establishments) %>%
  head(10) %>%
  print()

message("\n", paste(rep("=", 70), collapse = ""))
message("DATA FETCH COMPLETE - REAL BLS QCEW API DATA")
message(paste(rep("=", 70), collapse = ""))
