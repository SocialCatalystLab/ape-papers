# =============================================================================
# Paper 73: SOI Discrimination Laws and Housing Voucher Utilization
# 02_clean_data.R - Clean and merge data sources
# =============================================================================

source("code/00_packages.R")
library(readxl)

# =============================================================================
# 1. Load SOI Laws Data
# =============================================================================

soi_laws <- read_csv("data/soi_laws.csv", show_col_types = FALSE) %>%
  mutate(effective_date = ymd(effective_date))

cat("SOI Laws loaded:", nrow(soi_laws), "states with treatment\n")

# =============================================================================
# 2. Load and Combine HUD Picture of Subsidized Households Data
# =============================================================================

# Function to read and standardize HUD data
read_hud_year <- function(year) {
  file_path <- sprintf("data/STATE_%d.xlsx", year)

  if (!file.exists(file_path)) {
    message(sprintf("File not found: %s", file_path))
    return(NULL)
  }

  tryCatch({
    df <- read_excel(file_path, sheet = 1)

    # Standardize column names (they vary across years)
    names(df) <- tolower(names(df))
    names(df) <- gsub(" ", "_", names(df))
    names(df) <- gsub("[^a-z0-9_]", "", names(df))

    # Add year
    df$year <- year

    return(df)
  }, error = function(e) {
    message(sprintf("Error reading %s: %s", file_path, e$message))
    return(NULL)
  })
}

# Load all years
years <- 2015:2024
hud_list <- lapply(years, read_hud_year)
hud_list <- hud_list[!sapply(hud_list, is.null)]

cat("Loaded HUD data for", length(hud_list), "years\n")

# Check column names across years
cat("\nColumn names by year:\n")
for (i in seq_along(hud_list)) {
  cat(sprintf("  Year %d: %d columns\n", hud_list[[i]]$year[1], ncol(hud_list[[i]])))
}

# Find common columns
common_cols <- Reduce(intersect, lapply(hud_list, names))
cat("\nCommon columns across all years:", length(common_cols), "\n")

# =============================================================================
# 3. Identify Key Variables
# =============================================================================

# Check what the columns look like in 2024 data
hud_2024 <- hud_list[[length(hud_list)]]
cat("\nSample columns from 2024:\n")
print(head(names(hud_2024), 30))

# Look for voucher-specific columns
voucher_cols <- names(hud_2024)[grepl("voucher|hcv|section_8|s8", names(hud_2024), ignore.case = TRUE)]
cat("\nVoucher-related columns:\n")
print(voucher_cols)

# Look for utilization columns
util_cols <- names(hud_2024)[grepl("util|lease|unit|total", names(hud_2024), ignore.case = TRUE)]
cat("\nUtilization-related columns:\n")
print(head(util_cols, 20))

# =============================================================================
# 4. Extract Key Variables
# =============================================================================

extract_key_vars <- function(df) {
  # Try to find state identifier
  state_col <- names(df)[grepl("^state$|state_name|states", names(df), ignore.case = TRUE)][1]

  # Try to find program type
  program_col <- names(df)[grepl("program|code", names(df), ignore.case = TRUE)][1]

  # Try to find total units
  units_col <- names(df)[grepl("total_units|number_reported|total", names(df), ignore.case = TRUE)][1]

  # Try to find households
  hh_col <- names(df)[grepl("people_total|total_households|hh_", names(df), ignore.case = TRUE)][1]

  cat(sprintf("Year %d: state=%s, program=%s, units=%s, hh=%s\n",
              df$year[1], state_col, program_col, units_col, hh_col))

  return(list(state = state_col, program = program_col, units = units_col, hh = hh_col))
}

# Check variables in each year
for (df in hud_list) {
  extract_key_vars(df)
}

# =============================================================================
# 5. Standardize and Combine Data
# =============================================================================

# Based on the HUD Picture data dictionary, key variables are:
# - States (state name)
# - program (program type: 1=Public Housing, 3=Housing Choice Voucher, etc.)
# - total_units
# - pct_occupied (occupancy rate)
# - people_total (total people)

