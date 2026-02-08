# Revision Plan 1

## Summary of Revision (from parent APEP-0190)

This paper is a revision of apep_0190 addressing all three reviewers' MAJOR REVISION concerns:

### Changes Made in This Revision

1. **Shock-Robust Inference (AKM/Adão et al.)**: Added two-way clustering (state + year) and permutation inference. Results remain significant under all inference methods.

2. **Rambachan-Roth Pre-Trend Sensitivity**: Added explicit sensitivity analysis section discussing how conclusions would change under parallel trends violations.

3. **Magnitude Calibration**: Added back-of-envelope calibration comparing our implied elasticity to labor supply elasticity literature (Chetty 2012).

4. **Migration Mechanism Test**: Created new code script (04b_mechanisms.R) to test whether migration rather than information drives effects using IRS SOI data.

5. **Pre-Period Weight Fix**: Updated text to clarify that population weights use pre-treatment (2012-2013) employment, not full-sample average, per Borusyak et al. (2022) requirements.

6. **Missing Literature Added**:
   - Goodman-Bacon (2021) on staggered DiD
   - Jäger et al. (2024) on worker beliefs about outside options
   - Topa (2001) on social interactions and labor markets
   - Clemens & Strain (2021) on minimum wage effects
   - Chetty (2012) for magnitude calibration

7. **New Title**: "Friends in High Places: How Social Networks Transmit Minimum Wage Shocks"

8. **Fixed Data Issues**:
   - Corrected minimum exposure values in summary statistics (now ≥ log(7.25))
   - Clarified county count arithmetic (3,030 + 23 VA independent cities = 3,053)
   - Fixed code column name standardization

### Referee Decisions on Revision

- GPT-5-mini: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

This represents improvement from the parent paper which received 3x MAJOR REVISION.

## Actions Taken

- Updated 03_main_analysis.R with shock-robust inference
- Updated 04_robustness.R with Rambachan-Roth sensitivity
- Created 04b_mechanisms.R for migration test
- Added 6 citations to references.bib
- Updated paper.tex with new literature, magnitude discussion, mechanism tests
- Fixed summary statistics table
- Clarified sample construction
