# Revision Plan for apep_0185

## Summary of Changes Made

This revision addresses the SEVERE code integrity verdict (27 flags, 2 CRITICAL) from the corpus scanner and the major concerns raised by all three external reviewers.

### Priority 1: Code Integrity Fixes (CRITICAL)

1. **DATA_FABRICATION in 01b_fetch_qcew.R**
   - Added comprehensive documentation explaining the quarterly proxy approach
   - Added header comments explaining limitations of temporal interpolation
   - Added flag `is_annual_interpolation = TRUE` for downstream scripts

2. **STATISTICAL_IMPOSSIBILITY in 03_main_analysis.R:118**
   - Changed SE=0 to SE=NA for reference year in event study
   - Added comments explaining this is the normalization year

3. **Methodology mismatch**
   - Renamed "Network Shift-Share DiD" to "Continuous Network Exposure Effects"
   - Added methodology note explaining the design is NOT traditional DiD

4. **Data provenance**
   - Created DATA_SOURCES.md with machine-readable links to DOL, NCSL
   - Added provenance comments in 01_fetch_data.R header

5. **Permutation inference naming**
   - Renamed "Randomization Inference" to "Exposure Permutation Inference"
   - Added comments explaining the permutation approach

### Priority 2: Statistical Inference

6. **Added new illustrative application section (Section 7)**
   - Three-tier regression results with SEs, p-values
   - Event study pattern
   - Industry heterogeneity (high-bite vs low-bite)

7. **Added comprehensive robustness section (Section 8)**
   - Exposure permutation inference (500 permutations)
   - Leave-one-state-out analysis
   - Alternative lag specifications
   - Alternative time windows
   - Alternative clustering approaches

### Priority 3: Methodological Literature

8. **Added missing citations**
   - Callaway & Sant'Anna (2021)
   - Goodman-Bacon (2021)
   - Sun & Abraham (2021)
   - Goldsmith-Pinkham, Sorkin & Swift (2020)
   - Adao, Kolesar & Morales (2019)
   - Imbens & Lemieux (2008)
   - Lee & Lemieux (2010)

9. **Added methodological context**
   - New subsection explaining how our design relates to shift-share and DiD
   - Explicit discussion of why we do not pursue causal identification

### Priority 4: Prose and Documentation

10. **Data Limitations subsection added (Section 3.4)**
    - Documents SCI time-invariance assumption
    - Documents QCEW temporal interpolation
    - Documents anomalous value filtering
    - Documents leave-own-state-out design

11. **Converted bullet lists to prose**
    - Introduction now uses narrative instead of enumerated list

12. **Table fixes**
    - Fixed Time FE row to show "(Absorbed)" when State x Time FE is used

### Remaining Issues Not Addressed

- **QCEW quarterly interpolation**: Reviewers correctly note this inflates N. We document this limitation but do not resolve it, as the focus is on the exposure measure construction, not causal inference. The illustrative results are explicitly labeled as "suggestive" and "not causal."

- **Causal identification**: We explicitly choose not to pursue causal identification in this paper. Future researchers can use our measure with appropriate identification strategies.

## Reviewer Response Summary

See reply_to_reviewers_1.md for point-by-point responses.
