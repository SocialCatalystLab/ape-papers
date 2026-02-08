# Internal Review: Round 1
## Paper 70: Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid?

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-23
**Verdict:** MINOR REVISION

---

## Summary

This paper uses a regression discontinuity design to estimate the effect of "aging out" of ACA dependent coverage at age 26 on the source of payment for childbirth. Using CDC Natality data, the author finds a 2.7 pp increase in Medicaid-paid births and a 3.1 pp decrease in private insurance-paid births at the threshold. Effects are larger for unmarried women (4.9 pp vs 2.1 pp). No significant effects on health outcomes are detected.

## Major Comments

### 1. Covariate Imbalance Concern (Important)

The paper reports a significant discontinuity in college education at the threshold (RD = 1.4 pp, p < 0.001). This is concerning because it suggests potential selection—women who give birth at 26+ are systematically different from those who give birth just before 26. The paper attempts to address this with covariate-adjusted estimates, but this needs more discussion:

- Why might college completion be discontinuous at 26? Is this related to age at first birth patterns for educated women?
- The covariate-adjusted estimate (3.3 pp) is *larger* than the unadjusted estimate (2.7 pp). This is reassuring but should be explained.
- Consider showing results separately by education level as a robustness check.

### 2. Placebo Test Interpretation

The placebo tests show significant "effects" at ages 24 (-1.0 pp, p=0.002) and 27 (-2.8 pp, p<0.001). The paper argues these reflect the underlying age gradient and that the age 26 effect is larger and in the opposite direction. This argument is reasonable but needs strengthening:

- The age 27 "effect" (-2.8 pp) is actually larger in magnitude than the age 26 effect (+2.7 pp), just in the opposite direction.
- Consider presenting a figure showing RD estimates at each placebo cutoff to visually demonstrate that age 26 is the anomaly.
- Discuss whether the positive effect at 26 could simply be a deviation in the nonlinear age-Medicaid relationship rather than a true policy effect.

### 3. Data Year Inconsistency

The abstract states the data covers 2023 only (1.6 million births), but the introduction and data section mention 2016-2023 (28 million births). This inconsistency should be resolved. If only 2023 data were used, explain why earlier years were excluded.

## Minor Comments

### 4. Missing Figures and Tables

All figure and table references appear as "??" in the compiled PDF. The figures were generated (figure1_rdd_main.pdf, etc.) but not included in the LaTeX document. This must be fixed before submission.

### 5. Missing Citations

Several citations appear as "?" in the text (e.g., page 3: "(?)", page 4: "(?)", page 5: "(??)"). These should be completed.

### 6. External Validity Discussion

The paper should discuss external validity more explicitly:
- What fraction of women under 26 are actually on parental coverage? The RD effect is an intent-to-treat estimate; the effect on compliers is much larger.
- How might results differ for women who get pregnant vs. those already pregnant when turning 26?

### 7. Policy Discussion

The fiscal externality argument could be quantified:
- With ~3.6 million annual births and ~X% to women 26-30, the shift represents $Y in costs shifted from private insurers to Medicaid annually.
- This strengthens the policy relevance.

### 8. Discrete RDD Methodology

The paper appropriately cites Kolesár & Rothe (2018) but the actual implementation uses parametric local linear regression via `fixest` rather than `rdrobust`. This should be clarified in the methods section.

## Technical Issues

1. **Bandwidth selection**: The bandwidth (4 years) appears manually chosen. Discuss why this bandwidth was selected and report data-driven bandwidth selection results.

2. **Standard errors**: Are SEs clustered at the age level or computed with heteroskedasticity-robust estimates? This should be explicit.

3. **Multiple testing**: Six outcomes are tested. Consider discussing multiple testing corrections or focusing on pre-specified primary outcomes.

## Verdict

The paper addresses an interesting policy question with appropriate methodology and finds meaningful effects. The main concerns are the covariate imbalance and the placebo test results, which require more careful discussion. The missing figures and citations must be fixed. After these revisions, the paper will be suitable for publication.

**Recommendation:** MINOR REVISION

## Required Revisions

1. Resolve data year inconsistency (2023 only vs. 2016-2023)
2. Include figures and tables in the LaTeX document
3. Fix missing citations
4. Expand discussion of covariate imbalance and provide robustness check by education
5. Strengthen placebo test interpretation with visual evidence
6. Clarify econometric methodology (parametric vs. nonparametric RDD)
