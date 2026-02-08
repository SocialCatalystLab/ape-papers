# Research Idea Ranking

**Generated:** 2026-01-20T16:29:40.466660
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 2465
**OpenAI Response ID:** resp_0ac407bc4514630500696f9f4afb1881968df5f3c279f1ec4e

---

### Rankings

**#1: State Paid Family Leave and Maternal Employment**
- **Score: 72/100**
- **Strengths:** Clear policy start dates and a tightly defined treated population (mothers with very recent births) make the estimand interpretable and help identification. ACS provides large samples and the staggered rollout supports modern DiD/event-study designs with treatment-effect heterogeneity.
- **Concerns:** This is still vulnerable to policy endogeneity (states adopting PFL may already be on different female labor-supply trends) and to concurrent policy changes (childcare, minimum wage, EITC expansions). Effects on “employment in the last week” may miss intensive-margin responses (hours, attachment) unless carefully defined.
- **Novelty Assessment:** **Moderately studied.** California has a deep literature, and there are now multiple multi-state PFL papers; the “modern DiD + longer panel + employment focus” is incremental rather than truly new, but can still be publishable if executed cleanly (e.g., strong event-study diagnostics, heterogeneity by parity/earnings/industry).
- **Recommendation:** **PURSUE**

---

**#2: Recreational Cannabis Legalization and Employment**
- **Score: 60/100**
- **Strengths:** Policymakers care about labor-market consequences of legalization, and using *retail sales* timing is a sensible improvement over ballot/adoption dates. ACS can support broad employment/wage outcomes with good power.
- **Concerns:** Identification is comparatively weak: legalization and retail rollout are highly correlated with other contemporaneous changes (criminal justice practices, local economic trends, migration, industry booms) and treatment timing is often “fuzzy” (local opt-outs, delayed store openings, partial rollouts). State-level ACS outcomes may dilute effects that operate through specific subgroups (young men, low-skill workers, certain industries), making null results hard to interpret.
- **Novelty Assessment:** **Somewhat studied.** There is an enormous cannabis-policy literature; employment effects are less saturated than crime/health but not untouched, and many papers already exploit staggered timing across states.
- **Recommendation:** **CONSIDER** (better if redesigned around sharper margins—e.g., border-county designs, local retail entry, or subgroup-focused outcomes)

---

**#3: Right-to-Work Laws and Union Membership**
- **Score: 42/100**
- **Strengths:** The 2012–2017 wave is policy-relevant and could enable cleaner comparisons than older adoptions if pre-trends look good. Industry heterogeneity is a coherent angle (high vs. low union-density sectors).
- **Concerns:** Two major feasibility/credibility problems: (i) **ACS does not have a reliable union membership measure**—union status is typically measured in CPS (especially CPS-ORG), so the stated data plan is off; and (ii) RTW adoption is extremely politically selected and often bundled with other labor-policy changes, making parallel trends implausible without a stronger design (e.g., bordering-county designs, synthetic controls, or rich policy controls). Also, RTW’s labor-market effects are a very mature literature.
- **Novelty Assessment:** **Heavily studied.** RTW and unions/wages/employment is one of the most worked-over U.S. labor policy topics; focusing on the recent wave is only a modest novelty bump.
- **Recommendation:** **SKIP** (unless you pivot to a sharper design and correct data source—CPS-ORG—with a genuinely new angle)

---

### Summary

This batch has one clearly fundable direction (paid family leave) and two that are substantially more fragile on identification and/or novelty. I’d prioritize the PFL project, ideally strengthening it with a triple-difference (e.g., mothers of infants vs. mothers of older children vs. childless women) and tight event-study diagnostics; cannabis is a plausible secondary project if reframed around sharper treatment intensity or local variation. RTW, as currently formulated, has both a data problem and a low-novelty/high-endogeneity problem and should be deprioritized.