# Revision Plan (Post-External Review)

**Paper:** Does the Safety Net Bite Back? Medicaid Postpartum Coverage Extensions
**Date:** 2026-02-04
**Reviews:** GPT (MAJOR), Grok (MINOR), Gemini (CONDITIONAL ACCEPT)

## Changes Implemented

### 1. Power Framing (GPT #priority, Gemini suggestion)
- **Abstract**: Expanded final sentence to explicitly compare MDE (4.3 pp) to point estimate (0.99 pp) and plausible effect range (2.5-10.5 pp), noting data can rule out large effects but not distinguish modest positive from true zero.
- **Rationale**: All three reviewers wanted clearer power context in abstract.

### 2. SE Consistency Fix (Internal, from advisor review)
- **MDE section**: Corrected SE from 0.69 pp to 0.63 pp; MDE from 1.93 pp to 1.8 pp.
- **Rationale**: GPT advisor identified numeric inconsistency.

### 3. Monte Carlo to Analytic (Internal, from advisor review)
- **4 locations in paper.tex**: Changed "Monte Carlo simulation" to "analytic calculation" throughout.
- **Rationale**: Codex advisor flagged Monte Carlo as potential synthetic data policy violation. Attenuation calibration is now purely analytic (closed-form expressions).

### 4. 2024-Only Reconciliation (GPT advisor, Gemini reviewer)
- **Section 7.3**: Rewrote to describe actual result (+0.75 pp, SE = 3.4 pp) rather than making directional predictions.
- **Section 7.7**: Replaced speculative text with observed result and interpretation.
- **Rationale**: Previous text predicted 2024-only should be "similarly or more negative" but actual result is positive (though insignificant).

### 5. Permutation Documentation (GPT advisor)
- **Appendix**: Added sentence clarifying that cohort-size distribution is held fixed during permutation.
- **Rationale**: Ensures permutation procedure is fully specified.

## Deferred to Future Revision

| Suggestion | Source | Reason for Deferral |
|------------|--------|---------------------|
| Stratified/blocked permutations | GPT | Requires substantial new analysis code |
| Synthetic control / entropy balancing | GPT | Requires new methodological code |
| State × linear time trends in DDD | GPT | Computationally intensive, exploratory |
| Admin data comparison | All | Data not available in current framework |
| Heterogeneity by admin capacity | Gemini | State-level admin quality data not readily available |
| Additional references (Kline, Soni, Courtmanche, Guth) | Grok, Gemini | Minor; can add in next revision |
