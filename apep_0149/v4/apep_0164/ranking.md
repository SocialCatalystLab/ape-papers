# Research Idea Ranking

**Generated:** 2026-01-28T21:02:26.425621
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 7829
**OpenAI Response ID:** resp_0c5fa72dc20ae72200697a6adddcdc81939c3fa4919c768d7e

---

### Rankings

**#1: State Minimum Wage Increases and New Business Formation**
- **Score: 69/100**
- **Strengths:** Uses a relatively new, high-frequency administrative outcome (BFS) with good pre-period coverage and lots of policy variation; business formation is a policy-relevant margin that’s not as saturated as MW–employment. Monthly data allows cleaner timing alignment than most MW studies.
- **Concerns:** Minimum wage changes are politically/endogenously adopted and often bundled with other labor-market policies (paid leave, EITC changes, scheduling laws), threatening parallel trends; “business applications” may respond to macro/credit conditions differently across states, complicating comparisons.
- **Novelty Assessment:** **Moderately novel.** There is a huge MW literature, and some work on entrepreneurship/firm dynamics exists, but BFS-based state-month analysis of applications/high-propensity applications is still less crowded than MW–employment.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (BFS from 2004; many major hikes post-2014 → ample pre-trends)
  - **Selection into treatment:** **Marginal** (policy responds to politics/cost-of-living and possibly local labor-market trends)
  - **Comparison group:** **Marginal** (never/low-change states are disproportionately Southern/rural and structurally different)
  - **Treatment clusters:** **Strong** (well over 20 states with meaningful changes)
  - **Concurrent policies:** **Marginal** (common co-movement with other pro-worker policies and economic cycles; needs explicit controls/robustness)
  - **Outcome-Policy Alignment:** **Strong** (labor-cost policy plausibly shifts entry decisions; BFS directly measures the entry margin)
  - **Data-Outcome Timing:** **Strong** (BFS is monthly by application date; MW effective dates often Jan 1/Jul 1—can code “first full month of exposure” and exclude partial months)
  - **Outcome Dilution:** **Marginal** (MW mainly binds in low-wage sectors; aggregate applications include many unaffected industries—mitigate by NAICS stratification and “applications with planned wages” / high-propensity series)
- **Recommendation:** **PURSUE (conditional on: (i) using modern staggered-adoption methods + transparent pre-trends/event studies; (ii) sectoral/“bindingness” design—e.g., exposure based on pre-policy wage distribution or low-wage-industry shares; (iii) explicit sensitivity to concurrent policies/business-cycle shocks).**

---

**#2: State Nurse Practitioner Full Practice Authority and Rural Mental Health Treatment**
- **Score: 62/100**
- **Strengths:** The rural mental health angle is policy-salient and less studied than overall primary care access; triple-difference (FPA × rural × post) is a credible strategy to soak up many state-level shocks if rural/urban trends are stable within state.
- **Concerns:** Post-2010 FPA adoptions may yield limited treated clusters (inference fragility), and mental health access is heavily affected by contemporaneous shocks (Medicaid expansion, telehealth rules, provider networks) that may differentially hit rural areas—this is the main identification risk.
- **Novelty Assessment:** **Moderate.** FPA is well-studied; “mental health in rural areas” is less saturated, but not untouched. The contribution hinges on a clearly mental-health-specific mechanism/outcome and stronger design than prior FPA papers.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (BRFSS/AHRF go back decades; easy to get ≥5 pre-years)
  - **Selection into treatment:** **Marginal** (adoption may respond to provider shortages and political environment; not plausibly random)
  - **Comparison group:** **Strong/Marginal** (the *within-state* rural vs urban contrast is helpful; cross-state comparability still imperfect)
  - **Treatment clusters:** **Marginal** (depending on window; post-2010 adopters likely ~10–15, not 20+)
  - **Concurrent policies:** **Marginal** (potentially severe due to ACA Medicaid expansion timing, MH parity enforcement, telehealth expansions; must model explicitly, possibly with interactions for rurality)
  - **Outcome-Policy Alignment:** **Marginal** (BRFSS “mentally unhealthy days” is not treatment; use direct utilization/access measures—e.g., “received counseling/treatment,” unmet need, provider counts)
  - **Data-Outcome Timing:** **Marginal** (BRFSS is fielded throughout the year; if FPA effective mid-year, “treated year” has partial exposure—need careful coding or drop transition years)
  - **Outcome Dilution:** **Strong (if executed correctly)** (restrict analysis to rural respondents/areas rather than statewide averages; otherwise dilution is nontrivial because rural share is often ~15–20%)
