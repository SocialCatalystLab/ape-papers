# ============================================================================
# 00_policy_data.R
# Salary Transparency Laws and the Gender Wage Gap
# Treatment Timing with Official Legislative Citations
# ============================================================================
#
# --- Input/Output Provenance ---
# INPUTS:
#   (none -- hand-coded from official legislative sources listed below)
# OUTPUTS:
#   data/transparency_laws.rds         (all 50 states + DC with treatment timing)
#   data/transparency_laws_treated.csv (treated states only, human-readable)
# SOURCES:
#   NCSL Pay Equity: https://www.ncsl.org/labor-and-employment/pay-equity-and-pay-transparency
#   Littler Mendelson Pay Transparency Chart (2024)
#   Individual state legislative databases (URLs in source_url column)
# ============================================================================

# This script creates the transparency_laws.rds file with properly documented
# treatment timing for salary transparency laws across US states.
#
# IMPORTANT: All treatment dates are sourced from official state legislation
# and verified against NCSL (National Conference of State Legislatures)
# pay transparency summary: https://www.ncsl.org/labor-and-employment/pay-equity-and-pay-transparency

library(tibble)
library(dplyr)

cat("Creating salary transparency law treatment data with citations...\n")

# ============================================================================
# State Salary Transparency Laws - Treatment Timing
# ============================================================================
#
# Sources:
# - NCSL Pay Equity and Pay Transparency: https://www.ncsl.org/labor-and-employment/pay-equity-and-pay-transparency
# - Individual state legislative databases
# - Littler Mendelson Pay Transparency Chart (2024)
#
# Income year coding:
# - CPS ASEC asks about income in the PREVIOUS calendar year
# - Treatment is coded for the first full income year affected
# - Laws effective mid-year: income year = following year (most wages earned before law)
# - Laws effective Jan 1: income year = that year

transparency_laws <- tibble(
  statefip = c(
    8,   # Colorado
    9,   # Connecticut
    32,  # Nevada
    44,  # Rhode Island
    6,   # California
    53,  # Washington
    36,  # New York
    15,  # Hawaii
    17,  # Illinois
    24,  # Maryland
    27   # Minnesota
  ),
  state = c(
    "Colorado",
    "Connecticut",
    "Nevada",
    "Rhode Island",
    "California",
    "Washington",
    "New York",
    "Hawaii",
    "Illinois",
    "Maryland",
    "Minnesota"
  ),
  effective_date = as.Date(c(
    "2021-01-01",  # Colorado: Equal Pay for Equal Work Act
    "2021-10-01",  # Connecticut: Public Act 21-30
    "2021-10-01",  # Nevada: SB 293
    "2023-01-01",  # Rhode Island: H 5171
    "2023-01-01",  # California: SB 1162
    "2023-01-01",  # Washington: SB 5761
    "2023-09-17",  # New York: Labor Law §194-b
    "2024-01-01",  # Hawaii: SB 1057
    "2025-01-01",  # Illinois: HB 3129 (Pay Transparency Act)
    "2025-10-01",  # Maryland: SB 525 (Wage Range Transparency Act)
    "2025-01-01"   # Minnesota: HF 2614 (Pay Transparency Act)
  )),
  first_treat = c(
    2021,  # Colorado: effective Jan 1, 2021 → income year 2021
    2022,  # Connecticut: effective Oct 1, 2021 → income year 2022 (most 2021 wages pre-law)
    2022,  # Nevada: effective Oct 1, 2021 → income year 2022
    2023,  # Rhode Island: effective Jan 1, 2023 → income year 2023
    2023,  # California: effective Jan 1, 2023 → income year 2023
    2023,  # Washington: effective Jan 1, 2023 → income year 2023
    2024,  # New York: effective Sep 17, 2023 → income year 2024 (most 2023 wages pre-law)
    2024,  # Hawaii: effective Jan 1, 2024 → income year 2024
    2025,  # Illinois: effective Jan 1, 2025 → income year 2025 (outside sample)
    2026,  # Maryland: effective Oct 1, 2025 → income year 2026 (outside sample)
    2025   # Minnesota: effective Jan 1, 2025 → income year 2025 (outside sample)
  ),
  employer_threshold = c(
    "All employers",           # Colorado
    "All employers",           # Connecticut
    "All employers",           # Nevada
    "All employers",           # Rhode Island
    "15+ employees",           # California
    "15+ employees",           # Washington
    "4+ employees",            # New York
    "50+ employees",           # Hawaii
    "15+ employees",           # Illinois
    "15+ employees",           # Maryland
    "All employers"            # Minnesota
  ),
  law_citation = c(
    "Colorado Equal Pay for Equal Work Act, SB19-085, C.R.S. § 8-5-201",
    "Connecticut Public Act 21-30 (HB 6380), Conn. Gen. Stat. § 31-40z",
    "Nevada SB 293 (2021), NRS 613.4383",
    "Rhode Island H 5171 (2023), R.I. Gen. Laws § 28-6-22",
    "California Pay Transparency Act, SB 1162 (2022), Cal. Lab. Code § 432.3",
    "Washington SB 5761 (2022), RCW 49.58.110",
    "New York Labor Law § 194-b, as amended by S.9427/A.10477",
    "Hawaii SB 1057 (2023), HRS § 378-2.4",
    "Illinois Pay Transparency Act, HB 3129 (2024), 820 ILCS 112/11",
    "Maryland Wage Range Transparency Act, SB 525 (2024), Md. Lab. & Empl. § 3-304.3",
    "Minnesota Pay Transparency Act, HF 2614 (2024), Minn. Stat. § 181.174"
  ),
  source_url = c(
    "https://leg.colorado.gov/bills/sb19-085",
    "https://www.cga.ct.gov/asp/cgabillstatus/cgabillstatus.asp?selBillType=Bill&bill_num=HB06380",
    "https://www.leg.state.nv.us/App/NELIS/REL/81st2021/Bill/7898/Overview",
    "http://webserver.rilin.state.ri.us/BillText/BillText23/HouseText23/H5171.pdf",
    "https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=202120220SB1162",
    "https://app.leg.wa.gov/billsummary?BillNumber=5761&Year=2021",
    "https://legislation.nysenate.gov/pdf/bills/2021/S9427A",
    "https://www.capitol.hawaii.gov/session/measure_indiv.aspx?billtype=SB&billnumber=1057&year=2023",
    "https://www.ilga.gov/legislation/billstatus.asp?DocNum=3129&GAID=17&GA=103&DocTypeID=HB",
    "https://mgaleg.maryland.gov/mgawebsite/Legislation/Details/SB0525?ys=2024RS",
    "https://www.revisor.mn.gov/bills/bill.php?b=House&f=HF2614&ssn=0&y=2024"
  ),
  # Alternative treatment timing: partial-year laws coded to same year (aggressive)
  # Used for sensitivity analysis in 05_robustness.R Section 16
  first_treat_alt = c(
    2021,  # Colorado: effective Jan 1, 2021 -> same either way
    2021,  # Connecticut: effective Oct 1, 2021 -> coded to 2021 (aggressive)
    2021,  # Nevada: effective Oct 1, 2021 -> coded to 2021 (aggressive)
    2023,  # Rhode Island: effective Jan 1, 2023 -> same either way
    2023,  # California: effective Jan 1, 2023 -> same either way
    2023,  # Washington: effective Jan 1, 2023 -> same either way
    2023,  # New York: effective Sep 17, 2023 -> coded to 2023 (aggressive)
    2024,  # Hawaii: effective Jan 1, 2024 -> same either way
    2025,  # Illinois: effective Jan 1, 2025 -> same either way
    2025,  # Maryland: effective Oct 1, 2025 -> coded to 2025 (aggressive)
    2025   # Minnesota: effective Jan 1, 2025 -> same either way
  )
)

