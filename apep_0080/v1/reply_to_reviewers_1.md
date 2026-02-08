# Reply to Reviewers - Round 1

We thank all three reviewers for their careful reading and constructive feedback. Below we address each concern.

---

## Response to All Reviewers: Running Variable Construction

All reviewers correctly identified that our running variable (distance to nearest opposite-type state polygon) does not guarantee correspondence to actual treatment-changing border segments. We agree this is a fundamental limitation.

**Our Response:**
- We have extensively revised the paper to frame it as a **methodological case study** documenting why naive spatial RDD at multi-state borders fails
- The abstract now explicitly states: "our running variable... does not consistently correspond to actual treatment-changing border segments—a design flaw we document as a methodological warning"
- Section 6.1 (Limitations) provides detailed explanation of this issue
- We acknowledge this cannot be fixed without complete re-implementation

**Why we believe publication is still valuable:**
1. Documents a common pitfall in applied spatial RDD
2. Provides guidance for future researchers
3. Demonstrates importance of border-segment-specific running variables
4. Shows what happens when validity tests fail

---

## Reviewer 1 Specific Comments

**Comment:** McCrary and placebo test failures invalidate causal claims.
**Response:** We have removed all causal language. The paper now explicitly states estimates are "descriptive discontinuities rather than causal effects."

**Comment:** Need border-pair-specific RDs.
**Response:** We acknowledge this in the new limitations section and recommend it for future work.

---

## Reviewer 2 Specific Comments

**Comment:** Treatment timing coded at year level vs crash date.
**Response:** We have clarified in Section 3.2 that treatment is coded at crash-date level using exact effective dates.

**Comment:** Pooled design violates single-cutoff structure.
**Response:** Acknowledged in Section 6.1 as second major limitation.

---

## Reviewer 3 Specific Comments

**Comment:** State counts inconsistent (35/14 vs 34+DC/15).
**Response:** Fixed throughout. All references now consistently use "34 states plus DC primary, 15 secondary, NH no law" for 2019.

**Comment:** Missing robustness tables.
**Response:** Added Tables 7-9 in Appendix C: Covariate Balance, Donut RD, Specification Robustness.

---

## Summary of Changes Made

1. Reframed entire paper as methodological case study
2. Removed all causal language
3. Added three appendix tables
4. Fixed all date/count inconsistencies
5. Added detailed limitations discussion
6. Clarified FARS estimand throughout
