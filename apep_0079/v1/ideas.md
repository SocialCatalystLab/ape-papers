# Research Ideas

## Idea 1: Universal Free School Meals and Household Food Security
**Policy:** State universal free school meals laws (California 2022, Maine 2022, Massachusetts 2022, Nevada 2022, Vermont 2022, Colorado 2023, Minnesota 2023, Michigan 2023, New Mexico 2023)

**Outcome:** Household food insecurity measured via CPS Food Security Supplement (annual, state-level identifiers, available 1995-present)

**Identification:** Staggered DiD with 9 treated states adopting between 2022-2023. Pre-treatment period 2015-2021, post-treatment 2022-2024. Comparison group: never-treated states.

**Why it's novel:**
- Most existing research focuses on food insecurity among children directly or school meal participation rates
- Novel angle: Effect on *household-level* food security (the "freed-up resources" mechanism)
- Theory: When families no longer pay for school meals, freed resources allow better food provisioning for entire household
- Heterogeneity by baseline income and family composition

**Feasibility check:**
- [x] Variation exists: 9 states with staggered adoption 2022-2023
- [x] Data accessible: CPS-FSS via IPUMS with state identifiers
- [x] Not overstudied: One USDA ERS paper (2024) found effects on children's food insufficiency; no work on household-level food security
- [x] Pre-treatment periods: 7+ years (2015-2021)
- [x] Treatment clusters: 9 states (marginal but acceptable)

**Limitations:** Some states (CA, ME, MA, NV, VT) adopted in same year (2022), limiting within-cohort variation.

---

## Idea 2: State Data Privacy Laws and Technology Sector Employment
**Policy:** Comprehensive state data privacy laws (California CCPA 2020, Virginia 2023, Colorado 2023, Connecticut 2023, Utah 2023, Iowa 2025, Delaware 2025, etc.)

**Outcome:** Tech sector employment and wages from Quarterly Census of Employment and Wages (QCEW) via BLS, information sector (NAICS 51)

**Identification:** Staggered DiD with 20+ states adopting between 2020-2025. Use Callaway-Sant'Anna estimator.

**Why it's novel:**
- Literature focuses on compliance costs and consumer protection outcomes
- Novel angle: Labor market effects in tech sector (hiring freezes vs. compliance jobs)
- Could have heterogeneous effects: Large firms (CCPA threshold = $25M revenue) vs. small firms
- Mechanism: Compliance burden vs. consumer trust and market expansion

**Feasibility check:**
- [x] Variation exists: 20 states with staggered adoption 2020-2025
- [x] Data accessible: QCEW publicly available via BLS API
- [x] Not overstudied: Policy literature exists but no DiD on employment effects
- [x] Pre-treatment periods: 5+ years
- [x] Treatment clusters: 20+ states

**Limitations:** Heterogeneous law stringency (CCPA vs. others). Would need to code law strength.

---

## Idea 3: Right-to-Repair Laws and Independent Repair Shop Employment
**Policy:** State electronics right-to-repair laws (New York 2023, California 2024, Minnesota 2024, Oregon 2025, Colorado 2026)

**Outcome:** Employment in electronic and appliance repair services (NAICS 8112) from QCEW

**Identification:** Staggered DiD with 5 states. Very recent policy - limited post-treatment data.

**Why it's novel:**
- Completely unstudied policy from labor market perspective
- Theory: Right-to-repair reduces barriers to entry for independent repair shops
- Heterogeneity: Urban vs. rural, areas with Apple/authorized repair presence

**Feasibility check:**
- [x] Variation exists: 5 states with staggered adoption
- [x] Data accessible: QCEW via BLS API
- [x] Not overstudied: No academic literature on employment effects
- [ ] Pre-treatment periods: Limited (NY effective Dec 2023)
- [ ] Treatment clusters: Only 5 states

**Limitations:** Too recent - insufficient post-treatment data. **PARKING FOR FUTURE.**

---

## Idea 4: Guaranteed Income Pilots and Labor Supply (City-Level)
**Policy:** Municipal guaranteed income programs (Stockton 2019, St. Paul 2020, Denver 2022, Chicago 2022, multiple others)

**Outcome:** Labor force participation from ACS 1-year estimates at metro level

**Identification:** Synthetic control or DiD with city-level variation

**Why it's novel:**
- Most GI pilot evaluations are internal RCTs comparing treatment to control within pilot
- Novel angle: City-level spillover effects on labor market (general equilibrium)
- Does GI change reservation wages and labor supply at the market level?

**Feasibility check:**
- [x] Variation exists: 50+ pilots across different cities/times
- [x] Data accessible: ACS 1-year metro-level estimates
- [ ] Clear treatment definition: Pilots vary enormously in scale, duration, eligibility
- [ ] Sample size concerns: Most pilots are small (200-5000 people) - may not move city aggregates

**Limitations:** Treatment intensity too low for market-level effects. **SKIP.**

---

## Idea 5: State Universal Free School Meals and Academic Achievement
**Policy:** Same as Idea 1 (CA, ME, MA, NV, VT 2022; CO, MN, MI, NM 2023)

**Outcome:** NAEP 4th and 8th grade reading and math scores at state level

**Identification:** Staggered DiD with state-year NAEP data (biennial assessment)

**Why it's novel:**
- Extends "free lunch improves achievement" literature to universal programs
- Novel angle: Removes stigma of means-testing, may have different effects than targeted programs
- Heterogeneity: States with high vs. low baseline free/reduced price lunch participation

**Feasibility check:**
- [x] Variation exists: 9 states, staggered adoption
- [x] Data accessible: NAEP Data Explorer, state-level scores freely available
- [x] Not overstudied: COVID recovery papers exist, but not focused on universal meals policy
- [ ] Timing challenge: NAEP is biennial (2022, 2024); only one post-treatment observation for 2022 cohort
- [ ] Treatment clusters: 9 states

**Limitations:** Only 2 NAEP waves post-treatment (2022, 2024). May need to wait for 2026 wave. **CONSIDER BUT RISKY.**

---

## Summary

| Idea | Policy | Novel Angle | DiD Feasibility | Data Access | Recommend |
|------|--------|-------------|-----------------|-------------|-----------|
| 1 | Universal Free School Meals | Household food security | Strong (9 states, 7+ pre-periods) | CPS-FSS via IPUMS | **PURSUE** |
| 2 | Data Privacy Laws | Tech employment | Strong (20+ states) | QCEW via BLS | **PURSUE** |
| 3 | Right-to-Repair | Repair shop employment | Weak (5 states, too recent) | QCEW | SKIP |
| 4 | Guaranteed Income | City labor supply | Weak (treatment too dilute) | ACS | SKIP |
| 5 | Universal Meals | Academic achievement | Marginal (biennial NAEP) | NAEP | CONSIDER |

**Primary recommendation:** Idea 1 (Universal Free School Meals → Household Food Security) offers the strongest combination of policy novelty, causal identification, and data availability.
