# Advisor Review - GPT-5.2

**Role:** Academic advisor checking for fatal errors
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T23:02:13.481714
**Route:** OpenRouter + LaTeX
**Tokens:** 17505 in / 1568 out
**Response SHA256:** 46ba075ba51d1846

---

FATAL ERROR 1: Completeness  
  Location: Title page (`\author{... \and @CONTRIBUTOR_GITHUB}`) and Acknowledgements (“Contributors: @CONTRIBUTOR_GITHUB”, “First Contributor: https://github.com/FIRST_CONTRIBUTOR_GITHUB”)  
  Error: Placeholder strings (`@CONTRIBUTOR_GITHUB`, `FIRST_CONTRIBUTOR_GITHUB`) appear in the compiled manuscript. This is a hard “not-ready-for-journal” issue.  
  Fix: Replace with actual author/contributor identities (or remove these fields entirely). Recompile and visually verify the PDF contains no placeholder handles/URLs.

FATAL ERROR 2: Regression Sanity / Internal Consistency (incoherent p-values relative to reported coefficients and SEs)  
  Location: Table 4 “Main RDD Estimates” (`\label{tab:main_rdd}`), multiple rows  
  Error: Reported p-values do not match the coefficient/SE pairs shown in the same row. Example checks:
  - Row “Change in female non-ag share”: Estimate = 0.0021, Robust SE = 0.0043 ⇒ z ≈ 0.49, two-sided p ≈ 0.62 (not 0.444).  
  - Row “Change in male non-ag share”: −0.0013 / 0.0031 ⇒ z ≈ −0.42, p ≈ 0.67 (not 0.713).  
  - Row “Gender gap change (F - M)”: 0.0010 / 0.0035 ⇒ z ≈ 0.29, p ≈ 0.77 (not 0.826).  
  These discrepancies indicate the table is internally inconsistent (mixing outputs from different estimands, or copying the wrong p-values/SEs, or mislabeling “robust SE” vs the SE used for the p-value). A journal will desk-reject or the referee will immediately flag this as broken output.
  Fix: Re-export the regression output directly from `rdrobust` in a single pipeline so that (Estimate, SE, p-value) come from the same statistic. Ensure the p-values correspond to the displayed SE (same “robust bias-corrected” version). Then re-check mechanically that p ≈ 2·(1−Φ(|coef/SE|)) for the reported rows (allowing for minor rounding).

FATAL ERROR 3: Regression Sanity / Internal Consistency (Table 5 has mathematically impossible p-values given reported SEs)  
  Location: Table 5 “Robustness: Bandwidth and Polynomial Sensitivity” (`\label{tab:robustness}`), Panel A (Bandwidth)  
  Error: Several p-values are inconsistent with the displayed Estimate and Robust SE by large margins, e.g.:
  - “0.8× optimal (h = 87)”: 0.0048 / 0.0063 ⇒ z ≈ 0.76, p ≈ 0.45 (table reports p = 0.037).  
  - “1.0× optimal (h = 116)”: 0.0021 / 0.0055 ⇒ z ≈ 0.38, p ≈ 0.70 (table reports p = 0.088).  
  This is not a rounding issue; it indicates the column entries are not coming from the same regression output.
  Fix: Same as above—regenerate Table 5 from a single consistent extract. Also verify that the “Robust SE” column is the SE used for inference (and that you are not accidentally pairing “conventional” SE with “robust” p-values or vice versa).

FATAL ERROR 4: Internal Consistency (treatment-rule classification contradicts itself in the appendix)  
  Location: Data Appendix → “State Classification” (special-category states list)  
  Error: You define special-category states earlier as NE states + Himachal Pradesh + Jammu & Kashmir + Uttarakhand (threshold 250). In the appendix you additionally list “Bihar hill districts (10, for some phases)” as special-category. This is a major classification inconsistency because it affects which observations are assigned the 250 vs 500 cutoff and therefore affects sample construction (“Plain-area states only” vs “Special-category states”).  
  Fix: Decide and document one classification consistent with PMGSY guidelines *as implemented in your data*. If Bihar (state code 10) is not actually treated as special-category in your coding, remove it from the appendix. If some districts truly had a different threshold in certain phases, you must (i) show how you identify them in the data, (ii) adjust sample definitions accordingly, and (iii) ensure all tables/results reflect that rule.

ADVISOR VERDICT: FAIL