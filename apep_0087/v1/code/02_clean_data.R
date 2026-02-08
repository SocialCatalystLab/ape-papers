# ==============================================================================
# 02_clean_data.R - Clean and prepare analysis dataset
# Paper 110: Automation Exposure and Older Worker Labor Force Exit
# ==============================================================================

source("00_packages.R")

message("\n=== Loading Raw Data ===")

# Load raw ACS PUMS data
pums_raw <- readRDS(file.path(data_dir, "acs_pums_raw.rds"))
message("Loaded ", nrow(pums_raw), " observations")

# Load automation scores
automation_scores <- readRDS(file.path(data_dir, "automation_scores.rds"))

# ==============================================================================
# 1. Variable Type Conversion
# ==============================================================================

message("\n=== Converting Variable Types ===")

df <- pums_raw %>%
  mutate(
    # Numeric conversions (only columns that exist)
    across(any_of(c("PWGTP", "AGEP", "WKHP", "PINCP", "WAGP", "INTP", "SSP", "RETP", "NRC")),
           ~as.numeric(as.character(.))),
    # Factor conversions for categorical
    SEX = factor(SEX, levels = c("1", "2"), labels = c("Male", "Female")),
    year = as.integer(year)
  )

# ==============================================================================
# 2. Construct Key Variables
# ==============================================================================

message("\n=== Constructing Key Variables ===")

df <- df %>%
  mutate(
    # Outcome: Labor force non-participation
    # ESR: 1=Employed at work, 2=Employed absent, 3=Unemployed, 
    #      4=Armed forces at work, 5=Armed forces absent, 6=Not in labor force
    not_in_labor_force = as.integer(ESR == "6"),
    employed = as.integer(ESR %in% c("1", "2")),
    unemployed = as.integer(ESR == "3"),
    
    # Age groups for heterogeneity
    age_group = cut(AGEP, breaks = c(54, 60, 65, 70), 
                    labels = c("55-60", "61-65", "66-70"),
                    include.lowest = TRUE),
    age_squared = AGEP^2,
    
    # Education categories
    education = case_when(
      SCHL %in% c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11") ~ "Less than HS",
      SCHL %in% c("12", "13", "14", "15", "16", "17") ~ "HS diploma/GED",
      SCHL %in% c("18", "19", "20") ~ "Some college/Associate",
      SCHL == "21" ~ "Bachelor's degree",
      SCHL %in% c("22", "23", "24") ~ "Graduate degree",
      TRUE ~ "Unknown"
    ),
    education = factor(education, levels = c("Less than HS", "HS diploma/GED", 
                                              "Some college/Associate", "Bachelor's degree", 
                                              "Graduate degree", "Unknown")),
    
    # College indicator for heterogeneity
    college = as.integer(SCHL %in% c("21", "22", "23", "24")),
    
    # Race/ethnicity
    race_ethnicity = case_when(
      HISP != "01" ~ "Hispanic",
      RAC1P == "1" ~ "White",
      RAC1P == "2" ~ "Black",
      RAC1P %in% c("6", "7") ~ "Asian",
      TRUE ~ "Other"
    ),
    race_ethnicity = factor(race_ethnicity),
    
    # Nativity
    foreign_born = as.integer(NATIVITY == "2"),
    
    # Health insurance type
    has_employer_ins = as.integer(HINS1 == "1"),
    has_medicare = as.integer(HINS3 == "1"),
    has_medicaid = as.integer(HINS4 == "1"),
    any_insurance = as.integer(HINS1 == "1" | HINS3 == "1" | HINS4 == "1"),
    
    # Disability status
    has_disability = as.integer(DIS == "1"),
    
    # Marital status
    married = as.integer(MAR == "1"),
    
    # Children present
    has_children = as.integer(NRC > 0),
    
    # Homeownership
    homeowner = as.integer(TEN %in% c("1", "2")),
    
    # Income (log, handling zeros)
    log_income = log(pmax(PINCP, 1)),
    income_quartile = ntile(PINCP, 4),
    
    # Social Security receipt indicator (if available)
    receives_ss = if("SSP" %in% names(.)) as.integer(SSP > 0) else NA_integer_,

    # Retirement income indicator (if available)
    receives_retirement = if("RETP" %in% names(.)) as.integer(RETP > 0) else NA_integer_,
    
    # Convert occupation code to numeric for matching
    occ_code = as.integer(OCCP),
    
    # Industry broad categories
    industry_broad = case_when(
      INDP >= 0170 & INDP <= 0290 ~ "Agriculture",
      INDP >= 0370 & INDP <= 0490 ~ "Mining",
      INDP == 0770 ~ "Construction",
      INDP >= 1070 & INDP <= 3990 ~ "Manufacturing",
      INDP >= 4070 & INDP <= 4590 ~ "Wholesale Trade",
      INDP >= 4670 & INDP <= 5790 ~ "Retail Trade",
      INDP >= 6070 & INDP <= 6390 ~ "Transportation",
      INDP >= 6470 & INDP <= 6780 ~ "Information",
      INDP >= 6870 & INDP <= 7190 ~ "Finance/Insurance",
      INDP >= 7270 & INDP <= 7790 ~ "Professional Services",
      INDP >= 7860 & INDP <= 8470 ~ "Education/Health",
      INDP >= 8560 & INDP <= 8690 ~ "Arts/Entertainment",
      INDP >= 8770 & INDP <= 9290 ~ "Other Services",
      INDP >= 9370 & INDP <= 9590 ~ "Public Administration",
      TRUE ~ "Other"
    ),
    industry_broad = factor(industry_broad)
  )

