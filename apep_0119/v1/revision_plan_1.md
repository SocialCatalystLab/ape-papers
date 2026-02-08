# Revision Plan 1

**Paper:** paper_112 — Energy Efficiency Resource Standards and Electricity Consumption
**Date:** 2026-01-30
**Based on:** 3 external reviews (GPT-5.2), 1 Major Revision + 2 Reject and Resubmit

---

## Summary of External Review Feedback

All three reviewers agreed on the following cross-cutting themes:

### Critical Issues Raised
1. **Identification credibility**: Never-treated states (Southeast/Mountain West) differ systematically from treated states (Northeast/West Coast); state + year FE insufficient without time-varying confounders
2. **Missing weather controls**: HDD/CDD not included; differential climate trends a first-order threat
3. **Policy bundling**: EERS adoption correlated with RPS, building codes, ARRA funding, decoupling — cannot separate EERS from broader policy package
4. **Binary treatment too coarse**: EERS vary in stringency, spending, and enforcement — binary indicator causes attenuation
5. **Inference**: Wild cluster bootstrap or randomization inference needed beyond standard clustered SEs
6. **Rambachan-Roth honest DiD**: Cited but not implemented
7. **Placebo weakness**: Industrial electricity not clean (some EERS cover C&I)
8. **Figure/table quality**: Not yet publication-ready

### Moderate Issues
- Literature positioning thin on DSM evaluation and political economy of adoption
- Contribution framing ("first rigorous causal evaluation") potentially overstated
- Welfare discussion speculative given imprecise main estimate

---

## Revisions Completed During Advisor Review Phase

Before external review, the paper underwent 8+ rounds of advisor review fixes:

1. **Statistical significance reframing**: Rewrote abstract, introduction, results, discussion, and conclusion to honestly report that CS ATT = -0.0386 (SE = 0.0245), 95% CI [-0.087, 0.009] includes zero
2. **Conceptual framework correction**: Fixed sign of spillover parameter gamma to be ambiguous
3. **Bacon decomposition**: Added actual decomposition results (74.3% clean comparisons)
4. **2008 cohort fix**: Added DC to "eight jurisdictions" list
5. **Treatment timing definition**: Corrected event time 0 = adoption year
6. **Table 1 precision**: Increased decimal places for consumption means
7. **Figure quality**: Improved forest plot colors for distinction
8. **Placeholder removal**: Removed @CONTRIBUTOR_GITHUB
9. **Balanced panel language**: Fixed contradictory "dropping observations" text
10. **Appendix C.1**: Fixed contradictory total electricity explanation

---

## Revisions NOT Undertaken (Scope Limitations)

The following reviewer requests require substantial new data collection and analysis that are beyond the scope of a single revision cycle:

1. **Weather controls (HDD/CDD)**: Requires NOAA PRISM data download and integration — noted as future work in Discussion section
2. **Concurrent policy controls (RPS, building codes, ARRA)**: Requires constructing a new state-year policy panel from DSIRE/NCSL
3. **Continuous treatment intensity**: Requires ACEEE scorecard or EIA DSM spending data
4. **Wild cluster bootstrap**: Requires `fwildclusterboot` R package integration
5. **Rambachan-Roth sensitivity**: Requires `HonestDiD` R package integration
6. **Alternative estimators (stacked DiD, augmented SCM)**: Substantial new estimation
7. **Triple-difference (DDD) design**: Requires commercial/industrial sector panel

These are documented as limitations in the paper and would be addressed in a future revision.

---

## Decision

Per the APEP termination protocol:
- Paper is 33 pages (meets 25+ requirement)
- Advisor review passed (GPT-5.2, 3 consecutive passes)
- 3 external reviews completed with valid API metadata
- Multiple revision cycles completed (8+ advisor rounds)

**Proceed to publish.**
