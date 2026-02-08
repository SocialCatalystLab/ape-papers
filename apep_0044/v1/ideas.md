# Research Ideas

## Idea 1: Clean Slate Laws and Employment Outcomes

**Policy:** State "Clean Slate" automatic criminal record expungement laws adopted 2018-2025

States with adoption dates:
- Pennsylvania: 2018 (first adopter)
- Utah: 2019
- New Jersey: 2019
- Michigan: 2020
- Connecticut: 2021
- Delaware: 2021
- Virginia: 2021
- Oklahoma: 2022
- Colorado: 2022
- California: 2022
- Minnesota: 2023
- New York: 2024

**Outcome:** Employment-to-population ratio, labor force participation rate, wage income (state-level from Census ACS and BLS LAUS)

**Identification:** Staggered difference-in-differences exploiting variation in Clean Slate law adoption timing across states. Use Callaway-Sant'Anna estimator to handle heterogeneous treatment effects with staggered adoption.

**Why it's novel:** Clean Slate laws are a recent policy innovation distinct from Ban-the-Box laws. Ban-the-Box only delays criminal history inquiries; Clean Slate actually erases records, removing barriers permanently. No APEP paper has studied automatic expungement. This directly tests whether removing criminal records improves labor market outcomes at scale, rather than just delaying employer access to them.

**Feasibility check:**
- Variation: 12 treated states with staggered adoption 2018-2024; ~38 never-treated control states
- Data accessible: Census ACS state-level employment data confirmed working; BLS LAUS provides monthly state employment data
- Not overstudied: Academic literature on Clean Slate is nascent (policy is new)

**DiD Early Feasibility Assessment:**

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | STRONG | PA adopted 2018 → 6+ years pre-treatment (2012-2017) |
| Selection into treatment | MARGINAL | Adoption driven by advocacy coalitions, not labor market trends |
| Comparison group quality | STRONG | Never-treated states geographically diverse |
| Treatment clusters | MARGINAL | 12 treated states (10-19 range) |
| Concurrent policies | MARGINAL | Federal First Step Act (2018), some state min wage changes |

---

## Idea 2: Nurse Practitioner Full Practice Authority and Healthcare Access

**Policy:** State adoption of Full Practice Authority (FPA) for Nurse Practitioners, staggered 1994-2024

States with recent FPA adoption (2011-2024):
- Nevada (2013), Maine (2015), Nebraska (2015), Minnesota (2015), North Dakota (2015)
- Delaware (2016), Rhode Island (2016), West Virginia (2016), Connecticut (2017)
- Massachusetts (2020), Virginia (2022), Kansas (2022)
- Texas (2023), Tennessee (2024), Louisiana (2024)

30 states now have FPA; 15 have reduced practice; 11 have restricted practice.

**Outcome:** Health insurance coverage rates, usual source of care, unmet medical needs due to cost (from Census ACS and BRFSS)

**Identification:** Staggered difference-in-differences comparing states adopting FPA to states retaining physician supervision requirements. Focus on 2011-2024 adoption wave to avoid confounding with earlier healthcare reforms.

**Why it's novel:** While NP scope-of-practice has been studied, most research focuses on rural areas or specific populations. This would examine population-wide effects on healthcare access and insurance coverage, testing whether expanding NP authority reduces the uninsured rate by increasing primary care supply.

**Feasibility check:**
- Variation: 15+ states adopted FPA during 2011-2024; 11 remain "restricted" controls
- Data accessible: Census ACS health insurance variables confirmed working
- Partially studied: Some literature exists, but population-wide insurance effects are underexplored

**DiD Early Feasibility Assessment:**

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | STRONG | Many states adopted 2015+; ACS data from 2005+ |
| Selection into treatment | MARGINAL | Political factors drive adoption |
| Comparison group quality | STRONG | Restricted-practice states provide clean control |
| Treatment clusters | STRONG | 15+ treated states in recent wave |
| Concurrent policies | WEAK | ACA (2014), Medicaid expansion confound |

**CONCERN:** ACA and Medicaid expansion are major confounds. Would need triple-differences design or restriction to post-2016 analysis.

---

## Idea 3: Automatic Voter Registration and Civic Participation

**Policy:** State adoption of Automatic Voter Registration (AVR), staggered 2015-2023

States with adoption dates:
- Oregon: 2015 (implemented 2016)
- California: 2015
- Vermont: 2016
- West Virginia: 2016
- Colorado: 2017
- Alaska: 2016 (ballot measure)
- Illinois: 2017
- Rhode Island: 2017
- Washington: 2018
- Maryland: 2018
- New Jersey: 2018
- Nevada: 2018
- Massachusetts: 2018
- New Mexico: 2019
- New York: 2020
- Virginia: 2020
- Pennsylvania: 2023
- Minnesota: 2023

24 states + DC now have AVR.

**Outcome:** Voter registration rates, voter turnout in general elections (from CPS Voting Supplement, EAC Election Administration and Voting Survey)

**Identification:** Staggered difference-in-differences comparing states adopting AVR to states without. Event study examining registration and turnout in elections before and after AVR implementation.

**Why it's novel:** While some studies examine AVR, most focus on registration effects. This would test downstream turnout effects and examine whether AVR changes the composition of the electorate (by age, education, race).

