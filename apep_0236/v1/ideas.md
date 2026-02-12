# Research Ideas: Remote Work and Healthcare Labor Markets

## Idea 1: Licensing to Log In: The Interstate Medical Licensure Compact and Healthcare Supply Creation

**Policy:** The Interstate Medical Licensure Compact (IMLC), adopted by 42 US states between 2017 and 2024, creates an expedited pathway for physicians to obtain licenses in multiple states. The compact became operational in April 2017 when the first 17 states went live simultaneously, with subsequent states joining in staggered fashion through 2024. Non-member states include CA, NY, OR, VA, SC, AK, NM.

**Outcome:** BLS Quarterly Census of Employment and Wages (QCEW) — healthcare employment (NAICS 62, 621), wages, and establishment counts at the state-quarter level, 2012-2024. Supplemented by ACS interstate migration data for healthcare workers.

**Identification:** Staggered difference-in-differences using Callaway and Sant'Anna (2021) estimator. Treatment = year-quarter when state became operational IMLC member. ~8 distinct adoption cohorts (2017Q2, 2018, 2019, 2020, 2021, 2022, 2023, 2024) plus 8+ never-treated states. Pre-treatment: 2012Q1-2016Q4 (5+ years).

**Why it's novel:**
1. Frames licensing reform as "remote work infrastructure" — the compact enables physicians to deliver telehealth across state lines without relocating
2. Tests whether IMLC creates new healthcare supply (more establishments, more employment) or merely redistributes existing providers across states
3. Only one existing DiD study on IMLC (Deyo et al. 2023, focused on out-of-state practice counts). Oh & Kleiner (2025 NBER) study broader ULR laws but find no migration — suggesting the mechanism is virtual. No study examines healthcare employment and establishment creation effects
4. The MOST Policy Initiative explicitly notes "little quantitative research on the effects of entry into the IMLC"

**Feasibility check:**
- Variation: 42 states, 8 adoption cohorts, 8+ never-treated. ✓
- Data: QCEW API confirmed working, no key required, state-quarter-industry. ✓
- Pre-periods: 5 years (2012-2016) for first cohort. ✓
- Not overstudied: Only 1 DiD paper, research gap explicitly identified. ✓
- Sample: 50 states × 52 quarters = 2,600 state-quarter observations. ✓

---

## Idea 2: Telehealth Parity Laws and the Geography of Healthcare Work

**Policy:** State telehealth payment parity laws requiring insurers to reimburse telehealth visits at the same rate as in-person visits. ~16 states adopted pre-2020 with staggered timing (2010-2019), with a second wave of 17+ states during COVID (2020-2021).

**Outcome:** ACS commuting data (B08301 — "worked from home" for healthcare workers), QCEW healthcare employment by state-year, CMS telehealth utilization.

**Identification:** Staggered DiD exploiting pre-2020 parity adoption (cleaner than COVID-era adoption). ~16 treated states with 5+ pre-periods.

**Why it's novel:** Prior telehealth parity studies focus on patient utilization. No study examines provider-side labor market effects (wages, location, work mode).

**Feasibility check:**
- Variation: 16 states pre-2020 adoption. Borderline (need to verify exact count). ⚠️
- Data: ACS + QCEW confirmed accessible. ✓
- Pre-periods: Varies by adoption year, generally 5+. ✓
- Concern: Some existing studies on telehealth parity and utilization (PubMed 29847224, 33491006). May not be sufficiently novel.

---

## Idea 3: The Psychology Interjurisdictional Compact (PSYPACT) and Mental Health Access

**Policy:** PSYPACT, adopted by 43 states starting July 2020, enables licensed psychologists to practice telepsychology across state lines. Staggered adoption 2020-2024.

**Outcome:** QCEW mental health employment (NAICS 6211, 6213), ACS healthcare worker migration, HRSA mental health shortage area designations.

**Identification:** Staggered DiD. 43 treated states, multiple adoption cohorts.

**Why it's novel:** Mental health access crisis is a first-order policy issue. No causal study of PSYPACT's labor market effects exists.

**Feasibility check:**
- Variation: 43 states but compact starts July 2020. ⚠️
- Data: QCEW accessible. ✓
- Pre-periods: Only 2020Q2-2020Q3 is pre-treatment for first cohort. ✗ SERIOUS CONCERN.
- COVID confounding: PSYPACT activation coincides exactly with COVID pandemic. ✗ FATAL.
- Verdict: Pre-treatment period too short and COVID confounds everything.

---

## Idea 4: Stacked Healthcare Compacts and Provider Supply Elasticity

**Policy:** Multiple interstate healthcare compacts — IMLC (physicians, 2017+), NLC (nurses, enhanced 2018+), PSYPACT (psychologists, 2020+), PT Compact (physical therapists, 2017+) — adopted at different times across different sets of states. Exploits multiple treatment events per state.

**Outcome:** QCEW healthcare sub-industry employment (NAICS 6211, 6213, 6214, etc.).

**Identification:** Multiple-treatment staggered DiD. Each compact treated different healthcare sub-industries, enabling within-state cross-industry comparison (quasi-triple-diff).

**Why it's novel:** Would be the first paper to estimate the combined supply effects of multiple licensing compacts.

**Feasibility check:**
- Variation: Multiple compacts × states × time. Rich but complex. ⚠️
- Data: QCEW at sub-industry level. ✓
- Concern: Extreme complexity — 4 different treatments, different timing, different industries. Identification becomes opaque.
- Verdict: Intellectually interesting but execution risk is very high.

---

## Idea 5: State Broadband Infrastructure Mandates and Rural Remote Work Adoption

**Policy:** State broadband expansion programs (broadband offices, speed mandates for subsidized ISPs, municipal broadband authorization). Staggered adoption 2015-2023, accelerated post-IIJA (2021).

**Outcome:** ACS "worked from home" rates by state-year, with focus on rural counties. QCEW rural employment.

**Identification:** Staggered DiD using state broadband office establishment dates.

**Why it's novel:** Infrastructure-enabled remote work, rather than direct remote work policy.

**Feasibility check:**
- Variation: 30+ states. ✓
- Data: ACS WFH variable + QCEW accessible. ✓
- Pre-periods: Variable. ✓
- Concern: Long causal chain (broadband policy → broadband deployment → remote work adoption). Many confounders. Broadband is a necessary but not sufficient condition — hard to isolate.
- Verdict: Interesting but weak identification. Broadband → remote work is endogenous.

---

## Ranking Summary

| Idea | Novelty | Identification | Feasibility | Verdict |
|------|---------|---------------|-------------|---------|
| 1. IMLC + Healthcare Supply | ★★★★★ | ★★★★☆ | ★★★★★ | **PURSUE** |
| 2. Telehealth Parity + Labor | ★★★☆☆ | ★★★★☆ | ★★★☆☆ | CONSIDER |
| 3. PSYPACT + Mental Health | ★★★★☆ | ★★☆☆☆ | ★★☆☆☆ | SKIP (COVID confound) |
| 4. Stacked Compacts | ★★★★★ | ★★★☆☆ | ★★☆☆☆ | SKIP (too complex) |
| 5. Broadband + Remote Work | ★★★☆☆ | ★★☆☆☆ | ★★★☆☆ | SKIP (weak ID) |
