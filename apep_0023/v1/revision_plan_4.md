# Revision Plan - Round 4

## Issues to Address

### Moderate Issues

1. **Figure Legend Inconsistency** - Update figure generation to use "≤138% FPL" instead of "<138% FPL" to match standardized text notation. Regenerate all affected figures.

2. **Event Study Caption Clarification** - Fix the misleading "28 state-year clusters" language. Should clarify that clustering is at state level (4 clusters), not state-year level.

3. **Heterogeneity Figure Label Fix** - Fix the "Age 25-54" label that renders incorrectly as "Age 25♣04" or similar.

### Minor Issues

4. **Table A2 Notes** - Add clarification that hours worked control mean is weekly hours among employed.

5. **SUTVA Mention** - Add brief mention of SUTVA assumption in limitations.

6. **Baicker Reference** - Fix "et al." in reference list.

## Implementation Plan

1. Update Python figure generation scripts to use "≤138% FPL" notation
2. Regenerate employment_trends.png, did_visualization.png, heterogeneity.png
3. Edit paper.tex:
   - Fix event study figure caption
   - Add SUTVA mention to limitations
   - Expand Table A2 notes
   - Fix Baicker reference
4. Recompile PDF
5. Visual QA
6. Write reply to reviewers
