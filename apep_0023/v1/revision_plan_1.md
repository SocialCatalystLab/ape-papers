# Revision Plan - Round 1

## Response to Internal Review

### Critical Issues (Must Address)

#### 1. Pre-Trends and Event Study Standard Errors
**Issue:** Event study shows "illustrative" CIs; 2014 coefficient raises pre-trend concerns.

**Plan:**
- Update `create_figures.py` to compute bootstrap standard errors for event study
- Add formal pre-trend test (joint F-test for 2013-2014 = 0)
- Revise Figure 2 with actual confidence intervals
- Add explicit discussion acknowledging 2014 coefficient concern
- Add robustness check excluding 2014

#### 2. Heterogeneity Confidence Intervals
**Issue:** Figure 3 has no uncertainty measures.

**Plan:**
- Update `create_figures.py` to add error bars to heterogeneity plot
- Add footnote with p-values for each subgroup

#### 3. Add Balance Table
**Issue:** No pre-treatment comparability assessment beyond Table 1.

**Plan:**
- Add Table showing pre-treatment means for Montana vs. control on key demographics
- Include standardized differences

### Moderate Issues

#### 4. Table Numbering
**Fix:** Change "Table 3" → "Table A1" and "Table 4" → "Table A2" in appendix

#### 5. Abstract Inconsistency
**Fix:** Change "prime-age adults (25-54)" to "older workers (55-64) and prime-age adults"

#### 6. Roadmap Mismatch
**Fix:** Update introduction to say "Section 5 presents results including robustness checks. Section 6 discusses..."

#### 7. Include Figure 4 (DiD Visualization)
**Plan:** Add Figure 4 to the paper after Figure 3

#### 8. Clarify Regression Weights
**Fix:** Add sentence to Methods: "All regressions are estimated using ACS person weights."

### Minor Issues

#### 9. Inference Caveats
**Fix:** Add paragraph to Section 6.3 discussing 4-cluster limitation more prominently

#### 10. Expansion Timing Discussion
**Fix:** Expand timing mismatch discussion in Section 6.3

---

## Implementation Order

1. Update `analyze_did.py` to compute bootstrap SEs for event study coefficients
2. Update `create_figures.py` to use computed SEs and add error bars
3. Regenerate figures
4. Edit paper.tex with all text fixes
5. Recompile PDF
6. Visual QA

---

## Files to Modify

- `data/analyze_did.py` - Add bootstrap SE computation
- `data/create_figures.py` - Use real SEs, add error bars to Fig 3
- `paper.tex` - Text edits, add Figure 4, fix tables
