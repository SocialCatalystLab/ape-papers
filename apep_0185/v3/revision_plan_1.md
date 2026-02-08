# Revision Plan

**Paper:** Social Network Minimum Wage Exposure: Causal Evidence from Distance-Based Instrumental Variables
**Parent:** apep_0186
**Date:** 2026-02-05

## Summary of Changes from Parent Paper (apep_0186)

This revision implements the IV/2SLS strategy using distance-based instruments as planned. The key finding is that the instrument is weak (F=1.2), which is an honest null result.

### Major Changes

1. **Added real QWI employment data** - Fetched Quarterly Workforce Indicators from Census API (137,224 county-quarter observations)

2. **Implemented distance-based IV** - Constructed instruments using SCI-weighted MW from connections 400-600km away

3. **Documented weak IV finding** - First-stage F=1.2 is far below conventional thresholds, making 2SLS uninformative

4. **Reframed contribution** - Paper now emphasizes the data contribution (panel of network MW exposure) rather than causal claims

5. **Updated all summary statistics** - Reflect actual computed values from real data

6. **Fixed internal consistency issues** - Sample period (2012-2022), observation counts, correlation values all standardized

### Reviewer Concerns Addressed

From external reviews (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash):

1. **Weak IV acknowledged** - Paper explicitly states IV is uninformative and does not overclaim causality

2. **Data contribution emphasized** - Primary value is the constructed panel released for future research

3. **95% CIs** - Not fully added to all tables (future improvement)

4. **Missing citations** - Added Bartik (1991), Staiger & Stock (1997)

5. **Section 10 framing** - Updated to "outlines framework" rather than "examines"

## Files Modified

- `paper.tex` - Comprehensive updates to reflect honest results
- `code/00_packages.R` - Added library(AER)
- `code/02_clean_data.R` - Fixed NA handling in orthogonalization
- `code/03_main_analysis.R` - Fixed namespace conflicts
- `code/04_robustness.R` - Fixed industry heterogeneity check

## Outstanding Issues

1. Figure 6 annotation (-0.22) differs from Table 1 mean (-0.24) - requires regenerating figure
2. Some summary statistics in Table 4/5 may need recalculation
3. 2SLS columns have very large SEs - acknowledged as weak IV issue
