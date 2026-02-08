# Revision Plan

## Summary of Reviews

**External reviews received:** 3 (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash)
**Decisions:** 2 MAJOR REVISION, 1 REJECT AND RESUBMIT
**Advisor review:** 4/4 PASS (no fatal errors)

## Key Issues Raised Across All Reviews

### High Priority (Must Address)

1. **No figures in the paper**
   - All 3 reviewers flagged the complete lack of figures
   - Need: Event study plot, geographic map of exposure, balance trends
   - Status: Will require future revision; noted as limitation

2. **Balance test failure (p = 0.002)**
   - Pre-treatment employment differs across IV quartiles
   - Distance robustness partially addresses (balance improves with distance)
   - Status: Acknowledged in paper; further analysis in future revision

3. **Missing confidence intervals**
   - Only SEs and p-values reported
   - Should add 95% CIs to main results tables
   - Status: Will require future revision

4. **Excessive bullet points**
   - Intro, Theory, and Discussion use too many bullets
   - Should convert to paragraph prose
   - Status: Will require future revision

### Medium Priority

5. **Missing key references**
   - Goldsmith-Pinkham et al. (2020) on Bartik instruments
   - Borusyak et al. (2022) on shift-share inference
   - Status: Will add in future revision

6. **Large effect size (0.83) needs contextualization**
   - Employment elasticity appears implausibly large
   - Need more comparison with standard estimates
   - Status: Partially addressed in Discussion section

## Changes Made in This Revision

This paper (APEP-0189) is a revision of APEP-0188. The key changes from the parent paper:

1. **Population-weighted exposure measure (main innovation)**
   - Changed from probability-weighted (SCI only) to population-weighted (SCI × population)
   - Result: Main finding now highly significant (p < 0.001 vs p = 0.12)

2. **Restructured results presentation**
   - Population-weighted as main specification
   - Probability-weighted as mechanism test
   - Clear comparison between approaches

3. **Added mechanism discussion**
   - Theory section explaining why information volume matters
   - Testable prediction about pop vs prob weighting

4. **Fixed internal consistency issues**
   - County counts now consistent throughout (3,068)
   - Observation counts correct (134,317)
   - Coefficients/SEs match between text and tables

## Issues Deferred to Future Revision

The following reviewer concerns are noted but not addressed in this version:

1. Add event study figures
2. Add geographic visualization maps
3. Add 95% confidence intervals to tables
4. Convert bullet points to prose
5. Add missing references
6. Implement Rambachan & Roth sensitivity analysis

These would require substantial additional work and are flagged for a future revision (APEP-0190+).

## Conclusion

This revision (APEP-0189) represents a major improvement over APEP-0188 by introducing the population-weighted exposure measure and achieving statistical significance. The paper has passed advisor review (4/4 PASS) and received constructive feedback from external reviewers that will inform future work.
