# Research Ideas

## Idea 1: State Opioid Prescribing Limits and Labor Force Participation

**Policy:** State opioid prescribing duration and dosage limits for acute pain. Massachusetts became the first state in 2016 to limit initial prescriptions to 7 days; by end of 2019, 39 states had enacted such limits with durations ranging from 3-31 days.

**Outcome:** Labor force participation and employment rates from the Current Population Survey (CPS), focusing on working-age adults. The CPS provides monthly state-level employment data with demographic detail.

**Identification:** Difference-in-differences exploiting staggered state adoption from 2016-2019. Treatment timing is well-documented (Network for Public Health Law, Ballotpedia). Never-treated states provide comparison group. Use Callaway-Sant'Anna estimator for heterogeneous treatment effects.

**Why it's novel:**
- Explicit research gap: "To date, there is no data on whether and to what extent these laws...are associated with broader impacts" (Network for Public Health Law)
- Most research examines prescribing volumes or overdose deaths; labor market consequences are unstudied
- Novel mechanism: Do restrictions on pain management affect work capacity?

**Feasibility check:**
- ✓ Variation exists: 39 states adopted limits by 2019, staggered timing
- ✓ Data accessible: CPS via IPUMS or Census API
- ✓ Not overstudied: Explicit gap in literature
- ✓ Sample size: CPS provides ~100,000+ observations monthly
- ✓ Pre-treatment periods: Most adoptions 2016-2019, CPS data from 2010+

---

## Idea 2: State Minimum Wage Increases and New Business Formation

**Policy:** State minimum wage increases above the federal floor ($7.25 since 2009). 29 states plus DC have minimum wages above federal; many increased in steps (e.g., CA to $15 by 2022, NY to $15 by 2019-2021 depending on region).

**Outcome:** Census Business Formation Statistics (BFS) - monthly state-level data on new business applications, high-propensity business applications (likely to become employers), and applications with planned wages. Available July 2004-present.

**Identification:** Two-way fixed effects DiD with state and month fixed effects. Treatment is continuous (MW level) or binary (above-federal indicator). Event study around large MW increases (e.g., CA, NY, WA). Use Callaway-Sant'Anna with continuous treatment extension.

**Why it's novel:**
- Most MW research focuses on employment levels and wages; business formation is understudied
- Competing hypotheses: (1) Higher labor costs reduce business starts, (2) Higher MW formalizes economy by reducing informal competition, (3) Efficiency wage effects improve worker quality making new businesses viable
- New data: BFS only released publicly in 2018, available back to 2004

**Feasibility check:**
- ✓ Variation exists: 30+ large MW increases since 2014
- ✓ Data accessible: Census BFS public API, FRED
- ✓ Novel outcome: Business formation rarely studied for MW
- ✓ Sample size: Monthly state-level panel, 50 states × 20 years
- ✓ Pre-treatment: Data starts 2004, most large MW increases post-2014

---

## Idea 3: Recreational Marijuana Legalization and Workers' Compensation Claims

**Policy:** State recreational marijuana legalization (RML). Colorado and Washington first in 2012; now 24 states plus DC have legalized (as of 2024). Most laws include legal purchase age of 21.

**Outcome:** Workers' compensation claims and benefit receipt. BLS publishes state-level WC data; NBER/CPS supplements capture WC income receipt at individual level.

**Identification:** Staggered DiD with state and year fixed effects. Clear treatment dates (legalization effective dates). Use retail sales opening as robustness check (legal access vs. just legal possession).

**Why it's novel:**
- Prior search found 20% reduction in WC claims post-RML (NBER working paper), but mechanism unexplored
- Novel mechanisms: (1) Pain management substitution reduces opioid-related workplace accidents, (2) Marijuana impairment increases accidents, (3) Selection - injury-prone workers substitute marijuana for alcohol
- Policy relevance: Employers concerned about workplace safety post-legalization

**Feasibility check:**
- ✓ Variation exists: 24 states legalized 2012-2024, excellent staggered timing
- ✓ Data accessible: BLS state WC data, CPS for individual-level analysis
- ✓ Emerging literature: Room for contribution
- ✓ Sample size: Good state-year panel
- ✓ Pre-treatment: CO/WA data 2000-2012

---

## Idea 4: State Nurse Practitioner Full Practice Authority and Rural Mental Health Treatment

**Policy:** State laws granting nurse practitioners (NPs) full practice authority (FPA) - ability to practice without physician supervision. 27+ states now have FPA; 8 states adopted between 2011-2016, with more adopting since (e.g., Massachusetts 2021).

**Outcome:** Mental health treatment access and utilization in rural areas. BRFSS provides "mentally unhealthy days" and treatment utilization; CDC WONDER has mental health-related ED visits; Area Health Resource File has provider counts.

**Identification:** DiD exploiting staggered FPA adoption. Triple-difference: FPA × Rural × Post. Focus on states adopting post-2010 for clean identification.

**Why it's novel:**
- Existing NP research focuses on overall primary care access; mental health services specifically understudied
- Mental health services are especially amenable to independent NP practice (psychotherapy, medication management)
- Rural mental health crisis is severe; policy-relevant question
- Novel angle: Mental health outcomes rather than primary care utilization

**Feasibility check:**
- ✓ Variation exists: 8 states adopted 2011-2016, more since
- ✓ Data accessible: BRFSS public use files, CDC WONDER
- ✓ Novel angle: Mental health vs. general primary care
- ✓ Sample size: BRFSS ~400,000 annual observations
- ⚠️ Potential issue: FPA effects may be gradual (NP supply takes time to respond)

---

## Summary Ranking

| Idea | Novelty | Identification | Feasibility | Relevance | Overall |
|------|---------|----------------|-------------|-----------|---------|
| 1. Opioid Limits → LFP | Very High | High | High | High | **Top Choice** |
| 2. Min Wage → Business Formation | High | High | High | High | **Strong** |
| 3. RML → Workers' Comp | Medium-High | High | Medium | High | Good |
| 4. NP FPA → Rural Mental Health | Medium-High | Medium | Medium | High | Good |

**Recommendation:** Ideas 1 and 2 are strongest. Idea 1 fills an explicit research gap with clean identification. Idea 2 uses newly available data with a novel outcome on a classic policy.
