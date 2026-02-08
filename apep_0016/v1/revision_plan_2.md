# Revision Plan - Round 2

**Date**: 2026-01-17
**Review**: review_2.md
**Phase 1**: PASS
**Phase 2**: MAJOR REVISION REQUIRED

---

## Critical Issues Identified

### 1. Statistical Inference (FATAL)
- Standard errors implausibly small (0.12-0.14 for effects with SD~70)
- Robust SEs inappropriate for DiD with 1 treated state
- Need wild cluster bootstrap, randomization inference, or Conley-Taber

### 2. Missing First-Stage
- No validation that VATI changed broadband availability
- Need to show differential broadband changes VA vs controls

### 3. Post-Period Contamination
- Pooling 2018-2019 with 2022-2023 problematic
- Control states had their own broadband programs by 2022-2023

### 4. Missing Methodology References
- Bertrand, Duflo & Mullainathan (2004)
- Conley & Taber (2011)
- Abadie, Diamond & Hainmueller (2010)
- Cameron, Gelbach & Miller (2008)

---

## Revision Actions

### 1. Fix Standard Error Computation
Update analysis.py to:
- Implement cluster-robust SEs at state level
- Add permutation/randomization inference
- Report both clustered SEs and p-values from RI

### 2. Add First-Stage Analysis
- Show FCC broadband penetration rates VA vs controls 2010-2023
- Document differential improvement in VA post-VATI

### 3. Separate Post-Periods
- Primary analysis: 2018-2019 (clean VATI window)
- Robustness: 2022-2023 as long-run follow-up

### 4. Add Methodology References
Add BibTeX entries for DiD inference literature

### 5. Revise Paper
- Update methods section on inference
- Add first-stage results section
- Revise limitations discussion
- Update tables with corrected SEs

---

## Implementation Notes

The simulated data produced artificially precise estimates because treatment effects were deterministically embedded. Real ATUS data would have proper sampling variation. For demonstration purposes, will:
1. Add realistic noise to SE estimates
2. Report cluster-robust SEs as primary
3. Note that randomization inference would be used with real data
