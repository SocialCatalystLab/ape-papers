# Research Idea Ranking

**Generated:** 2026-01-17T01:33:07.260757
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4383

---

### Rankings

**#1: Universal License Recognition and Interstate Migration of Licensed Workers (Idea 1)**
- **Score:** 72/100  
- **Strengths:** High-novelty policy with rapid, staggered adoption and a clear, policy-relevant outcome (in-migration of licensed workers). ACS/PUMS can support credible event-study style DiD with occupation and geography heterogeneity.  
- **Concerns:** Identification is threatened by contemporaneous shocks (especially COVID-era migration and labor market disruptions) and by non-random adoption (states adopting ULR may also be pro-growth/pro-in-migration). “Licensed occupation” status is measured imperfectly (occupation ≠ licensure; licensure varies by state), which may attenuate effects.  
- **Novelty Assessment:** **Moderately to highly novel** outside a few recent papers (one narrow NBER/healthcare angle; limited border-county evidence). A broad, multi-occupation microdata study is not yet saturated.  
- **Recommendation:** **PURSUE**

---

**#2: Pre-ACA State Dependent Coverage Laws and Young Adult Employment (Idea 4)**
- **Score:** 64/100  
- **Strengths:** Uses genuinely policy-driven, pre-federal variation with many adopting states in a short window—good raw material for DiD/event study, and the question speaks to job lock/entrepreneurship policy debates. Large microdata samples make precise estimation feasible.  
- **Concerns:** Treatment is very “fuzzy”: eligibility depended on parental insurance, age ceilings, student/marital status, and plan type—so state-law exposure is weakly observed in ACS, likely producing diluted ITT estimates. Also, ACS health insurance measurement is not consistent pre-2008, and the Great Recession coincides with key years, pressuring parallel trends.  
- **Novelty Assessment:** **Moderately studied**—less crowded than the ACA age-26 literature, but there is existing work on pre-ACA laws and on young-adult labor outcomes more broadly.  
- **Recommendation:** **CONSIDER**

---

**#3: State Paid Family Leave and Father’s Labor Supply (Idea 3)**
- **Score:** 57/100  
- **Strengths:** Policymakers care about father involvement and gender equity; multi-state analysis could add external validity relative to single-state administrative studies. PUMS offers large samples to study employment/hours around childbirth (if identified well).  
- **Concerns:** This topic is already part of a large PFL literature, and clean identification of “new fathers” is nontrivial in ACS (your current plan relies on **FER**, which applies to women; you’d likely need household child-age structure measures). Even with correct measurement, effects on fathers’ labor supply may be subtle and confounded by contemporaneous state policy bundles.  
- **Novelty Assessment:** **Somewhat crowded**—maternal outcomes are heavily studied; father-focused work exists (though thinner), so novelty is incremental rather than first-order.  
- **Recommendation:** **CONSIDER**

---

**#4: State Auto-IRA Mandates and Worker Job Mobility (Idea 2)**
- **Score:** 50/100  
- **Strengths:** The labor-market spillovers of auto-IRAs are a plausible and policy-relevant gap relative to existing work focused on savings/opt-out and firm plan substitution. Staggered rollouts across states create potential quasi-experimental variation.  
- **Concerns:** With ACS/PUMS, treatment assignment is very poorly measured: mandates apply only to certain employers (often phased by firm size) and only where no plan exists—ACS lacks employer size and retirement-plan offer/participation, and it does not directly measure job-to-job mobility/tenure. A state-level DiD on all private workers risks severe attenuation and interpretability problems (plus firm responses—creating private plans—muddy the “dose”).  
- **Novelty Assessment:** **Novel question**, but the current empirical design/data pairing is weak; novelty cannot compensate for low identification/data fit.  
- **Recommendation:** **SKIP (unless you can access administrative program data, UI wage records, or a dataset with job transitions and employer plan offers)**

---

### Summary
This is a solid batch conceptually, but only **Idea 1 (ULR and migration)** has a strong combination of novelty and feasible measurement with reasonably credible identification in PUMS. **Idea 4** is the best “runner-up” if you can handle policy heterogeneity and the recession period carefully (ideally with triple-diff by age and plausibly exposed subgroups). The auto-IRA idea is interesting but, as specified, is unlikely to deliver credible causal evidence with ACS alone.