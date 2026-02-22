# Initial Research Plan: apep_0441

## Research Question

Does political decentralization through state creation accelerate economic development? India's 2000 trifurcation—creating Uttarakhand, Jharkhand, and Chhattisgarh from Uttar Pradesh, Bihar, and Madhya Pradesh—provides a natural experiment with 23 years of post-treatment satellite data. We test whether districts in newly created states experienced faster economic growth than districts remaining in parent states, and whether any gains were spatially concentrated near new state capitals.

## Identification Strategy

**Primary: Staggered DiD at the district level**

- Treatment group: Districts assigned to newly created states
  - 2000 cohort: 55 districts (13 Uttarakhand + 24 Jharkhand + 18 Chhattisgarh)
  - 2014 cohort: 10 Telangana districts (extension analysis)
- Control group: Remaining districts in parent states (71 UP + 38 Bihar + 50 MP = 159)
- Pre-period: DMSP nightlights 1994–1999 (6 years); Census 1991/2001
- Post-period: DMSP 2001–2013 + VIIRS 2014–2023
- Treatment timing: First full-exposure post year = 2001 for 2000 cohort; 2015 for 2014 cohort
- Estimator: Callaway-Sant'Anna for heterogeneity-robust group-time ATTs
- Clustering: State level (8 clusters for 2000 cohort) → wild cluster bootstrap + randomization inference

**Co-primary: Border discontinuity design**

- Compare sub-districts/villages within 50km of the new state boundary on either side
- Eliminates concerns about baseline differences between mountain/plain, mineral/agricultural regions
- Provides geographically tight counterfactual

## Expected Effects and Mechanisms

**Ex ante predictions (before seeing data):**

1. **New state capital effect (+):** Districts hosting new capitals (Dehradun, Ranchi, Raipur) should see concentrated growth from government spending, bureaucratic employment, and agglomeration
2. **Administrative proximity (+):** Closer district headquarters to state capital → faster service delivery, more responsive governance
3. **Resource reallocation (±):** New states inherited fiscal transfers but lost cross-subsidy from wealthier regions of parent state. Net effect ambiguous.
4. **Mineral resource curse (−):** Jharkhand and Chhattisgarh inherited mineral wealth but may suffer Dutch disease / governance capture

**This paper is valuable regardless of sign.** A positive average effect validates decentralization advocates. A null or negative effect (or heterogeneity showing only capitals benefit) challenges the "smaller states = better governance" narrative.

## Primary Specification

```
log(nightlights_{d,t} + 1) = α_d + γ_t + β * NewState_{d} × Post_{t} + ε_{d,t}
```

Where:
- d indexes districts, t indexes years
- α_d = district fixed effects
- γ_t = year fixed effects
- NewState_d = 1 if district assigned to new state
- Post_t = 1 if t ≥ 2001 (first full-exposure year)
- Cluster SE at state level with wild bootstrap

For CS-DiD:
```
ATT(g,t) via Callaway-Sant'Anna
g ∈ {2001, 2015} (group = first full-exposure year)
```

## Exposure Alignment (DiD-specific)

- **Who is actually treated?** Districts in newly created states receive new state government, capital infrastructure, dedicated fiscal transfers
- **Primary estimand population:** All districts in treatment states
- **Placebo/control population:** Districts in parent states that were NOT reassigned
- **Design:** DiD (primary) + Border RD (co-primary)

## Power Assessment

- Pre-treatment periods: 6 (DMSP 1994–1999) — exceeds minimum of 5
- Treated clusters: 3 states (2000 cohort) + 1 state (2014 cohort) = 4 state-level clusters
- Treated districts: 55 (2000) + 10 (2014) = 65 total — exceeds 20
- Post-treatment periods: 13 (DMSP) + 9 (VIIRS extension) = 22 per cohort
- Few-clusters concern: Only 8 state-level clusters → RI mandatory
- MDE: With 214 district-year observations per year and nightlight variation, detectable effects on the order of 10-15% changes in luminosity

## Planned Robustness Checks

1. **Pre-trends:** Event study plot with pre-treatment coefficients; HonestDiD sensitivity bounds
2. **Wild cluster bootstrap:** fwildclusterboot for few-cluster inference
3. **Randomization inference:** Permute treatment across states (2000 cohort: permute which 3 of 6 states are "new")
4. **Alternative estimators:** Sun-Abraham, TWFE (for comparison), synthetic DiD
5. **Border RD:** Restrict to districts within 50km of new state boundaries
6. **Placebo treatments:** Assign fake state creation in 1997 (3 years before actual)
7. **Capital city heterogeneity:** Separate effects for capital vs non-capital districts
8. **Mineral wealth heterogeneity:** Interact treatment with baseline mineral production
9. **VIIRS extension:** Calibrated DMSP-VIIRS panel through 2023 for long-run dynamics
10. **Census outcomes:** Worker composition, literacy, amenities (2001 vs 2011)
