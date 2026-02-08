# Initial Research Plan - Paper 70

## Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid? A Regression Discontinuity Analysis

**Date:** 2026-01-23
**Method:** Regression Discontinuity Design (Discrete RDD)

---

## Research Question

Does the ACA-mandated loss of dependent health insurance coverage at age 26 cause a discontinuous shift in the source of payment for childbirth—from private insurance to Medicaid or self-pay (uninsured)?

## Policy Background

The Affordable Care Act's dependent coverage provision (effective September 2010) requires private health insurers to allow young adults to remain on their parents' plans until age 26. Upon turning 26, individuals "age out" and must obtain coverage through:
- Employer-sponsored insurance
- Medicaid (if income-eligible)
- ACA marketplace plans
- Remain uninsured

~30% of US births are to women ages 19-25, the population directly affected by this provision.

## Identification Strategy

### Design: Discrete Regression Discontinuity

**Running variable:** Mother's age at delivery (single year, from MAGER variable)

**Cutoff:** Age 26

**Treatment:** Loss of eligibility for parental health insurance coverage

**Bandwidth:** Primary: Ages 24-28 (2 years each side). Sensitivity: 23-29, 22-30.

### Estimand

Intent-to-Treat (ITT) effect of reaching the age threshold for dependent coverage loss on source of payment for delivery.

### Key Assumption

Continuity of potential outcomes at the age-26 cutoff. Women just above 26 are comparable to women just below 26 in all respects except insurance coverage eligibility.

### Why This Is Credible

1. **Age is exogenous**: Women cannot manipulate their date of birth
2. **No birth timing manipulation**: Pregnancy is ~9 months; timing births to avoid insurance loss is implausible
3. **Sharp policy rule**: Coverage ends on 26th birthday (not gradual)

## Data

### Primary: NBER/CDC Natality Public Use Files (2016-2024)

**Source:** https://www.nber.org/research/data/vital-statistics-natality-birth-data

**Sample:** All US births to mothers ages 22-30 (for bandwidth flexibility)

**Key Variables:**
- `MAGER`: Mother's single year of age (running variable)
- `PAY`: Source of payment for delivery
  - 1 = Medicaid
  - 2 = Private insurance
  - 3 = Self-pay (uninsured)
  - 4 = Other (IHS, TRICARE, other government)
  - 9 = Unknown/not stated
- `MRACE6`: Mother's race (6 categories)
- `MEDUC`: Mother's education
- `DMAR`: Marital status
- `MBSTATE_REC`: Mother's birth state (US-born vs foreign-born)
- `LBO_REC`: Live birth order
- `PRECARE5`: Month prenatal care began
- `DBWT`: Birth weight
- `COMBGEST`: Combined gestation estimate (weeks)

**Sample Size:** ~400,000 births annually at ages 25-26; ~3.2 million total with 8 years of data.

### Secondary: American Community Survey (IPUMS)

For supplementary analysis of health insurance coverage by single year of age (not conditional on giving birth).

## Econometric Specification

### Primary Specification

Local polynomial regression with triangular kernel:

```
Y_i = α + τ · D_i + β · (Age_i - 26) + γ · D_i · (Age_i - 26) + ε_i
```

Where:
- `Y_i` = Outcome (e.g., 1 if Medicaid-paid, 0 otherwise)
- `D_i` = 1 if Age_i ≥ 26, 0 otherwise
- `τ` = RD estimate (effect of crossing age-26 threshold)

### Inference

Given discrete running variable (integer ages), we will use:

1. **Kolesár & Rothe (2018)** variance estimator for discrete RDD
2. **Local randomization inference** (Cattaneo et al. 2015) as robustness check
3. **Cluster-robust SEs** at the state level (treatment varies by state Medicaid eligibility)

### R Packages

```r
library(rdrobust)      # Main RD estimation
library(rddensity)     # McCrary density test
library(rdlocrand)     # Local randomization inference
library(fixest)        # Alternative estimation with clustering
```

## Validity Tests

### 1. Covariate Balance

Test for discontinuities at age 26 in predetermined characteristics:
- Mother's race/ethnicity
- Mother's education
- Marital status
- Nativity (US-born)
- Live birth order

**Expectation:** No discontinuities (these are determined before age 26)

