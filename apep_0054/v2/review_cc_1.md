# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Date:** January 22, 2026
**Paper:** Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap

---

## Summary

This paper examines the causal effects of state salary transparency laws on wages and gender pay gaps using difference-in-differences estimation. The paper exploits staggered adoption across 14 U.S. states (2021-2024) and uses CPS ASEC data with the Callaway-Sant'Anna heterogeneity-robust estimator. The main finding is that transparency laws reduce average wages by ~1.2% while potentially narrowing the gender gap.

---

## Major Issues

### 1. Pre-trends Concerns (Critical)
The event study shows pre-treatment coefficients that are not consistently zero. The paper acknowledges this but does not sufficiently address it:
- Some pre-period coefficients reach 3.2% magnitude
- The paper needs HonestDiD sensitivity analysis to bound how violations of parallel trends would affect conclusions
- Without this, the causal claims are weakened

**Recommendation:** Add Rambachan-Roth sensitivity analysis using the `HonestDiD` package.

### 2. Small Number of Treated Clusters
With only 14 treated states and staggered adoption, there are concerns about:
- Statistical power for detecting effects
- Standard error reliability with few clusters
- Some treatment cohorts have only 1-3 states

**Recommendation:** Report wild bootstrap p-values or other small-sample inference adjustments. Discuss power explicitly.

### 3. Selection into Treatment
States that adopted transparency laws early (CO, CA, NY) are systematically different:
- Higher wages
- More educated workforce
- More urban
- More progressive politically

While state FEs control for time-invariant differences, if these states were on different wage trajectories, DiD estimates are biased.

**Recommendation:** Add discussion of why selection might be or might be less problematic. Consider synthetic control as robustness.

---

## Minor Issues

### 4. Missing Main Figures in Text
The paper references figures from the code but the main text lacks embedded figures showing:
- Treatment map
- Main wage trends
- Event study plot

**Recommendation:** Include key figures (map, trends, event study) in main body.

### 5. Imprecise Gender Gap DDD Results
The triple-difference coefficient for the gender gap is positive but not statistically significant at conventional levels in some specifications. The paper should be more cautious in its claims.

**Recommendation:** Temper claims about gender gap effects; emphasize direction rather than magnitude.

### 6. Literature Review Gaps
Missing references to:
- Dustmann et al. (2020) on wage posting
- Mas (2017) on California pay disclosure
- Recko et al. (2023) on Colorado effects

**Recommendation:** Expand related literature section.

### 7. Standard Errors Discussion
The paper uses state-clustered SEs but doesn't discuss whether this is appropriate given:
- Treatment assigned at state level
- Serial correlation in wages

**Recommendation:** Briefly justify clustering choice; consider Conley SEs for robustness.

---

## Presentation Issues

1. **Page count:** At 23 pages, paper is slightly below target of 25+ pages. Could expand discussion/robustness sections.

2. **Table clarity:** Some table notes are compressed. Consider expanding explanations.

3. **Figure quality:** Figures are functional but could use more annotation (e.g., vertical lines at treatment for event studies).

---

## Verdict

**MAJOR REVISION**

The paper addresses an important and timely policy question with appropriate methodology. However, the pre-trends concerns and small cluster issues need more attention before the causal claims can be fully supported. The core contribution is solid, and with revisions to address identification concerns, this could be a strong paper.

### Key Actions Required:
1. Add HonestDiD sensitivity analysis for parallel trends
2. Add small-sample inference adjustments
3. Include key figures in main text
4. Expand discussion of selection into treatment
5. Temper causal language given pre-trends
