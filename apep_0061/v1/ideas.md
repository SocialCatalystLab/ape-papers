# Ideas: Paper 78

## Revision Context

This paper is a **revision** of apep_0069 ("Do State Dyslexia Laws Improve Reading Achievement?").

The original paper identified a research question and methodology that were sound, but reviewers identified four key issues requiring revision:

1. Treatment timing misalignment with NAEP test dates
2. Policy bundling confounds (MS, FL, TN, AL)
3. State mean outcome dilutes targeted effects
4. Inference gaps (singular covariance, missing pretrend tests)

## Selected Idea (from Parent Paper)

**Title:** Do State Dyslexia Laws Improve Reading Achievement? Evidence from Staggered Adoption with Corrected Treatment Timing

**Method:** Staggered DiD (Callaway-Sant'Anna 2021)

**Data Sources:**
- NAEP Grade 4 Reading (2003-2022) - 50 states × 10 years
- State dyslexia law effective dates compiled from Dyslegia.com, State of Dyslexia, Education Week

**Key Revisions:**
1. Corrected treatment timing: `first_naep_exposure` instead of `mandate_year`
2. Separate estimation for bundled reform vs. dyslexia-only states
3. Improved inference: 1000 bootstrap iterations, pretrend tests, binned event study

**Feasibility:** Confirmed - parent paper successfully executed using real NAEP API data.
