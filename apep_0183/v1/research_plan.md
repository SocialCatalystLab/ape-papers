# Initial Research Plan: Marijuana Legalization and Labor Market Equilibria

**Paper ID:** 167
**Date:** 2026-02-04
**Contributor:** @SocialCatalystLab

## Research Question

Does recreational marijuana legalization affect local labor market outcomes? Specifically:
1. What is the average effect on employment, hiring, and wages at the state border?
2. Do effects vary across industries based on (a) direct cannabis exposure, (b) drug testing prevalence?
3. Are there anticipation effects between election and retail opening?
4. Are placebos centered at zero, validating the spatial design?

## Policy Context

**Treatment:** Recreational marijuana legalization (RML) with retail sales

**Treated States and Retail Opening Dates:**
| State | Retail Opening | FIPS |
|-------|----------------|------|
| Colorado | 2014-01-01 | 08 |
| Washington | 2014-07-08 | 53 |
| Oregon | 2015-10-01 | 41 |
| Nevada | 2017-07-01 | 32 |
| California | 2018-01-01 | 06 |
| Massachusetts | 2018-11-20 | 25 |
| Michigan | 2019-12-01 | 26 |
| Illinois | 2020-01-01 | 17 |

**Control States:** All contiguous states without RML during sample period:
- Western: AZ, NM, UT, ID, WY, KS, NE, OK, TX
- Eastern: CT, RI, NH, VT (pre-legalization), NY (pre-legalization), IN, OH, WI, IA, KY, MO

## Theoretical Framework

### Model: Labor Market with Marijuana Access

Consider a local labor market (commuting zone or border region) with:
- Labor supply: L^s(w, θ) where θ = marijuana accessibility
- Labor demand: L^d(w, π) where π = productivity/cost shifters

**Legalization affects both sides:**

**Supply shifts:**
- (+) Opioid substitution → reduced disability → increased labor supply
- (+) Relaxed sorting constraint → workers no longer avoid testing industries
- (-) Increased consumption → possible reduction in work capacity

**Demand shifts:**
- (+) New industry creation → cannabis jobs in agriculture, retail
- (+) Expanded hiring pool → firms can hire previously-excluded users
- (-) Productivity concerns → some employers may reduce hiring

**Equilibrium predictions by industry:**

| Industry | Direct Effect | Testing Channel | Net Prediction |
|----------|---------------|-----------------|----------------|
| Agriculture (11) | Strong + (cultivation) | Low testing | Strong + |
| Retail (44-45) | Moderate + (dispensaries) | Low testing | Moderate + |
| Accommodation/Food (72) | Moderate + (tourism) | Low testing | Moderate + |
| Transportation (48-49) | None | DOT mandate | Null or - |
| Manufacturing (31-33) | None | Safety testing | Null |
| Professional (54) | None | No testing | Null |
| Finance (52) | None | Banking restrictions | Null |

## Identification Strategy

### Primary: Difference-in-Discontinuities (DiDisc)

**Unit of analysis:** County × quarter × industry

**Running variable:** Signed distance from county centroid to nearest treated/control state border
- Positive for counties in treated state
- Negative for counties in control state
- Calculated using sf::st_distance() on TIGER/Line shapefiles

**Specification:**
```
log(Y_{cist}) = α + β₁·Treated_{s} + β₂·Post_{t} + τ·(Treated_{s} × Post_{t})
              + f(Distance_{c}) + f(Distance_{c}) × Post_{t}
              + γ·(Treated_{s} × f(Distance_{c})) + δ·(Treated_{s} × f(Distance_{c}) × Post_{t})
              + μ_{b} + λ_{t} + ε_{cist}
```

Where:
- τ = DiDisc treatment effect (change in discontinuity)
- f(·) = local linear or quadratic polynomial
- μ_{b} = border-pair fixed effects
- λ_{t} = quarter fixed effects

**Key identifying assumption:** The change in the discontinuity at the border at treatment onset is attributable to legalization, not other factors.

