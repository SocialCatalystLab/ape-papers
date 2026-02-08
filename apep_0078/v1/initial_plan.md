# Research Plan: State Minimum Wage Increases and New Business Formation

## Research Question

Do state minimum wage increases affect the rate of new business formation? Specifically, how do increases in state minimum wages above the federal floor impact business applications, high-propensity business applications, and applications with planned wages?

## Motivation

The minimum wage is one of the most studied labor market policies, yet the extensive literature focuses almost exclusively on employment effects for existing workers. The effect of minimum wage on the *entry margin*—new business formation—is comparatively understudied. This gap matters for several reasons:

1. **Entrepreneurship is a key driver of job creation**: New businesses account for nearly all net job creation in the U.S. economy
2. **Competing theoretical predictions**: Higher labor costs could deter business starts (cost channel) or encourage formalization by raising the cost of competing through informal/low-wage labor (formalization channel)
3. **Policy relevance**: The recent wave of state and local minimum wage increases to $15+ creates urgency for understanding broader economic effects

## Identification Strategy

**Design**: Difference-in-differences (DiD) exploiting staggered state adoption of minimum wage increases

**Treatment Definition**:
- Primary: Log real minimum wage (continuous treatment)
- Robustness: Binary indicator for "above federal floor" and event study around large discrete increases

**Key Identifying Assumption**: Absent treatment, states with minimum wage increases would have followed parallel trends in business formation as non-increasing states

**Threats to Identification**:
1. *Endogenous policy timing*: MW increases may respond to local economic conditions
2. *Concurrent policies*: Other pro-worker policies (paid leave, scheduling laws) often bundled
3. *Heterogeneous comparison groups*: Never-treated states (primarily Southern/rural) differ structurally

**Mitigation Strategies**:
- Event study to assess pre-trends visually and formally
- Include state-specific linear trends as robustness check
- Control for state GDP growth, unemployment rate, political party of governor
- Callaway-Sant'Anna estimator for heterogeneous treatment effects
- Goodman-Bacon decomposition to assess problematic comparisons

## Data Sources

1. **Outcome**: Census Bureau Business Formation Statistics (BFS)
   - Monthly state-level data, July 2004-present
   - Series: Business Applications (BA), High-Propensity Business Applications (HBA), Applications with Planned Wages (WBA)
   - API: https://api.census.gov/data/timeseries/econ/bfs

2. **Treatment**: State minimum wage laws
   - Source: UC Berkeley Labor Center, Department of Labor
   - Monthly effective dates, 2004-2024
   - Will construct log real MW (deflated by CPI-U)

3. **Controls**:
   - BLS: State unemployment rate (monthly)
   - BEA: State GDP (quarterly, interpolated)
   - Census: State population (annual)

## Exposure Alignment (DiD-Specific)

**Who is treated?**: Prospective entrepreneurs considering starting a business in states with higher minimum wages

**Primary estimand population**: Business formation decisions in treated states post-MW increase

**Placebo/control population**:
- Never-treated states (federal MW only): ~20 states as of 2024
- Not-yet-treated observations in early adopters

**Design**: Standard two-way DiD with staggered adoption; supplement with CS estimator

## Power Assessment

- **Pre-treatment periods**: 10+ years (2004-2014 for most states)
- **Treated clusters**: 30+ states with MW above federal
- **Post-treatment periods**: Varies by cohort (early adopters have 10+ years)
- **MDE**: With 50 states × 240 months, expect power to detect 2-3% changes in application rates

## Primary Specification

```
log(BA_{st}) = α + β × log(MW_{st}) + γ_s + δ_t + X_{st}θ + ε_{st}

where:
- BA_{st} = Business Applications in state s, month t
- MW_{st} = Real minimum wage in state s, month t
- γ_s = State fixed effects
- δ_t = Month-year fixed effects
- X_{st} = Time-varying state controls (unemployment, GDP growth)
```

Standard errors clustered at state level.

## Robustness Checks

1. **Alternative estimators**:
   - Callaway-Sant'Anna with staggered adoption
   - Sun-Abraham interaction-weighted estimator
   - Goodman-Bacon decomposition

2. **Alternative outcomes**:
   - High-Propensity Applications (HBA) - more likely to become employers
   - Applications with Planned Wages (WBA) - explicitly planning to hire
   - Log applications per capita

3. **Alternative treatment definitions**:
   - Binary: above federal floor
   - Event study: large increases (≥$1.00)
   - Continuous: percent increase from prior year

4. **Specification checks**:
   - State-specific linear trends
   - Drop recession years (2008-2010, 2020)
   - Exclude California and New York (large, early movers)
   - Placebo test: use lead of treatment

5. **Heterogeneity**:
   - By baseline wage distribution (high-MW-impact vs low-impact industries)
   - By business cycle phase
   - By state characteristics (right-to-work, cost of living)

## Expected Effects and Mechanisms

**Hypothesis 1 (Cost Channel)**: Higher minimum wages increase labor costs, reducing expected profitability and deterring business formation → *Negative effect on BA*

**Hypothesis 2 (Formalization Channel)**: Higher minimum wages make it harder to compete through low wages, reducing informal sector competition and encouraging formal business starts → *Positive effect on BA*

**Hypothesis 3 (Efficiency Wage Channel)**: Higher wages attract better workers, improving productivity and making new ventures more viable → *Positive effect on HBA*

**Prediction**: Effects may be heterogeneous—negative for low-wage sectors (restaurants, retail), potentially positive for others. Effect on HBA may differ from overall BA if MW affects composition of entrants.

## Timeline and Deliverables

1. Fetch and clean data (BFS, MW series, controls)
2. Construct analysis sample with treatment timing
3. Run main specifications and event studies
4. Generate figures (pre-trends, event study, geographic variation)
5. Run robustness checks and heterogeneity analysis
6. Write paper

## Key References

- Dube, Lester, Reich (2010): MW effects using border counties
- Cengiz et al. (2019): Bunching estimator for MW employment effects
- Callaway & Sant'Anna (2021): DiD with staggered adoption
- Autor, Manning, Smith (2016): MW and low-wage labor markets
- Census BFS documentation: https://www.census.gov/econ/bfs/about_the_data.html
