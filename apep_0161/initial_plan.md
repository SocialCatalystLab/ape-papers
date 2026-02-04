# Initial Research Plan (Revision of apep_0157 → v4)

## Research Question
Does state insulin copay cap legislation reduce diabetes mortality among working-age adults (25-64)?

## Identification Strategy
Staggered difference-in-differences exploiting the variation in adoption timing of insulin copay cap laws across 26 US states (2019-2024). Primary estimator: Callaway-Sant'Anna (2021).

## Key Improvements Over Parent (apep_0157)
1. **Working-age (25-64) outcome** from CDC WONDER as primary — reduces outcome dilution from s~3% to s~15-20%
2. **Fill 2018-2019 data gap** using CDC WONDER D76 database (continuous 1999-2020)
3. **Fix all 8 HIGH scan flags** from code integrity review
4. **Report both HonestDiD approaches** (relative magnitudes AND smoothness/FLCI)
5. **Vermont sensitivity analysis** (excluded, as-treated, as-control)
6. **Suppression sensitivity analysis** (bounds with imputed 0 and 9 deaths)

## Exposure Alignment
- **Who is actually treated?** Commercially insured insulin users in state-regulated plans (not self-insured ERISA, not Medicare, not Medicaid, not uninsured)
- **Primary estimand population:** Working-age adults 25-64 (excludes Medicare-eligible 65+)
- **Treated share of outcome population:** s ≈ 15-20% (working-age) vs s ≈ 3% (all-ages)
- **Placebo/control population:** Never-treated and not-yet-treated states (n=33)
- **Design:** Staggered DiD (not DDD) — state-level ITT capturing diluted effect of targeted intervention

## Expected Effects
Null effect expected, but more informative than all-ages null: MDE on treated subpopulation reduced 3-5x.

## Primary Specification
Working-age (25-64) diabetes mortality ~ treated | state_id + year, Callaway-Sant'Anna doubly robust estimator with never-treated controls and universal base period.

## Robustness Checks
- COVID sensitivity (excluding 2020-21, COVID controls)
- Wild cluster bootstrap
- HonestDiD (both approaches)
- Placebo outcomes (cancer, heart disease)
- Vermont sensitivity (3 specs)
- Suppression bounds
- All-ages replication
- Heterogeneity by cap amount
- Log specification
- State-specific trends
- Anticipation leads
