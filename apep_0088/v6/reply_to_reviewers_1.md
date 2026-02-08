# Reply to Reviewers

**Paper:** Does Local Climate Policy Build Demand for National Action? Evidence from Swiss Energy Referendums
**Revision of:** apep_0132

---

## Summary of Changes in This Revision

This revision addresses three issues from the previous version:

1. **RDD Figures:** All RDD figures now use the corrected sample construction (distance to own canton border). The "illustrative" pre-correction figures have been replaced with figures using the actual estimation sample.

2. **Event Study Removed:** The event study analysis has been removed from both the main text and appendix, as the staggered timing with only 5 treated cantons made it unreliable.

3. **Table Formatting:** Tables have been reformatted to fit page margins properly.

---

## Response to Referee Reviews

### Reviewer 1 (GPT-5-mini) - Major Revision

**Concern 1: Inferential fragility across methods**
- *Response:* We acknowledge the divergence between bias-corrected RDD CI (excludes zero), wild bootstrap p-value (0.058), and OLS permutation p-value (0.62). The paper now emphasizes this as suggestive evidence rather than definitive causal claims. The same-language RDD specification remains our preferred estimate because it addresses the Rostigraben confound directly.

**Concern 2: Placebo RDDs on corrected same-language sample**
- *Response:* The placebo tests in Table 15 show significant discontinuities for some unrelated referendums, which we acknowledge as a limitation. The same-language restriction mitigates but may not fully eliminate border heterogeneity. This is discussed in Section 7.

**Concern 3: Additional inference methods (Ibragimov-Muller, Conley SEs)**
- *Response:* These are valuable suggestions for future extensions. The current paper already employs wild cluster bootstrap and randomization inference to address few-cluster concerns.

### Reviewer 2 (Grok-4.1-Fast) - Major Revision

**Concern 1: Placebos indicate borders not quasi-random**
- *Response:* We agree this is an important caveat. The paper is transparent about these results (Table 15) and discusses them extensively in Section 6.5 and limitations.

**Concern 2: Municipality-level language shares**
- *Response:* A valuable suggestion for robustness. The current specification uses canton-level language classification, which we acknowledge as a limitation.

**Concern 3: Missing references (Cattaneo et al. 2021, etc.)**
- *Response:* Thank you for these suggestions. These references would strengthen future revisions.

### Reviewer 3 (Gemini-3-Flash) - Minor Revision

**Concern 1: Mechanism deep dive with installation data**
- *Response:* Excellent suggestion. Municipality-level solar/heat pump data would allow testing cost salience directly. This is noted as a direction for future research.

**Concern 2: Contextualizing the -5.9pp magnitude**
- *Response:* The paper discusses this in Section 7, noting that this magnitude is approximately one-third of the raw Rostigraben gap and represents a meaningful political effect.

---

## Conclusion

This revision addresses the specific issues identified in the previous version (RDD figures, event study removal, table formatting). The methodological concerns raised by reviewers regarding inferential fragility and placebo tests are acknowledged as important caveats to the causal interpretation, and the paper frames the findings as suggestive evidence consistent with negative policy feedback rather than definitive proof.
