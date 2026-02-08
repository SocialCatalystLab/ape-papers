# Research Ideas

## Idea 1: State Autonomous Vehicle Laws and Traffic Safety

**Policy:** State autonomous vehicle (AV) legislation permitting testing/operation on public roads
- Nevada: 2011 (first state)
- California: 2012
- Florida: 2012, expanded 2016
- Michigan: 2013
- Multiple states 2015-2020 wave

**Current status:** 29 states + DC have passed AV legislation; 7 states allow fully driverless operation (FL, GA, NV, NC, ND, UT, WV)

**Outcome:** Traffic fatality rates from FARS (Fatality Analysis Reporting System)
- Primary: Traffic fatalities per vehicle miles traveled by state-year
- Secondary: Pedestrian fatalities, intersection fatalities
- Mechanism: Could reduce human error accidents OR increase if technology fails

**Identification:** Staggered Difference-in-Differences using Callaway-Sant'Anna estimator
- Treatment: State-year of AV legislation effective date
- Unit: State × year
- Pre-treatment periods: 2005-2010 (before any AV laws)
- Treated states: 29 states with AV laws (staggered adoption)
- Never-treated: 21 states without explicit AV legislation

**Why it's novel:**
1. AV legislation effects on safety outcomes are theoretically ambiguous
2. No existing APEP paper on this topic
3. Policy highly relevant as AV deployment accelerates
4. Large number of treated states with staggered timing addresses few-clusters concern

**Feasibility check:**
- ✓ Variation: 29 treated states with staggered adoption over 10+ years
- ✓ Data access: FARS is publicly available, comprehensive, state×year
- ✓ Novelty: Not in APEP list
- ✓ Sample size: 50 states × 20 years = 1,000 observations
- ⚠ Treatment intensity varies: Some laws are permissive, others restrictive
- ⚠ Actual AV deployment is still very limited - may see null effects

**Theoretical contribution:** Tests whether regulatory frameworks enabling AV testing affect traffic safety, distinguishing early-adopter states from late-adopters.

---

## Idea 2: State Data Privacy Laws and Technology Sector Business Formation (REVISED)

**Policy:** Comprehensive state consumer data privacy laws (CCPA-style) - FOCUS ON 2023+ WAVE
- **Primary treatment group (2023+ cohort):**
  - Virginia VCDPA: Effective Jan 1, 2023
  - Colorado CPA: Effective July 1, 2023
  - Connecticut CTDPA: Effective July 1, 2023
  - Utah UCPA: Effective Dec 31, 2023
  - Iowa: Effective Jan 1, 2025
  - Indiana, Tennessee, Montana, Oregon, Texas: 2024 effective dates
- **Secondary/robustness (early adopter):**
  - California CCPA: Effective Jan 1, 2020 - analyzed separately via Synthetic Control Method due to COVID confounding

**Outcome:** Business applications in Information sector (NAICS 51)
- Primary: High-propensity business applications in NAICS 51 (Information) by state-month
- Secondary: Total business applications in NAICS 51
- Mechanism: QCEW employment in NAICS 51

**Identification:** Combined Staggered DiD + Synthetic Control Method
1. **Primary design:** Staggered DiD (Callaway-Sant'Anna) for 2023+ adopters only
   - Treatment: State-month of privacy law effective date
   - Unit: State × month
   - Pre-treatment: 2020-2022 (post-COVID recovery, pre-treatment)
   - Post-treatment: 2023-2025 (clean post-COVID window)
   - Treated states: VA, CO, CT, UT, IA, IN, TN, MT, OR, TX = 10+ treated units
   - Never-treated: ~35 states without comprehensive privacy laws

2. **Secondary design:** Synthetic Control Method for California (2020)
   - Donor pool: Non-privacy states
   - Pre-treatment: 2015-2019
   - Post-treatment: 2020-2024
   - Addresses COVID confounding through SCM's unit-specific counterfactual

**Why it's novel:**
1. First wave of state privacy laws just became effective (2020-2024)
2. Compliance costs may reduce startup formation OR privacy protection may attract data-conscious consumers
3. Directly policy-relevant as more states consider CCPA-style laws
4. Novel methodological contribution: combining SCM for early adopter with staggered DiD for later wave

**Feasibility check (REVISED):**
- ✓ Variation: 10+ treated states in 2023-2024 wave with clean timing
- ✓ Data access: FRED BABANAICS51SAXX (Information sector) by state confirmed accessible
- ✓ Novelty: Not in APEP; very new policy area
- ✓ Timing: 2023+ wave is post-COVID recovery
- ✓ Outcome alignment: NAICS 51 (Information) is more tightly aligned than broad NAICS 62 or 54
- ⚠ Short post-period: Most 2023 adopters have ~18-24 months post-treatment (acceptable for monthly data)

**Theoretical contribution:** Tests whether comprehensive privacy regulation suppresses or stimulates data-intensive entrepreneurship. CCPA-style laws impose compliance costs (reducing entry) but may also signal consumer protection (attracting privacy-conscious firms/consumers).

---

## Idea 3: State PBM Spread Pricing Bans and Pharmacy Closures

**Policy:** State laws banning "spread pricing" by Pharmacy Benefit Managers
- West Virginia: 2017 (first "Share the Savings" law)
- Maine: 2019 (rebate pass-through)
- Louisiana, New York, California: 2019-2021 (various fiduciary/transparency requirements)
- Iowa, Nevada, Oregon: 2023 (340B protections)

**Outcome:** Independent pharmacy closures/establishments from County Business Patterns
- Primary: Number of pharmacies (NAICS 446110) by state-year
- Secondary: Pharmacy employment

**Identification:** Staggered DiD comparing states with strong PBM regulation vs. weak/no regulation

**Why it's novel:**
1. PBM regulation is exploding (43 states considered bills in 2023)
2. Independent pharmacy closures are a major policy concern, especially in rural areas
3. Causal effect of PBM regulation on pharmacy market structure is unstudied

**Feasibility check:**
- ✓ Variation: Many states, staggered timing
- ✓ Data: County Business Patterns pharmacy counts available
- ⚠ Heterogeneous treatment: Laws vary significantly in scope and strength
- ⚠ Measurement: "Strong" vs "weak" regulation is subjective

---

## Ranking

**PURSUE: Idea 2 (Data Privacy Laws - REVISED)**
- Strongest identification: 10+ treated states in 2023-2024 wave with clean post-COVID timing
- Addresses COVID confounding: Primary design excludes California; SCM for California as robustness
- Tight outcome: NAICS 51 (Information sector) directly affected by data privacy compliance
- Novel question: First causal evidence on how comprehensive state privacy laws affect startup formation
- Methodological contribution: Combined SCM + staggered DiD design

**SKIP: Idea 1 (Autonomous Vehicle Laws)**
- Critical flaw: Outcome dilution (AV share of VMT is <1% even in permissive states)
- AV legislation enables testing but actual deployment is too limited to affect statewide fatalities
- Would need city/county-level data on AV deployment to rescue this design

**SKIP: Idea 3 (PBM Regulation)**
- Treatment heterogeneity is too severe
- Hard to classify states as "treated" vs "control" when all 50 states have some PBM law
- CBP timing misalignment (March snapshot) makes causal inference fragile
