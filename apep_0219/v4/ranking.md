# Research Idea Ranking

**Generated:** 2026-02-11T09:09:56.301402
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 5255

---

### Rankings

**#1: The Distress Label Trap — Does ARC's "Distressed" Designation Help or Harm Appalachian Counties?**
- **Score: 68/100**
- **Strengths:** Very strong *policy discontinuity* (match rate 80% vs 70% plus program eligibility) with unusually rich, long county panel data and a forcing variable that is public and annually updated. Novel application area (ARC tiering) with clear policy stakes for place-based funding design.
- **Concerns:** The **running variable is constructed from (or tightly related to) key economic outcomes** you’ll want to study (poverty, unemployment, income), creating risks of mechanical “effects” or mean reversion unless outcomes are **measured strictly post-designation** (e.g., \(t+1\) to \(t+3\) only) and/or use outcomes not in the CIV (business formation, migration, health, etc.). The cutoff is a **moving national percentile** and counties may “hover” across years, complicating inference (effective sample size smaller than county-year count).
- **Novelty Assessment:** High. ARC’s distressed cutoff is a plausibly clean forcing variable that (to my knowledge) has not generated a large RDD literature, especially not on stigma/label effects.
- **Recommendation:** **PURSUE (conditional on: (i) explicitly aligning timing—designation year vs outcome measurement year; (ii) treating CIV-component outcomes carefully—use leads/lags and prioritize non-CIV outcomes; (iii) documenting no manipulation/bunching and stable covariates at the cutoff; (iv) showing a strong first stage on ARC dollars / match-rate utilization).**

---

**#2: Does Superfund Listing Improve Community Health? Revisiting the HRS Score Threshold with an Environmental Justice Lens**
- **Score: 60/100**
- **Strengths:** A classic, well-understood **sharp regulatory cutoff (HRS ≥ 28.5)** with a credible quasi-experimental design and high policy relevance (environmental justice and cleanup prioritization). Extending the canonical RDD beyond housing prices toward *health* is substantively valuable.
- **Concerns:** **Outcome dilution is a serious threat** if you use county-level mortality: Superfund exposure is highly localized, and many “treated” people in the county are unexposed (attenuation toward zero). Also, **treatment is not “listing = immediate cleanup”**; cleanup timing and pathway to exposure reduction are long and heterogeneous, so you’ll need an event-study style design around *actual remediation milestones* or at least long lags—otherwise nulls are hard to interpret.
- **Novelty Assessment:** Medium. The cutoff RDD itself is famous and heavily cited (Greenstone & Gallagher and successors), and there is a substantial broader Superfund/cleanup-health literature (often DiD). The “RDD + modern health/EJ outcomes” angle is new-ish but not untouched.
- **Recommendation:** **CONSIDER (conditional on: (i) moving to finer geography/exposure—ZIP, tract, or distance bands around sites; (ii) using outcomes plausibly tied to exposure pathways and timing; (iii) explicitly modeling remediation timing, not just NPL listing).**

---

**#3: Flood Zone Mandates and Credit Access — An NFIP Boundary Discontinuity Design**
- **Score: 48/100**
- **Strengths:** The question is highly policy-relevant (insurance mandates and credit constraints) and plausibly novel relative to the flood-zone boundary literature that emphasizes housing prices. HMDA post-2018 is rich and large.
- **Concerns:** **Identification is the core problem.** The SFHA boundary discontinuity mixes (a) the *mandate* with (b) true/ perceived *flood risk* and (c) underwriting responses to collateral risk—so even near the line, effects may reflect risk rather than the policy requirement. Data feasibility is also shaky with public HMDA: outcomes are at **census-tract**, but the treatment is **property-level location relative to a polygon boundary**; tract aggregation creates **severe treatment misclassification and dilution**, undermining a spatial RDD unless you have restricted micro-geo (property coordinates) or a design focused on “boundary-adjacent” micro areas.
- **Novelty Assessment:** Medium-to-high on *credit outcomes*, but the broader “SFHA boundary discontinuity” approach is not new; the novelty is not enough to compensate for the likely measurement/identification weaknesses with tract-level data.
- **Recommendation:** **SKIP (unless you can obtain property-level geocodes / restricted HMDA or a lender dataset with precise location, and can separate mandate effects from flood-risk effects—e.g., using map revisions that change SFHA status for the same properties).**

---

### Summary

This is a solid batch: two ideas leverage genuine regulatory cutoffs, and one pushes into an underexplored policy margin (ARC distressed designation). **Idea 1** is the best bet if you handle the major pitfall (CIV is built from the same variables you might call “outcomes”) and demonstrate a first-stage on actual fiscal resources. **Idea 2** is credible but at high risk of attenuation from coarse health geography and slow treatment timing; it becomes much stronger with finer exposure measures or remediation-timing data. **Idea 3** is interesting but, with public tract-level HMDA, is unlikely to deliver clean causal inference without better micro-geography or a map-revision design.