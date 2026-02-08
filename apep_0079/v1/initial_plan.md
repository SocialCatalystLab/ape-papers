# Initial Research Plan

## Title
Free Lunch for the Whole Family? Universal School Meals and Household Food Security

## Research Question
Do state universal free school meals policies reduce household-level food insecurity beyond the direct beneficiaries (schoolchildren)?

## Motivation
Between 2022 and 2023, nine U.S. states adopted universal free school meals policies, providing breakfast and lunch to all public school students regardless of family income. While a substantial literature documents the effects of school nutrition programs on student outcomes (attendance, achievement, health), the household-level resource reallocation effects remain understudied.

When families no longer pay for school meals—even partial copays under the National School Lunch Program—freed resources may improve food provisioning for the entire household. This "resource reallocation" mechanism is distinct from the direct nutrition effect on children. The magnitude of this spillover is policy-relevant for understanding the full welfare effects of universal meal programs.

## Policy Treatment
**Universal Free School Meals Laws**

| State | Effective Date | School Year |
|-------|---------------|-------------|
| California | Aug 2022 | 2022-23 |
| Maine | Aug 2022 | 2022-23 |
| Massachusetts | Aug 2022 | 2022-23 |
| Nevada | Aug 2022 | 2022-23 |
| Vermont | Aug 2022 | 2022-23 |
| Colorado | Aug 2023 | 2023-24 |
| Michigan | Aug 2023 | 2023-24 |
| Minnesota | Aug 2023 | 2023-24 |
| New Mexico | Aug 2023 | 2023-24 |

Note: Two treatment cohorts—2022 (5 states) and 2023 (4 states). This provides staggered adoption for DiD.

## Identification Strategy
**Staggered Difference-in-Differences** using the Callaway-Sant'Anna (2021) estimator, which:
1. Avoids negative weighting problems in two-way fixed effects
2. Provides group-time ATT estimates for heterogeneity analysis
3. Allows clean event-study visualization

**Comparison group:** Never-treated states (41 states + DC that did not adopt universal meals by 2024)

**Key identifying assumption:** Absent universal meal policies, treated and control states would have followed parallel food insecurity trends.

### Threats to Identification

1. **Coincident federal policy changes:**
   - SNAP Emergency Allotments ended Feb-Mar 2023 (all states)
   - P-EBT phased out by state throughout 2022-2023

   *Mitigation:* Control for state-year SNAP EA/P-EBT status; all states faced these changes, so federal variation is absorbed by year FEs

2. **Selection into treatment:**
   - States adopting universal meals may have stronger social safety nets

   *Mitigation:* State fixed effects absorb time-invariant differences; event-study shows pre-trend patterns

3. **Small number of treated clusters (9 states):**

   *Mitigation:* Wild cluster bootstrap and randomization inference for valid p-values

## Data
**Current Population Survey Food Security Supplement (CPS-FSS)**
- Source: IPUMS CPS
- Years: 2015-2024 (7 pre-treatment years, 2 post-treatment years)
- Sample: Households with at least one child aged 5-17
- Variables:
  - FSSTAT: Household food security status (secure, low, very low)
  - FSSTATUSC: Food security among children
  - State identifiers (STATEFIP)
  - Household demographics for controls

## Primary Specification

$$Y_{ist} = \alpha + \sum_{g}\sum_{t} \mathbb{1}[G_i = g] \cdot \mathbb{1}[T = t] \cdot ATT(g,t) + X_{ist}\beta + \gamma_s + \delta_t + \varepsilon_{ist}$$

Where:
- $Y_{ist}$: Food insecurity indicator for household $i$ in state $s$ at time $t$
- $G_i$: Treatment cohort (2022, 2023, or never-treated)
- $ATT(g,t)$: Group-time average treatment effect
- $X_{ist}$: Household controls (income, HH size, race, urban/rural)
- $\gamma_s$: State fixed effects
- $\delta_t$: Year fixed effects

