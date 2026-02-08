# Revision Plan - Round 1

## Summary of Reviewer Feedback

All three reviewers identified the same fundamental issue: the running variable is computed as distance to opposite-type state polygons rather than to actual treatment-changing border segments. This is acknowledged as a design limitation in the paper.

## Key Issues Raised

1. **Running variable construction** - Distance to polygon ≠ distance to treatment boundary
2. **Pooled border design** - Needs border-segment conditioning
3. **Failed validity tests** - McCrary, placebo cutoffs, covariate balance

## Revisions Made (Prior to This Round)

The paper has already been extensively revised to:
- Frame as methodological case study documenting RDD challenges
- Explicitly acknowledge running variable limitation in abstract, intro, and limitations
- Add comprehensive robustness tables (donut RD, specifications, covariate balance)
- Fix all internal inconsistencies (dates, counts, p-values)
- Clarify FARS estimand throughout

## Remaining Issue

The running variable issue cannot be fixed without complete re-implementation:
1. Would require constructing state adjacency graph
2. Extracting shared border segments
3. Computing time-varying treatment-changing segments
4. Re-computing all distances

This is beyond the scope of revision - it would be a new paper.

## Decision

The paper is publishable as a methodological contribution showing why naive spatial RDD at multi-state borders fails. The honest acknowledgment of limitations is itself valuable.
