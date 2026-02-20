# Initial Research Plan: Does Water Access Build Human Capital?

## Research Question

Does household piped water access improve human capital outcomes in rural India? We exploit the staggered rollout of the Jal Jeevan Mission (JJM), the world's largest piped water program, to estimate causal effects on economic activity (nighttime lights), child health (diarrhea, stunting), and educational participation.

## Identification Strategy

**Design:** Continuous treatment intensity difference-in-differences.

**Treatment variable:** Baseline exposure intensity = (1 − NFHS-4 piped water coverage %) at the district level. Districts with lower pre-JJM piped water coverage received proportionally greater JJM investment. This is interacted with a post-JJM indicator (August 2019+).

**Primary specification (nightlights panel):**
$$\ln(NL_{d,t}) = \alpha_d + \gamma_{s(d),t} + \beta \cdot Exposure_d \times Post_t + X'_{d} \cdot \delta_t + \varepsilon_{d,t}$$

Where:
- $NL_{d,t}$: nighttime lights in district $d$, month $t$
- $\alpha_d$: district fixed effects
- $\gamma_{s(d),t}$: state×month fixed effects
- $Exposure_d$: 1 − (NFHS-4 piped water %) for district $d$
- $Post_t$: indicator for $t \geq$ August 2019
- $X'_d \cdot \delta_t$: baseline controls (population, urbanization, literacy) × time trends

**Supplementary specification (NFHS cross-section):**
$$\Delta Y_d = \alpha + \beta \cdot \Delta Water_d + X'_d \cdot \gamma + \varepsilon_d$$

Where $\Delta Y_d$ is the change in outcome from NFHS-4 to NFHS-5 and $\Delta Water_d$ is the change in piped water coverage.

## Expected Effects and Mechanisms

1. **Water → Health:** Piped water reduces waterborne disease (diarrhea, cholera). Expected: 5-15% reduction in diarrhea prevalence in high-exposure districts.
2. **Water → Time savings:** Women spend ~45 min/day fetching water in rural India. Piped connections free this time for productive activities. Expected: positive effect on nightlights (economic activity).
3. **Water → Education:** Girls disproportionately bear water collection burden. Freed time → increased school attendance. Expected: larger effects for girls than boys.
4. **Heterogeneity:** Effects should be larger in states with higher female water collection burden (measured from NFHS-4 time-use data).

## Primary Specification Details

- **Panel:** ~640 districts × 137 months (Jan 2013 – May 2024)
- **Clustering:** Standard errors clustered at state level (28-30 clusters)
- **Estimator:** Two-way fixed effects (TWFE) as baseline; Callaway-Sant'Anna/Sun-Abraham for heterogeneity-robust estimation if treatment effects vary by cohort
- **Treatment timing:** August 2019 (JJM national launch). For robustness, use state-level JJM financial disbursement data to construct state-year treatment intensity.

## Planned Robustness Checks

1. **Event study:** Estimate year-by-year coefficients (relative to JJM launch) interacted with baseline exposure. Pre-trend coefficients should be zero.
2. **COVID donut:** Drop March 2020 – June 2021 from estimation.
3. **Placebo treatment:** Use baseline characteristics unrelated to water (e.g., road access) as fake treatment variable. Should show null effect.
4. **Placebo outcome:** Male school attendance should respond less than female attendance to water access improvements.
5. **Alternative treatment measures:** Replace NFHS-4 baseline with SHRUG village directory piped water indicators (Census 2011).
6. **Bandwidth/binning:** Continuous exposure vs. tercile/quartile bins.
7. **Wild cluster bootstrap:** For inference with ~28 state-level clusters.

## Data Sources

| Source | Level | Frequency | Coverage | Role |
|--------|-------|-----------|----------|------|
| NFHS-4/5 district factsheets | District (707) | 2 waves | 2015-16, 2019-21 | Treatment intensity + health outcomes |
| Yao VIIRS nightlights | District (~640) | Monthly | 2013-2024 | Primary outcome (economic activity) |
| JJM financial progress (data.gov.in) | State | Annual | 2019-2024 | Treatment dosage robustness |
| NFHS-4 controls | District | Baseline | 2015-16 | Controls (population, literacy, urbanization) |

## Exposure Alignment

- **Who is treated:** Rural households in districts with low baseline piped water coverage, receiving new FHTC under JJM.
- **Primary estimand population:** Rural population in districts with below-median NFHS-4 piped water coverage.
- **Control population:** Districts with high baseline piped water coverage (less JJM treatment needed).
- **Design:** Continuous treatment intensity DiD (not binary). All districts contribute, weighted by their exposure.

## Power Assessment

- **Pre-treatment periods:** 72 months (Jan 2013 – Jul 2019) = 6+ years
- **Treated clusters:** ~640 districts with continuous treatment variation; ~320 above-median exposure
- **Post-treatment periods:** 58 months (Aug 2019 – May 2024)
- **State-level clusters:** 28-30 (above the ~20 threshold for cluster-robust inference)
- **MDE:** With 640 districts and 137 months, we have high statistical power. For a 1 SD change in exposure (approximately moving from 25th to 75th percentile), a 2-3% change in log nightlights should be detectable at the 5% level. For NFHS outcomes (707 districts, 2 periods), detectable effects are larger but still reasonable for health outcomes (~3-5 pp for diarrhea prevalence).
