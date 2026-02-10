# Initial Research Plan: The Innovation Cost of Privacy

## Research Question

Do state comprehensive consumer data privacy laws reduce technology sector employment, wages, and new business formation?

## Identification Strategy

**Staggered difference-in-differences** exploiting the sequential adoption of comprehensive data privacy laws across 20 US states between 2020 and 2026. Treatment is defined as the first full quarter after a state's privacy law becomes effective. Control states are the ~30 states that have not enacted comprehensive privacy legislation.

**Estimator:** Callaway and Sant'Anna (2021) group-time ATT, which handles heterogeneous treatment effects and avoids the negative-weighting problems of two-way fixed effects in staggered settings.

## Treatment Assignment

| Wave | State(s) | Effective Date | Treatment Quarter |
|------|----------|---------------|-------------------|
| 1 | California | 2020-01-01 | 2020Q1 |
| 2 | Virginia | 2023-01-01 | 2023Q1 |
| 3 | Colorado, Connecticut | 2023-07-01 | 2023Q3 |
| 4 | Utah | 2023-12-31 | 2024Q1 |
| 5 | Texas, Oregon | 2024-07-01 | 2024Q3 |
| 5b | Montana | 2024-10-01 | 2024Q4 |
| 6 | Delaware, Iowa, Nebraska, New Hampshire, New Jersey | 2025-01-01/15 | 2025Q1 |
| 7 | Tennessee, Minnesota, Maryland | 2025-07-01/10-01 | 2025Q3/Q4 |
| 8 | Indiana, Kentucky, Rhode Island | 2026-01-01 | 2026Q1 |

Note: Florida's Digital Bill of Rights is excluded from the primary specification due to its $1B revenue threshold, which makes it functionally different from other comprehensive laws. Included in robustness.

## Expected Effects and Mechanisms

**Primary hypothesis (Regulatory Burden):** Privacy laws impose compliance costs (data mapping, consent management, DPO hiring, vendor audits) that disproportionately burden small and data-intensive firms. Expected: negative effects on establishment counts and business applications, with larger effects for small firms and data-intensive industries.

**Alternative 1 (Regulatory Moat):** Large firms absorb compliance costs easily while small competitors cannot, leading to industry concentration. Expected: negative effects on establishment counts but zero or positive effects on total employment at large firms.

**Alternative 2 (De Facto Federal Standard):** Multi-state firms already comply with CCPA/CPRA standards nationally, so additional state laws have no marginal effect. Expected: null effects across all outcomes.

## Primary Specification

$$Y_{s,t} = \text{ATT}(g,t) \text{ via Callaway-Sant'Anna (2021)}$$

Where:
- $Y_{s,t}$: Log employment (or establishments, wages, business applications) in state $s$, quarter $t$
- Group $g$: Treatment cohort defined by first full treatment quarter
- Never-treated states as comparison group
- Unconditional parallel trends assumption (tested via event study)
- Doubly-robust estimator (inverse probability weighting + outcome regression)

**Outcome variables (ordered by priority):**
1. Log employment in NAICS 51 (Information sector) — primary
2. Log number of establishments in NAICS 51 — entry/exit channel
3. Log average weekly wages in NAICS 51 — labor market tightness
4. Log business applications (Census BFS) — startup formation
5. Log employment in NAICS 5112 (Software Publishers) — narrow tech

## Planned Robustness Checks

1. **Placebo industries:** Apply same specification to NAICS 31-33 (Manufacturing), NAICS 62 (Healthcare), NAICS 23 (Construction). Expect null effects.
2. **Event-study pre-trends:** Plot dynamic ATT for leads t-8 through t-1 (2 years pre). Require joint F-test of pre-trends p > 0.10.
3. **Sun-Abraham (2021) estimator:** Alternative to CS as robustness.
4. **Including Florida:** Add Florida (treated 2024Q3) as sensitivity.
5. **Heterogeneity by state tech intensity:** Split states by baseline share of NAICS 51 employment. Test if high-tech treated states show larger effects.
6. **Randomization inference:** Fisher permutation test with 1000 draws.
7. **Synthetic DiD (Arkhangelsky et al. 2021):** Alternative estimation using sdid.
8. **Spillover test:** Compare tech employment growth in never-treated states bordering treated states vs. interior never-treated states.

## Exposure Alignment

**Who is treated:** All firms operating in a state with a comprehensive data privacy law are subject to compliance requirements, though enforcement thresholds vary (e.g., Virginia requires processing data of 100,000+ consumers). The treatment is state-level and applies uniformly within each state's jurisdiction.

**Treatment-eligible population:** The affected population is the universe of technology-sector firms (NAICS 51 and sub-industries) operating in treated states. Software publishers (NAICS 5112) face the most direct exposure because their core business model involves collecting, processing, and monetizing consumer data.

**Estimand alignment:** The outcome (state-level QCEW employment/establishments) captures the aggregate effect on all firms in the treated state's technology sector. This is the policy-relevant estimand for state legislators considering whether to adopt privacy legislation.

**Design:** Standard staggered DiD (not triple-diff/DDD), since the treatment applies at the state level and the comparison is between treated and never-treated states over time.

## Power Assessment

- **Pre-treatment periods:** 20 quarters (2015Q1–2019Q4) for California; 8+ quarters for all waves
- **Treated clusters:** 19 states (excluding Florida) across 8 cohorts
- **Post-treatment periods:** California has 24+ post quarters; Virginia has 12+; later cohorts have fewer
- **MDE estimate:** With ~50 state-quarters per cohort and typical QCEW variance, conservative MDE is ~2-5% for Information sector employment. Establishment counts likely have higher variance → larger MDE.

## Data Sources

| Source | Variable | Frequency | Geography | Access |
|--------|----------|-----------|-----------|--------|
| BLS QCEW | Employment, establishments, wages by industry | Quarterly | State | Public API (no key) |
| Census BFS | Business applications | Quarterly | State | Public CSV download |

## Timeline

1. Fetch QCEW data for all states, 2015–2025, NAICS 51 and placebo industries
2. Fetch BFS data for all states, 2015–2025
3. Construct treatment indicator from privacy law effective dates
4. Run CS-DiD for primary and secondary outcomes
5. Run all robustness checks
6. Generate figures: event-study plots, treatment maps, trend comparisons
7. Write paper (25+ pages)
