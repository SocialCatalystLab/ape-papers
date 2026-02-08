# Initial Research Plan (Revision of APEP-0049)

**Paper ID:** paper_129
**Parent Paper:** apep_0049
**Date:** 2026-02-01

---

## Research Question

Does gaining eligibility for federal transit formula funding improve local transportation access and labor market outcomes?

## Identification Strategy

Sharp Regression Discontinuity Design exploiting the 50,000 population threshold for FTA Section 5307 Urbanized Area Formula Grants.

**Running Variable:** 2010 Census population relative to 50,000 threshold
**Treatment:** Section 5307 eligibility (binary: 1 if population ≥ 50,000)
**Outcomes:** 2016-2020 ACS 5-year estimates (transit share, employment rate, no-vehicle share, long commute share)

## Expected Effects and Mechanisms

**Primary hypothesis:** Eligibility for formula funding increases transit service availability, which improves transportation access and labor market outcomes.

**Mechanisms:**
1. Funding → Capital investment (vehicle purchases, facilities)
2. Capital → Service provision (more routes, higher frequency)
3. Service → Ridership (transit becomes competitive with auto)
4. Ridership → Labor market outcomes (expanded job access, reduced commute costs)

**Alternative hypotheses:**
- Funding too small to matter at margin
- Implementation lags exceed observation window
- Local capacity constraints prevent utilization
- Low baseline demand limits transit potential

## Primary Specification

Local polynomial regression discontinuity with:
- Triangular kernel
- MSE-optimal bandwidth selection (Calonico et al. 2014)
- Robust bias-corrected confidence intervals
- Standard errors clustered by urban area

## Planned Robustness Checks

1. McCrary density test for manipulation
2. Covariate balance (median household income)
3. Bandwidth sensitivity (0.5x to 2x optimal)
4. Placebo thresholds (40k, 45k, 55k, 60k)
5. Alternative kernels (uniform, Epanechnikov)
6. Alternative polynomial orders (quadratic, cubic)
7. Heterogeneity by region, income, density

## Critical Fixes from Parent Paper

1. **Data Integrity:** Fetch real data from Census Bureau APIs (no synthetic variables)
2. **Timing:** Use 2010 Census for running variable, 2016-2020 ACS for outcomes
3. **Literature:** Complete all citations, no placeholders
4. **First Stage:** Document statutory discontinuity accurately (100% sharp by law)

---

*This plan locked before data analysis on 2026-02-01.*
