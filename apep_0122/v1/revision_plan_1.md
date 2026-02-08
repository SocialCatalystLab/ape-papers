# Revision Plan - Paper 113

## Reviews Received
- Reviewer 1: REJECT AND RESUBMIT
- Reviewer 2: MAJOR REVISION
- Reviewer 3: REJECT AND RESUBMIT

## Critical Issues to Address

### 1. Pre-Trend Rejection (All 3 reviewers)
**Concern:** Joint test rejects at p<0.01; narrative dismissal insufficient.
**Action:** Add Rambachan & Roth (2023) citation and discussion. Note that HonestDiD R package failed to run (library not available). Add restricted event window [-4, +8] where all coefficients are individually insignificant as the preferred specification. Report both the full and restricted event windows. Discuss compositional fragility at distant horizons.

### 2. External Validity (All 3 reviewers)
**Concern:** 10 early adopters (including CA, TX, MA) excluded from identification.
**Action:** Add explicit discussion of external validity limitations. Note that the ATT reflects the effect for post-2006 adopters only. Discuss how this may differ from early adopters and why. Note QCEW extension as future work.

### 3. Binary Treatment / Attenuation (All 3 reviewers)
**Concern:** 0/1 indicator ignores RPS stringency variation.
**Action:** Already have alternative treatment (target > 5%) as robustness. Strengthen discussion of attenuation concern. Note the slightly larger point estimate for higher-target states (+0.131 vs +0.112) as suggestive evidence.

### 4. No First Stage (Reviewers 2, 3)
**Concern:** Paper doesn't show RPS actually changed renewable generation.
**Action:** Add discussion citing external evidence from literature (EIA data on renewable generation growth in RPS vs non-RPS states). Note that establishing the first stage with our data would require additional data collection beyond this paper's scope.

### 5. Mechanism Not Demonstrated (All 3 reviewers)
**Concern:** "Offsetting reallocation" is speculative.
**Action:** Reframe the conclusion more carefully. Remove or qualify the reallocation interpretation. Acknowledge this limitation explicitly.

### 6. Spillovers/SUTVA (All 3 reviewers)
**Concern:** REC trading and interstate markets could contaminate estimates.
**Action:** Add substantive discussion of how REC trading and interstate electricity markets could attenuate the treatment effect. Note this as a key limitation.

### 7. RPS Literature (All 3 reviewers)
**Concern:** Energy economics literature on RPS design underengaged.
**Action:** Add citations and discussion of RPS effectiveness literature.

## Minor Issues
- Trim abstract
- Add Rambachan & Roth (2023) citation
- Improve discussion of event-study support at distant horizons
- Fix manufacturing placebo discussion (p=0.102 is borderline)
- Reframe contribution claims (don't overclaim "first credible causal evidence")

## Implementation Priority
1. Revise main text: limitations, external validity, first stage, mechanism, RPS literature
2. Add Rambachan & Roth discussion and restricted event window analysis
3. Trim abstract
4. Reframe contribution claims
5. Recompile and publish
