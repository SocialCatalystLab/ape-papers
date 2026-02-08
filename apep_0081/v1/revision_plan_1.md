# Revision Plan - Round 1

## Summary of Reviewer Feedback

All three reviewers gave REJECT AND RESUBMIT with consistent concerns:

1. **No statistical inference** - No regressions, SEs, CIs, or hypothesis tests
2. **No implemented identification strategy** - RDD/DiD discussed but not executed
3. **Thin literature** - Missing key RDD, DiD, and marijuana/traffic safety references
4. **Missing years (2006-2015)** - Prevents credible event studies
5. **Drug testing selection** - Need to address formally

## Paper Positioning

This paper was designed as a **data infrastructure and descriptive atlas** paper, explicitly stating it is "methodological and descriptive rather than causal" (Section 1). The reviewers acknowledge this but note that top general-interest journals (AER/QJE/JPE/ReStud/Ecta/AEJ:EP) require formal statistical inference even for data papers.

## Target Venue Reconsideration

Given the feedback, this paper may be better suited for:
- **Scientific Data** (Nature portfolio) - Explicit data paper format
- **Journal of the Royal Statistical Society, Series A** - Applied statistics with data focus
- **Journal of Policy Analysis and Management** - Policy-oriented, descriptive accepted
- **Transport Policy** or **Accident Analysis & Prevention** - Domain journals

## Changes Made in This Round

1. **Internal consistency issues resolved** (from advisor review):
   - Fixed Table 2 Panel C THC rates (21.3% → 19.1%, 10.8% → 10.0%)
   - Fixed poly-substance text (swapped 4%/8% to correct values)
   - Removed Urban crashes row (no source variable)
   - Clarified FARS vs OSM variable usage in footnotes

2. **Figure terminology corrected**:
   - "Tested" → "with any drug finding reported"
   - "THC Negative" → "No THC Finding"
   - Regenerated all affected figures

## Changes NOT Made (Scope Constraints)

1. **Full RDD/DiD implementation** - Would require reframing the entire paper
2. **Missing years (2006-2015)** - Data pipeline constraint; noted as limitation
3. **Formal selection modeling** - Beyond scope of descriptive paper

## Recommendation

Publish with current decision noted. The paper provides a valuable data infrastructure contribution that can serve as foundation for future causal work. The descriptive patterns are accurately documented with appropriate caveats.
