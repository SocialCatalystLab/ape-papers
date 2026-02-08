# Pre-Analysis Plan

## Research Question

Did Wyoming's 2021 Universal License Recognition law (SF 0018) increase in-migration of licensed workers relative to comparison states?

## Policy Context

Wyoming enacted SF 0018 in February 2021, requiring state licensing boards to universally recognize occupational licenses obtained in other states. This removes the requirement for licensed workers moving to Wyoming to repeat training, take new exams, or pay additional fees. The law covers most licensed occupations but excludes attorneys and professions with prescriptive drug authority.

Prior to this law, a cosmetologist moving from Colorado to Wyoming would need to verify their out-of-state license met Wyoming's 1,600-hour training requirement, potentially take additional exams, and pay licensing fees. After SF 0018, the same cosmetologist can apply for recognition and begin work immediately.

## Conceptual Framework

### Theory 1: Reduced Mobility Costs

**Mechanism:** Occupational licensing creates barriers to interstate mobility by requiring workers to re-invest in credentials when moving across state lines. Universal license recognition removes these barriers, reducing the cost of migration for licensed workers.

**Predictions:**
- Sign: Positive effect on in-migration of licensed workers to Wyoming
- Magnitude: Expect modest effects (5-15% increase in in-migration) given Wyoming's small economy and the relatively recent policy change
- Heterogeneity: Effects should concentrate in:
  - Occupations with high relicensing costs (cosmetology, real estate)
  - Workers moving from states with different licensing standards
  - Workers in geographically mobile occupations

### Theory 2: No Effect (Null Hypothesis)

**Mechanism:** Licensing barriers may not be the binding constraint on interstate migration. Workers choose locations based on wages, housing costs, amenities, and family ties. Licensing costs may be small relative to moving costs and wage differentials.

**Predictions:**
- Sign: Zero or negligible effect
- Heterogeneity: If licensing barriers were never binding, effects should be null across all subgroups

### Theory 3: Negative Effect (Competition)

**Mechanism:** Workers in Wyoming's licensed occupations may anticipate increased competition from out-of-state workers and leave the state, or potential in-migrants may be deterred by concerns about labor market saturation.

**Predictions:**
- Sign: Negative effect (unlikely but theoretically possible)
- Heterogeneity: Would manifest in occupations with excess local supply

## Primary Specification

### Question
Did the share of licensed workers who recently moved to Wyoming from out of state increase after SF 0018, relative to control states?

### Unit of Observation
Individual person-year from Census PUMS microdata

### Sample
- Working-age adults (ages 18-64)
- Residing in Wyoming (treatment) or control states
- Employed in licensed occupations (identified by OCCP codes)
- Years: 2018-2023 (3 years pre, 3 years post)

### Outcome Variable
**In-migration indicator**: Binary indicator = 1 if person lived in a different state 1 year ago (MIG=4 "Moved from different state" and current ST=56 for Wyoming)

### Treatment Variable
**Post × Wyoming**: Interaction of post-2021 indicator with Wyoming state indicator

### Model (DiD)

$$
InMigration_{ist} = \alpha + \beta_1 (Post_t \times Wyoming_s) + \gamma_s + \delta_t + X_{ist}'\theta + \varepsilon_{ist}
$$

Where:
- $InMigration_{ist}$: Indicator for person $i$ in state $s$ at time $t$ having moved from different state in past year
- $Post_t$: Indicator for years 2021-2023
- $Wyoming_s$: Indicator for Wyoming (ST=56)
- $\gamma_s$: State fixed effects
- $\delta_t$: Year fixed effects
- $X_{ist}$: Individual controls (age, sex, education)
- $\beta_1$: Treatment effect (coefficient of interest)

### Expected Sign
**Positive** ($\beta_1 > 0$): Universal license recognition reduces relicensing costs, which should increase in-migration of licensed workers. Based on the Goldwater Institute's descriptive evidence from Arizona (8,000+ licenses issued under ULR by 2023), we expect positive effects on mobility.

### Control States
States without universal license recognition as of 2023:
- Neighboring states: Idaho (FIPS 16), Montana (FIPS 30 - adopted ULR same year, will exclude), Utah (FIPS 49), Colorado (FIPS 08 - adopted ULR, will exclude), Nebraska (FIPS 31), South Dakota (FIPS 46)
- Similar rural/small states: North Dakota (FIPS 38)

**Final control states:** Idaho, Utah, Nebraska, South Dakota, North Dakota (states without ULR and geographically similar)

## Where Mechanism Should Operate (REQUIRED)

