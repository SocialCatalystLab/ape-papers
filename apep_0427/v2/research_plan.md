# Initial Research Plan: apep_0427

## Research Question

Do apprenticeship hiring subsidies create net new entry-level positions, or do they merely relabel existing junior hiring as subsidized training contracts? When subsidies are reduced, do firms cut back on youth hiring, substitute toward experienced workers, or maintain the training pipeline?

## Policy Context

France's "aide exceptionnelle à l'embauche d'alternants" introduced in July 2020 created the largest apprenticeship subsidy expansion in modern European history:
- **July 2020:** €5,000 for minors, €8,000 for adults (all firms)
- **January 2023:** Reduced to €6,000 flat (25% cut for adult apprentices)
- **February 2025:** Further reduced to €5,000 (<250 employees) / €2,000 (≥250 employees)
- **Result:** New contracts tripled from 306K (2017) to 879K (2024); cost ~€15B/year

## Identification Strategy

### Primary: Sector-Exposure Bartik DiD

**Treatment intensity:** Pre-reform (2019) sector-level apprenticeship rate
- Exposure_s = Apprenticeship contracts in sector s (2019) / Total employment in sector s (2019)
- High-exposure: Construction (~20%), Accommodation/Food (~18%), Retail (~12%)
- Low-exposure: Finance (~3%), Public admin (~2%), IT/Professional services (~5%)

**Time variation:** January 2023 subsidy reduction (primary shock), February 2025 reform (secondary shock)

**Specification:**
Y_{s,t} = β₁(Exposure_s × Post2023_t) + γ_s + δ_t + X_{s,t}Γ + ε_{s,t}

where Y is youth employment share, NEET rate, or vacancy index in sector s at quarter t.

### Secondary: Cross-Country DiD (Robustness)

France vs Belgium, Netherlands, Spain, Italy, Portugal
- Youth (15-24) vs prime-age (25-54) as additional comparison
- Callaway-Sant'Anna estimator for staggered treatment

### Tertiary: Indeed Vacancy Event Study

High-frequency (daily) job posting data around January 2023 reduction
- Compare high-apprenticeship sectors vs low-apprenticeship sectors
- Tests real-time firm behavioral response

## Expected Effects and Mechanisms

**Hypothesis 1 (Net creation):** Subsidies genuinely reduce the cost of entry-level hiring, creating positions that wouldn't exist otherwise. Reduction → negative effect on youth employment in high-exposure sectors.

**Hypothesis 2 (Relabeling):** Subsidies incentivize firms to reclassify existing junior positions as "apprenticeship" contracts. Reduction → minimal effect on total youth employment but shift from apprenticeship to regular contracts.

**Hypothesis 3 (Substitution):** When apprenticeship subsidies decrease, firms substitute toward experienced hires rather than paying full cost for juniors. Reduction → decreased youth employment share, increased experienced-hire share.

## Data Sources

1. **Eurostat `lfsi_emp_q`:** Youth employment rate by country, quarterly (2008-2025)
2. **Eurostat `lfsi_neet_q`:** NEET rate by country, quarterly
3. **Eurostat `lfsq_egan22d`:** Employment by NACE sector × age × country, quarterly
4. **Indeed Hiring Lab (GitHub):** Daily job posting indices by country and sector
5. **DARES:** Annual apprenticeship contract statistics (for exposure construction)
6. **FRED:** Additional macro controls (GDP growth, unemployment)

## Primary Specification

Triple-diff: France × High-exposure-sector × Post-January-2023

## Planned Robustness Checks

1. Permutation inference: randomize sector exposure assignment
2. Pre-trend tests: sector-specific trends before 2023
3. Placebo test: prime-age (25-54) workers should show no effect
4. Leave-one-sector-out: ensure no single sector drives results
5. Dose-response: continuous exposure measure
6. Cross-country DiD as alternative specification
7. Callaway-Sant'Anna heterogeneity-robust estimator
8. Indeed event study for high-frequency validation

## Power Assessment

- 21 NACE sections × ~28 quarters (2018Q1-2025Q3) = ~588 sector-quarter observations
- Pre-treatment: 2018Q1-2022Q4 = 20 quarters
- Post-treatment: 2023Q1-2025Q3 = 11 quarters
- Variation in exposure: substantial (range ~2% to ~20% apprenticeship intensity)
- Expected MDE: ~2-3 percentage points in youth employment share (feasible given the scale of the subsidy change)
