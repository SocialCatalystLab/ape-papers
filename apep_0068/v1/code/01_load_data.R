# ==============================================================================
# Paper 91: Credit, Social Networks, and Political Polarization
# 01_load_data.R - Load and merge all datasets
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"

# ==============================================================================
# 1. CREDIT ACCESS DATA (Opportunity Insights 2020)
# ==============================================================================

cat("Loading credit access data...\n")

# Credit scores
credit_scores <- fread(file.path(data_dir, "credit_score_county.csv")) %>%
  filter(kid_race == "Pooled", par_pctile == -9) %>%  # Use pooled, all percentiles
  select(state = par_state, county = par_county, credit_score = shrunk_xkid_vscore2020, county_name) %>%
  mutate(fips = sprintf("%02d%03d", state, county))

# Student loans
student_loans <- fread(file.path(data_dir, "student_loan_county.csv")) %>%
  filter(kid_race == "Pooled", par_pctile == -9) %>%
  select(state = par_state, county = par_county, student_loan = shrunk_xkid_stubalance2020) %>%
  mutate(fips = sprintf("%02d%03d", state, county))

# Mortgage balances (mta = mortgage)
mortgages <- fread(file.path(data_dir, "mortgage_county.csv")) %>%
  filter(kid_race == "Pooled", par_pctile == -9) %>%
  select(state = par_state, county = par_county, mortgage = shrunk_xkid_mtabalance2020) %>%
  mutate(fips = sprintf("%02d%03d", state, county))

# Delinquency rates
delinquency <- fread(file.path(data_dir, "delinquency_county.csv")) %>%
  filter(kid_race == "Pooled", par_pctile == -9) %>%
  select(state = par_state, county = par_county, delinquency = shrunk_xkid_delinq90_02020) %>%
  mutate(fips = sprintf("%02d%03d", state, county))

# Credit cards (brc = bank revolving credit / credit card)
credit_cards <- fread(file.path(data_dir, "credit_card_county.csv")) %>%
  filter(kid_race == "Pooled", par_pctile == -9) %>%
  select(state = par_state, county = par_county, credit_card = shrunk_xkid_brcbalance2020) %>%
  mutate(fips = sprintf("%02d%03d", state, county))

# Auto loans (aua = auto)
auto_loans <- fread(file.path(data_dir, "auto_loan_county.csv")) %>%
  filter(kid_race == "Pooled", par_pctile == -9) %>%
  select(state = par_state, county = par_county, auto_loan = shrunk_xkid_auabalance2020) %>%
  mutate(fips = sprintf("%02d%03d", state, county))

# Merge credit data
credit_data <- credit_scores %>%
  left_join(student_loans %>% select(fips, student_loan), by = "fips") %>%
  left_join(mortgages %>% select(fips, mortgage), by = "fips") %>%
  left_join(delinquency %>% select(fips, delinquency), by = "fips") %>%
  left_join(credit_cards %>% select(fips, credit_card), by = "fips") %>%
  left_join(auto_loans %>% select(fips, auto_loan), by = "fips")

cat(sprintf("Credit data: %d counties\n", nrow(credit_data)))

# ==============================================================================
# 2. SOCIAL CAPITAL DATA (Chetty et al. 2022)
# ==============================================================================

cat("Loading social capital data...\n")

social_capital <- fread(file.path(data_dir, "social_capital_county.csv")) %>%
  mutate(fips = sprintf("%05d", county)) %>%
  select(
    fips,
    ec = ec_county,               # Economic connectedness
    ec_se = ec_se_county,
    child_ec = child_ec_county,   # Child economic connectedness
    friending_bias = bias_grp_mem_county,  # Friending bias
    clustering = clustering_county,
    volunteering = volunteering_rate_county,
    civic_orgs = civic_organizations_county,
    pop2018
  )

cat(sprintf("Social capital data: %d counties\n", nrow(social_capital)))

# ==============================================================================
# 3. FRIENDSHIP MATRIX (100x100 SES)
# ==============================================================================

cat("Loading friendship matrix...\n")

friendship_matrix <- fread(file.path(data_dir, "friendship_matrix.csv"))
cat(sprintf("Friendship matrix: %d x %d\n", nrow(friendship_matrix), ncol(friendship_matrix) - 1))

# ==============================================================================
# 4. COLLEGE ADMISSIONS DATA (139 Selective Colleges)
# ==============================================================================

cat("Loading college admissions data...\n")

college_admissions <- fread(file.path(data_dir, "college_admissions.csv"))

# Calculate elite attendance skew (ratio of top 1% to bottom 20%)
college_summary <- college_admissions %>%
  filter(par_income_lab %in% c("0-20", "Top 1", "Top 0.1")) %>%
  select(super_opeid, name, par_income_lab, attend) %>%
  pivot_wider(names_from = par_income_lab, values_from = attend, names_prefix = "attend_") %>%
  rename(attend_bottom20 = `attend_0-20`, attend_top1 = `attend_Top 1`, attend_top01 = `attend_Top 0.1`) %>%
  mutate(elite_ratio = attend_top1 / attend_bottom20) %>%
  filter(!is.na(elite_ratio) & is.finite(elite_ratio))

cat(sprintf("College data: %d selective colleges\n", nrow(college_summary)))

# ==============================================================================
# 5. COUNTY COVARIATES
# ==============================================================================

cat("Loading county covariates...\n")

