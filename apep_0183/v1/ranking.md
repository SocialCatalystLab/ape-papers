# Research Idea Ranking

**Generated:** 2026-02-04T00:07:39.975614
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7866

---

### Rankings

**#1: The Green Rush at State Borders: Difference-in-Discontinuities for Marijuana Effects on Employment (Idea 2)**
- **Score: 69/100**
- **Strengths:** DiDisc is the right robustness upgrade over a pure border RDD: it allows persistent cross-border level gaps and focuses on *changes* in the discontinuity at retail opening. QWI has high-frequency outcomes and permits credible event-study style diagnostics at the border-pair level.
- **Concerns:** The proposal currently mentions only ~8 pre-treatment quarters—too short to convincingly establish stable pre-trends in the *border discontinuity*. Cross-border spillovers (shopping/commuting) and anticipatory effects (post-election, pre-retail) can mechanically attenuate effects.
- **Novelty Assessment:** **Moderate.** Marijuana legalization’s labor-market impacts have been studied, but **DiDisc using QWI at county×industry×quarter across multiple borders** is less saturated than state-level DiD and could add real incremental value, especially on industry heterogeneity.
- **DiD Assessment (DiDisc counts as DiD-family):**
  - **Pre-treatment periods:** **Weak** *(as written: 2 years; fixable by pulling 5–10+ years of pre QWI)*  
  - **Selection into treatment:** **Marginal** *(legalization is endogenous to preferences/trends; border design helps but doesn’t eliminate policy endogeneity)*  
  - **Comparison group:** **Marginal** *(border counties are better than whole-state controls, but CA–AZ/NV and OR–ID type borders can still differ sharply)*  
  - **Treatment clusters:** **Marginal** *(5 treated states → limited “treated border segments”; inference needs clustering at border-pair and enough pairs)*  
  - **Concurrent policies:** **Marginal** *(legalization often coincides with other state changes; border-pair×time FE mitigates but doesn’t guarantee)*  
  - **Outcome-Policy Alignment:** **Strong** *(employment/hiring/earnings directly reflect labor-market equilibrium outcomes that legalization could affect)*  
  - **Data-Outcome Timing:** **Marginal** *(QWI is quarterly; retail openings in Jul/Oct/Jan align reasonably, but “post” definitions must avoid partial/anticipation windows; election-to-retail gap must be handled)*  
  - **Outcome Dilution:** **Marginal** *(effects in broad 2-digit sectors may be small relative to total sector employment; better for outcomes like hiring and for retail/accommodation than for “manufacturing” overall)*  
- **Recommendation:** **PURSUE (conditional on: extending pre-period to ≥5 years; expanding treated states/borders to raise treated border clusters; explicitly modeling anticipation using event time around *election* and *retail opening*)**

---

**#2: High on Employment? A Spatial RDD of Recreational Marijuana Legalization Effects on Industry-Specific Labor Markets (Idea 1)**
- **Score: 64/100**
- **Strengths:** Clean, intuitive design and strong transparency: GIS running variable + border-pair×quarter FE + placebo tests are exactly what a serious spatial RDD should do. Industry-by-industry predictions plus multiple-testing correction is a coherent empirical package.
- **Concerns:** Spatial RDD’s core assumption (smooth potential outcomes at the border absent treatment) is fragile here because **borders are exactly where taxes, regulation, policing, and economic geography jump**—and marijuana creates *purposeful cross-border travel*, violating SUTVA. Centroid distance is also a noisy running variable for irregular counties; results can be bandwidth- and specification-sensitive.
- **Novelty Assessment:** **Moderate-low to moderate.** Border approaches and cannabis are not new; what’s newer is **QWI-based, high-frequency, industry-resolved border RDD with strong diagnostics**—still incremental, but not frontier.
- **Recommendation:** **CONSIDER** *(as a “first-stage diagnostic” for where DiDisc is plausible; don’t rely on it alone—plan for DiDisc as primary)*

---

**#3: Drug Testing Industries vs. Non-Testing Industries: A Triple-Difference Approach (Idea 4)**
- **Score: 55/100**
- **Strengths:** The mechanism is policy-relevant and potentially novel: legalization interacting with workplace testing regimes could explain heterogeneous labor-supply and hiring responses, not just cannabis-sector job creation.
- **Concerns:** The **Quest Drug Testing Index** is a problematic “intensity” measure: it is often closer to *positivity among tested* than *testing prevalence*, and may itself respond to legalization (endogenous). It is also typically annual and may provide too few pre-periods for early legalizers (CO/WA), making the key DDD parallel-trends claim hard to defend.
- **Novelty Assessment:** **Moderate.** “Cannabis × labor markets” is well-trodden, but **explicit DDD by drug-testing intensity** is less common and could be a contribution if measurement is solid.
- **DiD Assessment (DDD):**
  - **Pre-treatment periods:** **Weak** *(Quest series likely short; may not deliver ≥5 pre years for early-treated states)*  
  - **Selection into treatment:** **Marginal**  
  - **Comparison group:** **Marginal** *(across states + across industries; industry composition differs and may trend differently)*  
  - **Treatment clusters:** **Marginal** *(only 5 treated states as written; could add more legal states)*  
  - **Concurrent policies:** **Marginal** *(industry-specific cycles + state policy bundles)*  
  - **Outcome-Policy Alignment:** **Strong** *(QWI outcomes align; mechanism is industry hiring constraints)*  
  - **Data-Outcome Timing:** **Marginal** *(annual testing measure vs quarterly outcomes → timing/aggregation choices matter)*  
  - **Outcome Dilution:** **Marginal** *(“high-testing industries” are broad; legalization’s binding constraint likely affects a subset of occupations/firms)*  
