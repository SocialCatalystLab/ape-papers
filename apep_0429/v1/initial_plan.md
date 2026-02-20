# Initial Research Plan: The Long Arc of Rural Roads

## Research Question

Do the economic effects of rural road construction persist, accumulate, or decay over two decades? We exploit the PMGSY population eligibility threshold at 500 using village-level nighttime lights (1992–2021) to trace the complete dynamic path of treatment effects — from road construction through long-run equilibrium.

## Identification Strategy

**Sharp RDD** at Census 2001 population = 500 (plain area villages).

Under PMGSY guidelines, habitations with population ≥ 500 in Census 2001 are eligible for all-weather road connectivity. This creates a sharp discontinuity in eligibility.

- **Running variable:** Census 2001 total village population
- **Threshold:** 500
- **Treatment:** Eligibility for PMGSY road construction (ITT)
- **Estimation:** Local polynomial RDD using `rdrobust` (Cattaneo, Idrobo & Titiunik 2020)
- **Bandwidth:** MSE-optimal (Imbens-Kalyanaraman), with robustness across 50–200% of optimal
- **Kernel:** Triangular (primary), uniform and Epanechnikov (robustness)

## Expected Effects and Mechanisms

1. **Short-run (0–5 years):** Road construction creates local employment, improves market access. Expect positive nightlights effect.
2. **Medium-run (5–10 years):** Structural transformation — shift from agricultural to non-agricultural employment. Firms locate along new roads. Effect may amplify.
3. **Long-run (10–20 years):** Three competing hypotheses:
   - **Accumulation:** Road effects compound as market integration deepens → growing treatment effect
   - **Plateau:** Initial gains captured quickly → flat treatment effect
   - **Decay:** Road maintenance failures or general convergence → diminishing treatment effect

## Primary Specification

For each year t in {1992, ..., 2021}:

Y_i,t = α + τ_t · 1(Pop_i,2001 ≥ 500) + f(Pop_i,2001) + ε_i,t

where Y_i,t is nightlights (log or asinh), f(·) is a local polynomial, and τ_t is the year-specific treatment effect.

Report τ_t for all t, plotted as a dynamic treatment effect graph. Pre-2001 estimates (τ_{1992},...,τ_{2000}) serve as placebo/balance tests.

## Planned Robustness Checks

1. **McCrary density test** at threshold 500
2. **Covariate balance:** 1991 Census variables (population, literacy, SC/ST share, worker composition)
3. **Bandwidth sensitivity:** 50%, 75%, 100%, 125%, 150%, 200% of MSE-optimal
4. **Polynomial order:** Local linear (primary), local quadratic (robustness)
5. **DMSP-only vs VIIRS-only vs harmonized nightlights**
6. **Donut RDD:** Exclude observations within ±25 of threshold (address heaping)
7. **Placebo thresholds:** Run RDD at 300, 400, 600, 700 — expect no effect
8. **Exclude tribal/hilly areas** where the threshold is 250 (to avoid contamination)
9. **Asinh transform** as alternative to log(Y+1)
10. **Fuzzy RDD** using 2011 Census road access as endogenous treatment

## Data Sources

| Data | Source | Coverage | Status |
|------|--------|----------|--------|
| Village population (2001) | SHRUG Census PCA | ~590K villages | On disk |
| Village population (1991, 2011) | SHRUG Census PCA | ~590K villages | On disk |
| Nightlights (DMSP) | SHRUG dmsp_shrid | 1992–2013, village-level | On disk |
| Nightlights (VIIRS) | SHRUG viirs_annual_shrid | 2012–2021, village-level | On disk |
| Geographic crosswalk | SHRUG pc11_td/keys | State/district/subdistrict | On disk |
| Village land area | SHRUG rural key | ~590K villages | On disk |
| Road connectivity | Census 2011 Village Directory | 2011 | In TD file (urban only); proxy from SHRUG |

## Sample Restrictions

1. Rural villages only (from `pc01r_shrid_key.csv`)
2. Exclude tribal/hilly areas (Schedule V areas, NE states, J&K, Himachal, Uttarakhand) where the eligibility threshold is 250, not 500
3. Population window: 100–1000 for broad sample; MSE-optimal bandwidth for primary specification
4. Non-missing nightlights data

## Figure Plan

1. **McCrary density plot** at threshold 500
2. **RDD scatter + local polynomial fit** for key years (2001, 2005, 2010, 2015, 2020)
3. **Dynamic treatment effect plot:** Year-specific τ_t estimates with 95% CI (1992–2021)
4. **Covariate balance plots:** 1991 Census variables at the 500 threshold
5. **Bandwidth sensitivity plot:** Main estimate across different bandwidths
6. **Placebo threshold plot:** Estimates at non-PMGSY thresholds
7. **DMSP vs VIIRS comparison:** Dynamic effects separately for each sensor

## Table Plan

1. **Summary statistics:** Above/below 500 threshold
2. **Covariate balance at threshold:** 1991 Census variables
3. **Main RDD results:** Cross-sectional RDD at 2005, 2010, 2015, 2020
4. **Dynamic treatment effects:** Full panel of year-specific estimates
5. **Robustness:** Bandwidth, polynomial, kernel, donut, placebo
6. **Heterogeneity:** By state, by distance to district HQ, by baseline nightlights
