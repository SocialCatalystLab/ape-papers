# Initial Research Plan — Paper 72

**Title:** Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid Coverage? A Regression Discontinuity Design

**Created:** 2026-01-23
**Method:** Regression Discontinuity Design (discrete running variable)
**Data:** CDC/NCHS Natality Public Use Files (2011-2022)

---

## Research Question

Does the ACA's age-26 dependent coverage cutoff cause a discontinuous shift in the payment source for deliveries, specifically increasing the share of births covered by Medicaid?

## Policy Background

The Affordable Care Act (2010) requires insurers to allow young adults to remain on their parents' health insurance until age 26. At the 26th birthday, this coverage terminates, creating a sharp discontinuity in insurance type. Young adults losing parental coverage face several options:
1. Obtain employer-sponsored insurance
2. Purchase ACA marketplace coverage
3. Become uninsured
4. Qualify for Medicaid (income-dependent; expanded post-2014 in some states)

For pregnant women, Medicaid eligibility is typically more generous than general eligibility, making it a likely fallback when private coverage is lost.

## Identification Strategy

**Design:** Regression Discontinuity at age 26

**Running Variable:** Mother's age at delivery in completed years (from public use natality file variable MAGER)

**Cutoff:** Age 26 (birthday when dependent coverage terminates)

**Treatment:** Loss of eligibility for parental health insurance coverage

**Outcome:** Payment source at delivery (PAY_REC variable):
- Private insurance (1)
- Medicaid (2)
- Self-pay (3)
- Other (4)

**Approach:** Discrete RD using local randomization methods (Cattaneo, Frandsen, & Titiunik 2015; Kolesár & Rothe 2018) given that the running variable has only integer values.

## Data

### Primary Data Source
**CDC/NCHS Natality Public Use Files** (via NBER)
- Years: 2011-2022 (post-ACA implementation)
- Unit: Individual births
- N: ~3.6 million births/year; ~150,000 births/year to mothers age 25-26
- Key variables:
  - MAGER: Mother's age in single years
  - PAY_REC: Principal source of payment for delivery
  - MEDUC: Mother's education
  - MRACEHISP: Mother's race/Hispanic origin
  - DMAR: Marital status
  - PRECARE: Prenatal care timing
  - LBO_REC: Live birth order

### Sample Restrictions
- Births occurring 2011-2022 (ACA era)
- Mothers age 20-32 (wide window for RD)
- Singleton births only (exclude multiples for comparability)
- Exclude births with missing payment source

## Analysis Plan

### 1. Descriptive Analysis
- Plot mean Medicaid share by single year of mother's age
- Visual inspection for discontinuity at age 26
- Summary statistics by age group (under 26 vs 26+)

### 2. Validity Tests
a) **Density Test:** Test for bunching/manipulation at age 26
   - Note: Birthday cannot be manipulated, but pregnancy/delivery timing could be
   - Use McCrary (2008) adapted for discrete variable

b) **Covariate Balance:** Test for discontinuities in predetermined characteristics
   - Education, race/ethnicity, parity, prenatal care
   - Marital status: Interpret as potential mechanism, not balance test

### 3. Main RD Estimates
- Local randomization RD using `rdlocrand` package
- Primary window: Ages 23-28 (3 integer years each side)
- Outcomes:
  - P(Medicaid) — primary
  - P(Private insurance)
  - P(Self-pay/uninsured)

### 4. Robustness Checks
- Bandwidth sensitivity: 24-27, 22-29 windows
- Placebo cutoffs: Test for "effects" at ages 24, 25, 27, 28
- Donut RD: Exclude age 26 exactly
- Polynomial specifications within window

### 5. Heterogeneity Analysis
- By Medicaid expansion status (expansion vs non-expansion states)
- By year (early ACA vs later)
- By education level
- By marital status

### 6. Mechanisms
- Test whether marriage increases discontinuously at 26 (spousal coverage mechanism)
- Test prenatal care timing effects

## Expected Results

Based on prior literature (Sommers et al. 2013; Antwi et al. 2013):
- Expect ~5-10 percentage point decrease in private coverage at age 26
- Corresponding increase in Medicaid coverage (for below-threshold income)
- Possible increase in self-pay/uninsured (for above-threshold income)

## Figures

1. **Figure 1:** Mean Medicaid share by single year of mother's age (RD plot)
2. **Figure 2:** Covariate balance plots
3. **Figure 3:** Placebo cutoff tests
4. **Figure 4:** Heterogeneity by Medicaid expansion status
5. **Figure 5:** Density of births by age (manipulation test)

## Tables

1. **Table 1:** Summary statistics by age group
2. **Table 2:** Covariate balance tests
3. **Table 3:** Main RD estimates
4. **Table 4:** Robustness to bandwidth
5. **Table 5:** Heterogeneity analysis

## Timeline

1. Data download and cleaning
2. Descriptive analysis and validity tests
3. Main RD estimation
4. Robustness and heterogeneity
5. Paper writing
6. Internal review
7. External review
8. Final revision and publish

## Key References

- Antwi, Y. A., Moriya, A. S., & Simon, K. (2013). Effects of federal policy to insure young adults: evidence from the 2010 Affordable Care Act's dependent-coverage mandate. American Economic Journal: Economic Policy.
- Cattaneo, M. D., Frandsen, B. R., & Titiunik, R. (2015). Randomization inference in the regression discontinuity design. Journal of Causal Inference.
- Kolesár, M., & Rothe, C. (2018). Inference in regression discontinuity designs with a discrete running variable. American Economic Review.
- Sommers, B. D., et al. (2013). Changes in utilization and health among young adults after the Affordable Care Act's dependent coverage expansion. JAMA Internal Medicine.
