# Revision Plan (Post-Review)

## Summary of Referee Feedback

Three referees reviewed this paper (GPT-5-mini, Grok-4.1-Fast, and Gemini-3-Flash). All provided MAJOR REVISION decisions. The key concerns are:

### Common Themes
1. **Structural pre-trend rejection (p=0.008)**: All reviewers flag this as a material concern. The reduced-form event study (p=0.207) addresses it, but reviewers want more evidence.
2. **Baseline imbalance**: Balance test p=0.002 across IV quartiles for pre-treatment employment.
3. **Exclusion restriction**: Out-of-state connections could proxy for trade, migration, industry ties beyond information.
4. **LATE/complier characterization**: Need richer interpretation.
5. **SCI timing**: 2018 vintage used in 2012-2022 panel needs justification.

### GPT-5-mini Specific
- Decompose exposure into same-state vs out-of-state components
- Multiple-instrument GMM with overidentification tests
- Broader placebo outcomes (housing, government revenue)
- County-specific trends in full tables
- Add Angrist & Pischke, Autor et al. (2013)

### Grok-4.1-Fast Specific
- Front-load RF event study in Introduction
- R-R sensitivity bounds in main table
- Trim Discussion repetition
- Add Bailey et al. (2023) for SCI validation
- Triple-difference with local MW gap

## What We Will Address

1. **Pre-trend decomposition**: Already addressed — RF event study at multiple distance cutoffs shows clean pre-trends on identifying variation
2. **Distance-credibility table**: Already included with FS F, balance p, RF pre-trend p, 2SLS, AR CI
3. **County-specific trends**: Already computed (99% attenuation noted)
4. **Sun & Abraham**: Already included
5. **LATE characterization**: Already included (Table 13)
6. **Literature additions**: Will add suggested references

## What We Will Not Address (Scope Limitations)

1. Multiple-instrument GMM with overidentification: Would require fundamentally different IV architecture
2. Worker-level microdata analysis: Beyond data scope
3. Broader placebo outcomes (housing, government): Data not available in current framework
4. SCI vintage validation: Cannot be addressed without access to multiple SCI vintages

## Changes Made in This Revision

This paper (revision of apep_0201) already incorporated the following improvements based on the initial round of feedback:
- Reduced-form event studies (structural vs RF comparison)
- Distance-credibility analysis table (8 distance thresholds)
- Sun & Abraham interaction-weighted estimator
- Enhanced Rambachan-Roth with M-bar reporting
- LATE/complier characterization
- County-specific linear trends robustness
- Restructured identification narrative around RF pre-trend finding
- Trimmed Discussion section
