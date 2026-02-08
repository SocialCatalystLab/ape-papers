# Research Idea Ranking

**Generated:** 2026-01-30T17:59:54.782808
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 6302
**OpenAI Response ID:** resp_0852eb990e48b1cd00697ce34f759481979d77114711fab9be

---

### Rankings

**#1: Self-Employment as Bridge Employment: Does the ACA Unlock Flexible Retirement Pathways?**
- **Score: 67/100**
- **Strengths:** Clear policy motivation (job lock → post-ACA decoupling of insurance from employment) and strong policy relevance for near-retirees. ACS has large samples and relevant measures (hours, class of worker, insurance source), making implementation feasible at scale.
- **Concerns:** **ACS is repeated cross-section**, so “bridge employment”/retirement *transitions* aren’t directly observed—only snapshots by age/year, which weakens the core mechanism claim. Identification is **still largely selection-on-unobservables** (who becomes self-employed) and a simple pre/post ACA comparison is confounded by the post-2010 recovery and other contemporaneous changes.
- **Novelty Assessment:** **Moderate.** There is a sizable ACA “job lock/entrepreneurship/self-employment” literature; the *older-worker/bridge-employment* framing is fresher, but not clearly “unexplored.”
- **DiD Assessment (if applicable):** **Not a DiD as written (primarily DR with pre/post comparisons).**  
  *If you reframe as a DiD/event-study using Medicaid expansion timing and/or a 65+ Medicare placebo group, then the DiD checklist becomes relevant and could materially strengthen the project.*
- **Recommendation:** **PURSUE (conditional on: (i) sharpening design around quasi-experimental variation—e.g., Medicaid expansion/exchange intensity + event study; (ii) adding a credible control/placebo such as 65+ (Medicare) or groups unlikely affected by ACA; (iii) redefining outcomes to match “bridge” concept (e.g., part-time incidence, weeks worked, self-employment entry proxies) given lack of panel transitions in ACS).**

---

**#2: Disability, Self-Employment, and the Accommodation Hypothesis**
- **Score: 62/100**
- **Strengths:** Interesting and comparatively underdeveloped policy angle: self-employment as a de facto accommodation channel when wage employment accommodations are imperfect. Data are feasible in ACS (large N, DIS, hours, income), and the heterogeneity-by-disability framing is policy-relevant for workforce/entrepreneurship programming.
- **Concerns:** Identification is **weak-to-marginal** because both disability reporting and self-employment are endogenous and likely correlated with unobserved productivity, severity, and preferences; DR won’t solve this without a plausibly exogenous shifter. Also, ACS disability measures are coarse (type/severity limited), so “accommodation mechanism” is hard to validate.
- **Novelty Assessment:** **Moderately high.** There is work on disability and employment/SSDI and some on disability entrepreneurship, but this specific “self-employment as accommodation substitute” framing is less saturated than ACA–self-employment.
- **DiD Assessment (if applicable):** **Not a DiD as written.**
- **Recommendation:** **CONSIDER (upgrade to PURSUE if you can introduce quasi-exogenous variation—e.g., state vocational rehabilitation/entrepreneurship program rollouts, disability-related policy shocks, or tighter design around plausibly exogenous occupation-level accommodation feasibility).**

---

**#3: Occupational Skill Mismatch and Immigrant Earnings**
- **Score: 50/100**
- **Strengths:** Policy relevance is real given active state credential-recognition reforms and “brain waste” concerns; ACS can measure immigrant status, occupation, education, English proficiency, and earnings with adequate sample sizes.
- **Concerns:** As proposed, mismatch is **highly selected** (language, networks, discrimination, licensing barriers, motivation), and DR comparisons “within cells” are unlikely to be credible causally. Also, the mismatch–earnings penalty has a **large existing literature** (often with better data on credentials/occupation requirements), so novelty is limited unless you explicitly exploit reforms as exogenous shocks.
- **Novelty Assessment:** **Low-to-moderate.** Immigrant overeducation/mismatch and wage penalties are well studied; the *credential-recognition reform* hook could be novel **only if** it becomes the actual identification strategy.
- **DiD Assessment (if applicable):** **Not a DiD as written.**  
  *If pivoting to DiD around state credential-recognition reforms (2019–2024), you would need careful timing (effective dates), adequate pre-periods, and to address concurrent labor-market/pandemic-era confounding.*
- **Recommendation:** **CONSIDER (only if re-scoped to a policy-based design—e.g., event-study around credential recognition laws with tight timing and strong checks). Otherwise SKIP.**

---

**#4: Does Housing Cost Burden Increase or Decrease Labor Supply?**
- **Score: 38/100**
- **Strengths:** High policy salience (housing affordability, labor supply constraints) and ACS contains cost-burden measures (GRPIP/OCPIP) and labor outcomes with big samples.
- **Concerns:** The proposed “treatment” is **mechanically linked to the outcome** through income (and income depends on hours), creating severe reverse causality and ratio-induced bias; this is close to a built-in negative/positive correlation problem rather than a causal design. Location choice and housing consumption are deeply endogenous, so DR without an exogenous housing-cost shock is unlikely to be publishable.
- **Novelty Assessment:** **Low.** Housing costs and labor supply/location choice are classic topics; what’s new here is mainly the packaging, not the identification.
- **DiD Assessment (if applicable):** **Not a DiD as written.**
- **Recommendation:** **SKIP (unless redesigned around plausibly exogenous shocks—e.g., rent control expansions/repeals, zoning reforms with clear timing, disaster-driven housing supply shocks, or instruments based on predicted rent growth).**

---

### Summary

This batch has strong **policy relevance** and good **data access**, but most ideas are fundamentally constrained by **selection/endogeneity** that DR methods alone won’t resolve in cross-sectional ACS. The only idea that plausibly supports a defensible causal story with modest redesign is **Idea 1** (ACA as a policy shock), especially if reframed around credible quasi-experimental variation (e.g., Medicaid expansion/event-study + Medicare-age placebo). Ideas 3 and 4 are likely to underperform on novelty and/or identification unless they pivot to explicit policy-timing designs with strong checks.