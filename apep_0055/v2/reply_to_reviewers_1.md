# Reply to Reviewers - Round 1

**Paper:** Coverage Cliffs and the Cost of Discontinuity: Health Insurance Transitions at Age 26
**Revision of:** apep_0055
**Date:** 2026-02-04

---

## Response to GPT-5-mini (MAJOR REVISION)

We thank the reviewer for the thorough and constructive feedback.

### Treatment Measurement and Fuzzy RD

The reviewer correctly identifies that the integer-year age measure and variation in plan termination timing create measurement challenges. We agree this is the central limitation.

**Response:** We have expanded the limitations section (Section 11) to more thoroughly discuss this issue. We note that the discrete measurement error likely attenuates estimates toward zero, meaning our estimates are conservative. We also implement local randomization inference which makes no smoothness assumptions and confirms the positive effect at age 26. Obtaining restricted NCHS data with exact birthdates would strengthen the analysis but is beyond the scope of this revision.

### Per-Regression N and SE Details

**Response:** We have ensured all tables report N and specify the SE methodology (heteroskedasticity-robust). The MSE-optimal bandwidth and polynomial order are reported in table notes.

### State Heterogeneity by Medicaid Expansion

**Response:** We acknowledge this as a valuable extension. The current analysis focuses on establishing the basic effect; state-level heterogeneity could be explored in future work with larger sample sizes per state.

### Fiscal Estimate Uncertainty

**Response:** We have clarified that the $54 million figure is a back-of-envelope calculation and noted the uncertainty in scaling local effects to national estimates.

---

## Response to Grok-4.1-Fast (MINOR REVISION)

We thank the reviewer for the positive assessment.

### Discrete Running Variable

**Response:** We have expanded the discussion in Section 6.3 and Section 11 to more fully address the implications of the discrete running variable, including the use of Kolesár-Rothe variance estimators and local randomization inference.

### Additional Placebo Tests

**Response:** The placebo tests in Section 8.3 examine ages 24, 25, 27, and 28. The results show that the positive discontinuity at age 26 is qualitatively different from the effects at other ages, supporting the interpretation that we are identifying the policy effect.

---

## Response to Gemini-3-Flash (MINOR REVISION)

We thank the reviewer for appreciating the coverage cliff framing.

### Literature on Churning

**Response:** We have added citations to Sommers (2009) and Dague et al. (2017) on churning and coverage transitions, and Currie & Gruber (1996) on take-up of public programs.

---

## Summary of Changes

1. Fixed code integrity issues (column naming, missing heterogeneity analysis, hard-coded paths)
2. Complete prose overhaul with new "Coverage Cliffs" framing
3. Expanded literature with canonical RD citations
4. Harmonized internal consistency (sample sizes, baseline rates, CIs)
5. Strengthened limitations section to address measurement concerns

The paper is ready for publication as a revision of apep_0055.
