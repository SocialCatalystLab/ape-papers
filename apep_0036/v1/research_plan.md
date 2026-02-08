# Initial Research Plan

**Paper:** Does Income Support Help Workers Escape Automation Risk? EITC Eligibility and Occupational Mobility at Age 25

**Date:** 2026-01-19

---

## Research Question

Does access to the Earned Income Tax Credit (EITC) at age 25 differentially affect labor market outcomes for workers in high- versus low-automation-exposure occupations?

### Specific Hypotheses

**H1 (Income Effect):** EITC eligibility reduces labor supply (hours, employment) due to income effect. This effect may be stronger for workers in high-automation occupations who have weaker attachment to their jobs.

**H2 (Transition Effect):** EITC provides income cushion that facilitates occupational transitions. Workers in high-automation occupations may be more likely to switch to lower-automation occupations when eligible for EITC.

**H3 (Null Heterogeneity):** EITC effects do not vary by automation exposure—the small credit size (~$600) is insufficient to generate differential behavioral responses.

---

## Identification Strategy

### Running Variable
**Age in months** (or age at time of survey). The EITC eligibility threshold for childless workers is age 25.

### Treatment
At age 25, childless workers become eligible for EITC (approximately $600 credit for 2024). Before age 25, childless workers are ineligible regardless of income.

### Estimand
Local Average Treatment Effect (LATE) of EITC eligibility on labor market outcomes at the age 25 cutoff, estimated separately for workers in high vs. low automation-exposure occupations.

### Specification

**Main model:**
```
Y_i = α + τ·D_i + f(Age_i - 25) + D_i·f(Age_i - 25) + X_i·β + ε_i
```

Where:
- Y_i = outcome (employment, hours, earnings, occupation switch)
- D_i = 1 if age ≥ 25
- f(·) = polynomial in running variable (age centered at 25)
- X_i = controls (gender, race, education, state, year)

**Heterogeneity model:**
```
Y_i = α + τ₁·D_i + τ₂·D_i·HighAutomation_i + τ₃·HighAutomation_i +
      f(Age_i - 25) + D_i·f(Age_i - 25) + X_i·β + ε_i
```

Where HighAutomation_i = 1 if worker's occupation automation score > median.

### Bandwidth Selection
- Data-driven optimal bandwidth (Calonico, Cattaneo, Titiunik 2014)
- Robustness to ±1, ±2, ±3 year bandwidths

### Validity Checks
1. **McCrary density test:** No bunching of ages around cutoff
2. **Covariate smoothness:** Education, race, gender smooth across threshold
3. **Placebo thresholds:** No effects at ages 23, 24, 26, 27

---

## Data Sources

### Current Population Survey (CPS)
- **Source:** IPUMS CPS (cps.ipums.org)
- **Years:** 2015-2024 (10 years)
- **Sample:** ASEC supplement (Annual Social and Economic Supplement)
- **Key variables:**
  - AGE (in years)
  - NCHILD (number of own children in household)
  - EMPSTAT (employment status)
  - UHRSWORKLY (usual hours worked per week last year)
  - INCWAGE (wage and salary income)
  - OCC (detailed occupation code, 2018 Census classification)
  - SEX, RACE, EDUC, STATEFIP, YEAR

### CPS Matched Panels (for occupational transitions)
- Use CPS rotation group design: individuals surveyed for 4 months, out 8 months, back for 4 months
- Match individuals across rotation groups using CPSIDP
- Measure occupation at time t and t+12 months

### O*NET Automation Exposure
- **Source:** O*NET Resource Center (onetcenter.org)
- **Data:** Work Context "Degree of Automation" (scale 1-5)
- **Alternative:** LMI Institute Automation Exposure Score (scale 1-10)
- **Crosswalk:** SOC → Census occupation codes

### Variable Construction

**Treatment:**
- Childless = NCHILD == 0
- EligibleEITC = AGE >= 25

**Outcomes:**
- Employed = EMPSTAT == 10, 12
- Hours = UHRSWORKLY (conditional on employed)
- Log(Earnings) = log(INCWAGE + 1) (conditional on employed)
- OccupationSwitch = 1 if OCC_t ≠ OCC_{t+12} (matched sample only)

**Heterogeneity:**
- HighAutomation = AutomationScore > median(AutomationScore)
- Continuous: AutomationScore (standardized)

---

## Sample Restrictions

1. Ages 22-28 (±3 years around cutoff)
2. Childless workers (NCHILD == 0)
3. Not in school (SCHLCOLL ≠ 1, 2)
4. Not disabled (DIFFANY == 0)
5. Not in military (EMPSTAT ≠ 30-36)

**Expected sample size:** ~30,000-40,000 person-year observations

---

## Analysis Plan

### Main Results

1. **First stage:** Show EITC eligibility discontinuity at age 25 (plot eligibility/filing by age)
2. **Reduced form (overall):** RDD estimates for employment, hours, earnings
3. **Heterogeneity by automation:** Interaction with HighAutomation indicator
4. **Continuous heterogeneity:** Plot τ(AutomationScore) across automation distribution

### Robustness Checks

1. Different bandwidths (±1, ±2, ±3 years)
2. Different polynomial orders (linear, quadratic)
3. Local linear regression with triangular kernel
4. Donut RDD (exclude ages 24.5-25.5)
5. Placebo cutoffs (ages 23, 24, 26, 27)
6. Subsample by education, gender, race

### Figures

1. **Figure 1:** Age distribution of sample (McCrary test)
2. **Figure 2:** Covariate smoothness across age 25 threshold
3. **Figure 3:** Main RDD plots (employment, hours, earnings by age)
4. **Figure 4:** Heterogeneous effects by automation exposure
5. **Figure 5:** Binscatter of treatment effect vs automation score
6. **Figure 6:** Robustness to bandwidth choices

### Tables

1. **Table 1:** Summary statistics by age group (< 25 vs ≥ 25)
2. **Table 2:** Main RDD results
3. **Table 3:** Heterogeneous effects by automation quartile
4. **Table 4:** Robustness checks
5. **Table 5:** Placebo tests

---

## Timeline

1. Data fetch and cleaning: Day 1
2. Descriptive statistics: Day 1
3. Main RDD analysis: Day 1-2
4. Robustness checks: Day 2
5. Paper writing: Day 2-3
6. Review and revision: Day 3+

---

## Potential Issues and Mitigations

| Issue | Mitigation |
|-------|------------|
| Fuzzy RD (eligibility ≠ receipt) | Report ITT; note LATE interpretation |
| Small effect size (~$600 credit) | Focus on heterogeneity where effects may concentrate |
| Occupation endogenous to EITC | Use pre-determined occupation (at age 24) |
| Cross-sectional CPS limits switching | Use matched panels for switching outcomes |
| Other policies at age 25 | Check for confounding policies; note in limitations |

---

## Expected Contribution

1. **Methodological:** First RDD study of EITC age threshold with automation heterogeneity
2. **Substantive:** Tests whether income support facilitates occupational transitions in face of automation
3. **Policy:** Informs EITC expansion debates with evidence on who benefits most

---

## R Packages Required

```r
library(tidyverse)      # Data manipulation
library(haven)          # Read Stata/SPSS files
library(ipumsr)         # IPUMS data interface
library(rdrobust)       # RDD estimation
library(rddensity)      # McCrary test
library(fixest)         # Fixed effects regression
library(modelsummary)   # Tables
library(ggplot2)        # Figures
```
