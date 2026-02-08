# ============================================================================
# Paper 74: Dental Therapy and Oral Health Access
# 02_fetch_brfss.R - Download and process BRFSS data
# ============================================================================

source("output/paper_74/code/00_packages.R")

# ============================================================================
# BRFSS Data Structure
# ============================================================================
#
# The Behavioral Risk Factor Surveillance System (BRFSS) is an annual
# telephone survey of health behaviors conducted by CDC.
#
# Dental health questions:
# - LASTDEN4 (2012+): When did you last visit dentist? (renamed from LASTDEN3)
# - RMVTETH4: How many teeth removed due to decay/disease?
#
# Variable availability changes over time:
# - 2000-2011: LASTDEN3 used different coding
# - 2012+: LASTDEN4 with consistent coding
#
# We focus on 2012-2023 for consistent variable definitions.
# This still provides:
# - 3 years pre-treatment for MN (2009)
# - Actually MN 2009 is before 2012, so we effectively measure post-2012 effects
# - Good pre-treatment for ME (2014), VT (2016), and later adopters
# ============================================================================

# Create data directory
dir.create("output/paper_74/data/brfss", recursive = TRUE, showWarnings = FALSE)

# ============================================================================
# Download BRFSS Annual Files (SAS Transport format)
# ============================================================================

# BRFSS files are large (100-300 MB each). Download only what we need.
# CDC hosts files at:
# https://www.cdc.gov/brfss/annual_data/annual_{year}.html

years <- 2012:2023

download_brfss <- function(year) {
  # CDC changed URL structure over time
  if (year >= 2021) {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%d_XPT.zip",
      year, year
    )
  } else if (year >= 2011) {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%d.XPT",
      year, year
    )
  } else {
    url <- sprintf(
      "https://www.cdc.gov/brfss/annual_data/%d/files/CDBRFS%02d.XPT",
      year, year %% 100
    )
  }

  dest_zip <- sprintf("output/paper_74/data/brfss/BRFSS_%d.zip", year)
  dest_xpt <- sprintf("output/paper_74/data/brfss/BRFSS_%d.XPT", year)

  if (file.exists(dest_xpt)) {
    cat(sprintf("Year %d already downloaded.\n", year))
    return(dest_xpt)
  }

  cat(sprintf("Downloading BRFSS %d...\n", year))

  tryCatch({
    if (grepl("\\.zip$", url)) {
      download.file(url, dest_zip, mode = "wb", quiet = TRUE)
      unzip(dest_zip, exdir = dirname(dest_zip))
      file.remove(dest_zip)
      # Find the extracted XPT file
      xpt_files <- list.files(dirname(dest_zip), pattern = "\\.XPT$", full.names = TRUE)
      if (length(xpt_files) > 0) {
        file.rename(xpt_files[1], dest_xpt)
      }
    } else {
      download.file(url, dest_xpt, mode = "wb", quiet = TRUE)
    }
    cat(sprintf("  Downloaded: %s\n", dest_xpt))
    return(dest_xpt)
  }, error = function(e) {
    warning(sprintf("Failed to download %d: %s", year, e$message))
    return(NULL)
  })
}

# Download all years
cat("Downloading BRFSS data files...\n")
cat("Note: Files are 100-300 MB each. This may take some time.\n\n")

downloaded_files <- map(years, download_brfss)

# ============================================================================
# Read and Extract Dental Variables
# ============================================================================

extract_dental_data <- function(year) {
  file_path <- sprintf("output/paper_74/data/brfss/BRFSS_%d.XPT", year)

  if (!file.exists(file_path)) {
    warning(sprintf("File not found for year %d", year))
    return(NULL)
  }

  cat(sprintf("Processing year %d...\n", year))

  # Read SAS transport file
  df <- haven::read_xpt(file_path)

  # Convert column names to uppercase for consistency
  names(df) <- toupper(names(df))

  # State FIPS variable
  state_var <- if ("_STATE" %in% names(df)) "_STATE" else "STATE"

  # Dental visit variable (coding changed over time)
  dental_var <- case_when(
    "LASTDEN4" %in% names(df) ~ "LASTDEN4",
    "LASTDEN3" %in% names(df) ~ "LASTDEN3",
    "LASTDENT" %in% names(df) ~ "LASTDENT",
    TRUE ~ NA_character_
  )

  if (is.na(dental_var)) {
    warning(sprintf("No dental variable found for year %d", year))
    return(NULL)
  }

  # Teeth removed variable
  teeth_var <- case_when(
    "RMVTETH4" %in% names(df) ~ "RMVTETH4",
    "RMVTETH3" %in% names(df) ~ "RMVTETH3",
    TRUE ~ NA_character_
  )

  # Extract and recode
  dental_df <- df %>%
    select(
      state_fips = all_of(state_var),
      dental_visit = all_of(dental_var),
      teeth_removed = if (!is.na(teeth_var)) all_of(teeth_var) else NULL
    ) %>%
    mutate(
      year = year,
      state_fips = sprintf("%02d", as.integer(state_fips)),

      # Recode dental visit
      # 1 = Within past year, 2 = 1-2 years, 3 = 2-5 years, 4 = 5+ years, 8 = Never
      # 7 = Don't know, 9 = Refused
      visited_past_year = case_when(
        dental_visit == 1 ~ 1L,
        dental_visit %in% c(2, 3, 4, 8) ~ 0L,
        TRUE ~ NA_integer_
      ),

      # Recode teeth removed
      # 1 = 1-5 teeth, 2 = 6+ but not all, 3 = All, 8 = None
      # 7 = Don't know, 9 = Refused
      any_teeth_removed = case_when(
        teeth_removed %in% c(1, 2, 3) ~ 1L,
        teeth_removed == 8 ~ 0L,
        TRUE ~ NA_integer_
      )
    ) %>%
    filter(
      # Exclude territories
      as.integer(state_fips) <= 56,
      # Keep only valid responses
      !is.na(visited_past_year)
    )

  return(dental_df)
}

