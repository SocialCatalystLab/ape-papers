# Initial Research Plan: apep_0372

## Research Question

Do state minimum wage increases affect the earnings of college graduates? Specifically, do minimum wage spillover effects reach into the lower tail of the graduate earnings distribution, and do these effects vary by degree level, field of study, and time since graduation?

## Identification Strategy

### Design: Two-Way Fixed Effects with Continuous Treatment

- **Unit of analysis:** Institution × cohort (primary); Institution × CIP × cohort (heterogeneity)
- **Treatment:** Log real effective state minimum wage, averaged over the 3-year cohort graduation window
- **Fixed effects:** Institution FE + Cohort FE (primary specification); Region × Cohort FE (robustness)
- **Variation exploited:** Within-institution, across-cohort changes in state minimum wage

### Key Equation

$$Y_{ict} = \alpha_i + \gamma_t + \beta \cdot \ln(MW_{s(i),t}) + X_{s(i),t}'\delta + \varepsilon_{ict}$$

Where $Y_{ict}$ is the pth percentile earnings for institution $i$ in cohort $t$, $MW_{s(i),t}$ is the effective minimum wage in state $s$ during cohort $t$'s graduation window, and $X_{s(i),t}$ are state-level controls.

### Identifying Assumption

Conditional on institution and cohort fixed effects plus state economic controls, within-institution changes in graduate earnings across cohorts are not systematically correlated with state MW changes through channels other than the minimum wage.

## Expected Effects and Mechanisms

### Predictions
1. **P25 earnings:** Positive effect from MW spillovers (strongest for sub-baccalaureate, low-wage CIPs)
2. **P50 earnings:** Smaller positive effect (farther from MW threshold)
3. **P75 earnings:** Near-zero effect (placebo — MW should not reach upper tail)
4. **Y1 > Y5 > Y10:** Effects should attenuate over time as careers diverge from entry-level positions
5. **Sub-baccalaureate > Bachelor's:** Certificate/associate graduates more exposed to MW floor
6. **Low-wage CIPs > High-wage CIPs:** Education/arts/social work more affected than engineering/CS

### Mechanisms
- **Direct binding:** For sub-baccalaureate P25, MW may directly constrain the earnings floor
- **Spillover/compression:** MW increases push up wages above the floor through employer competition
- **Composition:** MW increases may change which graduates find employment (extensive margin)
- **Substitution:** Higher MW for non-graduates may reduce demand for low-skill graduates

## Primary Specification

1. **Main results:** Elasticity of P25/P50/P75 earnings w.r.t. state MW, by degree level (certificate, associate, bachelor's)
2. **Field heterogeneity:** Separate estimates for low-wage CIPs (education, psychology, arts, liberal arts) vs. high-wage CIPs (CS, engineering, business, health)
3. **Time horizon:** Compare Y1, Y5, and Y10 outcomes to test persistence

## Planned Robustness Checks

1. **Region × Cohort FE** (absorbs differential regional trends)
2. **State labor market controls** (unemployment, GDP, industry composition)
3. **Border-state pairs** (compare institutions near state borders with different MW)
4. **Bachelor's as placebo** (if MW effects appear for bachelor's P75, design is suspect)
5. **Jackknife by state** (drop one state at a time)
6. **Binary treatment** (above-median MW increase) with CS estimator
7. **Lagged MW** (test whether future MW changes predict current earnings — falsification)

## Exposure Alignment

- **Who is treated:** Graduates from institutions in states that raised MW above the federal floor
- **Primary estimand population:** Certificate and associate degree graduates, especially in low-wage fields
- **Placebo/control population:** Bachelor's degree graduates in high-wage fields; P75 outcomes at any degree level
- **Design:** Continuous treatment intensity (log MW) in TWFE framework

## Power Assessment

- **Pre-treatment periods:** 7 cohorts for bachelor's (2001-2019), 4 for sub-baccalaureate (2001-2016)
- **Treated clusters:** ~20+ states with MW increases during sample period (11→31 states above federal)
- **Post-treatment periods:** Multiple cohorts span the period of MW increases (ongoing treatment, not a single event)
- **Observations:** ~3,500 institution × cohort for bachelor's; ~1,500 for sub-baccalaureate; ~27,000 institution × CIP × cohort for field analysis
- **MDE:** With N~3,500, institutional FE, and a plausible R² ~ 0.8 for FE, should detect elasticities of ~0.02-0.05 at conventional significance levels

## Data Sources

1. **PSEO Time Series Earnings:** Census API (api.census.gov/data/timeseries/pseo/earnings) — institution × degree × CIP × cohort earnings at P25/P50/P75
2. **State Minimum Wages:** DOL historical data via Lislejoem GitHub (1968-2020, all states)
3. **State Economic Controls:** FRED API (unemployment rates, GDP), BEA (personal income, industry composition)
4. **Institution Characteristics:** College Scorecard API (sector, selectivity, size)
