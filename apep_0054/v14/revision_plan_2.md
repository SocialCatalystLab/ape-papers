# Revision Plan 2 - Code Cleanup (Scan Report Fix)

## Purpose
Targeted cleanup to address GPT-5.2 scan report findings from v13.

## Changes Made

### 1. Deleted `code/01_fetch_data.R`
- 215-line Auto-IRA / CPS ASEC code file entirely unrelated to this paper's Salary Transparency / QWI analysis
- Flagged as METHODOLOGY_MISMATCH in scan report
- No downstream script depended on it; actual data fetch is `01_fetch_qwi_fast.R`

### 2. Fixed Table 1 footnote in `code/06_tables.R`
- Changed "1995-2023" to "2015Q1--2023Q4" to match the actual QWI data range
- Flagged as SUSPICIOUS_TRANSFORMS in scan report

### 3. Updated revision footnote in `paper.tex`
- Corrected parent reference from apep_0174 to apep_0054
- Fixed URL to use public `ape-papers` repository
- Fixed duplicate "Correspondence" text in author line

## Not Changed
- All other code files are clean and relevant
- Paper content unchanged (no substantive revisions)
- DATA_PROVENANCE_MISSING flag is benign (treatment timing correctly created in `01_fetch_qwi_fast.R`)
- HARD_CODED_RESULTS flag in `04e_power_analysis.R` is acceptable defensive coding

## Reviewer Feedback Note
All three external reviewers (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash) recommended MINOR REVISION. No fatal issues identified. Suggestions for future iterations include updated data, compliance evidence, and additional heterogeneity analysis.
