# Research Idea Ranking

**Generated:** 2026-01-20T15:35:27.798616
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 3043
**OpenAI Response ID:** resp_0d298c1b0b31161f00696f928d46448193ab41f39e84b7ed63

---

### Rankings

**#1: Self-Employment Premium — Incorporated vs Unincorporated Businesses (Idea 3)**
- **Score: 60/100**
- **Strengths:** Clear, well-measured treatment in ACS (class of worker) with a large sample and a naturally restricted comparison set (self-employed only), which helps relative to the other ideas. Policy salience is decent given ongoing debates about entrepreneurship, liability protection, and tax treatment.
- **Concerns:** Identification is still weak: incorporation is a choice tightly linked to unobserved business scale, growth intentions, access to capital, risk tolerance, accounting sophistication, and selection into higher-return opportunities—none of which ACS measures well. DR/DML improves functional-form robustness, not causal credibility if unobservables are first-order.
- **Novelty Assessment:** Moderately studied. There is a substantial literature on incorporated vs unincorporated self-employment earnings and selection (often using CPS/SIPP/IRS-linked or administrative data), though fewer papers use ACS specifically; the *question* itself is not new.
- **Recommendation:** **CONSIDER** (worth doing if framed as high-quality descriptive + sensitivity/bounds, or if you can add quasi-experimental leverage beyond selection-on-observables).

---

**#2: The Remote Work Wage Premium — A Doubly Robust Analysis (Idea 1)**
- **Score: 54/100**
- **Strengths:** Very high policy relevance and strong feasibility (big ACS sample, rich occupation/industry controls, accessible data). The proposed heterogeneity and sensitivity analyses are sensible and would add value for readers who want transparency about confounding.
- **Concerns:** Novelty is limited and identification is the main weakness. Remote work and wages are jointly determined by unobserved worker ability, firm pay policies, job level, and amenities-compensating differentials; even with 500+ occupation codes and industry controls, selection on unobservables is likely large. Additionally, ACS “worked from home” is essentially a commuting-mode/last-week measure (and can misclassify hybrid work), while wage income is annual—creating timing/mismeasurement concerns.
- **Novelty Assessment:** Heavily studied post-2020. There are many papers estimating remote-work wage differentials/premia using alternative data (job postings, employer-employee panels, longitudinal surveys) and/or stronger designs; the “DR/DML on ACS cross-section” angle is methodologically incremental rather than substantively novel.
- **Recommendation:** **CONSIDER** (good as a careful descriptive/sensitivity piece, but hard to sell as “causal” without stronger design elements).

---

**#3: Employer-Sponsored Health Insurance and Labor Supply (Idea 2)**
- **Score: 32/100**
- **Strengths:** The policy question (job lock and labor supply incentives from ESI) is important and perennial. ACS contains the key variables (ESI indicator and usual hours), making a descriptive analysis feasible.
- **Concerns:** Identification is extremely weak with ACS cross-sectional adjustment: hours worked is a determinant of ESI eligibility (mechanical reverse causality via full-time status and employer offering), and ESI is deeply endogenous to job quality and worker productivity. “Health status proxies” in ACS are limited, and conditioning on income/hours-related variables risks bad-control problems (controlling for post-treatment or jointly determined variables).
- **Novelty Assessment:** Very heavily studied. The ESI/job-lock/labor-supply literature is large (often leveraging ACA/Medicaid expansions, COBRA, spousal coverage, firm-size thresholds, or panel data); a selection-on-observables DR design on ACS is unlikely to be viewed as new.
- **Recommendation:** **SKIP** (unless the design is rethought around a plausibly exogenous policy variation that ACS can support).

---

### Summary

This batch is feasible in terms of data access, but all three proposals lean on selection-on-observables in a setting where unobserved heterogeneity is likely decisive; DR/DML cannot substitute for exogenous variation. If pursuing one, **Idea 3** is the most promising on novelty/tractability within ACS, while **Idea 1** is the most policy-relevant but least likely to clear a “causal” bar; **Idea 2** is weakest because of near-mechanical endogeneity between hours and ESI.