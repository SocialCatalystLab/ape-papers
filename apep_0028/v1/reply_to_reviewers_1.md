# Reply to Reviewers - Round 1

**Responding to:** Internal Review (review_cc_1.md)
**Date:** January 2026

---

We thank the reviewer for their thorough and constructive feedback. Below we address each point raised.

---

## Critical Issues

### 1. Event Study Missing from Paper

**Reviewer:** The event study figure (fig3_event_study.png) was generated but not included in the paper. This is essential for validating parallel trends.

**Response:** We have added Section 5.5 "Event Study Analysis" presenting Figure 2 (the event study plot). Importantly, the event study reveals that pre-treatment coefficients are not uniformly close to zero, ranging from approximately 0 to 21. We now prominently discuss this as a limitation that "cautions against strong causal interpretation of the main results" (Section 5.5 and Section 6.1).

### 2. Promised Robustness Checks Not Delivered

**Reviewer:** The paper claimed robustness checks were "discussed in Section 5" but none appeared.

**Response:** We have added Section 5.7 "Robustness Checks" with Table 4 presenting three specifications:
- Main specification (baseline)
- Excluding Idaho (rapid-growth outlier)
- Alternative treatment date (March 2025, when injunction lifted)

The March 2025 specification is particularly noteworthy, yielding a larger coefficient (5.90) that approaches significance (p=0.059), suggesting developers may have waited for legal clarity.

### 3. Wild Cluster Bootstrap Not Reported

**Reviewer:** Bootstrap inference was mentioned but not reported.

**Response:** We implemented wild cluster bootstrap with 999 iterations using Rademacher weights. The bootstrap p-value (0.487) is now reported in Table 2 alongside the clustered SE p-value (0.375). Both support the same conclusion of statistical insignificance.

### 4. No Parallel Trends Assessment

**Reviewer:** The paper should formally discuss whether pre-treatment trends are parallel.

**Response:** The event study (new Section 5.5) now serves this function. We explicitly acknowledge that "pre-treatment coefficients are not uniformly close to zero, suggesting some violation of the parallel trends assumption." This concern is reiterated in Section 6.1 with the magnitude of pre-treatment variation (0 to 21) noted as cautioning against strong causal interpretation.

---

## Moderate Issues

### 5. Treatment Date Ambiguity

**Reviewer:** Consider robustness check with March 2025 as alternative treatment date.

**Response:** Added to Table 4. The March 2025 specification yields coefficient = 5.90 (SE = 3.13, p = 0.059), approaching significance. We discuss this finding and note the tradeoff: while arguably more appropriate given legal uncertainty, it has only 8 months of post-treatment data.

### 6. Authorship Pronoun Inconsistency

**Reviewer:** Paper used "I" but author is institutional (APEP).

**Response:** Changed all first-person singular pronouns to passive voice or "this study/analysis" throughout the paper.

### 7. Regression Table Missing Confidence Intervals

**Reviewer:** Table 2 should include 95% CI bounds.

**Response:** Added 95% confidence interval [-3.91, 10.38] to Table 2 in brackets below the standard error.

### 8. Heterogeneity Analysis Uses Simple DiD Only

**Reviewer:** Should run full regression for SF and MF outcomes.

**Response:** Table 3 now presents regression-based estimates from separate two-way fixed effects specifications:
- Single-family: 0.178 (SE = 1.606, p = 0.912)
- Multi-family: 3.055 (SE = 3.047, p = 0.316)

Both include 95% confidence intervals.

---

## Minor Issues

### 9. Table 1 Column Labels

**Reviewer:** "Total Permits" vs "Per Capita" juxtaposition is confusing.

**Response:** We retained the original labels but clarified in the table notes that "Per capita rates are per 100,000 population." The labels are consistent with the column header structure used in applied economics papers.

### 10-12. Other Minor Issues

- **JEL Code R14:** Added to abstract.
- **References:** Retained existing structure; all cited works have bibliographic entries.

---

## Summary of Changes

| Issue | Status |
|-------|--------|
| Event study added | Complete |
| Robustness checks section | Complete |
| Wild bootstrap p-value | Complete |
| Parallel trends discussion | Complete |
| Pronoun standardization | Complete |
| CI in Table 2 | Complete |
| Heterogeneity regressions | Complete |
| JEL code R14 | Complete |

The revised paper is now 26 pages with 4 tables and 3 figures.
