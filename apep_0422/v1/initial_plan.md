# Initial Research Plan: Can Clean Cooking Save Lives?

## Research Question

Does subsidized clean cooking fuel improve child health in India? We exploit the rollout of Pradhan Mantri Ujjwala Yojana (PMUY, May 2016) — the world's largest clean cooking program — to estimate causal effects on child diarrhea, anemia, stunting, and acute respiratory infection. The NFHS-4 (2015-16) provides pre-treatment baseline; NFHS-5 (2019-21) captures post-treatment outcomes across 707 districts.

## Identification Strategy

**Design:** Continuous treatment intensity difference-in-differences.

**Treatment variable:** Baseline clean fuel gap = (100 − NFHS-4 clean fuel %) / 100 at the district level. Districts with lower baseline clean fuel usage had more BPL households eligible for Ujjwala, creating higher treatment intensity. This exploits the fact that Ujjwala targeted areas with the lowest clean fuel adoption.

**Primary specification (first-differences):**

$$\Delta Y_d = \alpha + \beta \cdot FuelGap_d + X'_d \cdot \gamma + \mu_s + \varepsilon_d$$

Where:
- $\Delta Y_d$: change in health outcome from NFHS-4 to NFHS-5 in district $d$
- $FuelGap_d$: (100 − NFHS-4 clean fuel %) / 100 — baseline treatment intensity
- $X'_d$: baseline controls (electricity, sanitation, literacy, institutional births)
- $\mu_s$: state fixed effects

**Panel specification (2-period DiD):**

$$Y_{d,t} = \alpha_d + \lambda_t + \beta \cdot FuelGap_d \times Post_t + \varepsilon_{d,t}$$

Where $\alpha_d$ are district FE and $\lambda_t$ are period FE. $\beta$ identifies the differential improvement in high-exposure districts relative to low-exposure districts.

**IV specification:**

$$\Delta Health_d = \alpha + \beta \cdot \widehat{\Delta CleanFuel_d} + X'_d \gamma + \mu_s + \varepsilon_d$$

First stage: $\Delta CleanFuel_d = \pi \cdot FuelGap_d + X'_d \delta + \mu_s + \nu_d$

The baseline clean fuel gap instruments for actual changes in clean fuel adoption, isolating the Ujjwala-driven component.

## Expected Effects and Mechanisms

1. **Fuel → ARI:** Indoor air pollution from biomass cooking causes acute respiratory infection in children. Switching to LPG eliminates this exposure. Expected: 3-8 pp reduction in ARI for children in high-exposure districts.

2. **Fuel → Anemia:** Smoke exposure depresses hemoglobin production. Expected: 2-5 pp reduction in women's anemia.

3. **Fuel → Stunting/Nutrition:** Reduced morbidity burden + women's time savings from faster cooking → improved child nutrition. Expected: smaller, indirect effects (1-3 pp).

4. **Fuel → Women's autonomy:** LPG connections registered in women's names. Time savings from faster cooking. Expected: positive effects on women's decision-making, mobility.

5. **Heterogeneity:** Effects should be larger in:
   - Districts with higher baseline biomass fuel use (dose-response)
   - States with lower urbanization (more biomass cooking in rural areas)
   - Districts with lower baseline health infrastructure (larger marginal returns)

## Primary Specification Details

- **Cross-section:** 707 districts, first-differences (NFHS-5 minus NFHS-4)
- **Panel:** 707 districts × 2 periods (NFHS-4, NFHS-5)
- **Clustering:** Standard errors clustered at state level (~28 clusters) with HC1 robust SE for cross-section
- **Estimator:** OLS reduced form + IV (clean fuel gap → Δ clean fuel → Δ health)

## Planned Robustness Checks

1. **Placebo treatment:** Use baseline ELECTRICITY gap as fake treatment. Electricity gap should NOT predict changes in cooking-fuel-related health outcomes (ARI, anemia) after controlling for clean fuel gap.

2. **Placebo outcome:** Clean fuel gap should NOT predict changes in vaccination rates or institutional births (health system outcomes unrelated to indoor air pollution).

3. **Dose-response:** Split districts into terciles/quartiles by baseline clean fuel. Show monotonically increasing treatment effects.

4. **Swachh Bharat control:** Add change in sanitation (Δ improved sanitation) as control. Sanitation improvements (SBM) are correlated with but distinct from cooking fuel changes. Coefficient on clean fuel gap should be robust.

5. **Leave-one-state-out:** Drop each state sequentially. Coefficient should be stable.

6. **Covariate balance:** Test whether baseline clean fuel gap predicts pre-treatment differences in non-fuel outcomes.

7. **Oster (2019) bounds:** Compute δ (coefficient stability ratio) to assess omitted variable bias sensitivity.

## Data Sources

| Source | Level | Frequency | Coverage | Role |
|--------|-------|-----------|----------|------|
| NFHS-4/5 district factsheets | District (707) | 2 waves | 2015-16, 2019-21 | Treatment + outcomes |
| NFHS-4 clean fuel % | District | Baseline | 2015-16 | Treatment intensity |
| NFHS-4 controls | District | Baseline | 2015-16 | Controls |

## Exposure Alignment

- **Who is treated:** BPL households in districts with low baseline clean fuel adoption, receiving free LPG connections under Ujjwala.
- **Primary estimand population:** Households using solid fuels (wood, dung, crop residue) for cooking at baseline.
- **Control population:** Districts with high baseline clean fuel adoption (less Ujjwala treatment needed).
- **Design:** Continuous treatment intensity DiD. All districts contribute, weighted by baseline fuel gap.

## Power Assessment

- **Pre-treatment periods:** 1 (NFHS-4, 2015-16). Limitation acknowledged.
- **Treatment variation:** 707 districts with continuous clean fuel gap ranging from ~5% to ~95%.
- **Post-treatment periods:** 1 (NFHS-5, 2019-21)
- **State-level clusters:** ~28 (above threshold for cluster-robust inference)
- **MDE:** With 707 districts and baseline clean fuel gap SD ≈ 0.25, we can detect a 2-3 pp change in diarrhea prevalence per SD of treatment intensity at the 5% level. For the first stage (clean fuel adoption), expected effects are large (15-25 pp increase in clean fuel in high-exposure districts).