### 2. Density Test (No Bunching)

McCrary (2008) test for manipulation of running variable.

**Expectation:** Smooth density of births across age 26 (women cannot time births to avoid threshold)

### 3. Placebo Cutoffs

Test for "effects" at ages 24, 25, 27, 28.

**Expectation:** No discontinuities at non-policy-relevant ages

### 4. Bandwidth Sensitivity

Vary bandwidth: h = 1, 2, 3, 4, 5 years on each side of cutoff.

**Expectation:** Estimates stable across reasonable bandwidth choices

## Expected Results

Based on prior DiD literature (Daw & Sommers 2018; Simon et al. 2017):

| Outcome | Expected RD Estimate | Direction |
|---------|---------------------|-----------|
| Private insurance | -3 to -5 pp | ↓ at 26 |
| Medicaid | +2 to +4 pp | ↑ at 26 |
| Self-pay (uninsured) | +0.5 to +1.5 pp | ↑ at 26 |

## Mechanisms

At age 26, women lose parental insurance eligibility. Those without employer coverage:

1. **Income-eligible** → Enroll in Medicaid
2. **Above Medicaid threshold, below marketplace affordability** → Remain uninsured
3. **Can afford marketplace** → Purchase ACA plan

The magnitude of the shift to Medicaid vs. uninsured depends on state Medicaid expansion status.

## Heterogeneity Analysis

1. **Medicaid expansion vs. non-expansion states** (post-2014)
2. **Married vs. unmarried mothers** (married more likely to have spousal coverage)
3. **Education levels** (higher education → more likely to have employer coverage)
4. **Pre-ACA vs. post-ACA periods** (compare 2016-2024 to assess policy evolution)

## Robustness Checks

1. **Donut-hole RDD**: Exclude age 26 to assess birthday timing uncertainty
2. **Different polynomial orders**: Linear, quadratic, cubic
3. **Alternative kernels**: Uniform, triangular, Epanechnikov
4. **Placebo outcomes**: Outcomes that should not change at 26 (e.g., mother's education level)
5. **Local randomization**: Alternative inference for discrete running variable

## Figures

1. **Main RD plot**: Source of payment (y) vs. mother's age (x) with fitted lines
2. **Covariate balance**: Similar plots for each predetermined covariate
3. **McCrary density**: Histogram of births by age with density test
4. **Bandwidth sensitivity**: Coefficient plot across different bandwidths
5. **Heterogeneity by Medicaid expansion**: Separate RD plots for expansion vs. non-expansion states

## Tables

1. **Summary statistics**: Sample characteristics by age group (24-25 vs. 26-27)
2. **Main results**: RD estimates for each payment source
3. **Covariate balance**: RD estimates for predetermined characteristics
4. **Robustness**: Different bandwidths, specifications, inference methods
5. **Heterogeneity**: By Medicaid expansion, marital status, education

## Contribution

This paper offers three contributions:

1. **Methodological**: First true RDD at the age-26 threshold for birth outcomes (prior work uses DiD with age groups)

2. **Substantive**: Quantifies the causal effect of insurance loss on payment source at delivery—a policy-relevant margin given Medicaid covers ~42% of US births

3. **Policy**: Informs debates about extending dependent coverage beyond 26 or creating coverage continuity mechanisms for young adults

## Timeline

1. Download natality files from NBER
2. Clean and construct analysis sample
3. Implement RDD estimation
4. Run validity tests
5. Estimate main results and heterogeneity
6. Generate figures and tables
7. Write paper

## References

- Akosa Antwi, Y., Moriya, A.S., & Simon, K. (2015). "Access to health insurance and the use of inpatient medical care." J Health Econ.
- Daw, J.R. & Sommers, B.D. (2018). "Association of the ACA Dependent Coverage Provision With Prenatal Care Use and Birth Outcomes." JAMA.
- Kolesár, M. & Rothe, C. (2018). "Inference in Regression Discontinuity Designs with a Discrete Running Variable." AER.
- Lee, D.S. & Lemieux, T. (2010). "Regression Discontinuity Designs in Economics." JEL.
- McCrary, J. (2008). "Manipulation of the running variable in the regression discontinuity design: A density test." JoE.
