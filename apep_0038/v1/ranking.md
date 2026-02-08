# Research Idea Ranking

**Generated:** 2026-01-19T21:36:18.787484
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4202
**OpenAI Response ID:** resp_0cea965e9d1d096200696e959a14288197a6782befb7a3df14

---

### Rankings

**#1: Sports Betting Legalization and State Employment**
- **Score: 74/100**
- **Strengths:** Clear policy shock with rich staggered adoption (many treated states) and strong administrative data options (QCEW) for sector-specific employment where effects—if any—should show up. High policy salience given ongoing legalization and industry job-creation claims.
- **Concerns:** The *Murphy* decision is exogenous, but **state adoption timing and form (mobile/retail, tax rates, licensing rules)** are plausibly endogenous to local economic conditions; a naive staggered DiD risks bias. Effects may be mostly **reclassification/formalization** (or substitution within leisure) rather than net job creation, making interpretation delicate.
- **Novelty Assessment:** Moderately novel. There is a large gambling/casino local-economy literature and a fast-growing sports betting literature, but **credible causal estimates on employment impacts of sports betting legalization specifically** are still relatively sparse.
- **Recommendation:** **PURSUE** (but only with a careful design: Sun-Abraham/Callaway-Sant’Anna estimators, event-study diagnostics, and ideally robustness using bordering counties or differential exposure to mobile vs retail rollout).

---

**#2: Domestic Violence Leave Laws and Women’s Employment**
- **Score: 63/100**
- **Strengths:** Genuinely underexplored policy lever with long-run, multi-state variation and a question policymakers could care about (labor market attachment, potential unintended hiring effects). CPS monthly data allow granular timing and subgroup analysis.
- **Concerns:** Identification is the main weakness: long adoption windows coincide with many correlated reforms (paid sick leave, family leave, EEO enforcement shifts), making **parallel trends hard to defend** without extensive controls/negative-control outcomes. The treated population (DV victims) is small relative to all women, so aggregate employment effects may be **too diluted to detect**, yielding a likely “zero” that is hard to interpret.
- **Novelty Assessment:** Fairly novel for **aggregate** women’s labor-market outcomes; most work I’m aware of focuses on victims, services, or legal implementation rather than state-level ITT effects on overall female employment.
- **Recommendation:** **CONSIDER** (best if reframed toward outcomes more directly linked to the policy—job separations/tenure, short-run employment retention around enactment, or groups plausibly at higher DV risk—plus stronger confound checks).

---

**#3: Pay Transparency Laws and Wage Compression**
- **Score: 57/100**
- **Strengths:** High topical relevance and a relatively new U.S. policy wave; strong “why now” motivation and clear theoretical ambiguity (wage compression vs wage increases vs composition effects). Potential to contribute if you can credibly isolate effects.
- **Concerns:** As proposed, the design is fragile: **few treated states**, short post-periods for many adopters, and large **spillovers** (remote work and national posting practices) that blur treated vs control states. CPS/ACS wage measures are noisy for the key margins (new-hire offers, within-firm pay structure), so you may miss the mechanism even if it exists.
- **Novelty Assessment:** High-to-moderate. There’s emerging work (notably on Colorado and some related transparency settings), but a credible multi-state causal estimate is still not saturated—however, many groups are actively working on this now, so novelty is shrinking quickly.
- **Recommendation:** **CONSIDER** only if you can upgrade data/identification (e.g., job-posting microdata like Lightcast/Burning Glass, enforcement/intensity measures, firm-level exposure, and an explicit spillover strategy). Otherwise **SKIP**.

---

**#4: State Clean Slate Laws and Employment by Demographic Group**
- **Score: 32/100**
- **Strengths:** Important policy area with clear distributional stakes and strong interest from justice and labor agencies; plausible heterogeneity by race/age.
- **Concerns:** Low incremental contribution given prior work already using essentially the same state-level DiD framing, plus limited treated states and likely **implementation lags/partial take-up** that CPS cannot observe. Without administrative expungement/timing data, the analysis risks being an underpowered, noisy ITT replication.
- **Novelty Assessment:** Low. Clean slate/expungement and related record-sealing policies are an active literature, and you cite at least one closely overlapping DiD study already.
- **Recommendation:** **SKIP** (unless you can obtain administrative expungement records and exploit sharp rollout features or eligibility discontinuities).

---

### Summary

This is a solid batch conceptually, but only one proposal is close to “ready to run” with a credible path to causal inference using available data. **Idea 1** is the clear first-best: it has the best combination of novelty, feasible measurement (QCEW), and statistical power, provided you take staggered-adoption biases and policy heterogeneity seriously. **Idea 2** is next but needs tighter identification and outcomes; **Idea 3** is exciting but currently underidentified without better data and a spillover plan; **Idea 4** is least promising due to overlap with existing studies and weak observability of treatment intensity.