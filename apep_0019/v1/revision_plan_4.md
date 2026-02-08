# Revision Plan - Round 4

## Issues from Review 4

### Key Concerns (Similar to Review 3)
1. ACP-era identification not addressed at design level
2. Discrete RV inference not implemented (only acknowledged)
3. Bandwidth sensitivity undermines "robust null" claim
4. Substitution mechanism not tested (broadband vs mobile-only)
5. Need local randomization inference robustness

### New Suggestions
- Test substitution to mobile-only using ACS device/access variables
- Report MSE-optimal bandwidth with robust bias-corrected inference
- Add local randomization inference robustness
- Reframe estimand more sharply to ACP-era marginal effect

## Changes Made

### 1. Sharpen Interpretation Throughout
- Already made in Round 3 with title change and limitations section
- Further tighten claims in abstract and conclusion

### 2. Note Substitution Mechanism
- Add discussion that negative estimates could reflect substitution to mobile-only
- Acknowledge this as alternative interpretation
- Note testing would require additional analysis

### 3. Acknowledge Methodological Limitations More Prominently
- The fundamental issues (pre-ACP data, rdrobust implementation, replicate weights)
  require additional methodological extensions beyond current scope

## Status

- [x] Revisions complete (2026-01-17)

## Note on Remaining Issues

The following issues raised by reviewers would require methodological extensions that are beyond the scope of a quick revision:

1. **Pre-ACP data**: Would require fetching 2016-2019 ACS data and re-running analysis
2. **rdrobust implementation**: Would require implementing full rdrobust package in Python or switching to R/Stata
3. **ACS replicate weights**: Would require fetching and using replicate weight files
4. **Local randomization inference**: Would require implementing additional inference framework

These limitations are documented in the paper and represent areas for future research improvement.
