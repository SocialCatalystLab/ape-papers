# Research Idea Ranking

**Generated:** 2026-01-27T08:37:12.969773
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5767
**OpenAI Response ID:** resp_0c8925d5d9732a7d0069786ad919b0819793681767b5e74cc1

---

### Rankings

**#1: Minimum Wage Increases and Teen Time Allocation: Direct and Spillover Effects**
- **Score: 72/100**
- **Strengths:** Very strong novelty in *outcomes* (time allocation) relative to the saturated MW-employment literature, and ATUS is unusually well-suited to measuring behavioral margins beyond employment. Staggered policy variation is abundant, and modern staggered-DiD estimators (Callaway–Sant’Anna) are appropriate.
- **Concerns:** The biggest risks are (i) **timing misclassification** if MW changes are coded annually rather than by *effective date*, and (ii) **outcome dilution/power**—many teens are not directly exposed to MW changes, and even among workers, only a subset are MW-bound. Also, MW changes co-move with other progressive state policies, raising omitted-variable concerns.
- **Novelty Assessment:** **High for the specific question/outcomes** (teen time diaries and spillovers to non-working teens). Minimum wage effects broadly are heavily studied, but this is a meaningfully new behavioral margin and population/outcome pairing.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** — 2003–2023 allows long pre-periods for most *increase events* (but you should drop/flag very early “always-high” states or very early increases with thin pre-trends).
  - **Selection into treatment:** **Marginal** — adoption is political and may correlate with underlying labor-market/social trends; not obviously driven by teen time use, but still plausibly endogenous to state trajectories.
  - **Comparison group:** **Marginal** — “never-treated” states are few and systematically different (often lower-wage Southern states); relying on not-yet-treated helps, but composition of controls changes over time.
  - **Treatment clusters:** **Strong** — 30+ treated states (and many increase events); clustering at state level is feasible.
  - **Concurrent policies:** **Marginal** — MW increases often bundled with EITC changes, paid sick leave, scheduling laws, etc.; you’ll need a policy-controls strategy (or show robustness to excluding big reform packages).
  - **Outcome-Policy Alignment:** **Strong** — minutes in work/school/homework/leisure directly reflect the mechanisms through which MW could affect teens.
  - **Data-Outcome Timing:** **Strong (conditional)** — ATUS is diary-date specific; many MW changes are effective **Jan 1 or Jul 1**. If you assign treatment using the *exact diary/interview date relative to the MW effective date* (not “state-year MW”), timing is clean. If coded annually, this becomes **Marginal/Weak** due to mechanical attenuation around mid-year changes.
  - **Outcome Dilution:** **Marginal** — among *all teens*, the directly affected share (MW-bound workers in sensitive industries) is likely well below 50%. This is fixable by (a) estimating effects for MW-sensitive working teens (direct) and (b) treating spillovers to non-workers as a separate estimand with realistic expected magnitudes/power calculations.
- **Recommendation:** **PURSUE (conditional on: coding treatment by effective date using ATUS interview/diary month; pre-trend/event-study diagnostics by cohort; a clear plan for dilution/power—especially for spillovers; explicit controls/robustness for bundled state policy changes).**

---

**#2: Minimum Wage and Teen School-Work Trade-offs by Family Income**
- **Score: 63/100**
- **Strengths:** A credible and policy-relevant heterogeneity question (distributional impacts) with a clear theoretical ambiguity; using time use to adjudicate mechanisms is a nice contribution beyond employment-only outcomes.
- **Concerns:** This is essentially **Idea 1 + heterogeneity**, so incremental novelty is moderate. The major practical threat is **power**: ATUS teen samples are not huge at the state×year level, and splitting into income terciles (plus MW-sensitive subgroups) will quickly make estimates noisy and pre-trend tests underpowered.
- **Novelty Assessment:** **Moderate** — heterogeneity of MW effects by SES/income is studied in adjacent ways (employment/schooling), but *mechanisms via time use by income* is less studied. Still, it’s a natural extension rather than a new research area.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** — same as Idea 1.
  - **Selection into treatment:** **Marginal** — same endogeneity concerns as Idea 1.
  - **Comparison group:** **Marginal** — same as Idea 1.
  - **Treatment clusters:** **Strong** — same as Idea 1.
  - **Concurrent policies:** **Marginal** — same as Idea 1, with added concern that other policies may differentially affect low-income teens.
  - **Outcome-Policy Alignment:** **Strong** — school/work/homework time are tightly linked to the hypothesized mechanism (opportunity cost vs human capital investment).
  - **Data-Outcome Timing:** **Strong (conditional)** — same effective-date requirement as Idea 1.
  - **Outcome Dilution:** **Marginal to Weak (depends on implementation)** — the “affected share” becomes small once you split by income; even if effects exist, estimates may be too imprecise to be policy-informative without pooling strategies.
- **Recommendation:** **CONSIDER (only after Idea 1 establishes baseline effects; conditional on: a serious power analysis; possibly coarser heterogeneity bins (e.g., below/above median), pooling across MW-sensitive industries, and/or focusing on a small set of primary outcomes to limit multiple-testing).**

---

**#3: Minimum Wage Spillovers Within Households**
- **Score: 44/100**
- **Strengths:** The mechanism focus (intra-household labor reallocation) is genuinely interesting and could be a valuable complement if identified well. It also could help distinguish labor-demand vs household-bargaining channels.
- **Concerns:** Identification is the core problem: “exposure” (having a parent/sibling in MW-sensitive industries) is **highly endogenous** and correlated with unobservables that directly affect teen time use (SES, preferences, constraints). With ATUS observing only one diary per household and limited longitudinal structure, you have weak leverage to separate MW shocks from household selection/composition changes.
- **Novelty Assessment:** **Moderate-High** as a mechanism, but novelty cannot compensate for weak identification in this setup.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** — in principle.
  - **Selection into treatment:** **Weak** — while MW adoption is external to a given household, the *exposure group definition* (MW-sensitive household member) is choice-driven and can change endogenously around MW hikes (industry switching, hours changes), directly contaminating DiD/DDD contrasts.
  - **Comparison group:** **Weak** — households “with MW-sensitive worker” vs “without” are structurally different; even within-state, this is not a credible counterfactual without much richer panel/administrative data.
  - **Treatment clusters:** **Strong** — plenty of states/events, but that does not fix within-state selection.
  - **Concurrent policies:** **Marginal** — still relevant, but dominated by the exposure endogeneity problem.
  - **Outcome-Policy Alignment:** **Marginal** — teen time use is relevant, but the mapping from MW policy → household member wage change → teen time use is indirect and poorly measured in ATUS.
  - **Data-Outcome Timing:** **Strong (conditional)** — can be aligned by diary date, but again not the binding constraint.
  - **Outcome Dilution:** **Weak/Marginal** — the share of teen households with clearly identified MW-sensitive earners is likely small, and misclassification is likely (industry ≠ MW-bound; wage not observed for all household members).
- **Recommendation:** **SKIP (as a standalone paper).** At most, treat as an exploratory appendix/robustness exercise, or redesign using administrative UI wage records or linked household panel data where exposure and wage changes are observed directly.

---

### Summary

This is a solid batch with one clearly promising core project: **Idea 1** stands out because it brings genuinely new outcome measurement (teen time allocation) to a policy space where identification tools are mature. **Idea 2** is a plausible second step but is at high risk of being underpowered once you stratify. **Idea 3** fails the “selection/comparison group” requirements in a way that is hard to fix with ATUS alone, so I would not fund it as a primary project.