# ============================================================================
# Add Never-Treated States
# ============================================================================

# All state FIPS codes
all_statefips <- c(
  1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23,
  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41,
  42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56
)

state_names <- c(
  "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
  "Connecticut", "Delaware", "District of Columbia", "Florida", "Georgia",
  "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
  "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
  "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
  "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
  "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
  "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
  "Washington", "West Virginia", "Wisconsin", "Wyoming"
)

# Create full state list with never-treated coded as 0
never_treated <- tibble(
  statefip = setdiff(all_statefips, transparency_laws$statefip)
) %>%
  mutate(
    first_treat = 0,  # Never-treated indicator for Callaway-Sant'Anna
    first_treat_alt = 0,  # Also never-treated under alternative coding
    effective_date = as.Date(NA),
    employer_threshold = NA_character_,
    law_citation = NA_character_,
    source_url = NA_character_
  )

# Add state names to never-treated
state_lookup <- tibble(
  statefip = all_statefips,
  state = state_names
)

never_treated <- never_treated %>%
  left_join(state_lookup, by = "statefip")

# Combine treated and never-treated
transparency_laws <- bind_rows(transparency_laws, never_treated) %>%
  arrange(statefip)

# ============================================================================
# Summary Statistics
# ============================================================================

cat("\n==== Transparency Law Summary ====\n")
cat("Total states:", nrow(transparency_laws), "\n")
cat("Treated states:", sum(transparency_laws$first_treat > 0), "\n")
cat("Never-treated states:", sum(transparency_laws$first_treat == 0), "\n")

cat("\nTreatment cohorts:\n")
transparency_laws %>%
  filter(first_treat > 0) %>%
  group_by(first_treat) %>%
  summarize(
    n_states = n(),
    states = paste(state, collapse = ", "),
    .groups = "drop"
  ) %>%
  print()

cat("\nTreated states with citations:\n")
transparency_laws %>%
  filter(first_treat > 0) %>%
  select(state, effective_date, first_treat, law_citation) %>%
  print()

# ============================================================================
# Save Data
# ============================================================================

saveRDS(transparency_laws, "data/transparency_laws.rds")
cat("\nSaved to data/transparency_laws.rds\n")

# Also save as CSV for transparency
write.csv(
  transparency_laws %>%
    filter(first_treat > 0) %>%
    select(statefip, state, effective_date, first_treat, employer_threshold, law_citation, source_url),
  "data/transparency_laws_treated.csv",
  row.names = FALSE
)
cat("Saved treated states to data/transparency_laws_treated.csv\n")

cat("\n==== Policy Data Creation Complete ====\n")
cat("Next step: Run 00_packages.R, then 01_fetch_data.R\n")
