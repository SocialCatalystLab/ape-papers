# ============================================================================
# 02_clean_data.R — Construct election panel with alignment variables
# Multi-Level Political Alignment and Local Development in India
# ============================================================================

source("00_packages.R")
data_dir <- "../data"
shrug_dir <- "../../../../data/india_shrug"
load(file.path(data_dir, "raw_data.RData"))

# ============================================================================
# 1. Clean Election Data: Identify top-two candidates per constituency-election
# ============================================================================
cat("Processing election data...\n")

# Remove missing vote counts
elections <- elections[!is.na(totvotpoll) & totvotpoll > 0]
elections[, year := as.integer(year)]

# Rank candidates within each constituency-election by votes
elections[, rank := frank(-totvotpoll, ties.method = "first"),
          by = .(st_name, year, ac_no)]

# Keep top-two candidates
top2 <- elections[rank <= 2]

# Reshape to wide: one row per constituency-election
winner <- top2[rank == 1, .(st_name, year, ac_no, ac_name, ac_type,
                             winner_name = cand_name,
                             winner_party = partyabbre,
                             winner_votes = totvotpoll,
                             electors)]
runner <- top2[rank == 2, .(st_name, year, ac_no,
                             runner_party = partyabbre,
                             runner_votes = totvotpoll)]

panel <- merge(winner, runner, by = c("st_name", "year", "ac_no"), all.x = TRUE)

# Compute vote margin (winner - runner-up, as share of total top-two votes)
panel[, total_top2 := winner_votes + runner_votes]
panel[, margin := (winner_votes - runner_votes) / total_top2]

cat(sprintf("  Constituency-elections: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("  Median margin: %.3f | Mean: %.3f\n", median(panel$margin, na.rm = TRUE),
            mean(panel$margin, na.rm = TRUE)))

# ============================================================================
# 2. Define State Ruling Parties (CM's party at time of election)
# ============================================================================
# This is constructed from public records of Indian state governments.
# For each state-year, we identify the CM's party at the time of the election.
# Post-election, the winner becomes the ruling party — but for the RDD we need
# the PRE-ELECTION ruling party (for alignment of the new MLA with existing govt).

# Actually, for the alignment RDD, we study the EFFECT of the MLA being from
# the ruling party. The "ruling party" is the party that forms government AFTER
# the election. So we need: which party won the state election (formed govt)?

# Step 1: Identify the winning party in each state election
# (party with most seats)
seats <- elections[rank == 1, .(seats = .N), by = .(st_name, year, partyabbre)]
seats[, max_seats := max(seats), by = .(st_name, year)]
state_winners <- seats[seats == max_seats][
  , .SD[1], by = .(st_name, year)  # Break ties: take first
][, .(st_name, year, state_ruling_party = partyabbre)]

# Merge ruling party into constituency panel
panel <- merge(panel, state_winners, by = c("st_name", "year"), all.x = TRUE)

# State alignment: winner's party = state ruling party
panel[, state_aligned := as.integer(winner_party == state_ruling_party)]

cat(sprintf("  State-aligned: %d/%d (%.1f%%)\n",
            sum(panel$state_aligned, na.rm = TRUE), nrow(panel),
            100 * mean(panel$state_aligned, na.rm = TRUE)))

# ============================================================================
# 3. Define Central Ruling Party (PM's party)
# ============================================================================
# Central government party for each year
central_party <- data.table(
  year_start = c(1977, 1980, 1989, 1991, 1996, 1998, 2004, 2014),
  year_end   = c(1979, 1989, 1990, 1996, 1997, 2004, 2014, 2025),
  central_party = c("JNP", "INC", "JD",  "INC", "BJP", "BJP", "INC", "BJP")
)

# For each election year, assign central ruling party
panel[, central_ruling_party := NA_character_]
for (i in seq_len(nrow(central_party))) {
  panel[year >= central_party$year_start[i] & year <= central_party$year_end[i],
        central_ruling_party := central_party$central_party[i]]
}

# Handle alliance partners: INC includes INC(I); BJP includes BJP allies
# Map common party abbreviations
panel[, winner_party_std := winner_party]
panel[winner_party %in% c("INC", "INC(I)"), winner_party_std := "INC"]

# Center alignment: winner's party = central ruling party
panel[, center_aligned := as.integer(winner_party_std == central_ruling_party)]

# Double alignment
panel[, double_aligned := as.integer(state_aligned == 1 & center_aligned == 1)]

