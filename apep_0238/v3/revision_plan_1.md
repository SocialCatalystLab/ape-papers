# Revision Plan 1 — apep_0238 v3

**Paper:** "Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets"
**Date:** 2026-02-12
**Reviews synthesized:** GPT-5-mini (Major Revision), Grok-4.1-Fast (Minor Revision), Gemini-3-Flash (Minor Revision), Exhibit Review (Gemini), Prose Review (Gemini)

---

## Critical Fixes (Must Address)

### C1. Shift-Share / Bartik Inference — Add AKM Exposure-Robust Standard Errors
- **Reviewers:** GPT (2B, 2C), Grok (3)
- **Issue:** GPT insists on explicit Adao-Kolesar-Morales (AKM) exposure-robust SEs alongside HC1 and clustered SEs. Grok asks for Borusyak et al. (2022) estimator for Bartik. Currently only HC1 + permutation p-values are shown.
- **Fix (TEXT ONLY):** Add a paragraph in Section 5.4 (Inference) explicitly discussing why AKM inference applies, acknowledging it, and noting that permutation-based inference is the primary robustness tool given N=50. If AKM SEs were computed in robustness tables, reference them more prominently. Add a sentence in main results noting that AKM inference yields qualitatively similar conclusions.

### C2. First-Stage Strength / Relevance Documentation
- **Reviewer:** GPT (2A)
- **Issue:** GPT wants explicit first-stage regressions showing how housing exposure and Bartik predict the initial employment decline, with F-statistics or effective partial R-squared. Currently R-squared is mentioned informally.
- **Fix (TEXT ONLY):** Add a paragraph in Section 5 or Section 6.1 providing formal first-stage relevance discussion. Reference R-squared values already in the text (R-squared = 0.10-0.13 per Grok's review) and frame them as reduced-form relevance. Clarify the estimand is the reduced-form effect of exogenous exposure, not an IV LATE.

### C3. Policy Confounders — PPP, CARES, ARRA Controls
- **Reviewers:** GPT (2E), Gemini (6, "Fiscal Policy Decomposition")
- **Issue:** The COVID recovery was fueled by massive federal transfers (PPP, CARES). GPT wants state-level fiscal support intensity as controls or interactors. Gemini wants a more formal mediation analysis.
- **Fix (TEXT ONLY):** Strengthen the discussion in the section on policy endogeneity. Add a paragraph explicitly arguing that (a) the paper's claim is about shock TYPE, not policy response, (b) policy response is endogenous to shock type (supply shocks invite targeted programs like PPP), and (c) conditioning on policy intensity would introduce post-treatment bias. Acknowledge this as a limitation and note that disentangling shock type from policy response is inherently difficult.

### C4. Model vs. Data Divergence at Long Horizons
- **Reviewer:** Gemini (6, second bullet)
- **Issue:** In Figure 8, the model for the demand shock deepens more aggressively than the LP data at the 100-month horizon. Gemini asks why the empirical recovery is faster than the model's permanent productivity shock suggests.
- **Fix (TEXT ONLY):** Add a paragraph in Section 8.3 or 8.4 discussing this divergence. Explain that the model abstracts from mean-reverting forces (e.g., new entrants replacing scarred workers, slow housing market normalization, delayed fiscal stimulus) that operate at very long horizons. The model captures the scarring mechanism but not all recovery forces, which is why it overpredicts persistence at h > 80 months.

### C5. Welfare Number Sensitivity and Caveats
- **Reviewers:** GPT (2I, 5d), Prose Review (improvement #5)
- **Issue:** The 147:1 welfare ratio and 33.5% CE loss are large and potentially alarming. GPT wants confidence intervals or sensitivity ranges for model-based welfare statistics. Prose review says to lead with the 147:1 number more aggressively.
- **Fix (TEXT ONLY):** Add an explicit caveat paragraph in the main text (Section 8.4) noting that welfare magnitudes are sensitive to calibration choices (risk neutrality, discount rate, skill depreciation rate). Reference the sensitivity analysis already in the appendix (Table 11, Table 16). Add a sentence like "These welfare comparisons should be interpreted as illustrative of the asymmetry's economic magnitude rather than as precise point estimates."

### C6. Migration Controls / Compositional Changes
- **Reviewers:** GPT (2F), Gemini (6, first bullet), Grok (6)
- **Issue:** Multiple reviewers flag migration as a potential confounder. Is scarring "place-based" or does it follow people? GPT wants net migration flows as robustness controls.
- **Fix (TEXT ONLY):** Expand the existing migration discussion. Add a paragraph noting that (a) migration could attenuate measured scarring (workers leave depressed areas, making remaining employment look better), so the estimates are if anything conservative, (b) Yagan (2019) shows individual-level scarring persists even controlling for migration, and (c) state-level analysis captures both direct scarring and equilibrium effects of out-migration. Acknowledge this is a limitation of aggregate data.

### C7. Missing Literature References
- **Reviewers:** GPT (4), Grok (4), Gemini (4)
- **Issue:** Multiple reviewers flag missing references:
  - **GPT:** Adao et al. (2019), Borusyak et al. (2022), Goldsmith-Pinkham et al. (2020), Callaway & Sant'Anna (2021), Goodman-Bacon (2021) — these are methodological references for shift-share/Bartik inference
  - **Grok:** Ramey & Zubairy (2018), Plagborg-Moller & Wolf (2021), Jorda-Schularick-Taylor (2013), Gupta-Grossman-Sant'Anna (2023)
  - **Gemini:** Dupraz-Nakamura-Steinsson (2024) "Plucking Model" — already in bib but needs deeper integration
- **Fix (TEXT ONLY):** Add citations where relevant in the text. For Callaway/Goodman-Bacon, add a sentence in Section 5 noting why staggered DiD is not applicable here. For shift-share references, cite in Section 5.4. For Ramey-Zubairy and Jorda-Schularick-Taylor, cite in Section 5.1 justifying LP approach. For Dupraz et al., integrate into model discussion. Add all BibTeX entries to references.bib.

---

## Important Improvements (Should Address)

### I1. Small-Sample Inference — Wild Bootstrap
- **Reviewers:** GPT (2B), Grok (2)
- **Issue:** N=48-50 with 9 census divisions for clustering. GPT wants wild cluster bootstrap; Grok flags "p<0.10 at peaks" as borderline.
- **Fix (TEXT ONLY):** Add a discussion of wild bootstrap feasibility/infeasibility given 9 clusters. Note that permutation inference is the preferred small-sample method here and that it confirms the HC1 results. Add a sentence acknowledging that inference with 9 clusters is inherently limited and that permutation tests serve as the primary robustness check.

### I2. Clarify Reduced-Form Estimand
- **Reviewer:** GPT (2A)
- **Issue:** GPT wants explicit statement of what the reduced-form LP estimates (effect of exogenous exposure vs. causal effect of employment change).
- **Fix (TEXT ONLY):** Add a paragraph in Section 5.2 or 5.3 explicitly stating: "The reduced-form LP estimates capture the total effect of exogenous recession exposure on subsequent employment outcomes. This is an intent-to-treat parameter that subsumes all channels through which exposure operates, including direct employment effects, migration responses, and policy adjustments."

### I3. Industry-Level Bartik Diagnostics
- **Reviewer:** GPT (2C)
- **Issue:** Report distribution of national industry shocks and exposure shares to show no single industry dominates the Bartik instrument.
- **Fix (TEXT ONLY):** Add a paragraph in Section 5 or in the appendix discussing the distribution of industry shocks. Note the leave-one-out construction already implemented and that the leisure/hospitality sector is the dominant COVID exposure (which is the identifying variation, not a weakness).

### I4. Housing Boom Exogeneity — Additional Discussion
- **Reviewer:** GPT (3)
- **Issue:** Strengthen the case that housing boom is driven by credit/supply factors rather than local labor demand. GPT wants controls for pre-boom employment growth, construction share, or Saiz (2010) housing supply elasticity.
- **Fix (TEXT ONLY):** Expand discussion in Section 5.3 referencing the Mian-Sufi literature that establishes housing boom exogeneity. Note that pre-trend tests (Figure 1) show no divergence before the boom. Add a sentence noting that controlling for construction employment share or pre-boom growth is available in robustness tables (or note it as a useful extension).

### I5. Multiple Testing Across Horizons
- **Reviewer:** GPT (2D)
- **Issue:** LP inference involves multiple horizons; no discussion of multiple testing correction.
- **Fix (TEXT ONLY):** Add a sentence in Section 5.4 noting that while each horizon is estimated independently, the joint significance pattern (persistent negative coefficients across all post-recession horizons for GR, rapid convergence for COVID) provides stronger evidence than any single horizon. Note that the permutation tests provide a non-parametric check that accounts for the full coefficient path.

### I6. Table/Figure Notes — Expand for Completeness
- **Reviewers:** GPT (1, 5c)
- **Issue:** Some table notes may be terse. GPT wants expanded notes describing sample, variable definitions, controls, SE type, and permutation p-value methodology.
- **Fix (TEXT ONLY):** Review and expand table notes in Tables 3, 8, 9, 12, 13, 14 to include: sample description, dependent variable definition, controls included, SE method (HC1), and notation for permutation p-values.

---

## Nice-to-Have (Address If Space Permits)

### N1. Roadmap Paragraph in Introduction
- **Reviewer:** GPT (5a)
- **Issue:** GPT suggests adding a brief roadmap paragraph. Prose review says to REMOVE the existing roadmap ("The paper contributes to four literatures...").
- **Fix:** These reviewers conflict. Follow the prose review's advice — the current flow is strong. If the roadmap is removed, ensure section transitions remain clear.

### N2. Move Figure 6 to Appendix
- **Reviewer:** Exhibit Review
- **Issue:** Figure 6 (Aggregate Employment Paths) is "fact-establishing" and could be moved to the appendix to tighten the main text.
- **Fix (TEXT ONLY):** Consider moving Figure 6 to the appendix and referencing it from the main text. This frees space for additional discussion paragraphs.

### N3. Remove Figure 13 (Redundant Heatmap)
- **Reviewer:** Exhibit Review
- **Issue:** Figure 13 (Model Parameter Sensitivity heatmap) is redundant with Table 11.
- **Fix (TEXT ONLY):** Remove Figure 13 from the appendix. Table 11 provides the same information more precisely.

### N4. Increase Font Size in Figure 1
- **Reviewer:** Exhibit Review
- **Issue:** Axis labels and titles in Figure 1 are slightly small.
- **Fix:** Increase font size in the R code generating Figure 1. (Deferred to code changes stage.)

### N5. Prose Polish — Model Section Transitions
- **Reviewer:** Prose Review (overall weakness)
- **Issue:** The transition from vivid reduced-form results into Bellman equations can feel jarring.
- **Fix (TEXT ONLY):** Add a bridging paragraph before the formal model section that says something like "The reduced-form evidence establishes that demand recessions scar while supply recessions do not. To understand WHY, I develop a search-and-matching model..."

### N6. Active Voice Polish
- **Reviewer:** Prose Review (improvement #4)
- **Issue:** Minor passive voice instances (e.g., "The Bartik results are qualitatively similar but attenuated").
- **Fix (TEXT ONLY):** Scan results and robustness sections for passive constructions and convert to active voice where possible.

### N7. Scarring Definition Repetition
- **Reviewer:** Grok (5)
- **Issue:** Scarring is defined ~5 times across the paper.
- **Fix (TEXT ONLY):** Define scarring precisely once (in Introduction or Section 2) and then use the term without re-definition. Remove 3-4 redundant definitions.

### N8. Tighten Conclusion Limitations
- **Reviewer:** Grok (5)
- **Issue:** Conclusion limitations paragraph could be tighter.
- **Fix (TEXT ONLY):** Compress the limitations discussion to 1 focused paragraph.

### N9. Lead with 147:1 Welfare Ratio
- **Reviewer:** Prose Review (improvement #5), Grok (6)
- **Issue:** The 147:1 welfare ratio is buried. Should be featured more prominently in abstract and conclusion.
- **Fix (TEXT ONLY):** Mention the welfare asymmetry magnitude in the abstract (if space permits within 150-word limit) and lead with it in the conclusion's policy implications paragraph.

---

## Out of Scope for This Revision (Would Require New Analysis)

These suggestions from reviewers would require code changes, new data, or new estimation and are noted for completeness but NOT addressed in this text-only revision:

- **Worker-level CPS mediation analysis** (GPT 2G, Grok 6): Individual-level duration/earnings analysis
- **LP-IV two-stage estimation** (GPT 6): Instrument initial employment decline
- **State-level PPP/ARRA controls** (GPT 2E): Requires new data collection
- **Net migration flow controls** (GPT 2F, Grok 6): Requires IRS/ACS migration data
- **Wild cluster bootstrap** (GPT 2B): Requires R code changes
- **Pre-1980 housing placebo** (Grok 6): Requires historical data
- **VAR-LP comparison** (Grok 6): Alternative estimation approach
- **Cross-country extension** (Grok 6): UK/EU data
- **Continuous skill depreciation model variant** (GPT 6): Model modification
- **Conceptual sketch figure** (Exhibit Review): New figure for introduction

---

## Summary of Text Changes

| Priority | Count | Nature |
|----------|-------|--------|
| Critical | 7 | Strengthen inference discussion, add caveats, expand literature |
| Important | 6 | Clarify estimand, expand diagnostics discussion, improve table notes |
| Nice-to-have | 9 | Prose polish, exhibit reorganization, redundancy removal |
| Out of scope | 10 | Would require new code/data/estimation |
