# Pre-Analysis Plan: Hair Braider Licensing Deregulation and Entrepreneurship

**Locked before analysis begins. SHA-256 checksum created on lock.**

## Research Question

Does eliminating occupational licensing requirements for hair braiders increase self-employment and entrepreneurship among personal appearance workers, particularly African American women?

## Conceptual Framework

### Theory 1: Barrier Reduction Theory
**Mechanism:** Occupational licensing creates substantial barriers to entry for would-be entrepreneurs. Full cosmetology licenses require 1,000-2,100 hours of training and $5,000-$20,000 in costs—requirements that are largely irrelevant to hair braiding but effectively exclude low-income individuals from self-employment. When states deregulate hair braiding, these barriers are removed, allowing qualified braiders to enter self-employment without the time and financial investment.

**Prediction:**
- Sign: Positive—deregulation should increase self-employment rates among personal appearance workers
- Magnitude: Moderate (5-15 percentage point increase in self-employment probability)
- Heterogeneity: Effects should concentrate among:
  - African American women (who dominate hair braiding culturally)
  - Workers without formal education credentials
  - Workers in lower-income brackets (for whom the license cost was prohibitive)

### Theory 2: Formalization Theory
**Mechanism:** Licensing requirements, while costly, may push some informal braiders into formal self-employment or wage work. Deregulation could cause some workers to shift from formal to informal work (not captured in surveys). This would attenuate measured effects or even show negative effects if formalization drops.

**Prediction:**
- Sign: Ambiguous—formal self-employment may increase or stay flat
- Magnitude: Small (if informal sector absorbs entrants)
- Heterogeneity: Effects may differ by state enforcement intensity

### Theory 3: Competition and Wages
**Mechanism:** Lower barriers increase labor supply to the hair braiding market, potentially reducing wages for incumbent workers through competition, even as self-employment increases.

**Prediction:**
- Sign: Positive for self-employment, potentially negative for wages
- Magnitude: Depends on market thickness
- Heterogeneity: Larger wage effects in markets with more potential entrants

## Primary Specification

### Main Analysis: Difference-in-Differences

- **Question:** Does state-level hair braiding license deregulation increase self-employment among personal appearance workers?

- **Unit of observation:** Individual worker-year (person i in state s in year t)

- **Sample:** 
  - Adults ages 18-64
  - Employed in personal appearance worker occupations (OCCP codes ~4500-4540 in Census PUMS)
  - Survey years 2010-2023
  - All 50 states + DC
  
- **Outcome variables:**
  1. Self-employed (primary): Binary indicator for class of worker = self-employed (COW = 6 or 7)
  2. Self-employment income: Continuous (SEMP variable, conditional on self-employment)
  3. Total earnings: Wages + self-employment income (WAGP + SEMP)
  4. Hours worked: Weekly hours (WKHP)

- **Treatment variable:** Binary indicator for state having deregulated hair braiding (exempted from cosmetology license) in year t

- **Model specification:**
  
  $$Y_{ist} = \alpha + \beta \cdot Deregulated_{st} + \gamma_s + \delta_t + X_{ist}'\theta + \varepsilon_{ist}$$
  
  Where:
  - $Y_{ist}$ is the outcome for person i in state s in year t
  - $Deregulated_{st}$ = 1 if state s has deregulated hair braiding by year t
  - $\gamma_s$ are state fixed effects
  - $\delta_t$ are year fixed effects
  - $X_{ist}$ are individual controls (age, sex, race, education)
  - Standard errors clustered at state level

- **Expected sign:** Positive for self-employment probability (β > 0)
  - Rationale: Removing training hour requirements and licensing fees reduces barriers to entry, allowing more workers to pursue self-employment

## Policy Treatment: State Deregulation Timeline

Based on Institute for Justice documentation and legislative records, states deregulated hair braiding in the following years (exempted braiders from cosmetology licensing):

**Pre-2010 (already deregulated - control group baseline):**
- Arizona (2004), California (~2000s), Mississippi (2005), Minnesota (~2005), Washington (~2005)

**Treatment states (deregulated 2010-2020):**
- 2011: Nevada (reduced from 1,200 to 250 hours - partial)
- 2015: Texas, Arkansas, Colorado, Washington (if not earlier)
- 2016: Nebraska, Kentucky
- 2017: Indiana, New Hampshire, South Dakota
- 2018: Iowa, New Jersey, Oklahoma
- 2019: North Dakota, Rhode Island, Minnesota (if expanded)
- 2020: Florida
- 2021: Massachusetts, Wisconsin
- 2023: Montana

