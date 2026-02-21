# Initial Research Plan: MGNREGA and Structural Transformation

## Research Question

Did India's Mahatma Gandhi National Rural Employment Guarantee Act (MGNREGA) accelerate or retard the structural transformation of rural labor markets from agricultural to non-agricultural employment?

## Identification Strategy

**Design:** Staggered Difference-in-Differences exploiting MGNREGA's three-phase rollout.

- **Phase I** (Feb 2006): 200 districts selected based on Planning Commission Backwardness Index
- **Phase II** (Apr 2007): 130 additional districts
- **Phase III** (Apr 2008): All remaining ~310 rural districts

**Estimator:** Callaway & Sant'Anna (2021) group-time ATT, aggregated to overall ATT. This avoids the well-documented bias of TWFE in staggered settings with heterogeneous treatment effects.

**Unit of analysis:** District × Census year (primary), with village-level analysis for robustness. District-level nightlights panel provides annual variation for event study plots.

**Clustering:** State level (28+ clusters for Phase I districts across India).

## Exposure Alignment

- **Who is treated:** All rural households in treated districts gain access to 100 days of guaranteed manual employment at minimum wage.
- **Primary estimand:** Effect on worker composition (structural transformation) in treated districts relative to not-yet-treated districts.
- **Placebo population:** Urban areas within treated districts (MGNREGA covers rural areas only); pre-treatment Census periods.
- **Design:** Standard two-group staggered DiD with three cohorts.

## Expected Effects and Mechanisms

**Theoretical ambiguity** is central to this paper. Two opposing channels:

1. **Demand stimulus (pro-transformation):** MGNREGA raises rural incomes → increased demand for non-farm goods and services (retail, transport, repair, food processing) → encourages non-farm enterprise entry and employment.

2. **Labor cost shock (anti-transformation):** MGNREGA raises the reservation wage for unskilled labor → increases costs for non-farm firms → discourages non-farm enterprise entry, may push marginal firms out.

The net effect is an empirical question. The sign of the structural transformation effect is genuinely unknown.

**Additional mechanisms:**
- Agricultural intensification: higher wages may push cultivators toward capital-intensive farming, reducing cultivator counts
- Female empowerment: 33% women's quota may shift female workers from unpaid family labor to counted employment categories
- Proletarianization: cultivators may sell land and become wage laborers (either agricultural or non-agricultural)

## Primary Specification

```
Y_{d,t} = α + β × MGNREGA_{d,t} + γ_d + δ_t + ε_{d,t}
```

Where:
- Y = non-farm worker share (main_hh + main_ot) / total_main_workers, at district level
- MGNREGA_{d,t} = 1 if district d has received MGNREGA by Census year t
- γ_d = district fixed effects
- δ_t = Census year fixed effects
- Clustering at state level

**CS-DiD implementation:** Callaway & Sant'Anna with:
- Group variable: MGNREGA phase assignment (2006, 2007, 2008)
- Time periods: Census 1991, 2001, 2011 (village aggregated to district)
- Outcomes: Non-farm share, cultivator share, ag laborer share, nightlights

## Planned Robustness Checks

1. **Pre-trend validation:** Census 1991→2001 changes in worker composition across phase groups
2. **Event study:** Annual nightlights at district level, 1994-2013 (DMSP) and 2012-2023 (VIIRS)
3. **Alternative estimators:** Sun & Abraham (2021), de Chaisemartin & d'Haultfoeuille (2020)
4. **Placebo:** Urban areas within treated districts (MGNREGA is rural only)
5. **Heterogeneity:** By baseline development level, SC/ST concentration, female LFP
6. **Dose-response:** MGNREGA expenditure intensity as continuous treatment
7. **Village-level analysis:** Direct village-level DiD using SHRUG (~640K observations)
8. **Randomization inference:** Permute treatment assignment across districts for p-values

## Power Assessment

- **Pre-treatment periods:** 2 Census years (1991, 2001) + 12 annual nightlights years (1994-2005)
- **Treated clusters:** ~200 districts (Phase I), ~130 (Phase II), ~310 (Phase III) — well above 20-district minimum
- **Post-treatment periods:** Census 2011 (3-5 years post for all phases), nightlights through 2023
- **MDE:** With 640+ districts and 3 Census waves, detectable effects < 1 percentage point in non-farm worker share. Massively powered.

## Data Sources

| Data | Source | Level | Years |
|------|--------|-------|-------|
| Census PCA | SHRUG (local) | Village → District | 1991, 2001, 2011 |
| Nightlights DMSP | SHRUG (local) | District (annual) | 1994-2013 |
| Nightlights VIIRS | SHRUG (local) | District (annual) | 2012-2023 |
| MGNREGA phase dates | Published literature + MoRD | District | 2006-2008 |
| Geographic crosswalk | SHRUG (local) | SHRID → District → State | - |

## Paper Structure

1. Introduction: The structural transformation puzzle + MGNREGA's potential role
2. Background: MGNREGA design, phased rollout, existing literature
3. Data: SHRUG Census panel, nightlights, MGNREGA phase assignment
4. Empirical Strategy: CS-DiD, identification assumptions, pre-trend tests
5. Results: Main effects on worker composition, event study dynamics
6. Mechanisms: Demand vs. cost channels, gender decomposition
7. Robustness: Alternative estimators, placebos, heterogeneity
8. Conclusion: Policy implications for employment guarantee programs worldwide