**Aggregation:** ATT estimates will be aggregated to:
1. Overall ATT (simple average)
2. Dynamic ATT (event-study by relative year)
3. Group-specific ATT (2022 vs 2023 cohort)

## Outcome Variables

**Primary:**
1. `food_insecure`: Binary indicator for low or very low food security (FSSTAT = 2 or 3)
2. `food_insecure_children`: Binary for food insecurity among children (FSSTATUSC)

**Secondary:**
3. `very_low_food_security`: Binary for very low food security (most severe)
4. Food spending outcomes if available

## Expected Effects and Mechanisms

**Direction:** Negative (universal meals should *reduce* food insecurity)

**Magnitude:** Modest effect sizes expected. National School Lunch Program participants typically paid ~$2/meal. For a household with 2 children, universal meals save ~$20/week or ~$700/school year—meaningful for low-income families but not transformative.

**Prior:** USDA ERS (2024) found 1-2 pp reduction in child food insufficiency in states with universal meals. Household-level effects may be similar or slightly smaller.

**Mechanisms:**
1. Direct resource savings (avoided meal costs)
2. Reduced stigma increases participation → more meals consumed at school → less home food needed
3. Administrative simplification frees parent time

**Heterogeneity predictions:**
- Stronger effects for low-income households (higher marginal utility of freed resources)
- Stronger effects for households with multiple school-age children (more savings)
- Weaker effects for households already receiving free meals under NSLP (no marginal savings)

## Robustness Checks

1. **Pre-trend tests:** Event-study coefficients for t < 0 should be statistically insignificant and close to zero
2. **HonestDiD bounds:** Sensitivity analysis allowing for linear pre-trends
3. **Placebo outcomes:** Employment, general health (should not respond to meal policy)
4. **Alternative samples:**
   - All households with children (not just 5-17)
   - Low-income subsample only
   - Exclude states with concurrent major policy changes
5. **Alternative inference:**
   - Wild cluster bootstrap p-values
   - Randomization inference p-values
   - Leave-one-out (drop each treated state)
6. **SNAP/P-EBT controls:** Add state-year indicators for concurrent food assistance changes

## Power Assessment

- **Treated states:** 9
- **Pre-treatment years:** 7 (2015-2021)
- **Post-treatment years:** 2 (2022-2024, with 2022 partial for first cohort)
- **Sample size:** CPS-FSS ~50,000 households/year, ~30% have children 5-17 ≈ 15,000/year
- **Baseline food insecurity rate:** ~11% for households with children

**Minimum Detectable Effect (rough calculation):**
With 9 treated clusters and limited post-periods, MDE is likely 1.5-2.5 pp using conventional inference. Wild bootstrap may widen confidence intervals.

## Deliverables

1. **Main Table:** DiD estimates for household food insecurity
2. **Event-Study Figure:** Dynamic treatment effects (-4 to +2 relative years)
3. **Heterogeneity Table:** Effects by income, number of children, baseline NSLP eligibility
4. **Robustness Table:** Alternative inference methods, specifications, samples

## Potential Limitations

1. **Short post-treatment period:** Only 1-2 post years limits ability to detect medium-run effects
2. **Few treatment clusters:** 9 states constrains inference despite bootstrap corrections
3. **Treatment timing clustering:** 5 of 9 states adopted in 2022; limited cohort variation
4. **Concurrent COVID recovery:** General economic improvements 2022-2024 may confound
5. **CPS-FSS measurement:** Annual retrospective recall may smooth seasonal variation

## Timeline

1. Fetch CPS-FSS data via IPUMS → `code/01_fetch_data.R`
2. Clean and construct analysis sample → `code/02_clean_data.R`
3. Run main DiD analysis → `code/03_main_analysis.R`
4. Robustness checks → `code/04_robustness.R`
5. Generate figures → `code/05_figures.R`
6. Generate tables → `code/06_tables.R`
7. Write paper → `paper.tex`
