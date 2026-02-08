# Initial Research Plan

## Research Question

Does state-level paid family leave (PFL) increase female entrepreneurship, measured by transitions into self-employment among women of childbearing age?

## Motivation

Paid family leave provides a safety net that may reduce "entrepreneurship lock" - the phenomenon where potential entrepreneurs avoid self-employment because they would lose access to employer-provided benefits. This is particularly relevant for women, who face disproportionate caregiving responsibilities. By providing wage replacement during leave periods, PFL may enable women to pursue self-employment without sacrificing family formation.

## Policy Variation

Staggered state adoption of paid family leave:

| State | Benefits Began | First Full Treated Year |
|-------|----------------|------------------------|
| California | July 2004 | 2005 |
| New Jersey | July 2009 | 2010 |
| Rhode Island | Jan 2014 | 2014 |
| New York | Jan 2018 | 2018 |
| Washington | Jan 2020 | 2020 |
| DC | July 2020 | 2021 |
| Massachusetts | Jan 2021 | 2021 |
| Connecticut | Jan 2022 | 2022 |
| Oregon | Sep 2023 | 2024 |
| Colorado | Jan 2024 | 2024 |

Note: California has no pre-treatment period in ACS data (ACS 1-year starts 2005). Will exclude CA from primary analysis or use as a "always-treated" group.

## Identification Strategy

**Staggered Difference-in-Differences** using the Callaway-Sant'Anna (2021) estimator to address heterogeneous treatment timing and potential negative weighting issues.

**Treatment definition**: State-year is treated if PFL benefits were available for the full calendar year.

**Comparison groups**:
- Primary: States that never adopt PFL during sample period
- Robustness: Not-yet-treated states

## Outcome Variable

**Primary outcome**: Self-employment rate among women aged 25-44 (prime childbearing and early career years)

Measured from Census ACS 1-year estimates, Table B24080 (Sex by Class of Worker):
- Numerator: Female self-employed (incorporated + unincorporated)
- Denominator: Total female civilian employed population

**Secondary outcomes** (if data permit):
- Self-employment rate among women aged 25-44 with children under 5
- Incorporated vs. unincorporated self-employment separately
- Male self-employment (placebo test - PFL affects both sexes equally in policy but literature shows women more responsive to family policies)

## Expected Effects and Mechanisms

**Primary mechanism**: PFL reduces opportunity cost of self-employment for women planning families or with young children, because they retain access to wage replacement during leave even if self-employed.

**Expected direction**: Positive effect on female self-employment in treated states after PFL adoption.

**Effect size**: Given that PFL directly affects a subset of women (those with family leave needs), aggregate effects may be modest. Expecting 0.5-2 percentage point increase in self-employment rate among women 25-44, or 5-15% relative to baseline.

**Heterogeneity**: Effects may be larger for:
- Younger women (25-34) with higher fertility rates
- Mothers of young children
- Women in industries with lower baseline self-employment

## Primary Specification

$$Y_{st} = \sum_{g} \sum_{t \geq g} ATT(g,t) \cdot \mathbb{1}[G_s = g] \cdot \mathbb{1}[T = t] + \alpha_s + \lambda_t + \epsilon_{st}$$

Using Callaway-Sant'Anna estimator with:
- $G_s$: Treatment cohort (year state first has full-year PFL)
- $ATT(g,t)$: Group-time average treatment effect
- Never-treated states as comparison group
- State and year fixed effects
- Clustered standard errors at state level

## Robustness Checks

1. **Alternative control groups**: Not-yet-treated, last-treated
2. **Placebo tests**: Male self-employment, women 45+, pre-trend tests
3. **Honest DiD** (Rambachan & Roth): Sensitivity to pre-trend violations
4. **Alternative outcomes**: Incorporated only, unincorporated only
5. **Excluding California**: Drop "always-treated" state
6. **Triple-difference**: Women 25-44 vs. women 45+ within states (DDD)
7. **Event study**: Dynamic treatment effects by years since adoption

## Data Sources

1. **Census ACS 1-year estimates** (2005-2023)
   - Table B24080: Sex by Class of Worker
   - State-level aggregates
   - Can get age-specific with custom queries

2. **FRED** (for controls)
   - State unemployment rates
   - State GDP

3. **Policy dates**: DOL compilation of state PFL enactment and effective dates

## Sample

- **Geography**: All 50 states + DC
- **Years**: 2005-2023 (19 years)
- **Unit**: State-year
- **Observations**: ~970 state-years

## Threats to Identification

1. **Coincident policies**: PFL states may also adopt other progressive policies (paid sick leave, minimum wage increases). Will control for these where possible.

2. **Selection into treatment**: PFL adoption is politically determined and may correlate with pre-existing trends in female labor force participation. Will test pre-trends explicitly.

3. **Composition effects**: PFL may attract women to states, changing the composition of the female workforce. This is arguably part of the treatment effect.

4. **Small treatment clusters**: Only ~10 treated states. Will use wild cluster bootstrap for inference.

## Timeline Checkpoints

- [x] Phase 1: Setup and initialization
- [x] Phase 2: Discovery
- [x] Phase 3: Ranking
- [ ] Phase 4a: Write initial plan (this document)
- [ ] Phase 4b: Fetch data
- [ ] Phase 4c: Run analysis
- [ ] Phase 4d: Write paper
- [ ] Phase 5: Review & Revise
- [ ] Phase 6: Publish
