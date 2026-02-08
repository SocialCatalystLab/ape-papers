# Revision Plan - Round 1

## Fatal Errors Identified by Advisors

### 1. Internal Consistency: Sample Size / State Counts
**Issue:** Paper says 25 states and 200 observations, but tables say 18+6=24 states (would give 192 obs)
**Fix:**
- The actual panel has 25 states × 8 years = 200 obs
- Tables should say 19 treated + 6 control = 25 total
- Review data and clarify: Wisconsin is "late treated" (2016), so:
  - 18 "early treated" (2015)
  - 1 "late treated" (Wisconsin, 2016)
  - 6 never-treated
- Update all counts consistently

### 2. Data-Design Alignment: Treatment Coding
**Issue:** Control states (UT, ND, SD) have low unemployment - shouldn't have maintained waivers
**Fix:**
- These states actually did maintain waivers through 2019 per FNS records
- Waiver eligibility includes multiple criteria beyond unemployment rate:
  - Extended unemployment benefits trigger
  - Labor surplus area designation
  - State-specific exemptions
  - Policy discretion in waiver requests
- Add footnote explaining waiver basis for low-unemployment control states
- Consider dropping questionable controls as robustness check

### 3. Event Study Table Missing SEs
**Issue:** Table 3 lacks standard errors and sample sizes
**Fix:** Add SE, N, and clustering information to event study table

### 4. Missing Figure 3
**Issue:** Figure 3 referenced but not present
**Fix:** The paper refers to "Figure 3" but actual figures are numbered differently in compilation. Renumber or add the referenced figure.

### 5. Contradictory Labor Market Statement
**Issue:** Statement says control states have "stronger labor markets" allowing waivers - backwards
**Fix:** Reword to explain that some states maintained waivers through alternative eligibility criteria (e.g., state policy choices to request partial/substate waivers), not necessarily due to weak labor markets

## Action Items

1. Update sample size counts to be consistent (25 states, 200 obs)
2. Add waiver basis documentation for control states
3. Add SEs to event study table
4. Fix figure numbering
5. Reword labor market statement
6. Recompile PDF