cat(sprintf("  Center-aligned: %d/%d (%.1f%%)\n",
            sum(panel$center_aligned, na.rm = TRUE), nrow(panel),
            100 * mean(panel$center_aligned, na.rm = TRUE)))
cat(sprintf("  Double-aligned: %d/%d (%.1f%%)\n",
            sum(panel$double_aligned, na.rm = TRUE), nrow(panel),
            100 * mean(panel$double_aligned, na.rm = TRUE)))

# ============================================================================
# 4. Construct the RDD Running Variable
# ============================================================================
# For state-alignment RDD: margin between ruling-party candidate and top opponent
# We need to re-compute margin relative to the RULING party candidate

# Case 1: Winner IS from ruling party → margin is positive (same as computed)
# Case 2: Winner is NOT from ruling party → margin should be NEGATIVE
# (ruling party candidate lost)

# Identify whether the ruling party candidate was the winner or runner-up
panel[, ruling_is_winner := as.integer(winner_party == state_ruling_party)]
panel[, ruling_is_runner := as.integer(runner_party == state_ruling_party)]

# Construct RDD running variable: margin of ruling party candidate
# Positive = ruling party won; Negative = ruling party lost
panel[, rdd_margin_state := ifelse(ruling_is_winner == 1, margin,
                                    ifelse(ruling_is_runner == 1, -margin, NA_real_))]

# Similarly for center alignment
panel[, central_is_winner := as.integer(winner_party_std == central_ruling_party)]
panel[, central_is_runner := as.integer(runner_party == central_ruling_party)]
panel[runner_party %in% c("INC", "INC(I)"), central_is_runner_std := 1L]
panel[is.na(central_is_runner_std), central_is_runner_std := central_is_runner]

panel[, rdd_margin_center := ifelse(central_is_winner == 1, margin,
                                     ifelse(central_is_runner_std == 1, -margin, NA_real_))]

# Keep only elections where the ruling party candidate was one of the top-two
state_rdd <- panel[!is.na(rdd_margin_state)]
center_rdd <- panel[!is.na(rdd_margin_center)]

cat(sprintf("\n  State-alignment RDD sample: %s elections (ruling party in top-2)\n",
            format(nrow(state_rdd), big.mark = ",")))
cat(sprintf("  Center-alignment RDD sample: %s elections (central party in top-2)\n",
            format(nrow(center_rdd), big.mark = ",")))

# ============================================================================
# 5. Merge Election Data with VIIRS Nightlights
# ============================================================================
cat("\nMerging elections with nightlights...\n")

# Need to map state-year-AC to SHRUG ac07_id
# The ac07_id in SHRUG corresponds to the 2007 delimitation AC numbers
# Election data has ac_no which may use different numbering per delimitation

# Strategy: merge on state + AC number for post-2008 elections
# (2008 delimitation applied to elections from ~2008 onward)

# First, identify the state mapping between election data and SHRUG
# SHRUG ac07_id format: [state_code][ac_number] or similar

# Let's examine SHRUG AC IDs
cat("  SHRUG AC ID examples:", head(viirs$ac07_id, 5), "\n")

# Create state code mapping
state_codes <- data.table(
  st_name = c("Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar",
              "Chhattisgarh", "Goa", "Gujarat", "Haryana", "Himachal Pradesh",
              "Jammu and Kashmir", "Jharkhand", "Karnataka", "Kerala",
              "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya",
              "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan",
              "Sikkim", "Tamil Nadu", "Tripura", "Uttar Pradesh",
              "Uttarakhand", "West Bengal", "Delhi", "Telangana",
              "Andaman and Nicobar Islands", "Chandigarh", "Dadra and Nagar Haveli",
              "Daman and Diu", "Lakshadweep", "Puducherry"),
  pc11_state_id = c(28, 12, 18, 10, 22, 30, 24, 6, 2, 1, 20, 29, 32,
                     23, 27, 14, 17, 15, 13, 21, 3, 8, 11, 33, 16, 9,
                     5, 19, 7, 36, 35, 4, 26, 25, 31, 34)
)

# Merge state codes into election panel
panel <- merge(panel, state_codes, by = "st_name", all.x = TRUE)
state_rdd <- merge(state_rdd, state_codes, by = "st_name", all.x = TRUE)
center_rdd <- merge(center_rdd, state_codes, by = "st_name", all.x = TRUE)

# SHRUG AC IDs are strings like "2007-12-006" (2007-StateCode-ACNumber)
panel[, ac07_id := sprintf("2007-%02d-%03d", pc11_state_id, ac_no)]
state_rdd[, ac07_id := sprintf("2007-%02d-%03d", pc11_state_id, ac_no)]
center_rdd[, ac07_id := sprintf("2007-%02d-%03d", pc11_state_id, ac_no)]

