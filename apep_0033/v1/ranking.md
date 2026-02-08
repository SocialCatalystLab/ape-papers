# Research Idea Ranking

**Generated:** 2026-01-19T02:11:40.722638
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4133
**OpenAI Response ID:** resp_04fee869b5ca693100696d84a4c5e88194a04518c1aec86f12

---

### Rankings

**#1: Financial Literacy Graduation Requirements and Long-Run Labor Market Outcomes**
- **Score:** 69/100  
- **Strengths:** Big policy variation over a long window and outcomes are well-measured in ACS/CPS, so you can credibly estimate cohort-level effects with decent precision. Labor-market impacts of mandated financial literacy are plausibly less saturated than credit/borrowing outcomes and would be policy-relevant for education departments.  
- **Concerns:** Treatment assignment is noisy if you use **state of birth** (migration and cross-state schooling will attenuate effects); “state of schooling at age 16–18” is what you really want and is hard in public microdata. Staggered adoption coincides with other state education reforms (testing, graduation requirements, CTE expansion), making parallel trends and confounding a real risk.  
- **Novelty Assessment:** **Moderate-high, not “high.”** There is a sizable financial-education literature (e.g., mandated courses and later credit/borrowing), but fewer clean papers on **earnings/employment** specifically; still, the general “financial education mandates” space is well-trodden.  
- **Recommendation:** **CONSIDER** (upgrade to **PURSUE** if you can improve exposure measurement—e.g., restricted data with state-of-schooling, or a design leveraging within-state cohort rollouts / implementation details).

---

**#2: Salary History Bans and Job Tenure / Occupational Mobility**
- **Score:** 63/100  
- **Strengths:** Clear policy timing (effective dates) and a meaningful mechanism: bans may change match quality, bargaining, and sorting—so mobility/tenure is a natural, policy-relevant extension beyond wage effects. Using modern staggered DiD estimators (Callaway–Sant’Anna / Sun–Abraham) is appropriate.  
- **Concerns:** The CPS Job Tenure Supplement is **biennial** and you effectively have only a few post periods for many states; power (especially for subgroup or occupation analyses) is a major constraint. Also, many places had **local ordinances** or related pay-transparency policies, so “treatment” may be anticipatory/contaminated and hard to code cleanly.  
- **Novelty Assessment:** **Moderate.** Wage effects of salary history bans are heavily studied; tenure/mobility outcomes are less common, but not completely untouched and may be hard to publish if effects are noisy.  
- **Recommendation:** **CONSIDER** (worth doing if you pre-register a tight set of outcomes and do a serious power/MDES calculation up front).

---

**#3: Non-Compete Agreement Restrictions and Self-Employment/Entrepreneurship**
- **Score:** 60/100  
- **Strengths:** Strong policy relevance (current federal/state attention) and ACS provides large samples for entrepreneurship proxies (self-employment, incorporated status) with long panels for event-study timing. Focusing on high–non-compete-prevalence occupations is a sensible way to sharpen first-stage exposure.  
- **Concerns:** Identification and measurement are the core problems: non-compete policy is **heterogeneous** (thresholds, carve-outs, enforceability standards), and “law on the books” may not map cleanly into enforcement or employer behavior. The topic is also vulnerable to omitted-variable bias because reforms often arrive alongside broader labor-market policy packages (e.g., wage theft enforcement, pay transparency, worker classification rules).  
- **Novelty Assessment:** **Moderate-low.** There is already a substantial literature linking non-compete enforceability to mobility, wages, innovation, and entrepreneurship/new firm activity; this would need a genuinely new angle (better coding, differential exposure, or a sharper quasi-experiment like MN 2023) to stand out.  
- **Recommendation:** **CONSIDER** (only **PURSUE** if you can (i) precisely code reforms and (ii) credibly isolate a sharp change—e.g., Minnesota’s 2023 ban with a clean event window, or occupation-level exposure validated with external non-compete prevalence data).

---

**#4: Extended Foster Care Eligibility and Youth Employment Outcomes**
- **Score:** 34/100  
- **Strengths:** High intrinsic policy importance (very high-stakes population) and staggered adoption could, in principle, support credible DiD if the treated population were observable.  
- **Concerns:** In ACS/CPS public-use data you **cannot identify foster youth**, making the analysis mostly an intent-to-treat on the general 19–24 population—effects will be mechanically tiny and easily swamped by noise and confounding. Without a clear first stage (more youth actually staying in care) and a way to observe outcomes for the affected group, identification and feasibility are both weak.  
- **Novelty Assessment:** **Moderate.** There is prior work using administrative/linked data on extended foster care and later outcomes; the novelty here is mainly the dataset choice, which is the problem.  
- **Recommendation:** **SKIP** (unless you can obtain administrative foster care records linked to UI wage data or another dataset that directly observes foster status).

---

### Summary
This is a decent batch: three ideas are plausible DiD studies, but only **Idea 1** has a strong enough novelty–feasibility combination to be a lead project, and even it hinges on improving treatment assignment beyond state-of-birth. I would start with **Idea 1**, then keep **Idea 2** as a secondary project conditional on a convincing power/design check; **Idea 3** needs a sharper reform/coding strategy to clear the novelty bar.