# Research Idea Ranking

**Generated:** 2026-01-22T13:21:59.312619
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 8117
**OpenAI Response ID:** resp_0ab6378128a702b40069721611cc7881938c4a9650f1691848

---

### Rankings

**#1: Salary Transparency Laws and Wage Outcomes**
- **Score: 72/100**
- **Strengths:** Clear, policy-relevant question with direct, well-measured outcomes (wages; gender wage gaps) in large public microdata. Staggered adoption across many states enables modern staggered DiD/event-study with heterogeneity by law design.
- **Concerns:** Treatment is not “statewide for all workers” (employer-size thresholds; enforcement varies), so estimates are ITT and may be attenuated. Potential contamination from concurrent pay-equity reforms and from multi-state employers adopting uniform posting practices (or avoiding posting in treated states), plus CPS measures **state of residence** rather than job location.
- **Novelty Assessment:** **Moderate.** Colorado has been studied and there’s broader literature on pay transparency, but a **comprehensive multi-state (2021–2025) U.S. DiD** with design heterogeneity is still relatively new.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (CPS/ACS allow long pre-periods; can use 2010–2020 for CO and 2010–2022 for 2023 adopters).
  - **Selection into treatment:** **Marginal** (progressive states; adoption may correlate with evolving labor-market/gender-equity trends).
  - **Comparison group:** **Marginal** (never-treated states are plentiful but systematically different; must show convincing pre-trends and consider regional reweighting/synthetic controls).
  - **Treatment clusters:** **Marginal** (≈13 treated by end-2025; acceptable, but not “large-N” for state-cluster inference).
  - **Concurrent policies:** **Marginal** (equal pay acts, pay data reporting, minimum wage trajectories; needs explicit controls/stacked designs and sensitivity checks).
  - **Outcome-Policy Alignment:** **Strong** (policy targets wage offers/information; wages and wage gaps are the core outcomes—though compliance/coverage issues imply attenuation).
- **Recommendation:** **PURSUE (conditional on: (i) using a long pre-period and demonstrating clean pre-trends; (ii) explicitly accounting for concurrent pay-equity policies; (iii) addressing residence-vs-work location and multi-state employer spillovers, e.g., robustness using ACS place-of-work where feasible or restricting to less-remote occupations).**

---

**#2: PBM Spread Pricing Bans and Pharmacy Reimbursement**
- **Score: 67/100**
- **Strengths:** Strong staggered policy variation with a large “wave” (2019) and **many treated states**, including cross-partisan adoption—good for identification. High policy salience (Medicaid spending, pharmacy viability, rural access).
- **Concerns:** The project hinges on **hard-to-access or messy outcome data** (closures, reimbursement, net prices) and the causal chain can be indirect if outcomes are not tightly tied to the Medicaid channel affected by the ban. Bundled PBM reforms (DIR fees, MAC lists, network rules) risk confounding.
- **Novelty Assessment:** **Moderate-to-high.** There are policy reports and some targeted studies (often single-state Medicaid reforms), but **credible multi-state DiD evidence on market structure (closures) and reimbursement** is still relatively sparse.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (many years pre-2019 available in principle).
  - **Selection into treatment:** **Strong** (adoption not purely partisan; less obviously driven by pre-trends in closures if shown).
  - **Comparison group:** **Strong** (~30 never-treated/late-treated states; feasible matching/reweighting).
  - **Treatment clusters:** **Strong** (≈20+ treated states).
  - **Concurrent policies:** **Marginal** (PBM reforms often packaged; must code co-reforms and run “policy bundle” robustness).
  - **Outcome-Policy Alignment:** **Marginal** as written (spread-pricing bans operate mainly through **Medicaid reimbursement/payment flows**; pharmacy closures are a downstream proxy and “drug prices” may be poorly aligned). Alignment becomes **Strong** if the main outcome is Medicaid reimbursement per claim / pharmacy margin using Medicaid claims or state Medicaid financial reports.
- **Recommendation:** **CONSIDER (conditional on: (i) securing a defensible, scalable closure measure—e.g., consistent administrative licensure panels or a validated NCPDP-based panel; (ii) prioritizing Medicaid-channel outcomes over generic “drug prices”; (iii) coding and controlling for other PBM reforms).**

---

