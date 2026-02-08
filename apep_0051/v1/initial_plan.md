# Initial Research Plan: Aging Out at 26 and Fertility

## Research Question

Does the loss of parental health insurance coverage at age 26 affect fertility decisions among young women in the United States?

## Background and Motivation

The Affordable Care Act's dependent coverage provision, effective September 2010, allows young adults to remain on their parents' health insurance until age 26. At this age threshold, individuals experience a sharp discontinuity in insurance access: they must transition to employer-provided coverage, individual market plans, Medicaid, or become uninsured.

Prior research has established that:
1. Insurance coverage drops by 3-5 percentage points at age 26 (Dahlen 2015; Yörük & Xu 2018)
2. Young adults rely on employment as a means of maintaining coverage after 26
3. The ACA dependent coverage provision improved insurance coverage and prenatal care for young women (Ma et al. 2018)

However, no study has used a regression discontinuity design to examine fertility outcomes specifically at the age 26 threshold. This study fills that gap.

## Identification Strategy

### Regression Discontinuity Design

**Running variable:** Age in years (AGEP in ACS PUMS)

**Cutoff:** Age 26

**Treatment:** Loss of eligibility for parental insurance coverage

**Key assumption:** All observable and unobservable characteristics vary smoothly through age 26, except for insurance coverage eligibility

**Validity support:**
- Individuals cannot manipulate their birthday
- Age 26 is defined by statute, not selection
- No other major policy changes at exactly age 26

### Addressing Discrete Running Variable

Since age is measured in whole years (mass points), we will:
1. Use `rdrobust` with `masspoints = "adjust"` for appropriate variance estimation
2. Present simple mean comparisons (25 vs 26 vs 27) alongside polynomial estimates
3. Conduct donut RDD robustness checks

### Addressing Fuzziness

Coverage loss timing varies (birthday vs. end-of-month vs. plan-year). Our approach:
1. Primary analysis: Intent-to-treat (ITT) estimates treating 26 as sharp cutoff
2. First-stage validation: Confirm insurance coverage drops at 26
3. Interpretation: Effects represent LATE for compliers

## Expected Effects and Mechanisms

### Theoretical Predictions

**If insurance affects fertility timing:**
- Women may delay childbearing when losing coverage (access to prenatal care concerns)
- Women may accelerate childbearing before losing coverage (use insurance while available)
- Net effect is ambiguous

**Mechanism:**
Age 26 → Insurance coverage ↓ → Access to contraception/prenatal care affected → Fertility decisions change

### Hypothesized Results

- First stage: ~4 percentage point decrease in insurance coverage at age 26
- Reduced form: Small but detectable discontinuity in fertility (direction uncertain)
- Heterogeneity: Larger effects for women in non-expansion states, unmarried women, lower income

## Data

### Source
Census American Community Survey (ACS) Public Use Microdata Sample (PUMS)
- Years: 2011-2022 (post-ACA period)
- Access: Census API (no IPUMS required)

### Variables

**Outcome:**
- FER: Gave birth to child within the past 12 months (1=Yes, 2=No)

**Running variable:**
- AGEP: Age in years

**Treatment mechanism (first stage):**
- HICOV: Health insurance coverage recode
- PRIVCOV: Private health insurance coverage
- PUBCOV: Public health coverage (Medicaid)

**Covariates for balance tests:**
- RAC1P: Race
- HISP: Hispanic origin
- SCHL: Educational attainment
- MAR: Marital status
- CIT: Citizenship status
- NATIVITY: Nativity
- POVPIP: Income-to-poverty ratio
- ST: State of residence

### Sample Restrictions
- Women only (SEX = 2)
- Ages 22-30 (bandwidth around cutoff)
- Civilian, non-institutional population

### Sample Size (Expected)
- ~300,000 women per year ages 22-30
- ~3 million observations total for 2011-2022

## Primary Specification

```r
# Main RDD specification
library(rdrobust)

# First stage: Insurance coverage
fs_result <- rdrobust(
  y = data$insurance_covered,
  x = data$age_centered,  # Age - 26
  c = 0,
  p = 1,  # Local linear
  masspoints = "adjust"
)

# Reduced form: Fertility outcome
rf_result <- rdrobust(
  y = data$gave_birth,
  x = data$age_centered,
  c = 0,
  p = 1,
  masspoints = "adjust"
)
```

## Planned Robustness Checks

1. **Bandwidth sensitivity**: Vary bandwidth from 2 to 5 years
2. **Polynomial order**: Compare linear vs. quadratic local polynomial
3. **Placebo cutoffs**: Test discontinuity at ages 23, 24, 25, 27, 28, 29
4. **Balance tests**: Verify no discontinuity in predetermined characteristics
5. **Donut RDD**: Exclude observations exactly at age 26
6. **Year-by-year**: Estimate separately by survey year
7. **State heterogeneity**: Compare Medicaid expansion vs. non-expansion states

## Heterogeneity Analysis

1. **Medicaid expansion status**: Effects may be smaller in expansion states (Medicaid provides alternative coverage)
2. **Marital status**: Unmarried women more likely affected (can't use spouse's insurance)
3. **Education**: Lower education may indicate less employer coverage access
4. **Race/ethnicity**: Prior work shows differential ACA impacts by race

## Paper Outline

1. **Introduction** (~3 pages)
   - Motivation: Young adult fertility and insurance coverage
   - Research question and contribution
   - Preview of findings

2. **Background** (~4 pages)
   - ACA dependent coverage provision
   - Prior literature on insurance and fertility
   - Prior literature on age 26 discontinuity

3. **Data** (~3 pages)
   - ACS PUMS description
   - Sample construction
   - Summary statistics

4. **Empirical Strategy** (~4 pages)
   - RDD framework
   - Discrete running variable methods
   - Validity tests

5. **Results** (~6 pages)
   - First stage (insurance coverage)
   - Main results (fertility)
   - Robustness checks

6. **Heterogeneity** (~3 pages)
   - By state Medicaid expansion
   - By marital status
   - By education and race

7. **Discussion** (~2 pages)
   - Interpretation
   - Mechanisms
   - Policy implications

8. **Conclusion** (~1 page)

**Target length:** 25-30 pages + appendix

## Figures and Tables (Planned)

### Main Figures
1. RDD plot: Insurance coverage vs. age (first stage)
2. RDD plot: Fertility vs. age (reduced form)
3. Event study style plot showing trends by age
4. Map showing state Medicaid expansion heterogeneity

### Main Tables
1. Summary statistics by age group
2. First stage: Insurance coverage discontinuity
3. Main results: Fertility discontinuity
4. Robustness: Bandwidth and polynomial sensitivity
5. Placebo cutoffs
6. Balance tests
7. Heterogeneity by state expansion status
8. Heterogeneity by marital status

### Appendix Figures/Tables
1. Density of running variable (McCrary test)
2. Year-by-year estimates
3. Additional heterogeneity (education, race)
4. Alternative outcome definitions
