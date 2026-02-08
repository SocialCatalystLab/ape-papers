# Research Idea Ranking

**Generated:** 2026-01-18T19:03:15.038376
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 7224
**OpenAI Response ID:** resp_095662201981a4bc00696d201023e08194b99ed05f2acfb068

---

### Rankings

**#1: Mothers' Pension Benefit Loss at Child Age 14 → Maternal Labor Supply**
- **Score:** 74/100
- **Strengths:** Creative use of a mechanically determined eligibility cliff that is plausibly exogenous to maternal tastes/skills, and the maternal labor-supply margin is meaningfully less studied than child outcomes in this program. Very large samples in full-count data make heterogeneity and precision feasible.
- **Concerns:** In the Census you typically observe **age in years**, not months, so the running variable is discrete and may be heaped—this can materially weaken RD credibility and requires “discrete RD” methods. More importantly, you **do not observe pension receipt**, so this is an “intent-to-treat” RD with an unknown/variable first stage (and eligibility/termination was often discretionary and sometimes at 16, not 14), which can dilute effects and complicate interpretation.
- **Novelty Assessment:** **Moderately high novelty.** Mothers’ pensions are heavily studied (esp. child outcomes and cross-area generosity), but an RD at the **age-of-youngest-child termination margin** for **maternal employment** is not something I recall seeing as a main design in the core literature.
- **Recommendation:** **PURSUE** (but only after confirming: (i) which states/counties had truly sharp termination at 14, (ii) the extent of discretion/grace periods, and (iii) whether age measurement allows a credible RD.)

---

**#2: Old Age Assistance Age-65 Threshold → Elderly Living Arrangements**
- **Score:** 66/100
- **Strengths:** Strong policy relevance and a clean, well-defined eligibility threshold with enormous sample size; living arrangements/institutionalization are outcomes policymakers care about and are well-measured in 1940. This is a natural complement to the established OAA-at-65 labor-supply work.
- **Concerns:** This is a **fuzzy RD** (means-tested, take-up varies, and you likely don’t observe receipt in Census microdata), so interpretation is reduced-form unless you can credibly proxy eligibility intensity. Age 65 also coincides with **retirement norms and other pensions**, and **age heaping at 65** is a serious threat to RD smoothness and must be convincingly addressed.
- **Novelty Assessment:** **Moderate novelty.** OAA around age 65 is a well-trodden identification strategy; the *specific outcome* (household composition/institutionalization) is less saturated than labor supply, but not wholly untouched in broader “pensions and co-residence” literatures.
- **Recommendation:** **CONSIDER** (good project if you can: (i) show no large discontinuities in other mechanisms at 65, and (ii) leverage strong cross-state generosity/administrative features to sharpen the first stage.)

---

**#3: Women’s Suffrage State Border Geographic RDD**
- **Score:** 58/100
- **Strengths:** High-concept novelty: a border-based design could, in principle, improve on classic state-level DiD by tightening comparability. The question remains policy-relevant (political rights → economic outcomes) and would be of wide scholarly interest if credibly executed.
- **Concerns:** Geographic RDD at state borders is fragile here because suffrage adoption correlates with many other state differences (progressive reforms, labor regulation, schooling, urbanization, industry mix), and border counties can be systematically non-comparable. Selective migration and potentially small/imbalanced border samples (especially in the West) could make estimates noisy and contestable.
- **Novelty Assessment:** **High novelty in design**, lower novelty in question. Suffrage impacts are well-studied, but I agree a *true* border-RD implementation is relatively uncommon.
- **Recommendation:** **CONSIDER** (only if you can pre-specify a small set of compelling border pairs with strong balance tests and show robustness to alternative border segments / donut RD / border-pair fixed effects.)

---

**#4: WWI Draft Eligibility Birth Cohort → Marriage and Family Formation**
- **Score:** 54/100
- **Strengths:** Potentially novel application of cohort cutoffs to family formation, an outcome set less studied than earnings/education in conscription papers. Large cohorts in full-count Censuses make subgroup analyses feasible.
- **Concerns:** The **first stage is unclear** because WWI registration occurred in multiple waves (including the 18–45 expansion), so “born just before vs. after” a single cutoff may not generate a sharp discontinuity in actual service risk. Key outcomes (age at first marriage, completed fertility) are not cleanly observed for men in these Censuses, so you risk measurement-driven ambiguity.
- **Novelty Assessment:** **Moderate novelty.** WWI draft RD designs exist in some form, and conscription effects on marriage are widely studied in other contexts; the WWI-specific marriage/fertility angle is less crowded but not obviously breakthrough without a very strong first stage.
- **Recommendation:** **SKIP** unless you can (i) identify a cutoff with a demonstrably strong service discontinuity and (ii) measure marriage/fertility outcomes convincingly (potentially requiring links beyond cross-sectional Census measures).

---

**#5: Child Labor Law Age-14 Work Permit Threshold → Child Schooling and Labor**
- **Score:** 50/100
- **Strengths:** Extremely feasible with massive samples and outcomes measured directly (schooling/employment). Policy relevance is clear and results would be easy to communicate.
- **Concerns:** Novelty is low and the RD is not clean: age 14 coincides with **schooling transitions, social norms, and reporting changes**, and many children worked in agriculture/informal settings not tightly governed by the statutory cutoff. With age measured in years, the “RD” becomes a coarse comparison that is easy to critique as capturing broad age-related changes rather than legal permission alone.
- **Novelty Assessment:** **Low.** Child labor laws and compulsory schooling are among the most studied early-20th-century policy topics; an age-threshold RD angle is not enough by itself to differentiate the contribution.
- **Recommendation:** **SKIP** (unless you uncover a genuinely underused enforcement shock or administrative linkage that makes the design substantively new).

---

### Summary

This is a solid batch with one genuinely strong lead: **Idea 1** stands out because it targets an important margin (maternal labor supply) with a plausibly exogenous eligibility cliff that is not the standard approach in the mothers’ pension literature. **Idea 2** is the best backup—credible and policy-relevant, but less novel and with the usual fuzzy-RD/age-heaping concerns. The remaining ideas are either identification-fragile (suffrage border RD), first-stage/measurement challenged (WWI draft), or too saturated (child labor).