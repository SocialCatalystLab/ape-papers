# Research Plan (Revision of apep_0202)

## Research Question
Do social network connections to high-wage labor markets improve local employment outcomes?

## Identification Strategy
Shift-share IV: population-weighted out-of-state SCI network minimum wage exposure instruments for total network exposure. State-by-time fixed effects absorb own-state MW and state-level shocks.

## Data
- Quarterly Workforce Indicators (QWI) from Census API: county-quarter employment, earnings, hires, separations
- Facebook Social Connectedness Index (SCI): county-to-county connection probabilities
- State minimum wage panel: quarterly state MW rates 2012-2022
- IRS county-to-county migration flows
- County centroids for distance calculations

## Analysis Pipeline
1. Fetch and clean data (01_fetch_data.R, 02_clean_data.R, 02b_add_pop_weights.R)
2. Main 2SLS regressions (03_main_analysis.R)
3. Robustness: distance instruments, placebos, leave-one-out, permutation, Sun-Abraham (04_robustness.R, 04b, 04c, 04d)
4. Figures and tables (05_figures.R, 06_tables.R)

## Key Revision Changes
1. Fixed population weights to use pre-treatment (2012-2013) employment only (Borusyak et al. 2022)
2. Reframed from "information volume" to core economics
3. Dropped event study entirely
4. Restructured to 32-page main text + 13-page appendix
5. Added reviewer-requested citations and analyses