# Process all years
cat("\nExtracting dental variables from BRFSS files...\n")
dental_data <- map(years, extract_dental_data)
dental_data <- bind_rows(dental_data[!sapply(dental_data, is.null)])

cat(sprintf("\nTotal observations: %s\n", format(nrow(dental_data), big.mark = ",")))

# ============================================================================
# Aggregate to State-Year Level
# ============================================================================

state_year_data <- dental_data %>%
  group_by(state_fips, year) %>%
  summarise(
    n_respondents = n(),
    dental_visit_rate = mean(visited_past_year, na.rm = TRUE),
    teeth_removed_rate = mean(any_teeth_removed, na.rm = TRUE),
    dental_visit_se = sd(visited_past_year, na.rm = TRUE) / sqrt(sum(!is.na(visited_past_year))),
    teeth_removed_se = sd(any_teeth_removed, na.rm = TRUE) / sqrt(sum(!is.na(any_teeth_removed))),
    .groups = "drop"
  )

cat(sprintf("State-year observations: %d\n", nrow(state_year_data)))
cat(sprintf("Years covered: %d-%d\n", min(state_year_data$year), max(state_year_data$year)))

# ============================================================================
# Merge with Treatment Timing
# ============================================================================

treatment_data <- readRDS("output/paper_74/data/treatment_timing.rds")

analysis_data <- state_year_data %>%
  left_join(
    treatment_data %>% select(state_fips, state, treatment_year),
    by = "state_fips"
  ) %>%
  mutate(
    # Post-treatment indicator
    post = if_else(treatment_year > 0 & year >= treatment_year, 1L, 0L),

    # Treated indicator (ever treated)
    treated = if_else(treatment_year > 0, 1L, 0L),

    # Event time (years since treatment)
    event_time = if_else(treatment_year > 0, year - treatment_year, NA_integer_)
  )

# Verify
cat("\nTreatment status summary:\n")
analysis_data %>%
  group_by(treated) %>%
  summarise(
    n_obs = n(),
    n_states = n_distinct(state_fips),
    mean_visit_rate = mean(dental_visit_rate)
  ) %>%
  print()

# ============================================================================
# Save
# ============================================================================

saveRDS(analysis_data, "output/paper_74/data/analysis_data.rds")
write_csv(analysis_data, "output/paper_74/data/analysis_data.csv")

cat("\nData saved to:\n")
cat("  - output/paper_74/data/analysis_data.rds\n")
cat("  - output/paper_74/data/analysis_data.csv\n")

# ============================================================================
# Quick Visualization
# ============================================================================

# Raw trends by treatment status
p <- analysis_data %>%
  mutate(group = if_else(treated == 1, "Adopter States", "Never-Adopter States")) %>%
  group_by(year, group) %>%
  summarise(dental_visit_rate = mean(dental_visit_rate), .groups = "drop") %>%
  ggplot(aes(x = year, y = dental_visit_rate, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_y_continuous(labels = percent_format()) +
  labs(
    title = "Dental Visit Rates by Treatment Status",
    subtitle = "BRFSS 2012-2023",
    x = "Year",
    y = "Visited Dentist in Past Year",
    color = NULL
  ) +
  theme_apep()

ggsave("output/paper_74/figures/raw_trends.pdf", p, width = 8, height = 5)
ggsave("output/paper_74/figures/raw_trends.png", p, width = 8, height = 5, dpi = 300)

cat("\nRaw trends plot saved to figures/raw_trends.pdf\n")
