# Research Idea Ranking

**Generated:** 2026-01-27T14:24:34.259016
**Model:** gpt-5.2 (reasoning: high)
**Tokens:** 4245
**OpenAI Response ID:** resp_02d5c3f47d5fa1cf006978bc67b1f88195a3e29557095abca0

---

### Rankings

**#1: Cantonal Energy Laws and Federal Referendum Voting**
- **Score: 76/100**
- **Strengths:** Very strong outcome data (universe of municipalities, one-day measurement, no recall/measurement error) and a compelling, policy-relevant mechanism (policy feedback/“priming” from lived experience with cantonal energy rules). Multiple plausible border segments allow a credible spatial RDD design with border-pair-by-border-pair estimation.
- **Concerns:** The biggest threat is **border discontinuities in latent environmental preferences** (cantons that adopted earlier may simply be “greener”), which could also jump at borders for historical/political reasons—this is the core RDD identifying assumption risk. Also, long exposure (2010–2016) raises (small but nonzero) concerns about selective migration/sorting and endogenous local implementation intensity.
- **Novelty Assessment:** **High.** Policy-feedback effects are studied broadly, but **Swiss cantonal energy-law exposure → municipal voting on a federal energy referendum using spatial RDD** feels comparatively underexplored and unusually well-matched to Swiss institutions/data.
- **Recommendation:** **PURSUE (conditional on: (i) show no pre-existing border discontinuity using placebo outcomes—earlier environmental referenda and party vote shares; (ii) estimate separately by each border pair and report a pooled estimate only if effects are coherent; (iii) implement standard spatial-RDD diagnostics: donut RDD around borders, bandwidth sensitivity, covariate balance, and border-segment fixed effects).**

---

**#2: Cantonal Energy Laws and Solar Panel Adoption**
- **Score: 60/100**
- **Strengths:** The question is policy-relevant (decarbonization adoption) and the spatial-RDD idea is conceptually appropriate because municipal PV uptake should respond to canton-level rules/incentives. If the PV data can be made reliable and granular, this can become a publishable applied policy evaluation.
- **Concerns:** **Data feasibility and construct validity are the key risks.** If the BFE dataset is cross-sectional or model-based (not actual installations) or lacks consistent timing, interpretation becomes difficult. Identification is also threatened by **canton-specific PV subsidies, permitting rules, grid constraints, and solar potential differences** that may change discretely at borders (administration and incentives often do), making it hard to attribute discontinuities specifically to the “comprehensive energy law reform” rather than other canton policies bundled with it.
- **Novelty Assessment:** **Medium.** There is a large literature on PV adoption responses to incentives/regulation; “Swiss cantonal energy laws via border RDD” is less common, but PV-policy evaluation per se is not novel.
- **Recommendation:** **CONSIDER (conditional on: (i) obtaining an installations registry with dates—e.g., Pronovo/guarantees-of-origin or interconnection/permit records—so you can verify exposure windows; (ii) documenting and controlling for other canton PV incentives and administrative barriers; (iii) restricting to border areas with similar irradiance/topography and doing strong robustness/border-pair stratification).**

---

**#3: Building Terms Harmonization (IVHB) and Construction Activity**
- **Score: 38/100**
- **Strengths:** Housing supply/regulatory frictions are highly policy-relevant, and a harmonization agreement is a plausibly exogenous institutional change in principle.
- **Concerns:** This idea looks fragile on both **identification power and data**: only **4 adopting cantons** implies few usable border segments and very limited external validity/power, and the proposed outcomes (permit processing time, applications) are often **not available at the municipality level** or are inconsistently recorded across cantons. Even if data exist, IVHB’s content (definitions/terms) may be too indirect to generate detectable discontinuities in construction activity relative to larger canton-level planning/zoning institutions that also differ at borders.
- **Novelty Assessment:** **Medium–low.** Regulatory harmonization and construction/housing outcomes are heavily studied; IVHB specifically is less studied internationally, but the causal question is close to an existing “regulatory barriers and housing supply” canon.
- **Recommendation:** **SKIP (unless you can verify municipal-level permit microdata with consistent timestamps and demonstrate that IVHB produced sharp, binding changes in allowable projects rather than mostly definitional harmonization).**

---

### Summary

This is a solid batch with one clearly standout proposal. **Idea 1** is the most promising because the outcome is exceptionally well-measured, the institutional context is well-suited to a border design, and the “policy feedback into federal voting” angle is comparatively novel—provided you convincingly rule out pre-existing border-level preference discontinuities using placebo referenda/party outcomes. **Idea 2** is viable but hinges on obtaining better PV adoption microdata and disentangling the energy law from other canton PV incentives; **Idea 3** is currently too underpowered and data-risky to recommend.