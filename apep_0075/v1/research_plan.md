# Initial Research Plan

**Paper:** 102
**Date:** 2026-01-28
**Status:** LOCKED (do not modify after data fetch)

---

## Research Question

**Do state minimum wage increases reduce employment among older workers (65+)?**

The vast minimum wage literature focuses on teenagers and young adults as the canonical affected group. Yet older workers (65+) are a growing share of the low-wage workforce: nearly 1 in 5 Americans 65+ are now employed (up from 1 in 10 in 1988), and many work in minimum-wage-adjacent sectors like retail, food service, and home care. We examine whether minimum wage increases—which may compress wage distributions and increase labor costs for older workers who are less productive or working reduced hours—affect employment outcomes for this understudied demographic.

---

## Identification Strategy

**Design:** Staggered Difference-in-Differences

We exploit variation in state minimum wage increases from 2010-2023. States raised their minimum wages at different times and by different magnitudes, providing rich policy variation. We compare employment outcomes for older workers in states that raised their minimum wage to outcomes in states that did not (or raised later).

**Treatment definition:**
- State raises effective minimum wage above $7.25 federal floor
- Treatment intensity: log(state MW) - log(federal MW)
- First-time treatment: first state MW increase above federal floor

**Estimator:** Callaway & Sant'Anna (2021) for heterogeneous treatment timing
- Avoids negative weighting problems in two-way fixed effects
- Allows for treatment effect heterogeneity by cohort and time
- Uses never-treated states as comparison group

---

## Expected Effects and Mechanisms

**Primary hypothesis:** Minimum wage increases reduce employment among elderly low-wage workers.

**Mechanisms:**
1. **Labor demand:** Higher wage floors increase labor costs; employers may substitute toward younger workers or automation
2. **Hours reduction:** Employers may reduce hours rather than headcount
3. **Labor supply:** Higher wages may induce some elderly workers to remain in/enter workforce (offsetting demand effects)

**Expected sign:** Ambiguous a priori. Prior literature on teens shows small negative or null employment effects. Elderly workers may face:
- Less job mobility (harder to find new jobs if displaced)
- Social Security interactions (earnings test pre-2000 was binding)
- Health limitations that make hour adjustments costly

**Heterogeneity:**
- Larger effects expected in retail/food service (high minimum wage exposure)
- Effects may differ by state economic conditions
- Effects may differ by age band (65-74 vs 75+)

---

## Data

**Primary data:** CPS Merged Outgoing Rotation Groups (MORG), 2010-2023
- Monthly observations with hourly wage data
- State identifiers
- Employment status, hours worked
- Demographics: age, education, race, gender
- Occupation and industry codes

**Minimum wage data:**
- Vaghul & Zipperer minimum wage database (Washington Center for Equitable Growth)
- State effective minimum wages by month/year

**Sample restrictions:**
- Age 65+
- Low-education (high school or less) OR low-wage occupations (service, retail)
- Civilian non-institutional population

**Sample size estimate:** ~15,000-20,000 observations per year of elderly low-wage workers

---

## Primary Specification

```
Y_ist = α + β * Post_st + γ_s + δ_t + X_it'θ + ε_ist
```

Where:
- Y_ist: Employment indicator for individual i in state s at time t
- Post_st: Indicator for state s having raised MW above federal by time t
- γ_s: State fixed effects
- δ_t: Time (year-month) fixed effects
- X_it: Individual controls (age, education, race, gender)

**Callaway-Sant'Anna specification:**
- Group = first year state raised MW above federal
- Treatment = log(state MW)
- Comparison = never-treated states only

---

## Planned Robustness Checks

1. **Event study:** Plot coefficients for t-5 to t+5 relative to treatment
2. **Bacon decomposition:** Identify which 2x2 comparisons drive results
3. **Alternative treatment:** Continuous log(MW) vs binary indicator
4. **Placebo tests:**
   - High-wage elderly workers (should show null)
   - Pre-trends test in event study
5. **Border discontinuity:** Compare contiguous border counties (Dube et al. style)
6. **Alternative samples:**
   - All 65+ (not just low-wage)
   - 55-64 (near-elderly comparison)
7. **Alternative outcomes:**
   - Hours worked (intensive margin)
   - Hourly wages (compliance check)
   - Labor force participation

---

## DiD Validity Assessment

| Criterion | Assessment |
|-----------|------------|
| Pre-treatment periods | Strong (10+ years before most treatments) |
| Treatment clusters | Strong (25+ states raise MW 2010-2023) |
| Parallel trends | Testable via event study |
| No anticipation | Plausible (MW increases often announced close to implementation) |
| SUTVA | Moderate (some cross-border shopping possible but limited for labor) |
| Staggered timing | Addressed via Callaway-Sant'Anna |

---

## Timeline

1. Data acquisition: Fetch CPS MORG via IPUMS
2. Variable construction: Create treatment indicators, sample restrictions
3. Descriptive statistics: Summary tables, trends plots
4. Main analysis: DiD estimation
5. Robustness: Event study, placebo tests, alternative specifications
6. Paper writing: Introduction, literature, methods, results, conclusion

---

## Key References

- Cengiz, D., Dube, A., Lindner, A., & Zipperer, B. (2019). The effect of minimum wages on low-wage jobs. QJE.
- Dube, A., Lester, T.W., & Reich, M. (2010). Minimum wage effects across state borders. REStat.
- Callaway, B., & Sant'Anna, P.H. (2021). Difference-in-differences with multiple time periods. JoE.
- Neumark, D., & Shirley, P. (2022). Myth or measurement: What does the new minimum wage research say about minimum wages and job loss in the United States? ILR Review.
