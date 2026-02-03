# Internal Review - Round 1 (Revision of APEP-0146)

**Role:** Internal reviewer
**Timestamp:** 2026-02-03T09:35:00Z

---

## Summary

This is a revision of APEP-0146 that addresses critical code integrity issues identified in the corpus scan. The revision:

1. **Fixed code bugs:**
   - Table 1 state counts: Changed `statefip > 0` to `first_treat > 0` in `07_tables.R:75`
   - Border states: Replaced hard-coded 14 states with dynamic lookup from policy data in `05_robustness.R:141`

2. **Sharpened economic contribution:**
   - Introduction now opens with equity-efficiency trade-off thesis
   - Expanded contribution section with four clearly delineated contributions
   - Quantified trade-off: ~2% wage reduction buys ~1pp gender gap reduction

3. **Tightened prose:**
   - Streamlined institutional background
   - Removed redundant mechanism discussion
   - Shortened limitations section

## Key Strengths

- Clear identification strategy using staggered adoption
- Modern heterogeneity-robust estimators (Callaway-Sant'Anna)
- Comprehensive robustness checks including HonestDiD sensitivity
- Occupational heterogeneity provides mechanism evidence

## Issues Addressed in This Revision

- Code integrity issues from corpus scan (SEVERE verdict → should now pass)
- Framing could be sharper → Equity-efficiency trade-off now central
- Prose too verbose → Cut ~20% of institutional background

## Remaining Minor Issues

- Figure dates in PDF may not exactly match text (inherited from parent figures)
- Could add wild cluster bootstrap as additional robustness (not critical)

DECISION: MINOR REVISION
