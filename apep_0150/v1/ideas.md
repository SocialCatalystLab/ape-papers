# Research Ideas

## Idea 1: State Insulin Copay Caps and Working-Age Diabetes Mortality (Redesigned)
**Policy:** State insulin copay cap laws limiting out-of-pocket insulin costs to $25-$100/month for commercially insured patients. Colorado first in 2019 (effective Jan 2020), followed by 28+ states through 2025 with staggered effective dates.
**Outcome:** State-level age-adjusted diabetes mortality rates for ages 25-64 (commercially-insured working-age population), ICD-10 E10-E14 as underlying cause of death, from CDC WONDER Multiple Cause of Death files, 1999-2023.
**Identification:** Staggered DiD using Callaway-Sant'Anna (2021) estimator. Treatment defined as the effective date of each state's insulin copay cap law. Never-treated and not-yet-treated states serve as controls.
**Why it's novel:** Existing literature focuses on insurance claims, adherence, and spending outcomes. No causal study examines whether copay caps translate to reduced mortality among the commercially insured population most directly affected by the policy. Working-age restriction (25-64) isolates the commercially insured population (excluding Medicare 65+). The age restriction also increases statistical power by reducing dilution from unaffected populations.
**COVID strategy:** (i) Include state-level COVID-19 death rates as time-varying controls; (ii) Show robustness to excluding 2020-2021; (iii) CS-DiD handles heterogeneous treatment timing and doesn't rely on never-treated comparisons contaminated by COVID; (iv) Use event-study plots showing pre-trends well before COVID (1999-2019).
**Feasibility check:** Confirmed: 25+ treated states with staggered adoption 2020-2025; CDC WONDER provides free annual state-level mortality data 1999-2023 by age group with 20+ pre-treatment years; sufficient treated clusters for standard inference; not studied by APEP. Data verified accessible via CDC WONDER web interface.

## Idea 2: State Mandatory Sexual Harassment Training Laws and EEOC Charge Filing Rates
**Policy:** State laws requiring employers to provide sexual harassment prevention training. Core mandating states: California (2005/2019 expanded), Connecticut (2019), Delaware (2019), Illinois (2020), Maine (2019), New York (2019), Washington (partial), DC.
**Outcome:** EEOC sexual harassment charge filing data by state.
**Identification:** Staggered DiD comparing mandating vs non-mandating states.
**Why it's novel:** Training mandates are widespread but understudied for effects on formal reporting behavior. Novel angle: do mandates increase reporting (awareness) or decrease harassment (deterrence)?
**Feasibility check:** CONCERN: Only ~6-8 states with comprehensive private-sector mandates, well below the ≥20 threshold. EEOC state-level data may not be available as a downloadable panel. RISKY — small treated cluster count.

## Idea 3: State Insulin Copay Caps and Diabetes-Related Emergency Department Visits
**Policy:** Same insulin copay cap laws as Idea 1.
**Outcome:** HCUP State Emergency Department Databases or CDC National Syndromic Surveillance Program for DKA-related ED visits.
**Identification:** Staggered DiD.
**Why it's novel:** Most proximal outcome — DKA is a direct consequence of insulin rationing.
**Feasibility check:** CONCERN: HCUP data requires purchase (not free). CDC NSSP data may not have state-level granularity for public access. Data access is a major barrier. SKIP unless free data source identified.

## Idea 4: State Laws Requiring Mental Health Education in K-12 Schools and Youth Suicide Rates
**Policy:** 20+ states require mental health education in schools, staggered 2016-2023. New York first (2016/effective 2018), Florida (2019), New Jersey (2019), Illinois (2021), California (2021/effective 2022), and others.
**Outcome:** Youth suicide rates (ages 10-24) from CDC WONDER, state-level, annual.
**Identification:** Staggered DiD with CS estimator.
**Why it's novel:** Mental health education mandates are recent and understudied for hard outcomes. Most research focuses on implementation, not causal effects on youth mental health outcomes.
**Feasibility check:** 20+ treated states, free CDC WONDER data, 15+ pre-treatment years. CONCERN: Implementation varies widely across states; law passage vs actual classroom implementation may differ significantly. Effect likely takes years to manifest. Moderate risk.
