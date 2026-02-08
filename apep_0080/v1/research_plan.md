# Initial Research Plan

**Paper:** Click It or Ticket at the Border: A Spatial Regression Discontinuity Analysis of Primary Seatbelt Enforcement Laws

**Date:** 2026-01-29

---

## Research Question

Do primary seatbelt enforcement laws—which allow police to stop and cite drivers solely for not wearing a seatbelt—reduce traffic fatalities? We exploit the sharp geographic discontinuity at state borders where enforcement type changes to estimate causal effects using spatial regression discontinuity design (Spatial RDD).

---

## Economic Model

### Theoretical Framework

Primary enforcement increases the expected cost of non-compliance:

$$E[C_{non-compliance}] = p \cdot F$$

where $p$ is the probability of citation and $F$ is the fine.

Under secondary enforcement, $p \approx 0$ unless another violation occurs first. Under primary enforcement, $p > 0$ even for otherwise law-abiding drivers.

**Behavioral prediction:** Higher $E[C]$ → higher seatbelt wearing rate → conditional on crash, lower probability of fatal injury.

### Key Mechanism: Compliance → Survival

Seatbelt laws do NOT prevent crashes. They reduce fatality conditional on crash:

$$P(death) = P(crash) \times P(death|crash)$$

Primary enforcement affects only the second term by increasing seatbelt use at time of crash.

### Testable Implications

