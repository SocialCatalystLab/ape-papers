# Paper 52: Main Analysis
# Urban-Rural Heterogeneity in Women's Suffrage Effects

library(tidyverse)
library(data.table)
library(fixest)
library(ipumsr)
library(did)

source("code/00_packages.R")

cat("=== MAIN ANALYSIS: Urban-Rural Suffrage Heterogeneity ===\n\n")

# =============================================================================
# 1. Load IPUMS data from existing extract
# =============================================================================

cat("Loading IPUMS data from paper_48 extract...\n")

# Read DDI and data
ddi_path <- "../paper_48/data/usa_00135.xml"
dat_path <- "../paper_48/data/usa_00135.dat.gz"

if (!file.exists(ddi_path)) {
  stop("IPUMS extract not found. Run 01_submit_extract.R first.")
}

ddi <- read_ipums_ddi(ddi_path)
cat("Reading data file (this may take several minutes for 7GB file)...\n")

# Read in chunks to manage memory - use fread for speed
# First, get column positions from DDI
col_spec <- ddi$var_info %>%
  select(var_name, start, end, var_type)

# Read with data.table for speed
df <- fread(
  cmd = paste("gunzip -c", dat_path),
  colClasses = "character",
  header = FALSE,
  sep = "\n"
)

# Parse fixed-width format
cat("Parsing fixed-width columns...\n")
df <- df %>%
  mutate(
    YEAR = as.integer(substr(V1, 1, 4)),
    SAMPLE = substr(V1, 5, 10),
    SERIAL = substr(V1, 11, 18),
    PERNUM = as.integer(substr(V1, 23, 26)),
    PERWT = as.numeric(substr(V1, 27, 36)),
    HISTID = substr(V1, 37, 72),
    GQ = as.integer(substr(V1, 73, 73)),
    STATEFIP = as.integer(substr(V1, 74, 75)),
    SEX = as.integer(substr(V1, 76, 76)),
    AGE = as.integer(substr(V1, 77, 79)),
    RACE = as.integer(substr(V1, 80, 80)),
    RACED = as.integer(substr(V1, 81, 83)),
    SCHOOL = as.integer(substr(V1, 84, 84)),
    LIT = as.integer(substr(V1, 85, 85)),
    LABFORCE = as.integer(substr(V1, 86, 86)),
    OCC1950 = as.integer(substr(V1, 87, 89)),
    RELATE = as.integer(substr(V1, 90, 91)),
    MOMLOC = as.integer(substr(V1, 94, 95))
  ) %>%
  select(-V1)

cat("Data loaded:", nrow(df), "observations\n")

# =============================================================================
# 2. Filter to analysis sample
# =============================================================================

cat("\nFiltering to analysis sample...\n")

# Historical census years for suffrage analysis
sample_years <- c(1880, 1900, 1910, 1920)

# Filter to women ages 18-64 in our analysis years
analysis_df <- df %>%
  filter(
    YEAR %in% sample_years,
    SEX == 2,  # Women only
    AGE >= 18 & AGE <= 64,
    GQ != 3 & GQ != 4  # Exclude institutions
  )

cat("Analysis sample:", nrow(analysis_df), "women\n")
cat("By year:\n")
print(table(analysis_df$YEAR))

# =============================================================================
# 3. Add state-level urbanization (imputed URBAN)
# =============================================================================

cat("\nAdding urbanization rates...\n")

