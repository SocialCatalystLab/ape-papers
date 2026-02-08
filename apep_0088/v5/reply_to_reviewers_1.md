# Reply to Reviewers - Revision 1

## Summary

This revision of apep_0125 is a **structural revision only**, focused on streamlining the main text by moving non-essential exhibits to the appendix. We appreciate the reviewers' detailed feedback and have addressed presentation issues. Substantive concerns about identification (placebo tests, mechanisms) would require additional analysis beyond this structural revision.

---

## Response to GPT-5-mini

### Concern 1: Structural organization
> "Consider consolidating diagnostic figures in appendix"

**Response:** Implemented. Moved all RDD diagnostic figures (McCrary test, covariate balance, bandwidth sensitivity, donut RDD, randomization inference) to new Appendix section B.1 "RDD Diagnostics". Added explicit cross-references from main text.

### Concern 2: Figure clarity
> "Some figure captions could be more explicit"

**Response:** Updated Figure 5 caption to clearly distinguish pre-correction (illustrative) vs corrected (primary) sample results. Updated Table 5 notes to explicitly label "Conventional SE" vs "Robust p-value" vs "Bias-corrected CI".

---

## Response to Grok-4.1-Fast

### Concern 1: Missing reference
> "Add Grembi et al. (2016) for Difference-in-Discontinuities"

**Response:** Added citation to bibliography and referenced in DiDisc section.

### Concern 2: Placebo interpretation
> "Same-language placebos needed to address border confounds"

**Response:** This requires additional analysis beyond structural revision. Noted for future work.

---

## Response to Gemini-3-Flash

### Concern 1: Table presentation
> "Raw difference (+6.9) vs causal estimate (-5.9) may confuse readers"

**Response:** Added explicit note in Table 7 explaining that the positive raw gap is "descriptive only and reflects selection—treated cantons are more urban and progressive." Clarified that unweighted canton averages differ from population-weighted national average.

### Concern 2: SE/CI alignment
> "CI width doesn't match 1.96×SE"

**Response:** Restructured Table 5 with explicit column labels: "Conv. SE", "Robust p", "95% CI (BC)" with detailed notes explaining that bias-corrected CIs use different effective SEs per Calonico et al. (2014).

---

## Changes NOT Made (Deferred to Future Revisions)

1. **Same-language placebo tests** - Requires new analysis
2. **Individual-level mechanisms survey** - Requires new data collection
3. **Triple-difference with Corporate Tax** - Requires additional specification
4. **Border-pair fixed effects in RDD** - Requires re-estimation

These substantive improvements are beyond the scope of this structural revision.
