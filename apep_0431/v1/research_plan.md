# Initial Research Plan: Roads to Equality?

## Research Question

Does India's rural road construction program (PMGSY) differentially affect women's structural transformation out of agriculture? Specifically: does crossing the PMGSY population eligibility threshold cause women to shift from agricultural to non-agricultural employment at different rates than men?

## Identification Strategy

**Design:** Reduced-form regression discontinuity at the PMGSY population threshold.

**Running variable:** Village population from Census 2001 (via SHRUG pc01_pca_clean_shrid.csv).

**Threshold:** 500 persons for plain-area states. Special category states (J&K, HP, Uttarakhand, NE states) use 250 threshold and are analyzed separately or excluded from the main specification.

**Treatment:** Villages above the threshold were eligible for priority road construction under PMGSY (Asher & Novosad 2020 AER show 22pp jump in road probability at habitation level). At village level, this is an intent-to-treat reduced form — villages above 500 are MORE LIKELY to contain eligible habitations.

**Identifying assumption:** No other policy or characteristic changes discontinuously at the 500 population threshold. Validated by: (1) McCrary density test for no manipulation, (2) smooth baseline covariates, (3) pre-PMGSY nightlights placebo.

## Expected Effects and Mechanisms

**Primary hypotheses:**
- H1: Roads increase female non-agricultural employment share (accessibility channel — women face larger mobility constraints than men, so road access has a larger proportional effect)
- H2: Roads increase male non-agricultural employment more than female (commuting channel — men commute out, women remain in agriculture)
- H3: Gender effects are heterogeneous by cultural region (purdah norms in north vs. more egalitarian south)

**Mechanisms:**
1. **Market access:** Roads connect villages to urban labor markets, enabling commuting
2. **Non-farm enterprise:** Roads facilitate goods transport, enabling non-agricultural businesses
3. **Education:** Better school access (Asher & Novosad found 7% middle school enrollment increase)
4. **Information:** Exposure to urban norms and opportunities

## Primary Specification

**Cross-sectional RDD (Census outcomes):**
```
Y_i(2011) - Y_i(2001) = α + τ·1[Pop_i(2001) ≥ 500] + f(Pop_i(2001) - 500) + ε_i
```
where Y = female non-agricultural worker share, f() = local polynomial.

**Dynamic RDD (annual nightlights):**
```
NL_it = α_t + τ_t·1[Pop_i(2001) ≥ 500] + f_t(Pop_i(2001) - 500) + ε_it
```
Estimate τ_t for each year t = 1994–2023. τ_t for t < 2000 = placebo.

**Bandwidth:** Optimal Calonico-Cattaneo-Titiunik (CCT) bandwidth with robust bias-corrected confidence intervals.

## Sample

~591,000 rural villages from Census 2001 (SHRUG). After restricting to plain-area states and near-threshold observations (within optimal bandwidth), expect 50,000–150,000 villages in the estimation sample.

## Planned Robustness Checks

1. **McCrary density test** at 500 threshold
2. **Covariate balance** — baseline literacy, SC/ST share, pre-PMGSY nightlights, female worker share
3. **Bandwidth sensitivity** — estimate across range of bandwidths (50% to 200% of CCT optimal)
4. **Polynomial order** — linear, quadratic, cubic
5. **Donut hole** — exclude villages with population exactly 500 (±5 persons)
6. **Placebo thresholds** — test for discontinuities at 300, 400, 600, 700 (should be null)
7. **Pre-PMGSY nightlights** — RDD at 500 for each year 1994-1999 (should be null)
8. **Special category states** — separate analysis at 250 threshold
9. **Heterogeneity by region** — North (Hindi belt) vs South vs East vs West
10. **Permutation inference** — randomization inference for finite-sample validity

## Power Assessment

- ~591K rural villages total
- Within ±100 of threshold: ~35,000-40,000 villages (based on India's village size distribution)
- Within ±200: ~70,000-80,000 villages
- Effect sizes: Asher & Novosad found 10-15% structural transformation effect. For gender-specific outcomes, expect smaller effects (5-10%). With N > 30,000 near threshold, we have excellent power for detecting economically meaningful effects.

## Data Sources

All from local SHRUG installation:
- `pc01_pca_clean_shrid.csv` — Census 2001 population (running variable), baseline worker classification
- `pc11_pca_clean_shrid.csv` — Census 2011 worker classification by gender (primary outcome)
- `dmsp_shrid.csv` — DMSP nightlights 1994-2013 (annual outcomes + placebo)
- `viirs_annual_shrid.csv` — VIIRS nightlights 2012-2023 (extended outcomes)
- `shrid_pc11dist_key.csv` — State/district codes (for identifying plain vs special-category states)
- `pc01r_shrid_key.csv` — Rural village identification
