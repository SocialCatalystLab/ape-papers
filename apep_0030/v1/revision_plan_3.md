# Revision Plan 3 — Response to GPT 5.2 Round 3 Review

**Date:** 2026-01-18
**Review Decision:** REJECT AND RESUBMIT
**Focus:** Fix critical inference inconsistency; acknowledge fundamental limitations

---

## Critical Issue: Bootstrap CI Inconsistency

**Problem:** The paper claims bootstrap CI "spans positive and negative effects" but Table 3 and analysis show CI is [1.7%, 33.9%] — entirely positive. This is a factual error.

**Root cause investigation:**
- Bootstrap CI [0.017, 0.292] in log terms = [1.7%, 33.9%] in percent terms
- Only 0.8% of bootstrap coefficients are ≤ 0
- CI correctly excludes 0, meaning the estimate is likely positive
- But permutation p-value = 0.72 means this isn't unusual compared to other states

**Resolution:** The bootstrap CI and permutation test answer different questions:
1. **Bootstrap CI**: "Given the model, what's the range of plausible effect sizes?" → Likely positive [1.7%, 33.9%]
2. **Permutation test**: "Is Colorado unusual compared to if we randomly assigned treatment?" → No (p=0.72)

The paper must be revised to correctly describe what each method shows.

---

## Changes Required

### 1. Fix Narrative About Bootstrap CI (Critical)

**Location:** Abstract, Section 5.2, Section 5.5, Table 3 notes

**Current text (incorrect):**
> "The bootstrap percentile CI is narrower (2% to 34%) but still spans economically meaningful positive and negative effects."

**Revised text:**
> "The bootstrap percentile CI is narrower [1.7%, 33.9%] and lies entirely above zero, suggesting the point estimate is reliably positive. However, this should not be interpreted as statistical significance: the permutation test (p=0.72) shows similar-magnitude effects arise frequently when randomly assigning treatment to other states, indicating the effect is not unusual in the regional context."

### 2. Clarify What Each Inference Method Shows

**Add to Section 4.2:**
> "These methods answer different questions. The wild cluster bootstrap CI provides uncertainty bounds around our point estimate—conditional on the DiD model, what range of effects is plausible? The permutation test asks whether Colorado's outcome is unusual compared to what we would observe if treatment were randomly assigned across states. A positive bootstrap CI combined with a high permutation p-value indicates that while our estimated effect is reliably positive, other untreated states show similar patterns when pretended-treated, suggesting confounding rather than a causal policy effect."

### 3. Update Abstract

**Current:** "statistically inconclusive effects spanning substantial decreases to large increases"
**Revised:** "statistically inconclusive effects; while point estimates suggest a 17% increase, permutation inference shows this is unremarkable compared to regional trends (p=0.72)"

### 4. Acknowledge Fundamental Limitations More Explicitly

The reviewer's core criticisms (state-level design, national shock, bundled treatment) are fundamental limitations we cannot fix without different data. Add explicit statement:

> "We acknowledge that the fundamental design limitations—single treated state, national fentanyl shock coinciding with treatment timing, and bundled policy provisions—cannot be resolved with state-level mortality data alone. Monthly and/or county-level data with border-county designs, combined with enforcement and treatment mechanism outcomes, would be necessary to credibly identify policy effects. Our contribution is more modest: we document that observable mortality trends in Colorado closely track regional patterns regardless of policy changes, suggesting that supply-side shocks dominate any demand-side policy effects."

---

## Issues We Cannot Address (Honest Acknowledgment)

| Issue | Why Not Addressable |
|-------|-------------------|
| Monthly data | CDC Wonder annual data used; monthly provisional data not available for this historical period |
| County-level design | County-level overdose data too sparse for small Colorado border counties |
| Mechanism evidence | Arrest/court data requires data request to Colorado Judicial Branch; TEDS treatment data has 2-year lag |
| Treatment bundling | Inherent to HB 22-1326; cannot separately identify penalty vs. diversion vs. harm reduction effects |

These are honest limitations, not excuses. The paper's contribution is documenting the null finding with appropriate uncertainty.

---

## Implementation Steps

1. Edit paper.tex:
   - Fix all instances of "spans positive and negative" to correctly describe CI
   - Add clarification about what different inference methods show
   - Update abstract
   - Add more explicit limitations statement

2. Recompile and visual QA

3. Write reply to reviewers

4. Run Round 4 review

---

## Expected Outcome

The paper will correctly describe its inference results. The fundamental limitations remain—this paper will likely continue receiving "REJECT AND RESUBMIT" or "MAJOR REVISION" decisions because the identification strategy is inherently weak. However, the paper will be internally consistent and honest about what it can and cannot show.

If subsequent reviews still recommend rejection due to fundamental design issues, we will proceed to publish with appropriate caveats per APEP workflow (minimum 3 external reviews completed).
