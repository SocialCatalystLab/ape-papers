# Internal Review Round 1

**Reviewer:** Claude Code (as Reviewer 2)
**Date:** 2026-01-18

---

## Summary

This paper examines the effect of state auto-IRA mandates on worker job mobility, arguing that portable retirement benefits reduce job lock. The research question is novel and policy-relevant. However, several methodological concerns limit the credibility of the findings.

---

## Major Concerns

### 1. Treatment Identification is Imprecise

The paper acknowledges that individual-level data cannot identify which workers are actually enrolled in auto-IRAs. The "high-exposure industry" proxy is crude and likely introduces substantial measurement error. Without knowing whether workers are at firms that (a) lack existing retirement plans and (b) actually enrolled workers in the auto-IRA, the treatment variable captures intent-to-treat at best, and may be severely attenuated.

**Recommendation:** The paper should more explicitly frame results as intent-to-treat effects and discuss the likely magnitude of attenuation. Consider obtaining data on firm-level retirement plan offerings or state auto-IRA enrollment statistics to validate the exposure measure.

### 2. Parallel Trends Concerns

While the event study shows pre-coefficients close to zero, Figure 2 reveals substantial year-to-year volatility in both treatment and control series. The visual "parallel trends" evidence is not compelling—the series cross multiple times pre-treatment. A formal test of pre-trend differences would strengthen the identification.

**Recommendation:** Report formal joint test of pre-treatment coefficients = 0. Consider placebo tests with fake treatment dates.

### 3. Small Number of Clusters

With only 14 states (3 treated, 11 control), cluster-robust standard errors may be unreliable. The paper mentions wild bootstrap but does not report those p-values in the main tables.

**Recommendation:** Report wild bootstrap p-values in main results table. Consider using randomization inference as additional robustness.

### 4. COVID Confounding Not Fully Addressed

California's rollout (2019-2022) overlaps substantially with COVID-19. Even focusing on Oregon and Illinois, the post-2020 data is affected. The paper should explicitly show results excluding 2020-2021 or interacting treatment with COVID indicators.

**Recommendation:** Add robustness table showing results with different sample period restrictions.

---

## Minor Concerns

### 5. Limited Literature Review

The introduction cites only three papers. The job lock literature is much larger (Dey & Flinn 2005, Gruber 2000, Garthwaite et al. 2014). The auto-IRA literature also includes additional recent work.

### 6. Mechanism Discussion

The paper assumes effects operate through job lock reduction, but other mechanisms are possible (e.g., mandates signal regulatory environment, firms respond by changing compensation packages). Some discussion of alternative mechanisms would strengthen interpretation.

### 7. Economic Magnitude

The 1.1pp effect on job transitions is described as "economically meaningful" but no benchmark is provided. How does this compare to health insurance job lock estimates? To minimum wage effects on mobility?

### 8. Missing Placebo Outcomes

The paper mentions health insurance as a placebo but doesn't report results. This should be included.

---

## Minor Technical Issues

- Table 2 R² values of 0.000-0.001 are extremely low; this is fine for treatment effect estimation but should be noted
- Figure 3 y-axis labels could be clearer
- Paper is currently 15 pages; target was 25+ pages

---

## Verdict

The paper addresses a novel and important question with a reasonable identification strategy. However, the treatment measurement concerns are significant, and the statistical evidence would benefit from additional robustness checks. With revisions addressing the major concerns above, this paper could make a meaningful contribution.

**Recommendation:** Major Revision (address treatment identification and robustness concerns)
