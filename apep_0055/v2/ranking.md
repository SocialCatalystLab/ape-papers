# Research Idea Ranking

**Generated:** 2026-01-23T14:52:03.956711
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6711
**OpenAI Response ID:** resp_0fb4c47205cb980a0069737cb182f081938def096f725bb2fe

---

### Rankings

**#1: Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid? (RDD)**
- **Score: 74/100**
- **Strengths:** High policy salience (Medicaid vs private payment at delivery) and extremely large natality microdata gives strong precision. The age-26 cutoff is plausibly exogenous and directly tied to the insurance mechanism you measure (payer at delivery).
- **Concerns:** In the **public-use** Natality file, mother’s age is typically measured in **integer years**, not exact days-from-birthday—so this is not a truly “sharp” birthday RDD; it’s effectively a **discrete/fuzzy RD** with substantial treatment misclassification (many “26-year-olds” are still eligible until their birthday). Also, outcomes among *births* can be compositionally affected if the policy changes who gives birth near 26 (selection on fertility timing), so you must check for discontinuities in the density of births and covariates.
- **Novelty Assessment:** **Moderately novel.** The ACA dependent coverage cutoff is heavily studied (insurance, labor supply, utilization), and there are some papers on young women and maternity-related outcomes using DiD/age-group comparisons; **a well-executed RD-style design focused on payer at delivery using natality microdata would still be a meaningful incremental contribution**, especially if you can credibly implement the cutoff at the actual birthday.
- **Recommendation:** **PURSUE (conditional on: obtaining/constructing a running variable closer to exact age-at-delivery, e.g., restricted natality with maternal DOB or another dataset with exact age; demonstrating no discontinuities in predetermined covariates and no bunching in births at 26; treating this explicitly as fuzzy/discrete RD if exact age is unavailable).**

---

**#2: Did Removing Age Restrictions on Emergency Contraception Reduce Teen Pregnancy? (RDD-in-time)**
- **Score: 44/100**
- **Strengths:** The policy date is clear and national, and teen birth outcomes are measurable at high frequency with CDC data. If effects exist, policymakers care (teen pregnancy is a core public health target).
- **Concerns:** **RD-in-time is fragile** here: teen birth rates were already on a strong secular downward trend, and many contemporaneous forces (economy, contraception trends, state policies, ACA-related changes) can generate “breaks” unrelated to Plan B access. The key behavioral effect should operate on **conceptions**, but births respond with a lag and seasonality—small misspecification can drive results; plus prior literature generally finds **small population-level effects**, so nulls are hard to interpret.
- **Novelty Assessment:** **Low to moderate.** Emergency contraception access and teen fertility has a substantial empirical literature (using earlier OTC changes, age thresholds, and state variation). A pure time-RD around June 2013 is not an obviously new angle unless paired with a clearly superior identification strategy.
- **Recommendation:** **CONSIDER (only if redesigned away from pure time-RD—e.g., leverage age-specific exposure and long pre-trends with an age-by-time design, or exploit meaningful cross-state variation in pre-2013 enforcement/access; otherwise SKIP).**

---

**#3: Did OTC Birth Control (Opill) Approval Affect Fertility? (RDD-in-time)**
- **Score: 38/100**
- **Strengths:** Very high policy relevance and potentially high upside: OTC daily contraception is a major market/policy shift, and evidence will be in demand.
- **Concerns:** As proposed, identification is weak: **no sharp threshold** (approval in 2023 vs uneven retail availability in 2024; adoption/stocking is staggered), and the post-period is heavily confounded by other major fertility shocks/policy changes (notably the post-Dobbs environment and ongoing state abortion/contraception policy changes). Even by early 2026 you’ll have limited clean post exposure for births and especially for conception-based outcomes.
- **Novelty Assessment:** **High.** There will not yet be many causal papers on Opill’s OTC availability, simply because it’s new.
- **Recommendation:** **SKIP for now (or CONSIDER only with a different design that uses differential rollout/availability or price/coverage variation—e.g., retailer-level penetration, state pharmacy environment, or claims/sales data—rather than a national time cutoff).**

---

**#4: Does Age 18 Eligibility for Pharmacist-Prescribed Contraception Increase Use? (Age-18 RDD)**
- **Score: 22/100**
- **Strengths:** The policy margin (pharmacist prescribing) is concrete and potentially important for access, especially for minors.
- **Concerns:** The age-18 cutoff is a **confounding magnet** (school completion, leaving home, consent/privacy changes, sexual behavior dynamics), so even a clean statistical discontinuity would be hard to attribute to pharmacist prescribing. Data feasibility is also poor as written: you lack a credible, age-specific measure of pharmacist-prescribed contraception uptake, and the policy environment is heterogeneous and fuzzy across a small set of states.
- **Novelty Assessment:** **Moderate** (there’s public health work on pharmacist prescribing, but less clean causal work on age-restriction variants), but novelty can’t compensate for weak identification and weak measurement.
- **Recommendation:** **SKIP.**

---

### Summary

This batch has **one genuinely fundable idea**: the age-26 dependent coverage project, *if* you can implement a credible birthday-based (or explicitly fuzzy/discrete) RD and pass density/balance diagnostics. The other three are dominated by **RD-in-time fragility** (Ideas 2 and 4) or **severe confounding + missing key exposure data** (Idea 3). If the institute wants a second option, the Plan B project is only worth pursuing after a major redesign that introduces a more credible counterfactual than a simple national time cutoff.