# Revision Plan — Round 1

**Date:** 2026-01-18

Based on Internal Review Round 1 (Claude Code as Reviewer 2 + Editor)

---

## Priority 1: Methodological Fixes

### 1.1 Add State and Year Fixed Effects to DiD Equations
**Concern:** Equations (1) and (2) omit fixed effects, making them underspecified.
**Action:** Revise equations to include δ_s and θ_t explicitly.

### 1.2 Address Few Clusters Inference
**Concern:** Only 8 states makes cluster-robust SEs unreliable.
**Action:** Add note acknowledging limitation; discuss permutation inference in footnote.

### 1.3 Add Per-Capita Analysis
**Concern:** Raw counts don't account for population growth.
**Action:** Add robustness check using deaths per 100,000.

---

## Priority 2: Content Additions

### 2.1 Mechanism Discussion
**Concern:** No discussion of WHY penalties might not affect overdose deaths.
**Action:** Add subsection in Discussion exploring channels.

### 2.2 COVID-19 Sensitivity
**Concern:** Pandemic overlaps with treatment period.
**Action:** Add robustness check excluding 2020-2021 or controlling for COVID.

### 2.3 Pre-Trend Testing
**Concern:** Visual suggestion of divergent pre-trends.
**Action:** Report joint F-test on pre-2019 event study coefficients.

---

## Priority 3: Language/Presentation

### 3.1 Revise "Precise Null" Language
**Concern:** Fentanyl 95% CI spans -97% to +4,443% — not precise.
**Action:** Change "precise null" to "underpowered estimate" or "inconclusive."

### 3.2 Fix Inconsistent Percentage
**Concern:** Abstract says 660%, Results say 810%.
**Action:** Verify correct figure from data; fix abstract.

### 3.3 Expand Literature Review
**Action:** Add Oregon Measure 110 discussion, deterrence theory citations.

---

## Implementation Order

1. Fix 660%/810% inconsistency (verify from data first)
2. Revise equations (1) and (2) to include fixed effects
3. Revise "precise null" language
4. Add mechanism discussion subsection
5. Add few-clusters acknowledgment
6. Add per-capita robustness mention
7. Add COVID sensitivity note
8. Expand literature review

---

## Deferred Items (for later rounds)

- Wild cluster bootstrap implementation
- Additional figures
- County-level analysis
