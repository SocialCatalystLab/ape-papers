# Initial Research Plan

**Title:** Self-Employment and Health Insurance Coverage in the Post-ACA Era: A Doubly Robust Analysis

**Date:** 2026-01-25
**Method:** Doubly Robust (AIPW with machine learning)

---

## Research Question

Does self-employment reduce health insurance coverage compared to wage employment, and if so, through what mechanisms? How has this relationship evolved in the post-ACA Marketplace era (2018-2022)?

---

## Identification Strategy

### Design
Doubly Robust estimation (AIPW) comparing self-employed workers to wage/salary workers, estimating the Average Treatment Effect on the Treated (ATT).

### Treatment Definition
- **Treated:** Self-employed workers (COW = 6: unincorporated, or COW = 7: incorporated)
- **Control:** Wage and salary workers (COW = 1-5: private for-profit, non-profit, local/state/federal government)
- **Excluded:** Unemployed (COW = 9), unpaid family workers (COW = 8)

### Primary Outcomes
1. **Any health insurance coverage** (HICOV = 1)
2. **Private coverage** (PRIVCOV = 1)
3. **Public coverage** (PUBCOV = 1)
4. **Employer-sponsored insurance** (HINS1 = 1)
5. **Direct purchase/Marketplace** (HINS2 = 1)
6. **Medicaid** (HINS4 = 1)

### Key Assumption: Conditional Independence (Unconfoundedness)
Treatment assignment (self-employment) is independent of potential insurance outcomes, conditional on observed covariates:
$$(Y(1), Y(0)) \perp T \mid X$$

**Plausibility assessment:**
- Strong: We observe detailed demographics, occupation, industry, location, household structure
- Concern: Risk tolerance, health status, entrepreneurial ability are unobserved
- Mitigation: Extensive sensitivity analysis using E-values and calibrated benchmarks

---

## Covariates for Adjustment

### Demographics
- Age (AGEP): continuous + quadratic
- Sex (SEX): binary
- Race/ethnicity (RAC1P, HISP): categorical
- Education (SCHL): categorical (less than HS, HS, some college, BA, graduate)
- Marital status (MAR): categorical

### Labor Market
- Occupation (OCCP): 2-digit SOC groups
- Industry (INDP): 2-digit NAICS groups
- Usual hours worked (WKHP): continuous
- Weeks worked (WKWN): continuous

### Household/Family
- Married spouse present (MSP): binary
- Presence of children (PAOC): categorical
- Household size (NP): continuous
- Household income (HINCP): income quintiles

### Geographic
- State (ST): state fixed effects
- Metro status: derived from PUMA
- Medicaid expansion state: merged external indicator

---

## Expected Effects and Mechanisms

### Main Hypothesis
Self-employed workers have lower overall insurance coverage rates than wage workers, primarily due to lack of employer-sponsored insurance (HINS1).

### Subgroup Predictions
1. **Incorporated vs. unincorporated self-employed:** Incorporated may have higher coverage (can offer themselves employer plans)
2. **Medicaid expansion states:** Self-employed in expansion states may have higher public coverage rates
3. **Income heterogeneity:** Low-income self-employed may rely on Marketplace/Medicaid; high-income may self-insure
4. **Spousal coverage:** Married self-employed may access coverage through spouse

### Mechanisms to Explore
- Substitution from employer to Marketplace/Medicaid
- Role of spousal insurance availability
- Industry-specific effects (gig economy vs. traditional self-employment)

---

## Primary Specification

### AIPW Estimator
Using the `AIPW` R package with SuperLearner ensemble for nuisance estimation:

```r
library(AIPW)
library(SuperLearner)

sl_lib <- c("SL.glm", "SL.ranger", "SL.xgboost")

aipw_fit <- AIPW$new(
  Y = df$insured,       # Binary outcome
  A = df$self_employed, # Binary treatment
  W = df[, covariates], # Covariate matrix
  Q.SL.library = sl_lib, # Outcome model
  g.SL.library = sl_lib, # Propensity model
  k_split = 10           # 10-fold cross-fitting
)
```

### Inference
- Influence-function based standard errors (built into AIPW)
- 95% confidence intervals
- Cluster-robust SEs at state level as sensitivity check

---

## Robustness Checks

### 1. Alternative Estimators
- TMLE (for positivity concerns)
- DoubleML PLR (Chernozhukov approach)

### 2. Propensity Score Diagnostics
- Overlap histogram
- Trimming at 0.01/0.99
- Overlap-weighted estimator

### 3. Sensitivity Analysis (CRITICAL)
- E-values for unmeasured confounding
- Calibrated sensitivity (benchmark to education, race as reference confounders)
- Partial R-squared bounds (sensemakr)

### 4. Negative Control Outcomes
- Medicare coverage (HINS3) for under-65 sample → should be zero effect
- VA coverage (HINS6) among non-veterans → should be zero effect

### 5. Falsification Tests
- Effect among 65+ (Medicare-eligible) → should be attenuated
- Effect on variables unaffected by insurance status

### 6. Subgroup Analyses
- By Medicaid expansion status
- By income level
- By marital status (access to spousal coverage)
- By self-employment type (incorporated vs. not)

---

## Data Requirements

### Source
Census Bureau American Community Survey (ACS) Public Use Microdata Sample (PUMS)
- Years: 2018-2022 (5-year pooled or single years)
- API: https://api.census.gov/data/{year}/acs/acs1/pums

### Sample Restrictions
- Age 25-64 (working age, pre-Medicare)
- Employed (ESR = 1 or 2)
- Civilian (exclude military)
- Not in group quarters

### Variables to Fetch
```
AGEP, SEX, RAC1P, HISP, SCHL, MAR, MSP, COW,
OCCP, INDP, WKHP, WKWN, HINCP, NP, ST, PUMA,
HICOV, PRIVCOV, PUBCOV, HINS1, HINS2, HINS3, HINS4, HINS5, HINS6,
PWGTP, ESR
```

### Expected Sample Size
- ~1.1M workers per year × 5 years = ~5.5M observations
- Self-employed: ~10% = ~550K
- Sufficient power for subgroup analyses

---

## Timeline and Outputs

### Phase 4 Deliverables
1. `code/01_fetch_data.R` - Data acquisition from Census API
2. `code/02_clean_data.R` - Variable construction, sample restrictions
3. `code/03_main_analysis.R` - Primary AIPW estimation
4. `code/04_robustness.R` - All robustness checks
5. `code/05_figures.R` - Publication-ready figures
6. `code/06_tables.R` - Formatted regression tables

### Key Figures
1. Propensity score overlap (histogram by treatment)
2. Covariate balance before/after weighting
3. Main effects by outcome type (forest plot)
4. Heterogeneity by Medicaid expansion/income (interaction plot)
5. Sensitivity analysis (E-value/bounds plot)

### Key Tables
1. Summary statistics by treatment status
2. Main AIPW results (6 outcomes)
3. Robustness to alternative estimators
4. Subgroup analysis results
5. Sensitivity analysis parameters

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Severe propensity score non-overlap | Medium | Trimming, TMLE, overlap weights |
| Unmeasured confounding invalidates results | High | Strong sensitivity analysis, calibrated benchmarks |
| Results not novel enough | Medium | Focus on post-ACA mechanisms, Marketplace heterogeneity |
| Computational issues with large sample | Low | Subsample for tuning, efficient packages |

---

## Commitment

This plan documents the intended analysis BEFORE examining the data. The plan is locked and hashed at the time of creation.
