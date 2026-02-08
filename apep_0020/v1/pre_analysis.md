# Pre-Analysis Plan: Intergenerational Time Transfers at the Social Security Eligibility Threshold

## Research Question

Does grandparent eligibility for early Social Security retirement at age 62 cause adult children with young kids to increase their work hours, through the mechanism of newly available grandparent-provided childcare?

## Conceptual Framework

### Theory and Mechanism

The standard model of retirement focuses on own labor supply: at 62, Social Security eligibility creates an income effect that may induce retirement. But retirement also frees up TIME that can be transferred to family members.

**The Mechanism:**
1. At age 62, older adults become eligible for early Social Security benefits
2. Some fraction claim benefits and reduce work hours (the "first stage")
3. Reduced work hours → increased availability for grandchild care
4. Adult children who receive grandparent childcare can increase their own work hours
5. This creates an intergenerational "spillover" effect of Social Security on labor supply

**Key Economic Insight:** Social Security's effect on aggregate labor supply may be smaller than individual-level estimates suggest, if grandparent retirement enables increased labor supply by the next generation. This has implications for fiscal sustainability calculations.

### Expected Signs

- **First Stage (Grandparent RDD):** Work hours should DECLINE discontinuously at age 62 (negative coefficient on being ≥62)
- **Second Stage (Parent Spillover):** Work hours for parents with young children should INCREASE when co-resident grandparents reach 62 eligibility (positive coefficient)

### Heterogeneity Predictions

The effect should concentrate in:
1. **Households with young children (ages 0-5)** - where childcare need is highest
2. **Mothers** - who face more binding childcare constraints on labor supply
3. **Lower-income households** - where formal childcare is less affordable
4. **States with high childcare costs** (e.g., California) - where grandparent care is more valuable
5. **Grandparents not already receiving pension/retirement income** - who face larger eligibility shock

## Primary Specification

### Outcome Variables
- **Primary:** Usual hours worked per week (WKHP) for co-resident working-age adults (25-55) with children
- **Secondary:** Employment status (ESR), weeks worked (WKWN), labor force participation

### Running Variable
- Grandparent age (AGEP) in the household, centered at 62

### Treatment
- Indicator for oldest grandparent in household being age ≥62 (Social Security early eligibility)

### Sample

**Multigenerational Households:** Households containing:
1. At least one adult aged 60-64 (the "grandparent" - near the eligibility threshold)
2. At least one adult aged 25-55 (the "working-age adult")
3. At least one child aged 0-17 (preferably 0-5 for strongest effect)

Sample restriction to ±2 years of cutoff: grandparents aged 60-64.

**Data:** Census ACS PUMS 2015-2023, pooled for statistical power.

### Model Equation (First Stage)

For grandparent hours:
```
WKHP_g = α + τ·1(Age_g ≥ 62) + f(Age_g - 62) + X_g'β + ε_g
```

Where:
- `WKHP_g` = grandparent's usual hours worked
- `1(Age_g ≥ 62)` = treatment indicator
- `f(Age_g - 62)` = local linear polynomial in running variable
- `X_g` = covariates (sex, education, race, state)

### Model Equation (Spillover - Reduced Form)

For parent hours in households with grandparents:
```
WKHP_p = α + γ·1(Age_g ≥ 62) + f(Age_g - 62) + X_p'β + X_g'δ + ε_p
```

Where:
- `WKHP_p` = working-age adult's usual hours worked
- `1(Age_g ≥ 62)` = indicator that co-resident grandparent is ≥62
- `f(Age_g - 62)` = local linear polynomial in grandparent's age
- `X_p`, `X_g` = parent and grandparent covariates

**Key Identification:** We are NOT instrumenting; this is a reduced-form RDD asking whether parent labor supply changes discontinuously at the grandparent's eligibility threshold.

## Where Mechanism Should Operate

### Who is Directly Affected?
- **Grandparents aged 60-64** who reduce hours upon reaching 62
- **Parents with young children (0-5)** who gain access to free childcare
- **Mothers** more than fathers (childcare constraints more binding)

### Who Should NOT Be Affected (Placebo Groups)?
- Adults without children in household
- Adults with only older children (13+) who don't need supervision
- Working-age adults in households where "grandparent" is already fully retired
- Adults in households where grandparent is much younger (55-59) - not near threshold

