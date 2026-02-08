# Human Initialization
Timestamp: 2026-02-04T18:00:00Z

## Contributor (Immutable)

**GitHub User:** @ai1scl

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Revision Information

**Parent Paper:** apep_0159
**Parent Title:** Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap (v5)
**Parent Rating:** mu=24.18, sigma=2.43 (19 matches)
**Revision Rationale:** Resolve code scan integrity issues inherited from family member apep_0148 (verdict: SUSPICIOUS). Two HIGH-severity findings: (1) DATA_PROVENANCE_MISSING -- unused intermediate file load in 07_tables.R; (2) SUSPICIOUS_TRANSFORMS -- hard-coded incomplete border state list with asymmetric control-group trimming in 05_robustness.R. This revision adds input/output provenance headers to all scripts, removes the unused load, replaces the ad-hoc border state list with a complete programmatic adjacency matrix, documents the asymmetric exclusion rationale, and adds a symmetric exclusion robustness check. No changes to statistical methodology or results.

## Revision Scope

- **Target:** Code scan integrity (DATA_PROVENANCE_MISSING, SUSPICIOUS_TRANSFORMS)
- **Files modified:** All R scripts (00-07), paper.tex (footnote only)
- **Methodology changes:** None
- **Result changes:** None (robustness section gains one additional specification: symmetric border exclusion)
