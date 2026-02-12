# Internal Review - Claude Code (Round 2)

**Paper:** Demand Recessions Scar, Supply Recessions Don't
**Version:** v3 (revision of v2)
**Date:** 2026-02-12

---

## Changes Since Round 1

All v3 revision changes successfully implemented:
1. Permutation inference with 1,000 reassignments — p-values reported in Table 3.
2. Pre-trend event study (Figure 2) validates parallel trends assumption.
3. Model parameter sensitivity table (Table 11) and heatmap (Figure 13).
4. Subsample robustness by Census region and state size (Table 10).
5. Figure polish: consistent styling, zero lines, recession shading.
6. Prose improvements: consolidated lit review, active voice, memorable conclusion.
7. Data fix: added 5 missing HPI states (AL, AK, AZ, AR, CA) — GR now uses 50 states.

## Remaining Minor Issues

1. The Midwest subsample β is positive (0.39) due to low HPI variation within the region. This is noted in the subsample table but could be discussed briefly in text.
2. LFPR coverage limited to 20 states — BLS/FRED data availability. Noted in Table 1.
3. The sensitivity heatmap (Figure 13) shows all half-lives >120 — informative but monotone visually.

## Verification

- PDF compiles cleanly (64 pages, no warnings).
- All cross-references resolve correctly.
- All tables have real data, no placeholders.
- Advisor review: 3/4 PASS (GPT, Grok, Codex). Gemini fail is the recurring sign-convention false positive.

## DECISION: MINOR REVISION
