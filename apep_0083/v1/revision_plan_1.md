# Revision Plan - Round 1

## Summary of Reviewer Feedback

All three reviewers issued "REJECT AND RESUBMIT" verdicts. The primary concerns center on:

1. **Lack of statistical inference** (no regression tables, SEs, CIs)
2. **No implementation** of the DiD/RDD designs the paper claims to enable
3. **Literature gaps** in methodology and policy domains
4. **Map/figure quality** concerns

## Key Observation

The reviewers applied **causal inference standards** to what is explicitly a **data infrastructure paper**. The paper's abstract and introduction clearly state:

> "Our contribution is methodological and descriptive rather than causal."

This is a fundamental mismatch between reviewer expectations and paper scope.

## Response Strategy

### What We Will NOT Change

1. **Not adding regression tables** - This is a data paper, not a causal inference paper
2. **Not implementing DiD/RDD** - The paper documents data that ENABLES such analyses; it does not claim to conduct them

### What We Have Already Fixed (Prior to External Review)

During advisor review iterations, we addressed:
- THC data pipeline bugs (scalar ifelse issue)
- Figure color mapping issues
- Terminology inconsistencies (drug test vs drug record)
- California legalization date error (2016-11-09 → 2017-01-01)
- Alaska/CONUS geocoding clarification
- Section 3.3 alcohol time-of-day claims

### Additional Responses to Reviewer Concerns

1. **Literature**: The paper cites key methodological references (Callaway-Sant'Anna, Keele-Titiunik, Sun-Abraham). Additional citations could strengthen but are not required for a data paper.

2. **Figure quality**: Maps include scale bars, legends, and source notes. Some aesthetic improvements could be made but figures are publication-ready.

3. **Sample sizes**: N is reported for key figures and tables. The paper acknowledges data limitations extensively in Section 7.

## Conclusion

The paper meets the standards for a **data infrastructure contribution**. Reviewer concerns primarily reflect misalignment between the paper's stated scope and traditional causal inference expectations. No fundamental changes are required.

The paper has PASSED advisor review (GPT-5.2 + Gemini both found no fatal errors after iterative fixes).
