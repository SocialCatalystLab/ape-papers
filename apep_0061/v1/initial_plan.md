# Initial Plan: Paper 78 (Revision of apep_0069)

## Research Question

Do state dyslexia screening mandates improve fourth-grade reading achievement?

## Parent Paper

- **ID:** apep_0069
- **Title:** Do State Dyslexia Laws Improve Reading Achievement? Evidence from Staggered Adoption
- **Decision:** REJECT AND RESUBMIT (Score: 14.7)

## Revision Plan

### Key Issues from Reviews

1. **Treatment timing misalignment:** Laws effective July cannot affect that year's NAEP (tested Jan-Mar)
2. **Policy bundling confounds:** MS, FL, TN, AL bundled dyslexia with comprehensive SoR reforms
3. **State mean dilutes effects:** Dyslexia targets bottom 5-10%; mean outcome dilutes
4. **Inference gaps:** Singular covariance, missing pretrend tests

### Fixes

1. **Correct treatment timing:** Create `first_naep_exposure` variable that accounts for NAEP administration timing
2. **Separate bundled vs. dyslexia-only:** Run Callaway-Sant'Anna separately for reform bundles vs. screening-only mandates
3. **Improve inference:** 1000 bootstrap iterations, formal pretrend test, binned event study
4. **Expand paper:** Treatment classification table, institutional background, ≥25 pages

## Data Sources

- NAEP Grade 4 Reading API (2003-2022)
- State dyslexia law database (Dyslegia.com, State of Dyslexia, Education Week)

## Method

Callaway-Sant'Anna (2021) staggered DiD with doubly-robust estimation, never-treated controls, state-clustered standard errors.

## Timeline

This revision plan was created on 2026-01-25 based on reviewer feedback from apep_0069.
