# Research Idea Ranking

**Generated:** 2026-01-17T02:04:15.855940
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5723

---

### Rankings

**#1: Hawaii Kupuna Caregivers Program and Caregiver Employment**
- **Score: 69/100**
- **Strengths:** First-in-nation caregiver subsidy with clear timing (2017) and a plausible labor-supply mechanism; very little prior causal work, so even a solid quasi-experimental evaluation would be high value. PUMS has enough years pre/post for an event-study style DiD and meaningful heterogeneity (gender, age of elder, income).
- **Concerns:** PUMS does not identify actual program participation or eligibility beyond crude proxies (co-resident elder ≠ caregiver; eligibility requires working ≥30 hours, which complicates interpretation and can induce selection/composition changes). Hawaii is a single treated state with unique labor-market shocks (tourism, COVID), making parallel trends and inference fragile without careful robustness (synthetic control, donor pool sensitivity, placebo tests).
- **Novelty Assessment:** **High.** This specific program appears essentially unevaluated in peer-reviewed causal work; that’s rare for a statewide labor policy.
- **Recommendation:** **PURSUE** (but redesign around a very careful “single treated unit” DiD/event study + robustness, and be explicit that you’re estimating an *intent-to-treat on a proxy group*, not effects on actual participants).

---

**#2: Utah Universal License Recognition and Interstate Migration of Licensed Workers**
- **Score: 56/100**
- **Strengths:** Policy is recent and politically salient; migration responses to licensing portability are policy-relevant, and microdata can examine movers’ employment/wage outcomes rather than only state aggregates. There’s room to add value by focusing on outcomes for *movers* and by using occupation-level heterogeneity (more vs less licensing burden).
- **Concerns:** Identification is shaky because Utah’s 2019–2022 period bundles strong economic conditions and COVID-era migration shifts; DiD estimates may mostly pick up Utah-specific demand shocks. PUMS does **not** measure licensing status—only occupation—so “licensed workers” is a noisy classification and treatment intensity is mismeasured.
- **Novelty Assessment:** **Moderate.** ULR has an emerging literature (ACS-based), so this is not untouched; the incremental contribution is “Utah-specific + micro outcomes,” which is narrower.
- **Recommendation:** **CONSIDER** (strongly prefer a multi-state staggered-adoption design using *all* ULR adopters, with Utah as a case study, plus placebo occupations and pre-trend diagnostics).

---

**#3: Missouri Minimum Wage Phase-In and Low-Wage Employment**
- **Score: 50/100**
- **Strengths:** High policy relevance and a clear, multi-step treatment path that can support an event-study or continuous-treatment approach (minimum wage level). Large samples in PUMS make subgroup analyses feasible (industry, education, age).
- **Concerns:** Novelty is low given the enormous minimum-wage literature; a Missouri-only DiD will be viewed as incremental unless the design is unusually compelling. PUMS wage/hour measures are annual/retrospective and affected by composition (the “low-wage/low-education” group changes as the policy changes), which can bias employment and hours estimates.
- **Novelty Assessment:** **Low.** While Missouri-specific peer-reviewed work may be limited, the question and methods are heavily mined, and reviewers will benchmark against dozens of similar state phase-in studies.
- **Recommendation:** **CONSIDER** (only if you can offer something distinctive—e.g., border-county design with stronger comparability, or a distributional approach that addresses composition and measurement issues).

---

**#4: Hawaii Prepaid Health Care Act 20-Hour Threshold**
- **Score: 46/100**
- **Strengths:** Hawaii’s 20-hour mandate threshold is genuinely distinctive and economically interesting (hours-setting, part-time work, employer benefit provision). PUMS includes hours and insurance variables that can speak directly to bunching and coverage patterns.
- **Concerns:** As proposed, an **RDD is not clean**: weekly hours are a choice variable with likely manipulation/heaping (especially at round numbers), violating key RDD assumptions; this is closer to a **bunching/kink** design than RDD. The policy is also very old (1974), so “pre/post” is impossible and many equilibrating margins have already adjusted long ago.
- **Novelty Assessment:** **Moderate-to-low.** Hawaii’s mandate and hours bunching have been studied (e.g., CPS-based work); “RDD with PUMS” is a method twist, but the core phenomenon is not new.
- **Recommendation:** **CONSIDER** only if reframed explicitly as a **bunching / difference-in-bunching** analysis (Hawaii vs other states) with careful treatment of hours heaping and falsification thresholds.

---

**#5: Utah Medicaid Expansion and Labor Supply at the 138% FPL Threshold**
- **Score: 37/100**
- **Strengths:** Medicaid labor-supply effects remain policy-relevant, and Utah’s ESI-coordination requirement is an interesting institutional feature. In principle, a threshold-based design is attractive.
- **Concerns:** With PUMS, the running variable (income-to-poverty) is noisy and partly behaviorally determined, creating severe measurement error/manipulation concerns; any discontinuity in coverage at 138% FPL is likely **fuzzy and weak**, undermining power and interpretation. Post-2020 estimates are heavily confounded by COVID-era labor market shocks; a credible design would likely require administrative enrollment/earnings data or an RD-in-time/difference-in-discontinuities structure that may still be underpowered.
- **Novelty Assessment:** **Low-to-moderate.** Medicaid expansions and threshold-based incentive effects are extensively studied; Utah’s specific twist is less studied, but PUMS is unlikely to capture it well.
- **Recommendation:** **SKIP** (unless you can access Utah administrative Medicaid + earnings data and implement a stronger design).

---

### Summary

This is a mixed batch: one genuinely high-upside idea (Kupuna Caregivers) and several that are either incremental (minimum wage, ULR) or methodologically fragile with PUMS (20-hour “RDD,” Medicaid threshold RDD). I would start with **Idea 1** immediately, but only with a design that is honest about treatment mismeasurement and that stress-tests single-state DiD assumptions; **Idea 2** is the next-best if broadened to a staggered-adoption framework rather than Utah alone.