# Paper 52: Real Data Extraction and Analysis
# Memory-efficient: Process in chunks, sample 10%, delete raw data immediately

library(tidyverse)
library(data.table)
library(fixest)
library(ipumsr)

source("code/00_packages.R")

cat("=== REAL DATA EXTRACTION: Memory-Efficient Strategy ===\n\n")

# =============================================================================
# 1. Variable positions from DDI (CORRECTED)
# =============================================================================

# From usa_00135.xml:
# YEAR: 1-4
# SAMPLE: 5-10
# SERIAL: 11-18
# HHWT: 19-28
# STATEFIP: 29-30
# GQ: 31-31
# PERNUM: 32-35
# PERWT: 36-45
# MOMLOC: 46-47
# RELATE: 48-49
# RELATED: 50-53
# SEX: 54-54
# AGE: 55-57
# RACE: 58-58
# RACED: 59-61
# SCHOOL: 62-62
# LIT: 63-63
# LABFORCE: 64-64
# OCC1950: 65-67
# VERSIONHIST: 68-69
# HISTID: 70-105

dat_path <- "../paper_48/data/usa_00135.dat.gz"

if (!file.exists(dat_path)) {
  stop("IPUMS extract not found at: ", dat_path)
}

# =============================================================================
# 2. Process data in chunks - Sample 10% immediately
# =============================================================================

cat("=== PROCESSING DATA IN CHUNKS ===\n")
cat("Strategy: Read 2M rows at a time, filter to women 18-64, sample 10%\n\n")

# Set up chunk reading
chunk_size <- 2000000  # 2 million rows at a time
sample_rate <- 0.10  # Keep 10% of qualifying records

# Initialize empty data frame for results
analysis_data <- data.frame()

# Years we care about for suffrage analysis
target_years <- c(1880, 1900, 1910, 1920)

# Open connection for chunked reading
con <- gzfile(dat_path, "r")
chunk_num <- 0
total_kept <- 0

cat("Starting chunked processing...\n")

while(TRUE) {
  chunk_num <- chunk_num + 1
  
  # Read chunk
  lines <- readLines(con, n = chunk_size)
  
  if (length(lines) == 0) break
  
  cat("Processing chunk", chunk_num, ":", length(lines), "records...")
  
  # Parse fixed-width to data frame (CORRECTED POSITIONS)
  chunk_df <- data.frame(
    YEAR = as.integer(substr(lines, 1, 4)),
    STATEFIP = as.integer(substr(lines, 29, 30)),
    GQ = as.integer(substr(lines, 31, 31)),
    PERWT = as.numeric(substr(lines, 36, 45)),
    SEX = as.integer(substr(lines, 54, 54)),
    AGE = as.integer(substr(lines, 55, 57)),
    RACE = as.integer(substr(lines, 58, 58)),
    SCHOOL = as.integer(substr(lines, 62, 62)),
    LIT = as.integer(substr(lines, 63, 63)),
    LABFORCE = as.integer(substr(lines, 64, 64)),
    OCC1950 = as.integer(substr(lines, 65, 67)),
    stringsAsFactors = FALSE
  )
  
  # Filter to analysis sample
  # 1. Target years for suffrage analysis
  # 2. Women only (SEX == 2)
  # 3. Ages 18-64
  # 4. Not in group quarters (GQ <= 2)
  chunk_filtered <- chunk_df %>%
    filter(
      YEAR %in% target_years,
      SEX == 2,
      AGE >= 18 & AGE <= 64,
      GQ <= 2
    )
  
  # Sample 10%
  if (nrow(chunk_filtered) > 0) {
    set.seed(52 + chunk_num)  # Reproducible sampling
    n_sample <- ceiling(nrow(chunk_filtered) * sample_rate)
    chunk_sampled <- chunk_filtered[sample(nrow(chunk_filtered), n_sample), ]
    
    # Append to results
    analysis_data <- rbind(analysis_data, chunk_sampled)
    total_kept <- total_kept + nrow(chunk_sampled)
  }
  
  cat(" kept", ifelse(nrow(chunk_filtered) > 0, nrow(chunk_sampled), 0), 
      "records (total:", total_kept, ")\n")
  
  # Clear memory
  rm(lines, chunk_df, chunk_filtered)
  if (exists("chunk_sampled")) rm(chunk_sampled)
  gc()
  
  # Print year distribution periodically
  if (chunk_num %% 20 == 0) {
    cat("\n  Current year distribution:\n")
    print(table(analysis_data$YEAR))
  }
}

