# Internal Review - Round 2 (Revision Review)

**Reviewer:** Claude Code
**Date:** 2026-02-03
**Paper:** Shining Light on Paychecks (Revision of apep_0155)

## Summary

This is a polishing revision of apep_0155. The changes address:
1. Gemini advisor FAIL issues (2024 cohort labeling, R² explanation, table formatting)
2. Reviewer requests (wild bootstrap p-values in tables, trimmed repetition)
3. Additional references and robustness discussion

## Changes Verified

1. **Figure 1 caption:** Now explicitly notes NY/Hawaii contribute no post-treatment observations
2. **Table 2 notes:** Explains high R² (state+year FE on aggregates) and includes bootstrap p-values
3. **Table 8:** Reference period formatting fixed (0.000 (---) [Ref.])
4. **Table 3 notes:** Added wild bootstrap p-values for gender interaction
5. **Table 4 notes:** Added wild bootstrap p-values for bargaining heterogeneity
6. **Introduction:** Trimmed contribution section significantly (was 3 full paragraphs, now 3 sentences with pointer to Section 4.4)
7. **Threats section:** Added salary history bans as concurrent policy confounder
8. **Bibliography:** Added Bertrand et al. (2004), Roth et al. (2023), Bessen et al. (2020)
9. **Title footnote:** Revised to note this is revision of apep_0155

## Assessment

The paper now addresses the key issues that caused Gemini's advisor FAIL:
- 2024 cohort treatment clearly explained
- R² = 0.965 explained as natural for aggregated data with fixed effects
- Table 8 formatting cleaned up
- Internal consistency concern likely addressed (Table 2/3 use different specifications)

**RECOMMENDATION:** Ready for external review

## Remaining Minor Issues

None blocking publication. The paper is 39 pages, well above the 25-page minimum.
