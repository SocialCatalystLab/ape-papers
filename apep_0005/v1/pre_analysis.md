# Pre-Analysis Plan: Arkansas Minimum Wage Stair-Step Increases (2019-2021)

**Locked before analysis begins. SHA-256 checksum created on lock.**

## Research Question

Did Arkansas's stair-step minimum wage increases from $8.50 to $11.00 (2019-2021) affect wages, employment, and hours worked among low-wage workers compared to neighboring states that remained at or near the federal minimum wage?

## Conceptual Framework

### Theory 1: Competitive Labor Market (Negative Employment Effects)

**Mechanism:** In a perfectly competitive labor market, a binding minimum wage increase raises labor costs above the market-clearing wage, causing employers to reduce employment. The magnitude depends on the elasticity of labor demand—more elastic demand produces larger disemployment effects.

**Prediction:**
- Sign: Negative for employment probability; positive for wages (conditional on employment)
- Magnitude: Arkansas's increase is unusually large (74% of median wage vs. typical 37-59%). Standard estimates suggest employment elasticities of -0.1 to -0.3, so a 29% wage floor increase could reduce employment 3-9% among affected workers.
- Heterogeneity: Effects should concentrate among:
  - Young workers (highest minimum wage bite)
  - Workers without college degrees
  - Service sector workers (restaurants, retail)
  - Part-time workers

### Theory 2: Monopsony/Search Frictions (Small or Zero Employment Effects)

**Mechanism:** When employers have wage-setting power (monopsony) or labor markets have search frictions, minimum wage increases can raise wages without reducing employment—employers simply capture less surplus. This reconciles the mixed empirical findings in the literature.

**Prediction:**
- Sign: Small negative or zero for employment; positive for wages
- Magnitude: Modern literature (Cengiz et al. 2019, Dube 2019) finds small disemployment effects
- Heterogeneity: Monopsony power varies by market concentration—effects may differ by local market structure

### Theory 3: Spillover Effects on Wages Above Minimum

**Mechanism:** Minimum wage increases compress the wage distribution from below, potentially "spilling over" to workers earning above the new minimum as employers maintain internal wage hierarchies.

**Prediction:**
- Sign: Positive for wages throughout the lower distribution
- Magnitude: Spillovers typically extend to 110-120% of the new minimum
- Heterogeneity: Strongest for workers just above the new minimum

## Primary Specification

### Main Analysis: Difference-in-Differences

- **Question:** Did Arkansas's minimum wage increase affect wages, employment, and hours for low-wage workers relative to neighboring states?

- **Unit of observation:** Individual worker-year (person i in state s in year t)

- **Sample:**
  - Adults ages 18-64
  - Survey years 2017-2022 (2 years pre, treatment years 2019-2021, 1 year post)
  - Treatment: Arkansas (FIPS = 05)
  - Control: Neighboring states at or near federal minimum throughout period:
    - Louisiana (FIPS = 22): Federal minimum ($7.25)
    - Mississippi (FIPS = 28): Federal minimum ($7.25)
    - Oklahoma (FIPS = 40): Federal minimum ($7.25)
    - Tennessee (FIPS = 47): Federal minimum ($7.25)
    - Note: Missouri (FIPS = 29) also raised minimum wage and is excluded from control
  - Restriction: Focus on workers potentially affected by minimum wage (those earning below $15/hour or low education)

- **Outcome variables:**
  1. Log hourly wage (primary): Calculated as WAGP / (WKHP × WKWN) for wage earners
  2. Employment probability: Binary indicator for ESR in [1,2] (employed)
  3. Hours worked: Weekly hours (WKHP), conditional on employment
  4. Weeks worked: Annual weeks (WKWN), conditional on employment
  5. Annual earnings: WAGP + SEMP

- **Treatment variable:**
  - $D_{st}$ = 1 if state s is Arkansas and year t >= 2019
  - For event study: separate indicators for each year

- **Model specification (two-way fixed effects):**

  $$Y_{ist} = \alpha + \beta \cdot (Arkansas_s \times Post_t) + \gamma_s + \delta_t + X_{ist}'\theta + \varepsilon_{ist}$$

  Where:
  - $Y_{ist}$ is the outcome for person i in state s in year t
  - $Arkansas_s$ = 1 if state is Arkansas
  - $Post_t$ = 1 if year >= 2019
  - $\gamma_s$ are state fixed effects
  - $\delta_t$ are year fixed effects
  - $X_{ist}$ are individual controls (age, age², sex, race, education)
  - Standard errors clustered at state level
  - All regressions weighted by PWGTP (person weight)

