# Revision Plan - Round 2

## Issues Identified by Review 2

### Critical Methodological Issues

1. **Sharp vs Fuzzy RD Mischaracterization**
   - Paper claims "sharp" threshold but Lifeline has categorical eligibility (SNAP/Medicaid/SSI/FPHA)
   - Households above 135% FPL may still be eligible via categorical programs
   - Need to reframe estimand as "effect of being below 135% FPL income threshold" not "effect of Lifeline eligibility"

2. **Manipulation Test Inadequate**
   - Current two-bin chi-squared test not acceptable for top journals
   - Need proper McCrary (2008) or Cattaneo-Jansson-Ma (rddensity) test

3. **Covariate Balance Issues**
   - Significant age discontinuity (p≈0.000) not adequately addressed
   - Need joint balance test across multiple covariates
   - Need RD with and without covariate adjustment

4. **Bandwidth Sensitivity**
   - At 30pp bandwidth: τ = -0.0092 (p=0.016) is statistically significant negative
   - Need MSE-optimal and CER-optimal bandwidth selection
   - Need robust bias-corrected inference
   - Need local quadratic specification robustness

5. **Missing Key RD References**
   - Calonico, Cattaneo, Titiunik (2014) - Econometrica
   - Cattaneo, Jansson, Ma (2018) - manipulation testing
   - Lee and Card (2008) - discrete running variable
   - Calonico, Cattaneo, Farrell, Titiunik (2019) - RD with covariates

6. **Survey Design Issues**
   - State clustering may not be appropriate for complex survey
   - Need robustness to PUMA clustering and unweighted estimation

## Planned Changes

### 1. Rerun Analysis with Modern RD Methods
- Implement rdrobust-style estimation with bias-corrected inference
- Compute MSE-optimal and CER-optimal bandwidths
- Add local quadratic specification
- Add donut RD robustness (excluding narrow window around cutoff)

### 2. Proper Manipulation Test
- Implement McCrary density test with proper bandwidth
- Create publication-quality density plot

### 3. Address Categorical Eligibility
- Use ACS variables to identify SNAP receipt (FS variable)
- Quantify share of categorically eligible above 135% FPL
- Either: (A) exclude categorically eligible, or (B) reframe as fuzzy RD, or (C) document fuzziness

### 4. Expand Covariate Analysis
- Joint F-test across all covariates
- Show RD estimates with full covariate adjustment
- Add education, household size, race to balance tests

### 5. Add Missing References
- Add Calonico et al. (2014)
- Add Cattaneo et al. (2018)
- Add Lee & Card (2008)
- Add Calonico et al. (2019)

### 6. Reframe Estimand Throughout Paper
- Change "Lifeline eligibility" to "income-based Lifeline eligibility"
- Acknowledge ITT interpretation more prominently
- Discuss categorical eligibility as limitation upfront

### 7. Survey Robustness
- Add unweighted estimates
- Add PUMA-clustered SEs as robustness

## Status

- [x] Revisions complete (2026-01-17)
