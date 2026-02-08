# Research Idea Ranking

**Generated:** 2026-01-17T16:30:47.620836
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4805
**OpenAI Response ID:** resp_0f67af61f7efa8a200696baaf1f3388196b5d862cb5cf9c807

---

### Rankings

**#1: Lifeline Broadband Subsidy Eligibility and Self-Employment**
- **Score:** 64/100  
- **Strengths:** Entrepreneurship/self-employment is a relatively less-saturated outcome in the broadband impacts literature, and ACS/PUMS has workable measures (COW, SEMP) with large samples. The policy lever (Lifeline eligibility) is real and salient, so even reduced-form “eligibility effects” could be informative.  
- **Concerns:** Income-as-running-variable RDD is fragile: reporting error/heaping, transitory income, and potential manipulation around program thresholds can badly blur the discontinuity. It’s also a fuzzy design (eligibility ≠ enrollment; enrollment ≠ broadband adoption), and PUMS doesn’t observe actual Lifeline take-up—so the first stage may be weak and interpretation contentious.  
- **Novelty Assessment:** **Moderately novel.** Broadband and local economic activity is heavily studied, but “Lifeline-threshold RDD → self-employment” is not something I recall as a well-trodden, clean canonical design; entrepreneurship outcomes are less common than wages/employment.  
- **Recommendation:** **CONSIDER** (PURSUE only if you can document a strong first stage and demonstrate no bunching/manipulation around 135% FPL).

---

**#2: Broadband Access and Work-From-Home Resilience During COVID-19**
- **Score:** 60/100  
- **Strengths:** Strong policy narrative and clear mechanism (WFH feasibility) with plausible heterogeneity during 2020–2021. A difference-in-discontinuities framework can partially net out baseline discontinuities at the 135% FPL cutoff.  
- **Concerns:** Novelty is limited because COVID-era broadband/WFH labor-market resilience has already been studied extensively with many designs; this risks becoming “one more paper” unless the identification is unusually crisp. The DiRD hinges on stable measurement (WFH coding changes) and on no other pandemic-era policies/behaviors shifting discontinuously at the income cutoff (quite plausible that many safety-net policies kink around similar ranges).  
- **Novelty Assessment:** **Low-to-moderate.** The COVID/WFH/broadband nexus is crowded; the specific Lifeline-threshold DiRD angle is somewhat distinctive but not a big novelty leap.  
- **Recommendation:** **CONSIDER** (worth doing if you can show clean pre-trends around the cutoff and stable outcome definitions).

---

**#3: E-Rate School Broadband and Student Achievement**
- **Score:** 53/100  
- **Strengths:** High policy relevance: if you could credibly link school connectivity investment to achievement, that’s valuable for E-Rate and education spending debates. School-level administrative data (USAC/NCES + state outcomes) can be powerful if assembled correctly.  
- **Concerns:** The proposed “40% threshold” is problematic: 40% is a key cutoff for CEP free meals eligibility, but **E-Rate discounts are stepwise on a discount matrix** (not a single sharp maximum at 40%), and many other programs correlate with poverty rates. Even if you exploit CEP at 40%, the treatment bundle (meals + other resources + accountability responses) makes it hard to interpret as “broadband investment” unless you can isolate E-Rate-driven spending/implementation. Data assembly and linkage (schools over time, outcomes, funding, implementation timing) is nontrivial and may stall.  
- **Novelty Assessment:** **Moderate.** E-Rate has a literature, and CEP-threshold RDDs exist in education; the “E-Rate via 40%” angle is not clearly a clean, underexplored discontinuity as written.  
- **Recommendation:** **SKIP as currently framed** (upgradeable to CONSIDER if redesigned around *actual* E-Rate discount cut points, verified implementation timing, and a strategy to separate broadband from coincident poverty-linked interventions).

---

**#4: Broadband Subsidy Eligibility and Geographic Mobility**
- **Score:** 49/100  
- **Strengths:** Mobility is a genuinely interesting and relatively less-standard outcome for broadband policy; the “location flexibility” mechanism is plausible, especially post-2020. PUMS has migration indicators, so it’s implementable in principle.  
- **Concerns:** Interstate migration over a 1-year window is rare, making RDD bandwidth samples thin and estimates noisy—especially if you limit to specific states. Identification is also weak because migration is driven by many forces that may change smoothly with income but also interact with policy eligibility in complicated ways; the design risks being underpowered and easy to poke holes in.  
- **Novelty Assessment:** **Moderate.** Less studied than wages/employment, but not wholly new; I’m aware of related work on broadband and migration/amenity sorting, though not necessarily via Lifeline RDD.  
- **Recommendation:** **SKIP** (unless you broaden outcomes to higher-frequency mobility—e.g., within-state moves—or secure a much larger effective sample and a compelling mechanism test).

---

**#5: Broadband × Medicare Interaction: Telehealth Access at Age 65**
- **Score:** 46/100  
- **Strengths:** Age-65 Medicare RDD is a well-understood discontinuity, and the policy question (does broadband amplify Medicare’s benefits via telehealth?) is important and timely.  
- **Concerns:** PUMS is the wrong tool for the key mechanism: it has essentially **no telehealth utilization** and limited health-care access/use measures, so you’d be forced into proxies (coverage, disability, employment) that don’t test telehealth directly. Novelty is also limited because Medicare-at-65 is one of the most-studied RD designs in applied micro; adding a broadband interaction is interesting but may look like a thin twist without utilization/outcome data.  
- **Novelty Assessment:** **Low.** Classic RDD setting with many papers; the “broadband interaction” is newer but the data don’t support the core claim.  
- **Recommendation:** **SKIP** (unless you can link to claims/survey data with utilization—e.g., MCBS, MEPS, or insurer/Medicare claims with broadband measures—then it becomes more viable).

---

### Summary

This is a coherent set centered on a consistent eligibility threshold, but **income-based RDD in survey data is intrinsically fragile** (measurement error, heaping, manipulation, fuzzy compliance), so none of these clear the bar for “high confidence” without substantial diagnostic work. If you pursue anything first, **Idea 1** is the best combination of novelty + feasible outcomes in PUMS, with **Idea 3** a reasonable second-best if you can convincingly handle measurement changes and pandemic-era confounds.