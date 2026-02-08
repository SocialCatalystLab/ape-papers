# Initial Research Plan: The Nitrogen Shock and Dutch Housing Markets

## Research Question

Did the May 2019 Dutch nitrogen ruling (stikstofcrisis) cause housing price increases and construction declines in areas near Natura 2000 protected areas, and how did these supply shocks propagate through local housing markets?

## Policy Background

On May 29, 2019, the Administrative Jurisdiction Division of the Dutch Council of State (Raad van State) ruled that the government's Integrated Approach to Nitrogen (Programma Aanpak Stikstof, PAS) was invalid under EU Habitats Directive requirements. This ruling:

1. Immediately suspended ~18,000 construction permits near Natura 2000 areas
2. Required new environmental assessments for any projects with nitrogen emissions
3. Created a "nitrogen lock" affecting construction within approximately 5km of protected areas
4. Was largely unanticipated by markets (the PAS had been operational since 2015)

## Identification Strategy

### Primary Design: Spatial Difference-in-Differences

**Treatment intensity:** Distance from municipality centroid to nearest Natura 2000 boundary
- Municipalities within 5km buffer: High treatment
- Municipalities 5-15km: Medium treatment
- Municipalities >15km: Low/no treatment

**Pre-treatment period:** 2015-2019Q1 (PAS operational, permits flowing)
**Post-treatment period:** 2019Q2-2023 (nitrogen lock in effect)

**Estimation equation:**
```
Y_{mt} = β₁(Near_m × Post_t) + β₂(Medium_m × Post_t) + α_m + γ_t + ε_{mt}
```

Where:
- Y = housing prices, construction permits, or completions
- Near_m = municipality within 5km of Natura 2000
- Medium_m = municipality 5-15km from Natura 2000
- α_m = municipality fixed effects
- γ_t = time fixed effects

### Secondary Design: Spatial RDD at Natura 2000 Boundaries

For municipalities that straddle or abut Natura 2000 boundaries:
- Running variable: Signed distance to Natura 2000 boundary
- Compare areas just inside affected zone vs. just outside
- Sharp treatment at 0 distance

## Expected Effects and Mechanisms

### Predictions

1. **Housing prices:** Increase in affected areas due to supply constraint
   - Expected: +3-8% relative increase in high-treatment municipalities
   - Mechanism: Reduced new supply → scarcity premium

2. **Construction permits:** Sharp decline post-ruling
   - Expected: -30-50% in permits within 5km of Natura 2000
   - Mechanism: Direct regulatory constraint

3. **Spatial displacement:** Increase in development outside affected zones
   - Expected: Spillover to medium/low treatment areas
   - Mechanism: Developers shift to permitted locations

4. **Heterogeneity:**
   - Larger effects where Natura 2000 covers larger share of buildable land
   - Larger effects in high-demand housing markets (Randstad)
   - Smaller effects where vacancy is high

## Primary Specification

**Outcome variables:**
1. Log housing price index (CBS Prijsindex bestaande koopwoningen)
2. Construction permits issued (bouwvergunningen)
3. Housing completions (opgeleverde woningen)
4. Rental price indices (where available)

**Treatment variables:**
1. Continuous: Distance to nearest Natura 2000 (km)
2. Binary: Within 5km buffer (yes/no)
3. Intensity: Share of municipality area in nitrogen-affected zone

**Controls:**
- Municipality population
- Pre-existing housing stock
- Historical construction activity
- Distance to major employment centers

## Planned Robustness Checks

1. **Parallel trends:** Event study design with leads and lags
2. **Placebo boundaries:** Fake treatment at arbitrary distances
3. **Alternative cutoffs:** 3km, 7km, 10km buffers
4. **Callaway-Sant'Anna:** Robust DiD for staggered effects
5. **Permutation inference:** Randomize treatment assignment

## Data Requirements

### Primary Data Sources

1. **CBS StatLine (Public API)**
   - Housing price indices: 83625NED, 83647NED
   - Construction permits: 83673NED
   - Housing stock: 81955ENG
   - Municipality-level aggregates

2. **Natura 2000 GIS Data**
   - European Environment Agency or Rijkswaterstaat
   - Shapefile of all 161 Dutch Natura 2000 areas

3. **Municipality Boundaries**
   - CBS Wijk- en buurtkaart
   - Centroids for distance calculations

### Derived Variables

- Distance from each municipality to nearest Natura 2000
- Share of municipality area within various buffer distances
- Pre-period average construction activity (for parallel trends)

## Timeline

1. Week 1: Data acquisition and cleaning
   - Fetch CBS data via API
   - Download and process Natura 2000 shapefiles
   - Compute distance measures

2. Week 2: Descriptive analysis
   - Pre-trend comparisons
   - Event study plots
   - Summary statistics

3. Week 3: Main estimation
   - DiD regressions
   - Spatial RDD (if boundary data permits)
   - Heterogeneity analysis

4. Week 4: Robustness and writing
   - Specification tests
   - Draft paper

## Key Assumptions

1. **No anticipation:** Markets did not anticipate May 2019 ruling
   - Support: Ruling was on long-pending case; PAS had been operational since 2015

2. **Parallel trends:** Treatment and control municipalities would have evolved similarly absent the shock
   - Test: Event study with pre-treatment periods

3. **No other shocks:** No confounding policies at exact same time
   - Risk: COVID-19 arrives in 2020; need to either truncate sample or control

4. **SUTVA:** One municipality's treatment doesn't affect another's outcomes
   - Challenge: Spatial spillovers are exactly what we expect to measure
