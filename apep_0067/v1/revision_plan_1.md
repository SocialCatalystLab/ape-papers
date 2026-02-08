# Revision Plan - Round 1

## Summary of Reviewer Concerns

All three reviewers recommended "Reject and Resubmit" with the following key concerns:

1. **Modern DiD Methods**: TWFE is not acceptable for staggered adoption with heterogeneous effects
2. **Inference**: Cluster-robust SEs invalid with few effective switchers; need permutation/randomization inference
3. **Identification**: Few switchers (16 states, mostly 2014-2015) limits statistical power

## Changes Made

### 1. Modern Inference (New Section - Appendix C.1)
- Implemented Fisher-style **permutation inference** (999 permutations)
- Result: p-value = 0.42, confirming null result
- Restricted to clean sample: 21 never-treated + 5 switchers in 2015 only

### 2. Fixed Data Documentation
- Corrected switcher count: 16 states (not 5) across 2010-2019
- Updated Table 1 jurisdiction counts
- Clarified that permutation uses 2015 cohort subset for clean inference

### 3. Added Missing Citations
- MacKinnon et al. (2022) for cluster-robust inference
- Abadie et al. (2010) for synthetic control
- Aguiar & Hurst (2007b) for life-cycle time allocation

### 4. Fixed Internal Consistency Issues
- Removed duplicate Allegretto (2011) reference
- Fixed citation key mismatches
- Clarified Table 7 is restricted sample (different from Table 2 baseline)

## Limitations Not Addressed

The paper acknowledges fundamental limitations that cannot be addressed with the current data:

1. **Callaway-Sant'Anna**: Implemented but produces unstable estimates due to single treatment cohort (2015) and small sample sizes within group-time cells

2. **Synthetic Control**: Pre-treatment fit is poor due to high volatility in state-level ATUS averages with only 5 pre-treatment years

3. **Event Study**: Cannot construct meaningful event study with single treatment cohort

## Conclusion

The paper makes a methodological contribution by demonstrating:
1. ATUS timing alignment advantages for policy evaluation
2. Why modern DiD methods face limitations with minimal policy variation
3. First estimates of minimum wage effects on teen time allocation using diary data

However, the fundamental identification challenge (few switcher states) limits what can be learned from state-level variation in this sample period.
