# Research Ideas

## Idea 1: The Innovation Cost of Privacy — State Data Privacy Laws and the Technology Sector

**Policy:** State comprehensive consumer data privacy laws (CCPA-type). 20 states enacted between 2020–2026 with genuinely staggered adoption across 9 distinct treatment waves. ~30 never-treated states serve as controls.

**Treatment timeline:**
- Wave 1 (2020): California
- Wave 2 (Jan 2023): Virginia
- Wave 3 (Jul 2023): Colorado, Connecticut
- Wave 4 (Dec 2023): Utah
- Wave 5 (Jul 2024): Texas, Oregon, Florida
- Wave 6 (Oct 2024): Montana
- Wave 7 (Jan 2025): Delaware, Iowa, Nebraska, New Hampshire, New Jersey
- Wave 8 (Jul–Oct 2025): Tennessee, Minnesota, Maryland
- Wave 9 (Jan 2026): Indiana, Kentucky, Rhode Island

**Outcome:** Technology sector employment, wages, establishment counts, and new business applications.

**Data sources:**
1. BLS QCEW (Quarterly Census of Employment and Wages) — state × quarter × industry administrative data. NAICS 51 (Information), 5112 (Software Publishers), 518 (Data Processing). Available 2010–present. No API key needed.
2. Census Business Formation Statistics (BFS) — state × quarter business applications. Available 2004–present as public CSV.

**Identification:** Staggered difference-in-differences using Callaway–Sant'Anna (2021) estimator. Treatment = effective date of state comprehensive privacy law. 20 treated states, ~30 never-treated controls, 5+ years of pre-treatment data (2015–2019 for earliest adopter CA).

**Why it's novel:** NO existing multi-state DiD study exploits the staggered rollout of state privacy laws. The only causal work uses CCPA alone (single state) or GDPR (international comparison). This is a genuine gap in the literature.

**Theoretical contribution:** Tests competing hypotheses: (1) Privacy laws impose compliance costs that disproportionately burden small firms, reducing tech employment and startup entry ("regulatory burden" hypothesis); (2) Privacy laws create competitive advantages for large firms that can absorb compliance costs ("regulatory moat" hypothesis); (3) Privacy laws have no meaningful effect because most firms already comply with CCPA standards ("de facto federal standard" hypothesis).

**Robustness:** Placebo industries (manufacturing, healthcare); event-study pre-trend plots; heterogeneity by firm size (establishment counts vs. employment); dose-response using law scope variation; border-county analysis.

**Feasibility check:** CONFIRMED — QCEW API returns state × quarter × industry data (tested). BFS CSV download works with state-level quarterly data back to 2004.

---

## Idea 2: Can You Cap Your Way to Health? State Insulin Copay Caps and Diabetes Outcomes

**Policy:** State insulin copay cap laws. 29+ states plus DC have enacted caps on monthly insulin out-of-pocket costs ($25–$100/month) for state-regulated commercial insurance. Staggered adoption 2020–2025.

**Treatment timeline:**
- 2020: Colorado ($100)
- 2020–2021: NY, WV, NH, DE, IL, ME, NM, UT, VA, WA, MN, TX
- 2022: CT, DC, KY, VT, OK
- 2023: MT, LA, MD, ND, NE, RI
- 2024–2025: MA, NV, NJ, OR, CA

**Outcome:** Diabetes-related mortality, self-reported diabetes management, cost-related medication non-adherence.

**Data sources:**
1. CDC BRFSS (Socrata API) — state × year prevalence data for diabetes outcomes, healthcare access, cost barriers. Available 2011–present.
2. CDC WONDER — diabetes mortality (ICD-10 E10–E14) by state and year. Available 1999–present.

**Identification:** Staggered DiD with CS estimator. 29+ treated states, ~20 never-treated controls.

**Why it's novel:** ALL existing studies (Seervai 2024, Baig 2024, Ukert 2024) focus on OOP costs and prescription utilization. NO study examines downstream health outcomes (mortality, ER visits, medication adherence). The existing "null result" on utilization makes the health outcome question even more interesting — if caps don't increase utilization, do they still improve health through reduced rationing?

**Feasibility check:** CONFIRMED — CDC BRFSS API returns state × year data (tested). CDC WONDER provides diabetes mortality.

---

## Idea 3: From Nairobi to Nashville — Community Health Worker Medicaid Integration and Population Health

**Policy:** State Medicaid reimbursement for Community Health Worker (CHW) services via State Plan Amendments. 20 states have CMS-approved SPAs with staggered adoption from 2008–2025. Kenya pioneered CHW programs; this tests whether formalizing CHW roles in the US Medicaid system improves health.

**Treatment timeline:**
- 2008: Minnesota (pioneer)
- 2012: Oregon
- 2018: Indiana
- 2019: South Dakota
- 2022: California, Louisiana, Maine, Nevada, Rhode Island
- 2023: Arizona, Kansas, Kentucky, Michigan, New York
- 2024–2025: New Mexico, Colorado, Georgia, Oklahoma, Washington

**Outcome:** Preventable hospitalization rates, chronic disease prevalence, infant mortality, self-reported health status.

**Data sources:**
1. CDC BRFSS — state × year health outcomes, healthcare access.
2. CDC WONDER — mortality data by state and year.
3. AHRQ PQI (Prevention Quality Indicators) — state-level preventable hospitalization rates.

**Identification:** Staggered DiD with CS estimator. 20 treated states, ~30 never-treated controls. Early adopters (MN 2008, OR 2012) provide long post-treatment windows.

**Why it's novel:** The only existing DiD on CHW Medicaid policies (Basu 2022) studies CHW wages/turnover, NOT population health outcomes. No study has estimated the causal effect of CHW Medicaid integration on health using the staggered state rollout. This fills a major gap.

**Concern:** Heavy clustering in 2022–2023 means most treated states have very short post-treatment periods (<2 years of data). The health effects of CHW integration may take years to materialize, limiting statistical power for recent adopters. Analysis would lean heavily on early adopters (MN, OR, IN, SD) for long-run effects.

**Feasibility check:** CONFIRMED — BRFSS and CDC WONDER APIs work (tested). Treatment dates verified from NASHP and CMS.
