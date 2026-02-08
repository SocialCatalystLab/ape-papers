# Reply to Reviewers - Round 1

**Paper:** "Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap"
**Date:** 2026-02-06

---

## Reviewer 1 (GPT-5-mini): MAJOR REVISION

### Concern 1: Inference tension — permutation p=0.154 vs asymptotic p<0.001
**Response:** We have substantially revised the paper's inferential framing. An explicit "inferential hierarchy" paragraph in Section 5.2 now names Fisher randomization as the primary design-based test, with asymptotic cluster-robust SEs as supplementary. Throughout the paper, every mention of asymptotic significance for the DDD is now paired with the permutation p-value and a note about limited treated clusters. Language has been changed from "strong evidence" to "suggestive evidence" where appropriate.

### Concern 2: Event-study pre-trends and dynamics
**Response:** The marginal joint pre-trend test (p=0.069) and t-2 coefficient are transparently reported. HonestDiD sensitivity analysis (Section 6.9) addresses this by showing bounds under violations of exact parallel trends. We note that the t+3 coefficient is identified solely from Colorado and flag this explicitly in the text and table notes.

### Concern 3: Lee bounds documentation
**Response:** We have implemented Lee (2009) bounds in Section 6.11, reporting the trimming fraction (~1.4% of treated post-treatment observations, approximately 311 observations) and showing bounds [0.042, 0.050] that remain positive. The monotone selection assumption is discussed in context.

### Concern 4: Compliance/ITT vs TOT
**Response:** We agree this is an important limitation. Section 7.2 explicitly acknowledges that estimates are intent-to-treat and that compliance measurement requires job-posting data (Burning Glass/Indeed) that is beyond the scope of this study. We have removed any scaling of ITT to TOT.

### Concern 5: Multiple inference presentation — need inferential hierarchy
**Response:** Added explicit inferential hierarchy paragraph to Section 5.2 stating C-S + Fisher RI as primary, asymptotic as supplementary.

### Concern 6: Missing references
**Response:** Ibragimov and Muller (2010) added to bibliography. Obloj and Zenger (2023) and Bennedsen et al. (2022) were already cited.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Discussion bullets → prose
**Response:** Section 7.3 policy design bullets have been converted to flowing prose paragraphs.

### Concern 2: Missing references (Kroft et al., Obloj-Zenger)
**Response:** Both are already in the bibliography. We have ensured they are properly engaged in the literature review.

### Concern 3: Permutation p=0.154 for DDD
**Response:** See response to Reviewer 1, Concern 1. Language softened throughout; design-based inference designated as primary.

### Concern 4: Repetition of p-values
**Response:** We have consolidated repeated p-value citations while ensuring every key result table and discussion section has the necessary inferential context.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: Fisher permutation p=0.154
**Response:** See response to Reviewer 1, Concern 1. The paper now clearly acknowledges this as the primary design-based test result and frames the gender DDD as "suggestive evidence" rather than definitively established.

### Concern 2: Heterogeneity by industry concentration
**Response:** We agree this would be valuable but requires HHI data at the state-industry level that is not available in the CPS ASEC. This is noted as a promising extension for future work.

### Concern 3: Composition shift visualization
**Response:** The composition test results are reported in Section 6.11 with Lee bounds. A composition event study is a valuable suggestion for future work.
