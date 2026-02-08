# Pre-Analysis Plan

## Research Question

Does eligibility for Colorado's Old Age Pension (OAP) program at age 60 reduce labor force participation among low-income older adults?

## Policy Background

Colorado's Old Age Pension (OAP) is a constitutionally mandated (since 1937) state program providing cash benefits to low-income Colorado residents aged 60 and older. This is unusually generous compared to most state-level assistance programs, which typically begin at age 65. The program guarantees a minimum monthly income (currently approximately $1,032/month), with benefits reduced dollar-for-dollar by other income sources. This creates a 100% implicit marginal tax rate on earnings for beneficiaries.

The age-60 threshold provides a sharp discontinuity for regression discontinuity analysis, as individuals just below 60 are ineligible while those just above may receive substantial cash benefits.

## Conceptual Framework

### Theory 1: Income Effect Dominance

**Mechanism:** The OAP provides unconditional income support at age 60. Following standard labor-leisure tradeoffs, receiving additional non-labor income should reduce labor supply as leisure is a normal good. Additionally, the dollar-for-dollar benefit reduction creates an implicit 100% marginal tax rate on earnings up to the benefit level.

**Prediction:**
- Sign: Negative effect on labor force participation and hours worked
- Magnitude: Expect modest effect (2-5 percentage points) since only low-income individuals are eligible and actual take-up may be imperfect
- Heterogeneity: Effect should be strongest among those with income just below the eligibility threshold; minimal effect among higher-income individuals who don't qualify

### Theory 2: Limited Awareness/Take-up

**Mechanism:** Despite eligibility, many older adults may be unaware of the OAP program or face stigma/transaction costs that discourage enrollment. Administrative barriers or lack of information would attenuate any labor supply response.

**Prediction:**
- Sign: Null or very small negative effect on labor supply
- Magnitude: Near zero
- Heterogeneity: May see effects only in counties with stronger outreach programs

### Theory 3: Program Interaction Effects

**Mechanism:** At age 60, individuals become eligible for multiple programs (OAP, some SNAP provisions, etc.), creating combined incentives. However, these overlap less than at age 65 (Medicare, Social Security), making age 60 a relatively clean threshold.

**Prediction:**
- Sign: Negative effect on labor supply
- Magnitude: Could be larger than OAP alone if programs are complementary
- Heterogeneity: Strongest among those eligible for multiple programs

## Primary Specification

- **Question:** Does crossing the age-60 threshold discontinuously change labor force participation among Colorado residents near the OAP income eligibility threshold?

- **Unit of observation:** Individual person-year from Census PUMS

- **Sample:** Colorado residents (ST=08) aged 55-65, pooled across years 2015-2023. Focus on those with total personal income (PINCP) below $20,000 (approximately twice the OAP maximum benefit) to capture the population most likely affected.

- **Outcome variables:**
  1. Primary: In labor force (ESR=1,2,3 vs ESR=6) - binary
  2. Secondary: Hours worked per week (WKHP) - continuous, 0 for non-workers
  3. Secondary: Wage income (WAGP) - continuous

- **Running variable:** Age in years (AGEP)

- **Cutoff:** Age 60

- **Model:** Sharp RDD with local linear regression

  Y_i = α + β₁(Age_i - 60) + β₂·D_{Age≥60} + β₃(Age_i - 60)·D_{Age≥60} + γX_i + ε_i

  where:
  - Y_i is the outcome (labor force participation, hours, or wages)
  - D_{Age≥60} is an indicator for age 60 or above
  - (Age_i - 60) is the centered running variable
  - X_i includes controls: sex, race, education, marital status
  - β₂ is the coefficient of interest (RDD treatment effect)

- **Expected sign:** Negative (β₂ < 0), indicating OAP eligibility reduces labor supply
  - Rationale: Cash benefits provide income replacement and implicit taxation of earnings discourages work
  - Expected magnitude: 2-8 percentage point reduction in labor force participation

- **Bandwidth:** Primary specification uses bandwidth of 5 years on each side (ages 55-65). Robustness checks use 3-year and 7-year bandwidths.

## Where Mechanism Should Operate (REQUIRED)

- **Who is directly affected by this policy/treatment?**
  Low-income Colorado residents crossing age 60 who are eligible for and take up OAP benefits. These are individuals with limited other income sources who would benefit from the cash transfer. The first stage (OAP receipt) should be strong for those with annual income below ~$12,000.

- **Who is NOT affected?**
  - Higher-income individuals (PINCP > $15,000-20,000) are ineligible for OAP
  - Individuals already out of the labor force (no margin to adjust)
  - Individuals with strong labor force attachment (may not respond to modest benefits)
  - Non-Colorado residents

- **Heterogeneity tests:**
  1. Income terciles: Effect should be strongest in lowest tercile
  2. Prior labor force status: Effect should be larger among marginally attached workers
  3. Education: Effect may be larger for less-educated workers with lower opportunity costs

