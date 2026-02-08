# Initial Research Plan - Paper 58

## Research Question

Does state-level paid family leave (PFL) increase maternal employment for women who recently gave birth?

## Policy Background

Five U.S. states adopted comprehensive paid family leave programs with staggered timing:
- **California:** July 1, 2004 (first state)
- **New Jersey:** July 1, 2009
- **Rhode Island:** January 1, 2014
- **New York:** January 1, 2018
- **Washington:** January 1, 2020

These programs provide partial wage replacement (50-90% depending on state and year) for workers taking leave to bond with a new child or care for a seriously ill family member. The staggered adoption creates quasi-experimental variation for DiD analysis.

## Identification Strategy

**Design:** Staggered difference-in-differences
- **Treatment:** State adopted PFL program
- **Treatment timing:** Year when PFL benefits became available
- **Treated group:** Working-age women (25-44) who gave birth in the past 12 months
- **Control group:** Same-aged women in states that never adopted PFL through the sample period
- **Estimator:** Callaway-Sant'Anna (2021) heterogeneity-robust DiD

**Key identification assumptions:**
1. **Parallel trends:** Employment rates for new mothers in treatment and control states would have followed parallel trajectories absent PFL
2. **No anticipation:** Women do not change employment behavior before PFL takes effect
3. **SUTVA:** No spillovers across states

**Potential threats:**
- States adopting PFL may already be on different trends (policy endogeneity)
- Concurrent policy changes (childcare subsidies, minimum wage, EITC)
- Migration/selection effects

## Data

**Source:** American Community Survey (ACS) 1-year PUMS, 2005-2022
- Accessed via Census Bureau API

**Sample:**
- Women aged 25-44
- Identify recent mothers using FER variable (gave birth in past 12 months)
- Approximately 18 years × 50 states × ~2,000 mothers per state-year = substantial sample

**Key variables:**
- **Outcome:** ESR (employment status): employed vs not employed
- **Treatment:** State × year PFL adoption
- **Controls:** Age, education, race, marital status, number of children

## Primary Specification

Event study specification using Callaway-Sant'Anna:
```
Y_it = α_i + λ_t + Σ_k β_k × 1{t - g_i = k} + ε_it
```
where g_i is the first year state i adopted PFL, and β_k captures the effect k years before/after adoption.

## Expected Effects

**Hypothesized positive effect:** PFL may increase maternal employment by:
1. Allowing mothers to take leave without quitting
2. Strengthening job attachment through guaranteed return rights
3. Reducing need to leave labor force entirely after birth

**Alternative hypotheses:**
- Null effect if labor supply is inelastic or PFL merely shifts timing
- Negative effect if PFL encourages longer leaves (unlikely for employment level)

## Robustness Checks

1. **Parallel trends validation:** Event study with pre-treatment coefficients
2. **Triple-difference:** New mothers vs. childless women or mothers of older children
3. **Honest DiD sensitivity:** Rambachan-Roth bounds for violations of parallel trends
4. **Heterogeneity:** By education, race, industry, parity (first birth vs. higher order)
5. **Alternative outcomes:** Hours worked, labor force participation, wages

## Timeline

1. Fetch ACS PUMS data (2005-2022)
2. Clean data, construct treatment indicators
3. Run main DiD analysis with event study
4. Robustness checks
5. Write paper
6. Internal review
7. External review

## Key Citations

- Rossin-Slater, Ruhm, Waldfogel (2013) - California PFL effects
- Baum & Ruhm (2016) - California PFL and mothers
- Callaway & Sant'Anna (2021) - Heterogeneity-robust DiD
- Sun & Abraham (2021) - Event study estimator