**#3: Predictive Scheduling Laws and Worker Outcomes**
- **Score: 45/100**
- **Strengths:** Interesting, worker-protection policy with plausible first-order outcomes (hours volatility, earnings stability) and long pre-period for Oregon. Literature is not enormous, so a well-identified design would be valuable.
- **Concerns:** Identification is a dealbreaker in the proposed form: essentially **one statewide treated unit (Oregon)**, while most other adoptions are city-level and **not identifiable in public CPS**. Minimum wage and local labor standards move together, making confounding likely.
- **Novelty Assessment:** **Moderate.** There are existing evaluations of specific cities (Seattle/SF/NYC) and related scheduling interventions; a clean statewide estimate would add, but the design is fragile.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong**
  - **Selection into treatment:** **Marginal** (progressive jurisdictions; could be trend-responsive).
  - **Comparison group:** **Strong** (many states without statewide laws).
  - **Treatment clusters:** **Weak** (≈1 statewide treated cluster; inference and generalizability are fragile).
  - **Concurrent policies:** **Marginal** (minimum wage, paid leave, sectoral standards often coincide).
  - **Outcome-Policy Alignment:** **Strong** (scheduling laws directly target hours predictability/volatility).
- **Recommendation:** **SKIP** (unless redesigned around data that can credibly identify treated cities—e.g., restricted geocoded microdata, administrative payroll data, or a large employer/shift-scheduling dataset with city identifiers).

---

**#4: State AI Hiring Regulation and Employment Outcomes**
- **Score: 38/100**
- **Strengths:** Very timely and genuinely new policy area; policymakers care, and there is real uncertainty about unintended consequences. Potential for high impact if matched with the right outcomes/data.
- **Concerns:** As proposed, DiD is not credible: too few treated jurisdictions, very limited pre-periods for key laws, and the outcome (employment rates) is **far downstream** from the mechanism (hiring tool disclosure/audits), making nulls hard to interpret.
- **Novelty Assessment:** **High** (little to no causal econometric evidence yet).
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (most treatment starts 2023+; limited pre to test parallel trends).
  - **Selection into treatment:** **Marginal** (tech-heavy/progressive areas; likely correlated with labor-market trends).
  - **Comparison group:** **Strong** (many untreated states), though comparability is questionable.
  - **Treatment clusters:** **Weak** (handful of jurisdictions; clustered inference weak).
  - **Concurrent policies:** **Marginal** (overlapping AI/privacy/employment enforcement changes).
  - **Outcome-Policy Alignment:** **Weak** (employment rates are an indirect, noisy proxy; the law targets hiring processes and discrimination risk, not aggregate employment).
- **Recommendation:** **SKIP** (promising topic, but needs a different design/outcome—e.g., job-posting text changes, adoption of audited tools, applicant callback/audit data, or discrimination-claim microdata tied to jurisdiction and timing).

---

**#5: Drug Pricing Transparency Laws and Pharmaceutical Pricing**
- **Score: 30/100**
- **Strengths:** High policy relevance; many states; clear adoption dates; superficially attractive DiD setup.
- **Concerns:** Fundamental outcome/geography mismatch: most manufacturer pricing (e.g., WAC) is **national**, so state transparency laws may not generate state-differential price trajectories. Without a credible state-specific pricing/market outcome tightly linked to the law (or a mechanism showing why pricing would diverge by state), DiD variation is unlikely to identify the effect.
- **Novelty Assessment:** **Moderate.** There is prior policy analysis and some empirical work on transparency/sunshine-type laws; the bigger issue here is not novelty but identification.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong**
  - **Selection into treatment:** **Strong**
  - **Comparison group:** **Strong**
  - **Treatment clusters:** **Marginal** (≈15 treated states)
  - **Concurrent policies:** **Marginal** (national reforms and insurer/PBM changes confound time patterns)
  - **Outcome-Policy Alignment:** **Weak** (state law vs largely national price-setting; “treated vs untreated states” is not the right level for the main outcome).
- **Recommendation:** **SKIP** (unless reframed to an outcome that is genuinely state-specific and mechanically affected—e.g., insurer formulary behavior in state-regulated markets, manufacturer reporting/compliance measures, or state procurement/Medicaid supplemental rebate negotiations if data exist).

---

### Summary

This is an above-average batch in policy relevance, but only **Idea 1** and (conditionally) **Idea 3** clear the minimum bar for credible DiD with measurable outcomes. The rest fail on core DiD identification requirements—especially **too few treated clusters** (Idea 2, Idea 5) and **outcome–policy misalignment** (Idea 4, Idea 5). I would start with **Salary Transparency** immediately, while parallel-path scoping the **PBM spread pricing** idea by auditing whether a clean, multi-state pharmacy closure/reimbursement panel is actually obtainable.