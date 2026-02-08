# Internal Review Round 1 - Paper 67

**Paper Title:** Aging Out of Dependent Coverage at 26 and Fertility: A Regression Discontinuity Analysis with Inconclusive Results

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-22

---

## Referee Report (Reviewer 2 Style)

### Summary

This paper examines whether losing health insurance eligibility at age 26 affects fertility among young women, using an RDD design with ACS data. The paper finds a strong first stage (4pp drop in private coverage) but ultimately concludes the RDD is invalid for fertility because marriage rates show a discontinuity at age 26.

### Major Concerns

**1. The paper's central finding undermines its own research design.**

The entire premise of conducting an RDD at age 26 for fertility rests on the assumption that potential outcomes are continuous at the threshold. The paper acknowledges this assumption fails (via the marriage balance test) but proceeds to report reduced-form estimates anyway. If the design is invalid, these estimates have no causal interpretation and should not be emphasized. The current structure buries the invalidity finding in Section 7.3, after already presenting "results" that readers may misinterpret as causal.

*Recommendation:* Restructure the paper to lead with the invalidity finding. The contribution is methodological (demonstrating when RDD fails), not substantive.

**2. Limited novelty in the invalidity finding itself.**

The fact that life-course transitions cluster around milestone ages is well-known. Marriage rates increase monotonically through the 20s, and any discrete measurement of age will show "jumps" due to binning. Is this really a discontinuity, or is it an artifact of measuring age in years? The paper doesn't adequately distinguish between:
- A true discontinuity in the latent marriage propensity at age 26
- A measurement artifact from binning a continuous variable

The balance test may be overpowered given the sample size (1.5M observations). A 5.6pp difference could reflect smooth underlying trends poorly captured by the discrete running variable.

**3. The placebo tests raise questions the paper doesn't address.**

The significant "effect" at age 27 is noted but not explained. If age 27 shows a larger discontinuity than age 26, what does this imply about the pattern? Is there something special about 27? The paper mentions this as a "concern" but doesn't investigate further.

**4. Heterogeneity analysis is descriptive, not causal.**

The stratified analysis by marital status cannot identify causal effects because marital status is endogenous to age. Women who are married at 25 vs. 26 differ in unobserved ways. The comparison conflates selection effects with treatment effects.

**5. Missing discussion of fuzzy RDD approach.**

If the first stage is strong but the design is confounded, a fuzzy RDD or instrumental variables approach might address the confounding. The paper dismisses the design entirely without exploring whether marriage could be controlled for or instrumented.

### Minor Concerns

1. The literature review is comprehensive but lacks a clear statement of the paper's contribution relative to Abramowitz (2016), who used a different design to study a similar question.

2. Table 3 shows bandwidth sensitivity, but the estimates are remarkably stable across very different bandwidths (2-5 years), which is unusual for RDD. This stability may indicate the "effect" is driven by broad trends rather than local discontinuities.

3. The paper mentions Title X clinics as alternative contraception sources but doesn't discuss the Trump administration's 2019 Title X rule changes that may have affected access during the sample period.

4. No power calculations are provided. Given the null findings within subgroups, is the study adequately powered to detect plausible effect sizes?

---

## Editor's Assessment

### Strengths

1. **Honest reporting of design failure.** Many papers would have stopped at the significant reduced-form estimate and ignored the balance test failures. This paper's transparency about the invalidity is commendable.

2. **Clear exposition.** The writing is generally clear, and the institutional background is well-explained.

3. **Comprehensive validity testing.** The paper conducts balance tests, placebo tests, and heterogeneity analysis - the full suite of RDD diagnostics.

4. **Policy relevance.** Understanding the relationship between insurance and fertility is genuinely important.

### Recommended Revisions

1. **Reframe the paper.** The current framing suggests this is a paper about insurance and fertility that encounters a methodological problem. Reframe it as a methodological paper about RDD validity that uses the insurance-fertility question as a case study.

2. **Address the overpowering concern.** With 1.5M observations, tiny imbalances become statistically significant. Discuss whether the marriage discontinuity is economically meaningful or just statistically detectable.

3. **Explore robustness to controlling for marriage.** Even if the design is invalid, showing what happens when you control for marriage (understanding it's not causal) would be informative.

4. **Add a formal density test.** While standard McCrary tests don't apply to discrete running variables, discuss the density of the running variable more formally.

5. **Expand the placebo analysis.** The significant effect at age 27 deserves more attention. Plot all placebo estimates with confidence intervals to visualize the pattern.

6. **Add power analysis.** Calculate the minimum detectable effect given sample sizes in the stratified analysis.

### Verdict: **Major Revision**

The paper has a valid contribution - demonstrating that age 26 is not a suitable RDD cutoff for fertility research - but the current framing and structure obscure this contribution. With substantial revision focusing on the methodological lesson rather than the failed causal question, this could be a useful cautionary paper for applied researchers.
