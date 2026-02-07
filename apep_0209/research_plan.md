# Research Plan: Code Scan Fix for APEP-0159

## Parent Paper
- **ID:** apep_0159 (v5 in the apep_0054 family)
- **Title:** Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap
- **Rating:** mu=24.18, sigma=2.43

## Revision Tasks

### Fix 1: 07_tables.R
- Remove unused `desc_stats <- readRDS("data/descriptive_stats.rds")` (line 15)
- Add provenance header documenting all 13 input files with source scripts
- Add file existence check loop for required inputs

### Fix 2: 05_robustness.R
- Replace hard-coded border state list (lines 146-155) with complete US Census Bureau state adjacency matrix
- Derive border states programmatically from adjacency lookup
- Document asymmetric exclusion rationale
- Add symmetric exclusion as additional robustness specification (Section 4b)
- Add provenance header

### Fix 3: 06_figures.R
- Add provenance header and file existence checks

### Fix 4: Scripts 00-04
- Add input/output provenance headers to all upstream scripts

### Fix 5: paper.tex
- Update title footnote to reference apep_0159 as parent

## Exposure Alignment (from parent apep_0159)

The treatment is salary transparency laws that require employers to disclose salary ranges in job postings. The outcome is measured via individual hourly wages from the CPS ASEC, which asks about income in the previous calendar year. Treatment timing is coded to the first full income year affected:
- Laws effective January 1 -> income year = effective year
- Laws effective mid-year -> income year = following year (most wages earned pre-law)

This ensures the outcome measurement window aligns with actual policy exposure. The CPS ASEC uses the ASECWT person weight, and the sample restricts to wage/salary workers ages 25-64 who are directly affected by the laws. The analysis uses state-level treatment variation (FIPS-coded) matching the geographic unit at which the laws are enacted.

## No-Change Guarantee
- Statistical methodology: unchanged
- Regression specifications: unchanged
- Results and interpretation: unchanged
- Paper text: unchanged (except footnote)
