# Advisor Review - Advisor 1/3

**Role:** Academic advisor checking for fatal errors
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-29T03:56:22.826522
**Response ID:** resp_0ef471d606b7650700697acb99b8e4819493cbe7ba9dbaddf8
**Tokens:** 12209 in / 5500 out
**Response SHA256:** b10376dfc81684e8

---

FATAL ERROR 1: Data–Design Alignment (running variable does not correspond to the treatment-changing cutoff)
  Location: Section 3.3 (Sample Construction), Step 4; Section 4.1 (definition of Di in Eq. (1)); Section 6.1 (Limitations, paragraph beginning “Second, our running variable…”); Abstract (claim about “spatial RDD at U.S. state borders”).
  Error: The paper’s RDD requires the running variable to be *distance to the specific border segment where treatment switches* (primary vs secondary) at the crash date. But you compute “distance to the nearest opposite-type state polygon” (and you explicitly acknowledge it “does not consistently correspond to actual treatment-changing border segments”). This breaks the basic RD structure: for a nontrivial subset of observations, Di is not the signed distance to any relevant cutoff, and the set of “within 100 km of an enforcement border” observations can include crashes that are not within 100 km of any *primary–secondary* shared border segment (e.g., separated by an intervening same-type state, coastline geometry, etc.). In that case, the discontinuity at Di = 0 is not the discontinuity you claim to be estimating, so the reported “RD estimate” is not an RD estimand.
  How to fix:
   1) Construct the universe of *treatment-switching border segments* for each crash date: intersect state boundary linework with the (time-varying) enforcement-type labeling, keep only segments where adjacent polygons differ in enforcement type at that date.
   2) Define Di as signed shortest distance from crash point to that set of segments (optionally: segment-specific sign based on which side of the segment the crash lies).
   3) Restrict the sample to crashes whose nearest segment is one of these treatment-switching segments (and document how often this fails under the current approach).
   4) Then estimate either (i) border-pair/segment-specific RDs and aggregate, or (ii) a pooled design that conditions on border segment (at minimum), consistent with geographic RD practice.

FATAL ERROR 2: Internal Consistency (paper claims an “enforcement border” design but implements a different object)
  Location: Section 3.3 vs Section 4.1–4.2; Figure 2 caption and notes; repeated statements such as “distance to the primary-secondary enforcement border,” “crashes within 100 km of enforcement borders,” and “signed distance to the nearest primary-secondary border.”
  Error: The empirical strategy (Eq. (1) and surrounding text) and figure/table descriptions repeatedly state that Di is distance to the *primary–secondary border*. The data construction states (and Section 6.1 reiterates) that Di is distance to the *nearest opposite-type polygon*, which is not the same object unless you additionally guarantee adjacency and correct segment selection. This is not a wording issue: it is a mismatch between the design the reader thinks you ran and what you actually ran, and it directly affects which observations are “near the cutoff.”
  How to fix: After fixing FATAL ERROR 1, rewrite the affected parts so the implemented running variable exactly matches the formal definition. If you choose not to fix the running variable, you must not label the design/figures/tables as an RD at an “enforcement border,” and you must redefine the estimand accordingly (but note: it will no longer be an RD design).

ADVISOR VERDICT: FAIL