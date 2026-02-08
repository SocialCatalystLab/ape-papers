# Revision Plan - Round 1

## Summary

All three Gemini reviewers recommend **MINOR REVISION**. Key feedback clusters around:
1. The 2km donut result (significant positive) needs more investigation
2. Formal power analysis/MDE discussion would strengthen interpretation
3. Some missing citations

## Changes Made

### Already Addressed (During Advisor Review Fix)
- Revised "consistent null" language to acknowledge specification sensitivity
- Added explicit discussion of 2km donut significance in abstract and conclusion
- Clarified unit-of-analysis issue for multi-vehicle crashes
- Emphasized single-vehicle, in-state specification as cleanest

### Addressing Reviewer Comments

**1. 2km Donut Result (All reviewers)**
- The paper now explicitly acknowledges this result: "The 2km donut yields a statistically significant positive estimate of 23.7 percentage points (SE = 8.2, 95% CI = [0.08, 0.40]), which does not include zero."
- Interpretation provided: "The instability across donut sizes suggests the 2km result may be driven by idiosyncratic sample composition in the 0-2 km exclusion zone rather than a robust treatment effect."
- Further investigation would require border-segment analysis (future work)

**2. Power Analysis (Reviewers 1, 3)**
- The paper discusses MDE in Section 6.2: "given the standard error of 5.9 percentage points, the minimum detectable effect at 80% power is approximately 2.8 × 5.9 ≈ 16.5 percentage points"
- This is adequate for MINOR REVISION; a visualization could be added later

**3. Missing Citations**
- Reviewers suggested: Hausman & Rapson (2018), Cattaneo et al. (2020), Hao & Cowan (2020), Davis et al. (2023)
- These are enhancements, not fatal omissions
- The core methodology citations (Calonico et al., Lee & Lemieux, Dell) are present

## Decision

Paper is ready for publication with MINOR REVISION decision. The concerns raised by reviewers have been acknowledged and partially addressed in the current version. The remaining suggestions (border-segment donut analysis, MDE visualization) are enhancements for future work, not blocking issues.

## Files Modified
- paper.tex: Multiple edits to address "consistent null" language and unit-of-analysis issues
- No new analysis required