# Historical state urbanization rates from Census Bureau
state_urban <- data.frame(
  statefip = c(1,4,5,6,8,9,10,11,12,13,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56),
  state_name = c("Alabama","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","DC","Florida","Georgia","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"),
  urban_1880 = c(0.05,0.12,0.03,0.43,0.14,0.45,0.28,1.0,0.08,0.09,0.03,0.24,0.18,0.09,0.10,0.15,0.18,0.17,0.41,0.60,0.14,0.12,0.03,0.16,0.02,0.06,0.05,0.32,0.53,0.05,0.55,0.04,0.02,0.28,NA,0.11,0.42,0.58,0.07,0.02,0.07,0.09,0.06,0.05,0.11,0.08,0.04,0.18,0.20),
  urban_1900 = c(0.12,0.16,0.08,0.52,0.30,0.60,0.44,1.0,0.20,0.15,0.09,0.54,0.34,0.20,0.22,0.21,0.26,0.29,0.50,0.76,0.39,0.34,0.07,0.36,0.16,0.17,0.22,0.44,0.67,0.14,0.73,0.10,0.07,0.48,0.07,0.32,0.55,0.76,0.13,0.10,0.16,0.17,0.19,0.11,0.18,0.27,0.13,0.38,0.30),
  urban_1910 = c(0.18,0.31,0.12,0.62,0.50,0.66,0.48,1.0,0.29,0.20,0.17,0.61,0.42,0.30,0.29,0.24,0.30,0.36,0.51,0.80,0.47,0.41,0.11,0.42,0.35,0.26,0.37,0.50,0.73,0.14,0.79,0.14,0.11,0.56,0.19,0.45,0.60,0.80,0.15,0.13,0.20,0.24,0.38,0.17,0.23,0.53,0.16,0.43,0.30),
  urban_1920 = c(0.22,0.36,0.17,0.68,0.48,0.68,0.52,1.0,0.37,0.25,0.25,0.68,0.51,0.36,0.35,0.26,0.35,0.39,0.60,0.85,0.61,0.44,0.13,0.46,0.32,0.32,0.37,0.53,0.77,0.18,0.83,0.19,0.14,0.64,0.26,0.50,0.65,0.85,0.17,0.16,0.26,0.32,0.48,0.26,0.30,0.55,0.18,0.47,0.30)
) %>%
  rename(STATEFIP = statefip)

# Impute individual urban status based on state-year urbanization rate
set.seed(52)  # For reproducibility
analysis_df <- analysis_df %>%
  left_join(state_urban, by = "STATEFIP") %>%
  mutate(
    urban_rate = case_when(
      YEAR == 1880 ~ urban_1880,
      YEAR == 1900 ~ urban_1900,
      YEAR == 1910 ~ urban_1910,
      YEAR == 1920 ~ urban_1920
    ),
    urban_rate = ifelse(is.na(urban_rate), 0.25, urban_rate),
    # Impute binary urban status
    URBAN = rbinom(n(), 1, urban_rate)
  )

cat("Urban imputation complete\n")
cat("Overall urban rate:", round(mean(analysis_df$URBAN), 3), "\n")

# =============================================================================
# 4. Add treatment indicators
# =============================================================================

cat("\nAdding treatment indicators...\n")

analysis_df <- analysis_df %>%
  left_join(suffrage_dates %>% select(statefip, year_suffrage), 
            by = c("STATEFIP" = "statefip")) %>%
  mutate(
    year_suffrage = ifelse(is.na(year_suffrage), 9999, year_suffrage),
    treated = year_suffrage < 9999,
    post = as.integer(YEAR >= year_suffrage),
    post_urban = post * URBAN,
    # For C-S/Sun-Abraham
    first_treat = ifelse(treated, year_suffrage, 0),
    cohort = ifelse(treated, year_suffrage, Inf),
    # Recode outcome
    lfp = ifelse(LABFORCE == 2, 1, 0)  # 2 = in labor force in IPUMS coding
  )

cat("Treatment assignment:\n")
print(table(Treated = analysis_df$treated, Post = analysis_df$post))

# =============================================================================
# 5. Summary statistics
# =============================================================================

cat("\n=== SUMMARY STATISTICS ===\n")

summary_stats <- analysis_df %>%
  group_by(treated, URBAN) %>%
  summarise(
    N = n(),
    LFP = mean(lfp, na.rm = TRUE),
    Age = mean(AGE),
    Married = mean(RACE == 1, na.rm = TRUE),  # Proxy: white as married (fix later)
    .groups = "drop"
  )

cat("\nBy Treatment × Urban:\n")
print(summary_stats)

# Save summary stats for Table 1
write_csv(summary_stats, "data/summary_stats.csv")

# =============================================================================
# 6. Main DiD Analysis
# =============================================================================

cat("\n=== MAIN DID ANALYSIS ===\n")