- **Event study specification:**

  $$Y_{ist} = \alpha + \sum_{k=-2}^{3} \beta_k \cdot (Arkansas_s \times \mathbf{1}[t = 2017+k]) + \gamma_s + \delta_t + X_{ist}'\theta + \varepsilon_{ist}$$

  With 2017 (k=-2) as the omitted reference period.

- **Expected signs:**
  - Log hourly wage: Positive (β > 0)
    - Rationale: Minimum wage mechanically raises wages for workers at the floor
  - Employment: Small negative or zero (β ≤ 0)
    - Rationale: Modern literature suggests small disemployment effects
  - Hours worked: Small negative or zero
    - Rationale: Employers may reduce hours as partial adjustment

## Policy Treatment: Arkansas Minimum Wage Timeline

Based on Issue 5 (2018 ballot initiative), approved with 68.5% voter support:

| Date | Arkansas Minimum Wage | Federal Minimum | Increase |
|------|----------------------|-----------------|----------|
| 2017 | $8.50 | $7.25 | Baseline |
| 2018 | $8.50 | $7.25 | Baseline |
| Jan 1, 2019 | $9.25 | $7.25 | +$0.75 (8.8%) |
| Jan 1, 2020 | $10.00 | $7.25 | +$0.75 (8.1%) |
| Jan 1, 2021 | $11.00 | $7.25 | +$1.00 (10.0%) |
| 2022 | $11.00 | $7.25 | Maintained |

**Total increase:** $8.50 → $11.00 = +$2.50 (29.4% increase over 3 years)

**Control states:** LA, MS, OK, TN all remained at federal minimum ($7.25) throughout 2017-2022.

## Where Mechanism Should Operate (REQUIRED)

### Who is directly affected by this policy?

The minimum wage increase primarily affects:
1. **Workers earning at or below the new minimum:** Those with wages between $7.25-$11.00 pre-treatment
2. **Workers in minimum wage-intensive industries:** Restaurants, retail, hospitality, agriculture
3. **Young workers:** Entry-level positions often pay minimum wage
4. **Workers without college degrees:** Higher concentration in low-wage jobs

The "first stage" (wage increase) is strongest for:
- Workers in the $8.50-$11.00 wage range pre-treatment
- Workers in industries with high minimum wage bite (food service, retail)
- Younger workers (18-24)
- Workers without bachelor's degrees

### Who is NOT affected?

- Workers earning well above $11.00/hour (no binding constraint)
- Salaried workers above the salary threshold
- Self-employed individuals (not covered by minimum wage)
- Workers in control states (no change in minimum wage)

### Heterogeneity tests:

1. **By predicted wage level:**
   - Low-wage workers (predicted wage < $12/hour): Largest effects expected
   - Mid-wage workers ($12-18/hour): Smaller/spillover effects
   - High-wage workers (> $18/hour): No effects expected (placebo)

2. **By age:**
   - Young workers 18-24: Largest effects (highest minimum wage bite)
   - Prime-age workers 25-54: Moderate effects
   - Older workers 55-64: Smaller effects

3. **By education:**
   - Less than high school: Largest effects
   - High school diploma only: Large effects
   - Some college: Moderate effects
   - Bachelor's+ : Small/no effects (placebo)

4. **By industry:**
   - Food service (NAICS 72): Largest effects
   - Retail trade (NAICS 44-45): Large effects
   - Healthcare support: Moderate effects
   - Other industries: Smaller effects

5. **By treatment intensity (year):**
   - 2019 effect vs. 2020 effect vs. 2021 effect
   - Effects should accumulate with each increase

## Robustness Checks

1. **Event study specification:**
   - Include leads (2017-2018) and lags (2019-2022)
   - Test for pre-trends (leads should be zero)
   - Examine dynamics of effect accumulation

2. **Sample restrictions:**
   - Restrict to workers age 18-30 only (highest bite)
   - Restrict to non-college workers only
   - Restrict to service sector workers only

3. **Alternative control groups:**
   - Border counties only (Arkansas vs. neighboring state counties)
   - Synthetic control method using all non-treated states
   - Drop each control state one at a time

4. **Alternative outcomes:**
   - Employment-to-population ratio (extensive margin)
   - Part-time vs. full-time status
   - Industry/occupation switching

5. **Staggered DiD considerations:**
   - This is a single-treated-unit design (Arkansas only), so staggered DiD bias not applicable
   - But note control states may experience other shocks

6. **Weighting:**
   - Weighted by PWGTP (primary)
   - Unweighted (sensitivity)

