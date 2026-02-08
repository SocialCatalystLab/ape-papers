# =============================================================================
# 02_clean_data.R
# Clean and prepare data for RDD analysis
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load raw data
# =============================================================================

cat("Loading data...\n")

municipal_results <- read_csv("../data/municipal_results_raw.csv", show_col_types = FALSE)
swissvotes <- read_csv("../data/swissvotes_metadata.csv", show_col_types = FALSE)

# =============================================================================
# 2. Merge with policy domain information
# =============================================================================

cat("Merging with Swissvotes metadata...\n")

# Match on vote date and vorlage_id (both are BFS numbers)
# For now, match on vote_date only and extract proposal info from title

# Create mapping of Swissvotes to municipal data
# The vorlage_id in municipal data should correspond to bfs_nummer in swissvotes

municipal_merged <- municipal_results %>%
  left_join(
    swissvotes %>%
      select(vote_date, vote_id, policy_domain, passed),
    by = "vote_date"
  )

# Handle multiple proposals per vote date
# Keep only proposals that passed nationally (for our RDD design)
municipal_merged <- municipal_merged %>%
  filter(vorlage_accepted == TRUE | is.na(vorlage_accepted))

cat("After merging:", nrow(municipal_merged), "observations\n")

# =============================================================================
# 3. Create analysis variables
# =============================================================================

cat("Creating analysis variables...\n")

analysis_data <- municipal_merged %>%
  mutate(
    # Running variable: distance from 50% (centered at cutoff)
    running_var = yes_pct - 50,

    # Treatment: local win (above 50%)
    local_win = as.integer(yes_pct > 50),

    # Outcome already included: turnout_pct

    # Vote identifiers
    vote_year = year(vote_date),
    vote_month = month(vote_date),

    # Create unique vote-proposal ID
    vote_proposal_id = paste(vote_date, vorlage_id, sep = "_"),

    # Language region from canton (approximate)
    language_region = case_when(
      kanton_name %in% c("Genève", "Vaud", "Neuchâtel", "Jura") ~ "French",
      kanton_name %in% c("Fribourg", "Valais", "Bern") ~ "Mixed_FR_DE",
      kanton_name == "Ticino" ~ "Italian",
      kanton_name == "Graubünden" ~ "Mixed_IT_RM_DE",
      TRUE ~ "German"
    ),

    # Create municipality-level panel ID
    muni_id = paste(kanton_id, gemeinde_id, sep = "_")
  )

# =============================================================================
# 4. Create panel structure for subsequent turnout analysis
# =============================================================================

cat("Creating panel structure...\n")

# For each municipality-proposal, find subsequent related votes
# "Related" = same policy domain

# First, get unique policy domains
domains <- swissvotes %>%
  select(vote_date, policy_domain) %>%
  distinct()

# Note: analysis_data already has policy_domain from the merge above

# For RDD: Focus on close votes (within bandwidth of cutoff)
# Define "close" as within 15 percentage points of 50%
close_votes <- analysis_data %>%
  filter(abs(running_var) <= 15)

cat("Close votes (within 15pp of 50%):", nrow(close_votes), "observations\n")

# =============================================================================
# 5. Create subsequent turnout outcomes
# =============================================================================

cat("Computing subsequent turnout by municipality...\n")

# Get average turnout by municipality and year (for outcome variable)
muni_year_turnout <- analysis_data %>%
  group_by(muni_id, gemeinde_name, kanton_name, vote_year) %>%
  summarise(
    avg_turnout = mean(turnout_pct, na.rm = TRUE),
    n_votes = n(),
    .groups = "drop"
  )

# Create balanced panel (municipality-year)
muni_year_panel <- muni_year_turnout %>%
  complete(muni_id, vote_year = 2010:2024)

# =============================================================================
# 6. Create RDD dataset: For each focal referendum that passed
# =============================================================================

cat("Creating RDD analysis dataset...\n")

# Focal referendums: those that passed nationally
focal_votes <- analysis_data %>%
  filter(vorlage_accepted == TRUE) %>%
  select(
    vote_date, vote_year, vote_proposal_id, vorlage_id, vorlage_title,
    policy_domain,
    muni_id, gemeinde_name, kanton_name, language_region,
    yes_pct, yes_count, no_count, running_var, local_win,
    turnout_pct, eligible_voters
  )

# For each focal vote, get subsequent turnout (1-3 years later)
# This will be computed in the analysis script

# =============================================================================
# 7. Save cleaned data
# =============================================================================

cat("\nSaving cleaned data...\n")

write_csv(analysis_data, "../data/municipal_results_cleaned.csv")
write_csv(focal_votes, "../data/rdd_focal_votes.csv")
write_csv(muni_year_turnout, "../data/muni_year_turnout.csv")

# =============================================================================
# 8. Summary statistics
# =============================================================================

cat("\n=== RDD Sample Summary ===\n")

focal_votes %>%
  summarise(
    n_obs = n(),
    n_proposals = n_distinct(vote_proposal_id),
    n_municipalities = n_distinct(muni_id),
    mean_yes_pct = mean(yes_pct, na.rm = TRUE),
    sd_yes_pct = sd(yes_pct, na.rm = TRUE),
    pct_local_win = mean(local_win, na.rm = TRUE) * 100,
    mean_turnout = mean(turnout_pct, na.rm = TRUE),
    # Close votes
    n_close_5pp = sum(abs(running_var) <= 5, na.rm = TRUE),
    n_close_10pp = sum(abs(running_var) <= 10, na.rm = TRUE)
  ) %>%
  glimpse()

cat("\n=== Distribution of Running Variable ===\n")
focal_votes %>%
  summarise(
    p10 = quantile(running_var, 0.10, na.rm = TRUE),
    p25 = quantile(running_var, 0.25, na.rm = TRUE),
    p50 = quantile(running_var, 0.50, na.rm = TRUE),
    p75 = quantile(running_var, 0.75, na.rm = TRUE),
    p90 = quantile(running_var, 0.90, na.rm = TRUE)
  ) %>%
  print()

cat("\nDone.\n")
