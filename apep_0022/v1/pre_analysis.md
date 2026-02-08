# Pre-Analysis Plan: Social Security Eligibility at Age 62 and Living Alone

## Research Question

Does becoming eligible for Social Security retirement benefits at age 62 cause older adults to change their living arrangements, specifically reducing the probability of living alone?

## Conceptual Framework

### Theory and Mechanism

Social isolation and loneliness among older adults is recognized as a public health crisis, with the U.S. Surgeon General declaring loneliness an epidemic in 2023. Living alone is the strongest demographic predictor of loneliness among older adults. This study examines whether Social Security eligibility—by providing guaranteed income—affects the probability of living alone.

**The Mechanism:**

1. Before age 62, workers without pensions or substantial savings may be "locked in" to living arrangements determined by employment location or financial constraints
2. At exactly age 62, individuals become eligible for early Social Security retirement benefits (70% of full retirement amount)
3. This guaranteed income stream may enable:
   - Co-residence with a partner who was previously financially difficult (e.g., in high-cost housing)
   - Geographic relocation to be near family members
   - Reduced need to maintain independent housing near former workplace
   - Formation of new households with others (partner, family)
4. Alternatively, SS income could INCREASE living alone by enabling financial independence from family

**The Effect Could Go Either Direction:**
- **Hypothesis A (Decrease living alone):** Income security enables household consolidation and co-residence with family/partners
- **Hypothesis B (Increase living alone):** Income security enables financial independence, allowing continued/new solo living
- The net effect is an empirical question

### Expected Sign

We hypothesize that living alone will **decrease** at age 62, as income security reduces financial barriers to co-residence. However, we acknowledge the theoretical ambiguity and will interpret results in either direction.

### Heterogeneity Predictions

The effect (in either direction) should concentrate in:
1. **Lower-income individuals** - for whom SS represents larger share of income
2. **Previously unmarried individuals** - who face binary choice between alone vs. other arrangement
3. **Renters** - who face more flexible housing adjustments than homeowners
4. **High cost-of-living areas** - where SS income matters more for housing affordability
5. **Those without employer pension** - who face larger income shock at SS eligibility

## Primary Specification

### Outcome Variable
- **Primary:** Living alone indicator (NP = 1, where NP = number of persons in household)
- **Secondary:**
  - Household size (NP)
  - Has unmarried partner (PARTNER)
  - Married (MAR)
  - Living with relatives (any household member with REL code indicating family)
  - Living in group quarters (GQ)
  - Moved in past year (MIG)

### Running Variable
- Age (AGEP), centered at 62
- Note: AGEP is reported as integer years in ACS PUMS, requiring discrete-RD methods

### Treatment
- Indicator for age ≥ 62 (Social Security early retirement eligibility)

### Sample
- **Age range:** 58-66 (±4 years from cutoff)
- **Primary bandwidth:** 60-64 (±2 years)
- **Exclusions:**
  - Institutionalized individuals (GQ = institutional)
  - Individuals in group quarters (for primary analysis; robustness includes)
- **Years:** ACS PUMS 2015-2023 (pooled)

### Model Equation

```
LivingAlone_i = α + τ·1(Age_i ≥ 62) + f(Age_i - 62) + X_i'β + γ_s + δ_t + ε_i
```

Where:
- `LivingAlone_i` = 1 if person lives alone (NP = 1)
- `1(Age_i ≥ 62)` = treatment indicator (SS eligibility)
- `f(Age_i - 62)` = local linear polynomial in running variable, allowed to differ on each side
- `X_i` = covariates (sex, race, education, disability status)
- `γ_s` = state fixed effects
- `δ_t` = year fixed effects

### First Stage: Social Security Income Receipt

Before examining living arrangements, we will verify that age 62 creates a discontinuity in Social Security income receipt:

```
HasSSIncome_i = α + φ·1(Age_i ≥ 62) + f(Age_i - 62) + X_i'β + γ_s + δ_t + ε_i
```

Where `HasSSIncome_i` = 1 if SSIP > 0 or SSP > 0 (Social Security income).

**Decision rule:** If first stage (SS income) does not show discontinuity at 62, the main results are uninformative about SS eligibility effects.

## Where Mechanism Should Operate

### Who is Directly Affected?
- Adults aged 60-64 approaching/passing the 62 threshold
- Those without prior retirement income (pension, investments)
- Those currently living alone who might consolidate
- Those in partnerships considering forming households

### Who Should NOT Be Affected (Placebo Groups)?
- Individuals much younger (50-55) or older (70+) - not near threshold
- Individuals already receiving substantial retirement income (pension, investments)
- Individuals in institutional settings (nursing homes)

