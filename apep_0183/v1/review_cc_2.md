# Internal Review - Round 2

**Reviewer:** Claude Code (Internal Review)
**Paper:** High on Employment? A Spatial Difference-in-Discontinuities Analysis of Marijuana Legalization and Industry-Specific Labor Market Effects
**Date:** 2026-02-04

---

## PART 1: CRITICAL REVIEW (Harsh, Skeptical)

### Methodology Deep Dive

**On the DiDisc estimator:**
The paper claims to implement a "difference-in-discontinuities" design but the formal exposition conflates several different estimands. Equation (8) shows $\tau^{DiDisc}$ as the coefficient on $T_c \times P_t$, but this is a standard DiD interaction term, not a change in an RDD slope or discontinuity. The true DiDisc estimator should difference out the pre-period RDD estimate from the post-period RDD estimate. The current specification may be capturing parallel trends violations rather than true changes in the border discontinuity.

**Rebuttal:** The specification includes $f(D_c) \times P_t$ and $T_c \times f(D_c) \times P_t$ interactions, which do allow the RDD polynomial to vary pre/post. This addresses the concern, though the paper could be clearer that the identifying variation comes from the triple interaction, not just the double interaction.

**On placebo tests:**
The paper claims all 8 placebos pass, but the test is underpowered. With SE around 0.03, the placebo tests can only detect effects larger than ~6% (at 80% power). The main effect has SE of 0.062, suggesting even less power. Passing placebo tests may simply reflect lack of statistical power rather than true validity of the identifying assumption.

**On industry heterogeneity:**
The pre-specification of industry categories is claimed in Section 3.4, but this is not truly pre-registered. The paper was written knowing the results, so the "pre-specification" may have been influenced by preliminary data exploration. The Information sector result (-13%) is reported as "the only FDR-significant result" but receives extensive discussion, while the pre-specified agriculture and retail null results receive less emphasis.

### Data Quality Concerns

1. **Suppression bias**: The paper acknowledges 15% of cells are suppressed, predominantly in rural counties and specialized industries. This is concerning because (a) border counties are disproportionately rural, and (b) direct cannabis industries (agriculture, retail) have high suppression rates. The null findings in pre-specified industries may reflect measurement error from suppression rather than true nulls.

2. **NAICS misclassification**: Cannabis businesses may be classified inconsistently across states and time. If Colorado classified dispensaries differently than Washington, the industry-specific estimates could be biased. The paper acknowledges this but doesn't assess the magnitude.

3. **QWI timing**: QWI data are released with a lag and subject to revision. The 2014-2019 data used here may differ from currently available QWI releases. Replication using current QWI data should be verified.

### Statistical Concerns

1. **Multiple comparisons**: The paper tests 9 industries plus the aggregate, plus 8 placebo windows, plus multiple bandwidth specifications. Even with FDR correction for industries, the overall false positive rate across all tests is unclear.

2. **Publication bias in robustness**: The robustness section reports 15+ specifications, all yielding insignificant results. This uniformity is suspicious - usually some specifications yield significant results by chance. Either the paper is engaging in selective reporting, or the true effect is so precisely zero that all specifications agree.

3. **Power analysis missing**: The paper does not report a formal power analysis. What is the minimum detectable effect (MDE) given the sample size and clustering structure? A null result is only informative if we know the study was powered to detect policy-relevant effects.

### Writing and Presentation

The paper is generally well-written but occasionally reads as defensive about the null result. Phrases like "ruling out large effects in either direction" frame a null as a success. More neutral framing would strengthen credibility.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Add power analysis**: Compute the MDE at 80% power given 8 clusters and observed variance. This would clarify whether the null is informative or simply reflects low power.

2. **Report all specifications**: If robustness checks were run that yielded different results, report them. The uniformity of results across 15+ specifications is unusual and should be verified.

3. **Verify QWI data**: Run the analysis with current QWI data releases to ensure results are robust to data revisions.

4. **Clarify DiDisc implementation**: Add explicit statement that the identifying variation comes from the change in the RDD estimate pre-to-post, not just from the DiD interaction alone.

5. **Acknowledge suppression limitations**: The null results in agriculture and retail may partly reflect suppression of small cells rather than true null effects. This should be stated more prominently.

---

## Summary

The paper presents a credible null result for aggregate labor market effects of marijuana legalization at state borders. However, several methodological concerns prevent strong conclusions:

1. The DiDisc implementation could be clarified
2. Power to detect policy-relevant effects is uncertain
3. Data suppression may bias industry-specific results toward null
4. The Information sector result is puzzling and potentially a false positive

The paper makes a contribution by providing quasi-experimental evidence where observational studies dominate, but should be more cautious in policy conclusions given the limitations.

**DECISION: MINOR REVISION**
