# Revision Plan - Round 1

**Responding to:** Internal Review (review_cc_1.md)
**Date:** January 2026

---

## Critical Issues

### 1. Add Event Study to Paper

**Task:** Include fig3_event_study.png in the Results section and add interpretation.

**Implementation:**
- Add new subsection 5.3.5 "Event Study Analysis" after "Main Difference-in-Differences Results"
- Include Figure 3 (event study plot)
- Discuss pre-treatment coefficients (should be near zero)
- Interpret post-treatment dynamic effects

### 2. Add Robustness Checks Section

**Task:** Either deliver promised robustness checks or remove unsupported claims.

**Implementation:**
- Add new subsection 5.6 "Robustness Checks"
- Test 1: Drop Idaho (fastest-growing control state)
- Test 2: Use alternative treatment date (March 2025)
- Report results in a summary table
- Update Section 4.2 text to accurately reflect what robustness checks exist

### 3. Implement Wild Cluster Bootstrap

**Task:** Report bootstrap p-values given small number of clusters.

**Implementation:**
- Update analysis code to compute wild cluster bootstrap
- Report in main results table
- Add footnote explaining the method

---

## Moderate Issues

### 4. Standardize Pronouns

**Task:** Change "I" to "this study/paper" throughout.

**Implementation:** Find-and-replace with careful manual review for natural language flow.

### 5. Add Confidence Interval to Table 2

**Task:** Show 95% CI bounds in regression table.

**Implementation:** Add row to Table 2 with CI.

### 6. Run Full Heterogeneity Regressions

**Task:** Replace simple DiD with regression-based estimates for single-family and multi-family.

**Implementation:**
- Update analysis code to run separate regressions
- Replace Table 3 with regression results
- Add standard errors

---

## Minor Issues

### 7. Clarify Table 1 Column Labels

**Task:** Rename columns for clarity.

### 8. Add JEL Code R14

**Task:** Add to abstract.

---

## Implementation Order

1. Update analysis code (02_analysis.py) to add:
   - Wild cluster bootstrap
   - Robustness checks (drop Idaho, alternative treatment date)
   - Heterogeneity regressions with SEs

2. Re-run analysis to generate new results

3. Update paper.tex:
   - Add event study section and figure
   - Add robustness section
   - Update tables with new results
   - Fix pronouns
   - Minor label fixes

4. Recompile PDF and visual QA

5. Write reply to reviewers