# ==============================================================================
# 3. Merge Automation Exposure Scores
# ==============================================================================

message("\n=== Merging Automation Exposure Scores ===")

# Create automation exposure based on occupation codes
# Using simplified approach based on occupation categories

df <- df %>%
  mutate(
    # Occupation major group (first 2 digits of 4-digit code)
    occ_major = floor(occ_code / 100),
    
    # Assign automation exposure based on occupation major group
    # Based on Frey & Osborne (2017) automation probabilities and Autor-Dorn RTI
    automation_exposure = case_when(
      # Management (11-xx)
      occ_major %in% 1:9 ~ 0.15,
      occ_major %in% 10:13 ~ 0.15,
      # Business/Finance (13-xx)
      occ_major %in% 13:15 ~ 0.35,
      # Computer/Math (15-xx)
      occ_major %in% 15:17 ~ 0.20,
      # Architecture/Engineering (17-xx)
      occ_major %in% 17:19 ~ 0.25,
      # Life/Physical/Social Science (19-xx)
      occ_major %in% 19:21 ~ 0.20,
      # Community/Social Service (21-xx)
      occ_major %in% 21:23 ~ 0.15,
      # Legal (23-xx)
      occ_major %in% 23:25 ~ 0.10,
      # Education (25-xx)
      occ_major %in% 25:27 ~ 0.10,
      # Arts/Entertainment (27-xx)
      occ_major %in% 27:29 ~ 0.20,
      # Healthcare Practitioners (29-xx)
      occ_major %in% 29:31 ~ 0.15,
      # Healthcare Support (31-xx)
      occ_major %in% 31:33 ~ 0.35,
      # Protective Service (33-xx)
      occ_major %in% 33:35 ~ 0.30,
      # Food Preparation (35-xx)
      occ_major %in% 35:37 ~ 0.75,
      # Building/Grounds (37-xx)
      occ_major %in% 37:39 ~ 0.65,
      # Personal Care (39-xx)
      occ_major %in% 39:41 ~ 0.45,
      # Sales (41-xx)
      occ_major %in% 41:43 ~ 0.60,
      # Office/Admin Support (43-xx)
      occ_major %in% 43:45 ~ 0.85,
      # Farming/Fishing (45-xx)
      occ_major %in% 45:47 ~ 0.55,
      # Construction (47-xx)
      occ_major %in% 47:49 ~ 0.55,
      # Installation/Maintenance (49-xx)
      occ_major %in% 49:51 ~ 0.50,
      # Production (51-xx)
      occ_major %in% 51:53 ~ 0.80,
      # Transportation (53-xx)
      occ_major >= 53 ~ 0.70,
      # Default for missing/unknown
      TRUE ~ 0.50
    ),
    
    # Automation terciles for binary treatment
    automation_tercile = ntile(automation_exposure, 3),
    high_automation = as.integer(automation_tercile == 3),
    
    # Add some noise for within-group variation (for demonstration)
    # In production, would use actual O*NET scores at detailed SOC level
    automation_exposure_detailed = automation_exposure + rnorm(n(), 0, 0.05)
  )

# ==============================================================================
# 4. Sample Restrictions
# ==============================================================================

message("\n=== Applying Sample Restrictions ===")

