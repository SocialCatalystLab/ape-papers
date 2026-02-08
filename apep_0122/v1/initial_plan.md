# Initial Research Plan

## Research Question

Do state Renewable Portfolio Standards (RPS) affect employment in the electric power generation, transmission, and distribution sector? RPS mandates require utilities to source a minimum share of electricity from renewable sources. Proponents argue RPS creates "green jobs," while opponents contend it destroys fossil fuel employment and raises electricity costs. Despite hundreds of studies on RPS effects on renewable deployment, emissions, and electricity prices, no study has used modern heterogeneity-robust difference-in-differences methods to estimate the causal employment effect in the utility sector.

## Identification Strategy

**Design:** Staggered difference-in-differences exploiting variation in the timing of first binding RPS compliance across U.S. states.

**Treatment:** Binary indicator equal to 1 in the first year a state's RPS imposes a binding renewable generation requirement on utilities, and all subsequent years. I will use DSIRE/LBNL compliance data to identify first binding compliance year (not enactment year). As robustness, a continuous treatment intensity measure (required renewable share %) will be used in dose-response specifications.

**Comparison groups:** (1) Not-yet-treated states (primary, CS-DiD default); (2) Never-treated states (~11 states without RPS: AL, AR, FL, GA, ID, KY, LA, MS, NE, TN, WY).

**Estimator:** Callaway-Sant'Anna (2021) group-time ATT estimator from the `did` R package. This avoids the negative weighting bias of two-way fixed effects (TWFE) under heterogeneous treatment effects with staggered adoption.

**Unit of analysis:** State-year panel constructed from individual-level ACS PUMS microdata, 2005-2023.

## Expected Effects and Mechanisms

**Theory predicts ambiguous net employment effects:**

1. **Job creation channel:** RPS stimulates construction of new renewable generation facilities (solar, wind), creating installation and maintenance jobs. Grid integration requires additional transmission workers.

2. **Job destruction channel:** Renewable energy is more capital-intensive per MWh than fossil fuel generation. Coal and gas plant closures eliminate operations and maintenance positions. Automation in renewable facilities reduces labor intensity.

3. **Transition dynamics:** Short-run employment may increase during construction phase, but long-run employment may decline as capital-intensive renewables replace labor-intensive fossil fuel generation.

**Expected magnitude:** Given the capital-intensive nature of renewables, I expect small or null aggregate effects, potentially masking positive short-run effects during transition. Effect heterogeneity by RPS stringency (high-target states seeing larger effects) is expected.

## Primary Specification

$$Y_{st} = \alpha_s + \lambda_t + \beta \cdot \text{RPS}_{st} + \varepsilon_{st}$$

Where:
- $Y_{st}$: Employment rate in electric power sector for state $s$, year $t$ (employees per 1,000 working-age population, or log employment count)
- $\alpha_s$: State fixed effects
- $\lambda_t$: Year fixed effects
- $\text{RPS}_{st}$: Binary treatment indicator (first binding compliance year)

Implemented via Callaway-Sant'Anna group-time ATT, with event study aggregation for dynamic effects.

**Clustering:** State level (N ≈ 51). Standard cluster-robust SEs. Wild cluster bootstrap as robustness for inference.

## Planned Robustness Checks

1. **Alternative treatment definition:** Use first year required renewable share > 5% instead of first binding compliance year
2. **Sun-Abraham (2021) estimator:** Alternative heterogeneity-robust DiD via `fixest::sunab()`
3. **Region × year fixed effects:** Absorb region-specific trends (Census division × year)
4. **Contiguous-state comparison:** Restrict to RPS states vs. contiguous non-RPS neighbors only
5. **Bacon decomposition:** Show TWFE bias via `bacondecomp` package
6. **HonestDiD sensitivity:** Rambachan-Roth bounds allowing for pre-trend violations
7. **Placebo outcomes:** Test effects on non-utility sectors (e.g., retail, education employment) — should show null
8. **Dose-response:** Continuous treatment intensity (required renewable share %) using Callaway-Sant'Anna with continuous treatment or TWFE with interaction
9. **Wild cluster bootstrap:** Using `fwildclusterboot` for finite-sample inference
10. **Leave-one-out:** Sequentially drop each treated state to check sensitivity

## Data Sources

1. **Employment data:** ACS 1-Year PUMS, 2005-2023. Variables: PWGTP (person weight), ESR (employment status), INDP (industry code, 0570 = electric power), ST (state FIPS), AGEP (age), SEX, RAC1P (race), SCHL (education). Census API confirmed working.

2. **RPS policy data:** DSIRE (dsireusa.org) and LBNL RPS compliance reports. Cross-validated with EIA state energy profiles. Manual coding of first binding compliance year for each state.

3. **State covariates (if needed):** Total population, per capita income, unemployment rate from BLS/Census. Used for balance tests and matching, not primary specification.

## Exposure Alignment (DiD-Specific)

- **Who is treated:** Electric utilities in states with binding RPS requirements
- **Primary estimand population:** Workers employed in NAICS 0570 (electric power generation, transmission, distribution)
- **Control population:** Same sector workers in states without (or not yet with) RPS
- **Design:** Standard staggered DiD (not triple-diff)

## Power Assessment

- **Pre-treatment periods:** At least 5 years for states adopting 2010+; up to 18 years for late adopters (2023)
- **Treated clusters:** 29 states with RPS (well above 20 threshold)
- **Post-treatment periods:** Varies by cohort; at least 1-18 years depending on adoption timing
- **Sample size per state-year cell:** ~180 individual-level ACS observations in electricity sector per state (national total ~9,000/year). State-year aggregation yields ~950 state-year observations (50 states × 19 years).
- **Power limitation:** Small sector (electricity workers are <1% of total employment). Effect must be expressed in rates or logs to be detectable. MDE analysis will be conducted in the analysis phase.
