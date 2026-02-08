# Revision Plan

**Paper:** State Minimum Wage Increases and Business Establishments
**Date:** 2026-01-28
**Review Status:** REJECT AND RESUBMIT (all 3 reviewers)

---

## Summary of Reviewer Feedback

All three reviewers identified similar fundamental concerns:

### Critical Issues (Cannot Address Without New Data/Design)

1. **Outcome Mismatch:** CBP establishment counts measure stock, not formation/entry. Reviewers want BDS births/deaths data, which requires a different data source entirely.

2. **State-Level Aggregation Too Coarse:** Reviewers request county-level border-pair designs (Dube-Lester-Reich style), which requires completely rebuilding the analysis at county level.

3. **Treatment Estimand Mismatch:** Continuous treatment (log MW) in TWFE vs binary treatment (above federal) in Callaway-Sant'Anna.

### Issues Addressed in This Revision

1. **Treatment Timing Inconsistency:** Fixed the appendix state lists to match actual treatment_timing.csv data. Previously listed 17 states as "early adopters" but claimed 13; now correctly lists 13. Fixed Florida timing discrepancy.

2. **Missing Placeholder Citations:** Verified no "(??)" or "(?)" placeholders exist in paper.tex.

### Issues That Cannot Be Addressed

- Using BDS birth/death data instead of CBP stock - requires new data
- County-level border-pair designs - requires complete redesign
- Industry heterogeneity analysis - CBP industry data not fetched
- Wild cluster bootstrap inference
- Longer pre-period (extending back to 2000)

---

## Conclusion

The reviewers' core critique is that the research design is insufficient for the claims being made. The fundamental issues require:
1. Different outcome data (BDS instead of CBP)
2. Different geographic unit (county border pairs instead of states)
3. Different identification strategy

These changes constitute a complete research redesign rather than a revision. The paper documents a "precisely estimated null" on establishment stocks at the state level, which is a limited but accurate statement given the data and design.

The paper will be published with REJECT AND RESUBMIT status, acknowledging these limitations.
