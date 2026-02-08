# Revision Plan - Round 1

## Summary of Reviewer Feedback

All three reviewers returned **REJECT AND RESUBMIT** verdicts, citing:

1. **Insufficient treated clusters**: Only 3-4 treated states in sample (CT, IN, CA, WA), with effectively 2 providing meaningful variation (IN and CA)
2. **Inference not credible**: Standard clustered SEs unreliable with so few treated clusters
3. **Outcome mismatch**: Total suicide used instead of firearm-specific suicide
4. **Missing treatment intensity**: Binary law-on-books ignores actual ERPO utilization rates
5. **Panel too short**: 1999-2017 excludes the 2018-2019 adoption wave
6. **Missing references**: Need additional citations on few-treated inference

## Assessment

These are **fundamental design limitations** that cannot be fully addressed without:
- Extending the data panel beyond 2017 (requires different data sources)
- Obtaining firearm-specific suicide data (programmatically difficult from CDC)
- Collecting ERPO utilization intensity data (state-by-state administrative records)
- Implementing randomization inference / wild cluster bootstrap

## Revisions Made in This Session

The paper was extensively revised during advisor review rounds to fix fatal errors:

1. **Excluded Connecticut from main specification** (no clean pre-period)
2. **Clarified partial treatment in transition years** for IN (2005) and WA (2016)
3. **Fixed internal consistency issues** throughout tables and text
4. **Moved cohort-specific effects to appendix** (no valid inference)
5. **Corrected group definitions** for never-treated states
6. **Updated robustness table** with consistent sample counts

## Limitations Acknowledged in Paper

The paper explicitly acknowledges:
- Reverse causation likely explains positive estimates
- TWFE vs C-S sign reversal suggests selection effects
- Only 3 treated cohorts with clean pre-periods
- Outcome (total suicide) attenuates firearm-specific effects
- Binary treatment ignores implementation intensity

## Decision

Given the fundamental design constraints (early adopters only, no firearm-specific data, 1999-2017 panel), this paper represents a **honest null/cautionary result** rather than a credible causal estimate. The contribution is documenting why ERPO evaluation with early adopters alone is empirically challenging.

The paper passes advisor review (no fatal errors) and can be published as-is with REJECT AND RESUBMIT as the external review verdict.
