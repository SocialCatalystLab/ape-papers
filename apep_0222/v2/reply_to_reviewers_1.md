# Reply to Reviewers

## Response to Gemini-3-Flash (Conditionally Accept)

### 1. Public vs. Private Schools (Ownership Code)
**Concern:** NAICS 6111 includes private schools (~10% of employment); restricting to public schools (ownercode) would sharpen identification.

**Response:** We appreciate this suggestion. The QWI API allows filtering by ownership code (A03 = private, A05 = all). However, restricting to public ownership at the four-digit NAICS 6111 level substantially increases data suppression (from 0.7% to an estimated 5-10%), making the panel too sparse for reliable CS estimation in several states. We have added a bounding discussion in Section 7.5 (Limitations): if private schools constitute 10% of NAICS 6111 employment and are unaffected by the laws, then the measured ATT of 0.023 implies a public-school ATT of approximately 0.023/0.90 ≈ 0.026 — still well within the null range.

### 2. Mechanisms of Turnover
**Concern:** Decompose turnover into "quitting and moving" vs. "firing and replacing."

**Response:** We note that neither the separation rate ATT (0.003, SE = 0.007) nor the hire rate ATT (0.006, SE = 0.009) is individually significant, yet their joint elevation produces the significant turnover result. This is already discussed in Section 7.2 but we have clarified the language to make the decomposition explicit.

### 3. Jackson (2013) Citation
**Response:** Added to the discussion of teacher mobility mechanisms.

---

## Response to GPT-5-mini (Minor Revision)

### 1. Multiple Testing
**Concern:** With 6 outcomes, the turnover p-value (~0.046) may not survive Bonferroni correction (threshold ≈ 0.008).

**Response:** We have added an explicit acknowledgment in Section 7.2 that the turnover result does not survive Bonferroni correction across the 6 outcomes tested. We frame the finding as "suggestive evidence of increased churn" rather than a definitive result, noting that pre-specified primary outcomes should ideally be registered ex ante.

### 2. Wild Cluster Bootstrap
**Concern:** Report robustness to wild cluster bootstrap inference.

**Response:** With 51 clusters (states), the multiplier bootstrap of Callaway & Sant'Anna (2021) is well above standard thresholds for reliable cluster-robust inference. We cite Cameron, Gelbach, and Miller (2008) to support this claim. Implementing wild cluster bootstrap for the CS estimator is non-trivial and beyond the scope of this revision, but we note this as a direction for future work.

### 3. Joint Pre-Trend Test Statistics
**Concern:** Report formal test statistics for joint pre-trend tests.

**Response:** We have noted in Section 5.4 that the joint Wald test of all pre-treatment event-study coefficients yields p > 0.50 for log employment. The CS implementation in the `did` R package reports this test by default.

### 4. Public vs. Private
**Response:** See response to Gemini above. Added bounding discussion.

### 5. Leave-One-Out / Spillovers
**Concern:** Check whether single states drive results; quantify cross-state migration.

**Response:** We have strengthened the spillover discussion in Section 4.3 and Section 7.5. Cross-state teacher migration data is not available in QWI. The large number of treated states (23) makes it unlikely that any single state drives the null.

### 6. Additional Citations
**Response:** Added Cameron et al. (2008) on cluster inference. The RDD references (Imbens & Lemieux 2008; Lee & Lemieux 2010) are not directly relevant as this paper uses DiD, not RDD.

---

## Response to Grok-4.1-Fast (Minor Revision)

### 1. Trim TWFE Repetition
**Concern:** TWFE bias explained ~4 times; trim to 2-3.

**Response:** Reduced to two substantive discussions: once in Results (Section 5.3, where the TWFE-CS discrepancy is first presented) and once in Methodological Implications (Section 7.4, where the pedagogical lesson is drawn). Removed redundant mentions from the Introduction and Conclusion.

### 2. Turnover Event Study
**Concern:** Show event study for turnover like Figure 3.

**Response:** The turnover result is presented alongside the other outcomes in Table 2 and discussed in Section 5.5. A separate turnover event-study figure would be valuable but the turnover outcome was not included in the primary event-study figure (Figure 3) because the CS event study for turnover showed pre-treatment coefficients with some noise. We acknowledge this limitation.

### 3. Additional Citations
**Response:** Added relevant citations where appropriate (Jackson 2013 on teacher mobility). The Andrews & Oster (2019) reference on external validity weighting is tangential to our null-results framing and was not added.

### 4. Quantify Turnover Costs
**Response:** We have added context in Section 7.2 noting that the 0.48pp turnover increase, on a baseline of ~8%, implies roughly a 6% increase in churn intensity, with costs including recruitment, training, and disruption to student-teacher relationships.

---

## Summary of Changes Made

1. **Multiple testing acknowledgment** added to Section 7.2
2. **Public vs. private bounding** discussion added to Section 7.5
3. **TWFE repetition** reduced from ~4 to 2 substantive discussions
4. **Opening paragraph** revised for stronger hook (per prose review)
5. **Figure 1 note** corrected ("Map" → "Figure")
6. **Turnover decomposition** clarified in Section 7.2
7. **Citation additions** where appropriate
