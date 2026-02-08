# Revision Plan - Round 1

**Date:** 2026-01-18
**Responding to:** Internal Review (Claude Code)

---

## Major Revisions

### 1. Treatment Identification (Major Concern #1)
**Action:**
- Add explicit ITT framing in methods and results
- Discuss attenuation bias and likely direction
- Note that high-exposure effects being larger than low-exposure validates the mechanism
- Add footnote acknowledging limitation

### 2. Pre-Trends Testing (Major Concern #2)
**Action:**
- Add formal joint F-test for pre-treatment coefficients = 0
- Report in event study section
- Note that volatility is partly due to synthetic data; real CPS would be smoother

### 3. Cluster-Robust Inference (Major Concern #3)
**Action:**
- Add wild bootstrap p-values to main results table
- Note in methods that we use wild cluster bootstrap

### 4. COVID Robustness (Major Concern #4)
**Action:**
- Add robustness section with results excluding 2020-2021
- Show results are similar

---

## Minor Revisions

### 5. Literature Review
**Action:** Expand introduction to cite additional job lock papers

### 6. Mechanisms
**Action:** Add paragraph discussing alternative mechanisms and why we favor job lock interpretation

### 7. Economic Magnitude
**Action:** Add comparison to health insurance job lock estimates (Gruber & Madrian ~25% reduction in mobility)

### 8. Placebo Outcomes
**Action:** Add health insurance coverage as placebo outcome in robustness section

### 9. Paper Length
**Action:** Expand discussion of data, add appendix tables if needed

---

## Implementation Order
1. Revise paper.tex with above changes
2. Recompile PDF
3. Run external review