# Changing Opportunity covariates
covariates <- fread(file.path(data_dir, "county_covariates.csv")) %>%
  mutate(fips = sprintf("%02d%03d", state, county)) %>%
  select(
    fips,
    emp_2010 = emp_pooled2010,
    frac_coll_2010 = frac_coll_pooled2010,
    hhinc_median_2010 = hhinc_median_pooled2010,
    gini_2010 = gini2010,
    poor_share_2010 = poor_share_pooled2010,
    share_white_2010 = share_white2010,
    share_black_2010 = share_black2010,
    singlepar_2010 = singlepar_pooled2010
  )

# Opportunity Atlas covariates (for additional variables)
atlas_covariates <- fread(file.path(data_dir, "opportunity_atlas_covariates.csv")) %>%
  mutate(fips = sprintf("%02d%03d", state, county)) %>%
  select(
    fips,
    popdensity = popdensity2010,
    rent_twobed = rent_twobed2015,
    commute_time = mean_commutetime2000
  )

cat(sprintf("Covariates: %d counties\n", nrow(covariates)))

# ==============================================================================
# 6. VOTING DATA (2016-2024)
# ==============================================================================

cat("Loading voting data...\n")

# 2016 voting data - note different format
voting_2016 <- fread(file.path(data_dir, "voting_2016.csv")) %>%
  select(
    fips = combined_fips,
    votes_dem_2016 = votes_dem,
    votes_gop_2016 = votes_gop,
    total_votes_2016 = total_votes,
    pct_dem_2016 = per_dem,
    pct_gop_2016 = per_gop
  ) %>%
  mutate(fips = sprintf("%05d", as.numeric(fips))) %>%
  filter(!is.na(fips))

# 2020 voting data
voting_2020 <- fread(file.path(data_dir, "voting_2020.csv")) %>%
  mutate(fips = sprintf("%05d", as.numeric(county_fips))) %>%
  select(
    fips,
    votes_dem_2020 = votes_dem,
    votes_gop_2020 = votes_gop,
    total_votes_2020 = total_votes,
    pct_dem_2020 = per_dem,
    pct_gop_2020 = per_gop
  )

# 2024 voting data
voting_2024 <- fread(file.path(data_dir, "voting_2024.csv")) %>%
  mutate(fips = sprintf("%05d", as.numeric(county_fips))) %>%
  select(
    fips,
    votes_dem_2024 = votes_dem,
    votes_gop_2024 = votes_gop,
    total_votes_2024 = total_votes,
    pct_dem_2024 = per_dem,
    pct_gop_2024 = per_gop
  )

# Merge voting data
voting_data <- voting_2020 %>%
  left_join(voting_2016, by = "fips") %>%
  left_join(voting_2024, by = "fips") %>%
  mutate(
    # Calculate changes
    gop_change_16_20 = pct_gop_2020 - pct_gop_2016,
    gop_change_20_24 = pct_gop_2024 - pct_gop_2020,
    gop_change_16_24 = pct_gop_2024 - pct_gop_2016,
    # Polarization measures
    margin_2020 = abs(pct_gop_2020 - pct_dem_2020),
    trump_county_2020 = pct_gop_2020 > 0.5
  )

cat(sprintf("Voting data: %d counties\n", nrow(voting_data)))

# ==============================================================================
# 7. MERGE ALL DATA
# ==============================================================================

cat("Merging all datasets...\n")

# Master dataset
df <- credit_data %>%
  inner_join(social_capital, by = "fips") %>%
  left_join(covariates, by = "fips") %>%
  left_join(atlas_covariates, by = "fips") %>%
  left_join(voting_data, by = "fips") %>%
  # Create standardized versions
  mutate(
    credit_score_z = scale(credit_score)[,1],
    ec_z = scale(ec)[,1],
    delinquency_z = scale(delinquency)[,1],
    student_loan_z = scale(student_loan)[,1],
    # Urban indicator (top quartile of density)
    urban = popdensity > quantile(popdensity, 0.75, na.rm = TRUE),
    # State FIPS
    state_fips = substr(fips, 1, 2)
  )

cat(sprintf("\nFinal merged dataset: %d counties\n", nrow(df)))
cat(sprintf("  - With voting data: %d counties\n", sum(!is.na(df$pct_gop_2020))))
cat(sprintf("  - With credit scores: %d counties\n", sum(!is.na(df$credit_score))))
cat(sprintf("  - With economic connectedness: %d counties\n", sum(!is.na(df$ec))))

# ==============================================================================
# 8. GET COUNTY SHAPEFILE
# ==============================================================================

cat("\nDownloading county shapefile...\n")

counties_sf <- counties(cb = TRUE, year = 2020) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69")) %>%  # Exclude AK, HI, territories
  mutate(fips = GEOID)

# Merge data to shapefile
counties_data <- counties_sf %>%
  left_join(df, by = "fips")

cat(sprintf("Shapefile joined: %d counties\n", nrow(counties_data)))

# ==============================================================================
# 9. SAVE PROCESSED DATA
# ==============================================================================

saveRDS(df, "../data/analysis_data.rds")
saveRDS(counties_data, "../data/counties_data.rds")
saveRDS(friendship_matrix, "../data/friendship_matrix.rds")
saveRDS(college_summary, "../data/college_summary.rds")

cat("\nData saved to ../data/\n")
cat("  - analysis_data.rds\n")
cat("  - counties_data.rds\n")
cat("  - friendship_matrix.rds\n")
cat("  - college_summary.rds\n")
