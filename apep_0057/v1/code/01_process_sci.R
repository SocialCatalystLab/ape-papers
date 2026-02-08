# =============================================================================
# Paper 73: Process Facebook Social Connectedness Index Data
# =============================================================================

library(tidyverse)
library(data.table)

# Set working directory
setwd("/Users/dyanag/auto-policy-evals")

# Read SCI data (large file - use data.table for speed)
cat("Reading SCI data...\n")
sci_raw <- fread(
  "output/paper_73/data/gadm1_nuts3_counties-gadm1_nuts3_counties - FB Social Connectedness Index - October 2021.tsv",
  sep = "\t",
  header = TRUE
)

cat(sprintf("Raw data: %s rows\n", format(nrow(sci_raw), big.mark = ",")))

# Filter to US counties only
sci_us <- sci_raw[grepl("^USA", user_loc) & grepl("^USA", fr_loc)]
cat(sprintf("US-to-US connections: %s rows\n", format(nrow(sci_us), big.mark = ",")))

# Extract FIPS codes from location codes
# Format: USA{state}{county} -> {state}{county}
sci_us[, user_fips := substr(user_loc, 4, 8)]
sci_us[, fr_fips := substr(fr_loc, 4, 8)]

# Check unique counties
n_counties <- length(unique(sci_us$user_fips))
cat(sprintf("Unique US counties: %d\n", n_counties))

# Save compressed US-only SCI data
# Skip full matrix save to conserve disk space - just save summary statistics
cat("Skipping full matrix save to conserve disk space\n")

# -----------------------------------------------------------------------------
# Calculate county-level SCI summary measures
# -----------------------------------------------------------------------------

# 1. Total SCI (sum of all connections)
county_total_sci <- sci_us[, .(total_sci = sum(scaled_sci)), by = user_fips]

# 2. Self-connection (within-county SCI)
self_sci <- sci_us[user_fips == fr_fips, .(self_sci = scaled_sci), by = user_fips]

# 3. Out-of-state connections (bridging social capital)
# Extract state FIPS
sci_us[, user_state := substr(user_fips, 1, 2)]
sci_us[, fr_state := substr(fr_fips, 1, 2)]

out_of_state_sci <- sci_us[user_state != fr_state,
                           .(out_of_state_sci = sum(scaled_sci)),
                           by = user_fips]

# 4. Geographic diversity (HHI of state-level connections)
state_connections <- sci_us[, .(state_sci = sum(scaled_sci)),
                            by = .(user_fips, fr_state)]
state_connections[, total := sum(state_sci), by = user_fips]
state_connections[, share := state_sci / total]
state_connections[, share_sq := share^2]

sci_diversity <- state_connections[, .(hhi_state = sum(share_sq)), by = user_fips]
sci_diversity[, diversity := 1 - hhi_state]  # Higher = more diverse connections

# 5. Number of significant connections (SCI > 100)
n_connections <- sci_us[user_fips != fr_fips & scaled_sci > 100,
                        .(n_connections = .N),
                        by = user_fips]

# Merge all measures
county_sci <- county_total_sci %>%
  left_join(self_sci, by = "user_fips") %>%
  left_join(out_of_state_sci, by = "user_fips") %>%
  left_join(sci_diversity, by = "user_fips") %>%
  left_join(n_connections, by = "user_fips")

# Calculate derived measures
county_sci <- county_sci %>%
  mutate(
    # Share of connections outside county's state
    out_of_state_share = out_of_state_sci / total_sci,
    # Self-connection share (insularity)
    self_share = self_sci / total_sci,
    # Log transformations
    log_total_sci = log(total_sci),
    log_n_connections = log(n_connections + 1)
  )

# Save county summary
fwrite(county_sci, "output/paper_73/data/county_sci_summary.csv")
cat("Saved: county_sci_summary.csv\n")

# Summary statistics
cat("\n--- County SCI Summary Statistics ---\n")
print(summary(county_sci[, .(total_sci, self_share, out_of_state_share, diversity, n_connections)]))

# Distribution of diversity (geographic bridging)
cat("\n--- Diversity Distribution ---\n")
cat(sprintf("Min: %.3f\n", min(county_sci$diversity, na.rm = TRUE)))
cat(sprintf("Mean: %.3f\n", mean(county_sci$diversity, na.rm = TRUE)))
cat(sprintf("Median: %.3f\n", median(county_sci$diversity, na.rm = TRUE)))
cat(sprintf("Max: %.3f\n", max(county_sci$diversity, na.rm = TRUE)))

cat("\nDone!\n")