**Feasibility check:**
- Variation: 24 treated states with clear implementation dates; 26 never-treated states
- Data accessible: CPS Voting Supplement available via IPUMS; EAC data downloadable
- Partially studied: Registration effects studied; turnout effects and composition less so

**DiD Early Feasibility Assessment:**

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | STRONG | Oregon 2016 → data from 2008+ |
| Selection into treatment | MARGINAL | Blue states adopt first; political selection |
| Comparison group quality | MARGINAL | Non-adopting states skew Republican |
| Treatment clusters | STRONG | 24 treated states |
| Concurrent policies | MARGINAL | Voter ID laws, early voting expansions |

**CONCERN:** Political selection is strong—blue states adopt AVR. Need to control for pre-existing political composition or use within-state variation.

---

## Idea 4: Pay Transparency Laws and Gender Wage Gap

**Policy:** State pay transparency laws requiring salary disclosure in job postings, staggered 2021-2025

States with adoption dates:
- Colorado: 2021 (first comprehensive law)
- Connecticut: 2021
- Nevada: 2021
- Rhode Island: 2023
- California: 2023
- Washington: 2023
- New York: 2023 (NYC)
- Illinois: 2025
- Hawaii: 2024
- Maryland: 2024
- Minnesota: 2025
- Massachusetts: 2025

**Outcome:** Gender wage gap, wage dispersion, wage levels (from Census ACS PUMS microdata)

**Identification:** Staggered difference-in-differences comparing states with pay transparency requirements to states without. Examine effects on gender wage gap, overall wage levels, and wage dispersion.

**Why it's novel:** Pay transparency is a cutting-edge policy reform with almost no academic evaluation yet. This would be among the first rigorous studies of whether requiring salary disclosure affects labor market outcomes.

**Feasibility check:**
- Variation: 12+ states with transparency laws; timing variation 2021-2025
- Data accessible: Census ACS PUMS microdata with earnings
- Very novel: Policy is new; minimal academic literature

**DiD Early Feasibility Assessment:**

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | WEAK | Colorado 2021 → only 2019-2020 clean pre-period (COVID) |
| Selection into treatment | MARGINAL | Progressive states adopt; not responding to wage trends |
| Comparison group quality | MARGINAL | Non-adopting states differ politically |
| Treatment clusters | MARGINAL | ~12 states, growing |
| Concurrent policies | WEAK | COVID recovery, inflation, remote work revolution |

**CONCERN:** Too recent. COVID disruption contaminates pre-period. Only 2-3 years of post-treatment data for early adopters. Recommend WAITING 2-3 years before studying this policy.

---

## Idea 5: State Data Privacy Laws and Tech Employment

**Policy:** State comprehensive data privacy laws (CCPA-style), staggered 2020-2025

States with adoption dates:
- California: 2020 (CCPA effective)
- Virginia: 2021
- Colorado: 2021
- Connecticut: 2022
- Utah: 2023
- Iowa: 2025
- Delaware: 2025
- Nebraska: 2025
- New Hampshire: 2025
- Montana: 2024
- Oregon: 2024

20 states now have comprehensive data privacy laws.

**Outcome:** Technology sector employment, business formation rates, IT occupation employment (from BLS QCEW, Census Business Dynamics Statistics)

**Identification:** Staggered difference-in-differences examining tech sector employment changes following state privacy law adoption.

**Why it's novel:** State data privacy laws are understudied. Most commentary focuses on compliance costs, but no rigorous study examines labor market effects. This tests whether privacy regulations affect tech sector hiring or business formation.

**Feasibility check:**
- Variation: 20 states with privacy laws; clear timing variation
- Data accessible: BLS QCEW provides state-industry employment; Census BDS for business formation
- Novel: No academic studies of labor market effects

**DiD Early Feasibility Assessment:**

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | MARGINAL | CA 2020 → only 2015-2019 pre-period |
| Selection into treatment | MARGINAL | Large/tech-heavy states adopt first |
| Comparison group quality | MARGINAL | Non-adopting states less tech-focused |
| Treatment clusters | STRONG | 20 states |
| Concurrent policies | WEAK | COVID, remote work, tech layoffs 2022-23 |

**CONCERN:** COVID disruption. Tech-sector shocks (layoffs 2022-2023) confound treatment effects. Selection issue: tech-heavy states adopt privacy laws AND have more tech employment.

---

## Summary Ranking

| Idea | Policy | Novelty | Feasibility | DiD Validity | Recommend |
|------|--------|---------|-------------|--------------|-----------|
| 1 | Clean Slate Laws | HIGH | HIGH | STRONG | **PURSUE** |
| 2 | NP Full Practice Authority | MEDIUM | HIGH | MARGINAL (ACA confound) | CONSIDER |
| 3 | Automatic Voter Registration | MEDIUM | HIGH | MARGINAL (selection) | CONSIDER |
| 4 | Pay Transparency | HIGH | LOW | WEAK (too recent) | WAIT |
| 5 | Data Privacy Laws | HIGH | MEDIUM | WEAK (COVID, selection) | WAIT |

**Recommendation:** Pursue Idea 1 (Clean Slate Laws). It has the best combination of novelty, data availability, and identification credibility. The 2018-2024 adoption window provides adequate pre-treatment periods, and the policy is distinct from Ban-the-Box (which has been extensively studied).
