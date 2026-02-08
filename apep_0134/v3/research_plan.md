# Initial Research Plan

## Research Question

Do supervised drug injection sites (overdose prevention centers) reduce overdose mortality in their surrounding neighborhoods?

## Revision Context

This is a major methodological revision of apep_0136. The parent paper had severe issues:
1. Level mismatch: East Harlem (42-92/100k) outside convex hull of controls (20-68/100k)
2. Standard SCM inappropriate per Abadie (2021), Ferman & Pinto (2021)
3. Figures used raw control means, not actual SCM output
4. Claims didn't match analysis results

## Identification Strategy

**Primary Method:** De-meaned Synthetic Control (Ferman & Pinto 2021)
- Subtract unit-specific pre-treatment means from all observations
- Match on within-unit variation rather than absolute levels
- Addresses convex hull violation

**Robustness Checks:**
- Generalized Synthetic Control (gsynth, Xu 2017)
- Standard DiD with randomization inference
- MSPE-based placebo tests

## Expected Effects

Given the methodological fix, we expect:
- Smaller effect sizes than originally claimed
- Higher p-values (less statistical significance)
- Honest null result is acceptable and valuable

## Exposure Alignment

**Who is actually treated?** OPCs are located in two UHF neighborhoods (East Harlem, Washington Heights). The treatment is neighborhood-level: all residents of the treated UHF are considered "exposed" regardless of whether they personally use the OPC.

**Primary estimand population:** Residents of treated neighborhoods (UHF 201, 203) who would have died of overdose in the absence of OPCs.

**Placebo/control population:** Residents of control neighborhoods (restricted donor pool, N=5 UHFs) who do not have OPC access.

**Design:** Two-way fixed effects DiD on de-meaned outcomes, with randomization inference for p-values. This is a standard place-based policy evaluation design.

## Primary Specification

```r
# De-mean outcomes
panel_demeaned <- panel_data %>%
  left_join(pre_treat_means, by = "uhf_id") %>%
  mutate(od_rate_dm = od_rate - pre_mean)

# Run DiD on de-meaned data
did_demeaned <- feols(
  od_rate_dm ~ i(year, treat, ref = 2021) | uhf_id + year,
  data = panel_demeaned,
  cluster = ~uhf_id
)
```

## Planned Robustness Checks

1. Generalized SCM (gsynth) with interactive fixed effects
2. Alternative donor pools (include/exclude Bronx)
3. MSPE ratio randomization inference
4. Permutation tests for p-values
