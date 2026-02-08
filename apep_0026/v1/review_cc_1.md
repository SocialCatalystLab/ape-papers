# Internal Review Round 1

**Reviewer:** Claude Code (Self-Review)
**Date:** 2026-01-18

---

## Overall Assessment

This paper investigates a novel and creative research question: whether marijuana legalization at age 21 shifts workers into self-employment to avoid employer drug testing. The difference-in-discontinuities design is methodologically appropriate for addressing the alcohol-at-21 confound. However, the paper has several issues that should be addressed.

**Recommendation:** Major Revision

---

## Major Issues

### 1. Statistical Power Concerns

The paper finds a null result but doesn't adequately discuss statistical power. With a baseline self-employment rate of ~2% and only ~7,500 Colorado observations, the study may be underpowered to detect economically meaningful effects.

**Suggestion:** Add a power analysis or minimum detectable effect calculation. What effect size could you rule out with 80% power?

### 2. Missing 2020 Data Not Discussed

The paper excludes 2020 due to COVID but doesn't discuss how this affects the analysis. 2020 was a critical year for self-employment trends due to the pandemic. This gap may bias results.

**Suggestion:** Add robustness check excluding 2021-2022 as well (to avoid pandemic recovery effects).

### 3. Control State Selection Needs Justification

Why these six control states? Some (FL, TX) had medical marijuana during the sample period. This could affect the "control" status if medical users are shifting behavior pre-age-21.

**Suggestion:** Add sensitivity analysis using only states without ANY marijuana legalization (recreational or medical).

### 4. Pre-Trend Analysis Missing

The paper lacks a formal pre-trend analysis. Are Colorado and control states trending similarly before 2015? Without this, we cannot rule out differential secular trends.

**Suggestion:** Add pre-period (2010-2014) analysis showing similar trends.

### 5. Age in Years vs. Months

GPT raised this concern and it deserves more attention. Using age in years introduces measurement error that attenuates RDD estimates. The paper should quantify this bias.

**Suggestion:** Add discussion of how much attenuation is expected and cite relevant methodological literature.

---

## Minor Issues

### 6. Figure Quality

The figures are functional but could be improved:
- Add confidence intervals to the RDD plots
- Consider adding a combined diff-in-disc visualization
- Y-axis scales differ between Colorado and Control panels, making visual comparison difficult

### 7. Summary Statistics Table Incomplete

Table 1 shows means but not separate means for Colorado vs. control states. This would help readers understand baseline comparability.

### 8. Standard Error Clustering

The paper uses heteroskedasticity-robust SEs but doesn't cluster. Should SEs be clustered at the state level given the state-level treatment assignment?

### 9. Bandwidth Sensitivity

The paper mentions bandwidth robustness but doesn't report results. Should include table with different bandwidths.

### 10. Drug Testing Industry Definition

The paper creates an ad-hoc "drug testing industry" variable but doesn't provide validation. Are these industries actually drug-tested at higher rates?

---

## Strengths

1. Novel research question with clear policy relevance
2. Appropriate diff-in-disc methodology to handle alcohol confound
3. Placebo tests pass, supporting internal validity
4. Gender heterogeneity finding is interesting and potentially important
5. Honest reporting of null result
6. Well-written and clearly structured

---

## Specific Recommendations for Revision

1. **Add power analysis** showing minimum detectable effect
2. **Add pre-period analysis** to validate parallel trends
3. **Add bandwidth sensitivity table**
4. **Cluster standard errors** at state level
5. **Improve figures** with confidence intervals
6. **Add robustness check** excluding pandemic years
7. **Discuss control state selection** and medical marijuana status
