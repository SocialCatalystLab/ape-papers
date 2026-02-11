# Initial Research Plan: Fentanyl Test Strip Legalization and Synthetic Opioid Overdose Deaths

## Research Question

Does state legalization of fentanyl test strips reduce synthetic opioid overdose mortality? Fentanyl test strips (FTS) are immunoassay-based devices that detect fentanyl in drug samples. Most US states historically classified them as illegal drug paraphernalia. Beginning in 2018, states began removing FTS from paraphernalia definitions, allowing harm reduction organizations to distribute them. By 2023, approximately 40 states had legalized FTS, while 5 states (Idaho, Indiana, Iowa, North Dakota, Texas) retained their prohibition.

## Identification Strategy

**Staggered Difference-in-Differences** exploiting the differential timing of state FTS legalization across 2018-2023. We estimate:

$$Y_{st} = \alpha_s + \gamma_t + \beta \cdot FTS_{st} + X_{st}'\delta + \varepsilon_{st}$$

where $Y_{st}$ is the synthetic opioid overdose death rate per 100,000 in state $s$ and year $t$, $FTS_{st}$ is an indicator for whether state $s$ has legalized fentanyl test strips by year $t$, $\alpha_s$ and $\gamma_t$ are state and year fixed effects, and $X_{st}$ is a vector of time-varying controls.

**Primary estimator:** Callaway and Sant'Anna (2021) group-time ATT estimator, which avoids the "negative weighting" bias of TWFE under staggered adoption with heterogeneous treatment effects. We use the "never-treated" comparison group (5 states: ID, IN, IA, ND, TX) and separately the "not-yet-treated" comparison group for robustness.

**Event study:** Dynamic treatment effects for leads $k \in \{-5, ..., 0, ..., +4\}$ to validate the parallel trends assumption and trace out the treatment effect path.

## Expected Effects and Mechanisms

**Primary mechanism:** FTS allow people who use drugs to test their supply for fentanyl contamination before consumption, enabling harm avoidance behaviors: dose reduction, sequential dosing (testing a small amount first), ensuring naloxone is nearby, or avoiding contaminated batches entirely.

**Expected direction:** Negative — FTS legalization reduces synthetic opioid overdose deaths.

**Counterfactual concern:** The "moral hazard" argument suggests FTS could enable riskier drug use by providing false security. We test this by examining stimulant-involved deaths (cocaine, methamphetamine) separately — if FTS reduce fentanyl contamination deaths, stimulant + fentanyl polysubstance deaths should decline.

**Effect magnitude:** The existing TWFE study (Bhai et al. 2025) finds ~7% reduction overall and 13.5% among Black individuals. With CS-DiD methods (which correct for negative weighting), effects may differ.

## Primary Specification

1. **Outcome:** Synthetic opioid overdose death rate per 100,000 (ICD-10: T40.4 as contributing cause, X40-X44/X60-X64/X85/Y10-Y14 as underlying cause)
2. **Treatment:** Binary indicator = 1 if state legalized FTS by that year, with partial-year exposure coding (proportion of year after effective date)
3. **Sample:** 50 states + DC, 2013-2023 (11 years: 5 pre-treatment before first adoption, 6 years of staggered rollout)
4. **Controls:** State population, poverty rate, unemployment rate, naloxone access law indicator, syringe services program legality, PDMP mandated use indicator, Medicaid expansion status
5. **Fixed effects:** State and year (absorbed by CS-DiD group-time structure)
6. **Inference:** Cluster-robust at state level; wild cluster bootstrap (Webb 2023) for sensitivity; randomization inference

## Exposure Alignment (DiD)

- **Who is treated:** People who use drugs in states where FTS are legal. Treatment is at the state level (law change) but uptake depends on harm reduction infrastructure.
- **Primary estimand population:** All residents, measured via mortality rates
- **Placebo population:** Deaths from causes unrelated to drug use (cancers, cardiovascular, motor vehicle accidents)
- **Design:** Standard staggered DiD (not triple-diff)

## Power Assessment

- **Pre-treatment periods:** 5 years (2013-2017, before RI/MA adopt in 2018)
- **Treated clusters:** ~40 states (strong)
- **Post-treatment periods:** Varies by cohort: 5 years for 2018 cohort, 1 year for 2023 cohort
- **Control clusters:** 5 never-treated + late adopters serve as not-yet-treated
- **Baseline outcome:** ~15 synthetic opioid deaths per 100K nationally (2021). State-level variance is substantial (range: 2-50+ per 100K).
- **MDE estimate:** With 50 state-year clusters and ~10 years, we should detect effects ≥10% of the mean (1.5 deaths/100K) with reasonable power.

## Planned Robustness Checks

1. **Alternative estimators:** Sun & Abraham (2021) interaction-weighted, Borusyak et al. (2024) imputation-based
2. **Comparison group sensitivity:** Never-treated only vs. not-yet-treated
3. **HonestDiD bounds:** Rambachan & Roth (2023) sensitivity to linear pre-trend violations
4. **Partial-year exposure:** Binary treatment (any part of year) vs. fraction of year exposed
5. **Excluding early/late adopters:** Drop 2018 cohort (RI/MA) to test sensitivity to pioneers
6. **Concurrent policy controls:** Sequentially add naloxone access laws, SSP legality, PDMP mandates, Medicaid expansion
7. **Placebo outcomes:** Non-drug mortality (cancer, cardiovascular, motor vehicle)
8. **Subgroup analysis:** By race (Black, White, Hispanic), age group, urbanicity, baseline overdose rate quintile
9. **Dose-response:** Interact treatment with harm reduction infrastructure (# of syringe services programs per capita)
10. **Randomization inference:** Permute treatment timing across states (500 draws) to construct exact p-values
