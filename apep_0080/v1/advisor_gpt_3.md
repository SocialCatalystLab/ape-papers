# Advisor Review - Advisor 3/3

**Role:** Academic advisor checking for fatal errors
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** high
**Timestamp:** 2026-01-29T03:56:22.828149
**Response ID:** resp_0860a42812af592d00697acb99a7508190b3ca3a2ed8bd7b94
**Tokens:** 12209 in / 6960 out
**Response SHA256:** 5513ba90a9dfb14d

---

FATAL ERROR 1: Data–Design Alignment (running variable does not correspond to the treatment-changing border)
- **Location:** Abstract (“running variable … does not consistently correspond…”), Section **3.3** step 4–5, Section **4.1** definition of \(D_i\), and all RD results (Figures 2–4, Tables 2, 6–9).
- **Error:** The paper’s RD estimand requires \(D_i\) to be the **signed distance to the local treatment boundary** (a primary–secondary *adjacent* border segment relevant for that observation). But you define/implement \(D_i\) as distance to the **nearest opposite-type state polygon**, which can be **non-adjacent** and can point to a boundary segment that does **not** separate primary from secondary at the crash location. Then \(D_i=0\) is not a unique “border” for many observations, and many included crashes may be within 100 km of an opposite-type state *without being near any enforcement-discontinuity border segment at all*. That breaks the core RD structure (sharp treatment change at a well-defined cutoff).
- **Why this is fatal:** With a misaligned running variable, the “RD estimate,” McCrary test, placebo-cutoff tests, and covariate-balance tests are not diagnosing RD validity—they are diagnosing artifacts of a running variable that is not the treatment boundary. A journal will treat this as “not an RD” rather than “an RD that fails.”
- **Fix:** Rebuild the running variable so it is distance to the **set of treatment-changing border segments** at the crash date:
  1. For each date (or year) construct state polygons labeled by enforcement type **at that time**.
  2. Construct the **line geometry** of borders where the two adjacent polygons have different enforcement.
  3. For each crash, compute the shortest distance to that line set; sign it by the enforcement of the crash-side polygon.
  4. Restrict the estimation sample to crashes whose nearest boundary segment is in that treatment-changing set (or equivalently: drop observations not locally “facing” an opposite-type adjacent border).

FATAL ERROR 2: Internal Consistency (sample description contradicts your own construction/limitation)
- **Location:** Abstract (“within 100 kilometers of enforcement borders”), Section **3.3** step 5 (“within 100 km of a primary-secondary border”), versus Section **6.1** (“distance … may not always correspond to an adjacent state boundary”).
- **Error:** You repeatedly label the sample as being near “primary–secondary borders,” but your own limitation admits the implemented distance is to a nearest opposite-type polygon and may not correspond to a treatment-changing border segment. Those statements cannot simultaneously be true as written.
- **Fix:** Either (i) implement the corrected border-segment distance (Fix under Error 1) so the description is true, **or** (ii) if you intentionally want a “naïve” design, you must relabel everywhere: e.g., “within 100 km of the nearest opposite-type state polygon (not necessarily an adjacent enforcement border).” If you choose (ii), you must also stop presenting the outputs as an “RDD at the border,” because the cutoff is not a border for many observations.

FATAL ERROR 3: Data–Design Alignment (pooled multi-border ‘single-cutoff’ rdrobust is not a valid RD setup here)
- **Location:** Section **4.2** (use of **rdrobust** as a single-cutoff local polynomial), and all pooled RD tables/figures (Tables 2, 6–9; Figures 2–3).
- **Error:** Even if distance were correctly computed to a treatment-changing border, your estimator pools observations from many heterogeneous borders into a **single one-dimensional running variable** without conditioning on border segment / border pair. In that pooled setup, the conditional expectation \(E[Y \mid D=d]\) is generally a **mixture over different borders at different distances**, so it is not the “same smooth function on either side of one cutoff” that rdrobust’s single-cutoff RD logic assumes. This is not a minor modeling choice; it is a mismatch between the identifying model and the estimator.
- **Fix:** Use an RD approach that is coherent under multiple borders, e.g.:
  - Estimate **border-pair-specific** (or segment-specific) RDs and then aggregate (meta-analysis / inverse-variance weighting / hierarchical model), **or**
  - Use a stacked/pooled specification with **border-segment fixed effects** and a **segment-specific running variable** (distance to that segment, within a segment-specific neighborhood), **or**
  - Use a proper geographic RD framework (e.g., local randomization / matching within segment neighborhoods) where identification is explicitly segment-conditional.

ADVISOR VERDICT: FAIL