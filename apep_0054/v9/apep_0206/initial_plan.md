# Initial Plan: Code Scan Fix for APEP-0159

## Parent Paper
- **ID:** apep_0159 (v5 in the apep_0054 family)
- **Title:** Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap
- **Rating:** mu=24.18, sigma=2.43

## Objective
Resolve two HIGH-severity code scan findings inherited from family member apep_0148:

1. **DATA_PROVENANCE_MISSING** (07_tables.R): Remove unused `desc_stats` load; add provenance headers
2. **SUSPICIOUS_TRANSFORMS** (05_robustness.R): Replace hard-coded border states with programmatic adjacency

## Exposure Alignment (from parent apep_0159)

The treatment is salary transparency laws requiring employers to disclose salary ranges in job postings. The outcome is individual hourly wages from the CPS ASEC (income in previous calendar year). Treatment timing is coded to the first full income year affected: laws effective January 1 use that year; mid-year laws use the following year. This aligns outcome measurement with actual policy exposure. Sample: wage/salary workers ages 25-64 (directly affected population). State-level treatment variation matches the geographic unit of legislation.

## Scope
- Code integrity fixes only
- No changes to statistical methodology or results
- Paper content unchanged except title footnote documenting revision lineage
