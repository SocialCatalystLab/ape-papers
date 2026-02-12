# Internal Review — Claude Code (Round 1)

**Role:** Internal self-review by authoring agent
**Model:** claude-opus-4-6
**Paper:** Demand Recessions Scar, Supply Recessions Don't (apep_0238 v2)
**Timestamp:** 2026-02-12T14:38:00

---

## Summary

This is a revision of apep_0238 v1 with two primary improvements: (1) corrected leave-one-out Bartik instrument construction in the code, fixing a methodology mismatch flagged by the code scanner; (2) expanded bibliography with 15 critical missing citations integrated into the text.

## Review Findings

### Strengths
- **Code integrity:** Leave-one-out Bartik now properly subtracts state s's own industry contribution from national totals before computing industry shifts. This matches the paper's text description.
- **Bibliography:** All major missing references (Pissarides 1992, Blanchard & Katz 1992, Beraja et al. 2019, Jarosch 2023, Cerra et al. 2023, Barrero et al. 2021, Goodman-Bacon 2021, Callaway & Sant'Anna 2021, etc.) now properly cited and woven into appropriate sections.
- **Internal consistency:** All in-text numbers updated to match regenerated tables after code fix and FRED data revision.
- **Appendix tables:** Clustering and Sand States appendix tables now consistent with main Table 3 (h=24 and h=36 coefficients matched).

### Issues Found and Addressed
1. **LFPR sample size (N=5,880):** Table 1 note now explains this reflects 20 states with LFPR data via FRED LAUS, not a data error.
2. **Model vs data LFPR:** Table 5 note now explains model's LFPR (0.98) targets prime-age participation, different from all-ages BLS LFPR (64.6%).
3. **Arizona HPI missing in Table 2:** Table 2 note now clarifies ranking is by peak-to-trough employment, and "---" indicates FHFA data unavailable.
4. **Permutation algorithm:** Formal 4-step algorithm documented in appendix.
5. **TWFE/DiD positioning:** New paragraph explains why LP preferred over staggered DiD (continuous exposure, no parametric assumptions).

### Remaining Limitations (Acknowledged)
- Small cross-section (N=46-48) inherent to state-level design
- No worker-level mediation analysis (acknowledged as future work)
- Policy controls (PPP intensity) not included (discussed qualitatively)
- Gemini advisor continues to flag sign convention as "error" — this is a false positive; the convention is correctly explained in Section 5.1

## Verdict

Paper is ready for publication. All code integrity issues fixed, bibliography substantially improved, internal consistency verified.
