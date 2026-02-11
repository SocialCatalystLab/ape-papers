# Revision Plan (Round 1)

## Summary of Reviews
- **GPT-5-mini:** MAJOR REVISION — small control pool, pre-trends, DC outlier, need wild bootstrap, more RI permutations, leave-one-out, state-specific trends
- **Grok-4.1-Fast:** MINOR REVISION — expand RI to 1000, add 3-4 references, minor polish
- **Gemini-3-Flash:** MINOR REVISION — PPML estimation, leave-one-out for DC, add references

## Common Themes
1. More RI permutations (200→1000) — all three reviewers
2. Leave-one-out analysis for DC influence — GPT, Gemini
3. Additional references — all three
4. State-specific linear trends as robustness — GPT
5. Wild cluster bootstrap — GPT
6. Sensitivity with ambiguous states included — GPT

## Planned Changes

### A. New Analyses (R code)
1. **Increase RI to 1000 permutations** — update 04_robustness.R, recompile
2. **Leave-one-out aggregate ATT** — drop each treated state, recompute aggregate
3. **State-specific linear trends** — add linear state trends to TWFE specification
4. **Sensitivity: include ambiguous states as untreated** — re-run CS with AK, NE, OR, WY as controls

### B. Paper Revisions
1. Add suggested references to references.bib
2. Report leave-one-out results in appendix (or main text)
3. Report state-specific trends result
4. Update RI p-value from 1000 permutations
5. Note ambiguous-states sensitivity result in robustness section
6. Address functional form concern more explicitly (note PPML as future work)

### C. Not Addressed (scope limitations)
- Synthetic control for DC: valuable but substantial additional analysis beyond scope of v1
- Sub-state/county analysis: data not available at required granularity from VSRR
- FTS distribution volumes: data not publicly available
- PPML: beyond scope; noted as suggestion for future work
- Wild cluster bootstrap: attempted if `fwildclusterboot` available; otherwise noted
