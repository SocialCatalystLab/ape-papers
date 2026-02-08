# Initial Research Plan

## Title
Self-Employment as Bridge Employment: Does the ACA Unlock Flexible Retirement Pathways for Older Workers?

## Research Question
Among workers aged 55-70, does self-employment serve as a bridge to retirement (facilitating gradual withdrawal from the labor force) by offering reduced hours and flexible work arrangements? How did the Affordable Care Act change this relationship by decoupling health insurance from employment?

## Motivation
Prior to the ACA, older workers faced significant "job lock" - the inability to leave employer-sponsored health insurance before Medicare eligibility at 65. This particularly constrained the transition to self-employment, which traditionally lacked affordable health insurance options. The ACA's individual marketplace, premium subsidies, and guaranteed issue provisions may have unlocked self-employment as a viable bridge employment pathway.

This connects two important literatures:
1. **Bridge employment literature** - documents phased retirement through part-time work, but focuses on job type rather than employment status
2. **ACA/job lock literature** - documents effects on entrepreneurship and self-employment rates, but less focus on older workers specifically

## Identification Strategy

### Primary Design: Doubly Robust Estimation
Treatment: Self-employment (COW=6,7) vs. wage employment (COW=1-5) among employed workers aged 55-70
Outcome: Weekly hours worked (WKHP), part-time incidence (WKHP<35), income (PINCP)

Key covariates for propensity score and outcome model:
- Demographics: Age, sex, race/ethnicity, marital status
- Human capital: Education, occupation (2-digit SOCP), industry (NAICS)
- Geography: State, metropolitan status
- Health: Disability status (DIS)

### Design Enhancements (per reviewer feedback)
1. **Pre/post ACA comparison**: 2010-2013 (pre-marketplace) vs 2015-2019 (post-marketplace, pre-COVID)
2. **Medicaid expansion heterogeneity**: Compare effects in expansion vs non-expansion states (2014 cutoff)
3. **Medicare placebo**: Workers 65+ (Medicare-eligible) should show no ACA effect - tests mechanism
4. **Age gradient**: Effects should be larger for 55-64 (ACA-dependent for insurance) than 65+ (Medicare)

### Estimand
Average Treatment Effect on the Treated (ATT): Effect of self-employment on hours worked for those who chose self-employment, relative to counterfactual wage employment.

## Expected Effects and Mechanisms

**Hypothesis 1 (Bridge Employment):** Self-employed workers aged 55-64 work fewer hours than comparable wage workers (flexibility hypothesis)

**Hypothesis 2 (ACA Effect):** The self-employment hours gap widened after ACA implementation (insurance decoupling enabled bridge employment)

**Hypothesis 3 (Medicare Placebo):** No such change for workers 65+ (already Medicare-eligible)

**Hypothesis 4 (Medicaid Expansion Heterogeneity):** Effects stronger in Medicaid expansion states (broader insurance access)

**Alternative Hypothesis:** Self-employment represents precarious work, not bridge employment - would show higher hours, not lower

## Primary Specification

```
Outcome_it = β₁(SelfEmployed_it) + β₂(SelfEmployed × Post2014) + X_it'γ + State_s + Year_t + ε_it
```

Using doubly robust AIPW estimator with:
- Propensity score: Random forest/XGBoost ensemble
- Outcome model: Random forest/XGBoost ensemble
- 10-fold cross-fitting
- Trimming at propensity scores < 0.01 or > 0.99

## Sample Definition

**Inclusion criteria:**
- Employed (ESR = 1 or 2)
- Age 55-74
- Non-missing hours worked (WKHP > 0)
- Non-missing class of worker (COW)

**Exclusion criteria:**
- Agricultural workers (excluded from ACA employer mandate)
- Government workers (COW = 3,4,5) - different insurance dynamics
- Unpaid family workers

**Analysis groups:**
- Pre-Medicare (55-64): main treatment group
- Post-Medicare (65-74): placebo/control group

## Planned Robustness Checks

1. **Alternative ML methods**: Compare SuperLearner, XGBoost, random forest for nuisance estimation
2. **Different trimming rules**: 1%, 5%, 10% tails
3. **Outcome transformations**: Log hours, part-time indicator, hours bins
4. **Sample restrictions**: Full-time workers only, exclude self-employed professionals
5. **State subsamples**: Large states only for precision
6. **Year-by-year effects**: Event study around 2014
7. **Sensitivity analysis**: E-values, calibrated sensitivity (sensemakr)
8. **Negative controls**: Effect on outcomes that shouldn't change (e.g., occupation type)

## Data Sources

**Primary:** American Community Survey PUMS (Census API, 2010-2023)
- ~3 million observations per year
- Key variables: AGEP, COW, WKHP, PINCP, SCHL, SOCP, NAICS, ST, DIS, HICOV, SEX, RAC1P, MAR

**Supplementary:** 
- O*NET for occupation-level characteristics (physical demands, flexibility)
- KFF for state Medicaid expansion dates

## Power Assessment

**Sample size:** Expect ~500,000 self-employed workers aged 55-70 across 2010-2023 ACS
**Treatment rate:** ~15-20% of employed workers aged 55-70 are self-employed
**Minimum detectable effect:** With N=2,000,000+, should detect effects of 0.5-1 hour/week (very small)

## Timeline (Aspirational)

1. Data fetch and cleaning
2. Descriptive statistics and balance assessment
3. Propensity score estimation and overlap diagnostics
4. Main DR estimates (ATT of self-employment on hours)
5. Pre/post ACA comparison
6. Heterogeneity analysis (age, Medicaid expansion)
7. Sensitivity analysis
8. Write-up

## Potential Concerns and Responses

1. **Selection on unobservables**: Sensitivity analysis with E-values; benchmark to observed confounders
2. **ACS is cross-sectional**: Cannot observe transitions; interpret as steady-state comparison
3. **COVID contamination**: Use 2010-2019 as primary sample; 2020+ as supplementary
4. **Occupation endogeneity**: Condition on pre-treatment occupation proxies (education)
5. **Surviving workers bias**: Older workers who are employed may be selected; acknowledge limitation
