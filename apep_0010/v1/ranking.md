# Research Idea Ranking

**Generated:** 2026-01-17T03:39:41.747248
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4772
**OpenAI Response ID:** resp_0055fa668d0dce7900696af643dd188190aa20bef1a51c1dda

---

### Rankings

**#1: New York Predictive Scheduling / Fair Workweek Law (NYC)**
- **Score:** 68/100  
- **Strengths:** Strong policy relevance and fairly direct outcomes (hours, employment) that should move quickly if the law binds. With the right design (NYC vs non-NYC + treated industries vs non-treated), you can get closer to a clean triple-difference rather than a blunt NY-vs-other-states DiD.  
- **Concerns:** Using **ACS PUMS at the state level is not credible** for a NYC-only policy; you must define NYC using PUMAs (and accept imperfect mapping) and you still can’t observe employer size or “fast food chain” coverage, so treatment misclassification is a serious attenuation risk. NYC-specific shocks around 2017–2019 (local labor market, immigration enforcement, sectoral changes) could violate parallel trends unless you do a careful event-study and robustness with alternative controls (other large MSAs).  
- **Novelty Assessment:** Predictive scheduling/fair workweek laws have been studied (especially Seattle/SF; also policy reports on NYC), but **NYC remains less saturated in peer-reviewed causal work** than many headline labor policies. Moderate novelty.  
- **Recommendation:** **PURSUE** (but only if you re-specify as NYC-PUMA-based DDD/event-study; otherwise skip)

---

**#2: New York Sexual Harassment Training Mandate**
- **Score:** 63/100  
- **Strengths:** The statewide scope and clear statutory dates are attractive, and the topic is plausibly underexplored in causal labor-market terms. Large ACS sample sizes make precise estimation feasible.  
- **Concerns:** The main outcomes proposed—female employment and “retention”—are **far from the compliance margin** and hard to measure in ACS (retention is especially weak in repeated cross-sections). Identification is threatened by contemporaneous NY changes and broader shocks (e.g., #MeToo-era reporting/behavior changes, other NY labor policies), and by the fact that the mandate applies to essentially all employers (limited within-state contrast; heterogeneous compliance is unobserved).  
- **Novelty Assessment:** There is a lot written on harassment, reporting, and workplace training in general, but **statewide training mandates’ labor-market effects** appear genuinely less studied. High-ish novelty, weaker causal traction.  
- **Recommendation:** **CONSIDER** (better if paired with outcomes closer to the mechanism—EEOC charges, lawsuit filings, employer HR policy adoption—or with an intensity design by pre-policy harassment prevalence/industry exposure)

---

**#3: Alabama Salary History Ban**
- **Score:** 54/100  
- **Strengths:** Clear policy date and a policy lever policymakers actively debate (pay equity). Alabama’s “weaker” variant is a potentially interesting margin relative to stronger bans studied elsewhere.  
- **Concerns:** The proposed key estimand—gender wage gap **among job changers**—is not well identified in ACS: using MIG as a job-change proxy is very noisy (migration ≠ job change; job change without moving is common). Given the law allows asking and only restricts penalizing non-disclosure, the policy may have limited bite/enforcement, making null results hard to interpret.  
- **Novelty Assessment:** Salary history bans are **already a well-trodden topic** (not exhausted, but definitely not greenfield). Alabama-specific evidence is novel, but the broader question is not.  
- **Recommendation:** **CONSIDER** only if you can obtain better job-to-job and wage-change data (e.g., CPS matched panels, LEHD/administrative UI wage records, or a resume/posting audit design); with ACS alone, likely **SKIP**.

---

**#4: South Carolina Military Spouse Licensing Reciprocity**
- **Score:** 46/100  
- **Strengths:** Substantively important and genuinely under-researched; licensing barriers for military spouses are a real policy concern, and reciprocity reforms are spreading.  
- **Concerns:** Data feasibility is the binding constraint: the **SC military spouse sample in ACS is very small**, and ACS does not cleanly identify who needs/holds a license or whether the spouse is in an affected occupation at the time of the move. Timing also overlaps with COVID-era labor market disruption (2019–2021), which is especially problematic for a small, specific subgroup and for sectoral employment outcomes.  
- **Novelty Assessment:** Very high novelty academically, but novelty cannot compensate for weak measurement and low power here.  
- **Recommendation:** **SKIP** with ACS PUMS; reconsider only with administrative spouse/licensing data (DoD + state boards) or a multi-state rollout design pooling many adopting states.

---

### Summary
This is a solid batch in terms of policy creativity, but two proposals lean heavily on ACS for effects that ACS is not well-suited to measure (job-changing; retention/licensing exposure). The most promising path is the **NYC Fair Workweek** idea—*if* you redesign it around NYC identification (PUMAs) and a DDD/event-study framework. The **NY harassment training** idea is novel but needs sharper outcomes or an intensity-based design to be credible.