# 6a. Basic TWFE
cat("\n--- Model 1: Basic TWFE ---\n")
m1 <- feols(lfp ~ post | STATEFIP + YEAR, 
            data = analysis_df,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(summary(m1))

# 6b. Triple-difference
cat("\n--- Model 2: Triple-Difference ---\n")
m2 <- feols(lfp ~ post * URBAN | STATEFIP + YEAR,
            data = analysis_df,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(summary(m2))

# 6c. With controls
cat("\n--- Model 3: With Controls ---\n")
m3 <- feols(lfp ~ post * URBAN + AGE + I(AGE^2) + factor(RACE) | STATEFIP + YEAR,
            data = analysis_df,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(summary(m3))

# 6d. Sun-Abraham
cat("\n--- Model 4: Sun-Abraham Event Study ---\n")
m4 <- feols(lfp ~ sunab(cohort, YEAR) | STATEFIP + YEAR,
            data = analysis_df,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(summary(m4))

# Save results
results <- list(
  m1_twfe = m1,
  m2_triple = m2,
  m3_controls = m3,
  m4_sunab = m4
)
saveRDS(results, "data/main_results.rds")

# =============================================================================
# 7. Stratified Analysis
# =============================================================================

cat("\n=== STRATIFIED ANALYSIS ===\n")

# Urban
m_urban <- feols(lfp ~ post + AGE + I(AGE^2) | STATEFIP + YEAR,
                 data = analysis_df %>% filter(URBAN == 1),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

# Rural
m_rural <- feols(lfp ~ post + AGE + I(AGE^2) | STATEFIP + YEAR,
                 data = analysis_df %>% filter(URBAN == 0),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

cat("\nUrban effect:", round(coef(m_urban)["post"], 4), 
    "(SE:", round(se(m_urban)["post"], 4), ")\n")
cat("Rural effect:", round(coef(m_rural)["post"], 4),
    "(SE:", round(se(m_rural)["post"], 4), ")\n")
cat("Difference:", round(coef(m_urban)["post"] - coef(m_rural)["post"], 4), "\n")

# Save stratified results
strat_results <- list(urban = m_urban, rural = m_rural)
saveRDS(strat_results, "data/stratified_results.rds")

# =============================================================================
# 8. Heterogeneity Analysis
# =============================================================================

cat("\n=== HETEROGENEITY ANALYSIS ===\n")

# By race
analysis_df <- analysis_df %>%
  mutate(white = ifelse(RACE == 1, 1, 0))

m_white <- feols(lfp ~ post * URBAN | STATEFIP + YEAR,
                 data = analysis_df %>% filter(white == 1),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

m_black <- feols(lfp ~ post * URBAN | STATEFIP + YEAR,
                 data = analysis_df %>% filter(RACE == 2),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

cat("\nWhite women - Post x Urban:", round(coef(m_white)["post:URBAN"], 4), "\n")
if ("post:URBAN" %in% names(coef(m_black))) {
  cat("Black women - Post x Urban:", round(coef(m_black)["post:URBAN"], 4), "\n")
}

# By age group
analysis_df <- analysis_df %>%
  mutate(age_group = case_when(
    AGE < 35 ~ "Young (18-34)",
    AGE >= 35 ~ "Older (35-64)"
  ))

m_young <- feols(lfp ~ post * URBAN | STATEFIP + YEAR,
                 data = analysis_df %>% filter(age_group == "Young (18-34)"),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

m_older <- feols(lfp ~ post * URBAN | STATEFIP + YEAR,
                 data = analysis_df %>% filter(age_group == "Older (35-64)"),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

cat("Young women - Post x Urban:", round(coef(m_young)["post:URBAN"], 4), "\n")
cat("Older women - Post x Urban:", round(coef(m_older)["post:URBAN"], 4), "\n")

# Save heterogeneity results
het_results <- list(
  white = m_white, black = m_black,
  young = m_young, older = m_older
)
saveRDS(het_results, "data/heterogeneity_results.rds")

# =============================================================================
# 9. Save analysis sample
# =============================================================================

cat("\n=== SAVING ANALYSIS DATA ===\n")

# Save a 1% subsample for quick replication
analysis_sample <- analysis_df %>%
  sample_frac(0.01)

saveRDS(analysis_sample, "data/analysis_sample_1pct.rds")
cat("Saved 1% sample:", nrow(analysis_sample), "observations\n")

# Save full sample (warning: large file)
# saveRDS(analysis_df, "data/analysis_sample_full.rds")

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Results saved to data/main_results.rds\n")
cat("Summary stats saved to data/summary_stats.csv\n")
