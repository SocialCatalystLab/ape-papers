# Initial Research Plan: Wisconsin BadgerCare 100% FPL Cliff and Labor Supply

**Date Created:** January 18, 2026
**Status:** PRE-DATA (This document is locked after creation)

---

## Research Question

Does Wisconsin's unique Medicaid eligibility cliff at exactly 100% of the Federal Poverty Level (FPL) distort labor supply decisions among low-income adults?

## Background

Wisconsin is the only U.S. state that:
1. Rejected the ACA Medicaid expansion to 138% FPL
2. BUT covers all adults up to exactly 100% FPL through BadgerCare

This creates a sharp eligibility discontinuity at 100% FPL:
- **Below 100% FPL:** Eligible for BadgerCare (Medicaid) - free or near-free coverage
- **Above 100% FPL:** Must purchase coverage on the ACA exchange (subsidized but with premiums/cost-sharing)

This policy design is unique nationally. Other non-expansion states cover only specific categorical groups (pregnant women, parents with very low income), not all adults to 100% FPL.

## Identification Strategy

### Primary Design: Fuzzy Regression Discontinuity

**Running Variable:** Household income as a percentage of FPL (POVPIP in ACS PUMS)

**Threshold:** 100% FPL

**Treatment:** Medicaid (BadgerCare) eligibility

**Outcomes:**
1. Employment (binary: employed vs. not)
2. Hours worked (conditional on employment)
3. Earnings (wage/salary income)
4. Full-time vs. part-time status
5. Self-employment (alternative to wage employment)

### Econometric Specification

Local linear regression within bandwidth around 100% FPL:
```
Y_i = α + τ · D_i + β · (X_i - 100) + γ · D_i · (X_i - 100) + ε_i
```

Where:
- Y_i = outcome for individual i
- D_i = 1 if income ≤ 100% FPL
- X_i = income as % of FPL (running variable)
- τ = treatment effect (parameter of interest)

### Key Assumptions

1. **No precise manipulation:** Individuals cannot precisely sort to just below 100% FPL (fuzzy design accounts for imprecise control)
2. **Continuity:** Other determinants of labor supply are continuous at 100% FPL
3. **Local average treatment effect:** Estimates apply to compliers near threshold

## Expected Results

### Hypothesis 1: Labor Supply Reduction (Bunching Below Threshold)
- Prediction: Excess mass of individuals just below 100% FPL
- Magnitude: Small but detectable bunching (5-15% excess)
- Rationale: Some workers reduce hours/earnings to maintain Medicaid eligibility

### Hypothesis 2: Employment Effects
- Prediction: Null or small positive effect on employment at threshold
- Rationale: Medicaid may enable employment (health security), but work disincentives could offset

### Hypothesis 3: Heterogeneity by Demographics
- Prediction: Stronger effects for:
  - Single adults (no dependent-based eligibility routes)
  - Ages 26-64 (not on parents' insurance, not Medicare eligible)
  - Workers in industries with limited employer coverage

## Alternative Hypotheses

1. **No bunching:** ACA subsidies above 100% FPL smooth the cliff sufficiently
2. **Measurement error dominates:** PUMS income measurement too noisy to detect effects
3. **Limited awareness:** Workers don't know exact eligibility thresholds

## Data

**Source:** American Community Survey (ACS) PUMS, 2014-2023

**Sample:**
- Wisconsin residents
- Ages 19-64 (adult Medicaid-eligible ages)
- Non-disabled (to isolate work-capable population)
- Not in school full-time
- Civilian, non-institutionalized

**Comparison Group:** Similar individuals in neighboring states with different Medicaid designs:
- Minnesota (expanded to 138% FPL)
- Iowa (expanded)
- Illinois (expanded)
- Michigan (expanded)

## Analysis Plan

1. **Descriptive:** Distribution of income around 100% FPL in Wisconsin vs. comparison states
2. **McCrary Test:** Density discontinuity at 100% FPL threshold
3. **RDD Estimation:** Local linear regression with optimal bandwidth (Imbens-Kalyanaraman or Calonico-Cattaneo-Titiunik)
4. **Robustness:**
   - Alternative bandwidths
   - Polynomial orders
   - Donut RDD (exclude observations very close to threshold)
   - Placebo thresholds (50%, 75%, 125% FPL)
5. **Bunching Analysis:** Estimate excess mass below threshold using Chetty et al. (2011) methods

## Validity Checks

1. **Balance tests:** Covariate continuity at threshold (age, education, race, family structure)
2. **Placebo states:** No discontinuity expected in expansion states at 100% FPL
3. **Pre-period:** No discontinuity before 2014 (when current policy took effect)
4. **Sensitivity:** Results robust to exclusion of self-employed (income easier to manipulate)

## Expected Contribution

1. **Novel Policy Evaluation:** First study of Wisconsin's unique 100% FPL adult Medicaid cliff
2. **Benefit Cliff Literature:** Contributes to understanding of how eligibility thresholds affect labor supply
3. **Policy Relevance:** Informs debate over Medicaid expansion vs. partial coverage designs

## Limitations (Anticipated)

1. PUMS income is measured annually with recall error; true program eligibility depends on monthly income
2. Cannot observe actual BadgerCare enrollment (only eligibility)
3. Fuzzy first stage may weaken precision
4. Local average treatment effect - external validity limited

---

**Commitment:** This plan is written BEFORE examining any data. Analysis will proceed as specified above. Any deviations will be documented in research_plan.md.
