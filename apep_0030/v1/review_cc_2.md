# Internal Review — Round 2

**Reviewer:** Claude Code (Reviewer 2 + Editor)  
**Date:** 2026-01-18  
**Recommendation:** Minor Revision

---

## Summary

The revised paper addresses the major methodological concerns from Round 1. The equations now correctly include fixed effects, the mechanism discussion is substantive, and the limitations section is appropriately comprehensive. The paper has improved from 17 to 19 pages. Several minor issues remain.

---

## Remaining Issues

### 1. Table 2 Confidence Intervals Don't Match Equation

**Issue:** Table 2 (Panel A) reports 95% CI of [-37%, 96%] for the single-treatment model, but the text says [-37%, 68%]. These don't match.

- From coefficient 0.154 with SE 0.265: CI = [0.154 - 1.96×0.265, 0.154 + 1.96×0.265] = [-0.37, 0.67]
- exp(-0.37) - 1 = -31%, exp(0.67) - 1 = 96%

The correct range is approximately **[-31%, 96%]**, not [-37%, 96%]. The paper should verify these calculations.

**Action:** Recompute confidence intervals from the regression output.

### 2. Abstract Claims "17-24%" But Table Shows 16.7% and 23.7%

Minor rounding inconsistency. Could say "17-24%" or "17-23%", but should be internally consistent.

### 3. Missing Appendix with Additional Robustness

The robustness section mentions:
- Alternative comparison states
- Drug-specific outcomes
- Levels vs. logs

But these are discussed in prose without tables. An appendix with formal robustness tables would strengthen the paper for top journals.

**Action:** Add appendix with robustness tables (optional for this round).

### 4. Event Study Figure Needs Annotation

Figure 3 would benefit from direct annotation of the two policy dates (2019, 2022) on the figure rather than just the caption. The current figure relies on vertical dashed lines, but labels would improve clarity.

### 5. Small Editorial Issues

- Page 4: "oregonmeasure110" citation renders oddly in text
- Table 1 header: "Pre-Treatment (2015–2018)" uses en-dash, should be consistent with body text em-dashes

---

## Assessment of Round 1 Fixes

| Issue | Status |
|-------|--------|
| Fixed effects in equations | ✓ Resolved |
| 660% → 811% | ✓ Resolved |
| Mechanism discussion | ✓ Resolved |
| Few-clusters footnote | ✓ Resolved |
| COVID-19 discussion | ✓ Resolved |
| "Precise null" language | ✓ Resolved |
| Literature expansion | ✓ Resolved |

---

## Decision

**Minor Revision.** The paper has addressed the major methodological concerns. Remaining issues are primarily presentational and can be fixed quickly. After addressing the confidence interval calculation and minor editorial issues, the paper should be ready for external review.

---

## Checklist for Round 2 Revisions

- [ ] Verify confidence interval calculations in Table 2
- [ ] Ensure 17-24% claim is consistent with table
- [ ] Fix Oregon citation rendering
- [ ] Consider adding appendix with robustness tables
- [ ] Optional: Annotate event study figure with policy labels
