# Revision Plan - Round 1

**Date:** 2026-01-22

## Major Issues to Address

### 1. Reframe the paper as methodological contribution

**Action:** Revise the introduction to lead with the methodological finding. The paper's contribution is demonstrating when RDD designs fail, not providing causal estimates of insurance effects on fertility.

**Specific changes:**
- Revise title to emphasize methodological lesson
- Restructure abstract to emphasize balance test failure upfront
- Add explicit statement in introduction about the paper's contribution being methodological

### 2. Address overpowering concern

**Action:** Add discussion of effect size interpretation. With 1.5M observations, statistical significance is easy; economic significance matters more.

**Specific changes:**
- Add paragraph in discussion about statistical vs. economic significance
- Calculate effect sizes in standard deviation units
- Note that even small compositional shifts become significant with large N

### 3. Expand placebo analysis discussion

**Action:** Provide more analysis of the age 27 finding and broader placebo pattern.

**Specific changes:**
- Add interpretation of why age 27 shows significance
- Note that 27 is a "rounded" milestone age (late 20s)
- Discuss implications for choosing RDD cutoffs

### 4. Add power analysis for subgroup estimates

**Action:** Calculate minimum detectable effects for the stratified analysis.

**Specific changes:**
- Add power calculation to Appendix
- Discuss whether null findings reflect true nulls vs. insufficient power

### 5. Control for marriage (sensitivity analysis)

**Action:** Add analysis that controls for marriage to show what estimates would look like under different assumptions.

**Specific changes:**
- Add regression controlling for marriage (noting it's not causal)
- Show estimates shrink toward zero when marriage is controlled

## Minor Issues to Address

1. Clarify contribution relative to Abramowitz (2016)
2. Discuss bandwidth stability as potential concern
3. Note Title X policy changes in limitations

## Implementation Order

1. Run additional analysis (marriage controls, power calculation)
2. Revise paper text
3. Recompile PDF
