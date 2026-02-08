# Research Plan: Sports Betting Employment Effects (Major Revision)

**Parent Paper:** APEP-0051
**Status:** Major revision - complete re-execution with real data

## Research Question

What are the causal effects of sports betting legalization on gambling industry employment in the United States?

## Identification Strategy

Staggered difference-in-differences exploiting state-level adoption following Murphy v. NCAA (May 2018).

## Key Improvements from Original

1. **Quarterly treatment timing** (not annual) - QCEW is quarterly; mid-year launches matter
2. **Real QCEW data** - Original had no actual data
3. **iGaming confounding** - Code as separate confounder
4. **Mobile vs retail split** - Heterogeneous effects by implementation
5. **HonestDiD sensitivity** - Rambachan-Roth bounds for parallel trends
6. **COVID-19 robustness** - Pre-COVID cohorts, COVID controls

## Data Sources

- **QCEW** - BLS Quarterly Census of Employment and Wages
  - NAICS 7132 (Gambling Industries) - primary
  - NAICS 71 (Arts/Entertainment/Recreation) - robustness
  - State-quarter panel 2010-2024
- **Policy dates** - Legal Sports Report, state gaming commissions

## Implementation Plan

### Phase 1: Data Collection
- [x] Create workspace
- [ ] Build policy timing dataset (quarterly precision)
- [ ] Fetch QCEW data via BLS API
- [ ] Merge and clean data

### Phase 2: Descriptive Analysis
- [ ] Treatment rollout visualization
- [ ] Outcome trends by cohort
- [ ] Summary statistics

### Phase 3: Main Analysis
- [ ] Callaway-Sant'Anna estimation
- [ ] Event study
- [ ] Aggregate effects

### Phase 4: Robustness
- [ ] Sun-Abraham, TWFE, Synthetic DiD
- [ ] Exclude iGaming states
- [ ] Pre-COVID cohorts
- [ ] HonestDiD bounds
- [ ] Placebo tests

### Phase 5: Paper Writing
- [ ] Full LaTeX document with real results

## Files

| File | Purpose |
|------|---------|
| `code/00_packages.R` | Load required packages |
| `code/01_policy_dates.R` | Build policy timing panel |
| `code/02_fetch_qcew.R` | Fetch real QCEW data |
| `code/03_clean_data.R` | Merge and prepare data |
| `code/04_main_analysis.R` | Callaway-Sant'Anna, event study |
| `code/05_robustness.R` | Sensitivity checks |
| `code/06_figures.R` | Publication figures |
| `code/07_tables.R` | Regression tables |
