# Initial Research Plan: Sports Betting Legalization and State Employment

## Research Question

Does the legalization of sports betting at the state level create new jobs in the gambling and leisure industries, or does it primarily formalize existing informal betting activity without net employment gains?

## Policy Background

### The Murphy v. NCAA Decision (May 14, 2018)

The Supreme Court's ruling in *Murphy v. NCAA* struck down the Professional and Amateur Sports Protection Act (PASPA), which had effectively banned sports betting in most states since 1992. This landmark decision empowered states to legalize and regulate sports betting at their discretion.

### Staggered State Adoption

Following the decision, states have legalized sports betting at different times and in different forms:

| Year | States Legalizing |
|------|-------------------|
| 2018 | DE, NJ, MS, WV, PA, RI (6 states) |
| 2019 | AR, IN, IA, MT, NH, NY (retail), OR, TN (8 states) |
| 2020 | CO, IL, MI, VA, WA (5 states) |
| 2021 | AZ, CT, LA, MD, SD, WY (6 states) |
| 2022 | KS, OH (2 states) |
| 2023 | KY, ME, MA, NE, NC, VT (6 states) |
| 2024 | MO (1 state) |

As of 2024, 38 states plus DC have legalized sports betting in some form. The remaining states (including UT, ID, AK, GA, TX, FL, SC, AL, HI, WI) have not legalized.

## Identification Strategy

### Difference-in-Differences with Staggered Adoption

**Treatment:** State legalization of sports betting (first legal bet placed)

**Control groups:**
1. Never-treated states (12 states that never legalized)
2. Not-yet-treated states (before their own legalization)

**Key identifying assumption:** Parallel trends - employment in gambling/leisure sectors would have evolved similarly in treated and control states absent legalization.

### Addressing Staggered Adoption Bias

Following Goodman-Bacon (2021), Sun-Abraham (2021), and Callaway-Sant'Anna (2021), I will:

1. **Diagnostic:** Run Goodman-Bacon decomposition to identify problematic 2x2 comparisons
2. **Event study:** Plot dynamic treatment effects with leads/lags to assess pre-trends
3. **Heterogeneity-robust estimation:** Use Callaway-Sant'Anna group-time ATTs (via R's `did` package)
4. **Robustness:** Sun-Abraham interaction-weighted estimator (via R's `fixest::sunab()`)

### Potential Threats

1. **Endogenous timing:** States may legalize during economic booms → include state economic controls
2. **Heterogeneous implementation:** Retail vs. mobile, tax rates, licensing → estimate by implementation type
3. **Anticipation effects:** Firms may hire before legal launch → allow pre-period effects
4. **Substitution:** Jobs may shift from casinos or illegal markets, not create net gains

## Data Sources

### Primary Data: Quarterly Census of Employment and Wages (QCEW)

- Source: Bureau of Labor Statistics
- Coverage: All establishments covered by unemployment insurance
- Granularity: State × quarter × industry (NAICS)
- Key industries:
  - NAICS 7132: Gambling industries
  - NAICS 713210: Casinos (excluding hotels)
  - NAICS 713290: Other gambling industries
  - NAICS 721120: Casino hotels
  - NAICS 71: Arts, entertainment, recreation (broader)

### Secondary Data: Current Population Survey (CPS)

- Source: Census Bureau/BLS
- Coverage: Monthly household survey
- Variables: Employment by state × industry × demographics
- Limitation: Small samples for narrow industries at state level

### Policy Timing Data

- Source: Legal Sports Report, American Gaming Association
- Variables: State, legalization date, type (retail/mobile/both), tax rate

## Outcome Variables

### Primary outcomes:
1. **Employment:** Number of employees in gambling industries (QCEW)
2. **Establishments:** Number of gambling establishments (QCEW)
3. **Wages:** Average weekly wages in gambling industries (QCEW)

### Secondary outcomes:
1. Leisure/hospitality employment (broader sector)
2. Food service employment (complementary sector)
3. Casino employment (potential substitute)

## Empirical Specification

### Static DiD (TWFE baseline, for comparison only)
```
Y_st = α + β × Treat_st + γ_s + δ_t + X_st'θ + ε_st
```

### Callaway-Sant'Anna Group-Time ATT
```
ATT(g,t) = E[Y_t(g) - Y_t(0) | G = g]
```
Where g is the cohort (year of legalization) and t is calendar time.

### Event Study
```
Y_st = α + Σ_k β_k × D_st^k + γ_s + δ_t + ε_st
```
Where D_st^k indicates k periods relative to treatment.

## Expected Effects and Mechanisms

### Mechanism 1: Direct job creation
- Sportsbook operators hire staff (traders, customer service, compliance)
- Retail locations create floor staff positions
- Expected effect: Positive employment in NAICS 7132

### Mechanism 2: Complementary spillovers
- Sports bars and restaurants may benefit from increased traffic
- Expected effect: Positive employment in food service

### Mechanism 3: Substitution from casinos
- Bettors may shift from casino gambling to sports betting
- Expected effect: Negative/null effect on casino employment (NAICS 713210)

### Mechanism 4: Formalization (not net creation)
- Existing illegal betting becomes legal; same workers, new classification
- Expected effect: Positive gambling employment but null total employment

## Robustness Checks

1. **Placebo test:** Industries unaffected by sports betting (manufacturing, agriculture)
2. **Dose-response:** Effects by implementation type (mobile stronger than retail-only)
3. **Border county analysis:** Compare counties bordering states with different policies
4. **Synthetic control:** For early adopters (NJ, PA) with long pre-periods
5. **Alternative timing:** Use announcement date vs. launch date
6. **Heterogeneity:** By state size, existing casino presence, sports culture

## Timeline and Milestones

1. Data collection and cleaning (QCEW, policy dates)
2. Descriptive statistics and visualization
3. Event study estimation and pre-trend assessment
4. Main results (Callaway-Sant'Anna ATTs)
5. Robustness checks
6. Paper writing

## Expected Contribution

This paper will provide the first rigorous causal estimates of the employment effects of sports betting legalization. The contribution is:

1. **Policy-relevant:** $20B+ industry with ongoing legalization debates
2. **Novel:** Existing work focuses on consumer outcomes, not labor markets
3. **Methodologically sound:** Modern DiD methods for staggered adoption
4. **Actionable:** Informs state-level cost-benefit analyses

## Potential Findings

- **Scenario A (industry claims correct):** Large positive employment effects in gambling sector
- **Scenario B (substitution dominates):** Positive gambling, negative casino, null net effect
- **Scenario C (formalization only):** Positive gambling employment, null total employment
- **Scenario D (null):** No detectable effects (jobs too few to measure at state level)

All scenarios are publishable with appropriate interpretation.
