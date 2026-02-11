# Revision Plan — Stage C (Post-External Review, v4)

## Review Summary

All three external reviewers gave **MINOR REVISION**:
- **GPT-5-mini**: "promising and publishable after modest revisions"
- **Grok-4.1-Fast**: "Reads like a QJE feature... Prose already elite"
- **Gemini-3-Flash**: "AER-quality prose... methodology is beyond reproach"

## Changes Made in This Revision Pass

### 1. SE Consistency Fix (Gemini Advisor)
Text now reports TWFE SE as 210.5 (matching table), not rounded to 211.

### 2. Log Approximation Transparency (Gemini Advisor)
Added footnote documenting gap between 100×β and exact exp(β)-1 for wage coefficients.

### 3. Firm Headcount Context (Gemini External, Grok)
Added DraftKings (5,500) and FanDuel/Flutter (7,500 US) headcounts in Discussion to concretize why NAICS 7132 shows zero—the two dominant firms employ fewer workers than one casino resort.

### 4. Inference Language (Prose Review)
Rephrased cluster-robust inference sentence per prose review suggestion.

## Items Acknowledged as Future Work (Not Feasible in Prose-Only Revision)
- Broader NAICS basket (5415+5614+5182)
- Permutation/randomization inference
- Wild cluster bootstrap for TWFE
- Border-county spatial analysis
- Treatment timing sensitivity (month-level)
- Tax rate heterogeneity analysis
- Oster (2019) selection bounds