## First Stage: Treatment Verification

Since PUMS does not directly identify OAP receipt, we use Public Assistance Income (PAP) as a proxy for program participation. We expect:
- Discontinuous increase in PAP > 0 at age 60
- Discontinuous increase in mean PAP amount at age 60

If the first stage is weak (no visible jump in PAP), this threatens the interpretation of reduced-form results, as we cannot confirm OAP take-up.

## Robustness Checks

1. **Bandwidth sensitivity:**
   - Primary: 5-year bandwidth (ages 55-65)
   - Narrow: 3-year bandwidth (ages 57-63)
   - Wide: 7-year bandwidth (ages 53-67)

2. **Specification changes:**
   - Linear vs quadratic polynomial in running variable
   - With and without demographic controls
   - Local linear regression with triangular kernel weights

3. **Sample restrictions:**
   - Full Colorado sample (not income-restricted)
   - Low-income subsample (PINCP < $15,000)
   - By sex (male only, female only)
   - By education (high school or less vs. some college+)

4. **Alternative outcomes:**
   - Part-time work indicator (WKHP < 35)
   - Any wage income (WAGP > 0)
   - Social insurance income indicators

## Validity Checks

1. **Manipulation test:**
   - McCrary (2008) density test for bunching at age 60
   - Visual inspection of age distribution
   - Expectation: No bunching, as age cannot be manipulated

2. **Covariate balance:**
   - Test for discontinuity in pre-determined characteristics at age 60:
     - Sex (SEX)
     - Race (RAC1P)
     - Educational attainment (SCHL)
     - Citizenship (CIT)
     - Nativity (NATIVITY)
   - Expectation: No discontinuities (p > 0.05 for all)

3. **Placebo cutoffs:**
   - Test for discontinuities at ages 58 and 62 (where no policy change occurs)
   - Expectation: No significant effects at placebo cutoffs

4. **Comparison to non-Colorado states:**
   - Estimate same RDD in neighboring states without age-60 pension programs
   - States: New Mexico, Wyoming, Kansas, Nebraska
   - Expectation: No discontinuity at age 60 in comparison states

## Interpretation Guidelines

### If Results Match Predictions (Negative, Significant):
- Interpretation: OAP eligibility reduces labor supply
- Mechanism: Income effect and implicit taxation
- Policy implication: Earlier retirement subsidies affect work decisions

### If Results Are Null:
- Possible explanations:
  1. Low program awareness/take-up (check first stage in PAP)
  2. Small eligible population in PUMS sample
  3. Heterogeneous effects masking average effect (check subgroups)
- Proceed with heterogeneity analysis to identify affected subpopulations

### If Results Are Positive (Unexpected):
- Consider: Measurement error, confounding policies at age 60
- Check: Are there other programs starting at 60 that encourage work?
- Recommendation: Strong skepticism; likely specification issue

## What Would Invalidate the Design

1. **Bunching/Sorting:** Evidence of age manipulation at 60 (unlikely but check density)
2. **Confounding policies:** Other major programs that kick in at exactly age 60 in Colorado (identified: SNAP exemption, but this would reinforce negative prediction)
3. **Covariate imbalance:** Discontinuities in predetermined characteristics at age 60 (would suggest selection)
4. **No first stage:** If PAP shows no discontinuity, we cannot attribute labor supply changes to OAP
5. **Effects in comparison states:** If we find similar discontinuities in states without age-60 pensions, this suggests a national trend rather than OAP effect

## Data and Sample Construction

### Source
Census PUMS 1-year estimates, 2015-2023, via Census API

### Variables
| Variable | PUMS Code | Definition |
|----------|-----------|------------|
| Age | AGEP | Age in years (running variable) |
| State | ST | State FIPS code (08 = Colorado) |
| Employment status | ESR | 1-3 = employed/unemployed, 6 = not in LF |
| Hours worked | WKHP | Usual hours per week |
| Wage income | WAGP | Wages/salary past 12 months |
| Total income | PINCP | Total personal income |
| Public assistance | PAP | Public assistance income (OAP proxy) |
| Person weight | PWGTP | Survey weight |
| Sex | SEX | 1=Male, 2=Female |
| Race | RAC1P | Race codes |
| Education | SCHL | Educational attainment |

### Sample Size Estimates
- Colorado adults 55-65: ~500,000 per year in PUMS
- With income < $20,000: ~50,000-100,000 per year
- Pooled 2015-2023: ~400,000-800,000 observations

## Timeline
1. Lock this pre-analysis plan
2. Fetch PUMS data for Colorado, 2015-2023
3. Construct analysis sample
4. Run primary specification and validity checks
5. Run robustness checks and heterogeneity analysis
6. Write results section

---
**Date:** 2026-01-17
**Author:** APEP Autonomous Research
**Status:** PRE-REGISTRATION (to be locked before analysis)
