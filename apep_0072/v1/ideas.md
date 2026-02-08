# Research Ideas

**Paper:** paper_96
**Date:** 2026-01-28
**Method:** Difference-in-Differences (Callaway-Sant'Anna)
**Risk Appetite:** Novel angle (classic policy + classic data + new question/method)

---

## Idea 1: Right-to-Work Laws and Workplace Safety

**Policy:** State Right-to-Work (RTW) laws adopted 2012-2017
- Indiana: February 2012
- Michigan: March 2013
- Wisconsin: March 2015
- West Virginia: February 2016
- Kentucky: January 2017
- *Note: Michigan repealed RTW in February 2024 (potential additional variation)*

**Outcome:** Workplace injury and fatality rates
- Primary: Fatal occupational injury rate per 100,000 FTE workers
- Secondary: Nonfatal injury/illness incidence rate per 100 FTE workers

**Data Source:** Bureau of Labor Statistics
- Census of Fatal Occupational Injuries (CFOI): State-level fatality counts and rates, 2003-2023
- Survey of Occupational Injuries and Illnesses (SOII): State-level nonfatal injury rates, varies by year

**Identification:** Staggered DiD with Callaway-Sant'Anna estimator using not-yet-treated states as controls.

**Why it's novel:** Existing research (BMJ 2018, AFL-CIO reports) uses correlational comparisons between RTW and non-RTW states. No published study applies modern heterogeneity-robust DiD estimators to the staggered adoption of RTW laws. This paper would provide the first clean causal estimate using contemporary econometric methods.

**Mechanism:** RTW laws reduce union density by eliminating mandatory union dues. Unions provide: (1) workplace safety training, (2) enforcement of safety standards through collective bargaining, (3) worker voice to report hazards without retaliation. Reduced union presence may degrade workplace safety.

**Feasibility check:**
- ✅ Variation exists: 5 states adopted RTW 2012-2017
- ✅ Data accessible: BLS CFOI/SOII publicly available
- ✅ Not overstudied: No modern DiD papers on this exact question
- ⚠️ Power concern: Only 5 treated states (similar to paper_94 limitation)
- ✅ Clear policy dates: State legislation with specific effective dates

---

## Idea 2: Telehealth Parity Laws and Mental Health Service Utilization (Pre-COVID)

**Policy:** State telehealth parity laws requiring private insurers to cover telehealth services, adopted 2010-2019
- 8 states had parity laws pre-2010; 30+ states adopted by 2019
- Treatment defined as: State enacts law requiring coverage parity OR payment parity for telehealth

**Outcome:** Mental health service utilization
- Primary: Share of adults receiving mental health treatment (past year)
- Secondary: Adults with major depressive episode who received treatment; days with poor mental health

**Data Source:**
- National Survey on Drug Use and Health (NSDUH): State-level estimates, 2010-2019
- BRFSS: State-level mental health days, 2010-2019

**Identification:** Staggered DiD with Callaway-Sant'Anna, restricting sample to 2010-2019 (pre-COVID) to avoid confounding from pandemic-era telehealth expansion.

**Why it's novel:** Most telehealth research examines post-COVID adoption or focuses on utilization broadly. This paper isolates the pre-COVID period when telehealth parity laws created plausibly exogenous variation, examining the specific outcome of mental health treatment—where access barriers are particularly high due to stigma and provider shortages.

**Mechanism:** Telehealth reduces barriers to mental health treatment: (1) eliminates travel time/costs, (2) increases scheduling flexibility, (3) reduces perceived stigma of in-person visits, (4) expands provider availability in underserved areas.

**Feasibility check:**
- ✅ Variation exists: ~22 states adopted parity laws 2010-2019
- ✅ Data accessible: NSDUH state estimates publicly available
- ⚠️ Novelty concern: Some pre-COVID telehealth studies exist; must differentiate
- ✅ Power: Many treated states provides adequate power
- ⚠️ Policy heterogeneity: Coverage vs. payment parity varies—may need to code carefully

---

## Idea 3: Certificate of Need (CON) Repeal and Rural Hospital Viability

**Policy:** State CON law repeals/substantial reforms, 2011-2021
- Wisconsin: Repealed 2011, fully phased out 2015
- New Hampshire: Repealed 2016
- Florida: Hospital CON eliminated 2019 (fully effective 2021)

**Outcome:** Rural hospital closures and financial viability
- Primary: Rural hospital closure indicator (binary)
- Secondary: Hospital operating margin, staffed beds per capita

**Data Source:**
- Sheps Center Rural Hospital Closures database (comprehensive list of closures since 2010)
- American Hospital Association (AHA) Annual Survey
- CMS Cost Reports

**Identification:** Staggered DiD comparing hospital closure rates in states that repeal CON laws to states that retain them.

**Why it's novel:** The CON literature focuses on market entry, prices, and competition. The specific effect on rural hospital closures—a major policy concern—has not been rigorously evaluated with modern DiD methods.

**Mechanism:** CON laws create barriers to entry that protect incumbent hospitals. Repeal could: (1) increase competition leading to lower margins and closures of marginal hospitals, OR (2) allow new entrants to fill gaps in underserved areas, reducing closure pressure on existing facilities.

**Feasibility check:**
- ⚠️ Limited variation: Only 3 states with full repeal 2011-2021
- ✅ Data accessible: Sheps Center data freely available
- ✅ Novel outcome: Rural closures not previously studied
- ⚠️ Power concern: Very few treated states
- ⚠️ Heterogeneous treatment: Partial vs. full repeal differs across states

---

## Idea 4: Paid Family Leave and Infant Immunization Rates (Expanded States)

**Policy:** State Paid Family Leave (PFL) programs adopted 2004-2021
- California: 2004
- New Jersey: 2009
- Rhode Island: 2014
- New York: 2018
- Washington: 2020
- Massachusetts: 2021
- Connecticut: 2022

**Outcome:** Infant immunization rates (on-time completion of recommended vaccines)
- Primary: % of children 19-35 months with DTaP 4+ doses, MMR, Hep B series complete
- Secondary: % of children up-to-date on combined vaccine series

**Data Source:** National Immunization Survey (NIS-Child), CDC, 2003-2022

**Identification:** Staggered DiD with Callaway-Sant'Anna using NIS state-level immunization estimates.

**Why it's novel:** While one study (Lichtman-Sadot & Bell, 2017) examined California's PFL effect on breastfeeding using NIS data, and several papers study labor market effects, the effect of the broader wave of PFL adoption (2014-2022) on infant immunizations has not been evaluated. This extends the single-state California analysis to a multi-state panel.

**Mechanism:** PFL provides time for parents to: (1) attend well-baby visits where vaccines are administered, (2) monitor for adverse reactions, (3) avoid schedule disruptions from work demands.

**Feasibility check:**
- ✅ Variation exists: 7 states with staggered adoption 2004-2022
- ✅ Data accessible: NIS state estimates available via CDC
- ⚠️ Partially studied: CA-only study exists; this extends to multi-state
- ✅ Power: More treated states than paper_94
- ✅ Clear policy dates: State legislation with specific start dates

---

## Summary Ranking (Pre-GPT)

| Idea | Novelty | Power | Data Access | Recommendation |
|------|---------|-------|-------------|----------------|
| 1. RTW → Safety | High | Low (5 states) | High | Consider |
| 2. Telehealth → Mental Health | Medium | High (20+ states) | Medium | Consider |
| 3. CON → Hospital Closures | High | Very Low (3 states) | High | Skip (power) |
| 4. PFL → Immunizations | Medium | Medium (7 states) | High | Consider |

**Top pick for Novel Angle mandate:** Idea 1 (RTW → Safety) or Idea 2 (Telehealth → Mental Health)
