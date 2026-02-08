# Initial Research Plan

**Paper:** 81
**Title:** Cooling the Workplace: The Effects of State Occupational Heat Standards on Worker Safety
**Date:** 2026-01-26

---

## Research Question

Do state-level occupational heat illness prevention standards reduce heat-related worker injuries and fatalities?

---

## Policy Background

Extreme heat is a growing occupational hazard, with climate change increasing the frequency and intensity of heat waves. Workers in outdoor industries (agriculture, construction, landscaping) and indoor environments without adequate climate control face elevated risks of heat-related illness and death.

In the absence of a federal OSHA standard, five states have adopted comprehensive occupational heat illness prevention rules:

| State | Effective Date | Scope | Key Requirements |
|-------|----------------|-------|------------------|
| California | Aug 1, 2005 | Outdoor | Shade, water, rest at 95°F; high-heat procedures at 105°F |
| Minnesota | Historic | Indoor | Temperature standards 77-86°F based on workload |
| Washington | July 17, 2023 | Outdoor | Year-round; 52°F monitoring trigger; 80°F protections; 90°F mandatory breaks |
| Oregon | June 15, 2022 | Indoor & Outdoor | 80°F trigger; shade, water, acclimatization; emergency plans |
| Colorado | 2021 | Agricultural | 80°F trigger for agricultural workers |
| Maryland | Sept 2024 | Indoor & Outdoor | 80°F heat index trigger; acclimatization; rest breaks |

The federal OSHA heat rule remains in the proposed stage (published August 2024, public comment period ended January 2025).

---

## Identification Strategy

### Primary Approach: Stacked Difference-in-Differences with Synthetic Controls

Given the small number of treated states (<10), standard two-way fixed effects (TWFE) DiD is inappropriate. Following GPT ranking recommendations, I will use:

1. **Synthetic Control Method (SCM)** for each treated state individually, constructing synthetic controls from never-treated states
2. **Stacked DiD** with cohort-specific treatment timing
3. **Wild cluster bootstrap** for inference with few clusters
4. **Randomization inference** for synthetic control p-values

### Treatment Definition

To address mid-year effective dates and ensure full treatment exposure:
- **First treated year** = first full calendar year after effective date
- California: 2006 (law effective Aug 2005)
- Oregon: 2023 (law effective June 2022)
- Washington: 2024 (revision effective July 2023)
- Colorado: 2022 (law effective 2021)
- Maryland: 2025 (law effective Sept 2024)

### Comparison Group

- Never-treated states (no heat standard as of end of sample)
- For robustness: restrict to high-heat states (states with above-median heat-related fatality rates pre-treatment)

### Outcome Variables

**Primary outcome:** Heat-related occupational fatalities per 100,000 workers
- Source: BLS Census of Fatal Occupational Injuries (CFOI)
- Event code: "Exposure to environmental heat" (BLS event code 5211)

**Secondary outcomes:**
- Heat-related nonfatal occupational injuries/illnesses
  - Source: BLS Survey of Occupational Injuries and Illnesses (SOII) where state data available
- All-cause occupational fatalities in high-risk industries (agriculture, construction)
  - Source: CFOI by industry

### Expected Effects and Mechanisms

**Mechanism:** Heat standards require employers to provide preventive measures (shade, water, rest breaks, acclimatization) that directly reduce physiological heat stress.

**Expected direction:** Negative effect on heat-related injuries/fatalities

**Magnitude benchmark:** Prior California research (Health Affairs, 2025) found ~33% reduction in heat-related worker deaths. We expect similar or smaller effects for newer standards, which may have weaker enforcement.

---

## Primary Specification

For state $s$ and year $t$:

$$Y_{st} = \alpha_s + \gamma_t + \beta \cdot \text{HeatStandard}_{st} + \epsilon_{st}$$

Where:
- $Y_{st}$ = heat-related fatalities per 100,000 workers
- $\alpha_s$ = state fixed effects
- $\gamma_t$ = year fixed effects
- $\text{HeatStandard}_{st}$ = 1 if state $s$ has heat standard in effect for full year $t$
- Standard errors clustered at state level with wild cluster bootstrap

For synthetic control:
- Pre-treatment RMSPE minimized over heat fatality rate, employment share in outdoor industries, average summer temperature
- Post-treatment effects estimated as gap between treated and synthetic control

---

## Planned Robustness Checks

1. **Event study specification** to assess pre-trends
2. **Placebo test:** Effect on non-heat-related fatalities (shouldn't change)
3. **Placebo test:** Effect on office/retail workers (should not be affected by outdoor heat rules)
4. **Triple-difference:** Compare outdoor vs. indoor workers within treated states
5. **Restrict comparison to high-heat states only**
6. **Alternative treatment timing:** Use actual effective month with fractional exposure
7. **Leave-one-out:** Drop California (largest, longest treated)
8. **Callaway & Sant'Anna estimator** for heterogeneous treatment effects across cohorts

---

## Data Sources

| Data | Source | Years | Geography |
|------|--------|-------|-----------|
| Fatal injuries | BLS CFOI | 1992-2023 | State |
| Nonfatal injuries | BLS SOII | 2003-2022 | State (participating) |
| Employment | BLS QCEW | 1990-2023 | State × Industry |
| Temperature | NOAA NCEI | 1990-2023 | State |
| Policy dates | State OSHA websites, NCSL | - | State |

---

## Power Assessment

- **Pre-treatment periods:** 10+ years for California; 3-5 years for recent adopters
- **Treated clusters:** 5-6 states
- **Post-treatment periods:** 18 years for CA; 1-2 years for WA/OR
- **Baseline outcome:** ~35 heat-related fatalities/year nationally; ~3.5 per 100,000 outdoor workers

**Power concern:** Heat fatalities are rare events (~30-40 nationally per year, ~0.3 per state-year on average). With high variance and few treated states, we may be underpowered to detect small effects. Synthetic control with permutation inference addresses this partly, but null results should be interpreted cautiously.

---

## Potential Threats to Identification

1. **Selection into treatment:** States with worse heat problems may adopt standards → upward bias in baseline
   - *Mitigation:* Control for pre-treatment heat fatality trends; restrict to high-heat comparison states

2. **Concurrent policies:** Wildfire smoke rules (OR, WA), general OSHA emphasis
   - *Mitigation:* Placebo on non-heat outcomes; event study for timing

3. **Measurement error:** Heat fatalities may be underreported; reporting practices may change with policy
   - *Mitigation:* Use consistent CFOI coding; note that policy-induced better reporting would bias toward finding effects

4. **Few treated clusters:** Standard asymptotic inference fails
   - *Mitigation:* Wild cluster bootstrap; randomization inference; transparent sensitivity

---

## Timeline

1. Data collection and cleaning
2. Construct treatment indicators and outcomes
3. Descriptive analysis and pre-trends
4. Main estimation (SCM + stacked DiD)
5. Robustness checks
6. Write paper

---

## Contribution

This paper provides the first multi-state causal evaluation of occupational heat standards beyond California. As climate change increases heat exposure and federal regulation remains pending, understanding the effectiveness of state standards is critical for policy design.
