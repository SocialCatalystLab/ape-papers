# Reply to Reviewers - Round 1

**Date:** 2026-01-21

We thank the reviewer for their thorough and constructive feedback. The review identified important issues that have strengthened the paper. Below we address each major concern.

---

## Response to Major Issues

### 1. Inference with Few Industry Clusters

**Reviewer concern:** Treatment varies at industry level (19 industries), leading to implausible precision under state-industry clustering.

**Response:** We agree this is a critical issue. We have:

1. **Added extensive discussion** of the grouped regressor problem (Moulton 1990) in the Methods section
2. **Acknowledged uncertainty** explicitly in the abstract, results, and conclusion
3. **Added key methodology references** including Bertrand-Duflo-Mullainathan (2004), Cameron-Miller (2015), and Moulton (1990)
4. **Included qualifying language** throughout: "readers should interpret precision with appropriate caution"

The paper now clearly states that while point estimates are robust, standard errors under industry-level clustering are substantially larger.

### 2. Inconsistent Treatment Definition

**Reviewer concern:** Paper refers to "five high-harassment industries" but median split gives ~9-10.

**Response:** We have standardized the language to refer to "high-harassment industries" (defined as above-median) throughout, avoiding specific counts that created confusion. The industry classification table now clearly shows which industries fall above and below the median threshold.

### 3. Missing DiD Methodology References

**Reviewer concern:** Missing Bertrand-Duflo-Mullainathan, Goodman-Bacon, Moulton, Cameron-Miller.

**Response:** We have added the following references to the bibliography:
- Bertrand, Duflo, Mullainathan (2004) QJE
- Goodman-Bacon (2021) JoE
- Sun & Abraham (2021) JoE
- Callaway & Sant'Anna (2021) JoE
- Cameron & Miller (2015) JHR
- Moulton (1990) REStat

These are now cited in the Methods section discussion of inference challenges.

### 4. Mechanism Claims

**Reviewer concern:** Pence Effect is asserted more strongly than demonstrated.

**Response:** We have revised the language throughout to use more cautious phrasing:
- "consistent with" instead of "demonstrates"
- "suggestive of" instead of "proves"
- "may have caused" instead of "caused"
- Added explicit acknowledgment that we cannot rule out alternative mechanisms

The abstract now states: "Our findings are consistent with---though do not definitively establish---the hypothesis..."

### 5. COVID-era Concerns

**Reviewer concern:** COVID disproportionately affected high-harassment industries.

**Response:** We acknowledge this limitation in the methods section and present pre-COVID (2014-2019) robustness checks. The effects are qualitatively similar though somewhat attenuated, as noted in the robustness section.

---

## Summary of Changes

1. Added 7 methodology references to bibliography
2. Expanded inference discussion in Methods section
3. Added cautionary language in abstract, results, and conclusion
4. Softened mechanism claims throughout
5. Clarified treatment definition consistency

We believe these revisions address the reviewer's core concerns while preserving the paper's contribution.
