# Revision Plan: Round 1

## Paper 70: Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid?

**Based on:** Internal Review (review_cc_1.md)
**Verdict:** MINOR REVISION

---

## Issues to Address

### Major Issues

1. **Data Year Inconsistency** (Priority: HIGH)
   - Issue: Abstract says 2023; introduction says 2016-2023
   - Action: Clarify that analysis uses 2023 only (consistent with actual data)
   - Status: COMPLETED

2. **Missing Figures and Tables** (Priority: HIGH)
   - Issue: All figure/table references showed "??"
   - Action: Add \includegraphics for all figures; create and include LaTeX tables
   - Status: COMPLETED (7 figures, 5 tables now included)

3. **Missing Citations** (Priority: HIGH)
   - Issue: Several citations appeared as "?"
   - Action: Add all missing bibliography entries
   - Status: COMPLETED

4. **Covariate Imbalance Discussion** (Priority: MEDIUM)
   - Issue: College education discontinuity not adequately explained
   - Action: Expanded discussion of why imbalance exists and why covariate-adjusted estimates are reassuring
   - Status: COMPLETED

5. **Placebo Test Interpretation** (Priority: MEDIUM)
   - Issue: Placebo effects at ages 24 and 27 need stronger interpretation
   - Action: Added Figure 6 showing all cutoffs; expanded discussion of sign reversal at age 26
   - Status: COMPLETED

6. **Econometric Methodology Clarification** (Priority: MEDIUM)
   - Issue: Paper cited rdrobust but used parametric approach
   - Action: Updated methods section to accurately describe fixest implementation
   - Status: COMPLETED

### Minor Issues

7. **Bandwidth Sensitivity Figure**
   - Issue: fig:bandwidth was undefined
   - Action: Created and added Figure 7 showing bandwidth sensitivity
   - Status: COMPLETED

8. **Health Outcomes Table Reference**
   - Issue: tab:health was undefined
   - Action: Redirected to main results table (Table 2)
   - Status: COMPLETED

---

## Files Modified

- `paper.tex` - Main paper with all revisions
- `code/07_placebo_figure.R` - New script for placebo cutoff visualization
- `code/08_tables.R` - New script for LaTeX table generation
- `code/09_bandwidth_figure.R` - New script for bandwidth sensitivity figure

## New Figures Added

1. `figure6_placebo_cutoffs.pdf` - RD estimates at all cutoffs
2. `figure7_bandwidth.pdf` - Bandwidth sensitivity analysis

## New Tables Added

1. `table1_summary.tex` - Summary statistics by age group
2. `table2_main.tex` - Main RDD results
3. `table3_balance.tex` - Covariate balance tests
4. `table4_placebo.tex` - Placebo cutoff tests
5. `table5_heterogeneity.tex` - Heterogeneity by marital status

---

## Paper Statistics After Revision

- Pages: 23
- Figures: 7
- Tables: 5
- References: ~30

## Ready for External Review

All major and minor issues from internal review have been addressed.
