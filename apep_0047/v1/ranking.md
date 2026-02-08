# Research Idea Ranking

**Generated:** 2026-01-21T20:28:40.276534
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 5774
**OpenAI Response ID:** resp_0d027d32513de230006971289ca9d48193a55ffc26823dc503

---

### Rankings

**#1: Idea 2 — “#MeToo Movement and Female Labor Market Outcomes (Triple-Difference)”**
- Score: **74/100**
- Strengths: Clever use of a national shock with cross-industry “exposure” (baseline harassment intensity) creates much richer variation than state policy timing and largely avoids the “few treated states” problem. QWI gives high-frequency hiring/employment outcomes with strong gender × industry granularity.
- Concerns: The key threat is **differential industry trends** around 2017–2019 (e.g., retail/food services vs professional services) that could correlate with both “harassment-prone” classification and female employment trajectories; triple-diff helps but doesn’t automatically fix this. You’ll need very transparent event studies, strong pre-trend diagnostics, and careful inference (e.g., clustering at industry and state or state×industry).
- Novelty Assessment: **Moderately high novelty.** There is a growing literature on #MeToo and workplace behavior/labor markets, but the specific **industry-exposure triple-diff using EEOC-based baseline harassment** and QWI outcomes still feels relatively under-explored compared with standard post-2017 narrative analyses.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (15 quarters is ample for pre-trends)
  - Selection into treatment: **Strong** (timing of #MeToo is plausibly exogenous to any single industry’s employment trend)
  - Comparison group: **Marginal** (low-harassment industries differ structurally; must show parallel pre-trends in *female-minus-male* outcomes across high vs low exposure)
  - Treatment clusters: **Strong** (many state×industry cells; but effective variation is limited by number of industries—plan inference accordingly)
  - Concurrent policies: **Marginal** (macro boom, tax reform, minimum wage changes, etc.; triple-diff absorbs a lot, but not all, if shocks hit “high-harassment” industries differently)
  - Outcome-Policy Alignment: **Strong** (QWI employment/hiring by gender × industry is directly aligned with the hypothesized “avoidance/backlash” channels affecting hiring, retention, and advancement)
- Recommendation: **PURSUE (conditional on: (i) event-study pre-trends that are clean in high- vs low-harassment industries for female-minus-male outcomes; (ii) robustness to alternative harassment-intensity measures/classifications; (iii) inference plan with appropriate clustering and sensitivity to industry-level shocks).**

---

**#2: Idea 1 — “Sexual Harassment Training Mandates and Female Labor Market Outcomes”**
- Score: **52/100**
- Strengths: Tight policy variation (state mandates with clear effective dates) and strong administrative outcomes (QWI hiring/employment by gender) make the question concrete and policy-relevant. The “backlash/avoidance” mechanism is plausible and testable in the near term.
- Concerns: **Small number of treated states (≈6)** in the proposed window is a major inference problem; with staggered adoption, modern DiD estimators still won’t save you from fragile cluster-robust inference with so few treated clusters. Also, treated states are politically/culturally distinct (blue, high-cost, policy-active), raising selection and concurrent-policy worries.
- Novelty Assessment: **High-ish novelty.** There is extensive work on harassment training effectiveness and on #MeToo broadly, but **state training mandate impacts on labor-market gender outcomes** is not an overcrowded empirical niche.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (multi-year quarterly pre-period feasible)
  - Selection into treatment: **Marginal** (early adoption likely correlated with social/political trends that may also affect female labor outcomes)
  - Comparison group: **Marginal** (44 “never-treated” states are not necessarily comparable; composition-weighting and region-specific trends may be necessary)
  - Treatment clusters: **Weak** (≈6 treated states is a potential dealbreaker for credible inference)
  - Concurrent policies: **Marginal** (likely co-moves with other gender-equity/worker-protection policies; hard to fully net out)
  - Outcome-Policy Alignment: **Strong** (QWI gender hiring/employment maps well to hypothesized hiring/avoidance channels)
- Recommendation: **CONSIDER (conditional on: extending the panel to include additional adopting states post-2020 to raise treated clusters; pre-registering an inference strategy robust to few clusters—e.g., randomization inference / wild cluster bootstrap; and demonstrating treated vs control comparability via strong pre-trends and weighting).**  
  *Absent more treated states, I would not fund this as the flagship design.*

---

**#3: Idea 4 — “State Pay Transparency Laws and the Gender Wage Gap”**
- Score: **46/100**
- Strengths: Highly policy-relevant with active legislative interest; wage posting requirements are salient and potentially consequential. There are plausible short-run margins (job-to-job moves, offers) even if “wage gap” is slow-moving.
- Concerns: Treated cluster count is **very small (~5)** and early years often have limited post-treatment horizon; effects may be partially about compliance/coverage rather than pay-setting. Outcome measurement is hard: CPS/ACS wage data are noisy at the state level, and compositional shifts can masquerade as wage-gap changes.
- Novelty Assessment: **Medium to low novelty.** Pay transparency has a rapidly expanding literature (especially around Colorado and job posting behavior), and “wage gap effects” is a common endpoint—this risks being incremental unless you have unusually good data (e.g., administrative earnings) or a compelling new design.
- DiD Assessment:
  - Pre-treatment periods: **Marginal** (depends on exact adoption years; many laws are 2021–2023, limiting long pre-trends unless you extend back far and harmonize definitions)
  - Selection into treatment: **Marginal** (policy adoption likely correlated with pre-existing gender-equality trajectories)
  - Comparison group: **Marginal** (never-treated states differ substantially; may require careful matching/weighting)
  - Treatment clusters: **Weak** (≈5 treated states—fragile inference)
  - Concurrent policies: **Marginal** (often bundled with broader employment-law changes)
  - Outcome-Policy Alignment: **Marginal** (policy targets *offers/posting transparency*; aggregate wage gaps can move slowly and are confounded by selection/composition)
- Recommendation: **SKIP (unless you can secure administrative earnings/posted-wage microdata and expand treated clusters/time).**

---

**#4: Idea 3 — “NDA Limitation Laws and Sexual Harassment Reporting”**
- Score: **40/100**
- Strengths: Clear, important mechanism: limiting NDAs could change reporting and deterrence; EEOC charges are closer to the concept than many survey proxies. If credible, results would matter for ongoing state reforms.
- Concerns: The design is undermined by **very few treated states (~5)** and **heavy policy bundling** in the #MeToo era (training mandates, statute-of-limitations changes, enforcement changes). Also, the policy’s direct margin is *settlement secrecy*—it is not obvious it should cleanly map into *EEOC filings*, which occur earlier in the process (reporting may change through awareness campaigns rather than NDA law per se).
- Novelty Assessment: **Moderate novelty.** NDA reforms are newer and less studied than pay transparency, but the small-N policy rollout makes this hard to do well right now.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (long EEOC time series)
  - Selection into treatment: **Marginal** (politically selected, correlated with activism and enforcement intensity)
  - Comparison group: **Marginal** (never-treated states may differ in reporting culture and enforcement)
  - Treatment clusters: **Weak** (<10 treated states)
  - Concurrent policies: **Weak** (high likelihood of coincident harassment-related reforms and awareness shocks)
  - Outcome-Policy Alignment: **Marginal** (EEOC filings are related, but NDA limits primarily affect confidentiality of settlements; link to filings is indirect and may be dominated by contemporaneous awareness/enforcement)
- Recommendation: **SKIP** (too few treated clusters + bundled reforms; mechanism-outcome link needs a sharper empirical hook).

---

**#5: Idea 5 — “#MeToo and Women’s Occupational Sorting”**
- Score: **28/100**
- Strengths: Big-picture question with genuine social importance; could connect culture shocks to labor market structure.
- Concerns: Occupational sorting is **slow-moving** and heavily confounded by contemporaneous macro trends, cohort effects, and changing industry demand; pinning causal impact on #MeToo with credible counterfactuals is extremely difficult. Identification would likely be selection-on-trends with weak leverage.
- Novelty Assessment: **Medium novelty but crowded adjacency.** Many papers study gender segregation/occupational sorting and many papers study #MeToo; combining them is intuitive but not automatically novel unless paired with a truly sharp design.
- DiD Assessment:
  - Pre-treatment periods: **Strong** (in principle)
  - Selection into treatment: **Weak** (the “treatment” is a diffuse social movement; exposure is hard to define cleanly)
  - Comparison group: **Weak** (no obvious credible control group for a pervasive national movement)
  - Treatment clusters: **Weak** (effective treated units unclear)
  - Concurrent policies: **Weak** (many overlapping changes 2017–2020)
  - Outcome-Policy Alignment: **Marginal** (sorting could respond, but slowly and through many channels unrelated to harassment policy)
- Recommendation: **SKIP**

---

### Summary

This is a mixed batch: the only design that looks genuinely close to fundable on identification is **Idea 2 (triple-diff)**, provided it clears stringent pre-trend and “industry-cycle” robustness tests. The state-policy DiDs (Ideas 1, 3, 4) are mostly dragged down by **too few treated clusters** and policy bundling; without expanding the treated sample/time window or obtaining stronger microdata, they are not reliable enough for a policy institute’s flagship causal evidence.