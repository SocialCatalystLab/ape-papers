# Revision Plan

## Summary

This revision of apep_0130 addresses two main objectives:
1. Fix code integrity issues (DATA_PROVENANCE_MISSING scan verdict)
2. Implement methodological extensions requested by reviewers

## Changes Made

### Priority 1: Code Integrity Fixes

1. **Created DATA_SOURCES.md** - Comprehensive documentation of all data sources with URLs, access dates, and verification methods

2. **Created data/raw/ directory** with source CSV files:
   - eers_adoption_sources.csv
   - census_1990_population.csv
   - rps_adoption_sources.csv
   - decoupling_adoption_sources.csv
   - building_codes_sources.csv

3. **Created 01d_validate_provenance.R** - Script to validate hardcoded data against raw CSV files

4. **Updated code comments** with provenance documentation in:
   - 01_fetch_data.R
   - 01c_fetch_policy.R

### Priority 2: Methodological Extensions

1. **Synthetic DiD Robustness (04b_sdid_robustness.R)**
   - Implemented Arkhangelsky et al. (2021) SDID estimator
   - Used early adopters (1998-2004) vs. never-treated
   - Jackknife standard errors
   - Cross-method comparison table

2. **Treatment Intensity Analysis**
   - Added framework for DSM expenditure intensity (01e_fetch_dsm.R)
   - Added dose-response specification in 03_main_analysis.R

3. **Welfare Analysis (04_robustness.R)**
   - Social cost of carbon calculation using EPA SCC ($51/tCO2)
   - Benefit-cost ratio computation
   - Welfare table added to paper

4. **Inference Strengthening**
   - CS-DiD cluster bootstrap added
   - Cohort contribution diagnostics
   - Wild cluster bootstrap for TWFE

### Paper Updates

1. Updated abstract with new contributions
2. Added Synthetic DiD section with comparison table
3. Added welfare analysis section with SCC calculation
4. Added new bibliography entries (EPA, Conley & Taber, Novan)
5. Fixed welfare number consistency ($1.0 billion)
6. Fixed SDID sample definition (1998-2004, treatment year 2004)

## Review Response Summary

All advisor reviews now pass (4/4). External reviews: 2 MINOR REVISION, 1 MAJOR REVISION.
