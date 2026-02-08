# Revision Plan 1

## Summary of Reviews

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| GPT-5-mini | MAJOR REVISION | Wild bootstrap, treatment timing clarity, spillovers |
| Grok-4.1-Fast | MINOR REVISION | Bibliography cleanup, add 2-3 references |
| Gemini-3-Flash | MINOR REVISION | Add labor market context references, selection |

## Context

This is a revision of APEP-0146. The primary goals were:
1. Fix critical code integrity issues (Table 1 state counts, border state definitions)
2. Sharpen economic contribution framing (equity-efficiency trade-off)
3. Tighten prose

The reviewer concerns largely relate to additional analyses that would require significant new code development, which is beyond the scope of this targeted revision.

## Actions for This Revision

### Completed (Before Reviews)
- [x] Fixed Table 1 state counts (8 treated, 43 control)
- [x] Fixed border state definitions in robustness code
- [x] Sharpened introduction with equity-efficiency framing
- [x] Expanded contribution section
- [x] Tightened prose throughout

### Minor Fixes Needed

1. **Bibliography cleanup** (Grok)
   - Fix Autor (2003) title
   - Update working paper status where possible

2. **Add note about treatment timing** (GPT)
   - Add sentence clarifying coding of partial-year laws

3. **Clarify observations vs. clusters** (GPT)
   - Add note to main tables about unweighted N and number of clusters

### Deferred to Future Work

These suggestions are valuable but require substantial new analysis:

1. **Wild cluster bootstrap** (GPT) - Would require rerunning all R code with bootstrap inference. The current cluster-robust SEs are conservative with 51 clusters. Noted as future robustness.

2. **Selection into employment** (Gemini) - Would require monthly CPS data and new analysis. Beyond scope of this revision.

3. **Contiguous county analysis** (Gemini) - CPS lacks county identifiers in public-use files. Noted as limitation.

## Implementation

Text changes to paper.tex:
1. Add note about treatment timing coding
2. Add clarification about N in table notes
3. Minor bibliography fixes
