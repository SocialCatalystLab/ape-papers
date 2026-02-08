# Internal Review Round 1

**Reviewer:** Claude Code (self-review during revision)
**Date:** 2026-02-03
**Paper:** Salary Transparency Laws and the Gender Wage Gap (v4 revision of apep_0148)

## Summary

This revision of apep_0148 addresses all critical issues from the parent paper's advisor reviews and adds wild cluster bootstrap inference. The R pipeline has been fully re-run and all tables/figures now reflect actual pipeline output rather than hardcoded parent values.

## Key Findings

1. **C-S ATT:** -0.0105 (SE = 0.0055) — marginally significant
2. **TWFE:** 0.004 (SE = 0.013) — insignificant
3. **DDD (gender):** TP×Female = 0.046-0.064 — highly significant
4. **Bootstrap:** TWFE p = 0.778 (confirms null)

## Issues Identified and Fixed

1. **Table 1 values**: Updated from parent paper values to actual TWFE pipeline output
2. **Table 2 (DDD gender)**: Updated all coefficients to pipeline values
3. **Event study table**: Updated from parent values to actual C-S event study
4. **Bargaining table**: Updated coefficients and observation counts (566,844 unweighted, not 1,452,000 weighted)
5. **Cohort table**: Updated with actual group-level C-S ATTs
6. **HonestDiD table**: Updated with pipeline bounds
7. **Sample sizes**: Standardized to 566,844 unweighted throughout
8. **Pre-trends**: Honestly reported significant t-3 and t-2 coefficients
9. **State counts**: Clarified 8 ever-treated / 6 with post-treatment data / 43 never-treated throughout
10. **NY/HI treatment**: Explicitly stated these have zero post-treatment obs and zero weight in ATT
11. **Bootstrap**: Added set.seed() for reproducibility
12. **C-S ATT**: Standardized to -0.0105 (SE = 0.0055) throughout

## Verdict

**CONDITIONALLY ACCEPT** — The paper is internally consistent and ready for external review.