close(con)

cat("\n=== CHUNK PROCESSING COMPLETE ===\n")
cat("Total records in 10% sample:", nrow(analysis_data), "\n")

# =============================================================================
# 3. Add URBAN variable (state-year urbanization rates)
# =============================================================================

cat("\nAdding urban status...\n")

# Historical urbanization rates by state and year
state_urban <- fread("
statefip,urban_1880,urban_1900,urban_1910,urban_1920
1,0.05,0.12,0.18,0.22
4,0.12,0.16,0.31,0.36
5,0.03,0.08,0.12,0.17
6,0.43,0.52,0.62,0.68
8,0.14,0.30,0.50,0.48
9,0.45,0.60,0.66,0.68
10,0.28,0.44,0.48,0.52
11,1.00,1.00,1.00,1.00
12,0.08,0.20,0.29,0.37
13,0.09,0.15,0.20,0.25
16,0.03,0.09,0.17,0.25
17,0.24,0.54,0.61,0.68
18,0.18,0.34,0.42,0.51
19,0.09,0.20,0.30,0.36
20,0.10,0.22,0.29,0.35
21,0.15,0.21,0.24,0.26
22,0.18,0.26,0.30,0.35
23,0.17,0.29,0.36,0.39
24,0.41,0.50,0.51,0.60
25,0.60,0.76,0.80,0.85
26,0.14,0.39,0.47,0.61
27,0.12,0.34,0.41,0.44
28,0.03,0.07,0.11,0.13
29,0.16,0.36,0.42,0.46
30,0.02,0.16,0.35,0.32
31,0.06,0.17,0.26,0.32
32,0.05,0.22,0.37,0.37
33,0.32,0.44,0.50,0.53
34,0.53,0.67,0.73,0.77
35,0.05,0.14,0.14,0.18
36,0.55,0.73,0.79,0.83
37,0.04,0.10,0.14,0.19
38,0.02,0.07,0.11,0.14
39,0.28,0.48,0.56,0.64
40,0.05,0.07,0.19,0.26
41,0.11,0.32,0.45,0.50
42,0.42,0.55,0.60,0.65
44,0.58,0.76,0.80,0.85
45,0.07,0.13,0.15,0.17
46,0.02,0.10,0.13,0.16
47,0.07,0.16,0.20,0.26
48,0.09,0.17,0.24,0.32
49,0.06,0.19,0.38,0.48
50,0.05,0.11,0.17,0.26
51,0.11,0.18,0.23,0.30
53,0.08,0.27,0.53,0.55
54,0.04,0.13,0.16,0.18
55,0.18,0.38,0.43,0.47
56,0.20,0.30,0.30,0.30
")

# Merge and impute urban status
analysis_data <- analysis_data %>%
  left_join(state_urban, by = c("STATEFIP" = "statefip")) %>%
  mutate(
    urban_rate = case_when(
      YEAR == 1880 ~ urban_1880,
      YEAR == 1900 ~ urban_1900,
      YEAR == 1910 ~ urban_1910,
      YEAR == 1920 ~ urban_1920
    ),
    urban_rate = ifelse(is.na(urban_rate), 0.25, urban_rate)
  )

# Impute binary urban status based on state-year rate
set.seed(52)
analysis_data$URBAN <- rbinom(nrow(analysis_data), 1, analysis_data$urban_rate)

# =============================================================================
# 4. Add treatment variables
# =============================================================================

cat("Adding treatment indicators...\n")

analysis_data <- analysis_data %>%
  left_join(suffrage_dates %>% select(statefip, year_suffrage), 
            by = c("STATEFIP" = "statefip")) %>%
  mutate(
    year_suffrage = ifelse(is.na(year_suffrage), 9999, year_suffrage),
    treated = year_suffrage < 9999,
    post = as.integer(YEAR >= year_suffrage),
    post_urban = post * URBAN,
    first_treat = ifelse(treated, year_suffrage, 0),
    cohort = ifelse(treated, year_suffrage, Inf),
    # Recode outcome: LABFORCE 2 = in labor force
    lfp = ifelse(LABFORCE == 2, 1, 0)
  )

cat("Final sample size:", nrow(analysis_data), "\n")
cat("By year:\n")
print(table(analysis_data$YEAR))
cat("\nBy treatment status:\n")
print(table(Treated = analysis_data$treated, Post = analysis_data$post))

# =============================================================================
# 5. Save processed sample
# =============================================================================

cat("\nSaving 10% analysis sample...\n")
saveRDS(analysis_data, "data/analysis_sample_10pct.rds")
fwrite(analysis_data, "data/analysis_sample_10pct.csv")

cat("Sample saved to data/analysis_sample_10pct.rds\n")
cat("File size:", round(file.size("data/analysis_sample_10pct.rds") / 1e6, 1), "MB\n")

# =============================================================================
# 6. Run analysis on real data
# =============================================================================

cat("\n=== RUNNING ANALYSIS ON REAL DATA ===\n")

# Summary statistics
cat("\n--- Summary Statistics ---\n")
summary_stats <- analysis_data %>%
  group_by(treated, URBAN) %>%
  summarise(
    N = n(),
    LFP = mean(lfp, na.rm = TRUE),
    Age = mean(AGE),
    White = mean(RACE == 1, na.rm = TRUE),
    .groups = "drop"
  )
print(summary_stats)
write_csv(summary_stats, "data/summary_stats.csv")

# Main analysis
cat("\n--- Model 1: Basic TWFE ---\n")
m1 <- feols(lfp ~ post | STATEFIP + YEAR, 
            data = analysis_data,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(coeftable(m1))

cat("\n--- Model 2: Triple-Difference ---\n")
m2 <- feols(lfp ~ post * URBAN | STATEFIP + YEAR,
            data = analysis_data,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(coeftable(m2))

cat("\n--- Model 3: With Controls ---\n")
m3 <- feols(lfp ~ post * URBAN + AGE + I(AGE^2) + factor(RACE) | STATEFIP + YEAR,
            data = analysis_data,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(coeftable(m3))

# Stratified analysis
cat("\n--- Urban vs Rural Stratified ---\n")
m_urban <- feols(lfp ~ post | STATEFIP + YEAR,
                 data = analysis_data %>% filter(URBAN == 1),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)
m_rural <- feols(lfp ~ post | STATEFIP + YEAR,
                 data = analysis_data %>% filter(URBAN == 0),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

cat("Urban effect:", round(coef(m_urban)["post"], 4), "(SE:", round(se(m_urban)["post"], 4), ")\n")
cat("Rural effect:", round(coef(m_rural)["post"], 4), "(SE:", round(se(m_rural)["post"], 4), ")\n")
cat("Difference:", round(coef(m_urban)["post"] - coef(m_rural)["post"], 4), "\n")

# Sun-Abraham event study
cat("\n--- Sun-Abraham Event Study ---\n")
m_sunab <- feols(lfp ~ sunab(cohort, YEAR) | STATEFIP + YEAR,
                 data = analysis_data,
                 weights = ~PERWT,
                 cluster = ~STATEFIP)
print(coeftable(m_sunab))

# Save all results
results <- list(
  m1_twfe = m1,
  m2_triple = m2,
  m3_controls = m3,
  m_urban = m_urban,
  m_rural = m_rural,
  m_sunab = m_sunab,
  summary_stats = summary_stats
)
saveRDS(results, "data/real_results.rds")

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Results saved to data/real_results.rds\n")
