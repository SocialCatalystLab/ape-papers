# Advisor Review - Advisor 2/3

**Role:** Academic advisor checking for fatal errors
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-29T03:56:22.827912
**Response ID:** resp_06f3769e168eb48300697acb9935c881a0b5b43eca5f446e5a
**Tokens:** 12209 in / 5142 out
**Response SHA256:** 116297d6a2eb4145

---

FATAL ERROR 1: **Data–Design Alignment (Running variable does not correspond to the treatment discontinuity)**
- **Location:** Section 3.3 (Sample construction), Step 4; Section 4.1 (definition of \(D_i\)); Section 6.1 (Limitations); affects Figures 2–4 and Tables 2–9.
- **Error:** The paper’s running variable is *not* the signed distance to the **actual primary–secondary border segment that would change treatment if crossed**. You compute “Euclidean distance to the nearest opposite-type state polygon,” which can be a **non-adjacent** state (distance crossing intervening states) and therefore does not define a valid RD cutoff for many observations. As a result:
  - Many crashes included as “within 100 km of an enforcement border” may in fact be **nowhere near any treatment-changing border segment** (they are just within 100 km of *some* opposite-type polygon).
  - The RD estimand in Eq. (2) is not well-defined because \(D_i\) is not the distance to the discontinuity that assigns treatment for that observation.
  - The estimated discontinuity at \(D_i=0\) (Table 2 / Figure 2) is therefore not an RD estimate of the effect of crossing an enforcement border, even “descriptively.”
- **How to fix (minimum needed before submission):**
  1. For each crash date \(t\), construct the set of **treatment-changing border segments**: state-pair borders where one side is primary and the adjacent side is secondary **at time \(t\)**.
  2. Compute each crash’s signed distance to the **nearest such segment** (not nearest opposite-type polygon), ensuring that “nearest” implies the segment is the boundary one would cross to switch treatment locally.
  3. Restrict the sample to crashes whose nearest segment is treatment-changing (or explicitly handle ties / ambiguous nearest segments).
  4. Re-run all RD estimates and diagnostics using this corrected \(D_i\). If you still want pooling, you must at least condition on border segment (see Fatal Error 2).

---

FATAL ERROR 2: **Internal Consistency (Your main validity diagnostics are not interpretable under the pooled multi-border construction you use)**
- **Location:** Section 5.3 (Validity concerns), Figure 4 (McCrary), Table 6 (Placebo cutoffs), and statements in Abstract/Intro that these tests “reveal fundamental violations of RDD assumptions.”
- **Error:** With pooled multi-border spatial RD using a one-dimensional “distance-to-(something)” running variable, the **density test and placebo-cutoff tests you present are not valid evidence of RDD assumption failure** because the composition of observations at a given distance changes mechanically with geography and border availability.
  - **McCrary density test (Figure 4):** The distribution of signed distances in a pooled, multi-segment geography is not expected to be smooth at 0 even absent sorting/manipulation—because the amount of land/road network and the set of contributing borders can differ discontinuously across sides and segments. With your misdefined \(D_i\) (Fatal Error 1), this problem is even worse. Interpreting \(p<0.001\) as a continuity violation attributable to sorting or policy endogeneity is therefore not justified.
  - **Placebo cutoffs (Table 6):** In a pooled design, “+10 km” is not a single counterfactual location; it is a different mixture of states/border segments than “0 km.” Significant placebo “effects” can arise mechanically from changing segment composition rather than from failure of continuity at a true cutoff.
- **How to fix (minimum needed before submission):**
  1. After fixing \(D_i\) to be segment-specific (Fatal Error 1), run RD **separately by border segment or border pair** (adjacent state pair) and then aggregate estimates (e.g., meta-analysis / precision weighting), *or* implement an estimator that conditions on segment (segment fixed effects / within-segment centering so that distance is defined relative to that segment).
  2. Redo diagnostics in a way that matches the corrected design:
     - Density: assess continuity of crash *locations* around the border in a segment-appropriate way (or at least apply density tests within border segments / pairs, not pooled).
     - Placebo cutoffs: implement within-segment placebo cutoffs where the underlying segment and local geography are held fixed.

---

FATAL ERROR 3: **Internal Consistency (Core sample description is not supported by the implemented construction)**
- **Location:** Abstract (“within 100 kilometers of enforcement borders”), Section 3.3 Step 5 (“Restrict to crashes within 100 km of a primary-secondary border”), plus Table 1 (“Fatal Crashes Near Enforcement Borders”).
- **Error:** Given the current distance construction (nearest opposite-type polygon), the statement “within 100 km of a primary–secondary border” is not guaranteed to be true for all included crashes. This is not a minor wording issue: it is a misdescription of the actual analytic sample and undermines interpretability of all summary statistics and RD graphs/tables tied to that sample definition.
- **How to fix:**
  - After constructing the true set of treatment-changing border segments (Fatal Error 1), redefine the analytic sample as “within 100 km of the nearest treatment-changing border segment” and regenerate Table 1 and all subsequent analyses.

---

ADVISOR VERDICT: FAIL