- **Recommendation:** **CONSIDER (conditional on: obtaining a credible panel of *testing prevalence* by industry over a long pre-period, or a plausibly time-invariant pre-period measure; pre-registering a small set of industry groups to avoid specification search)**

---

**#4: Cross-Border Commuting Zones: Labor Market Spillovers from Marijuana Legalization (Idea 3)**
- **Score: 48/100**
- **Strengths:** Conceptually appealing: commuting zones match the economic labor market better than state lines, and CZ×quarter FE is a strong way to net out local shocks.
- **Concerns:** Identification is threatened because **CZ integration is exactly what causes treatment contamination** (workers and consumers cross the state line), shrinking treated-control contrast within a CZ. Also, the number of CZs that cleanly straddle treated/control borders may be small, making inference fragile.
- **Novelty Assessment:** **Moderate.** CZ framing is somewhat fresh, but spillovers and commuting have been discussed in prior border-cannabis work; the big issue is not novelty but contamination/inference.
- **DiD Assessment (within-CZ treated vs control counties):**
  - **Pre-treatment periods:** **Marginal** *(feasible to get long pre; not yet specified)*  
  - **Selection into treatment:** **Marginal**  
  - **Comparison group:** **Marginal** *(within CZ helps, but counties on each side can still differ; plus spillovers)*  
  - **Treatment clusters:** **Weak** *(likely <10 CZs/border-CZs with usable data → very fragile SEs)*  
  - **Concurrent policies:** **Marginal**  
  - **Outcome-Policy Alignment:** **Strong**  
  - **Data-Outcome Timing:** **Marginal**  
  - **Outcome Dilution:** **Weak** *(spillovers imply both sides are partially treated; “control” is contaminated)*  
- **Recommendation:** **SKIP** *(unless reframed explicitly as a **spillover/contamination study** with measured commuting flows and a design that treats “exposure intensity” continuously rather than binary treated/control)*

---

**#5: Age-Specific Effects: Youth Employment and the Minimum Legal Age (Idea 5)**
- **Score: 40/100**
- **Strengths:** Policy hook is clear (legal access at 21), and QWI age bins make it tempting to implement quickly.
- **Concerns:** The age bins undermine the design: the “19–21” group includes **21-year-olds who are legally treated**, creating mechanical misclassification. Even if fixed, legal access is not the only margin (illegal access, social sourcing, medical markets), so the treated-control contrast by age is weak and effects will be heavily diluted.
- **Novelty Assessment:** **Low to moderate.** Age heterogeneity around legal thresholds has been examined in multiple substance-policy contexts; for cannabis specifically, age-stratified labor outcomes are not entirely new.
- **DiD Assessment (age-based DDD):**
  - **Pre-treatment periods:** **Marginal** *(can be long, but not specified)*  
  - **Selection into treatment:** **Marginal**  
  - **Comparison group:** **Weak** *(19–21 vs 22–24 differ systematically for lifecycle reasons; plus 21 is inside the “control” bin)*  
  - **Treatment clusters:** **Marginal**  
  - **Concurrent policies:** **Marginal**  
  - **Outcome-Policy Alignment:** **Marginal** *(employment is relevant, but the policy margin is *legal purchase*, not employment policy; link is indirect and confounded by other age-related changes)*  
  - **Data-Outcome Timing:** **Marginal**  
  - **Outcome Dilution:** **Weak** *(only a subset changes use because of legal access; plus bin misclassification further dilutes)*  
- **Recommendation:** **SKIP** *(unless you can use microdata with exact age in months and outcomes tightly linked to the access margin, e.g., UI wage records with DOB, or survey microdata with exact age and usage)*

---

### Summary

This is a coherent bundle centered on border-based identification with strong administrative outcomes, but most ideas hinge on **credible pre-trend evidence and avoiding contamination/attenuation from cross-border spillovers**. The most promising path is to make **Idea 2 (DiDisc)** the main design (with much longer pre-periods and more treated borders), using **Idea 1 (RDD)** as a diagnostic/visualization tool rather than the headline estimator. Ideas 3 and 5 fail on core identification (spillover contamination; age-bin misclassification/dilution), while Idea 4 is potentially interesting but currently constrained by the drug-testing measure’s validity and time coverage.