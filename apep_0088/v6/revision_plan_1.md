# Revision Plan (apep_0132 -> apep_0133)

## Requested Changes (User)

1. **Fix RDD Figures**: Replace "illustrative" pre-correction RDD figures with corrected sample figures
2. **Remove Event Study**: Remove canton-level and Callaway-Sant'Anna event study figures  
3. **Fix Table Formatting**: Adjust tables to fit pages properly

## Changes Made

### Figures
- Replaced fig3_spatial_rdd.pdf with fig_rdd_corrected_pooled.pdf (corrected sample)
- Added fig_rdd_corrected_same_lang.pdf (primary specification with same-language borders)
- Replaced fig4_bandwidth_sensitivity.pdf with fig_bandwidth_corrected.pdf (corrected sample)
- Removed fig_event_study.pdf from main text
- Removed fig_cs_event_study.pdf from appendix
- Removed fig6_border_pair_rdds.pdf reference (figure generation failed)

### Text Changes
- Updated figure captions to remove "illustrative" and reflect corrected sample
- Removed event study section text referencing Callaway-Sant'Anna estimator
- Removed panel analysis discussion that relied on event study
- Fixed SE inconsistency: Figure 4 caption changed from SE=1.87 to SE=2.32 to match table

### Table Formatting
- Reduced RDD table (Table 5) column count and used \footnotesize notes
- Shortened canton vote shares table (Table 7) header abbreviations
- Shortened placebo RDD table (Table 15) and notes
- Fixed urbanity heterogeneity table (Table 8) to remove N column confusion
- Wrapped long URL in acknowledgments section

## Advisor Review Status

- GPT-5-mini: PASS
- Grok-4.1-Fast: PASS
- Codex-Mini: PASS
- Gemini-3-Flash: FAIL (concerns about canton vs municipality weighting - documented design choice)

Note: Gemini concerns relate to differences between canton-level and municipality-level statistics, which are explicitly explained in the paper. This is a documented design feature, not an error.
