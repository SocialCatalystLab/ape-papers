# Revision Plan - Round 3

## Issues to Address

### Major Issues

1. **Expansion Timing Mismatch** - Add more prominent discussion of how the 2014 vs 2016 expansion timing difference could affect interpretation. Add text noting this concern more explicitly in the methodology section.

2. **External Validity Discussion** - Expand the generalizability caveat to explicitly note Montana's demographic atypicality (81% White, rural) and implications for external validity.

### Moderate Issues

3. **Eligibility Threshold Notation** - Standardize to "≤138% FPL" or "<138% FPL" consistently throughout (the ACA uses ≤138%).

4. **Appendix Table Numbering** - Fix LaTeX labels so appendix tables display as "Table A1" and "Table A2" rather than "Table 3" and "Table 4".

5. **Sample Size Precision** - Change "approximately 122,000" to exact figure "122,397" for consistency with tables.

6. **Bootstrap P-values** - Add note to Table 2 explaining that bootstrap inference is reported for the main coefficient only due to its primary importance.

7. **Figure 3 Labels** - Verify label positioning is correct (this was fixed in Round 2, confirm in PDF).

### Minor Issues

8. **R-squared** - Add R-squared values to Table 2.

9. **Reference Formatting** - Already consistent with description style, no change needed.

10. **Percentage Consistency** - Tables use decimals (0.498), text uses percentages (49.8%). This is acceptable convention, no change needed.

## Implementation Plan

1. Edit paper.tex:
   - Add paragraph in Section 4.2.1 discussing expansion timing mismatch
   - Expand external validity discussion in Section 6.2
   - Standardize eligibility notation
   - Fix appendix table labels
   - Update sample size text
   - Add R-squared to Table 2
   - Add clarification about bootstrap p-values

2. Recompile PDF

3. Visual QA

4. Write reply to reviewers
