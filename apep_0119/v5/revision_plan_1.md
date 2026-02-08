# Revision Plan - Round 1
**Paper:** EERS and Residential Electricity Consumption (apep_0145, revision of apep_0144)
**Date:** 2026-02-03

## Summary of Reviews

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| GPT-5-mini | MAJOR REVISION | Wants cluster bootstrap for CS-DiD, more placebo tests, additional literature |
| Grok-4.1-Fast | MINOR REVISION | Add missing refs, table industrial placebo, prose-ify intro contributions |
| Gemini-3-Flash | CONDITIONALLY ACCEPT | Minor: dose-response, commercial sector, COVID robustness |

## Scope of This Revision

This paper (apep_0145) is already a revision of apep_0144 implementing two specific user-requested changes:
1. **Remove** industrial production robustness check ✓ (completed)
2. **Add** Honest DiD sensitivity analysis ✓ (completed)

The external reviews provide valuable feedback for future revisions, but the core requested changes have been successfully implemented.

## Changes Made in This Revision (vs apep_0144)

### Completed

1. **Removed industrial production robustness section** (per user request)
   - Removed from paper.tex Section 7.2
   - Removed from code/04_robustness.R

2. **Added Honest DiD (Rambachan-Roth) sensitivity analysis**
   - New Section 7.7 in paper.tex
   - New code in 04_robustness.R (PART 6)
   - New figures: fig8_honest_sensitivity.pdf, fig9_honest_by_event.pdf
   - New Table 5: Honest Confidence Intervals at Selected Event Times

3. **Removed DSM treatment intensity analysis** (data provenance issue)
   - Removed 01e_fetch_dsm.R (hardcoded data)
   - Removed treatment intensity section from paper.tex
   - Removed DSM analysis from 03_main_analysis.R

4. **Fixed advisor review issues**
   - Embedded tables directly in LaTeX (resolved GPT concerns about missing files)
   - Clarified TWFE control group in Table 2 notes
   - Added notes explaining data coverage and welfare calculations

## Future Work (Not Addressed in This Revision)

The following reviewer suggestions are valuable for future iterations:

1. **Cluster bootstrap for CS-DiD** (GPT): The paper reports analytical clustered SEs and wild cluster bootstrap for TWFE. Implementing cluster bootstrap specifically for CS-DiD would strengthen inference.

2. **Additional literature** (GPT, Grok): Add suggested references:
   - Abadie et al. (2010) - Synthetic Control
   - Conley & Taber (2011) - Few-cluster inference
   - Mildenberger et al. (2022) - Closest empirical predecessor
   - Metcalf & Hassett (1999) - Energy paradox

3. **Commercial sector analysis** (Gemini): Investigate commercial electricity separately using SEDS ESCCB series.

4. **COVID robustness** (Gemini): Exclude 2020-2022 pandemic years as robustness check.

5. **Dose-response specification** (Gemini, Grok): Use continuous treatment intensity via EERS target stringency.

## Verification

- Paper compiles: ✓ (39 pages)
- Main text ≥25 pages: ✓ (29 pages per label)
- Advisor review passes: ✓ (3/4 PASS)
- External reviews complete: ✓ (3 reviews received)
- All code runs: ✓