### Who is directly affected by this policy?
Licensed workers who might consider moving to Wyoming. This includes:
- Workers in states with different/stricter licensing requirements than Wyoming
- Workers in highly mobile occupations (e.g., military spouses)
- Workers with prior licensing in multiple states
- Younger workers early in careers who are more geographically mobile

### Who is NOT affected?
- Workers in unlicensed occupations (no barrier removed)
- Workers already in Wyoming (no relicensing needed)
- Workers in states with identical licensing requirements to Wyoming
- Workers in occupations excluded from SF 0018 (attorneys, prescribers)
- Older workers with strong local ties and low mobility propensity

### Heterogeneity Tests
1. **Licensed vs. Unlicensed occupations:** Effect should be concentrated in licensed occupations; no effect expected for unlicensed workers (placebo test)
2. **High-barrier vs. Low-barrier occupations:** Stronger effects expected for occupations with higher relicensing costs (e.g., cosmetology with 1,600 hours vs. occupations with shorter requirements)
3. **Age:** Stronger effects for younger workers (18-35) who are more mobile

## Licensed Occupation Identification

Using OCCP codes from Census PUMS to identify licensed occupations:

### Primary Licensed Occupations (Non-Healthcare)
| Occupation | OCCP Code | Licensing Requirement |
|------------|-----------|----------------------|
| Hairdressers/Cosmetologists | 4510 | 1,600 hours training |
| Barbers | 4500 | 1,250 hours training |
| Real Estate Agents | 4920 | License exam, hours |
| Insurance Agents | 4810 | State license |
| Electricians | 6355 | Apprenticeship + exam |
| Plumbers | 6440 | Apprenticeship + exam |

### Comparison Unlicensed Occupations (Placebo)
| Occupation | OCCP Code | Notes |
|------------|-----------|-------|
| Retail Salespersons | 4760 | No license required |
| General Office Clerks | 5860 | No license required |
| Laborers | 9620 | No license required |

## Robustness Checks

1. **Alternative control groups:**
   - All non-ULR states
   - Border states only
   - Synthetic control using pre-treatment characteristics

2. **Event study specification:**
   - Estimate year-by-year effects to verify parallel trends pre-treatment
   - Test for anticipation effects in 2020

3. **Alternative outcomes:**
   - Employment rate among licensed workers in Wyoming
   - Total count of licensed workers (extensive margin)
   - Wage outcomes (WAGP) for licensed workers

4. **Sample restrictions:**
   - Exclude 2020 (COVID shock)
   - Ages 25-55 only (core working ages)

## Validity Checks

### Parallel Trends
Run event study to test for pre-treatment trends:
$$
InMigration_{ist} = \alpha + \sum_{t=2018}^{2023} \beta_t (Year_t \times Wyoming_s) + \gamma_s + \delta_t + \varepsilon_{ist}
$$

Coefficients $\beta_{2018}$, $\beta_{2019}$, $\beta_{2020}$ should be approximately zero (relative to omitted pre-period baseline).

### Placebo Tests
1. **Placebo outcome:** In-migration in unlicensed occupations (should show no effect)
2. **Placebo treatment state:** Run same specification with Idaho as "treated" state (should show no effect)

### Balance Tests
Verify that composition of licensed workers in Wyoming vs. control states is similar in pre-period on:
- Age distribution
- Sex ratio
- Education levels
- Occupation mix

## What Would Invalidate the Design

1. **Differential COVID effects:** If Wyoming's economy recovered differently from control states in ways that affected licensed occupation migration specifically
2. **Other concurrent policies:** If Wyoming enacted other labor market policies in 2021 affecting licensed workers
3. **Anticipation effects:** If workers delayed moves to 2021+ in anticipation of ULR, creating artificial pre-treatment dip
4. **Spillovers to control states:** If ULR in Wyoming affected migration patterns in control states

## Power Considerations

Wyoming has a small population (~580,000). PUMS samples roughly 1% of the population, yielding ~5,800 Wyoming observations per year. Filtering to licensed occupations and recent movers will substantially reduce sample size.

Expected sample sizes (rough):
- Wyoming licensed workers: ~1,500-2,500/year
- Recent in-migrants among them: ~50-150/year (3-6% migration rate)
- Total Wyoming treatment observations: ~150-450 over 3 post-years

With small samples, we will use:
- Person weights (PWGTP) for proper population inference
- Robust standard errors clustered at state level
- Consider pooling years or using 5-year ACS for larger samples

## Data Sources

- **Census PUMS 1-year estimates:** 2018-2023
- **API endpoint:** https://api.census.gov/data/[YEAR]/acs/acs1/pums
- **Key variables:** ST, MIG, MIGSP, OCCP, ESR, AGEP, SEX, SCHL, WAGP, PWGTP
