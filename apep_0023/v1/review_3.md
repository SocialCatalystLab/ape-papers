# Internal Review - Round 3

**Paper:** Does Bundling Workforce Services with Medicaid Expansion Improve Employment Outcomes? Evidence from Montana's HELP-Link Program

**Reviewer:** Claude Code (Internal Adversarial Review)

**Date:** January 2026

**Round:** 3

---

## Overall Assessment

The paper has improved substantially through Rounds 1 and 2. The formal parallel trends test, improved figure captions, and expanded limitations section strengthen the contribution. However, several issues remain that merit attention before the paper is ready for publication.

---

## Major Issues

### 1. Expansion Timing Mismatch Deserves More Prominence

**Issue:** Control states expanded Medicaid in 2014, while Montana expanded in 2016. The paper mentions this in the limitations but understates the threat to identification.

**Concern:** By 2016, control states were 2 years into expansion while Montana was just starting. The near-eligible comparison group may not fully absorb this differential maturity effect because:
- Coverage take-up patterns differ in Year 1 vs Year 3 of expansion
- Behavioral responses to expansion may evolve over time
- Economic conditions in 2014-2015 vs 2016-2019 differed

**Recommendation:** Add a robustness check that restricts the post-period to 2016-2017 only (when control states were 2-3 years into expansion) to see if results are similar when timing is more comparable. Alternatively, discuss this limitation more prominently in the main text rather than just in limitations.

### 2. External Validity Concerns Inadequately Addressed

**Issue:** Montana is highly atypical: 81.2% White in the sample (vs ~60% nationally for this income group), rural, small population. The generalizability section is too brief.

**Recommendation:** Add explicit discussion of how Montana's demographics differ from the typical Medicaid expansion population and what this implies for external validity. Consider whether results might differ in states with different demographic compositions.

---

## Moderate Issues

### 3. Eligibility Threshold Notation Inconsistent

**Issue:** The paper inconsistently refers to the eligibility threshold as "<138% FPL" in some places and "at or below 138%" in others. The ACA threshold is technically ≤138% FPL.

**Locations:**
- Figure 1 legend: "(<138% FPL)" - incorrect, should be ≤
- Text Section 2.1: "at or below 138%" - correct
- Table 1 notes: "<138% FPL" - inconsistent

**Recommendation:** Standardize to "≤138% FPL" or "138% FPL or below" throughout.

### 4. Appendix Table Numbering Inconsistent

**Issue:** In the PDF, the robustness table is labeled "Table 3" and outcomes table is "Table 4" but the text refers to them as "Table A1" and "Table A2." The caption says "(Table A1)" but the actual table number is wrong.

**Recommendation:** Fix the LaTeX labeling to use proper appendix table numbering (Table A1, Table A2).

### 5. Sample Size Precision

**Issue:** The text says "approximately 122,000 person-year observations" but tables show exact count of 122,397.

**Recommendation:** Be consistent - either use the exact figure throughout or use "approximately" with a rounder number like "approximately 122,400."

### 6. Bootstrap P-values for Lower-Order Interactions

**Issue:** Table 2 notes report the bootstrap p-value for the main coefficient (0.024) but not for the lower-order interaction terms. With only 4 clusters, inference on all coefficients is uncertain.

**Recommendation:** Either report bootstrap p-values for all coefficients or add a note explaining why only the main coefficient is reported.

### 7. Figure 3 Visual Check

**Issue:** Need to verify the category labels (Age, Sex, Education, Disability) are fully visible and properly positioned in the actual PDF output.

**Recommendation:** Confirm labels appear correctly positioned and fully within the visible plot area.

---

## Minor Issues

### 8. Reference Formatting

**Issue:** Reference formatting is inconsistent. Some entries use "et al." in the bibliography while the actual entries spell out all authors.

### 9. R-squared Not Reported

**Issue:** Table 2 does not report R-squared or model fit statistics. While not essential, this is standard practice.

**Recommendation:** Add R-squared values to Table 2.

### 10. Percentage Consistency

**Issue:** Sometimes percentages use % symbol (e.g., "81.2%"), sometimes written as decimals in tables. While minor, consistency would improve readability.

---

## Summary of Required Changes

| Priority | Issue | Suggested Action |
|----------|-------|------------------|
| Major | Expansion timing mismatch | Add robustness check or expand discussion |
| Major | External validity | Expand discussion of Montana's atypicality |
| Moderate | Eligibility notation | Standardize to ≤138% FPL |
| Moderate | Appendix table numbers | Fix LaTeX labeling |
| Moderate | Sample size precision | Use consistent figure |
| Moderate | Bootstrap p-values | Report or explain |
| Moderate | Figure 3 labels | Verify visibility |
| Minor | Reference formatting | Standardize |
| Minor | R-squared | Consider adding |
| Minor | Percentage consistency | Standardize |

---

## Verdict

The paper is close to publication-ready. The two major issues (expansion timing and external validity) should be addressed through expanded discussion. The moderate issues are mostly minor fixes that can be resolved quickly.

**Recommendation:** Revise and proceed to Round 4.
