# Initial Research Plan: apep_0439

## Title
Where Cultural Borders Cross: Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy

## Research Question
Do Switzerland's language and religious boundaries interact to shape gender attitudes? Specifically: (1) Does the well-documented language border gap in gender progressivism depend on local confessional heritage? (2) Is the interaction additive (each dimension contributes independently) or multiplicative (the combination amplifies inequality)?

## Identification Strategy
**Multi-dimensional spatial RDD** at two historically predetermined cultural borders:

### Primary: Language Border RDD (replication + extension)
- **Running variable:** Geodesic distance from municipality centroid to nearest language border segment (negative = French side, positive = German side)
- **Treatment:** Living in a French-speaking vs. German-speaking municipality
- **Bandwidth:** MSE-optimal via `rdrobust`; robustness with half/double bandwidth
- **Key control:** Canton fixed effects where the language border crosses within cantons (Fribourg, Bern, Valais)

### Secondary: Religion Heterogeneity Analysis
- **Interaction term:** Language border estimate × historically Catholic municipality indicator
- **Religion classification:** Use historically predetermined confessional status (cantonal Reformation-era choice, 16th century), NOT modern census religion. This addresses GPT reviewer concern about endogeneity of modern religious composition.
- **Classification source:** Historical cantonal confessional status is fixed and well-documented. Catholic cantons: LU, UR, SZ, OW, NW, ZG, FR, VS, TI, JU, AI. Protestant cantons: ZH, BE, GL, BS, BL, SH, AR, VD, NE, GE. Mixed cantons: AG, GR, SG, SO, TG (assign by pre-1800 majority).

### Tertiary: Religion Border RDD
- **Running variable:** Distance from municipality centroid to nearest confessional border segment
- **Treatment:** Living in a historically Protestant vs. Catholic municipality
- **Focused region:** Following Basten & Betz (2013), focus on western Switzerland where the confessional border is sharpest

### Intersection (Novel Contribution)
- At the Fribourg region, the language border crosses through a Catholic canton surrounded by Protestant cantons
- Within-Fribourg language border: language varies, religion constant (Catholic) → pure language effect
- Fribourg–Bern border: both language and religion vary → compound effect
- Compare language gap estimates across Catholic vs. Protestant segments → identifies interaction

## Pre-registered Primary Outcomes
Following GPT recommendation to avoid specification searching, we pre-specify:

**Primary gender referenda (6 core votes):**
1. June 14, 1981: Equal rights constitutional amendment
2. June 12, 1994: Health insurance law (maternity coverage provisions)
3. March 2, 2004: Maternity insurance (Mutterschaftsversicherung)
4. September 27, 2020: Paternity leave (Vaterschaftsurlaub)
5. September 26, 2021: Marriage for All (Ehe für alle)
6. February 13, 2005: Registered partnerships (eingetragene Partnerschaften)

**Aggregate index:** Average yes-share across these 6 gender referenda (primary outcome).

**Falsification:** Non-gender referenda (mass immigration 2014, fighter jets 2020, tobacco advertising 2022) should show different patterns.

**Secondary (exploratory):** Marriage/divorce rates from BFS vital statistics.

## Expected Effects and Mechanisms
- **Language gap (Level 1):** French-speaking municipalities vote 5–10 pp more progressive on gender referenda than German-speaking neighbors at the border (replicating Eugster et al. pattern for gender outcomes).
- **Religion gap (Level 2):** Protestant municipalities vote 2–5 pp more progressive than Catholic neighbors at confessional borders.
- **Interaction (Level 3 — key hypothesis):** The language gap is LARGER in Catholic areas than Protestant areas. Rationale: In Protestant areas, German speakers are already relatively progressive (Protestant work ethic promotes gender equality through female economic participation). In Catholic areas, German speakers are "double conservative" (conservative language culture + traditional Catholic family norms), so the language gap is amplified.
- **Convergence:** The language gap has narrowed over time (documented in apep_0435). We expect the religion gap to narrow more slowly (religion is less mutable than linguistic/media culture).

## Primary Specification

```
Yes_share_{m,r} = α + β₁·French_m + β₂·Catholic_m + β₃·(French × Catholic)_m
                  + f(distance_lang_m) + g(distance_relig_m) + δ_c + ε_{m,r}
```

Where:
- m = municipality, r = referendum
- French_m = 1 if French-speaking majority
- Catholic_m = 1 if historically Catholic canton
- f(·), g(·) = local polynomial in distance to respective borders
- δ_c = canton fixed effects (where possible)
- Standard errors clustered at municipality level

## Planned Robustness Checks
1. **Bandwidth sensitivity:** Half-bandwidth, double-bandwidth, CER-optimal
2. **Polynomial order:** Linear, quadratic, cubic
3. **Donut RDD:** Exclude municipalities within 1 km, 2 km, 5 km of border (addresses sorting concern)
4. **Kernel choice:** Triangular (main), Epanechnikov, uniform
5. **Covariate balance:** Test continuity of population, foreign-born share, age structure, urbanization at borders
6. **Density test:** McCrary (2008) / Cattaneo-Jansson-Ma (2020) test for manipulation of running variable
7. **Permutation inference:** Randomly reassign municipality positions relative to border (500+ permutations)
8. **Placebo borders:** Shift border 5 km, 10 km into French/German territory
9. **Time-varying estimates:** Separate RDD for each referendum year, showing gap evolution
10. **Falsification:** Non-gender referenda should show language gap but different religion interaction pattern

## Data Requirements
1. **swissdd:** Municipality-level referendum results (1981–2024), ~2,100 municipalities × 20+ votes
2. **BFS shapefiles:** Municipal boundaries in LV95 (EPSG:2056) for distance computation
3. **BFS language classification:** Dominant language per municipality
4. **Historical confessional status:** Cantonal-level (predetermined 16th century), supplemented by 2000 census at municipal level for mixed cantons
5. **BFS population statistics:** Municipality-level covariates (population, age structure, foreign-born share) for balance tests
6. **SMMT:** Municipality harmonization table for consistent IDs across time

## Analysis Pipeline
- `00_packages.R` — Libraries and themes
- `01_fetch_data.R` — Download referendum data (swissdd), shapefiles (BFS), population (BFS)
- `02_clean_data.R` — Harmonize municipalities (SMMT), classify language/religion, compute border distances
- `03_main_analysis.R` — Spatial RDD, interaction models, multi-dimensional analysis
- `04_robustness.R` — Bandwidth sensitivity, donut, permutation, placebo
- `05_figures.R` — Maps, RDD plots, event study, convergence dynamics
- `06_tables.R` — Main results, balance tests, robustness summaries
