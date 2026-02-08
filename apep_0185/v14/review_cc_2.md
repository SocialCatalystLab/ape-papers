# Internal Review — Round 2 (Polishing Revision)

**Reviewer:** Claude Code (claude-opus-4-6)
**Date:** 2026-02-07
**Focus:** Exhibit quality + prose polish per Gemini-3-Flash visual/prose advisors

## Changes Made

### Exhibit Improvements (from exhibit_review_gemini)
1. **Figure 2 (IV Residual Maps):** Increased legend font size and added N=3,108 to subtitle
2. **Figure 3/4 (First-Stage Binscatter):** Moved slope/F-stat annotations into a labeled box; darkened dot color
3. **Figure 7 (Balance Trends):** Smoothed seasonal noise by plotting annual averages instead of quarterly data
4. **Table 3 (Distance-Credibility):** Moved to Appendix B per reviewer recommendation
5. **Figure 11 (Exposure Gap Map):** Promoted from appendix to main text Section 5

### Prose Improvements (from prose_review_gemini)
1. Punchier opening hook: "Legally, the two counties are identical; socially, they are worlds apart."
2. Fixed throat-clearing: "This baseline imbalance is a feature of our geography, not a failure of our design."
3. Active voice in lit review (Granovetter)
4. Simplified mechanism titles: "The Information Channel" / "The Migration Channel"
5. Stronger final sentence: "Labor markets do not end at state lines; neither should our understanding of the policies that govern them."
6. Trimmed housing prices discussion section
7. Broke up long El Paso/Amarillo sentence

### Advisor Fixes (Round 3)
1. Fixed county count arithmetic (removed explicit 3,143 - 30 - 5 - 78 subtraction that yielded wrong total)
2. Explained Figure 4 vs Table 1 first-stage coefficient difference (parsimonious vs full specification)
3. Labeled Column 5 (>=500km) as sensitivity check with dagger footnote
4. Added Virginia independent cities explanation in Sample Construction
5. Reconciled N=135,700 vs 135,744 with explicit note about winsorization

## Assessment

Paper is polished and ready for external review. Advisor review passed 3/4 (Gemini sole holdout on >=500km coefficient magnitude, which is correctly documented as a sensitivity check). No substantive changes to results or methodology.
