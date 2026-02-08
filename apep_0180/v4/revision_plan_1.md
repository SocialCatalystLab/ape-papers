# Revision Plan (Round 1)

**Date:** 2026-02-06
**Paper:** "The Marginal Value of Public Funds for Unconditional Cash Transfers in a Developing Country: Evidence from Kenya"
**Parent:** apep_0182

## Summary of Reviewer Feedback

### GPT-5-mini (Major Revision)
- Needs microdata reanalysis (acknowledged limitation)
- Include admin cost uncertainty in bootstrap
- Add references: Efron & Tibshirani, Fieller, Deaton & Cartwright
- Clarify MVPF accounting convention (WTP vs Net Cost)
- Expand Section 3 algebra

### Grok-4.1-Fast (Minor Revision)
- Fix bib errors (Banerjee year)
- Add references: Bachas et al. (published version), Hendren (2016)
- Minor template/formatting

### Gemini-3-Flash (Conditionally Accept)
- Fix Figure 1 tornado label overlap
- Discuss non-recipient labor supply cost
- Add Hendren (2016) reference

## Changes Made

1. **MVPF Accounting Clarity**: Added explicit footnote explaining the accounting convention (government disburses $1,000; $150 admin; $850 to recipients; MVPF = 850/978).

2. **References Added**: Hendren (2016) "The Policy Elasticity"; Efron & Tibshirani (1994) "An Introduction to the Bootstrap"; Deaton & Cartwright (2018) "Understanding and misunderstanding randomized controlled trials".

3. **Bibliography Fixes**: Corrected Banerjee et al. year from 2019 to 2017 in the bibliographic entry.

4. **Tornado Figure**: Reduced str_wrap width from 22 to 18 characters; increased figure height from 7 to 8 inches; reduced axis text size.

5. **Figure Precision**: Changed Figure 2 and Figure 7 bar labels from 2 to 3 decimal places to match tables.

6. **Table/Text Consistency**: Clarified that Table 1 shows monthly PPP values from Haushofer-Shapiro while MVPF calculations use annual USD from Egger et al.

7. **Discount Rate**: Added explicit mention of r = 5% in main text (Section 4.3).

8. **Sensitivity Precision**: Changed rounding in 04_robustness.R from 2 to 3 decimal places so Table 6 baseline (0.867) matches the note.

9. **Table 6 Rendering**: Removed all spacing tricks that caused PDF rendering issues.

## Changes NOT Made (with justification)

1. **Microdata reanalysis**: Acknowledged as a limitation. Automated retrieval requires interactive authentication. The covariance sensitivity analysis (Table 8) shows MVPF is invariant to the correlation parameter.

2. **Admin cost stochastic in bootstrap**: Not implemented. Admin cost is well-documented (GiveDirectly annual reports). Adding this uncertainty would marginally widen the already-narrow CI but wouldn't change the point estimate or conclusions.