1. **Effect on crash rate:** Should be ZERO (seatbelts don't prevent crashes)
2. **Effect on fatality|crash:** Should be NEGATIVE (seatbelts save lives)
3. **Effect on ejection deaths:** Should be LARGE negative (seatbelts prevent ejection)
4. **Effect on pedestrian deaths:** Should be ZERO (seatbelts don't help pedestrians)
5. **Residents vs. non-residents:** Residents should show larger effects (formed habits under local law)

---

## Identification Strategy

### Spatial Regression Discontinuity Design

**Treatment:** Crash occurred in a state with primary seatbelt enforcement (vs. secondary)

**Running variable:** Road network distance from crash location to nearest primary/secondary enforcement state border

**Cutoff:** 0 (the state border)

**Outcome:** Probability of fatality per person in crash

### Key Assumptions

1. **Continuity:** Potential outcomes are continuous at the border
   - Validated by balance tests on covariates

2. **No precise manipulation:** Crashes cannot be precisely sorted to one side of border
   - Crashes are not chosen locations; placebo density test

3. **Local treatment effect:** Effect applies to crashes near the border
   - Extrapolation to interior is separate question

### Variation Exploited

35 states have adopted primary enforcement at different times (1993-2023), creating:
- **Cross-sectional variation:** ~15 primary vs. secondary borders at any given time
- **Temporal variation:** Borders "activate" as states switch from secondary to primary
- **Placebo power:** Pre-adoption years at borders that later switch

---

## Expected Effects

Based on prior DiD literature (Cohen & Einav 2003), primary enforcement reduces fatalities by 5-9%.

At the border, we expect:
- **Main effect:** 5-10% lower fatality probability on primary side
- **Mechanism:** Effect concentrated in ejection deaths
- **Heterogeneity:** Larger effects for single-occupant vehicles (driver behavior)

---

## Primary Specification

### Main Estimating Equation

For crash $i$ at distance $d_i$ from border $b$ in year $t$:

$$Y_{ibt} = \alpha + \tau \cdot Primary_{ibt} + f(d_i) + \gamma_b + \delta_t + \epsilon_{ibt}$$

where:
- $Y_{ibt}$ = fatality probability (deaths / persons in crash)
- $Primary_{ibt}$ = 1 if crash in primary enforcement state
- $f(d_i)$ = flexible function of distance (local linear, quadratic)
- $\gamma_b$ = border-segment fixed effects
- $\delta_t$ = year fixed effects

### Bandwidth Selection

Use `rdrobust` MSE-optimal bandwidth selection, with robustness to:
- 50%, 75%, 150%, 200% of optimal bandwidth
- Different polynomial orders (1, 2, 3)

### Standard Errors

Clustered at border-segment × year level. Robustness with:
- Conley (1999) spatial HAC standard errors
- Wild cluster bootstrap

---

## Planned Robustness Checks

### A. Identification Validity

1. **Covariate balance:** Road type, weather, time of day, driver demographics smooth at border
2. **Density test:** McCrary (2008) test for bunching at border
3. **Placebo borders:** RDD at borders where both states have same enforcement type → expect null
4. **Pre-treatment placebo:** RDD in years before adoption for borders that later switch → expect null
5. **Donut RD:** Exclude crashes within 1km, 2km, 5km of border

### B. Specification Robustness

6. **Bandwidth sensitivity:** Plot effect across range of bandwidths
7. **Polynomial order:** Local linear vs. quadratic vs. cubic
8. **Kernel choice:** Triangular vs. uniform vs. Epanechnikov
9. **Distance metric:** Road distance vs. Euclidean distance

### C. Heterogeneity & Mechanisms

10. **By crash type:** Single-vehicle, multi-vehicle, rollover
11. **By injury mechanism:** Ejection, non-ejection
12. **By occupant type:** Driver, passenger, pedestrian (placebo)
13. **By driver residence:** In-state vs. out-of-state license
14. **By time:** Day vs. night, weekday vs. weekend
15. **By road type:** Interstate, US highway, state highway, local

### D. Alternative Outcomes

16. **Fatalities per crash** (instead of probability)
17. **Serious injuries** (if data available)
18. **Crash rate per VMT** (using HPMS data) → should be null

---

## Data Sources

### Primary Data

1. **FARS (Fatality Analysis Reporting System)**, NHTSA
   - Years: 1990-2020
   - Unit: Individual fatal crashes with lat/long coordinates
   - Files: Accident, Person, Vehicle
   - Access: FTP (1975-2020), API (2010+)

2. **Census TIGER/Line Shapefiles**
   - State boundaries for border identification
   - Road network for distance calculations

3. **OpenStreetMap/TIGER Roads**
   - Road network for computing road distance to border

### Policy Data

4. **IIHS State Law Database**
   - Primary vs. secondary enforcement status by state-year
   - Effective dates for each state

### Supplementary Data

5. **HPMS (Highway Performance Monitoring System)**
   - VMT by road segment for denominator robustness

6. **American Community Survey**
   - County demographics for balance tests

---

## Visual Elements (High Impact)

### Maps

1. **National map of enforcement types** showing primary (green) vs. secondary (red) states with major crash-density borders highlighted

2. **Border detail maps** for key borders (e.g., NC-VA, WA-ID) showing crash locations colored by outcome

3. **Before/after maps** showing treatment effect emergence at borders that switch

### RDD Plots

4. **Main RDD plot:** Fatality probability by distance to border, pooled across all borders

5. **Individual border RDDs:** Separate plots for each major border

6. **Bandwidth sensitivity plot:** Effect estimate vs. bandwidth

7. **Placebo RDD plot:** Same design for pedestrian fatalities (should be null)

### Mechanism Figures

8. **Effect decomposition:** Bar chart showing effect for ejection vs. non-ejection deaths

9. **Event study:** Effect at border counties by year relative to adoption

10. **Heterogeneity forest plot:** Effects by subgroup

---

## Code Structure

```
output/paper_107/code/
├── 00_packages.R          # Load libraries, set ggplot theme
├── 01_fetch_data.R        # Download FARS, TIGER, IIHS data
├── 02_clean_data.R        # Merge, compute distance to border
├── 03_main_analysis.R     # Primary RDD estimation
├── 04_robustness.R        # All robustness checks
├── 05_figures.R           # Generate all figures
├── 06_tables.R            # Generate all tables
└── 07_spatial_prep.R      # GIS operations for maps
```

---

## Timeline & Checkpoints

1. **Data acquisition:** Fetch FARS, verify lat/long coverage
2. **GIS setup:** Compute road distances to all relevant borders
3. **Descriptive analysis:** Summary stats, basic maps
4. **Main estimation:** Run primary RDD specification
5. **Robustness:** Execute all planned checks
6. **Visualization:** Generate publication-quality figures
7. **Writing:** Draft full paper

---

## Risks & Mitigations

| Risk | Probability | Mitigation |
|------|-------------|------------|
| FARS lat/long missing pre-2000 | Medium | Focus on 2000-2020; note limitation |
| Few crashes near some borders | Medium | Pool across borders; report individual border estimates |
| Road distance computation slow | Low | Use efficient routing (sfnetworks, dodgr) |
| Sorting at borders | Low | Donut RD, balance tests, density test |
| Null result | Medium | Report confidently; null is informative |
