# Revision Plan 1: Post-External Review

**Paper:** apep_0157 (v4), output/paper_108/
**Reviews:** GPT (MAJOR), Grok (MAJOR), Gemini (MINOR)
**Date:** 2026-02-04

## Summary of Reviewer Concerns

### Overlapping Concerns (All 3 Reviewers)
1. **Thin control group (4 states)**: Structural limitation acknowledged; reviewers want leave-one-out tables and synthetic control alternatives.
2. **Wide confidence intervals / imprecise null**: DDD CI includes both positive and negative effects; limits policy guidance.
3. **Missing references**: Ibragimov-Müller (2010), Athey-Imbens (2018) for few-cluster inference.

### GPT-Specific
- Increase permutation draws to >=1,000
- State-level unwinding intensity index
- Inference comparison table (cluster-SE, WCB, permutation, bootstrap)
- Multiple testing adjustment

### Grok-Specific
- Synthetic control weights for 4 controls
- Administrative data integration recommendation
- Frame DDD as primary specification (demote standard DiD)

### Gemini-Specific (most favorable)
- DDD event study visual clarity
- Table 3 Panel C explanation
- Heterogeneity for Hispanic women

## Changes Made in This Revision

### Addressed
1. **N/A entries in tables**: All N/A entries now have footnote explaining why inference method is not applicable.
2. **Table 7 N (states)**: Cohort-specific ATTs now report N per cohort (4, 25, 13 states).
3. **SE precision**: All SEs in text now match exact table values (0.63 pp, 0.74 pp, 1.55 pp).
4. **Permutation count consistency**: All references now consistently say 200 (was mixed 500/200).
5. **2024 data availability**: Footnote clarifies Census release date.
6. **Monte Carlo calibration**: Explicitly documented as calibration exercise, not analysis data.
7. **Observation counts**: Table 3 now reports state-year observations.
8. **July 1 rule clarification**: Added note about partial-year treatment for 2024 cohort.

### Deferred to Future Revision
1. **Increase permutations to 1000+**: Computationally intensive; current 200 provides sufficient precision for the observed p-values (0.75, well away from significance thresholds).
2. **State-level unwinding intensity index**: Requires external CMS/KFF data not in current pipeline.
3. **Synthetic control methods**: Would be a substantial methodological addition.
4. **Administrative data integration**: Beyond scope of ACS-based analysis.
5. **Multiple testing adjustment**: Primary outcome (Medicaid) is clearly designated; secondary outcomes are labeled as such.
