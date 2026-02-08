# Research Idea Ranking

**Generated:** 2026-01-19T23:25:16.718415
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 3372
**OpenAI Response ID:** resp_01c78319192335ea00696eaf14dacc8190bcb8e354d96fe4e2

---

### Rankings

**#1: Heat Illness Prevention Standards and Outdoor Worker Safety**
- **Score:** 78/100  
- **Strengths:** Highly policy-relevant given OSHA’s 2024 federal heat rulemaking and accelerating climate risks, and there is genuinely limited economics-style causal evidence on state heat standards. Outcomes (injuries/illnesses) are directly targeted by the policy, and the design can be strengthened using heat-exposure intensity (weather) and industry exposure.  
- **Concerns:** SOII is well-known to suffer from underreporting and cross-state reporting differences; if standards also change reporting/recordkeeping, estimates may partly reflect reporting responses rather than true safety. Adoption timing is likely endogenous to heat events/politics, and the treated set is small with a long gap between CA (2005) and the recent wave—requiring careful modern staggered DiD/event-study methods and robustness to differential climate trends.  
- **Novelty Assessment:** **High** in economics/policy evaluation terms (especially using DiD with administrative injury data), though there is related public health/occupational safety work and some descriptive evidence; not “zero-literature,” but still under-studied with credible causal designs.  
- **Recommendation:** **PURSUE** (best in the batch; just be very deliberate about measurement/reporting and weather-driven confounding)

---

**#2: CROWN Act and Black Employment Outcomes**
- **Score:** 67/100  
- **Strengths:** Clear policy variation (many adoptions post-2019) and a natural triple-difference structure (Black vs non-Black; treated vs untreated; pre vs post) that helps with identification relative to a plain state-time DiD. Strong societal/policy interest and plausible mechanisms in hiring/occupational sorting.  
- **Concerns:** Effects on employment/wages may be small relative to CPS noise at the state-year-race level, risking low power and fragile results (especially for wages). Adoption correlates with broader civil-rights and labor-market policy bundles (and with changing social norms), so even triple-diff may not fully address differential trends; consider complementing with EEOC charge data or audit-study style outcomes if available.  
- **Novelty Assessment:** **High**—this is not a heavily mined policy lever in the labor econ causal literature, even though discrimination law effects broadly are widely studied.  
- **Recommendation:** **CONSIDER** (promising, but power/measurement and confounding-by-progressive-policy-bundles are real risks)

---

**#3: State Auto-IRA Mandates and Retirement Savings**
- **Score:** 61/100  
- **Strengths:** Very policy-relevant (retirement coverage gaps) with multiple adopting states and potential for meaningful effect sizes (participation, contributions, employer plan offerings). There is a plausible DiD/event-study setup and likely scope for heterogeneity by firm size/industry/earnings.  
- **Concerns:** This area is **already being studied** (especially early adopters like OregonSaves/CalSavers), so the novelty margin is smaller unless you bring new data (administrative program data, linked earnings, firm outcomes) or a sharply distinct question. CPS/ACS measures of “pension coverage” and “retirement income” are imperfect for detecting auto-IRA effects (timing, misclassification, and limited ability to isolate eligible workers), and phased rollouts by employer size complicate treatment definition and parallel trends.  
- **Novelty Assessment:** **Medium**—there is an emerging but nontrivial literature; incremental contributions are feasible but need a distinctive angle/data advantage.  
- **Recommendation:** **CONSIDER** (worth doing only if you can secure administrative/implementation detail that materially improves measurement and identification)

---

**#4: Captive Audience Meeting Bans and Union Organizing**
- **Score:** 54/100  
- **Strengths:** Extremely timely and politically salient, and NLRB election microdata are rich (petitions, win rates, units) with outcomes closely aligned to the policy’s intent. Novel policy lever with little rigorous evaluation to date.  
- **Concerns:** Identification is the weakest: most adoptions are 2023–2024, leaving very limited pre-trends and making event studies uninformative; only a handful of treated states, and adoption is highly endogenous to pro-labor climates and other concurrent labor-law changes. There is also legal/institutional uncertainty (enforcement/preemption challenges) that may attenuate “treatment,” creating ambiguity about what actually changes on the ground.  
- **Novelty Assessment:** **Very high**, but the main constraint is not novelty—it’s credible causal identification given timing, bundling, and small-N treatment.  
- **Recommendation:** **SKIP for now / CONSIDER later** (revisit once more post-period accumulates or if you can credibly exploit a sharper discontinuity such as court injunction timing)

---

### Summary
The strongest proposal is **Heat Illness Prevention Standards**: it combines high policy relevance with relatively credible pathways to identification if you explicitly address weather trends and SOII reporting/measurement concerns. **CROWN Act** is the most novel labor-market idea but may struggle with statistical power and confounding; **Auto-IRA** is feasible and relevant but less novel unless paired with superior administrative/eligibility measurement; **Captive audience bans** are intriguing but currently underpowered and hard to identify cleanly given very recent adoption and policy bundling.