# Initial Research Plan

**Title:** Medicare Eligibility and Labor Force Exit: Heterogeneous Effects by Automation Exposure

**Date:** 2026-01-19

---

## Research Question

Does Medicare eligibility at age 65 have a larger effect on labor force exit for workers in high-automation-exposure occupations compared to low-automation-exposure occupations?

## Motivation

Two major forces shape older workers' labor market decisions:

1. **Health insurance and "job lock"**: Workers may remain employed primarily for employer-sponsored health insurance. Medicare eligibility at age 65 removes this constraint.

2. **Automation and job displacement**: Workers in high-automation occupations face greater displacement risk and may have less bargaining power with employers.

**Key insight:** The intersection of these forces is understudied. High-automation workers may be more responsive to Medicare eligibility because:
- They have less job security to begin with
- They may face implicit pressure to retire
- Medicare removes their primary reason to stay (health insurance)

## Identification Strategy

### Design: RDD at Age 65 with Heterogeneous Effects

**Running variable:** Age (in years, centered at 65)

**Treatment:** Medicare eligible (age >= 65)

**Heterogeneity dimension:** Automation exposure (continuous, 0-1 probability from Frey-Osborne)

**Key estimand:**
- τ_high = Effect of Medicare eligibility on LFP for high-automation workers
- τ_low = Effect of Medicare eligibility on LFP for low-automation workers
- τ_diff = τ_high - τ_low (difference in effects)

### Doubly Robust Estimation

Within the RDD framework, use DR/AIPW to adjust for covariates:
- Demographics: gender, race, marital status
- Education: detailed levels
- Geographic: state fixed effects
- Industry: broad categories
- Income: wage terciles
- Time: year fixed effects

### Addressing GPT Feedback Concerns

1. **Focus tightly on age 65**: Sample restricted to ages 60-70 (5-year bandwidth each side)
2. **Last occupation for retirees**: Use occupation at age 60-64 as the relevant automation exposure (avoids endogenous occupation switching)
3. **Selection into occupations**: Control for education, cognitive demand, industry - use sensitivity analysis for remaining selection

## Data

### Primary: IPUMS CPS (2005-2023)

Extract variables:
- EMPSTAT: Employment status
- LABFORCE: Labor force participation
- AGE: Age in years
- OCC2010: Occupation (harmonized)
- IND1990: Industry
- EDUC: Education
- SEX, RACE, MARST: Demographics
- STATEFIP: State
- YEAR: Year
- HCOVANY, HINSEMP: Health insurance coverage

### Secondary: Frey-Osborne Automation Probabilities

- 702 occupations with automation probabilities (0-1 scale)
- Crosswalk SOC 2010 → Census OCC2010 via BLS crosswalk

## Expected Effects

**Hypothesis:** τ_high > τ_low (Medicare has larger effect on high-automation workers)

**Magnitude:**
- Baseline LFP drop at 65: ~3-5 pp (literature)
- Expected difference by automation: 1-3 pp additional drop for high-auto workers

**Mechanisms:**
1. Health insurance access (primary)
2. Reduced bargaining leverage for high-auto workers
3. Employer-side incentives to facilitate exit

## Robustness Checks

1. **Bandwidth sensitivity:** 3, 5, 7, 10 year windows
2. **Polynomial specification:** Linear, quadratic in age
3. **Placebo cutoffs:** Test for discontinuities at ages 62, 67, 70
4. **Alternative automation measures:** AIOE (Felten et al.), LMI scores
5. **Subgroup analysis:** By education, industry, state
6. **Sensitivity analysis:** E-values for unmeasured confounding
7. **McCrary density test:** Check for manipulation of running variable

## Timeline

1. Data acquisition and cleaning
2. Merge automation indices
3. Descriptive statistics and visualization
4. Main RDD estimation
5. Heterogeneity analysis
6. Robustness checks
7. Write paper
8. Internal review
9. External review
10. Publish

## Potential Limitations

1. **Age in years (not months):** Discrete running variable limits RDD precision - will use local randomization methods (Cattaneo et al.)
2. **Occupation measurement:** Occupation at survey date may not reflect pre-retirement occupation for non-workers
3. **Selection into occupations:** Cannot fully rule out unobserved confounders affecting both occupation choice and retirement
4. **Medicare enrollment vs eligibility:** Some delay enrollment; using eligibility (age 65) as treatment
