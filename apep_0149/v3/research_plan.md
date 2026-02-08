# Initial Research Plan: Medicaid Postpartum Coverage Extensions and Insurance Continuity

## Research Question
Do state Medicaid postpartum coverage extensions (from 60 days to 12 months) reduce uninsurance and increase coverage continuity among women who recently gave birth?

## Identification Strategy
Staggered difference-in-differences (DiD) exploiting the temporal variation in state adoption of Medicaid postpartum extensions between 2021 and 2024. Using the Callaway and Sant'Anna (2021) estimator to avoid the biases of two-way fixed effects with staggered adoption.

## Exposure Alignment
- **Who is treated:** Women who gave birth and would have lost Medicaid coverage after 60 days postpartum. Approximately 42% of US births are Medicaid-financed.
- **Primary estimand population:** Women aged 18-44 who gave birth in the past 12 months (ACS FER=1), with income below 200% FPL (most likely Medicaid-eligible).
- **Placebo/control population:** (1) Higher-income women (>400% FPL) who gave birth — should not be affected by Medicaid policy. (2) Non-postpartum women of similar age/income — should not be directly affected.
- **Design:** DiD with triple-diff robustness (treated states × postpartum women × low-income)

## Critical Design Consideration: PHE Continuous Enrollment
The COVID-19 Public Health Emergency (PHE) enacted continuous enrollment in Medicaid from March 2020 through May 11, 2023. During this period, states could not disenroll Medicaid beneficiaries, meaning the 60-day postpartum limit was effectively non-binding. This creates a unique identification opportunity:
- States adopting during PHE (April 2021 - May 2023): Extension had no immediate "bite" on coverage
- States adopting after PHE (June 2023+): Extension immediately prevented coverage loss
- The PHE unwinding (starting April 2023) created a "turning on" of the treatment effect for early adopters

**Primary specification:** Focus on post-PHE outcomes (2023-2024 ACS data) where the extension has real bite. Use pre-PHE data (2017-2019) for parallel trends testing. Exclude 2020-2022 as the PHE "contaminated" period.

## Expected Effects and Mechanisms
1. **Primary:** Postpartum Medicaid coverage (+): Extension mechanically increases coverage duration from 2 months to 12 months → expect large increase in measured Medicaid coverage among recent mothers
2. **Secondary:** Uninsurance rate (-): Women who would have become uninsured after 60 days are now covered → expect decrease in uninsurance
3. **Heterogeneity:** Effects should be concentrated among low-income women (below 138% FPL in expansion states, below traditional Medicaid eligibility in non-expansion states)
4. **Null prediction:** No effect on employer-sponsored or private insurance coverage (these women weren't on Medicaid)

## Primary Specification
Y_{ist} = α_s + γ_t + β × Treatment_{st} + X_{ist}δ + ε_{ist}

Where:
- Y = Medicaid coverage (HINS4), uninsured (1-HICOV), private insurance (HINS1+HINS2)
- s = state, t = year, i = individual
- Treatment_{st} = 1 if state s has postpartum extension in effect by year t
- X = age, race, education, marital status, income, number of children
- Standard errors clustered at the state level
- Weights: PWGTP (ACS person weights)

CS-DiD specification: att_gt estimates group-time average treatment effects; aggregate to overall ATT, dynamic (event-study), and calendar-time effects.

## Planned Robustness Checks
1. **Event study:** Dynamic treatment effects using CS-DiD event-study plots
2. **Triple difference:** Add interaction with low-income status (below 200% FPL)
3. **Placebo outcomes:** Effects on employer insurance (HINS1) among same population — should be null
4. **Placebo population:** Effects on higher-income women (>400% FPL) — should be null
5. **Alternative estimators:** Sun & Abraham (2021), TWFE comparison
6. **PHE sensitivity:** (a) Include PHE period, (b) Exclude PHE period, (c) Interact treatment with PHE indicators
7. **Wild cluster bootstrap:** Given 50 state clusters, WCB for inference robustness
8. **Medicaid expansion heterogeneity:** Separate effects for states that expanded Medicaid under ACA vs. those that did not
9. **HonestDiD sensitivity:** Rambachan & Roth (2023) bounds on parallel trends violations

## Power Assessment
- Pre-treatment periods: 3 years clean (2017-2019, pre-PHE)
- Treated clusters: 48 states (near-universal adoption)
- Post-treatment periods: 1-2 clean years (2023-2024, post-PHE)
- Sample size: ~61,000 postpartum women per ACS year, ~488,000 total across 8 years
- MDE: ~2-3 percentage points given 48 clusters and CS-DiD
- Expected effect: 5-15 percentage points (mechanical increase from 2-month to 12-month coverage)

## Data Sources
1. **ACS 1-year PUMS** (2017-2024): Individual-level microdata with FER (fertility), insurance type, state, demographics
2. **KFF/CMS records**: State postpartum extension effective dates
3. **CDC WONDER** (supplementary): Maternal mortality data for appendix analysis
