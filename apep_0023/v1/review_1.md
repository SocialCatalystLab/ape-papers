# Internal Review - Round 1
## Montana HELP-Link Paper

**Reviewer:** Claude Code (Internal Adversarial Review)
**Date:** January 2026
**Overall Assessment:** Major Revisions Required

---

### Summary

This paper examines whether Montana's HELP-Link workforce program, bundled with Medicaid expansion, improved employment outcomes. The research question is policy-relevant and the triple-difference design is appropriate. However, several methodological and presentation issues require attention before the paper meets publication standards.

---

## Major Issues

### 1. Pre-Trends Violation is More Serious Than Acknowledged (Critical)

The 2014 event-study coefficient of 0.16 is **larger than several post-treatment coefficients** (2017: 0.117, 2019: 0.092). This pattern—where the largest "effect" occurs *before* treatment—fundamentally undermines the parallel trends assumption. The paper dismisses this too casually as "possible anticipation effects."

**Required:**
- Conduct formal pre-trend tests
- Report whether the 2014 coefficient is statistically different from zero
- If pre-trends are violated, the main results may be biased; this needs frank discussion

### 2. Event Study Lacks Valid Standard Errors (Critical)

The event study figure shows "illustrative" confidence bands of ±0.05. These are not computed standard errors—they appear to be arbitrarily chosen. This is methodologically unacceptable.

**Required:**
- Compute actual standard errors for event-study coefficients using wild cluster bootstrap
- Report whether pre-period coefficients are jointly insignificant
- If bootstrap cannot produce reliable SEs with 4 clusters, acknowledge this limitation prominently

### 3. Statistical Inference with 4 Clusters (Serious)

Wild cluster bootstrap with 4 clusters is at the edge of acceptable practice. Cameron et al. (2008) recommend at least 6-8 clusters for reliable inference. The paper claims significance but doesn't adequately convey uncertainty.

**Required:**
- Report randomization inference p-values as an alternative
- Consider aggregating to state-year level and using permutation tests
- Add more prominent caveats about inference limitations

### 4. Control State Expansion Timing Mismatch (Serious)

Control states expanded Medicaid in 2014; Montana in 2016. By 2016-2019, control states had 2-4 years of expansion "maturity." Employment effects of Medicaid expansion may evolve over time, confounding the comparison.

**Required:**
- Discuss how expansion maturity could affect results
- Consider specification using only 2014-2016 data where timing is more comparable
- Address whether control state trends stabilized by 2016

### 5. Heterogeneity Analysis Missing Uncertainty Measures (Serious)

Figure 3 shows point estimates only. Without confidence intervals, readers cannot assess whether heterogeneous effects are statistically distinguishable from zero or from each other.

**Required:**
- Add confidence intervals to Figure 3
- Report p-values for each subgroup estimate
- Test whether subgroup differences are statistically significant

---

## Moderate Issues

### 6. Missing Figure (DiD Visualization)

The create_figures.py script generates 4 figures, but Figure 4 (did_visualization.png) is not included in the paper. This figure would help readers visualize the triple-difference mechanics.

### 7. Table Numbering Error in Appendix

The text references "Table A1" and "Table A2" but the tables are numbered "Table 3" and "Table 4."

### 8. Roadmap-Content Mismatch

The introduction states "Section 6 discusses robustness checks and threats to identification" but robustness checks appear in Section 5.4, not Section 6.

### 9. Abstract Inconsistency

The abstract says effects are "concentrated among prime-age adults (25-54)" but the heterogeneity analysis shows the largest effect for ages 55-64 (0.116 vs 0.041).

### 10. Missing Balance Table

No table compares Montana vs. control states on pre-treatment characteristics beyond employment rates. Readers need to assess baseline comparability.

### 11. Sample Weights in Regressions

Descriptive statistics use ACS weights, but it's unclear whether the regressions are weighted. This should be stated explicitly.

---

## Minor Issues

1. **References formatting:** Uses description list instead of standard bibliography format
2. **Missing data availability statement**
3. **No discussion of SUTVA violations** (potential spillovers between eligibility groups)
4. **Power analysis missing** given small Montana sample (n ≈ 11,500)
5. **Figure 3 label alignment:** "Education" and "Disability" group labels appear misaligned

---

## Recommendations

### Must Fix Before Resubmission:
1. Compute real standard errors for event study
2. Add formal pre-trend tests
3. Add confidence intervals to heterogeneity figure
4. Fix table numbering
5. Add balance table
6. Fix abstract inconsistency

### Strongly Recommended:
1. Include Figure 4 (DiD visualization)
2. Add randomization inference as robustness
3. Discuss expansion timing mismatch more thoroughly
4. Add explicit statement on regression weights

### Optional Improvements:
1. Reformat references with natbib/bibtex
2. Add data availability statement
3. Discuss SUTVA
4. Add power analysis

---

## Decision

**Major Revision.** The pre-trends concern and missing standard errors on the event study are the most critical issues. The core finding may be valid, but the paper needs to address these methodological concerns transparently.
