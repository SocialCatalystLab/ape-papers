# Initial Research Plan: Where Medicaid Goes Dark

## Research Question

Does the loss of Medicaid beneficiaries during enrollment unwinding cause providers to exit the Medicaid market, deepening specialty-specific provider deserts? More broadly: what does the true geography of Medicaid provider access look like when measured through claims rather than registries?

## Identification Strategy

**Staggered Difference-in-Differences** using state-level variation in Medicaid enrollment unwinding timing and intensity (April 2023 onward).

- **Treatment:** State-specific unwinding intensity, measured as cumulative net disenrollment rate (beneficiaries lost / peak enrollment) by quarter. States vary from ~1% (Maine) to ~30% (Colorado) net loss, with staggered start dates.
- **Unit of observation:** County × specialty × quarter (2018Q1 – 2024Q3)
- **Outcome:** Number of active Medicaid providers per 10,000 population (providers with ≥4 claims/quarter, to avoid billing artifacts)
- **Estimator:** Callaway & Sant'Anna (2021) for group-time ATT with staggered adoption; continuous treatment variant using disenrollment intensity
- **Pre-period:** 2018Q1 – 2023Q1 (20 quarters)
- **Post-period:** 2023Q2 – 2024Q3 (6 quarters)

### Exposure Alignment

- **Who is treated:** Medicaid providers in states that disenroll beneficiaries aggressively
- **Primary estimand:** Change in active provider counts in county × specialty cells
- **Mechanism:** Demand shock → fewer Medicaid patients → providers drop Medicaid panel or relocate
- **Control population:** Providers in states that are slow to disenroll (later treated or cautious approach)

### Power Assessment

- **Pre-treatment periods:** 20 quarters (2018Q1 – 2023Q1) ✓
- **Treated clusters:** 50 states (all eventually treated, staggered) ✓
- **Post-treatment periods:** 6 quarters per early-treated cohort ✓
- **County × specialty cells:** ~3,200 counties × 7 specialties × 27 quarters ≈ 600K+ observations
- **Identifying variation:** State-level disenrollment timing and intensity

## Expected Effects and Mechanisms

1. **Primary hypothesis:** Counties in states with aggressive unwinding (high/fast disenrollment) will see larger declines in active Medicaid provider counts, particularly in already-thin specialties (psychiatry, OB-GYN).

2. **Heterogeneity:**
   - Urban vs. rural: Rural counties with already-thin provider networks are more vulnerable
   - Specialty: Psychiatry and OB-GYN (already declining 30%+) should be most affected
   - Desert vs. non-desert: Counties already at desert thresholds may tip into complete absence

3. **Mechanisms:**
   - Demand channel: Fewer Medicaid patients → provider exits
   - NP/PA substitution: NPs may partially fill MD exits, especially in FPA states
   - Geographic reallocation: Providers may consolidate to urban centers

## Primary Specification

```
Y_{cst} = β × Unwinding_Intensity_{st} + α_cs + γ_t + X_{ct}δ + ε_{cst}

where:
  Y = active providers per 10,000 pop in county c, specialty s, quarter t
  Unwinding_Intensity = cumulative net disenrollment rate in state of county c, quarter t
  α_cs = county × specialty fixed effects
  γ_t = quarter fixed effects
  X_ct = time-varying county controls (population, unemployment)
  Clustered SEs at state level
```

For event study: CS-DiD with cohorts defined by state unwinding start quarter.

## Planned Robustness Checks

1. **Alternative outcome definitions:**
   - Active = ≥1 claim/quarter (loose) vs. ≥4 claims/quarter (strict) vs. ≥12 claims/quarter (full-time)
   - Extensive margin (any provider? 0/1 desert indicator) vs. intensive margin (provider count)
   - Beneficiaries served per provider (utilization intensity)

2. **Alternative treatment definitions:**
   - Binary: early unwinders (2023Q2) vs. late unwinders (2023Q4+)
   - Continuous: net disenrollment rate
   - Procedural: share of disenrollments that are procedural (proxy for aggressiveness)

3. **Threats to identification:**
   - Pre-trend test: event-study coefficients should be zero pre-2023Q2
   - MCO encounter reporting changes: test with FFS-only subsample
   - Contemporaneous policies: control for ARPA HCBS spending, Medicaid expansion status
   - Provider migration vs. exit: compare NPI deactivation vs. billing cessation

4. **Inference:**
   - Wild cluster bootstrap (50 state clusters)
   - Permutation inference (randomize treatment timing across states)

## Data Sources

| Source | Variables | Access |
|--------|-----------|--------|
| T-MSIS (local parquet) | Provider billing, HCPCS codes, claims, paid | Local file |
| NPPES extract (local parquet) | Provider location, specialty, entry/exit dates | Local file |
| Census ZCTA-county crosswalk | ZIP5 → county FIPS | Downloaded |
| Census ACS 5-year | County population, demographics | API (CENSUS_API_KEY) |
| KFF Unwinding Tracker | State disenrollment timing, rates | Web scrape/manual |
| CMS monthly enrollment | State Medicaid enrollment by month | Public download |
| Census TIGER/Line | County shapefiles for mapping | Public download |
| USDA Rural-Urban Codes | Urban/rural county classification | Public download |
| HRSA HPSA | Existing shortage area designations | Public download |

## Paper Structure (Target: 28-30 pages)

1. **Introduction** (3 pp): Medical deserts hook → policy relevance → what we do → key findings
2. **Background** (3 pp): Medicaid provider access literature, unwinding context, HPSA limitations
3. **Data** (4 pp): T-MSIS + NPPES construction, panel building, desert definitions, comparison with HPSA
4. **The Atlas** (5 pp): Descriptive maps and trends — specialty deserts, urban-rural gradient, entry/exit dynamics
5. **Empirical Strategy** (3 pp): Staggered DiD, identification assumptions, threats
6. **Results** (5 pp): Main effects, event studies, heterogeneity by specialty and geography
7. **Mechanisms** (3 pp): NP substitution, geographic reallocation, provider vs. billing exit
8. **Conclusion** (2 pp): Policy implications, limitations, future work
9. **References + Appendix** (tables, figures, additional maps)