- **Recommendation:** **CONSIDER (conditional on: (i) committing to rural-only outcomes to avoid dilution; (ii) explicit handling of Medicaid expansion/telehealth with interactions and/or sample restrictions; (iii) demonstrating stable rural–urban pre-trends within states).**

---

**#3: State Opioid Prescribing Limits and Labor Force Participation**
- **Score: 48/100**
- **Strengths:** The specific link from acute prescribing limits to labor-market outcomes is relatively unexplored and the policy variation (many adoptions, clear dates, monthly CPS) is attractive on paper.
- **Concerns:** The design is very likely to fail on identification: adoption is strongly responsive to the opioid crisis trajectory (selection on trends) and coincides with many other opioid-related and health policies; moreover, CPS labor force outcomes are extremely broad relative to a targeted prescribing restriction, creating severe dilution.
- **Novelty Assessment:** **High on the exact policy–outcome pairing**, but adjacent literatures (opioids and labor markets; opioid policy and health outcomes) are substantial—so novelty alone can’t rescue weak identification/measurement.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (CPS available well before 2016)
  - **Selection into treatment:** **Weak** (states adopted largely *because* opioid misuse/prescribing was salient—very likely correlated with labor-market and health trends)
  - **Comparison group:** **Marginal** (remaining never-treated states by 2019 are a small and potentially non-comparable set)
  - **Treatment clusters:** **Strong** (~39 treated by 2019)
  - **Concurrent policies:** **Weak** (PDMP expansions, pill-mill laws, naloxone access, Medicaid expansion, litigation/settlements—many coincide and plausibly affect labor outcomes)
  - **Outcome-Policy Alignment:** **Marginal/Weak** (LFP/employment are downstream, noisy aggregates; hard to interpret nulls/positives)
  - **Data-Outcome Timing:** **Strong** (CPS monthly; can align to effective month—CPS reference week is typically the week including the 12th)
  - **Outcome Dilution:** **Weak** (acute opioid limits directly affect a small share of working-age adults at any point—plausibly <10%; aggregate LFP is dominated by unaffected people)
- **Recommendation:** **SKIP (unless redesigned)**—a salvage path would require outcomes closer to the treated margin (e.g., linked claims/medical data, injury/surgery subpopulations, disability/pain-related work limitations), which CPS alone cannot deliver cleanly.

---

**#4: Recreational Marijuana Legalization and Workers’ Compensation Claims**
- **Score: 45/100**
- **Strengths:** Highly policy-relevant for workplace safety and employer regulation; staggered adoption is substantial, and the mechanism could run in either direction (impairment vs substitution away from opioids/alcohol).
- **Concerns:** Data feasibility is the binding constraint: truly comparable state-level WC *claims* series are often proprietary (NCCI/insurers) or inconsistently reported across states; CPS “workers’ compensation income receipt” is rare and likely too noisy/diluted to detect policy effects. Timing is also tricky (legalization vs retail sales opening vs workplace rules).
- **Novelty Assessment:** **Medium-to-low.** There is already emerging work on RML and workplace injuries/WC outcomes (including at least one prominent working paper); a new paper needs clearly better data or design to stand out.
- **DiD Assessment (if applicable):**
  - **Pre-treatment periods:** **Strong** (plenty of pre-2012 data in principle)
  - **Selection into treatment:** **Marginal** (often ballot initiative—better than purely legislative—but still correlated with demographics/attitudes/trends)
  - **Comparison group:** **Marginal** (never-treated states differ systematically)
  - **Treatment clusters:** **Strong** (24+ adopters)
  - **Concurrent policies:** **Marginal** (medical marijuana, decriminalization, opioid policies, workplace testing rules)
  - **Outcome-Policy Alignment:** **Strong (conceptually)** if using actual WC claims/benefits; **Weak in practice** if forced to use CPS income receipt as a proxy
  - **Data-Outcome Timing:** **Marginal/Weak** if annual data can’t distinguish legalization from retail access (often 6–18 months later); needs monthly/quarterly claims with correct “first full exposure” coding
  - **Outcome Dilution:** **Weak** if using CPS WC receipt (tiny share of population receives WC income in a given year); **Strong** if using claims counts among workers (but that’s the hard-to-get data)
- **Recommendation:** **SKIP (unless you have credible administrative WC claims data with consistent multi-state coverage and high-frequency timing).**

---

### Summary

This is a solid batch conceptually, but two ideas (opioid limits → LFP; RML → WC via public data) are likely to fail on core identification/measurement—especially outcome dilution and confounding from concurrent policies. The minimum wage–BFS project is the most “ready-to-execute” with credible timing and data, while the NP FPA rural mental health idea is promising if you explicitly confront Medicaid/telehealth confounds and keep outcomes tightly aligned to access/utilization in rural populations.