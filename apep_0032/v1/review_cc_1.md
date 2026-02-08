# Internal Review Round 1 - Paper 42

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-19
**Paper:** Compulsory Schooling Laws and Mother's Labor Supply: Testing the Permanent Income Hypothesis

---

## REVIEWER 2 (Harsh Referee)

### Major Concerns

**1. Fatal Identification Problem: Failed Placebo Test (CRITICAL)**

The childless women placebo test is devastating. Finding a -5.1 pp differential for childless women (p < 0.01) indicates that states with compulsory schooling laws systematically differed in ways that affected ALL women's labor force participation, not just mothers. This undermines the entire identification strategy.

The paper acknowledges this in Section 5.4 but then proceeds to interpret the main results as "suggestive" evidence. A referee at a top journal would view this as a fatal flaw. The fact that childless women show a LARGER effect than mothers (-5.1 pp vs +0.62 pp) is particularly problematic.

**Recommendation:** This needs serious attention. Consider:
- State × year fixed effects
- Triple-differences with childless women as control
- Synthetic control methods
- Or acknowledge this is an associational finding, not causal

**2. Missing Modern DiD Estimators**

The paper uses a standard two-way fixed effects (TWFE) estimator with staggered adoption. Since Goodman-Bacon (2021) and Sun & Abraham (2021), we know TWFE can be severely biased with heterogeneous treatment effects. The paper:
- Never mentions this literature
- Doesn't implement modern estimators (Callaway-Sant'Anna, stacked DiD, etc.)
- Doesn't test for treatment effect heterogeneity across adoption cohorts

This is now standard practice for any DiD paper submitted to a top journal.

**3. Paper Length and Depth (16 pages vs. target 25+)**

The paper is too short. Missing elements include:
- Event study figure (mentioned but not shown)
- Pre-trends visualization
- Detailed robustness checks
- Mechanism discussion
- More extensive literature review

**4. Event Study Not Shown**

Section 5.2 discusses an event study but no figure is included. For a DiD paper, this is essential. The event study figure would:
- Show pre-trends (or lack thereof)
- Demonstrate timing of effects
- Allow readers to assess identification visually

### Minor Concerns

**5. Inconsistent Sample Descriptions**

- Abstract says "IPUMS Full Count Census data" but Section 3.1 says "1% samples"
- These are very different datasets. Full count = ~10M observations per year; 1% = ~100K

**6. Single vs. Married Mother Results**

Table 4 shows married mothers at 0.0074*** (0.0017) and single/widowed at 0.0156 (0.0110). The text claims single mothers respond "nearly twice as large" but the difference is not statistically significant. This claim needs qualification.

**7. Missing Standard Errors in Some Tables**

Table 3 column headers say "(1) Main (2) Married Only (3) Non-Farm" but the text discusses coefficients without clear mapping to columns.

**8. PIH Tests Not in Paper**

The code includes PIH-specific tests (duration, persistence, insurance) but the paper doesn't present these results in dedicated tables.

### Verdict: MAJOR REVISION

The failed placebo test is a near-fatal flaw. The paper needs to either:
(a) Find a way to address the state-level confounding convincingly, or
(b) Completely reframe as descriptive/associational analysis

---

## EDITOR (Constructive)

### What Works Well

1. **Novel research question**: Using compulsory schooling to test PIH via mother's labor supply is creative
2. **Large sample size**: 600K+ observations provides statistical power
3. **Honest about limitations**: The paper doesn't hide the failed placebo
4. **Interesting heterogeneity**: Black mothers' 9x larger response is genuinely interesting
5. **Clean presentation**: Tables are well-formatted

### Constructive Suggestions

**To Address Identification:**

1. **Triple-differences**: Use childless women as an additional control group:
   ```
   Y = β(Treated × SchoolAgeChild × Mother) + all lower-order interactions + FE
   ```
   This differences out the state-level confounding affecting all women.

2. **Modern DiD estimators**: Implement Callaway-Sant'Anna (2021) or Sun-Abraham (2021). The `did` package in R or Python implementations exist.

3. **Goodman-Bacon decomposition**: Show which 2x2 comparisons drive the result.

**To Strengthen the Paper:**

4. **Add event study figure**: The code generates this - include it!

5. **Include PIH test results**: The code runs duration, persistence, and insurance tests. Add a dedicated section/table.

6. **Expand literature review**: Discuss:
   - Lleras-Muney (2002) more extensively
   - Added worker effect literature
   - Modern DiD methods

7. **Reconcile sample description**: Clarify whether this is 1% samples or full count data.

8. **Extend to 25+ pages**: Add:
   - Mechanism section
   - More robustness checks
   - Figures
   - Extended data appendix

### Path Forward

The core idea is interesting. The main threat is state-level confounding. If you can implement a triple-diff design that uses the childless women as a within-state control, you may be able to salvage identification. The key insight: if treated states have lower female LFP generally, but MOTHERS in treated states have RELATIVELY higher LFP than CHILDLESS women in those same states after the law, that's more convincing.

---

## Summary

| Dimension | Score | Notes |
|-----------|-------|-------|
| Identification | 2/5 | Failed placebo is serious |
| Novelty | 4/5 | Creative use of historical shock |
| Data | 4/5 | Large, appropriate sample |
| Execution | 3/5 | Standard methods, missing modern DiD |
| Writing | 4/5 | Clear, honest about limitations |
| **Overall** | **3/5** | Promising but needs major revision |

**DECISION: MAJOR REVISION**

Priority fixes:
1. Address identification (triple-diff or reframe as descriptive)
2. Add event study figure
3. Implement modern DiD estimators (or justify why not)
4. Expand paper length
5. Clarify data source (1% vs full count)
