# Reply to Reviewers

## Revision: Code Scan Fix for apep_0159 (Salary Transparency Laws v5 -> v6)

**Revision type:** Code integrity fix (no methodology changes)

---

## Scope Note

This revision addresses **two HIGH-severity automated code scan findings** that flagged family member apep_0148 as SUSPICIOUS and would persist in apep_0159 if scanned. The changes are strictly limited to code integrity: provenance documentation, removal of an unused file load, and replacement of an ad-hoc hard-coded data structure with a programmatic alternative.

The substantive methodology feedback from reviewers (small-cluster inference, pre-trend concerns, compliance measurement) is acknowledged as valid but is **out of scope** for this code-scan-fix revision. A future substantive revision may address these points.

---

## Response to GPT-5-mini

**Decision: MAJOR REVISION**

Thank you for the thorough review. The methodological concerns you raise -- small-cluster inference, pre-trend fluctuations, bootstrap/permutation discrepancy, and compliance measurement -- are valid and important. These are properties of the underlying research design that this code-integrity revision does not alter. The substantive content of the paper is unchanged; only code provenance and documentation have been improved.

---

## Response to Grok-4.1-Fast

**Decision: MINOR REVISION**

Thank you for the positive assessment of the methodology and identification strategy. Your suggestions regarding missing references (Obloj & Zenger 2023, Card et al. 2022) and prose conversion from bullets are noted for a future substantive revision. This revision addresses only the code scan issues.

---

## Response to Gemini-3-Flash

**Decision: MAJOR REVISION**

Thank you for the detailed review. Your concern about the "High-Bargaining" composition shift (Table 13) and the suggestion for Lee (2009) bounds analysis is well-taken and would strengthen the paper in a future revision. Your suggestion to drop NY/HI as a robustness check is also valuable. These substantive changes are beyond the scope of this code-integrity fix.

---

## Summary of Code Changes

| Issue | File | Fix |
|-------|------|-----|
| DATA_PROVENANCE_MISSING | 07_tables.R | Removed unused `desc_stats` load; added provenance header + file checks |
| SUSPICIOUS_TRANSFORMS | 05_robustness.R | Replaced hard-coded border list with Census Bureau adjacency matrix; documented asymmetric exclusion; added symmetric check |
| Provenance gaps | All scripts (00-07) | Added input/output provenance headers |
| Missing validation | 06_figures.R, 07_tables.R | Added file existence checks |
| Lineage tracking | paper.tex | Updated title footnote |
