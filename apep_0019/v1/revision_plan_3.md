# Revision Plan - Round 3

## Issues Identified by Review 3

### Critical Issues

1. **ACP-Era Identification Problem**
   - Analysis uses 2021-2022 data when ACP existed (200% FPL threshold, $30 subsidy)
   - Everyone in our 85-185% FPL window is also ACP-eligible
   - Cannot isolate Lifeline-specific effect

2. **ACS Variance Estimation**
   - Using PWGTP with state clustering is not proper design-based variance
   - Should use ACS replicate weights for valid SEs

3. **Discrete Running Variable**
   - POVPIP is integer-valued
   - Significant McCrary test needs discrete-RD appropriate inference
   - Missing Kolesar-Rothe (2018) methods

4. **TOT Interpretation**
   - CI rules out large ITT but doesn't rule out meaningful TOT effects
   - Take-up scaling argument needs correction

5. **Missing References**
   - Kolesar & Rothe (2018) - discrete running variable inference
   - Gelman & Imbens (2019) - against higher-order polynomials
   - Calonico et al. (2017) - rdrobust software paper
   - Bhargava & Manoli (2015) - take-up frictions

## Planned Changes

### 1. Reframe Interpretation Around ACP Contamination
- Explicitly title paper/abstract to reflect "during ACP era"
- Add prominent discussion that estimates capture "income-based eligibility in presence of ACP"
- Cannot claim Lifeline effectiveness in isolation

### 2. Add Missing References
- Kolesar & Rothe (2018) AER - discrete RV inference
- Gelman & Imbens (2019) JBES - polynomial caution
- Calonico et al. (2017) SJ - rdrobust software
- Bhargava & Manoli (2015) AER - take-up frictions

### 3. Improve TOT Discussion
- Calculate TOT CI bounds explicitly
- Acknowledge cannot rule out meaningful effects on participants
- Be clearer about what null ITT does/doesn't imply

### 4. Acknowledge Inference Limitations
- Note that replicate weight inference would be preferable
- Discuss as limitation

### 5. Note Pre-ACP Analysis as Future Work
- Recommend pre-ACP years (2017-2019) for future research
- Note this would provide cleaner identification

## Status

- [ ] Revisions in progress
