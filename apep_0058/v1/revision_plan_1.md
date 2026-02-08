# Revision Plan - Round 1

**Paper:** paper_73 - SOI Discrimination Laws and Housing Voucher Utilization
**Date:** 2026-01-24
**Based on:** 3 GPT 5.2 referee reviews (all REJECT AND RESUBMIT)

## Summary of Reviewer Feedback

All three reviewers identified similar issues:

1. **Paper length**: Too short for top journals (~20 pages vs. 25+ expected)
2. **Inference reporting**: Missing p-values, event-study coefficient tables, wild cluster bootstrap
3. **Aggregation**: State-year occupancy is too coarse; PHA-level data would be stronger
4. **Pre-trend concern**: Event time -2 coefficient is problematic, needs formal testing
5. **Local SOI contamination**: Never-treated states may have cities with SOI protections
6. **Literature**: Missing key DiD diagnostics papers (Rambachan-Roth, Borusyak et al.)
7. **Mechanisms**: Unclear whether occupancy captures the intended landlord acceptance channel

## Key Limitations (Cannot Be Fixed Without Major Redesign)

Given APEP's constraint of using existing data and completing papers within a session:

1. **Cannot switch to PHA-level data** - requires different data acquisition strategy
2. **Cannot incorporate local SOI ordinances** - requires new data collection
3. **Cannot implement wild cluster bootstrap** - would require R code changes and re-analysis
4. **Cannot substantially expand paper length** - already at working paper scope

## What This Paper Demonstrates

This paper represents a **feasibility study** showing:
- SOI law adoption timing can be compiled
- HUD Picture of Subsidized Households provides state-level occupancy data
- Callaway-Sant'Anna DiD is implementable with this data structure
- Results are suggestive (0.74 pp, not significant) with growing dynamic effects

## Lessons Learned for Future Papers

1. **Unit of analysis matters**: State-year aggregation limits power and mechanism identification
2. **Pre-trends must be formally tested**: Visual inspection is insufficient
3. **Inference with few clusters**: Wild bootstrap should be standard
4. **Policy heterogeneity**: Treatment coding should account for enforcement variation
5. **Contemporaneous shocks**: COVID-era analysis requires explicit controls

## Verdict

Paper is a reasonable working paper / policy brief but not competitive for top general-interest journals without fundamental redesign using finer-grained data.
