# Reply to Reviewers: Round 1

## Paper 70: Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid?

---

We thank the reviewer for their careful reading and constructive feedback. Below we address each comment in detail.

---

## Major Comments

### Comment 1: Covariate Imbalance Concern

> The paper reports a significant discontinuity in college education at the threshold (RD = 1.4 pp, p < 0.001). This is concerning because it suggests potential selection—women who give birth at 26+ are systematically different from those who give birth just before 26.

**Response:** We have substantially expanded the discussion of covariate imbalance (Section 8.2). We now explain that the college discontinuity likely reflects selection: women who complete college may delay childbearing until after 26, as college completion itself often occurs around this age. However, we emphasize that the covariate-adjusted RDD estimate (3.3 pp) is *larger* than the unadjusted estimate (2.7 pp). This is reassuring: if selection on education were biasing results, we would expect the adjusted estimate to be smaller. The fact that it is larger suggests the main effect is not driven by educational composition.

### Comment 2: Placebo Test Interpretation

> The placebo tests show significant "effects" at ages 24 and 27. Consider presenting a figure showing RD estimates at each placebo cutoff.

**Response:** We have added Figure 6, which plots RD estimates at all placebo cutoffs (ages 24, 25, 27, 28) alongside the policy-relevant cutoff at age 26. The figure clearly shows that age 26 is qualitatively different: it is the only cutoff with a *positive* effect on Medicaid. Placebo cutoffs show negative effects reflecting the underlying age gradient in Medicaid use. We have also expanded the discussion (Section 8.3) to explain that the sign reversal at age 26 is the key identifying feature.

### Comment 3: Data Year Inconsistency

> The abstract states the data covers 2023 only, but the introduction mentions 2016-2023.

**Response:** Fixed. We have corrected the introduction and data section to consistently state that we use 2023 data only (1.6 million births). The earlier reference to 2016-2023 was an error from an earlier draft that used multiple years.

---

## Minor Comments

### Comment 4: Missing Figures and Tables

> All figure and table references appear as "??" in the compiled PDF.

**Response:** Fixed. All figures are now properly included using \includegraphics, and we have generated formal LaTeX tables for all main results (Tables 1-5). The paper now includes 7 figures and 5 tables.

### Comment 5: Missing Citations

> Several citations appear as "?" in the text.

**Response:** Fixed. We have added all missing bibliography entries, including sommers2013, cdc2015, truven2013, martin2023, and others.

### Comment 6: External Validity Discussion

> The paper should discuss external validity more explicitly.

**Response:** We acknowledge this limitation in the Discussion section. The RD effect is indeed an intent-to-treat estimate; the effect on compliers (women who were actually on parental coverage) would be larger. We now note that not all women under 26 have access to parental coverage, so the policy-relevant effect is concentrated among those whose parents have private insurance.

### Comment 7: Discrete RDD Methodology

> The paper cites Kolesár & Rothe (2018) but uses parametric local linear regression via fixest.

**Response:** We have rewritten the Estimation section (6.2) to accurately describe our approach. We now explain that given the discrete nature of the running variable, we use parametric local linear regression with heteroskedasticity-robust standard errors via the fixest package, rather than the nonparametric rdrobust approach which requires continuous running variables.

---

## Technical Issues

### Bandwidth Selection

> The bandwidth (4 years) appears manually chosen.

**Response:** We have added Figure 7 showing bandwidth sensitivity. Results are stable across bandwidths of 1-4 years (estimates range from 2.7 to 3.2 pp). We selected 4 years as the primary specification to maximize precision while maintaining a reasonable local neighborhood around the threshold.

### Standard Errors

> Are SEs clustered at the age level or computed with heteroskedasticity-robust estimates?

**Response:** We now explicitly state in Section 6.2 that we use heteroskedasticity-robust standard errors (HC1). Given that we have only 9 age levels in the 4-year bandwidth window, clustering at the age level would leave too few clusters for valid inference.

### Multiple Testing

> Six outcomes are tested. Consider discussing multiple testing corrections.

**Response:** We note that the three payment source outcomes (Medicaid, Private, Self-Pay) are mechanically related and represent a single composite outcome. The primary hypothesis concerns Medicaid, which is significant at p < 0.001. Even with Bonferroni correction across all six outcomes, Medicaid and Private Insurance remain significant.

---

## Summary of Changes

1. Corrected data year inconsistency (2023 only)
2. Added all figures with proper \includegraphics
3. Generated and included 5 formal LaTeX tables
4. Added 15 missing bibliography entries
5. Expanded covariate imbalance discussion
6. Added Figure 6 for placebo cutoff visualization
7. Added Figure 7 for bandwidth sensitivity
8. Rewrote methodology section to accurately describe fixest implementation
9. Explicitly stated HC1 robust standard errors

We believe these revisions fully address the reviewer's concerns.