7. **Clustering:**
   - Cluster at state level (primary)
   - Wild bootstrap for small cluster correction (only 5 states)

## Validity Checks

1. **Parallel trends:**
   - Visual inspection of outcome trends 2017-2018 (pre-period)
   - Event study showing no significant pre-trends
   - Compare pre-treatment growth rates

2. **Placebo tests:**
   - Run same analysis on high-wage workers (> $20/hour) - should find no effect
   - Run same analysis on salaried workers - should find no effect
   - Placebo treatment timing (pretend 2017 was treatment year)

3. **Covariate balance:**
   - Compare demographic composition of Arkansas vs. control states over time
   - Test for differential changes in education, age, industry mix

4. **No anticipation:**
   - Examine whether wages started rising before Jan 1, 2019
   - Issue 5 passed Nov 2018, limited time for anticipation

## What Would Invalidate the Design

1. **Correlated policy changes:** If Arkansas enacted other labor market policies simultaneously (e.g., EITC changes, licensing reform, tax changes) that affect the same outcomes

2. **Differential economic shocks:** If Arkansas experienced different economic conditions (recession, industry shocks) than control states during the treatment period

3. **Control state contamination:** If workers or firms migrated from Arkansas to control states in response to minimum wage, biasing control outcomes

4. **Selective migration into Arkansas:** If minimum wage attracted different workers to Arkansas (unlikely to be large)

5. **COVID-19 confound:** The 2020-2021 pandemic may affect Arkansas and control states differently, confounding the later treatment effects. Will need to carefully interpret 2020-2021 results.

6. **Measurement error in wages:** PUMS wages are annual; imputed hourly wages (WAGP / WKHP / WKWN) may have error. This should not bias DiD if error is constant across states.

## Data Notes

### Census PUMS Variables

**Outcomes:**
- WAGP: Wage/salary income (past 12 months)
- ESR: Employment status recode (1=Employed civilian, 2=Employed civilian, with job not at work, 3=Unemployed, 6=Not in labor force)
- WKHP: Usual hours worked per week
- WKWN: Weeks worked past 12 months
- SEMP: Self-employment income

**Treatment/Geography:**
- ST: State FIPS code (05=AR, 22=LA, 28=MS, 40=OK, 47=TN)

**Controls:**
- AGEP: Age (0-99)
- SEX: Sex (1=Male, 2=Female)
- RAC1P: Race (1=White, 2=Black, etc.)
- HISP: Hispanic origin (1=Not Hispanic, 2-24=Hispanic)
- SCHL: Educational attainment (16=HS diploma, 20=Associate's, 21=Bachelor's, etc.)
- INDP: Industry code (NAICS-based)
- OCCP: Occupation code (SOC-based)

**Weights:**
- PWGTP: Person weight (for population estimates)
- PWGTP1-80: Replicate weights (for standard error calculation)

### Constructed Variables

1. **Hourly wage:**
   ```
   hourly_wage = WAGP / (WKHP * WKWN)
   ```
   Restricted to workers with positive WAGP, WKHP > 0, WKWN > 0

2. **Employed indicator:**
   ```
   employed = 1 if ESR in [1, 2] else 0
   ```

3. **Low-wage worker indicator:**
   ```
   low_wage = 1 if hourly_wage < 15 else 0
   ```

4. **Treatment indicator:**
   ```
   treat = 1 if ST == 05 else 0
   post = 1 if year >= 2019 else 0
   treat_post = treat * post
   ```

### Sample Size Estimates

Based on PUMS 1-year estimates (~3.5M records nationally):
- Arkansas (ST=05): ~15,000-20,000 working-age adults per year
- Control states combined: ~80,000-100,000 working-age adults per year
- Low-wage workers (< $15/hour): ~30-40% of employed workers
- Final analytical sample: ~200,000-300,000 person-year observations (2017-2022)

### Measurement Limitations

1. **Annual income timing:** WAGP is "past 12 months," not aligned perfectly with calendar year. Treatment effects may be attenuated if survey spans pre/post periods.

2. **Hourly wage imputation:** Dividing annual wages by hours*weeks introduces measurement error, especially for workers with variable schedules.

3. **Top-coding:** High incomes are top-coded in PUMS, but minimum wage workers are unaffected.

4. **Migration:** Cannot track individuals over time; some workers may move between states. Mitigated by short time window (6 years).

5. **COVID-19:** The 2020-2021 pandemic caused major labor market disruptions that may confound minimum wage effects. Will need careful interpretation.
