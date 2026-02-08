# Research Idea Ranking

**Generated:** 2026-01-21T17:07:35.603905
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5657
**OpenAI Response ID:** resp_0fcca6c308bc218d006970f98ee3ec8195b15973d1704134b1

---

### Rankings

**#1: Clean Slate Laws and Employment Outcomes**
- **Score: 74/100**
- **Strengths:** Genuinely new policy area with real stakes; staggered adoption and many never-treated states make a modern staggered DiD (e.g., Callaway–Sant’Anna) plausible. Strong pre-period length and clear policy timing (if using effective/implementation dates) help.
- **Concerns:** State-level labor market aggregates are likely too blunt: only a small share of the population is directly “treated,” so effects may be diluted toward zero. Also, only ~12 treated clusters raises inference fragility, and “clean slate” often comes alongside broader criminal-justice reforms that may move employment too.
- **Novelty Assessment:** **High.** There is extensive “Ban-the-Box” work, but automatic expungement/clean-slate evaluation is still thin in economics; most existing work is descriptive, legal, or based on early rollouts.
- **DiD Assessment:**
  - Pre-treatment periods: **Strong**
  - Selection into treatment: **Marginal**
  - Comparison group: **Strong**
  - Treatment clusters: **Marginal**
  - Concurrent policies: **Marginal**
- **Recommendation:** **PURSUE** (but strongly consider more targeted outcomes/subgroups and/or admin data on expungements to increase signal)

---

**#2: Automatic Voter Registration and Civic Participation**
- **Score: 62/100**
- **Strengths:** Large number of treated states (and staggered timing) with long pre-periods supports credible event-study diagnostics. Clear policy relevance, and turnout/composition effects are less fully settled than registration effects.
- **Concerns:** Political selection is substantial (early adopters are disproportionately Democratic), making counterfactual trends questionable; concurrent election-law changes (voter ID, mail voting, early voting) are frequent and hard to fully net out. CPS turnout is noisy/misreported, and state-year sample sizes can be thin for subgroup composition.
- **Novelty Assessment:** **Medium.** AVR has been studied (especially Oregon/California and registration impacts), but broader turnout and compositional impacts across many states remain less saturated.
- **DiD Assessment:**
  - Pre-treatment periods: **Strong**
  - Selection into treatment: **Marginal**
  - Comparison group: **Marginal**
  - Treatment clusters: **Strong**
  - Concurrent policies: **Marginal**
- **Recommendation:** **CONSIDER** (best if paired with strong controls for other election reforms and careful pre-trend/event-study evidence)

---

**#3: Nurse Practitioner Full Practice Authority and Healthcare Access**
- **Score: 48/100**
- **Strengths:** Highly policy-relevant, with good data availability (ACS/BRFSS) and a meaningful number of treated states in the 2011–2024 wave. There is a plausible mechanism via primary-care capacity.
- **Concerns:** **Major identification threat from ACA-era changes** (ACA rollout, Medicaid expansion timing, marketplace dynamics) that directly affect insurance and access outcomes; this is not a “small overlap”—it is first-order confounding. Also, NP scope-of-practice reforms are often bundled with other health workforce and insurance initiatives.
- **Novelty Assessment:** **Low-to-medium.** NP scope-of-practice is well studied in health economics (prices, utilization, provider supply, some access measures). The specific “uninsured rate” angle is less common, but the policy itself is not novel.
- **DiD Assessment:**
  - Pre-treatment periods: **Strong**
  - Selection into treatment: **Marginal**
  - Comparison group: **Strong**
  - Treatment clusters: **Strong**
  - Concurrent policies: **Weak** *(ACA/Medicaid expansion are direct, large confounds for insurance/access outcomes)*
- **Recommendation:** **SKIP as currently framed** (could become **CONSIDER** only with a redesign such as post-ACA-only adoption windows + explicit Medicaid-expansion interactions/triple-diff and tight policy controls)

---

**#4: State Data Privacy Laws and Tech Employment**
- **Score: 44/100**
- **Strengths:** Novel policy question with plausible economic mechanisms (compliance costs, data-driven product constraints) and decent administrative outcomes (QCEW, BDS). Enough treated states to do staggered designs.
- **Concerns:** Pandemic/remote-work restructuring and the 2022–2023 tech cycle are enormous sector-specific shocks that coincide with much of the adoption window; separating privacy-law effects from these shocks will be extremely difficult. Selection is also problematic: tech-intensive states are more likely to legislate privacy and have different underlying employment dynamics.
- **Novelty Assessment:** **High (for labor-market outcomes).** There is some work on CCPA-style laws and firm behavior/website tracking, but much less on employment and business formation.
- **DiD Assessment:**
  - Pre-treatment periods: **Marginal**
  - Selection into treatment: **Marginal**
  - Comparison group: **Marginal**
  - Treatment clusters: **Strong**
  - Concurrent policies: **Weak** *(COVID/remote work + tech boom/bust overlap directly with the outcome)*
- **Recommendation:** **SKIP** (unless the design can credibly isolate effects—e.g., much longer post-period, narrower pre-COVID window is impossible for early adopters like CA, or a very different identification strategy)

---

**#5: Pay Transparency Laws and Gender Wage Gap**
- **Score: 33/100**
- **Strengths:** Very policy-relevant and genuinely timely; if you could identify it cleanly, the contribution would be large. Microdata (ACS PUMS) can support rich heterogeneity by gender/industry/occupation.
- **Concerns:** The timing (2021+) makes **pre-trends and counterfactual validation weak**, with COVID-era labor market shocks contaminating both “pre” and “post” in ways tightly linked to wages, gender gaps, and remote work. Short post-treatment horizons and heterogeneous implementation/enforcement (including city-level laws like NYC) further muddy treatment definition.
- **Novelty Assessment:** **High.** There are some early descriptive/industry reports and a small emerging academic literature, but it’s not yet crowded.
- **DiD Assessment:**
  - Pre-treatment periods: **Weak**
  - Selection into treatment: **Marginal**
  - Comparison group: **Marginal**
  - Treatment clusters: **Marginal**
  - Concurrent policies: **Weak** *(COVID/inflation/remote-work shocks are first-order for wage structure and gender gaps)*
- **Recommendation:** **SKIP (for now)** / “wait 2–3+ years” before attempting a credible DiD

---

### Summary

This batch has one clearly fundable DiD today (**Clean Slate**) and one plausible “second tier” project (**AVR**) where identification hinges on convincing pre-trends and controlling for concurrent policy changes. The remaining three are dominated by **major coincident macro/policy shocks (ACA or COVID/tech cycle)** that are direct threats under DiD; they should be redesigned substantially or deferred until longer post-periods are available.