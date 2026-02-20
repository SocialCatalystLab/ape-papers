# =============================================================================
# 03_main_analysis.R — Primary Regressions
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Running main analysis for apep_0427 ===\n")

# Load data
cross_country <- readRDS("../data/cross_country_panel.rds")
sector_panel  <- readRDS("../data/sector_panel.rds")
neet_panel    <- readRDS("../data/neet_panel.rds")
temp_panel    <- readRDS("../data/temp_panel.rds")

# =============================================================
# ANALYSIS 1: Sector-Exposure Bartik DiD (PRIMARY)
# =============================================================
cat("\n--- Analysis 1: Sector-Exposure Bartik DiD ---\n")

# Focus on Jan 2023 reduction as primary shock
# Y_{s,t} = beta * (Exposure_s x Post2023_t) + sector_FE + time_FE + eps

# Main outcome: Youth employment share
m1_bartik <- feols(
  youth_share ~ bartik_reduction | sector + yq,
  data = sector_panel,
  cluster = ~sector
)
cat("Model 1 (Bartik, youth share):\n")
summary(m1_bartik)

# Youth employment level
m1b_bartik <- feols(
  emp_youth ~ bartik_reduction | sector + yq,
  data = sector_panel,
  cluster = ~sector
)
cat("\nModel 1b (Bartik, youth employment level):\n")
summary(m1b_bartik)

# Total employment (placebo — should show no/smaller effect)
# Restrict to same sample as youth regressions for consistency
m1c_bartik <- feols(
  emp_total ~ bartik_reduction | sector + yq,
  data = sector_panel %>% filter(!is.na(youth_share)),
  cluster = ~sector
)
cat("\nModel 1c (Bartik, total employment — placebo):\n")
summary(m1c_bartik)

# Binary high/low exposure DiD (easier to interpret)
m2_binary <- feols(
  youth_share ~ high_exposure:post_reduction | sector + yq,
  data = sector_panel,
  cluster = ~sector
)
cat("\nModel 2 (Binary exposure DiD):\n")
summary(m2_binary)

# =============================================================
# ANALYSIS 2: Cross-Country DiD (ROBUSTNESS)
# =============================================================
cat("\n--- Analysis 2: Cross-Country Triple-Difference ---\n")

# Triple-diff: France x Youth x Post-Reduction
cc_youth <- cross_country %>%
  filter(age_group %in% c("Y15-24", "Y25-54"))

m3_ddd <- feols(
  emp_rate ~ fr_youth_reduction + france:post_reduction + youth:post_reduction |
    country^age_group + yq^age_group,
  data = cc_youth,
  cluster = ~country
)
cat("Model 3 (DDD: France x Youth x Post-Reduction):\n")
summary(m3_ddd)

# Simpler DiD: France vs controls, youth only
cc_youth_only <- cross_country %>%
  filter(age_group == "Y15-24")

m4_did <- feols(
  emp_rate ~ france:post_reduction | country + yq,
  data = cc_youth_only,
  cluster = ~country
)
cat("\nModel 4 (DiD: France youth vs control youth):\n")
summary(m4_did)

# Also test the subsidy introduction (2020)
m5_intro <- feols(
  emp_rate ~ france:post_subsidy | country + yq,
  data = cc_youth_only,
  cluster = ~country
)
cat("\nModel 5 (DiD: Subsidy introduction 2020):\n")
summary(m5_intro)

# =============================================================
# ANALYSIS 3: NEET Rate (Inverse Outcome)
# =============================================================
cat("\n--- Analysis 3: NEET Rate ---\n")

neet_youth <- neet_panel %>%
  filter(grepl("15.*24|Y15-24|Y15-29", age_group))

m6_neet <- feols(
  neet_rate ~ france:post_reduction | country + yq,
  data = neet_youth %>% mutate(france = as.integer(country == "FR")),
  cluster = ~country
)
cat("Model 6 (NEET rate DiD):\n")
summary(m6_neet)

# =============================================================
# ANALYSIS 4: Temporary Employment (Substitution Test)
# =============================================================
cat("\n--- Analysis 4: Temporary Employment Share ---\n")

temp_youth <- temp_panel %>%
  filter(youth == 1)

m7_temp <- feols(
  temp_share ~ france:post_reduction | country + yq,
  data = temp_youth,
  cluster = ~country
)
cat("Model 7 (Temporary employment share, youth):\n")
summary(m7_temp)

# =============================================================
# Save all models
# =============================================================
cat("\n--- Saving model results ---\n")

models <- list(
  bartik_youth_share = m1_bartik,
  bartik_youth_level = m1b_bartik,
  bartik_total_placebo = m1c_bartik,
  binary_exposure = m2_binary,
  ddd = m3_ddd,
  did_youth = m4_did,
  did_intro = m5_intro,
  neet = m6_neet,
  temp_emp = m7_temp
)

saveRDS(models, "../data/main_models.rds")

cat("\n=== Main analysis complete ===\n")
cat("All models saved to ../data/main_models.rds\n")
