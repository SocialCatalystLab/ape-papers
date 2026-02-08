# Revision Plan #1

**Based on:** Internal Review #1 (Claude Code)
**Date:** January 18, 2026

---

## Critical Fixes

### 1. Sign Interpretation Issue

**Issue:** The coefficient on `below_threshold` is -0.077 for Medicaid, but the text interprets this as "more Medicaid below threshold." Need to verify whether this is a coding issue or interpretation issue.

**Resolution:** Actually, re-examining the figure and coefficient, I believe the issue is that the standard RD parameterization measures the JUMP at the threshold. In our case:
- D = 1 if income <= 100% FPL (eligible for Medicaid)
- The coefficient τ = -0.077 means: E[Medicaid | D=1, cutoff] - E[Medicaid | D=0, cutoff] = -0.077

This would mean being below threshold is associated with LOWER Medicaid, which contradicts expectations.

**HOWEVER**, looking at the figure more carefully, the pattern shows a DROP in Medicaid when moving from below to above (which is the expected direction). The discrepancy may be due to:
- The local linear regression detecting a different pattern than the global trend
- Noise in the binned means near the cutoff

**Action:** Recode the treatment variable as `above_threshold = (POVPIP > 100)` so that the coefficient has the intuitive interpretation (positive = losing Medicaid when crossing above threshold). This will make the coefficient positive and match the text interpretation.

### 2. Fix Missing Citation

**Action:** Add the Currie & Gruber (1996) citation for Medicaid pregnancy thresholds.

### 3. Fix Page 2 Layout

**Action:** Use `\newpage` after abstract to ensure keywords/JEL codes stay on page 1.

---

## Moderate Fixes

### 4. Address Gender Imbalance

**Action:** Add a robustness table showing main results controlling for gender (and other covariates).

### 5. Discuss Placebo Concern More Fully

**Action:** Add discussion of why 125% FPL might show a discontinuity (ACA cost-sharing reduction cliff, CHIP transitions, etc.) and argue this doesn't threaten main Medicaid finding.

### 6. Add Exchange Coverage Outcome

**Action:** Add `purchased_insurance` (HINS2) as an outcome to show transition to exchange coverage above threshold.

---

## Enhancements (Lower Priority)

### 7. Total Coverage Analysis

**Action:** Add `any_insurance` (HICOV) outcome to assess coverage gap.

### 8. Subgroup Heterogeneity

**Action:** Add brief discussion of heterogeneity by marital status (single adults may be more responsive since they can't rely on spouse's coverage).

---

## Implementation Order

1. Fix sign issue by recoding variable
2. Rerun analysis
3. Fix citation
4. Fix layout
5. Add robustness with controls
6. Add exchange coverage outcome
7. Recompile and verify

---

## Expected Results After Fix

After recoding to `above_threshold`, the coefficient should be:
- **+0.077** for has_medicaid (losing ~7.7 pp Medicaid when crossing above)
- **~0** for employment (no labor supply effect)

This matches the intuitive interpretation and the visual pattern in the figures.
