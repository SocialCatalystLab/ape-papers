# Initial Research Plan - Paper 35

**Title:** The Montana Miracle: Effects of Statewide Zoning Reform on Residential Construction

**Date Created:** 2026-01-18
**Status:** LOCKED (do not modify after creation)

---

## Research Question

Did Montana's 2024 statewide zoning reforms (SB 528 legalizing ADUs and SB 323 legalizing duplexes) increase residential building permits relative to comparable states?

---

## Policy Background

### Key Legislation

1. **Senate Bill 528** (ADU Legalization)
   - Signed: May 2023
   - Effective: January 1, 2024
   - Requires municipalities to allow at least one ADU per single-family lot
   - Prohibits owner-occupancy requirements, parking minimums, and impact fees
   - Caps permit fees at $250
   - Applies to: All Montana municipalities

2. **Senate Bill 323** (Duplex Legalization)
   - Signed: May 2023
   - Effective: January 1, 2024
   - Legalizes attached or detached duplexes anywhere single-family homes are permitted
   - Applies to: Cities with population >5,000 in counties with population >70,000

3. **Senate Bill 382** (Montana Land Use Planning Act)
   - Requires qualifying municipalities to plan for housing needs

### Legal Timeline
- **May 2023:** Bills signed by Governor Gianforte
- **December 29, 2023:** Preliminary injunction issued (Gallatin County court)
- **January 1, 2024:** Intended effective date
- **March 3, 2025:** Montana court upholds reforms, injunction lifted

### Treatment Definition
- **Primary treatment:** January 1, 2024 for SB 528 (ADUs, statewide)
- **Note:** Injunction creates uncertainty December 2023 - March 2025; will model as intent-to-treat

---

## Empirical Strategy

### Primary Approach: Difference-in-Differences (DiD)

Compare Montana building permits to a synthetic control or matched control states before and after January 2024.

#### Treatment Group
- Montana (all counties/places for SB 528)
- Montana cities >5,000 population in counties >70,000 (for SB 323)

#### Control Group Options
1. **Synthetic Control:** Construct weighted combination of similar Western states (Wyoming, Idaho, North Dakota, South Dakota) that did not implement similar statewide zoning reforms
2. **Border Counties:** Counties in neighboring states bordering Montana (commuting zone spillovers)
3. **Mountain West states:** Similar housing market dynamics

#### Time Period
- **Pre-period:** January 2019 - December 2023 (5 years, avoiding COVID-specific months)
- **Post-period:** January 2024 - December 2025 (2 years)

### Secondary Approach: Event Study

Estimate dynamic treatment effects by year/quarter relative to reform:
- Test for parallel pre-trends (2019-2023)
- Trace out quarterly effects post-reform

### Robustness Checks
1. Placebo tests with fake treatment dates
2. Different donor pool compositions
3. Dropping COVID-affected months (March 2020 - December 2021)
4. Triple-difference using within-Montana variation (cities above/below 5,000 threshold)

---

## Data Sources

### Primary Outcome: Building Permits

**Census Bureau Building Permits Survey (BPS)**
- URL: https://www.census.gov/construction/bps/
- Granularity: State, county, place, monthly
- Variables: Total units authorized, single-family, multi-family (2-4 units, 5+ units)
- Format: Excel/CSV downloads

### Secondary Outcomes

1. **Housing Prices:** Zillow Home Value Index (ZHVI), monthly, state/county
2. **Rental Prices:** Zillow Observed Rent Index (ZORI), monthly
3. **Population/Migration:** Census ACS 1-year estimates

### Control Variables

1. **Economic conditions:** BLS unemployment rate (state monthly)
2. **Population:** Census population estimates
3. **Income:** BEA personal income (state quarterly)
4. **Interest rates:** Freddie Mac 30-year mortgage rate (national monthly)

---

## Model Specification

### Main DiD Model

$$Y_{st} = \alpha + \beta \cdot (Montana_s \times Post_t) + \gamma_s + \delta_t + X_{st}\theta + \varepsilon_{st}$$

Where:
- $Y_{st}$ = Building permits per capita in state $s$, month $t$
- $Montana_s$ = Indicator for Montana
- $Post_t$ = Indicator for $t \geq$ January 2024
- $\gamma_s$ = State fixed effects
- $\delta_t$ = Month-year fixed effects
- $X_{st}$ = Time-varying controls (unemployment, mortgage rates)
- $\beta$ = Treatment effect of interest

### Event Study Model

$$Y_{st} = \alpha + \sum_{k \neq -1} \beta_k \cdot Montana_s \times D_t^k + \gamma_s + \delta_t + X_{st}\theta + \varepsilon_{st}$$

Where $D_t^k$ are indicators for $k$ quarters relative to treatment (January 2024).

### Standard Errors
- Cluster at state level (conservative)
- Consider wild cluster bootstrap for small number of clusters

---

## Expected Results

### Hypotheses

**H1:** Montana building permits increase relative to control states after January 2024
- Expected sign: Positive
- Mechanism: Lower barriers to ADU/duplex construction

**H2:** Effects are larger for multi-family (2-4 unit) permits
- Expected sign: Positive, larger than single-family
- Mechanism: Duplex legalization directly affects 2-unit structures

**H3:** Effects may be delayed or muted during injunction period
- Expected pattern: Smaller effects Jan 2024 - Mar 2025, larger after March 2025

### Effect Size Expectations
- Based on Minneapolis ADU reform studies: 5-15% increase in permits
- Montana's more comprehensive reform may yield larger effects

---

## Threats to Identification

1. **COVID Recovery Dynamics:** Housing markets were disrupted 2020-2022; differential recovery patterns may confound
   - *Mitigation:* Pre-trend tests, event study, drop COVID months

2. **Interest Rate Changes:** Fed tightening 2022-2023 affected housing nationwide
   - *Mitigation:* Include mortgage rate controls, time fixed effects absorb national trends

3. **Other Montana-Specific Shocks:** Population growth, remote work migration
   - *Mitigation:* Include population controls, compare to similar Mountain West states

4. **Injunction Uncertainty:** Legal challenge may have deterred construction during litigation
   - *Mitigation:* Model as intent-to-treat; test for structural break at March 2025

5. **Permit ≠ Construction:** Permits authorized may not reflect actual building
   - *Mitigation:* Robustness check with housing starts data if available

---

## Output Plan

### Tables
1. Summary statistics (Montana vs. controls, pre vs. post)
2. Main DiD results
3. Event study coefficients
4. Robustness checks (different controls, donor pools)
5. Heterogeneity by permit type (SF vs. MF)

### Figures
1. Parallel trends plot (raw permits over time)
2. Event study coefficient plot
3. Synthetic control vs. actual Montana
4. Map of Montana municipalities affected by SB 323

---

## Timeline

1. **Data Collection:** Download BPS, Zillow, BLS data
2. **Data Cleaning:** Merge, standardize, calculate per capita rates
3. **Descriptive Analysis:** Summary statistics, raw trends
4. **Main Analysis:** DiD, event study, synthetic control
5. **Robustness:** Placebo tests, alternative specifications
6. **Writing:** Full paper draft
7. **Review:** Internal and external review rounds

---

## Contingency

If building permits data shows insufficient variation or sample size issues:
- **Backup Plan A:** Pivot to Vermont Universal School Meals (Idea 2)
- **Backup Plan B:** Expand Montana analysis to include housing prices as primary outcome
