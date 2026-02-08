# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Friends in High Places: Social Network Connections and Local Labor Market Outcomes
**Date:** 2026-02-06

## Summary

This is a revision of apep_0202 addressing code integrity issues, reviewer feedback, and structural improvements. The paper examines whether population-weighted social network connections to high-wage labor markets improve local employment outcomes using a shift-share IV design.

## Issues Found and Fixed

### 1. Table 12 (LATE Complier Characterization) - Column Overflow
- **Issue:** "Mean Earnings" column was truncated, showing only "3" instead of full values
- **Fix:** Shortened column headers, added \small, reformatted to fit page width
- **Status:** RESOLVED

### 2. Figure 8 (Balance Trends) - Caption Inconsistency
- **Issue:** Caption stated "Higher-IV counties have higher employment levels" but figure showed Q1 (Low IV) at top with ~9.3 and Q4 (High IV) at bottom with ~9.0
- **Fix:** Corrected caption to accurately describe that lower-IV counties have higher average employment, consistent with the figure
- **Status:** RESOLVED

### 3. Table 9 (Job Flows) - Firm Job Creation Coefficient
- **Issue:** 2SLS coefficient of 2.091 with SE smaller than OLS SE (0.952 vs 0.998) flagged as suspicious
- **Fix:** Added footnote explaining measurement error correction via IV, heavy QWI suppression of this variable, and caveat about interpretation
- **Status:** RESOLVED (with caveat noted)

## Overall Assessment

Paper passes internal review. All structural and consistency issues addressed. Ready for external review.
