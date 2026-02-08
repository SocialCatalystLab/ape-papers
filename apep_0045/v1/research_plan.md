# Initial Research Plan: State Auto-IRA Mandates and Retirement Savings

## Research Question

Do state-mandated automatic enrollment IRA programs increase retirement savings participation among private-sector workers without employer-sponsored plans?

## Background

Since Oregon's pioneering OregonSaves program launched in October 2017, 13 states have implemented mandatory auto-enrollment retirement savings programs for private-sector workers. These programs require employers who do not offer qualified retirement plans to automatically enroll their employees in state-facilitated Roth IRA accounts with default contribution rates (typically 3-5% of wages). Workers can opt out, but the behavioral economics literature suggests auto-enrollment dramatically increases participation relative to opt-in systems.

**Treatment states and effective dates:**
| State | Program Name | Launch Date | Default Contribution |
|-------|--------------|-------------|---------------------|
| Oregon | OregonSaves | October 2017 | 5% |
| Illinois | Secure Choice | October 2018 | 5% |
| California | CalSavers | July 2019 | 5% |
| Connecticut | MyCTSavings | April 2022 | 3% |
| Maryland | Maryland$aves | September 2022 | 5% |
| Colorado | Secure Savings | January 2023 | 5% |
| Virginia | RetirePath | June 2023 | 5% |
| Maine | MERSavers | January 2024 | 5% |
| New Jersey | RetireReady NJ | June 2024 | 3% |
| Delaware | Delaware EARNS | July 2024 | 5% |
| Vermont | Green Mountain Secure | December 2024 | 5% |

## Identification Strategy

**Design:** Staggered difference-in-differences exploiting state-level policy adoption timing.

**Treatment:** State-year adoption of mandatory auto-IRA program.

**Comparison:** Never-treated states (no mandatory auto-IRA program as of 2024).

**Estimator:** Callaway-Sant'Anna (2021) group-time average treatment effects, which addresses heterogeneous treatment effect bias in staggered DiD. For robustness: Sun-Abraham (2021), Gardner two-stage (2022).

**Key Assumptions:**
1. **Parallel trends:** Absent treatment, retirement participation would have evolved similarly in treated vs. control states.
2. **No anticipation:** Workers don't change behavior before program implementation.
3. **SUTVA:** No spillovers between states (e.g., workers moving states to avoid/access programs).

## Exposure Alignment

**Who is actually treated?**
- Private-sector workers whose employers do not offer qualified retirement plans (401k, SIMPLE, SEP-IRA, etc.)
- Employers must meet size thresholds (varies by state: typically starts with largest employers, phases down to all employers over 1-3 years)
- Self-employed, government workers, and workers with employer plans are NOT directly affected

**Primary estimand population:**
- Private-sector workers ages 18-64 without employer-sponsored retirement plans
- This is the population directly affected by auto-enrollment

**Placebo/comparison populations:**
- Workers WITH employer-sponsored retirement plans (should see zero effect)
- Self-employed individuals (should see zero effect)
- Government workers (should see zero effect)

**Design implications:**
- Triple-diff possible: (auto-IRA state vs. non-auto-IRA state) × (no employer plan vs. has employer plan) × (pre vs. post)
- But baseline DiD on the directly affected population (workers without employer plans) is cleaner and more powerful

## Power Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | CPS ASEC 2012-2016 = 5 years pre-Oregon | **Strong** |
| Treated clusters | 11 states (through 2024 data) | **Marginal** (close to 10 threshold) |
| Post-treatment periods | 2-7 years per cohort | **Strong** |
| Sample size | ~100k ASEC respondents/year; ~30% without employer plans | **Strong** |

**MDE Calculation:** With N≈30,000 "at-risk" workers/year, ~11 treated states, 50 total states, and ICC≈0.02, MDE ≈ 3-5 percentage points for retirement participation. Given baseline participation among non-covered workers is ~10-15%, this represents a 20-50% relative increase, which is plausible given auto-enrollment literature.

## Data Sources

**Primary outcome data:**
- IPUMS CPS ASEC (March supplement), 2012-2024
- Variables: PENSESSION (pension plan at work), PENESSION (participating in pension), INCLUGH (any retirement income), state identifiers (STATEFIP), demographic/labor market controls

**Secondary outcome data:**
- Survey of Consumer Finances (SCF) for robustness - but only triennial

**Policy dates:**
- Hand-collected from state program websites and Georgetown Center for Retirement Initiatives

## Primary Specification

```
Y_ist = α + β × AutoIRA_st + X_ist'γ + λ_s + δ_t + ε_ist
```

Where:
- Y_ist = retirement plan participation indicator for individual i in state s at time t
- AutoIRA_st = 1 if state s has auto-IRA mandate in effect at time t
- X_ist = individual controls (age, education, income, industry, firm size, marital status)
- λ_s = state fixed effects
- δ_t = year fixed effects
- Standard errors clustered at state level

**Callaway-Sant'Anna specification:**
- Group-time ATTs: ATT(g,t) for each adoption cohort g and time t
- Aggregate to event-study (dynamic effects) and overall ATT

## Robustness Checks

1. **Event study:** Plot pre-treatment coefficients to assess parallel trends
2. **Alternative estimators:** Sun-Abraham, Gardner two-stage, Borusyak-Jaravel-Spiess imputation
3. **HonestDiD sensitivity:** Rambachan-Roth bounds for violations of parallel trends
4. **Placebo outcomes:** Workers WITH employer plans (should show null effect)
5. **Placebo timing:** Assign fake treatment dates 3 years before actual adoption
6. **Intensive margin:** Condition on participation, examine contribution amounts (limited in CPS)
7. **Heterogeneity:** By age, income, industry, firm size
8. **Alternative samples:** Drop early adopters (Oregon/Illinois), focus on post-2020 adopters

## Expected Effects and Mechanisms

**Primary mechanism:** Auto-enrollment overcomes inertia/procrastination (Madrian & Shea 2001, Thaler & Benartzi 2004). Default contribution rates of 3-5% are "sticky" - most workers don't opt out or change rates.

**Expected effects:**
- Increase in retirement account ownership/participation: +5-15 percentage points (based on 401k auto-enrollment studies)
- Increase in total retirement wealth (unobservable in CPS)
- Potential reduction in opt-out rates over time as programs mature

**Heterogeneity predictions:**
- Larger effects for younger workers (less established savings habits)
- Larger effects for lower-income workers (more likely to lack existing savings)
- Larger effects in states with higher default contribution rates

## Timeline and Deliverables

1. Fetch and clean CPS ASEC data (2012-2024)
2. Construct treatment indicators and verify policy dates
3. Run baseline DiD and Callaway-Sant'Anna
4. Event study and pre-trends diagnostics
5. Robustness checks and heterogeneity
6. Write paper
7. Internal and external review