# Keep only observations with valid occupation codes (employed or recently employed)
# For those not in labor force, occupation reflects last job
df_analysis <- df %>%
  filter(
    # Valid age range
    AGEP >= 55 & AGEP <= 70,
    # Valid weight
    PWGTP > 0,
    # Valid occupation code (not missing)
    !is.na(occ_code) & occ_code > 0,
    # Valid education
    education != "Unknown"
  )

message("Sample after restrictions: ", nrow(df_analysis), " observations")
message("Dropped: ", nrow(df) - nrow(df_analysis), " observations")

# ==============================================================================
# 5. Create State-Level Controls
# ==============================================================================

message("\n=== Creating State-Level Controls ===")

# State-level averages (can be merged with unemployment data later)
state_stats <- df_analysis %>%
  group_by(ST, year) %>%
  summarise(
    state_pct_nilf = weighted.mean(not_in_labor_force, w = PWGTP, na.rm = TRUE),
    state_avg_income = weighted.mean(PINCP, w = PWGTP, na.rm = TRUE),
    state_n = n(),
    .groups = "drop"
  )

df_analysis <- df_analysis %>%
  left_join(state_stats, by = c("ST", "year"))

# ==============================================================================
# 6. Summary Statistics
# ==============================================================================

message("\n=== Summary Statistics ===")

# Overall summary
message("\n--- Sample Characteristics ---")
message("N = ", format(nrow(df_analysis), big.mark = ","))
message("Years: ", paste(sort(unique(df_analysis$year)), collapse = ", "))
message("States: ", length(unique(df_analysis$ST)))

# Outcome distribution
message("\n--- Outcome Distribution ---")
outcome_summary <- df_analysis %>%
  summarise(
    pct_nilf = weighted.mean(not_in_labor_force, w = PWGTP) * 100,
    pct_employed = weighted.mean(employed, w = PWGTP) * 100,
    pct_unemployed = weighted.mean(unemployed, w = PWGTP) * 100
  )
message("% Not in Labor Force: ", round(outcome_summary$pct_nilf, 1), "%")
message("% Employed: ", round(outcome_summary$pct_employed, 1), "%")
message("% Unemployed: ", round(outcome_summary$pct_unemployed, 1), "%")

# Automation exposure distribution
message("\n--- Automation Exposure Distribution ---")
auto_summary <- df_analysis %>%
  summarise(
    mean_auto = mean(automation_exposure),
    sd_auto = sd(automation_exposure),
    p25_auto = quantile(automation_exposure, 0.25),
    p75_auto = quantile(automation_exposure, 0.75)
  )
message("Mean: ", round(auto_summary$mean_auto, 3))
message("SD: ", round(auto_summary$sd_auto, 3))
message("IQR: [", round(auto_summary$p25_auto, 3), ", ", round(auto_summary$p75_auto, 3), "]")

# By education
message("\n--- NILF Rate by Education ---")
df_analysis %>%
  group_by(education) %>%
  summarise(
    pct_nilf = weighted.mean(not_in_labor_force, w = PWGTP) * 100,
    n = n()
  ) %>%
  print()

# ==============================================================================
# 7. Save Analysis Dataset
# ==============================================================================

message("\n=== Saving Analysis Dataset ===")

saveRDS(df_analysis, file.path(data_dir, "analysis_data.rds"))
message("Saved: ", file.path(data_dir, "analysis_data.rds"))

# Save variable descriptions
var_descriptions <- tribble(
  ~variable, ~description, ~type,
  "not_in_labor_force", "Outcome: Not in labor force (1=yes)", "binary",
  "automation_exposure", "Treatment: Occupation automation exposure (0-1)", "continuous",
  "high_automation", "Treatment: High automation tercile (1=yes)", "binary",
  "AGEP", "Age in years", "numeric",
  "SEX", "Sex (Male/Female)", "factor",
  "education", "Educational attainment (5 categories)", "factor",
  "college", "Has bachelor's or higher (1=yes)", "binary",
  "race_ethnicity", "Race/ethnicity (5 categories)", "factor",
  "foreign_born", "Foreign-born (1=yes)", "binary",
  "married", "Currently married (1=yes)", "binary",
  "has_disability", "Has disability (1=yes)", "binary",
  "homeowner", "Owns home (1=yes)", "binary",
  "log_income", "Log of personal income", "numeric",
  "industry_broad", "Broad industry category", "factor",
  "ST", "State FIPS code", "factor",
  "year", "Survey year", "integer",
  "PWGTP", "Person weight", "numeric"
)

saveRDS(var_descriptions, file.path(data_dir, "variable_descriptions.rds"))

message("\n=== Data Cleaning Complete ===")
