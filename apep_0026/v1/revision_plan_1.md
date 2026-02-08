# Revision Plan: Round 1

**Date:** 2026-01-18

---

## Issues to Address

### Priority 1: Implement Now

1. **Add bandwidth sensitivity analysis** - Run with bandwidths of 1, 2, 3 years
2. **Cluster standard errors at state level** - Important for proper inference
3. **Improve figures** - Add confidence intervals, standardize y-axis scales

### Priority 2: Add to Paper

4. **Add power analysis discussion** - Calculate MDE given sample size
5. **Discuss control state medical marijuana status** - FL, OH, PA had medical
6. **Add limitation about age resolution** - Already partially discussed

### Priority 3: Note in Limitations (No New Analysis)

7. **Pre-period analysis** - Would require additional data fetch, note as limitation
8. **Drug testing industry validation** - Note as limitation/assumption

---

## Implementation

Will update the analysis code to:
1. Add bandwidth sensitivity
2. Cluster standard errors at state level
3. Improve figure quality

Will update paper to:
1. Add power analysis calculation
2. Expand control state discussion
3. Add bandwidth sensitivity table
