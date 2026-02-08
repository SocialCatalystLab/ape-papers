# Pre-Analysis Plan

## Research Question

Do Universal License Recognition (ULR) laws increase interstate migration of workers in licensed occupations?

## Conceptual Framework

### Theory 1: Barrier Reduction (Primary)

**Mechanism:** Occupational licensing creates barriers to interstate mobility because workers must often re-apply, take new exams, or meet different requirements when moving to a new state. ULR eliminates these barriers by granting automatic recognition of out-of-state licenses. This reduces the costs of interstate moves for licensed workers, both in terms of time (waiting for license approval) and money (exam fees, continuing education).

**Prediction:**
- Sign: **Positive** - ULR increases in-migration of licensed workers
- Magnitude: 5-15% increase in licensed occupation in-migration to adopting states
- Heterogeneity: Effect should be strongest for:
  - Occupations with historically difficult reciprocity (cosmetologists, contractors, barbers) where licensing requirements vary substantially across states
  - Workers in border regions where the option to move across state lines is most relevant
  - Workers in tighter labor markets where demand for licensed workers is high

### Theory 2: General Labor Market Tightening (Alternative)

**Mechanism:** States adopting ULR may be responding to labor shortages in licensed occupations. The policy itself may have limited direct effect if (a) most workers can already navigate licensing requirements or (b) licensing barriers are not the primary deterrent to migration. Other factors (housing costs, family ties, job availability) may dominate migration decisions.

**Prediction:**
- Sign: **Null or weak positive** - ULR has limited effect because licensing is not the binding constraint
- Magnitude: 0-5% increase, not statistically distinguishable from zero
- Heterogeneity: Any effect should be uniform across occupation types

### Theory 3: Healthcare Exception

**Mechanism:** Healthcare occupations (physicians, nurses) are highly licensed but also subject to other regulations (state board requirements, hospital credentialing, malpractice considerations). Prior research (NBER WP 34030) found no physician migration response to ULR. Healthcare workers may respond through telehealth rather than physical relocation.

**Prediction:**
- Sign: **Null for healthcare, positive for non-healthcare**
- Magnitude: Heterogeneous by occupation type
- Heterogeneity: Non-healthcare licensed occupations should show larger effects

## Primary Specification

- **Question:** Does ULR adoption increase interstate in-migration of licensed occupation workers?
- **Unit of observation:** Person-year from Census PUMS
- **Sample:** 
  - Adults aged 25-64
  - Workers in licensed occupations (identified via OCCP codes)
  - Interstate movers (MIG=1 and MIGSP != current ST)
  - Years: 2017-2022 (1-year ACS PUMS)
- **Outcome variable:** Binary indicator for interstate migration in past year (moved from different state)
- **Treatment variable:** State adopted ULR in prior year (allowing for implementation lag)
- **Model:** 

Given staggered adoption, we use the Callaway & Sant'Anna (2021) estimator:

$$ATT(g,t) = E[Y_{it}(g) - Y_{it}(0) | G_i = g]$$

Where:
- $g$ is the group (year of first ULR adoption)
- $t$ is the calendar year
- $Y_{it}(g)$ is the potential outcome under treatment at time $g$
- $Y_{it}(0)$ is the potential outcome under never-treatment

Aggregate to event-study and overall ATT following Callaway & Sant'Anna.

For implementation, we will estimate a simplified stacked DiD:

$$Y_{ist} = \alpha + \beta \cdot ULR_{st} + \gamma_s + \delta_t + X_{ist}'\theta + \epsilon_{ist}$$

Where:
- $Y_{ist}$ = 1 if person $i$ in state $s$ at time $t$ moved from a different state
- $ULR_{st}$ = 1 if state $s$ had ULR in effect in year $t-1$
- $\gamma_s$ = state fixed effects
- $\delta_t$ = year fixed effects
- $X_{ist}$ = individual controls (age, sex, race, education)

Standard errors clustered at state level.

- **Expected sign:** Positive ($\beta > 0$) - ULR increases in-migration

## Where Mechanism Should Operate (REQUIRED)

### Who is directly affected by this policy?

