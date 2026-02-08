# Research Idea Ranking

**Generated:** 2026-01-18T01:46:07.757888
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5099
**OpenAI Response ID:** resp_03f2bfcbb2a2d30d00696c2d25b0d8819594931c9e22cea1ac

---

### Rankings

**#1: Wisconsin BadgerCare 100% FPL Cliff and Labor Supply Distortions**
- **Score:** 74/100  
- **Strengths:** Wisconsin’s “to exactly 100% FPL” design is genuinely unusual, giving a rare opportunity to study an adult Medicaid eligibility cliff that essentially doesn’t exist elsewhere. ACS has the core outcomes (employment, hours, earnings) and a plausible running variable (poverty ratio), so a pooled multi-year design is doable.  
- **Concerns:** Identification hinges on whether ACS income (and the constructed POVPIP) is a sufficiently accurate proxy for program-relevant MAGI and household composition; expect substantial measurement error and a **fuzzy** first stage. If earnings are manipulated (bunching) and the running variable is noisy, conventional RDD estimates may be attenuated or misleading.  
- **Novelty Assessment:** **High** for this exact cliff in this exact policy environment; related work on Medicaid/benefit cliffs exists, but Wisconsin’s 100% FPL adult cutoff is unusually distinctive.  
- **Recommendation:** **PURSUE** (with an explicit fuzzy-RDD / bunching-first approach and strong validation/robustness plan)

---

**#2: Wyoming's Zero Income Tax Border and High-Earner Location Decisions**
- **Score:** 63/100  
- **Strengths:** Clear policy discontinuity (0% vs positive income tax) and high policy salience; if micro-geography were available, a spatial border design could be informative about sorting and cross-border commuting. Wyoming is understudied relative to NY/NJ/CT-style border work, so there is some “new setting” value.  
- **Concerns:** This is a classic case where the key threat is **non-comparability across the border** (amenities, labor markets, housing, geography) and **sorting is the main behavior**, which undermines the continuity assumptions needed for causal interpretation of outcomes. Using **PUMAs** (coarse geography) makes the running variable (distance to border) and “near-border” definition weak; sample sizes near WY borders may also be thin.  
- **Novelty Assessment:** **Medium.** Border tax differentials and migration/sorting have a large literature; “Wyoming specifically” is less studied, but the core question and design are not new.  
- **Recommendation:** **CONSIDER** (better if you can access finer geocodes/restricted microdata; otherwise it risks becoming descriptive)

---

**#3: Washington Cannabis Legalization Age 21 Threshold and Young Adult Employment**
- **Score:** 56/100  
- **Strengths:** The age-21 legal access cutoff is conceptually clean and policy-relevant; Washington’s early legalization offers a long post-period and potential to study labor market outcomes beyond short-run shocks.  
- **Concerns:** In **ACS PUMS**, age is effectively too coarse for a credible close-to-threshold RDD (generally years, not months/days), which can turn the design into a weak “age cell” comparison rather than an RDD. Also, age-21 discontinuities are heavily studied in other contexts (alcohol, schooling transitions), and cannabis-specific age-threshold work exists in other datasets (e.g., NSDUH), so the incremental novelty is limited.  
- **Novelty Assessment:** **Medium-low.** “Cannabis + RDD at 21” is not brand-new; Washington as an early adopter helps, but not enough to offset data/precision issues.  
- **Recommendation:** **CONSIDER** (only if you can obtain a dataset with month-of-birth / interview month precision or administrative data)

---

**#4: Wyoming Rule of 85 Pension Threshold and Public Employee Retirement Timing**
- **Score:** 44/100  
- **Strengths:** The Rule-of-85 is a well-defined incentive kink and retirement timing is a first-order policy concern for pension costs and workforce planning. With true administrative pension records, this could be a strong design.  
- **Concerns:** ACS PUMS is not fit-for-purpose here: it does **not** observe years of service, plan tier, or actual pension eligibility, and proxies like “potential experience” will generate severe misclassification around the threshold—effectively destroying the running variable. The result is likely weak/biased estimates and an identification story reviewers won’t buy.  
- **Novelty Assessment:** **Medium.** Rule-of-85/retirement incentive papers exist; Wyoming is less studied, but the contribution would be limited without administrative data.  
- **Recommendation:** **SKIP** (unless the institute can secure Wyoming retirement system microdata; then it becomes a different—and much stronger—project)

---

**#5: Washington's WA Cares Veteran 70% Disability Exemption and Labor Supply**
- **Score:** 32/100  
- **Strengths:** Extremely timely and plausibly unstudied; the exemption creates an intuitively sharp threshold tied to a concrete tax wedge, and policymakers in WA would care about behavioral responses and equity impacts.  
- **Concerns:** The fatal issue is data: ACS does not reliably provide the **exact VA disability rating percentage** needed to run an RDD at 70%, and the policy is very new (thin post period, implementation/takeup complexity). Without a credible measure of the running variable and enough post-exemption observations, the design collapses.  
- **Novelty Assessment:** **Very high** on the specific WA Cares × VA rating interaction; but novelty cannot compensate for missing running-variable data.  
- **Recommendation:** **SKIP** (or re-scope as a future admin-data project with VA rating records and WA earnings/tax data—otherwise not viable)

---

### Summary

This is a solid batch in terms of policy motivation, but most ideas lean heavily on ACS PUMS in ways that either coarsen the running variable (age, geography) or fail to measure it at all (VA rating, years of service). The clear “best bet” to pursue now is **Wisconsin’s 100% FPL BadgerCare cliff**, because it combines distinctive policy design with feasible measurement and a defensible identification strategy (likely fuzzy RDD plus bunching). The Wyoming border tax idea is next-best but needs finer geography (or a reframing away from causal border-RDD claims) to be publishable.