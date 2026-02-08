# Pre-Analysis Plan: Lifeline Broadband Subsidy Eligibility and Self-Employment

**Paper ID:** paper_20
**Date:** 2026-01-17
**Status:** DRAFT (to be locked before analysis)

---

## 1. Research Question

Does eligibility for the FCC Lifeline broadband subsidy (at the 135% Federal Poverty Level income threshold) increase self-employment and entrepreneurship?

## 2. Hypothesis

Households just below the 135% FPL threshold are eligible for the Lifeline broadband subsidy, which reduces the cost of internet access. We hypothesize that:

1. **First Stage:** Lifeline eligibility increases broadband adoption (HISPEED=1).
2. **Second Stage:** Broadband access enables self-employment and gig economy participation by reducing barriers to starting and operating a home-based business, accessing online marketplaces, and finding freelance work.

**Expected direction:** Positive effect of eligibility on both broadband adoption and self-employment.

## 3. Identification Strategy

### 3.1 Design: Fuzzy Regression Discontinuity

- **Running variable:** Household income as a percentage of Federal Poverty Level (FPL)
- **Cutoff:** 135% FPL (Lifeline eligibility threshold)
- **Treatment:** Eligibility for Lifeline broadband subsidy ($9.25/month discount)
- **Assignment:** Fuzzy (eligibility ≠ enrollment ≠ broadband adoption)

### 3.2 FPL Calculation

