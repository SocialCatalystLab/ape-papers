# Initial Research Plan: apep_0217

## Research Question

Does the Appalachian Regional Commission's "Distressed" county designation improve economic outcomes for designated counties, or does the label itself create stigma effects and dependency traps that offset the benefits of increased federal aid?

## Identification Strategy

**Regression Discontinuity Design (RDD)** at the ARC "Distressed" designation threshold.

The ARC classifies ~428 Appalachian counties annually using a Composite Index Value (CIV) — a continuous index averaging three ratios: (county unemployment / national unemployment), (national per capita market income / county PCMI), and (county poverty / national poverty), scaled to 100. Counties ranked in the worst national decile (among all ~3,110 US counties) receive the "Distressed" designation.

**Running variable:** Composite Index Value (CIV), centered at the Distressed/At-Risk threshold.
**Cutoff:** The CIV value corresponding to the 10th national percentile rank (varies by year).
**Treatment:** "Distressed" designation → 80% ARC match rate (vs 70% for At-Risk), exclusive access to Distressed Counties Program funding, and the "Distressed" label itself.

## Design: Panel RDD

Pool observations across FY2007-FY2017+ (11+ years of CIV data). Each county-year is an observation. The running variable is centered at the year-specific threshold.

**Key advantage over cross-sectional RDD:** Panel structure allows:
- County fixed effects (within-county variation in designation status over time)
- Year fixed effects (absorb national trends)
- Dramatically larger effective sample size near the threshold

## Expected Effects and Mechanisms

**Hypothesis 1 (Conventional):** Distressed designation increases federal aid, which improves local economic conditions (lower unemployment, higher income, reduced poverty).

**Hypothesis 2 (Counter-intuitive):** The "Distressed" label itself creates stigma — discouraging private investment, reducing business formation, and potentially creating dependency on federal transfers. Net effect on economic outcomes could be zero or negative despite increased public spending.

**Mechanisms to test:**
1. ARC grant funding (first stage) — Do distressed counties receive more ARC dollars?
2. Private sector activity — Business formation, private employment
3. Population dynamics — Out-migration, brain drain
4. Fiscal capacity — Local government revenue, tax base
5. Health outcomes — Insurance coverage, mortality (secondary)

## Primary Specification

$$Y_{it} = \alpha + \tau D_{it} + f(CIV_{it} - c_t) + D_{it} \times f(CIV_{it} - c_t) + \gamma_i + \delta_t + \varepsilon_{it}$$

Where:
- $Y_{it}$ = outcome for county $i$ in year $t$
- $D_{it} = \mathbf{1}[CIV_{it} \geq c_t]$ = distressed designation
- $f(\cdot)$ = local linear function of centered running variable
- $c_t$ = year-specific CIV threshold
- $\gamma_i$ = county fixed effects
- $\delta_t$ = year fixed effects

Bandwidth selected by rdrobust (Calonico, Cattaneo & Titiunik). Robust bias-corrected inference.

## Power Assessment

- **Total Appalachian counties:** ~428 per year
- **Counties within ±5 CIV points of threshold:** ~41 per year
- **Panel years:** 11+ (FY2007-FY2017)
- **Effective observations near threshold:** ~450+ county-years
- **Clustering:** County level (to account for serial correlation)

## Planned Robustness Checks

1. **McCrary density test** — Is there bunching at the CIV threshold? (manipulation test)
2. **Covariate balance** — Pre-determined characteristics smooth through the cutoff
3. **Bandwidth sensitivity** — Results across multiple bandwidth choices
4. **Placebo cutoffs** — No effect at fake thresholds (20th, 30th, 50th percentiles)
5. **Donut-hole RDD** — Drop observations closest to the threshold
6. **Polynomial sensitivity** — Local linear vs quadratic
7. **Year-by-year estimates** — Stability over time
8. **Cross-sectional pooled vs panel RDD** — Compare specifications

## Data Sources

| Data | Source | Variables | Access |
|------|--------|-----------|--------|
| CIV scores | ARC Excel files | CIV, rank, designation, components | Direct download |
| Unemployment | BLS LAUS | County unemployment rate | Free API |
| Poverty & income | Census SAIPE | Poverty rate, median income | Free API |
| Population | Census pop estimates | County population, components of change | Free API |
| Employment | BEA REIS | Employment by sector, personal income | Free API (BEA_API_KEY) |
| Health | County Health Rankings | Premature death, insurance, health factors | Download |

## Paper Structure

1. Introduction — Hook: $3.5B in ARC funding over 50 years, but Appalachia remains America's poorest region. Why?
2. Institutional Background — ARC classification system, funding mechanisms, historical context
3. Data — CIV construction, outcome variables, sample
4. Empirical Strategy — Panel RDD design, identification assumptions
5. Results — Main effects, heterogeneity, mechanisms
6. Discussion — Stigma vs aid effects, policy implications
7. Conclusion

Target: 28-30 pages main text.
