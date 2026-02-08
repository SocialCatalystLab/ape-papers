# Internal Review - Round 2

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-29
**Paper:** Click It or Ticket at the Border: A Spatial RDD Analysis

## Summary

Following Round 1 revisions, the paper now clearly frames itself as a methodological case study demonstrating challenges in spatial RDD at multi-state borders. The fundamental running variable issue remains (as expected - would require complete re-implementation), but is now clearly documented as a design limitation.

## Revisions Made

1. Abstract rewritten to frame as cautionary case study
2. State counts corrected (34 + DC primary, 15 secondary)
3. Figure 1 legend updated to match 2019 analysis period
4. Table 5 (placebo) now includes N column
5. Covariate balance table added to appendix
6. Donut RD and specification robustness tables added
7. "Persons per crash" imbalance now acknowledged in validity section
8. FARS estimand clarified throughout

## Remaining Issues

The running variable construction issue is fundamental and would require rebuilding the distance computation to use actual border segments rather than state polygons. The paper now explicitly acknowledges this as a methodological flaw.

## Assessment

The paper is publishable as a methodological contribution documenting spatial RDD challenges. The null finding is honestly presented with all validity test failures disclosed.

## Statistical Methodology
- All coefficients have proper SEs
- 95% CIs reported for main results
- Sample sizes reported throughout
- McCrary and placebo tests conducted
- Bandwidth sensitivity shown

DECISION: MINOR REVISION
