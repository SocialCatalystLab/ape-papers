# Initial Research Plan: Paper 166 (Revision of apep_0076)

## Context

This is a revision of APEP-0076: "State Earned Income Tax Credit Generosity and Crime: Evidence from Staggered Adoption"

Parent paper issues:
- SUSPICIOUS scan verdict (data provenance)
- Limited panel (1999-2019) excluded early adopters from CS estimation
- Static treatment measure (2019 snapshot)
- Missing robust inference methods

## Research Question

Does state EITC adoption causally affect crime rates? We estimate the effect using staggered adoption across 29 US jurisdictions.

## Identification Strategy

**Design:** Staggered difference-in-differences

**Treatment:** State EITC adoption (binary) and generosity (continuous, time-varying)

**Outcome:** Log crime rates per 100,000 population

**Key assumption:** Parallel trends - crime trajectories would have been similar absent EITC adoption

**Estimators:**
1. Two-way fixed effects (TWFE) with state and year FE
2. Callaway-Sant'Anna heterogeneity-robust estimator
3. Sun-Abraham interaction-weighted estimator
4. Goodman-Bacon decomposition for diagnostics

## Data Sources

1. **Crime data:** CORGIS State Crime dataset (FBI UCR, 1960-2019)
   - Downloaded programmatically with documented provenance

2. **EITC policy data:** Tax Policy Center, NCSL, state revenue departments
   - Time-varying credit rates (not just 2019 snapshot)

3. **Controls:** State minimum wage, national incarceration trends

## Panel Structure

- **Sample period:** 1987-2019 (33 years)
- **Units:** 51 jurisdictions (50 states + DC)
- **Observations:** 1,683 state-years
- **Treatment:** 29 jurisdictions adopt by 2019; 22 never-treated controls

## Expected Results

Based on parent paper: null effect on property crime, potentially some effect on violent crime that is sensitive to specification.

## Robustness Checks

1. State-specific linear time trends
2. Policy controls (minimum wage, incarceration)
3. Sample period restrictions (1999+, 2005+)
4. Exclude outliers (DC, MD)
5. Placebo tests (murder, pre-treatment fake treatment)
6. Heterogeneity by refundability and generosity

## Exposure Alignment

**Who is treated?**
- Direct beneficiaries: Low-income working families receiving state EITC
- Affected population: Households with earned income below ~$55,000
- Exposure rate: Approximately 15-25% of state households claim EITC

**Treatment-eligible units:**
- 29 jurisdictions adopted state EITC by 2019 (treatment group)
- 22 never-treated states serve as controls

**Mechanism:**
- EITC provides income support to working families
- May reduce economic desperation driving property crime
- State-level analysis captures intent-to-treat (ITT) effect

## Primary Specification

```
log(crime_rate_st) = α + τ·treated_st + γ_s + δ_t + ε_st
```

Where:
- s indexes states, t indexes years
- γ_s are state fixed effects
- δ_t are year fixed effects
- τ is the treatment effect of interest
- Standard errors clustered at state level

---

*Plan locked before data fetch. See research_plan.md for evolving documentation.*