### Diagnostic: Temporal Placebos

For each border, estimate the "discontinuity" in each pre-treatment quarter:
```
τ̂_{t} for t ∈ {t₀-20, ..., t₀-1}
```

**Validity test:** Joint F-test that all τ̂_{t} = 0 for t < t₀

If placebos fail (significant pre-existing discontinuity changes), the DiDisc design is invalidated for that border.

### Event Study

Estimate event-time coefficients relative to retail opening:
```
log(Y_{cist}) = Σ_{e=-8}^{+16} τ_{e} · 1[t - t₀ = e] × Treated_{s} × f(Distance_{c}) + ...
```

Allows visualization of:
- Pre-trends (should be flat)
- Anticipation effects (election to retail period)
- Dynamic treatment effects (post-retail)

## Data

### Primary: Census QWI (County × Quarter × Industry)

**API:** api.census.gov/data/timeseries/qwi/se

**Variables:**
- EarnHirAS: Average monthly earnings of stable new hires
- Emp: Total employment
- HirA: Total hires
- EarnS: Average monthly earnings

**Coverage:** 2005-2023, all states, NAICS 2-digit industries

**Unit:** County × quarter × sex × industry

### Geographic: TIGER/Line Shapefiles

**Source:** tigris R package

**Variables:**
- County boundaries (for centroid calculation)
- State boundaries (for distance to border)

### Commuting Zones: David Dorn Crosswalk

**Source:** ddorn.net/data.htm, file E7 (cw_cty_czone.zip)

**Use:** Identify cross-border CZs for spillover analysis

## Pre-Specified Industry Groups

To avoid multiple testing issues, we pre-specify 4 groups:

1. **Direct Cannabis** (expected strong +):
   - Agriculture (11)
   - Retail Trade (44-45)

2. **DOT-Regulated** (expected null/-):
   - Transportation (48-49)

3. **Safety-Sensitive** (expected ambiguous):
   - Manufacturing (31-33)
   - Construction (23)

4. **Low-Testing Services** (expected null):
   - Professional Services (54)
   - Finance (52)
   - Information (51)
   - Accommodation/Food (72) - also tourism exposure

All other industries are exploratory with FDR correction.

## Expected Results

### Main Effects
- Aggregate effect: small positive (1-3%) if any
- Industry heterogeneity: strong positive in agriculture/retail, null in transportation

### Placebos
- Possible failure: CA-AZ border has large pre-existing wage gap
- If placebos fail for some borders, exclude those borders and document

### Mechanisms
- If agriculture/retail effects dominate: direct job creation mechanism
- If DOT industries show negative effects: productivity concern mechanism
- If null across all industries: legalization doesn't affect labor markets

## Robustness Checks

1. **Bandwidth sensitivity:** 25km, 50km, 100km, 150km
2. **Polynomial order:** Linear, quadratic
3. **Exclude cross-border CZs:** Remove spillover contamination
4. **Event study by cohort:** Heterogeneity across early vs late adopters
5. **Placebo outcomes:** Weather, elections (should show no discontinuity change)
6. **Leave-one-border-out:** Sensitivity to individual borders

## Power Analysis

**Sample size (estimated):**
- ~100 border counties within 100km bandwidth per border pair
- 8 border pairs (conservative)
- 36 quarters (2014-2023)
- ~28,800 county-quarter observations

**MDE calculation:**
- With σ = 0.15 (log earnings SD), α = 0.05, power = 0.80
- MDE ≈ 2.5% for aggregate effect
- Industry-specific MDE larger (~5%) due to fewer observations

## Timeline

1. **Data acquisition:** Fetch QWI, shapefiles, CZ crosswalk
2. **Geographic processing:** Calculate distances, identify border counties
3. **Main analysis:** DiDisc estimation, event study
4. **Robustness:** Placebos, bandwidth sensitivity, industry heterogeneity
5. **Paper writing:** Results, interpretation, limitations