1. **Workers in licensed occupations who consider moving** - The policy removes licensing barriers, so only workers who would otherwise face re-licensing are affected
2. **Workers in occupations with difficult interstate reciprocity** - Occupations like cosmetology, barbering, and construction trades where licensing requirements vary substantially across states
3. **Workers in border areas** - Moving costs are lower, so licensing is a more binding constraint
4. **Workers in states with previously burdensome licensing requirements** - States that had strict requirements before ULR adoption

### Who is NOT affected?

1. **Workers in non-licensed occupations** - No licensing barrier exists, so ULR is irrelevant
2. **Workers in occupations with existing reciprocity agreements** - Some professions (e.g., nurses via Nurse Licensure Compact) already had interstate mobility
3. **Workers who would not consider moving regardless** - Deep roots, family ties, housing ownership
4. **Workers in healthcare** - May respond via telehealth rather than migration (prior evidence)

### Heterogeneity tests:

1. **By occupation type:** Estimate separately for healthcare licensed vs. non-healthcare licensed (construction, personal services, education support)
2. **By border proximity:** Compare effects for workers in border counties vs. interior
3. **By prior reciprocity difficulty:** Compare effects for occupations with historically low vs. high interstate mobility

## Licensed Occupation Identification

We identify licensed occupations using Census occupation codes (OCCP) for professions that typically require state licensure:

**Non-Healthcare Licensed (Primary Focus):**
- Barbers (4500)
- Hairdressers/Hairstylists/Cosmetologists (4510)
- Childcare workers (4600) - if licensed
- Real estate brokers and sales agents (4920)
- Electricians (6355)
- Plumbers (6440)
- Construction laborers (6260) - in states requiring licensure
- Massage therapists (3630)

**Healthcare Licensed (Comparison):**
- Registered nurses (3255)
- Licensed practical nurses (3500)
- Physicians (3060-3090)
- Dentists (3010)
- Pharmacists (3050)

## ULR Adoption Timing

Based on legislative research:

| State | Year Enacted | Effective |
|-------|--------------|-----------|
| Arizona | 2019 | August 2019 |
| Pennsylvania | 2019 | 2019 |
| Montana | 2019 | 2019 |
| Idaho | 2020 | 2020 |
| Utah | 2020 | 2020 |
| Iowa | 2020 | 2020 |
| Missouri | 2020 | 2020 |
| Colorado | 2020 | 2020 |

(Additional states adopted in 2021-2022)

## Robustness Checks

1. **Alternative treatment timing:** Test sensitivity to assumed implementation lag (immediate vs. 1-year lag)
2. **Sample restrictions:** 
   - Drop Arizona (first adopter, potential outlier)
   - Use only early adopters (2019-2020) vs. late
3. **Alternative control groups:**
   - Never-treated states only
   - Not-yet-treated states
4. **Alternative outcomes:**
   - In-migration rate (share of population from other states)
   - Employment in licensed occupation (extensive margin)
5. **Placebo tests:**
   - Effect on non-licensed occupations (should be null)
   - Pre-treatment trends (event study)

## Validity Checks

1. **Parallel trends:** Event-study plot showing pre-treatment coefficients not significantly different from zero
2. **Covariate balance:** Compare adopting vs. non-adopting states on:
   - Age distribution
   - Education distribution
   - Baseline migration rates
   - Baseline licensed occupation shares
3. **Placebo occupation test:** Estimate effect on non-licensed occupations (should be null)
4. **Placebo timing test:** Assign fake treatment dates 2 years before actual adoption

## What Would Invalidate the Design

1. **Differential pre-trends:** If migration trends were already diverging before ULR adoption, cannot attribute post-adoption changes to policy
2. **Contemporaneous state policies:** If ULR-adopting states also enacted other labor market policies that affect migration (e.g., tax cuts, COVID responses), estimates are confounded
3. **COVID-19 disruption:** 2020-2021 saw major migration pattern disruptions; may obscure or confound ULR effects
4. **Selection into adoption:** States adopting ULR may be systematically different in ways that affect migration trends

## Power Considerations

With PUMS 1-year data 2017-2022:
- ~3.5 million person-records per year
- ~15-20% in licensed occupations (rough estimate)
- ~3% interstate movers per year

Expected sample of interstate movers in licensed occupations: ~30,000-50,000 per year.

This should provide adequate power to detect a 5-10% change in migration rates.
