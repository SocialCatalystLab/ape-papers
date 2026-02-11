# Research Plan — Revision of APEP-0038 (Living Document)

**Last updated:** 2026-02-09

## Research Question

**Does sports betting legalization increase gambling industry employment?**

This revision of APEP-0038 ("Betting on Jobs? The Employment Effects of Legal Sports Betting in the United States") addresses critical deficiencies identified in code review and external referee reports. The parent paper reported large positive employment effects but used simulated data with a baked-in treatment effect. This revision replaces the entire data pipeline with real BLS QCEW data and adds reviewer-requested analyses.

## Critical Fixes from Parent Paper

| Issue | Parent Paper | This Revision |
|-------|-------------|---------------|
| Data source | Simulated data (01b_create_cached_qcew.R) with baked-in treatment effect | Real BLS QCEW API data |
| Pre-trend F-test | Incorrect element-wise t-tests | Proper joint Wald test from VCV matrix |
| Leave-one-out | Only first 10 treated states | All 34 treated states |
| HonestDiD | Approximate/manual implementation | Proper HonestDiD package functions |
| Wage analysis | Missing | Added (reviewer request) |
| Spillover analysis | Missing | Added (reviewer request) |

## Identification Strategy

**Staggered Difference-in-Differences with Callaway-Sant'Anna (2021) Estimator**

- **Treatment:** State-level legalization of sports betting, staggered across 34 states between 2018 and 2024
- **Control group:** 15 never-treated states plus not-yet-treated states (CS estimator default)
- **Unit of analysis:** State-quarter panels
- **Pre-treatment periods:** 2012Q1-treatment quarter (minimum 5 years for earliest adopters)
- **Outcome variable:** Log employment in NAICS 7132 (Gambling Industries) from BLS Quarterly Census of Employment and Wages

### Key Design Features

1. **Staggered adoption:** Murphy v. NCAA (2018) opened the door, but states adopted at different times based on legislative calendars, existing gambling infrastructure, and political dynamics — providing plausibly exogenous variation in timing
2. **Callaway-Sant'Anna estimator:** Avoids negative weighting bias inherent in two-way fixed effects with staggered treatment
3. **Not-yet-treated controls:** Uses not-yet-treated states as additional controls (default CS specification), with never-treated-only as robustness check

## Expected Effects

- **Parent paper finding:** Large positive effects (~15-20% employment increase) — but this was based on simulated data
- **Expected revision finding:** Null or modest positive effects. Real BLS data may show smaller or insignificant effects because:
  - Many states had existing gambling infrastructure that absorbed sports betting
  - Online/mobile betting requires fewer workers than traditional gambling
  - Some employment may be reclassified rather than newly created
- **A well-executed null result is a genuine contribution** — it challenges the jobs-creation narrative used to justify legalization

## Primary Specification

```
ATT(g,t) estimated via Callaway-Sant'Anna (2021)
  Y_it = log(employment_NAICS7132_it)
  Treatment: first quarter of legal sports betting operations
  Controls: not-yet-treated states (primary), never-treated only (robustness)
  Clustering: state level
  Aggregation: simple, calendar-time, event-study
```

## Robustness and Sensitivity Checks

1. **HonestDiD (Rambachan & Roth, 2023):** Sensitivity analysis for violations of parallel trends — compute breakdown values for the smoothness restriction (M-bar)
2. **Leave-one-out:** Drop each of the 34 treated states individually and re-estimate to check for influential observations
3. **COVID sensitivity:** Restrict sample to pre-COVID (through 2019Q4) and test whether results change
4. **iGaming controls:** Control for concurrent iGaming/online casino legalization (7 states legalized both)
5. **Placebo industries:** Run same DiD specification on NAICS codes unrelated to gambling (e.g., manufacturing, healthcare) — should find null effects
6. **Never-treated only controls:** Re-estimate using only the 15 never-treated states as controls
7. **Pre-trend F-test:** Proper joint Wald test on pre-treatment event-study coefficients using the VCV matrix (fixing parent paper's incorrect element-wise t-test approach)

## New Analyses (Reviewer-Requested)

### Wage Analysis
- **Question:** Are the jobs (if any) "good jobs"?
- **Outcome:** Log average weekly wage in NAICS 7132 from BLS QCEW
- **Specification:** Same CS DiD as primary analysis but with wage outcome
- **Motivation:** All three referees asked whether employment gains translate to quality jobs

### Spillover/Border Analysis
- **Question:** Does legalization in neighboring states affect a state's gambling employment?
- **Specification:** Neighbor exposure regression — for each state, compute share of border states that have legalized, use as continuous treatment
- **Motivation:** All three referees raised competitive effects (e.g., New Jersey legalizing may draw activity from Pennsylvania pre-legalization)

## Data Sources

| Data | Source | Access Method | Frequency |
|------|--------|---------------|-----------|
| NAICS 7132 Employment | BLS QCEW | API (api.bls.gov) | Quarterly |
| NAICS 7132 Wages | BLS QCEW | API (api.bls.gov) | Quarterly |
| Sports betting legalization dates | APEP-0038 + manual update | Hand-collected from state statutes | — |
| State adjacency matrix | Census Bureau | Static file | — |
| iGaming legalization dates | AGA/state records | Hand-collected | — |

## Code Pipeline

```
code/
├── 00_setup.R                  # Package loading, paths, helper functions
├── 01_fetch_qcew.R             # Real BLS QCEW API data fetch (replaces simulated data)
├── 02_clean_panel.R            # Panel construction, treatment assignment
├── 03_descriptive.R            # Summary stats, pre-treatment balance
├── 04_main_did.R               # Callaway-Sant'Anna primary specification
├── 05_event_study.R            # Event-study plots with confidence intervals
├── 06_robustness.R             # HonestDiD, leave-one-out, placebo industries
├── 07_pretrends.R              # Proper F-test, pre-trend diagnostics
├── 08_wage_analysis.R          # Wage DiD (new)
├── 09_spillover_analysis.R     # Border/neighbor exposure regression (new)
└── 10_tables_figures.R         # Output generation for paper
```

## Progress Tracking

- [ ] Data fetch: Pull real BLS QCEW data via API for all states, 2012-2024
- [ ] Panel construction: Build balanced state-quarter panel with treatment indicators
- [ ] Primary analysis: Run CS DiD, generate event-study plots
- [ ] Robustness: Full battery of sensitivity checks
- [ ] New analyses: Wage DiD and spillover regression
- [ ] Paper writing: Update all results, tables, figures; honest reporting of findings
- [ ] Review: Full advisor + exhibit + prose + external review pipeline

## Notes

This is a living document. Updates will be made as analysis progresses and results emerge. The key commitment is to honest reporting — if the real data shows null effects (which is likely), that is the finding we report. The parent paper's large positive effects were artifacts of simulated data, not empirical reality.
