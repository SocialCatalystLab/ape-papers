# Reply to Reviewers - Round 3

**Date:** January 18, 2026

---

## Response to GPT 5.2

### Issue 1: RD Inference Not at Top-Journal Standard
**Response:** We acknowledge this limitation more explicitly. For a working paper, we use conventional local linear + HC1 SEs with extensive bandwidth sensitivity. We cite the relevant methodological literature (Calonico et al. 2014, Kolesár & Rothe 2018) and note that future research could implement rdrobust-style bias-corrected inference.

### Issue 2: Make Diff-in-Disc Primary Design
**Response:** We have elevated the diff-in-disc presentation in Table 6 to include formal estimates with standard errors. The text now explicitly notes this approach "identifies the Wisconsin-specific effect of the 100\% FPL Medicaid threshold net of any ACA subsidy discontinuity."

### Issue 3: Table 1 vs Figure 2 Medicaid Rate Discrepancy
**Response:** Added clarifying sentence: "Note that these full-sample Medicaid rates differ substantially from the rates shown in Figure 2, which restricts to individuals near the 100\% FPL threshold; Medicaid coverage rates are naturally higher among low-income individuals near the eligibility threshold than in the full working-age sample."

### Issue 4: Covariate Imbalance - Need Tables
**Response:** Added Table 7 showing covariate-controlled estimates. Results show Medicaid discontinuity attenuates slightly from -7.7 pp to -7.2 pp when controlling for gender, age, and education, but remains statistically significant. Employment estimates similarly robust.

### Issue 5: Missing Frean, Gruber, Sommers (2017)
**Response:** Added citation and cited in the Interpretation section on ACA subsidies mitigating the cliff.

---

## Response to Gemini 3 Pro

### Issue 1: Covariate Imbalance - Show Results (CRITICAL)
**Response:** Added new Section 6.4 "Robustness to Covariate Controls" with Table 7 showing baseline and covariate-adjusted estimates side by side. Concludes: "These results indicate that the covariate imbalance documented in Table 3, while concerning, does not drive the main findings."

### Issue 2: Diff-in-Disc Formalization
**Response:** Expanded Table 6 presentation with formal diff-in-disc estimates.

### Issue 3: Missing Frean et al. (2017)
**Response:** Added citation to bibliography and cited in Interpretation section.

---

Paper now 33 pages with 29 citations including Table 7 with covariate controls.
