# Initial Research Plan

**Paper:** 86
**Title:** Minimum Wage Increases and Teen Time Allocation: Direct and Spillover Effects
**Date:** 2026-01-27

---

## Research Question

How do state minimum wage increases affect the time allocation of teenagers (ages 16-19)? We examine both direct effects on working teens in minimum-wage-sensitive industries and spillover effects on non-working teens.

## Identification Strategy

**Design:** Difference-in-differences exploiting staggered state adoption of minimum wages above the federal floor.

**Treatment:** State×month minimum wage above federal minimum, coded using exact effective dates (most take effect January 1 or July 1).

**Comparison:** Never-treated states (federal MW only: AL, LA, MS, SC, TN, GA, WY) plus not-yet-treated observations in eventually-treated states.

**Estimator:** Callaway & Sant'Anna (2021) for staggered DiD with heterogeneous treatment effects. Aggregated ATT reported after pre-trend validation.

## Expected Effects and Mechanisms

**Direct effects (working teens in MW-sensitive industries):**
1. **Work time:** Ambiguous. Hours may increase (higher wage → substitution) or decrease (employer demand falls).
2. **Job search time:** Decrease if employed; increase if displaced.
3. **Education time:** Increase if MW raises opportunity cost of work relative to schooling.
4. **Leisure time:** Ambiguous, depends on labor supply response.

**Spillover effects (non-working teens):**
1. **Job search time:** May increase (MW makes jobs more attractive) or decrease (fewer opportunities).
2. **Education time:** May increase if labor market tightening pushes teens toward school.
3. **Leisure/socializing:** May decrease if peers are working more, or increase if jobs are scarce.

**Hypotheses:**
- H1: Working teens in MW-sensitive industries reduce work time following MW increases (labor demand channel dominates).
- H2: Non-working teens increase education time (human capital investment response).
- H3: Job search time increases for non-working teens (wage attraction effect).

## Primary Specification

```
Y_ist = α + β × Post_st + γ_s + δ_t + X_ist'θ + ε_ist
```

Where:
- Y_ist = minutes per day in activity category for individual i in state s at time t
- Post_st = indicator for state s having MW above federal at time t (coded by diary month)
- γ_s = state fixed effects
- δ_t = year-month fixed effects
- X_ist = individual controls (age, sex, race, family income, school enrollment)

For Callaway-Sant'Anna: group by first MW increase date (cohort g), estimate ATT(g,t) for each cohort×period, then aggregate.

## Outcome Variables

**Primary (aggregated categories):**
1. Total work time (including job search)
2. Total education time (school attendance + homework)
3. Total leisure time (socializing + sports + entertainment)

**Secondary (detailed):**
4. Work time (employment only)
5. Job search time
6. School attendance time
7. Homework/studying time
8. Socializing with friends
9. Household chores

**Placebo:**
10. Sleep time (should not respond to MW)
11. Personal care (should not respond to MW)

## Sample Definitions

**Full sample:** ATUS respondents ages 16-19, years 2003-2023

**Direct effects sample:** Employed teens in MW-sensitive industries (NAICS 44-45, 71, 722)

**Spillover sample:** Non-employed teens (not currently working)

## Planned Robustness Checks

1. **Alternative treatment coding:** Annual state-year instead of state-month
2. **Intensive margin:** Log(MW) instead of binary treatment
3. **Exclude big reform states:** Drop CA, NY, WA
4. **Control for other policies:** State EITC, paid sick leave
5. **Bacon decomposition:** Show which comparisons drive the effect
6. **Sun-Abraham estimator:** Alternative to Callaway-Sant'Anna
7. **HonestDiD sensitivity:** Allow for violations of parallel trends
8. **Placebo test:** Effects on sleep/personal care (should be null)

## Data Sources

1. **ATUS:** IPUMS ATUS extract with STATEFIP, MONTH, YEAR, AGE, activity variables, employment status, industry codes
2. **MW data:** DOL Historical Minimum Wage Database, supplemented with EPI Minimum Wage Tracker for exact effective dates

## Timeline

1. Fetch ATUS data via IPUMS API
2. Fetch/construct MW panel with effective dates
3. Clean and merge data
4. Run main DiD analysis
5. Run robustness checks
6. Generate figures and tables
7. Write paper
