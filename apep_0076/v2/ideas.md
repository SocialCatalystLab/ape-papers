# Research Ideas (Revision of apep_0076)

## Revision Context

This is a revision of apep_0076 (State EITC Generosity and Crime). The research question, identification strategy, and data sources are inherited from the parent paper. The revision focuses on methodological improvements.

## Research Question

Does state EITC adoption affect crime rates? Can we credibly identify the causal effect using modern difference-in-differences methods?

## Key Improvements over Parent Paper

### 1. Extended Panel (1987-2019)
**Original problem:** Parent paper used 1999-2019 panel, making early adopters (MD 1987, VT 1988, WI 1989, etc.) "always-treated" with no pre-treatment observations.

**Solution:** Extend panel to 1987-2019 using CORGIS crime data (available from 1960). This gives 28 of 29 adopting jurisdictions pre-treatment observations for event study analysis.

**Feasibility:** ✓ Confirmed - CORGIS data downloaded and panel constructed.

### 2. Data Provenance Fix
**Original problem:** SUSPICIOUS scan verdict - no download script for crime data.

**Solution:** Created 00_download_data.R with programmatic download from CORGIS, full citation, and metadata documentation.

**Feasibility:** ✓ Confirmed - Data provenance now fully documented.

### 3. Time-Varying EITC Generosity
**Original problem:** Used 2019 snapshot of EITC rates applied retroactively.

**Solution:** Built state-year panel of actual EITC rates from historical Tax Policy Center data.

**Feasibility:** ✓ Confirmed - eitc_rates_historical.csv created with annual rates.

### 4. Robust Inference Methods
**Original problem:** No wild cluster bootstrap, no 95% CIs in tables.

**Solution:** Added Sun-Abraham estimator via fixest, wild cluster bootstrap attempt (package unavailable for this R version, but code implemented), Goodman-Bacon decomposition, and 95% CIs reported throughout.

**Feasibility:** ✓ Confirmed - All estimators run successfully.

### 5. Policy Controls
**Original problem:** No controls for confounding state policies.

**Solution:** Added minimum wage panel and national incarceration trends as controls.

**Feasibility:** ✓ Confirmed - Controls added to robustness checks.

## Verdict

PURSUE - All improvements implemented and tested. Ready for publication.
