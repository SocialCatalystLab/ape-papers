# Internal Review Round 1
**Reviewer: Claude Code (Internal)**
**Date: January 2026**

---

## Summary

This paper examines the early effects of Montana's 2023 zoning reforms ("Montana Miracle") on residential building permits using a difference-in-differences design. The topic is timely and policy-relevant. However, several methodological omissions and presentation issues require attention before external review.

---

## Major Issues

### 1. Event Study Missing from Paper (CRITICAL)

The analysis code (`02_analysis.py`) generates an event study plot (`fig3_event_study.png`), but this figure is not included in the paper. The event study is essential for:

- Validating the parallel trends assumption by showing pre-treatment coefficients near zero
- Documenting dynamic treatment effects over time
- Demonstrating no anticipation effects

**Recommendation:** Add Section 5.3.5 "Event Study" presenting fig3_event_study.png with interpretation of pre-treatment coefficients.

### 2. Promised Robustness Checks Not Delivered

The paper states (Section 4.2, line 158): "The main results are robust to alternative control group specifications, as discussed in Section 5."

However, Section 5 contains no robustness checks. This is a broken promise to readers.

**Recommendation:** Either (a) remove the claim, or (b) add robustness checks including:
- Dropping Idaho (rapidly growing outlier)
- Using all Mountain West states
- Using synthetic control weights

### 3. Wild Cluster Bootstrap Not Reported

The paper states (Section 4.3.1, line 174): "Given the small number of clusters (6 states), inference is also assessed using wild cluster bootstrap methods."

No bootstrap results are reported. With only 6 clusters, this is not merely methodological window-dressing—it's essential for credible inference.

**Recommendation:** Report wild cluster bootstrap p-values alongside standard clustered SEs.

### 4. No Parallel Trends Assessment

Beyond the event study, the paper should formally discuss whether pre-treatment trends are parallel. The visual evidence in Figure 1 is suggestive but not sufficient.

**Recommendation:** Add a pre-trends test (e.g., coefficient on Montana × linear pre-treatment time trend) or at minimum discuss the event study pre-treatment coefficients.

---

## Moderate Issues

### 5. Treatment Date Ambiguity

The paper correctly notes legal uncertainty persisted until March 2025 (15 months after the January 2024 effective date). Yet all analysis uses January 2024 as the treatment date.

**Recommendation:** Add a robustness check using March 2025 as an alternative treatment date, or at least discuss how results change with a "legally effective" treatment definition.

### 6. Authorship Pronoun Inconsistency

The paper uses first-person singular ("I find...", "I use...") but is authored by "Autonomous Policy Evaluation Project (APEP)," an institutional author.

**Recommendation:** Use "this study" or "we" throughout for consistency with institutional authorship.

### 7. Regression Table Missing Confidence Intervals

Table 2 reports only the point estimate and standard error. For a null result, the confidence interval is particularly informative.

**Recommendation:** Add a row showing 95% CI bounds (approximately [-4.1, 10.5]).

### 8. Heterogeneity Analysis Uses Simple DiD Only

Section 5.5 (Table 3) presents heterogeneity by permit type using only simple difference-in-differences calculations, not the full two-way fixed effects specification.

**Recommendation:** Run the full regression separately for single-family and multi-family outcomes and report coefficient estimates with standard errors.

---

## Minor Issues

### 9. Table 1 Column Labels Unclear

"Total Permits" shows raw counts while "Per Capita" shows rates per 100K. The juxtaposition is potentially confusing.

**Recommendation:** Relabel as "Mean Monthly Permits (raw)" and "Mean Monthly Permits (per 100K)".

### 10. Abstract Word "Immediately"

The abstract states effects are "modest" but uses language suggesting surprise. The framing should be more neutral.

**Recommendation:** Revise to emphasize that short-run null results are common for supply-side interventions.

### 11. Missing JEL Code

Consider adding R14 (Land Use Patterns) to the JEL codes.

### 12. References Incomplete

Some in-text citations lack full bibliographic entries. For example, "Oregon's 2019 reforms (HB 2001)" could use a formal citation.

---

## Summary of Required Revisions

| Priority | Issue | Action |
|----------|-------|--------|
| Critical | Event study missing | Add to results section |
| Major | Robustness claims unsupported | Add robustness checks or remove claims |
| Major | Bootstrap inference missing | Report wild cluster bootstrap |
| Major | Parallel trends not assessed | Add formal discussion |
| Moderate | Treatment date ambiguity | Add robustness check |
| Moderate | Pronoun inconsistency | Standardize to "this study" |
| Moderate | Missing CI in table | Add confidence interval |
| Moderate | Heterogeneity specification | Run full regressions |
| Minor | Table labels | Clarify column names |

---

## Decision

**REVISE AND RESUBMIT** - The paper addresses an important question with appropriate methods, but critical elements (event study, robustness checks, bootstrap inference) are missing. These should be straightforward to add given the existing analysis code and data.
