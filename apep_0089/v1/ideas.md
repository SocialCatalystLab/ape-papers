# Research Ideas

## Idea 1: Do Nurse Practitioners Displace Physicians? Full Practice Authority and the Physician Labor Market

**Policy:** Nurse Practitioner Full Practice Authority (FPA) - state laws granting NPs the ability to practice independently without physician oversight. Staggered adoption: 5 states by 1994, 10 states by 2000, 18 states by 2010, 27 states by 2023, 30 states by 2024.

**Outcome:** Physician employment levels by state (NAICS 6211 - Offices of Physicians) from BLS Quarterly Census of Employment and Wages (QCEW). Available 1990-2024, state × year level.

**Identification:** Staggered difference-in-differences using Callaway-Sant'Anna estimator. Treatment: state adoption of FPA. Comparison: states with restricted/reduced practice authority. Control for state trends, healthcare sector growth.

**Why it's novel:**
- Existing literature focuses almost exclusively on NP outcomes (earnings, self-employment, HPSA location)
- One paper found "no effect on physician earnings" but did not examine employment/relocation
- No published work examines whether FPA causes physicians to exit/relocate from FPA states
- Theoretical contribution: Tests whether "FPA expands access" has an unintended supply-side consequence (physician competition response)

**Research question:** Does FPA adoption cause a decline in physician employment, suggesting physicians relocate to states with more favorable competitive environments?

**Feasibility check:**
- ✓ Variation: 26+ treated states, staggered 1988-2024
- ✓ Pre-treatment periods: Many states never adopted (permanent control group), early adopters have 10+ years of data before treatment
- ✓ Data accessible: QCEW API confirmed working, returns state × industry employment
- ✓ Not in APEP list: No papers on NP FPA or physician labor market response
- ✓ Cluster count: 50 states + DC sufficient for inference

**Potential mechanisms:**
1. Direct competition: NPs substitute for physicians, reducing physician demand
2. Relocation: Physicians move to restricted-practice states with less competition
3. Entry deterrence: New physicians avoid FPA states for initial practice location
4. Wage pressure: Lower physician wages in FPA states reduces labor supply

**Robustness:**
- Event study for pre-trends
- Placebo: Non-healthcare industries (should show null)
- Heterogeneity by specialty (primary care vs. specialty)
- Sun-Abraham estimator as alternative to CS-DiD

---

## Idea 2: Contraceptive Insurance Mandates and Women's Job Mobility

**Policy:** State contraceptive insurance mandates requiring employer health plans to cover prescription contraceptives. Maryland first in 1998, 27 states by 2012. Federal ACA mandate August 2012 eliminates cross-state variation post-2012.

**Outcome:** Job-to-job transition rates for women from Current Population Survey (CPS) or state-level employment churn from Quarterly Workforce Indicators (QWI).

**Identification:** Staggered DiD using state adoption dates 1998-2011. Treatment ends when ACA federalizes policy (2012), creating clean pre-ACA window.

**Why it's novel:**
- Classic literature (Bailey 2006 QJE) focuses on pill legalization and labor supply
- No published work examines state insurance mandates and job mobility/job lock
- Theoretical contribution: Tests whether reduced out-of-pocket contraception costs reduce "job lock" (staying in job for benefits)

**Research question:** Do contraceptive insurance mandates increase women's job-to-job transitions by reducing dependence on employer-provided coverage?

**Feasibility check:**
- ✓ Variation: 27 treated states, staggered 1998-2011
- ✓ Pre-treatment periods: Maryland 1998, others follow through 2011
- ✓ Data: QWI accessible via Census API (state × quarter turnover rates)
- ✓ Not in APEP: No papers on contraceptive mandates
- ⚠️ Challenge: Limited post-2011 variation due to ACA

**Risk assessment:** Medium. Clear identification window but short post-treatment for late adopters.

---

## Idea 3: Data Breach Notification Laws and Cybersecurity Employment

**Policy:** State data breach notification laws requiring organizations to notify consumers of personal data breaches. California first in 2003, all 50 states by 2018. Staggered adoption.

**Outcome:** IT Security employment by state from BLS Occupational Employment and Wage Statistics (OES) - SOC codes for Information Security Analysts (15-1212) and related occupations.

**Identification:** Staggered DiD exploiting 2003-2018 adoption variation.

**Why it's novel:**
- Existing literature examines effect on data breaches and consumer behavior
- No published work examines labor market response (demand for cybersecurity workers)
- Tests "regulatory-induced employment" hypothesis

**Research question:** Do data breach notification laws increase employment in cybersecurity and IT security occupations?

**Feasibility check:**
- ✓ Variation: All 50 states, staggered 2003-2018
- ✓ Pre-treatment periods: 15-year window
- ⚠️ Data: OES occupation data may not be available at state × year level for specific SOC codes
- ✓ Not in APEP: No papers on data breach laws

**Risk assessment:** Medium-high. Need to verify OES data availability for specific SOC codes at state level.

---

## Summary Ranking

| Idea | Novelty | Identification | Data Access | Overall |
|------|---------|----------------|-------------|---------|
| 1. NP FPA → Physician Employment | High | Strong | Confirmed | **BEST** |
| 2. Contraceptive Mandates → Job Mobility | High | Good (pre-ACA) | QWI available | Second |
| 3. Data Breach Laws → Cybersecurity Jobs | Medium | Strong | Uncertain | Third |

**Recommendation:** Proceed with Idea 1 (NP FPA → Physician Employment). This has:
- Confirmed data access (QCEW)
- Clear novel contribution (supply-side physician response)
- Strong identification (26+ treated states, staggered adoption)
- Counter-intuitive hypothesis that challenges conventional "FPA expands access" narrative
