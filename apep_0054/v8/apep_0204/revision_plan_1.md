# Revision Plan (Stage C - Post-External Review)

## Summary of Reviews
- GPT-5-mini: MAJOR REVISION (inferential fragility, missing refs, tone down claims)
- Grok-4.1-Fast: MAJOR REVISION (same cluster concern, missing refs, praised writing)
- Gemini-3-Flash: MINOR REVISION (page count, occupation coding, magnitude context)

## Core Concern (All 3 Reviewers)
All reviewers flag the 8-treated-state limitation and permutation p=0.154 vs asymptotic p<0.001 tension. This is inherent to the policy landscape and already discussed in Section 6.7. Not fixable with prose. The paper already presents this honestly.

## Actionable Prose Changes

### 1. Page Count (Gemini concern: 23 pages)
Verify main text meets 25-page minimum. If short, add substantive content.

### 2. Add Missing References
- Roth et al. (2023) JoE survey - cite in methodology
- de Chaisemartin & D'Haultfoeuille (2020) - already cited as dechaisemartin2020, verify
- Recalde & Vesterlund (2018) - cite in gender gap literature

### 3. Magnitude Context (Gemini suggestion)
Add 1-2 sentences comparing the 4-6pp gender gap narrowing to other known interventions.

### 4. Occupation Coding Justification (Gemini)
Add brief justification for high-bargaining classification.

### 5. Tone Check
Verify abstract/intro language is appropriately cautious about design-based inference.

## Not Addressed (Would Require Code Changes)
- Wild cluster bootstrap (fwildclusterboot unavailable)
- Blocked permutation inference
- Compliance/treatment intensity measures
- Job-posting data linkage
- Cell-level collapsed DDD as primary
These are valid suggestions for future work but outside scope of this prose revision.
