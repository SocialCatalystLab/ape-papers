# Research Ideas

## Idea 1: Promise Programs and Community College Completion (PRIMARY)

**Policy:** State College Promise Programs (free community college tuition)
- Tennessee Promise: 2015 (first cohort)
- Oregon Promise: 2016
- Arkansas, Hawaii, Indiana, Kentucky, Nevada, New York, Rhode Island: 2017
- Maryland: 2018
- Washington: 2019
- California expansion, Connecticut, Delaware: 2020
- Michigan Reconnect: 2021
- **Total: 20+ states with staggered adoption**

**Outcome:** Community college completion rates (associate degrees within 3 years)

**Identification:** Staggered DiD comparing states before/after Promise adoption. Use Callaway-Sant'Anna estimator to handle heterogeneous treatment timing.

**Why it's novel:**
- Most Promise studies focus on **enrollment** effects (well-documented 5-15% increases)
- Completion is the policy-relevant margin but understudied
- Community colleges have ~30% completion rates; does free tuition help?
- Now (2026) we finally have enough post-treatment years to observe completion

**Data sources:**
- College Scorecard API: `latest.completion.completion_rate_4yr_150nt` for 2-year schools by state
- IPEDS Completions Survey: degrees awarded by institution type
- Census ACS: `B15003` educational attainment by age cohort × state × year

**Feasibility check:**
- ✓ 20+ treated states (exceeds minimum of 20)
- ✓ 5+ pre-treatment periods (2010-2014 baseline)
- ✓ Data accessible via working APIs
- ✓ Not in APEP database (checked: no Promise/completion papers)

**Expected mechanism:** Promise removes financial barriers at enrollment, but completion requires sustained academic support. Effect may be smaller than enrollment effect, or even negative if marginal students are less prepared.

---

## Idea 2: Promise Programs and Four-Year Enrollment Diversion

**Policy:** Same as Idea 1 (State College Promise Programs)

**Outcome:** 4-year university enrollment rates (potential crowd-out)

**Identification:** DiD comparing 2-year vs 4-year enrollment in Promise states vs controls. Triple-diff: state × year × institution-type.

**Why it's novel:**
- Tests the "diversion hypothesis": do Promise programs shift students from 4-year to 2-year?
- If diversion is large, net enrollment gain is smaller than headline numbers
- Policy-relevant: 4-year degrees have higher returns than associate degrees

**Data sources:**
- College Scorecard: enrollment by institution type (predominant degree = 2-year vs 4-year)
- Census ACS: `B14004` enrollment by type of school and age

**Feasibility check:**
- ✓ Same policy variation as Idea 1
- ✓ Data accessible
- ✓ Not in APEP database

**Expected finding:** Modest diversion (5-10% of new CC enrollees would have attended 4-year). Net welfare effect depends on completion rates at each margin.

---

## Idea 3: FAFSA Completion Requirements and College Enrollment

**Policy:** State mandates requiring FAFSA completion for high school graduation
- Louisiana: 2018 (first state; dropping 2025)
- Texas: 2019 (enforced 2021-22)
- Alabama, California, Illinois: 2020-2022
- Connecticut, Indiana, Nebraska, New Jersey, New York, Oklahoma: 2024-25
- **Total: 12 states with staggered adoption**

**Outcome:** College enrollment rates for high school graduates

**Identification:** DiD comparing enrollment rates in FAFSA-mandate states vs controls, using high school graduation cohorts.

**Why it's novel:**
- Very new policy (2018-2024) with almost no academic literature
- Tests whether information/nudge interventions at scale improve access
- Policy is spreading rapidly; evidence would inform expansion decisions

**Data sources:**
- Census ACS: college enrollment by age 18-24 × state × year
- FAFSA completion rates from studentaid.gov (by high school)

**Feasibility check:**
- ⚠️ Only 12 treated states (below 20 minimum for robust DiD)
- ⚠️ Most adoption is 2020-2024, limited post-treatment data
- ✓ Data accessible
- ✓ Novel topic not in APEP

**Risk:** Underpowered due to few treated clusters and short post-treatment window. Would need careful inference (wild cluster bootstrap, randomization inference).

---

## Idea 4: Promise Programs and Geographic Retention (Brain Drain)

**Policy:** Same as Idea 1 (State College Promise Programs)

**Outcome:** Young adult out-migration rates; share of young adults remaining in home state

**Identification:** DiD comparing out-migration in Promise states vs controls. Focus on cohorts who would have been eligible (recent high school graduates).

**Why it's novel:**
- Many Promise programs have residency requirements or in-state work requirements
- Brain drain is a major concern for rural/declining states
- Tests whether education subsidies affect long-run population composition

**Data sources:**
- Census ACS: migration questions (MIGSP - state of residence 1 year ago)
- ACS PUMS for individual-level analysis by education × age

**Feasibility check:**
- ✓ Same policy variation as Idea 1
- ✓ Data accessible (ACS migration variables)
- ✓ Not in APEP database

**Challenge:** Migration outcomes may take 4-6 years to observe (after graduation). May only see effects for earliest adopters (TN, OR).

---

## Recommendation

**Pursue Idea 1 (Promise Programs and Completion)** as the primary paper.

Rationale:
1. Best policy variation (20+ states, staggered 2015-2021)
2. Clearly novel angle (completion vs enrollment)
3. Policy-relevant and timely
4. Data accessible via working APIs
5. Sufficient post-treatment periods for completion (2-3 years to observe)

Idea 2 (Diversion) could be incorporated as a robustness check or mechanism analysis within the same paper.
