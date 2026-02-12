# Initial Research Plan: apep_0232

## Title
Licensing to Log In: The Interstate Medical Licensure Compact and the Virtual Expansion of Healthcare Supply

## Research Question
Did the Interstate Medical Licensure Compact (IMLC) increase healthcare supply by enabling physicians to practice across state lines — and did these gains flow disproportionately to underserved areas?

## Motivation
The IMLC, adopted by 42 US states between 2017 and 2024, creates an expedited pathway for physicians to obtain licenses in multiple member states. Prior work (Deyo et al. 2023) shows a 3% increase in out-of-state practice, and Oh & Kleiner (2025) find that broader universal licensing recognition increases patient access without increasing physical migration — suggesting the mechanism is virtual practice (telehealth). Yet no study examines whether the compact created *new* healthcare supply or merely redistributed existing providers. This paper fills that gap by studying employment, wages, and establishment counts in the healthcare sector.

## Identification Strategy

### Design: Staggered Difference-in-Differences

**Treatment:** State becomes an operational IMLC member. 8 distinct adoption cohorts:
- 2017Q2: AL, AZ, CO, ID, IL, IA, KS, MN, MS, MT, NV, NH, SD, UT, WA, WI, WV, WY (~18 states)
- 2018: DC, VT, MD, MI, Guam (~4 states + territory)
- 2019: KY, ND, OK, GA (~4 states)
- 2020: LA (~1 state)
- 2021: TX, DE, OH (~3 states)
- 2022: NJ, IN, CT, RI (~4 states)
- 2023: HI, MO (~2 states)
- 2024: FL (~1 state)

**Control:** Never-treated states: AK, CA, NM, NY, OR, SC, VA (~7-8 states)

**Estimator:** Callaway and Sant'Anna (2021) — robust to heterogeneous treatment effects across adoption cohorts. Group-time ATTs aggregated to event-study and overall ATT.

**Pre-treatment period:** 2012Q1–2016Q4 (20 quarters) for first cohort.

### Exposure Alignment
- **Who is treated?** All healthcare providers in states joining the IMLC — both those who obtain multi-state licenses AND those who benefit from increased competition/supply.
- **Primary estimand:** State-level healthcare employment, wages, and establishment counts.
- **Placebo population:** Non-healthcare industries in the same states (should show no IMLC effect).

### Power Assessment
- **Pre-treatment periods:** 20 quarters (2012-2016) for first cohort
- **Treated clusters:** 42 states across 8 cohorts
- **Post-treatment periods:** 7+ years for first cohort (2017-2024)
- **Never-treated:** 7-8 states
- **Unit of analysis:** State × quarter (50 states × 52 quarters ≈ 2,600 obs)

## Expected Effects and Mechanisms

### Primary hypotheses:
1. **Employment:** IMLC adoption increases healthcare employment (NAICS 62), particularly in ambulatory care (NAICS 621) where telehealth practices are concentrated.
2. **Establishments:** IMLC increases the number of healthcare establishments — physicians open practices to serve patients in multiple IMLC states.
3. **Wages:** Ambiguous. Supply expansion could lower wages, but increased demand from multi-state practice could raise them. Net effect is empirical.

### Mechanism: Virtual supply creation vs. redistribution
- If IMLC merely redistributes physicians (zero-sum): employment increases in some states but decreases in others. Net effect ≈ 0.
- If IMLC creates new supply (positive-sum): physicians serve more patients by practicing in additional states via telehealth. Net employment effect > 0.
- **Test:** Compare IMLC effects on healthcare employment in *all* member states vs. bordering non-member states. If redistribution, non-members should lose; if supply creation, non-members should be unaffected or gain from spillovers.

### Heterogeneity:
- **Shortage areas:** Effects should be larger in states with more Health Professional Shortage Areas (HPSAs).
- **Early vs. late adopters:** First-mover advantage may attenuate as more states join.
- **Ambulatory vs. hospital:** Ambulatory care (outpatient, telehealth-intensive) should respond more than hospitals.

## Primary Specification

$$Y_{st} = \alpha_s + \gamma_t + \sum_g \sum_t \beta_{g,t} \cdot \mathbb{1}[G_s = g] \cdot \mathbb{1}[t \geq g] + \varepsilon_{st}$$

Where:
- $Y_{st}$: Healthcare outcome (employment, wages, establishments) in state $s$, quarter $t$
- $\alpha_s$: State fixed effects
- $\gamma_t$: Time fixed effects
- $G_s$: Adoption cohort (year-quarter state joined IMLC)
- Estimated via Callaway-Sant'Anna with never-treated as comparison

## Data Sources

| Source | Variables | Granularity | Years |
|--------|-----------|-------------|-------|
| BLS QCEW | Employment, wages, establishments | State × quarter × NAICS | 2012-2024 |
| Census ACS | Healthcare worker counts, migration | State × year | 2012-2023 |
| IMLC records | Adoption dates by state | State | 2015-2024 |
| HRSA | HPSA designations | State × year | 2012-2023 |

## Planned Robustness Checks

1. **Placebo test:** Run same DiD on non-healthcare industries (retail, manufacturing) — should find no effect.
2. **Event study:** Plot pre-treatment coefficients to verify parallel trends assumption.
3. **Alternative estimators:** Sun & Abraham (2021), Borusyak-Jaravel-Spiess (2024) for comparison.
4. **Permutation inference:** Randomization inference with 1,000 permutations for cluster-robust p-values.
5. **Bacon decomposition:** Identify which 2×2 DiD comparisons drive the overall estimate.
6. **Spillover test:** Estimate effects on bordering non-IMLC states to distinguish supply creation from redistribution.
7. **Dose-response:** States with more HPSA-designated areas as "higher dose" treatment.
8. **Sub-industry analysis:** Ambulatory (621) vs. hospitals (622) vs. nursing (623) — effects should concentrate in 621.
