# Initial Research Plan

## Research Question

Does technological obsolescence—measured by the modal age of technologies used in a metropolitan area—predict support for populist candidates in U.S. presidential elections? Specifically, we test whether CBSAs with older modal technology ages exhibit higher Trump vote shares in 2016, 2020, and 2024.

## Theoretical Framework

Building on Acemoglu et al.'s "New Technologies and the Skill Premium," we hypothesize that regions using older technologies face:
1. Lower productivity growth and wage stagnation
2. Greater vulnerability to technological displacement
3. Weaker labor market prospects for non-college workers

These economic anxieties may translate into political support for candidates promising to restore economic security or blaming elites/globalization for regional decline.

## Identification Strategy

### Primary Specification (Cross-sectional)

$$TrumpShare_{c,t} = \alpha + \beta \cdot ModalAge_{c,t-1} + X_{c,t-1}'\gamma + \epsilon_{c,t}$$

Where:
- $TrumpShare_{c,t}$ = Republican vote share in CBSA $c$ in election year $t$ (2016, 2020, 2024)
- $ModalAge_{c,t-1}$ = Mean modal technology age in CBSA $c$ in the year before the election
- $X_{c,t-1}$ = Vector of controls (education, manufacturing share, population, density, etc.)

### Lagged Differences Specification

$$\Delta TrumpShare_{c} = \alpha + \beta \cdot \Delta ModalAge_{c} + \Delta X_{c}'\gamma + \epsilon_{c}$$

Regressing change in Trump share (2020-2016 or 2024-2016) on change in modal age over the same period.

### Panel Specification (with CBSA fixed effects)

$$TrumpShare_{c,t} = \alpha_c + \delta_t + \beta \cdot ModalAge_{c,t-1} + X_{c,t-1}'\gamma + \epsilon_{c,t}$$

This absorbs time-invariant CBSA characteristics, identifying effects from within-CBSA variation in technology age.

## Expected Effects and Mechanisms

**Primary hypothesis:** $\beta > 0$ — CBSAs with older technologies vote more for Trump.

**Magnitude:** Based on existing literature on economic anxiety and voting, we expect a 10-year increase in modal technology age to be associated with approximately 2-5 percentage point higher Trump vote share.

**Mechanisms to test:**
1. Wage stagnation: Older tech → lower wage growth → populist voting
2. Manufacturing decline: Older tech concentrated in declining industries
3. Education polarization: Older tech regions have lower college attainment

## Data Construction

### Technology Data (modal_age.dta)
- 917 CBSAs × 14 years (2010-2023)
- ~45 observations per CBSA-year (different sectors/industries)
- Key variable: `modal_age` = modal technology age in years
- Collapse to CBSA-year mean

### Election Data
- County-level presidential results 2016, 2020, 2024
- Aggregate to CBSA using NBER crosswalk (population-weighted)
- Construct Trump/Republican vote share

### Controls (from ACS/Census)
- % with bachelor's degree or higher
- % employed in manufacturing
- Median household income
- Population and density
- % non-Hispanic white
- Unemployment rate

## Robustness Checks

1. **China trade shock:** Control for Autor-Dorn-Hanson exposure
2. **Immigration:** Control for foreign-born share
3. **Alternative measures:** Use technology age percentiles, max/min instead of mean
4. **Spatial correlation:** Conley standard errors
5. **Placebo:** Effect on Democratic primary turnout or non-presidential races
6. **Heterogeneity:** By urban/rural, by manufacturing intensity

## Power Considerations

- N = 917 CBSAs
- 3 election years → pooled N ≈ 2,750 observations
- SD of modal age ≈ 15 years
- SD of Trump share ≈ 15 percentage points
- For detecting β = 0.2 pp per year (2 pp per decade):
  - Effect size = 0.2 × 15 / 15 ≈ 0.2
  - With N = 900 and α = 0.05, power > 90%

## Timeline

1. Data merging and cleaning
2. Descriptive statistics and visualization
3. Main regressions
4. Robustness checks
5. Mechanism analysis
6. Paper writing
