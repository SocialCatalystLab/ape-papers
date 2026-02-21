# Research Idea Ranking

**Generated:** 2026-02-21T13:06:41.012700
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 5150

---

### Rankings

**#1: Does Female Political Representation Cause Female Economic Empowerment? Evidence from French Municipal Gender Parity**
- Score: **80/100**
- Strengths: Very strong design with a plausibly sharp institutional threshold and an unusually large number of units near the cutoff (French communes). Outcomes are directly policy-relevant and measured in high-quality administrative/statistical sources, and the “first stage” (female councilor share) is easy to verify.
- Concerns: Need to rule out any manipulation/sorting around the **1,000 legal-population** threshold (or institutional quirks in how “population légale” is updated) and ensure outcomes are measured after meaningful exposure (post-2014 election). Commune-level labor market outcomes may respond slowly and could be noisy, requiring careful choice of timing and bandwidth.
- Novelty Assessment: **High-moderate.** The parity thresholds have been studied heavily for *political selection* and representation, but downstream *economic* effects in a developed-country setting are much less studied; this is a credible “new margin” on a known reform.
- Recommendation: **PURSUE (conditional on: (i) strong manipulation/bunching tests around 1,000; (ii) clear exposure timing—e.g., outcomes in 2015–2019 rather than 2014; (iii) consider a “difference-in-discontinuities” using the earlier 3,500 threshold period to strengthen credibility).**

---

**#2: The Price of Exclusion: Welfare Eligibility at Age 25 and Youth Self-Employment in France**
- Score: **70/100**
- Strengths: Age-based eligibility is conceptually a clean running variable, and the mechanism (liquidity/insurance affecting occupational choice and necessity self-employment) is compelling and policy-relevant. The outcome (self-employment / micro-enterprise entry) is a genuinely interesting angle relative to the existing RSA-at-25 labor supply literature.
- Concerns: The feasibility hinges on **having age measured finely enough (ideally month-of-birth / age-in-months)**—if the LFS only provides age-in-years, the RDD becomes weak/invalid due to discretization and heaping. Also must audit other discontinuous changes at 25 (benefits, student status/household definitions, eligibility rules) that could contaminate interpretation.
- Novelty Assessment: **Moderate.** There is prior work on the RSA age threshold and employment outcomes; focusing on self-employment/micro-entrepreneurship is plausibly novel, but not completely “virgin territory.”
- Recommendation: **CONSIDER (upgrade to PURSUE if you confirm: (i) month-level age; (ii) no other major age-25 discontinuities in the same outcomes; (iii) sufficient sample size near 25 for self-employment outcomes, which are relatively low-frequency).**

---

**#3: Urban Enterprise Zones and Local Employment: Spatial RDD Evidence from France's ZFU Program**
- Score: **63/100**
- Strengths: Spatial RDD at zone boundaries can be a meaningful identification upgrade over standard DiD comparisons if boundaries generate quasi-random local contrasts. Data feasibility is plausible with publicly available shapefiles and INSEE small-area statistics; policy relevance is high given recurring place-based policy debates.
- Concerns: Spatial RDD validity is fragile here: boundaries may coincide with sharp pre-existing discontinuities (major roads, industrial vs residential breaks) and **spillovers/sorting** (firms relocating just inside the boundary) are likely first-order. IRIS units not aligning with ZFU boundaries is a serious measurement problem unless you can construct boundary buffers and re-aggregate outcomes cleanly.
- Novelty Assessment: **Moderate-low.** ZFU itself is well studied, and spatial/border RDDs for enterprise zones are common internationally; the novelty is more “method applied to France’s ZFU” than a fundamentally new question.
- Recommendation: **CONSIDER (conditional on: (i) showing excellent covariate balance/smoothness at boundaries pre-treatment; (ii) using point-level establishment data or fine grids rather than IRIS averages if possible; (iii) an explicit spillover strategy—e.g., donut/buffer exclusions, or estimating displacement separately).**

---

**#4: Mandatory Safety Committees and Workplace Injuries: RDD Evidence from France's 50-Employee Threshold**
- Score: **45/100**
- Strengths: High policy importance (worker safety) and a clear institutional threshold; if the right administrative data were obtainable, the question is valuable and the outcome is directly aligned with the policy’s intent.
- Concerns: The **identification risk is severe** because the 50-employee threshold is known to induce **strategic size manipulation/bunching**, breaking the continuity assumptions of standard RDD; treated firms (50+) are selected and systematically different. Data feasibility is also a major concern—firm-level injury/accident measures are often restricted, and compliance with CHSCT obligations may be imperfect (making it fuzzy on top of manipulation).
- Novelty Assessment: **Moderate.** The 50-employee threshold is extremely well studied; “injuries” is a less-studied outcome, but not enough to offset the identification and data access risks.
- Recommendation: **SKIP (unless you can secure high-quality restricted administrative data + a compelling design to address manipulation, e.g., an IV/fuzzy design using predicted size from lagged payroll, or a policy change affecting enforcement rather than the threshold itself).**

---

### Summary

Overall, this is a strong batch: two ideas (municipal parity RDD; RSA-at-25 age RDD) have credible quasi-experimental structure and plausible public data paths. The ZFU spatial RDD could work but is inherently more fragile due to boundary/sorting/spillovers and spatial measurement issues. The CHSCT-at-50 idea is policy-important but is the least promising because the running variable is demonstrably manipulated and the key outcome data are likely restricted—without a redesigned identification strategy, it is unlikely to survive scrutiny.