# Check overlap with SHRUG
shrug_acs <- unique(viirs$ac07_id)
election_acs <- unique(panel[year >= 2008 & !is.na(pc11_state_id)]$ac07_id)
overlap <- length(intersect(shrug_acs, election_acs))
cat(sprintf("  AC overlap (post-2008 elections vs SHRUG): %d / %d election ACs matched to %d SHRUG ACs\n",
            overlap, length(election_acs), length(shrug_acs)))

# ============================================================================
# 6. Create Election-Year Panel with Post-Election Nightlights
# ============================================================================
# For each constituency-election, compute nightlights change in years 1-5 post-election

# Restrict to VIIRS era elections (2012+)
viirs_era <- panel[year >= 2008 & year <= 2020]  # Elections with post-election VIIRS data

# Merge with VIIRS (long format: one row per AC-year)
viirs_panel <- merge(
  viirs_era[, .(st_name, year, ac_no, ac_name, ac_type, winner_party,
                state_ruling_party, central_ruling_party,
                state_aligned, center_aligned, double_aligned,
                rdd_margin_state, rdd_margin_center,
                margin, pc11_state_id, ac07_id)],
  viirs[, .(ac07_id, nl_year = year, viirs_mean = viirs_annual_mean,
            viirs_sum = viirs_annual_sum)],
  by.x = "ac07_id", by.y = "ac07_id",
  allow.cartesian = TRUE
)

# Compute years relative to election
viirs_panel[, rel_year := nl_year - year]

# Keep -3 to +5 years relative to election
viirs_panel <- viirs_panel[rel_year >= -3 & rel_year <= 5]

cat(sprintf("\n  VIIRS panel: %s obs | Elections: %s | ACs: %d\n",
            format(nrow(viirs_panel), big.mark = ","),
            format(uniqueN(viirs_panel[, .(st_name, year, ac_no)]), big.mark = ","),
            uniqueN(viirs_panel$ac07_id)))

# ============================================================================
# 7. Compute Pre-Election Baseline Nightlights
# ============================================================================
baseline <- viirs_panel[rel_year %in% c(-2, -1),
                         .(baseline_nl = mean(viirs_mean, na.rm = TRUE)),
                         by = .(st_name, year, ac_no, ac07_id)]

viirs_panel <- merge(viirs_panel, baseline,
                      by = c("st_name", "year", "ac_no", "ac07_id"),
                      all.x = TRUE)

# Log nightlights (add small constant to avoid log(0))
viirs_panel[, log_nl := log(viirs_mean + 0.01)]
viirs_panel[, log_baseline := log(baseline_nl + 0.01)]
viirs_panel[, nl_growth := viirs_mean - baseline_nl]

# ============================================================================
# 8. Merge Census Covariates
# ============================================================================
# Census covariates for balance tests
census_vars <- census[, .(ac07_id,
                           pop = pc11_pca_tot_p,
                           lit_rate = pc11_pca_p_lit / pmax(pc11_pca_tot_p, 1),
                           sc_share = pc11_pca_p_sc / pmax(pc11_pca_tot_p, 1),
                           st_share = pc11_pca_p_st / pmax(pc11_pca_tot_p, 1),
                           work_rate = pc11_pca_tot_work_p / pmax(pc11_pca_tot_p, 1),
                           ag_share = (pc11_pca_main_cl_p + pc11_pca_main_al_p) /
                                       pmax(pc11_pca_tot_work_p, 1))]

viirs_panel <- merge(viirs_panel, census_vars,
                      by.x = "ac07_id", by.y = "ac07_id",
                      all.x = TRUE)

# ============================================================================
# 9. Save Analysis Dataset
# ============================================================================
save(panel, state_rdd, center_rdd, viirs_panel, census_vars, viirs, dmsp,
     state_codes, file = file.path(data_dir, "analysis_data.RData"))

cat("\n========================================\n")
cat("Analysis dataset constructed.\n")
cat(sprintf("  Total constituency-elections: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("  State-alignment RDD sample: %s\n", format(nrow(state_rdd), big.mark = ",")))
cat(sprintf("  Center-alignment RDD sample: %s\n", format(nrow(center_rdd), big.mark = ",")))
cat(sprintf("  VIIRS panel observations: %s\n", format(nrow(viirs_panel), big.mark = ",")))
cat("========================================\n")
