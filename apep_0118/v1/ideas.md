# Research Ideas

## Revision of apep_0038

This is a revision of paper apep_0038 (Sports Betting Employment Effects). The original paper received MAJOR REVISION recommendations from all 5 reviewers.

## Idea 1: Revised Sports Betting Employment Analysis

**Policy:** Sports betting legalization following Murphy v. NCAA (2018)

**Outcome:** Gambling industry employment (NAICS 7132) from QCEW

**Identification:** Callaway-Sant'Anna difference-in-differences exploiting staggered state adoption

**Why it's novel:** First rigorous causal estimates of sports betting employment effects using modern DiD methods

**Feasibility check:**
- Variation exists: 34 states legalized 2018-2024, 16 never-treated
- Data accessible: QCEW publicly available via BLS
- Not overstudied: No prior credible causal estimates exist
- Sample size: 50 states × 15 years = 750 observations

## Key Improvements from Original

1. **Treatment timing:** Use state-quarter precision for treatment coding
2. **iGaming controls:** Address concurrent online casino legalization confound
3. **HonestDiD:** Rambachan-Roth sensitivity analysis for parallel trends
4. **COVID robustness:** Exclude 2020-2021 as sensitivity check
5. **Pre-PASPA states:** Robustness excluding DE, MT, OR
6. **Leave-one-out:** Verify no single state drives results

## Reviewer Concerns Addressed

1. Timing mismeasurement → Use year of first legal bet
2. NAICS aggregation → Document measurement limitations, add placebo tests
3. iGaming confound → Triple-diff sensitivity excluding iGaming states
4. COVID confounding → Exclude 2020-2021 sensitivity
5. Parallel trends → HonestDiD sensitivity analysis
6. SUTVA concerns → Document geographic measurement, leave-one-out tests