Federal Poverty Level thresholds for 2023 (will use appropriate year's thresholds):
| Household Size | 100% FPL | 135% FPL |
|----------------|----------|----------|
| 1 | $14,580 | $19,683 |
| 2 | $19,720 | $26,622 |
| 3 | $24,860 | $33,561 |
| 4 | $30,000 | $40,500 |
| 5 | $35,140 | $47,439 |
| 6 | $40,280 | $54,378 |
| 7 | $45,420 | $61,317 |
| 8 | $50,560 | $68,256 |

**Construction:** FPL_ratio = HINCP / FPL_threshold(NP)

### 3.3 Bandwidth Selection

- **Primary:** Optimal bandwidth using Imbens-Kalyanaraman (IK) procedure
- **Robustness:** Test bandwidths of 10%, 15%, 20%, and 25% FPL on either side of cutoff
- **Sample restriction:** Households with FPL ratio between 75% and 200%

### 3.4 Estimation

**First Stage (Broadband Adoption):**
```
HISPEED_i = α + β₁ · ELIGIBLE_i + f(FPL_ratio_i) + X_i'γ + ε_i
```

**Reduced Form (Self-Employment):**
```
SELFEMP_i = α + β₁ · ELIGIBLE_i + f(FPL_ratio_i) + X_i'γ + ε_i
```

**Two-Stage Least Squares (if first stage is strong):**
```
Stage 1: HISPEED_i = α + β₁ · ELIGIBLE_i + f(FPL_ratio_i) + X_i'γ + ν_i
Stage 2: SELFEMP_i = α + β₂ · HISPEED_hat_i + f(FPL_ratio_i) + X_i'γ + ε_i
```

Where:
- ELIGIBLE_i = 1 if FPL_ratio ≤ 135%
- f(·) = polynomial function of running variable (linear, quadratic, or local linear)
- X_i = control variables

### 3.5 Controls

**Core controls:**
- Age (AGEP), Age²
- Sex (SEX)
- Race (RAC1P)
- Education (SCHL)
- State fixed effects (ST)
- Year fixed effects

**Additional controls (sensitivity):**
- Marital status (MAR)
- Citizenship (CIT)
- Number of persons in household (NP)

## 4. Data

### 4.1 Source
Census Bureau American Community Survey (ACS) Public Use Microdata Sample (PUMS), 1-year estimates.

### 4.2 Years
2019-2023 (5 years of data for adequate sample size)

### 4.3 Sample Restrictions

1. Working-age adults (18-64)
2. Household heads or spouses (to avoid double-counting households)
3. FPL ratio between 75% and 200% (within bandwidth of cutoff)
4. Non-institutionalized civilian population
5. Valid income and broadband data

### 4.4 Key Variables

**Running Variable:**
- HINCP: Household income (past 12 months)
- NP: Number of persons in household
- Constructed: FPL_ratio = HINCP / FPL_threshold(NP, year)

**Treatment (First Stage Outcome):**
- HISPEED: Broadband internet subscription (1=Yes, 2=No)
- ACCESSINET: Internet access at home (backup)

**Primary Outcomes (Self-Employment):**
- COW: Class of worker (6=self-employed not incorporated, 7=self-employed incorporated)
- SEMP: Self-employment income (past 12 months)

**Constructed Outcomes:**
- SELFEMP = 1 if COW ∈ {6, 7}
- ANY_SEMP = 1 if SEMP > 0
- LOG_SEMP = log(SEMP + 1) for intensive margin

**Weights:**
- PWGTP: Person weight (for population estimates)
- PWGTP1-80: Replicate weights (for standard errors)

## 5. Analysis Plan

### 5.1 Descriptive Statistics

1. Summary statistics by eligibility status (above/below 135% FPL)
2. Balance table on pre-determined covariates at the cutoff
3. Histogram of running variable (McCrary density test for manipulation)

### 5.2 Main Results

**Table 1:** First Stage - Effect of eligibility on broadband adoption
- Column 1: No controls
- Column 2: With demographic controls
- Column 3: With state/year fixed effects

**Table 2:** Reduced Form - Effect of eligibility on self-employment
- Same column structure as Table 1
- Panel A: Self-employment indicator (COW=6,7)
- Panel B: Any self-employment income (SEMP>0)
- Panel C: Log self-employment income (intensive margin)

**Table 3:** 2SLS - Effect of broadband on self-employment (if first stage F>10)

### 5.3 Figures

**Figure 1:** McCrary density test (histogram of FPL ratio around cutoff)
**Figure 2:** RD plot - Broadband adoption by FPL ratio (binned scatter + fitted lines)
**Figure 3:** RD plot - Self-employment rate by FPL ratio
**Figure 4:** RD plot - Self-employment income by FPL ratio

### 5.4 Robustness Checks

1. **Bandwidth sensitivity:** 10%, 15%, 20%, 25% FPL bandwidths
2. **Polynomial order:** Linear, quadratic, local linear
3. **Placebo cutoffs:** Test for discontinuities at 100%, 120%, 150%, 175% FPL
4. **Donut hole:** Exclude observations within 2% FPL of cutoff (manipulation robustness)
5. **Subsample analysis:** By state, by year, by age group, by education
6. **Alternative outcomes:** Incorporated vs unincorporated self-employment, gig work indicators

### 5.5 Heterogeneity Analysis

1. By state (Utah vs South Dakota vs Massachusetts vs others)
2. By urban/rural status (using PUMA characteristics)
3. By education level
4. By age group
5. By industry sector (for those currently employed)

## 6. Inference

- Standard errors clustered at PUMA level (geographic clustering)
- Alternative: Robust standard errors using replicate weights
- Report both 95% confidence intervals and p-values
- First stage F-statistic must exceed 10 for 2SLS

## 7. Threats to Validity

### 7.1 Manipulation
- Income reporting may be noisy but unlikely to be precisely manipulated around 135% FPL
- McCrary test will assess density manipulation
- Donut hole specification as robustness

### 7.2 Measurement Error
- PUMS income is past 12 months, may not align with Lifeline enrollment timing
- Cannot observe actual Lifeline enrollment (fuzzy design)
- Attenuation bias likely—estimates are lower bound

### 7.3 Concurrent Policies
- Other programs may have similar income thresholds (SNAP at 130%, Medicaid varies)
- Control for state-year fixed effects
- Discuss potential confounding in paper

### 7.4 External Validity
- Lifeline take-up is low (~20% of eligible)
- Estimates represent local average treatment effect (LATE) for compliers
- Generalizability to broader populations is limited

## 8. Decision Rules

### 8.1 Proceeding with 2SLS
- Only if first-stage F-statistic > 10
- Otherwise, report reduced form as intent-to-treat effect

### 8.2 Interpretation
- If first stage is weak (F<10): Focus on reduced-form "eligibility effect"
- If no reduced-form effect: Report null finding, discuss power
- If positive effects: Discuss mechanisms and policy implications

### 8.3 Publication
- Report all pre-specified analyses regardless of significance
- Clearly distinguish pre-specified from exploratory analyses

## 9. Expected Sample Size

Based on ACS PUMS:
- ~3.5 million person records per year
- ~1.5 million working-age adults per year
- ~300,000 within 75-200% FPL bandwidth per year
- ~1.5 million over 5 years in analysis sample

This should provide adequate power for detecting moderate effect sizes.

---

**Lock Status:** DRAFT
**To be locked before any regression analysis**
