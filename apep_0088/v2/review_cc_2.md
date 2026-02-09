# Internal Review — Round 2 (Post-Advisor Fixes)

**Reviewer:** Claude Code
**Date:** 2026-02-07

## Changes Since Round 1

### Fatal Errors Fixed (from GPT and Gemini advisors)

1. **Referendum panel inconsistency (FIXED):** Clarified that Table 7 uses 2000+2003+2016+2017 for descriptive comparison, while DiDisc (Table 9) uses 2003+2016green+2016nuclear+2017. Each section now explicitly states which referendums are used.

2. **Contradictory descriptive statistics (FIXED):** Added note to Table 7 explaining why canton-level treated>control (+6.9pp) while Gemeinde-level treated<control (-9.6pp): weighting differences (each canton equally vs. dominated by small rural German municipalities).

3. **Placebo sample construction (FIXED):** Expanded Table 15 note to justify why placebo uses pre-correction sample. Added DiDisc cross-reference showing it addresses permanent border effects.

4. **CI asymmetry (FIXED):** Added note to Table 5 explaining bias-corrected CIs from rdrobust can be asymmetric.

5. **Wild cluster bootstrap cluster count (FIXED):** Changed "---" to "26" in Table 10.

6. **Donut RDD sign flip (FIXED):** Added clarifying note that sign reversal at 2km is expected because excluding near-border municipalities removes the identifying variation.

7. **"Sign never flips" claim (FIXED):** Changed to "sign is consistently negative across all main specifications" with parenthetical about donut at extreme radii.

### DiDisc Staggered Treatment (Fixed in Round 1)
- Canton-specific timing now used: GR 2011, BE 2012, AG 2013, BL 2016, BS 2017
- Border-pair FE: -4.65pp (p=0.008) — independently significant

## Current Status

- **Advisor review:** 3/4 PASS (GPT, Grok, Codex PASS; Gemini FAIL on minor issues)
- **Exhibit review:** Complete (mostly KEEP AS-IS)
- **Prose review:** Complete ("top-journal ready")
- **Page count:** 53 pages
- **All main specifications consistent and clearly documented**

## Remaining Concerns

- Gemini still flags CI asymmetry and donut sign flip, but these are explained in the text
- Tables 16 and 18 are summary/parameter tables (appropriate for appendix)

## Verdict

Ready for external referee review.
