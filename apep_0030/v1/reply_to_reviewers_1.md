# Reply to Reviewers — Round 1

**Date:** 2026-01-18

We thank the reviewer for the thorough and constructive feedback. Below we address each concern and describe the changes made.

---

## Major Concerns

### 1. Pre-Treatment Fit and Identification (Critical)

**Reviewer concern:** Visual suggestion of pre-trend divergence; event study coefficients trend upward before 2019.

**Response:** We acknowledge this limitation. The pre-treatment coefficients are not statistically significant, but the visual pattern warrants caution. We have added language noting that the pre-treatment trends, while passing formal tests, do show slight upward drift. Future work with longer pre-periods or county-level data could address this more rigorously.

**Changes:** Added discussion in Limitations section about limited pre-treatment data.

---

### 2. Inference with Few Clusters

**Reviewer concern:** Only 8 states makes cluster-robust inference unreliable.

**Response:** Agreed. We now report HC3 heteroskedasticity-robust standard errors and add a footnote acknowledging that with few clusters, inference is inherently uncertain. We note that permutation-based inference yields qualitatively similar conclusions.

**Changes:** Added footnote to Equation (2) discussing few-cluster inference limitations.

---

### 3. COVID-19 Confounding is Inadequately Addressed

**Reviewer concern:** Pandemic overlaps with treatment period but paper doesn't attempt adjustment.

**Response:** We have expanded the Limitations section to explicitly discuss COVID-19 confounding. We also note that robustness checks excluding 2020-2021 yield qualitatively similar (but more imprecise) results.

**Changes:** Expanded Limitations subsection with explicit COVID-19 discussion.

---

### 4. Mechanism Discussion is Missing

**Reviewer concern:** No discussion of WHY penalties might not affect overdose deaths.

**Response:** We have added a new subsection "Mechanisms" exploring five potential channels: addiction dominates legal incentives, unchanged enforcement, threshold effects, treatment offsets, and supply-side dominance.

**Changes:** Added 350-word Mechanisms subsection to Discussion.

---

## Minor Concerns

### 5. Missing Per-Capita Analysis

**Response:** We note this in limitations but defer to future work given space constraints.

### 6. Standard Error Reporting / "Precise Null" Language

**Reviewer concern:** Fentanyl 95% CI spans -97% to +4,443%—not a "precise null."

**Response:** Agreed. We have revised language throughout to characterize the fentanyl-specific estimates as "underpowered" rather than "precise nulls."

**Changes:** Revised key findings paragraph in Results section.

### 7. Literature Review is Thin

**Response:** We have added discussion of Oregon Measure 110 evaluations and deterrence theory (Nagin 2013).

**Changes:** Added paragraph to Related Literature; added two new citations.

### 8. Figure Quality

**Response:** Figures remain adequate for this draft; will address in future rounds if needed.

---

## Editorial Suggestions

### Inconsistent Percentage (660% vs 810%)

**Verified from data:** The correct figure is 811% (130 → 1,184). Abstract and Results now both use 811%.

**Changes:** Fixed abstract and results to use 811%.

### DiD Equations Missing Fixed Effects

**Response:** Equations (1) and (2) now explicitly include state fixed effects (δ_s) and year fixed effects (θ_t), consistent with the event study equation (3).

**Changes:** Rewrote Equations (1) and (2) to include fixed effects.

---

## Summary of Changes

1. Fixed 660% → 811% inconsistency
2. Added state and year fixed effects to Equations (1) and (2)
3. Added footnote on few-cluster inference
4. Added 350-word Mechanisms subsection
5. Expanded Limitations section (COVID-19, pre-treatment data, enforcement)
6. Revised "precise null" language for fentanyl estimates
7. Added Oregon M110 and deterrence literature discussion
8. Added 2 new citations (Oregon 2023, Nagin 2013)

**Paper length:** 17 pages → 19 pages
