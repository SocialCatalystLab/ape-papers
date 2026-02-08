# Research Idea Ranking

**Generated:** 2026-01-19T13:41:21.542406
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 3668
**OpenAI Response ID:** resp_041b4f8be218b45100696e2647c8108194be13a13e48ff5efc

---

### Rankings

**#1: Noncompete Agreement Restrictions and Worker Mobility**
- **Score: 76/100**
- **Strengths:** Minnesota’s 2023 full ban is genuinely new large-policy variation, and QWI job-to-job flows are unusually well-suited to measuring mobility responses (levels and earnings gains for movers). Policy relevance is high given current federal/state interest in noncompetes.
- **Concerns:** With essentially one marquee “full ban” treated state, standard staggered DiD will be fragile (few treated units, sensitivity to donor pool, and confounding contemporaneous Minnesota labor-market dynamics). Enforcement/compliance and heterogeneous “income-threshold” reforms across other states complicate defining treatment intensity and timing.
- **Novelty Assessment:** Noncompetes are heavily studied in general (lots of papers on enforceability and cross-state differences), but *this specific post-2021 wave—especially Minnesota’s full ban—*is close to unstudied, making the marginal contribution potentially large.
- **Recommendation:** **PURSUE** (but design it as augmented DiD + synthetic control style robustness; consider border-county designs and treatment-intensity definitions for threshold states).

---

**#2: Pay Transparency Laws and the Gender Wage Gap**
- **Score: 71/100**
- **Strengths:** Multiple recent adoptions create credible timing variation with many never-treated controls, and the policy question is highly salient for state labor agencies and legislators. There is room to add value by focusing on gender gaps, within-firm compression, and worker flows rather than just posted wages.
- **Concerns:** The link from “posting ranges” to realized wages (and to the *gender wage gap*) may be slow and noisy; compositional changes (who applies, who is hired, remote-work postings crossing state lines) threaten interpretation. QWI/ACS can measure outcomes, but pinning the mechanism on pay transparency versus broader HR/DEI shifts will be challenging.
- **Novelty Assessment:** Pay transparency is an emerging literature: not saturated yet, but no longer blank-slate (early NBER/working papers and a growing set of state-specific evaluations). Still, the 2023–2024 expansions keep it meaningfully fresh.
- **Recommendation:** **PURSUE** (best if you pre-specify outcomes, address remote postings/extraterritorial compliance, and use modern staggered DiD with careful event-study diagnostics).

---

**#3: State EITC Expansions and Labor Force Participation**
- **Score: 62/100**
- **Strengths:** The policy is first-order for anti-poverty strategy, and there is genuine new post-2020 variation (including Washington’s unusual adoption). A well-executed modern DiD/event study could update older evidence and speak directly to current state design choices (refundability, generosity).
- **Concerns:** Identification is the core weakness: EITC changes are often endogenous to state economic/political trends, and “parallel trends” is hard to defend for labor supply. Data feasibility is also weaker than it looks—effects concentrate among eligible households, and ACS-based eligibility proxies are noisy; state EITC impacts can be diluted in aggregate LFP measures without high-quality tax/administrative data or strong subgroup design.
- **Novelty Assessment:** The EITC is one of the most-studied policies in applied micro; while *these specific* state expansions are newer, the incremental novelty is moderate because the conceptual question has a very large prior literature and well-known identification critiques.
- **Recommendation:** **CONSIDER** (worth doing only if you can credibly target eligible groups—e.g., by education/children/earnings bands—and tightly address policy endogeneity; otherwise it risks being unpersuasive).

---

**#4: Tipped Minimum Wage Elimination and Service Sector Employment**
- **Score: 48/100**
- **Strengths:** Clear policy interest (restaurants, worker earnings, consumer prices) and measurable sector outcomes (QWI/BLS). Michigan and D.C. developments are attention-grabbing and could motivate a focused case study.
- **Concerns:** This is the weakest identification setup: “never tip credit” states differ structurally and politically, making long-run cross-state DiD especially vulnerable to non-parallel trends and bundled policies (overall minimum wage, labor standards, unionization, cost of living). Michigan’s legal whiplash creates ambiguous treatment timing/dose, reducing interpretability and power.
- **Novelty Assessment:** Tip-credit and tipped wage policies have been studied in the minimum-wage literature more than the proposal suggests; the incremental novelty is limited unless you have a uniquely clean shock or new micro data on tipped workers.
- **Recommendation:** **SKIP** (unless you can isolate a clean, sharp policy change with stable implementation and a convincing counterfactual—otherwise it’s likely to be debated rather than informative).

---

### Summary

This is a solid batch in terms of policy relevance and basic data access, but only two ideas look strongly fundable on “novel + plausibly identified”: **noncompete restrictions (especially Minnesota)** and **pay transparency**. If choosing one to start, I’d prioritize **noncompetes** for novelty and outcome fit (mobility), while treating **pay transparency** as a close second with somewhat cleaner multi-state timing but more interpretational noise around mechanisms and remote postings.