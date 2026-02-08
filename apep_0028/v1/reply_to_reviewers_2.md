# Reply to Reviewers - Round 2

**Responding to:** GPT 5.2 Review (Round 2) + Gemini 3 Pro Review (Round 2)
**Date:** January 2026

---

## Summary of Changes

We thank both reviewers for their detailed and constructive feedback. The Round 2 reviews identified fundamental methodological concerns that we now address through substantial revisions:

1. **Implemented Synthetic Control Method (SCM)** as primary estimator
2. **Added permutation inference** with 47 donor states
3. **Added 10 new citations** covering modern DiD methodology, SCM, and inference with few treated units
4. **Expanded literature review** with methodological discussion
5. **Substantially revised interpretation** to acknowledge identification limitations
6. **Updated abstract and conclusion** to reflect conflicting estimates

The paper is now 35 pages with 26 citations.

---

## Response to GPT 5.2 (Round 2)

### Critical Issue 1: N=1 Treated Unit Requires Specialized Inference

**Reviewer:** "The design as implemented is not credible enough for a top journal... standard TWFE is inappropriate for single treated unit... need permutation/Conley-Taber/synthetic-based inference."

**Response:** We agree this was a fundamental limitation. We have now:
- Implemented Synthetic Control Method using 47 donor states (all non-reform states)
- Added permutation-based inference following Abadie et al. (2010)
- Reported Montana's rank in the placebo distribution (20 of 48, p = 0.958)
- Added new results section (5.8) presenting SCM findings

The SCM estimate of -0.71 permits/100K contrasts sharply with the TWFE estimate of +3.2, suggesting the TWFE result may reflect pre-existing differences rather than a causal effect.

### Critical Issue 2: Pre-Trends Violated

**Reviewer:** "Your own event study shows large, nonzero, oscillating pre-treatment coefficients... this is a serious threat."

**Response:** We acknowledge this limitation more prominently. The updated Discussion (Section 6.1) now opens with: "The analysis produces conflicting estimates depending on methodology... event study analysis reinforces concerns about identification... the magnitude of pre-treatment coefficients indicates that Montana and control states did not follow parallel trajectories before the policy change."

We do not claim causal identification is achieved.

### Critical Issue 3: Missing DiD Methodology Citations

**Reviewer provided BibTeX for:** Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Sun & Abraham (2021), de Chaisemartin & d'Haultfoeuille (2020), Conley & Taber (2011), Ferman & Pinto (2019), Cameron et al. (2008), Arkhangelsky et al. (2021), Ben-Michael et al. (2021)

**Response:** We added all suggested citations plus Greenaway-McGrevy & Phillips (2021) on Auckland upzoning. The bibliography now contains 26 references. We also added a new subsection (3.4) "Methodological Literature on Difference-in-Differences" discussing these advances.

### Critical Issue 4: State-Level Aggregation Masks Policy Variation

**Reviewer:** "SB 323 applies only to qualifying cities/counties. That creates a natural within-Montana design: triple-differences."

**Response:** We acknowledge this as a fundamental limitation but note that place-level BPS data requires special tabulation from Census. The updated Limitations section (6.4) and Conclusion explicitly call for future research using place-level data: "Future research should exploit within-state variation using place-level permit data. Montana cities above and below the 5,000 population threshold provide a natural comparison group for triple-difference designs."

We position this paper as documenting the limitations of state-level analysis rather than providing credible causal estimates.

### Issue 5: Literature Review Thin

**Response:** Expanded literature review with new subsection on methodological advances (3.4) and additional discussion of Auckland evidence (Greenaway-McGrevy & Phillips 2021).

---

## Response to Gemini 3 Pro (Round 2)

### Critical Issue 1: TWFE Inappropriate for N=1

**Reviewer:** "Standard TWFE is inferior here to Synthetic Control Methods (SCM), which construct a data-driven counterfactual."

**Response:** Addressed via implementation of SCM. Results in new Section 5.8 and Table 5. The SCM estimate (-0.71) contrasts with TWFE (+3.2), illustrating the reviewer's concern.

### Critical Issue 2: Granular Data Mandatory

**Reviewer:** "You cannot analyze a municipal-level policy with state-level data. You must acquire the Building Permits Survey Place-Level Data."

**Response:** We agree this would be ideal but note it requires special tabulation. We now position the paper as a methodological case study illustrating the problems with state-level analysis, and explicitly call for future research using place-level data.

### Critical Issue 3: Placebo Tests Needed

**Reviewer:** "With N=1 treated state, you should run 'placebo laws' on all control states."

**Response:** Implemented. Montana ranks 20 of 48 states in placebo distribution (p = 0.958). Results reported in Section 5.8 and Figure 6 (Appendix).

### Critical Issue 4: Auckland Evidence Missing

**Reviewer:** "The Auckland evidence is the most famous empirical example of upzoning. It must be cited and contrasted."

**Response:** Added Greenaway-McGrevy & Phillips (2021) citation and discussion: "The most rigorous evidence on upzoning comes from Greenaway-McGrevy and Phillips (2021), who studied Auckland, New Zealand's 2016 reforms... Using a spatial regression discontinuity design, they found substantial increases in building consents in newly upzoned areas."

### Issue 5: References Inadequate (17)

**Response:** Now 26 references after adding all suggested methodology citations.

---

## Summary of Current Status

| Criterion | Round 1 | Round 2 Revision |
|-----------|---------|------------------|
| Pages (main text) | ~23 | 35 |
| References | 8 → 17 | 26 |
| SCM Analysis | No | Yes (47 donors) |
| Permutation Inference | No | Yes (p = 0.958) |
| DiD Methodology Cites | 2 | 11 |
| Acknowledges Design Limitations | Briefly | Extensively |

---

## Remaining Limitations

We acknowledge that certain reviewer suggestions cannot be fully addressed:

1. **Place-level data:** Requires Census special tabulation. We call for future research.
2. **Within-Montana triple-diff:** Requires place-level data.
3. **Perfect pre-fit:** Monthly data is noisy; SCM achieves RMSPE of 10.1.

The paper now presents itself as a methodological case study showing *why* state-level analysis is inadequate for evaluating municipal-level policies, rather than claiming credible causal estimates.
