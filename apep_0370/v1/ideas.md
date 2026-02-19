# Research Ideas

## Idea 1: Click to Prescribe — Do Electronic Prescribing Mandates Reduce Opioid Overprescribing?

**Policy:** State mandates requiring electronic prescribing for controlled substances (EPCS). 34 states enacted EPCS mandates with staggered adoption from 2011 (Minnesota) to 2024 (Illinois). Major cohorts: 6 states in 2020, 14 states in 2021, 6 states in 2022. Federal CMS mandate for Medicare Part D effective January 2023.

**Outcome:** CDC Vital Statistics Rapid Release (VSRR) drug overdose death data (Socrata API: data.cdc.gov/resource/xkb8-kh2a), available 2015-2025 by state, with drug-class-specific indicators including:
- Natural & semi-synthetic opioids (T40.2) — prescription opioid deaths (TREATED outcome)
- Synthetic opioids excl. methadone (T40.4) — illicit fentanyl deaths (PLACEBO outcome)
- Total opioid deaths (T40.0-T40.4, T40.6)

**Identification:** Staggered difference-in-differences using Callaway-Sant'Anna (2021) estimator. Treatment = state EPCS mandate effective date. 34 treated states, ~16 never-treated (as of 2022) comparison states. Pre-treatment periods: 5+ years for the 2020-2022 cohorts (main analysis window).

**Why it's novel:**
1. EPCS mandates are a DISTINCT policy from PDMPs — PDMPs are monitoring/information systems; EPCS mandates the technological FORMAT of prescriptions (electronic vs paper). No economics paper applies modern DiD to EPCS mandates.
2. Built-in placebo test: EPCS mandates should affect PRESCRIPTION opioid deaths (T40.2) but NOT illicit fentanyl deaths (T40.4). This differential prediction is a powerful falsification strategy.
3. One existing study (Yang et al. 2020, JAMA Network Open) found EPCS was associated with INCREASED prescribing — but used cross-sectional variation in voluntary adoption, not causal estimation from mandates. My staggered DiD on mandates provides causal identification.
4. Policy relevance: The opioid crisis killed 80,000 Americans in 2023. Understanding which policy levers actually work (vs creating compliance burden) is critical.

**Feasibility check:**
- ✅ Variation: 34 states, staggered 2011-2024
- ✅ Data access: CDC VSRR Socrata API tested and confirmed (state × month × drug class)
- ✅ Novelty: Not in APEP list, not in economics literature with modern DiD
- ✅ Sample size: ~100K overdose deaths/year nationally; state-year cells have sufficient counts
- ✅ Pre-treatment: 5+ years for main cohorts (2020-2022)
- ⚠️ Limitation: Most adoption clustered in 2020-2022; early adopters (MN 2011, NY 2016) have limited pre-treatment in detailed VSRR data

**DiD Feasibility Screen:**
- Pre-treatment periods: ≥5 years for 2020+ cohorts ✓
- Treated clusters: 34 states ✓✓
- Selection into treatment: Driven by state legislative cycles, not outcome trends ✓
- Comparison group: ~16 never-treated states through 2022 ✓
- Outcome-policy alignment: EPCS mandates → prescribing format → prescribing rates → overdose deaths ✓


## Idea 2: Banning the "Cure" — Conversion Therapy Bans and Youth Suicide Mortality

**Policy:** State laws prohibiting licensed healthcare providers from subjecting minors to sexual orientation/gender identity change efforts ("conversion therapy"). 25+ states enacted bans with staggered adoption from 2012 (California) to 2024 (Pennsylvania).

**Outcome:** CDC WONDER underlying cause of death data: youth (ages 10-24) suicide mortality rates by state and year (ICD-10 codes X60-X84, Y87.0). Also CDC VSRR for more recent years.

**Identification:** Staggered DiD using CS estimator. 25+ treated states, ~25 never-treated comparison states.

**Why it's novel:**
1. One existing study (Overhage et al. 2025, HSR) used only 4 treatment states with YRBSS self-reported suicidal ideation data through 2019. My design uses 25+ states with MORTALITY data — a harder outcome that's not subject to self-report bias.
2. Economics literature has not studied conversion therapy bans causally.
3. Counter-intuitive results possible: bans may not affect mortality if conversion therapy was already rare (prevalence <5% of LGBTQ youth), or if banned practitioners simply operate informally.

**Feasibility check:**
- ✅ 25+ treated states, staggered 2012-2024
- ✅ CDC WONDER mortality data available 1999-2023
- ✅ Not in APEP list
- ⚠️ Power concern: conversion therapy affects ~2-5% of LGBTQ youth (themselves ~15% of teen population), so population-level mortality effects may be very small
- ⚠️ Youth suicide is rising secularly — parallel trends assumption may be challenging


## Idea 3: From Pump Room to Paycheck — Workplace Lactation Accommodation Laws and Maternal Employment

**Policy:** State laws mandating employers provide break time and private space for breastfeeding employees. 34+ states enacted workplace lactation laws with staggered adoption from 2007 to 2022 (before the federal PUMP Act created a national baseline in December 2022).

**Outcome:** Current Population Survey (CPS) maternal employment rates — specifically, labor force participation and work hours for women with children under age 1, by state and year. Also ACS employment data.

**Identification:** Staggered DiD. Treatment = state lactation accommodation law effective date. ~34 treated states, ~16 never-treated comparison states (pre-federal mandate). Study period: 2002-2022 (pre-PUMP Act).

**Why it's novel:**
1. Zero economics papers study lactation accommodation laws with causal methods. Existing research is entirely policy/public health descriptive.
2. Distinct from paid family leave (extensively studied in APEP) — PFL funds time OFF work; lactation accommodation supports breastfeeding AT work. The mechanisms and affected populations differ.
3. Interesting economics: If breastfeeding is a normal good but workplace incompatible, accommodation laws reduce the cost of combining work with breastfeeding → faster return to work, higher hours conditional on working.

**Feasibility check:**
- ✅ 34+ treated states
- ✅ CPS publicly available via Census API
- ✅ Not in APEP list, zero economics literature
- ⚠️ CPS state-year cells for mothers of infants may be small (need to verify sample size)
- ⚠️ Laws vary in strength (some require paid breaks + dedicated room, others just allow breaks)
