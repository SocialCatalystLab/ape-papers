# Revision Plan - Round 1

## Issues to Address

Based on internal review and advisor feedback:

### 1. Numerical Consistency
- **Issue:** Minor discrepancies between text and tables for coefficients
- **Fix:** Updated all coefficient citations to match exact table values (8.1 for bivariate, 7.7 for full model)

### 2. Urbanity Classification
- **Issue:** Text described classification as "quartiles" but thresholds create unequal groups
- **Fix:** Changed to "threshold-based classification" with explanation that these create substantively meaningful categories

### 3. Stockholm/Örebro Values
- **Issue:** Rounded values in abstract didn't match precise table values
- **Fix:** Updated to precise decimals (238.4 and 212.9)

### 4. R² Values
- **Issue:** R² appeared unchanged between columns 2 and 3
- **Fix:** Updated to show 0.197 in column 3 (minimal but non-zero increase)

### 5. Table Clarity
- **Issue:** Table 1 sample size unclear relative to regression tables
- **Fix:** Added note clarifying Table 1 is 2015 cross-section while regressions use pooled 2015-2016 (N=580)

## Implementation Status

All fixes have been implemented in paper.tex and PDF recompiled.