standardize_hud <- function(df) {
  # Get year
  yr <- df$year[1]

  # Try to identify the correct columns
  # State column
  if ("states" %in% names(df)) {
    df$state_name <- df$states
  } else if ("state" %in% names(df)) {
    df$state_name <- df$state
  }

  # Filter to HCV program only (code = 3)
  if ("program" %in% names(df)) {
    df <- df %>% filter(program == 3 | grepl("voucher", program, ignore.case = TRUE))
  } else if ("code" %in% names(df)) {
    df <- df %>% filter(code == 3)
  }

  # Select and rename key variables
  result <- df %>%
    select(
      year,
      state_name,
      any_of(c("total_units", "number_reported", "reported")),
      any_of(c("pct_occupied", "occupied", "occupancy")),
      any_of(c("people_total", "total_people", "persons")),
      any_of(c("avg_hh_income", "hh_income", "income")),
      any_of(c("months_waiting", "waiting_months", "wait"))
    )

  return(result)
}

# Let's examine the 2024 data more carefully
cat("\n=== Examining 2024 HUD Data ===\n")
cat("First few rows:\n")
print(head(hud_2024[, 1:10]))

# =============================================================================
# 6. Create Analysis Panel (Alternative Approach)
# =============================================================================

# Since HUD data structure varies, let's create a simplified panel
# using state-year level aggregation

create_state_panel <- function(df) {
  yr <- df$year[1]

  # Find state column
  state_col <- NULL
  for (col in c("states", "state", "name")) {
    if (col %in% names(df)) {
      state_col <- col
      break
    }
  }

  if (is.null(state_col)) {
    cat("Could not find state column in year", yr, "\n")
    return(NULL)
  }

  # Get numeric columns
  num_cols <- names(df)[sapply(df, is.numeric)]

  # Filter to rows that look like states (not totals)
  df_states <- df %>%
    filter(nchar(as.character(get(state_col))) > 1) %>%
    filter(!grepl("total|u.s.|united|all|average", get(state_col), ignore.case = TRUE))

  result <- df_states %>%
    mutate(
      year = yr,
      state_name = get(state_col)
    ) %>%
    select(year, state_name, everything())

  return(result)
}

# Process each year
hud_panel_list <- lapply(hud_list, create_state_panel)
hud_panel_list <- hud_panel_list[!sapply(hud_panel_list, is.null)]

cat("\nProcessed", length(hud_panel_list), "years of data\n")

# Save raw combined data for inspection
if (length(hud_panel_list) > 0) {
  # Just save individual year files for now
  for (i in seq_along(hud_panel_list)) {
    yr <- hud_panel_list[[i]]$year[1]
    write_csv(hud_panel_list[[i]], sprintf("data/hud_state_%d_clean.csv", yr))
  }
  cat("Individual year files saved to data/hud_state_YYYY_clean.csv\n")
}

# =============================================================================
# 7. Merge with SOI Laws
# =============================================================================

# Create state name to abbreviation mapping
state_xwalk <- tibble(
  state_name = c("Alabama", "Alaska", "Arizona", "Arkansas", "California",
                 "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida",
                 "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
                 "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine",
                 "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi",
                 "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
                 "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
                 "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island",
                 "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah",
                 "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"),
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
)

# Merge SOI laws with crosswalk
soi_treatment <- soi_laws %>%
  select(state_abbr, effective_date, treat_year, law_strength) %>%
  right_join(state_xwalk, by = "state_abbr") %>%
  mutate(
    has_soi = !is.na(effective_date),
    treat_year = ifelse(is.na(treat_year), 9999, treat_year)  # Never treated = 9999
  )

write_csv(soi_treatment, "data/soi_treatment.csv")
cat("\nTreatment data saved: data/soi_treatment.csv\n")

# =============================================================================
# 8. Summary Statistics
# =============================================================================

cat("\n=== SUMMARY ===\n")
cat("States with SOI protection:", sum(soi_treatment$has_soi), "\n")
cat("States without SOI protection:", sum(!soi_treatment$has_soi), "\n")
cat("\nTreatment timing distribution:\n")
print(table(soi_treatment$treat_year[soi_treatment$treat_year < 9999]))

cat("\nData files created:\n")
list.files("data", pattern = "*.csv")
