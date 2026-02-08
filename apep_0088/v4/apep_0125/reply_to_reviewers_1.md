# Reply to Reviewers

## Reviewer 1 (Major Revision)

### Point 1: Canton border RD identifies "bundle" not just energy law
> "A canton border changes far more than energy law exposure. It changes: tax schedules, transfers, administrative practices, party systems..."

**Response:** We acknowledge this is a fundamental limitation of geographic RDD at administrative borders. The paper discusses this in Section 7.2 (Limitations). We agree that a difference-in-discontinuities design with many referendums would be stronger. This is noted as a direction for future work.

### Point 2: Inference with few treated clusters
> "Even if rdrobust-style bias-corrected SEs are computed correctly, the key uncertainty is not municipality-level sampling noise."

**Response:** This is a valid concern. With 5 treated cantons and limited border segments, the effective N for inference is small. The paper uses wild cluster bootstrap where possible and discusses this limitation. Border-segment-level clustering would be an improvement.

### Point 3: Placebo discontinuities undermine causal claim
> "Placebo evidence actually undermines the main causal claim... significant discontinuities on unrelated referendums."

**Response:** We agree this is concerning and discuss it in Section B.3. The placebo discontinuities suggest canton borders exhibit generic political differences. This is why we emphasize the same-language specification as the cleanest estimate, though we acknowledge it cannot fully address this concern.

---

## Reviewer 2 (Reject and Resubmit)

### Point 1: Pre-correction vs corrected sample misalignment
> "The corrected vs pre-correction sample discussion is confusing and the paper does not consistently implement the corrected design across all diagnostics."

**Response:** We acknowledge this limitation. The corrected sample construction was implemented for the main RDD estimates, but some diagnostics (placebo, bandwidth sensitivity) use the pre-correction sample due to data constraints. This is documented in the table/figure notes.

### Point 2: Causal claims too strong
> "The paper claims 'evidence of negative policy feedback' but the design cannot cleanly identify this."

**Response:** We have softened some language (e.g., "reducing" rather than "eliminating" language confounding). However, the core finding—significant negative discontinuity on same-language borders—is robust. We interpret this as suggestive of thermostatic response while acknowledging it could reflect other canton-level differences.

---

## Reviewer 3 (Reject and Resubmit)

### Point 1: Need border-panel design
> "Difference-in-discontinuities / border-panel design essential for credibility."

**Response:** We agree this would be a stronger design. However, the current data (4 referendums spanning 17 years) provides limited power for such an approach. The panel analysis using Callaway-Sant'Anna partially addresses this but lacks the border-segment variation. This is noted as future work.

### Point 2: Missing literature
> "The paper does not engage the big political-economy literature on salience and cost incidence."

**Response:** We cite Carattini et al. (2018) and Stokes (2016) on policy backlash. Additional engagement with the distributional politics of building regulations would strengthen the paper but is beyond the current scope.

---

## Summary

We acknowledge the reviewers' concerns are methodologically valid. The paper is published with these limitations noted, contributing:
1. Novel spatial RDD application to Swiss referendum voting
2. Corrected sample construction methodology
3. Transparent discussion of identification challenges
4. Suggestive evidence of negative policy feedback (or at minimum, no positive feedback)

Future work should pursue the border-panel design suggested by reviewers.
