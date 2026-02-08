# Initial Research Plan

## Paper 93: SNAP Work Requirements and Employment Outcomes

### Research Question
Do SNAP work requirements for Able-Bodied Adults Without Dependents (ABAWDs) increase employment? We examine whether the reinstatement of work requirements following the expiration of state-level waivers led to increased employment among the targeted population.

### Policy Background
Under federal law (7 U.S.C. § 2015(o)), ABAWDs—defined as individuals aged 18-49 without dependents who are able to work—can only receive SNAP benefits for 3 months in any 36-month period unless they work or participate in a workfare program for at least 80 hours per month. However, states can request waivers of this time limit for areas with high unemployment or insufficient jobs.

Following the 2008 financial crisis, nearly all states received waivers. As labor markets recovered, states progressively lost waiver eligibility and work requirements were reinstated at different times, creating a natural experiment with staggered treatment timing.

### Identification Strategy
**Design:** Staggered difference-in-differences

**Treatment:** State loses ABAWD waiver → work requirements reinstated for ABAWDs

**Treatment Timing:** States lost waivers at different times between FY2013 and FY2019 based on local unemployment conditions falling below thresholds

**Comparison:** 
- Pre/post comparison within states that reinstated requirements
- States still under waiver serve as controls
- Triple-difference: compare ABAWDs (treated population) to similar adults with dependents (exempt from ABAWD requirements)

**Estimator:** Callaway and Sant'Anna (2021) for staggered DiD with heterogeneous treatment effects. This addresses concerns about negative weighting in two-way fixed effects with staggered adoption.

### Expected Effects and Mechanisms

**Primary Hypothesis:** Work requirements increase employment among ABAWDs by:
1. Incentivizing work to maintain benefits (income effect)
2. Increasing job search effort (compliance mechanism)
3. Connecting participants with employment services through SNAP Employment & Training programs

**Expected Magnitude:** Based on prior work requirement studies, we expect 2-5 percentage point increases in employment rates.

**Potential Null/Negative Results:**
- Work requirements may primarily cause benefit loss without employment gains if:
  - Local labor markets cannot absorb additional workers
  - Administrative barriers prevent compliance documentation
  - Target population has barriers (health, transportation) that ABAWD exemptions should capture but don't

### Primary Specification

$$Y_{ist} = \alpha + \beta \cdot \text{PostReinstatement}_{st} + \gamma_s + \delta_t + X_{ist}\theta + \varepsilon_{ist}$$

Where:
- $Y_{ist}$ = Employment indicator for individual $i$ in state $s$ at time $t$
- $\text{PostReinstatement}_{st}$ = 1 if state $s$ has reinstated work requirements by time $t$
- $\gamma_s$ = State fixed effects
- $\delta_t$ = Year fixed effects
- $X_{ist}$ = Individual controls (age, sex, race, education)

For staggered adoption with heterogeneous effects, we use the `did` package (Callaway & Sant'Anna 2021) to estimate group-time average treatment effects (ATT(g,t)) and aggregate to overall ATT.

### Sample Definition
**Treatment Group (ABAWDs):**
- Age 18-49
- No own children in household (NCHILD = 0 or OWN_CHILDREN = 0)
- Not receiving disability benefits
- Identify via ACS PUMS

**Control Group 1 (Within-State):**
- Same demographics but WITH dependents (exempt from ABAWD requirements)

**Control Group 2 (Cross-State):**
- ABAWDs in states still under waiver

### Planned Robustness Checks

1. **Event study:** Plot coefficients for years relative to reinstatement to assess pre-trends
2. **Triple difference:** ABAWDs vs. exempt adults, before/after, reinstated vs. waiver states
3. **Heterogeneity by:**
   - State unemployment rate at reinstatement
   - Urban vs. rural
   - Age (18-24 vs. 25-49)
   - Education level
4. **Alternative outcome:** Labor force participation (employed + unemployed looking for work)
5. **Placebo tests:**
   - Older adults (50+) who are exempt from ABAWD requirements
   - Employment outcomes for high-income individuals unlikely on SNAP

### Data Sources

1. **Policy Data:** USDA FNS ABAWD Waiver status by state and fiscal year
   - Source: https://www.fns.usda.gov/snap/abawd/waivers
   - Coverage: FY2010-2024

2. **Outcome Data:** Census ACS PUMS (2010-2022)
   - Employment status (ESR)
   - SNAP receipt (FS)
   - Age (AGEP)
   - Children in household (NCHILD/OC)
   - State (ST)
   - Person weights (PWGTP)

3. **Controls:** 
   - Individual: Age, sex, race, education, marital status
   - State-level: Unemployment rate, Medicaid expansion status

### Potential Confounders

1. **Medicaid Expansion:** Timing partially overlaps; control for state×year Medicaid expansion status
2. **Economic Recovery:** State-specific trends in employment; use event study to assess differential trends
3. **Selection out of SNAP:** Work requirements may cause people to leave SNAP without changing employment; examine SNAP receipt as secondary outcome

### Power Assessment

- ACS annual sample: ~3 million persons
- ABAWD-eligible (18-49, no dependents): ~15% of sample → ~450,000/year
- With 10 years of data: ~4.5 million person-year observations
- Minimum detectable effect at 80% power: <1 percentage point

### Timeline
1. Collect waiver status data from USDA FNS
2. Download ACS PUMS 2010-2022
3. Construct treatment and outcome variables
4. Estimate primary specification
5. Robustness checks
6. Write paper
