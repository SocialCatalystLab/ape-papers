# =============================================================================
# 02_clean_data.R
# Clean and prepare ACS data for analysis
# =============================================================================

library(dplyr, warn.conflicts = FALSE)
library(readr)
library(stringr)

message("=== STARTING DATA CLEANING ===")

# Load raw data
df <- readRDS("output/paper_116/data/acs_raw.rds")
message(paste("Loaded", format(nrow(df), big.mark = ","), "observations"))

# Clean data
df_clean <- df %>%
  # Filter to employed workers (ESR = 1 or 2 means employed)
  filter(ESR %in% c(1, 2)) %>%
  
  # Remove workers with missing key variables
  filter(
    !is.na(COW),
    COW > 0,
    !is.na(WKHP),
    WKHP > 0
  ) %>%
  
  # Exclude government workers (COW 3,4,5)
  filter(!COW %in% c(3, 4, 5)) %>%
  
  # Create variables
  mutate(
    # Treatment
    self_employed = COW %in% c(6, 7),
    
    # Age groups
    age_group = case_when(
      AGEP >= 55 & AGEP <= 59 ~ "55-59",
      AGEP >= 60 & AGEP <= 64 ~ "60-64",
      AGEP >= 65 & AGEP <= 69 ~ "65-69",
      AGEP >= 70 & AGEP <= 74 ~ "70-74",
      TRUE ~ "Other"
    ),
    
    # Pre-Medicare vs Post-Medicare
    pre_medicare = AGEP < 65,
    
    # Post-ACA (2015+)
    post_aca = YEAR >= 2015,
    
    # Outcomes
    hours_weekly = WKHP,
    part_time = WKHP < 35,
    log_income = log(pmax(PINCP, 1)),
    
    # Demographics
    female = SEX == 2,
    
    race = case_when(
      RAC1P == 1 ~ "White",
      RAC1P == 2 ~ "Black",
      RAC1P %in% c(3,4,5) ~ "AIAN",
      RAC1P == 6 ~ "Asian",
      TRUE ~ "Other"
    ),
    
    married = MAR == 1,
    college = SCHL >= 21,
    
    education = case_when(
      SCHL <= 15 ~ "Less than HS",
      SCHL %in% 16:17 ~ "HS diploma",
      SCHL %in% 18:20 ~ "Some college",
      SCHL == 21 ~ "Bachelor's",
      SCHL >= 22 ~ "Graduate",
      TRUE ~ "Unknown"
    ),
    
    has_disability = DIS == 1,
    has_insurance = HICOV == 1,
    
    state_fips = sprintf("%02d", ST)
  )

message(paste("After cleaning:", format(nrow(df_clean), big.mark = ","), "observations"))

# Add Medicaid expansion status (2014 wave)
expansion_states_2014 <- c(
  "04", "05", "06", "08", "09", "10", "15", "17", "18", "19", "21", "23", 
  "24", "25", "26", "27", "28", "29", "32", "33", "34", "35", "36", "38", 
  "39", "41", "44", "50", "53", "54"
)

df_clean <- df_clean %>%
  mutate(
    medicaid_expansion = state_fips %in% expansion_states_2014,
    sample_main = pre_medicare,
    sample_placebo = !pre_medicare
  )

# Summary
message("\n=== SAMPLE SUMMARY ===")
message(paste("Total:", format(nrow(df_clean), big.mark = ",")))
message(paste("Self-employed:", format(sum(df_clean$self_employed), big.mark = ","), 
              "(", round(mean(df_clean$self_employed) * 100, 1), "%)"))

message("\nBy Age Group:")
df_clean %>%
  group_by(age_group) %>%
  summarize(
    n = n(),
    self_emp_rate = round(mean(self_employed) * 100, 1),
    mean_hours = round(mean(hours_weekly), 1),
    .groups = "drop"
  ) %>%
  print()

message("\nBy Self-Employment Status:")
df_clean %>%
  group_by(self_employed) %>%
  summarize(
    n = n(),
    mean_age = round(mean(AGEP), 1),
    mean_hours = round(mean(hours_weekly), 1),
    part_time_pct = round(mean(part_time) * 100, 1),
    female_pct = round(mean(female) * 100, 1),
    .groups = "drop"
  ) %>%
  print()

# Save
saveRDS(df_clean, "output/paper_116/data/acs_clean.rds")
write_csv(df_clean, "output/paper_116/data/acs_clean.csv")

message("\n=== DATA CLEANING COMPLETE ===")