**Never deregulated (always required full cosmetology license - control group):**
- Louisiana, Missouri, New York, Pennsylvania (partial), Ohio, others

## Where Mechanism Should Operate (REQUIRED)

### Who is directly affected by this policy?

The deregulation primarily affects:
1. **Potential entrants:** People who want to become hair braiders but face licensing barriers
2. **Informal braiders:** People already braiding informally who can now formalize
3. **African American women:** Hair braiding (box braids, cornrows, locs, twists) is a practice deeply rooted in African American culture

The "first stage" (reduction in licensing requirements) is strongest for:
- Workers without existing cosmetology licenses
- Workers in states that previously required 1,000+ hours of training
- Lower-income workers for whom the $10,000+ licensing cost was prohibitive

### Who is NOT affected?

- Licensed cosmetologists (already have licenses)
- Hair stylists using chemical treatments (still require licenses)
- Workers in states that never had licensing requirements
- Workers in already-deregulated states

### Heterogeneity tests:

1. **By race/ethnicity:**
   - Primary: African American women (largest effects expected)
   - Comparison: Non-Hispanic White women (smaller effects expected)
   
2. **By education:**
   - Less than high school / high school diploma (larger effects - license cost more binding)
   - Some college+ (smaller effects - can more easily afford licensing)
   
3. **By age:**
   - Young workers 18-35 (entering labor force, larger effects)
   - Older workers 36-64 (incumbent workers, smaller effects)

4. **By pre-deregulation state characteristics:**
   - States with stricter prior requirements (larger effects)
   - States with larger African American populations (larger effects)

## Robustness Checks

1. **Event study specification:**
   - Include leads and lags around deregulation year
   - Test for pre-trends (leads should be zero)
   - Examine dynamics (how quickly effects appear)

2. **Sample restrictions:**
   - Restrict to African American women only
   - Restrict to workers age 25-54 (prime working age)
   - Exclude states with partial deregulation

3. **Alternative outcomes:**
   - Employment status (any employment vs. not)
   - Full-time vs. part-time work
   - Industry switching (personal care → other or vice versa)

4. **Weighting:**
   - Unweighted
   - Weighted by PWGTP (person weight)
   - Weighted by Black population share

5. **Clustering:**
   - Cluster at state level (primary)
   - Wild bootstrap cluster (small number of clusters)

## Validity Checks

1. **Parallel trends:**
   - Visual inspection of self-employment trends pre-deregulation
   - Event study showing no significant pre-trends
   - Compare treated vs. control states before treatment

2. **Placebo tests:**
   - Run same analysis on occupations NOT affected by hair braiding deregulation (e.g., food service, retail)
   - Should find no effect

3. **Timing tests:**
   - Use alternative deregulation years (1 year before/after)
   - Should find no effect at wrong timing

4. **Covariate balance:**
   - Check that observable characteristics don't change discontinuously at deregulation

## What Would Invalidate the Design

1. **Correlated policy changes:** If states that deregulated hair braiding simultaneously enacted other policies affecting self-employment (e.g., business tax changes, occupational licensing reform more broadly)

2. **Endogenous timing:** If states deregulated in response to unobserved trends in the hair braiding market (e.g., growing demand already increasing self-employment)

3. **Selective migration:** If deregulation caused migration of hair braiders across states, contaminating the control group

4. **Measurement error in treatment:** If our coding of deregulation years is systematically wrong

5. **Composition effects:** If deregulation changes WHO enters the personal appearance occupation (selection), not just their employment status

## Data Notes

### Census PUMS Variables
- OCCP: Occupation code (personal appearance workers ~4500-4540)
- COW: Class of worker (6,7 = self-employed)
- SEMP: Self-employment income
- WAGP: Wage/salary income
- WKHP: Hours worked per week
- AGEP: Age
- SEX: Sex (2 = Female)
- RAC1P: Race (2 = Black or African American)
- HISP: Hispanic origin
- SCHL: Educational attainment
- ST: State FIPS code
- PWGTP: Person weight

### Occupation Code Mapping
The Census occupation codes for personal appearance workers include:
- 4500: Barbers
- 4510: Hairdressers, hairstylists, cosmetologists
- 4520: Manicurists and pedicurists
- 4530: Skincare specialists
- 4540: Personal appearance workers, all other

Hair braiders would primarily be classified under 4510 (hairstylists) or 4540 (other personal appearance workers). We cannot directly identify "hair braiders" but treat all personal appearance workers as potentially affected.

### Measurement Limitations
1. Cannot directly identify "hair braiders" vs. other hairstylists in PUMS
2. Self-employment may be underreported in surveys
3. Informal work not captured
4. Migration may blur state exposure
