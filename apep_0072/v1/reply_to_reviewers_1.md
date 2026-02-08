# Reply to Reviewers - Round 1

## Summary of Reviewer Decisions

- **Reviewer 1:** REJECT AND RESUBMIT
- **Reviewer 2:** REJECT AND RESUBMIT
- **Reviewer 3:** REJECT AND RESUBMIT

## Common Concerns Across All Reviewers

### 1. Paper Length (~13 pages vs 25+ expected)

**Response:** We acknowledge the paper is shorter than typical top-journal submissions. The current version focuses on core methodology and findings. A full revision would expand institutional background, add appendices with robustness checks, and develop the discussion more fully.

### 2. Outcome Mismatch (Stock vs Flow)

**Response:** All reviewers correctly note that "lifetime depression diagnosis prevalence" is a stock measure that adjusts slowly, making it poorly suited to detect short-run access effects. We have relabeled the outcome throughout the paper to clarify this is "lifetime prevalence" not a "diagnosis rate." A stronger test would use flow measures (past-year diagnosis, utilization) or claims data. The current paper represents a conservative test: if parity laws increased diagnoses at the margin, the stock should eventually rise, but attenuation is expected.

### 3. Binary Treatment Coding

**Response:** Reviewers note that coding "parity law in effect" as binary ignores heterogeneity in coverage vs payment parity, modalities, and enforcement. This is a valid limitation. Granular treatment coding would require detailed legal research beyond the scope of this initial analysis. The binary indicator provides an intent-to-treat estimate that likely attenuates toward zero.

### 4. Missing Literature (DiD Methods)

**Response:** We will add:
- Sun & Abraham (2021) on interaction-weighted event studies
- Borusyak, Jaravel & Spiess (2021) on imputation estimators
- Roth (2022) on pre-trend testing sensitivity
- Sant'Anna & Zhao (2020) on doubly robust DiD

### 5. Single-State Cohorts (2017, 2019)

**Response:** Reviewers flag that the "significant" negative effects for 2017 and 2019 cohorts each contain only 1 state, raising concerns about idiosyncratic shocks. We acknowledge this limitation and will add:
- State names for single-state cohorts
- Leave-one-out sensitivity analysis discussion
- Interpretation that these should not be viewed as robust heterogeneity findings

### 6. Identification Concerns (Policy Bundling)

**Response:** Reviewers note that states adopting parity laws may simultaneously enact other mental health policies. Without comprehensive policy controls, this remains a limitation. The parallel trends evidence provides some reassurance, but we cannot rule out all confounders.

## Limitations of Current Revision

Given data constraints (BRFSS prevalence only), we cannot:
- Add claims-based utilization outcomes
- Construct granular treatment heterogeneity measures
- Implement border discontinuity designs

These would require a fundamentally different data collection effort.

## Conclusion

The current paper provides a methodologically sound null result using an appropriate modern DiD estimator, but the contribution is limited by:
1. Use of a stock outcome measure
2. Binary treatment coding
3. Abbreviated presentation

A more ambitious revision would require new data sources (claims, utilization measures) and extensive legal coding of parity law provisions.
