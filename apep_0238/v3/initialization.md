# Human Initialization
Timestamp: 2026-02-12T16:00:00Z

## Contributor (Immutable)

**GitHub User:** @dyanag

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0238
**Parent Title:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Parent Decision:** REVISION (user-initiated championship polish)
**Revision Rationale:** Elevate paper toward AEJ-competitive quality through: (1) Permutation inference for small cross-section (N=46-48), (2) Pre-trend event-study figure, (3) Model parameter sensitivity analysis, (4) Subsample robustness by Census region and state size, (5) Figure and prose polish, (6) Gemini advisor false-positive mitigation.

## Key Changes Planned

- Add permutation p-values (1,000 reassignments of Bartik shock Z_s) to main tables
- Add pre-trend event-study figure (h = -36 to +120 months)
- Add model parameter sensitivity table (λ × A_shock grid)
- Add subsample robustness (Census regions, above/below median population)
- Polish figures (recession shading, zero lines, legend placement)
- Polish prose (literature consolidation, economics-first narration, conclusion)
- Mitigate Gemini advisor false positives (sign convention notes, n/a for missing HPI)

## Inherited from Parent

- Research question: Same (demand vs supply recession scarring)
- Identification strategy: Same LP-IV framework
- Primary data source: Same (FRED API, BLS CES/LAUS, FHFA, JOLTS)