### Heterogeneity Tests
1. **By child age:** Effect should be largest for children 0-5, smaller for 6-12, null for 13+
2. **By parent sex:** Effect should be larger for mothers
3. **By grandparent prior work status:** Effect should be larger when grandparent was working pre-62
4. **By state childcare costs:** Effect should be larger in high-cost states (CA > NE)
5. **By income:** Effect should be larger for lower-income households

## Robustness Checks

### Bandwidth Sensitivity
- Primary bandwidth: ±2 years (ages 60-64)
- Robustness: ±1 year (61-63), ±3 years (59-65), ±4 years (58-66)
- MSE-optimal bandwidth selection following Calonico, Cattaneo, Titiunik (2014)

### Alternative Specifications
1. **Polynomial order:** Linear (primary), quadratic, cubic
2. **Kernel weighting:** Triangular (primary), uniform, Epanechnikov
3. **Clustering:** State-level, PUMA-level, household-level
4. **Fixed effects:** Year FE, state FE, state×year FE

### Sample Restrictions
1. **Age window variants:** As above
2. **Exclude California (largest state):** Check not driven by one state
3. **Only households where grandparent was working at baseline** (ages 60-61)
4. **Only biological grandparent relationships** (if identifiable via REL codes)

### Weighting
- Primary: Person-weighted (PWGTP)
- Robustness: Unweighted

## Validity Checks

### Manipulation Test (McCrary 2008)
Test whether there is bunching in the density of grandparent ages at 62:
- Run density test at cutoff
- Null hypothesis: Continuous density at 62
- Expected result: No manipulation (age is not chooseable)

### Covariate Balance
Test whether covariates are smooth across the 62 threshold:
- Grandparent education, race, sex
- Household income (lagged or predicted)
- Parent age, education
- Number of children
- State distribution

Plot covariate means by grandparent age and test for discontinuity.

### Placebo Cutoffs
Run the RDD at false cutoffs:
- Age 60, 61, 63, 64
- Expect: No significant discontinuities at placebo cutoffs
- This tests whether the effect is specific to the 62 eligibility threshold

### Placebo Outcome
Test outcomes that should NOT respond:
- Working-age adult hours in households WITHOUT children
- Household size (should not jump at 62)

## Sample Size and Power

**Expected Sample Sizes (rough estimates from PUMS):**
- Multigenerational households with grandparent aged 60-64: ~50,000-100,000 per year
- Pooled 2015-2023 (9 years): ~450,000-900,000 observations
- Within ±2 years of cutoff: ~200,000-400,000

**Power calculation:** With N~300,000, we should have power to detect effects of 0.5-1 hours/week change in parent labor supply, which is economically meaningful.

## Anticipated Limitations

1. **Discrete age measurement:** PUMS reports age in whole years, not months. This creates bandwidth = 1 year minimum and some measurement error around the exact cutoff.

2. **Selection into co-residence:** Households where multiple generations live together are selected. Co-residence itself may respond to the 62 threshold. We will test for this.

3. **Fuzzy treatment:** Not all grandparents claim Social Security at 62; claiming is a choice. The RDD identifies the reduced-form effect of eligibility, not the effect of actual claiming.

4. **Relationship inference:** PUMS relationship codes may not perfectly identify grandparent-grandchild relationships. We will use household structure (presence of children + presence of adults 60+) as proxy.

## Decision Rules

### If First Stage is Null
If grandparent hours do NOT decline at 62:
- Report null first stage
- Do not interpret spillover estimates
- Discuss why mechanism may not operate (already retired, not claiming early, etc.)

### If Spillover is Null
If grandparent hours decline but parent hours do not increase:
- Possible explanations: childcare substitutes available, grandparent time not going to childcare, parent hours already at desired level
- Examine heterogeneity where mechanism should be strongest
- A null spillover is still a contribution (bounds the intergenerational effect)

### Minimum Detectable Effect
We will report if the confidence interval rules out effects larger than 1 hour/week change in parent labor supply. This is our threshold for "economically meaningful."

---

**Pre-Analysis Plan Version:** 1.0
**Date:** 2026-01-17
**Author:** APEP Autonomous Research System