### Heterogeneity Tests
1. **By prior income:** Effect should be larger for low-income individuals (SS matters more)
2. **By housing tenure:** Effect may differ for renters vs. homeowners
3. **By sex:** May differ by gender (women more likely to outlive partners)
4. **By marital history:** Effect may be larger for never-married or divorced
5. **By state:** Effect may vary with cost of living and SS replacement rates
6. **By disability status:** Those with disabilities face different constraints

## Robustness Checks

### Bandwidth Sensitivity
- Primary bandwidth: ±2 years (ages 60-64)
- Robustness: ±1 year (61-63), ±3 years (59-65), ±4 years (58-66)
- MSE-optimal bandwidth selection following Cattaneo, Idrobo, Titiunik (2020)

### Alternative Specifications
1. **Polynomial order:** Linear (primary), quadratic
2. **Kernel weighting:** Triangular (primary), uniform
3. **Clustering:** State-level, PUMA-level
4. **Fixed effects:** Year FE only, state FE only, state×year FE

### Discrete-RD Considerations
Following Kolesár and Rothe (2018) on inference in RD with discrete running variables:
- Report honest confidence intervals that account for discrete running variable
- Consider local randomization approaches
- Test sensitivity to polynomial specification

### Weighting
- Primary: Person-weighted (PWGTP)
- Robustness: Unweighted

## Validity Checks

### Manipulation Test
Test whether there is bunching in the density of ages at 62:
- Run density test at cutoff (McCrary 2008)
- Null hypothesis: Continuous density at 62
- Expected result: No manipulation (age cannot be manipulated; discrete measurement)
- Note: With discrete age, test for unusual mass at age 62 relative to adjacent ages

### Covariate Balance
Test whether predetermined covariates are smooth across the 62 threshold:
- Sex, race, education, disability status
- State of birth
- Citizenship status
- Veteran status

Plot covariate means by age and test for discontinuity. Any imbalance suggests selection concerns.

### Placebo Cutoffs
Run the RDD at false cutoffs:
- Ages 59, 60, 61, 63, 64, 65
- Expect: No significant discontinuities at placebo cutoffs (except possibly 65 for Medicare)
- This tests whether the effect is specific to the 62 eligibility threshold

### Placebo Outcomes
Test outcomes that should NOT respond to SS eligibility:
- Sex, race (predetermined)
- State of birth
- Citizenship (predetermined)

## Sample Size and Power

**Expected Sample Sizes (rough estimates from PUMS):**
- Adults aged 58-66: ~3-4 million per year in ACS
- Pooled 2015-2023 (9 years): ~30 million observations
- Non-institutionalized: ~29 million
- Within ±2 years of cutoff (ages 60-64): ~10-12 million

**Baseline living alone rate:** Approximately 15-20% of adults aged 60-64 live alone

**Power calculation:** With N > 10 million, we have power to detect very small effects (< 0.5 percentage point change in living alone probability). The concern is not power but rather effect size meaningfulness.

## Anticipated Limitations

1. **Discrete age measurement:** PUMS reports age in whole years, not exact age or month of birth. This creates a coarse running variable. We address this with discrete-RD methods and honest confidence intervals.

2. **Slow-moving outcome:** Living arrangements change slowly. The effect may be small in annual cross-sectional data because adjustments take time. We will discuss timing explicitly.

3. **Fuzzy treatment:** Not all eligible individuals claim SS at 62. The RDD identifies the reduced-form effect of eligibility, not the effect of actual claiming. First stage on SS income receipt helps interpret.

4. **Selection into SS claiming:** Those who claim early may differ from those who delay. The RDD identifies a local average treatment effect for those induced to behave differently by the eligibility threshold.

5. **Confounding thresholds:** Age 62 may coincide with other life events or eligibility changes. We will search for and address potential confounds.

## Decision Rules

### If First Stage is Null
If SS income receipt does NOT increase discontinuously at 62:
- Investigate why (already receiving retirement income? delay claiming behavior?)
- Main living arrangement results are uninterpretable as SS effects
- Report descriptively but do not claim causal SS effect

### If Main Effect is Null
If SS eligibility does not affect living alone probability:
- Report null finding as informative
- Bounds on effect size from confidence intervals
- Examine whether heterogeneous effects exist that net to zero
- A null result contributes to understanding (income security doesn't change living arrangements)

### If Main Effect is Positive (Living Alone Increases)
If SS eligibility increases living alone:
- Interpret as income independence effect
- SS enables continued/new solo living that was previously unaffordable
- Discuss implications for loneliness policy

### If Main Effect is Negative (Living Alone Decreases)
If SS eligibility decreases living alone:
- Interpret as household consolidation/co-residence effect
- SS enables geographic mobility or housing adjustments toward others
- Discuss implications for social connection

### Minimum Meaningful Effect
We define effects as economically meaningful if they exceed 0.5 percentage points change in living alone probability (on a base of ~18%, this is ~3% relative change).

---

**Pre-Analysis Plan Version:** 1.0
**Date:** 2026-01-17
**Author:** APEP Autonomous Research System
