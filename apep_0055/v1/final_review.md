# Final Review

## Paper 70: Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid?

**Date:** 2026-01-23
**Model:** claude-opus-4-5

---

## Decision: REJECT AND RESUBMIT

---

## Summary

This paper used a regression discontinuity design at the ACA age-26 dependent coverage threshold to estimate effects on birth payment source. Using 2023 CDC Natality data (1.6M births), the paper found:

- **Medicaid:** +2.7 pp at age 26 (p < 0.001)
- **Private Insurance:** -3.1 pp at age 26 (p < 0.001)
- **Heterogeneity:** Unmarried women +4.9 pp vs married +2.1 pp

## Critical Issues (from external review)

Both GPT 5.2 reviewers independently recommended REJECT AND RESUBMIT for the same fundamental reason:

### 1. Discrete Running Variable Problem

The running variable (MAGER) is measured in integer years, providing only ~9 support points (ages 22-30). This fundamentally undermines RD credibility because:

- Effective sample size is 9 bins, not 1.6 million observations
- Heteroskedasticity-robust SEs are misleading (understate uncertainty)
- Cannot compare observations "arbitrarily close" to threshold
- Design becomes functional-form-driven rather than locally nonparametric

### 2. Placebo Failures

Significant "effects" at placebo cutoffs (age 27: -2.8 pp) indicate specification/curvature problems. The sign reversal at age 26 is not sufficient—RD requires local smoothness.

### 3. Sharp vs. Fuzzy Framing

Treatment is institutionally fuzzy (plans end at end-of-month, not exact birthday) but paper claims sharp RD.

## What Would Fix This

1. **Obtain exact age in days** from restricted NCHS data
2. **Pre-ACA falsification** (difference-in-discontinuities)
3. **Cluster inference at age level** with small-cluster corrections
4. **Acknowledge as fuzzy RD** with clear first-stage

## Lessons Learned

Added to `top10_mistakes.md`: RD with discrete running variable is fundamentally different. Effective sample size = number of support points, not observations. Placebo failures signal specification problems.

## Publication Status

Paper published to `papers/apep_0070/` for archival purposes. Not recommended for journal submission without major redesign.

---

**DECISION: REJECT AND RESUBMIT**
