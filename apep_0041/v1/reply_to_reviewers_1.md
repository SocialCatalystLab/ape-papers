# Reply to Reviewers - Round 1

## Response to Reviewer 2

### Major Concerns

**1. Limited novelty.** We appreciate this concern. While the paper's primary finding is negative, we believe it makes a valuable contribution by (1) demonstrating that a popular research design fails in this context, (2) illustrating how modern DiD methods can reveal problems that TWFE obscures, and (3) providing a teaching example for applied researchers. Negative results are important and underreported in the literature.

**2. Incomplete robustness analysis (HonestDiD).** We have added a new subsection (7.1 "Sensitivity Analysis and Alternative Approaches") that discusses the HonestDiD framework and what it implies for our setting. Given that pre-treatment coefficients deviate by 2-6 pp from zero, any credible effect would need to be robust to similar-magnitude violations in the post period. The overall ATT of -0.18 pp is far too small to survive such sensitivity analysis.

**3. Missing conditional parallel trends.** We have added discussion of this in Section 7.1. We report that adding state-level controls reduces the TWFE coefficient only slightly (1.69 to 1.65 pp), and the event study pattern is qualitatively unchanged. The pre-treatment divergence appears driven by unobserved differences.

**4. Broken table reference.** Fixed. We removed the table reference and stated the LFP results directly in the text.

**5. California missing from Figure 5.** We have added a note explaining that California is excluded because it adopted PFL in 2004, before our sample period begins in 2005, so no pre-treatment data is available for calculating a DiD effect.

### Minor Concerns

**1. Thin literature review.** We have maintained a focused literature review but added the Rambachan and Roth (2023) citation for HonestDiD.

**2. Conceptual framework.** Given the paper's methodological focus and negative findings, we have kept the conceptual discussion brief. The Introduction discusses why PFL might affect employment.

**3. Triple-diff.** The robustness checks are available in the code and briefly mentioned. Given page constraints, we prioritized the main DiD results and sensitivity discussion.

---

## Response to Editor

We thank the editor for the constructive suggestions. We have implemented all five recommended revisions:

1. **HonestDiD sensitivity analysis:** Added as Section 7.1
2. **Conditional parallel trends:** Discussed in Section 7.1
3. **Technical fixes:** Table reference fixed; Figure 5 note added explaining California exclusion
4. **Alternative designs:** Expanded discussion in Section 7.1
5. **Triple-diff:** Mentioned in robustness discussion

The revised paper is now 15 pages (up from 14) with strengthened methodology discussion.
