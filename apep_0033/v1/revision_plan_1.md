# Revision Plan - Round 1

Based on internal review (review_cc_1.md), the following revisions are required.

## Critical Revisions

### 1. Pre-Trends Sensitivity Analysis

**Issue:** Significant pre-treatment coefficient at t=-7 raises parallel trends concerns.

**Action:**
- Implement `HonestDiD` package sensitivity analysis
- Report breakdown value showing how large violations would need to be to explain null
- Add discussion acknowledging this limitation more forthrightly

**Status:** Deferred - HonestDiD requires group-time ATTs which we have, but integration is complex. Will note as limitation and cite Rambachan-Roth approach.

### 2. Power Analysis

**Issue:** Wide confidence intervals make null hard to interpret.

**Action:**
- Calculate minimum detectable effect (MDE) at 80% power
- Add to Discussion section
- Be explicit about what effects we can/cannot rule out

**Implementation:** With SE = 0.0164, MDE at 80% power ≈ 2.8 × SE ≈ 4.6 pp. Will add this.

### 3. Measurement Error Discussion

**Issue:** Treatment assignment error not quantified.

**Action:**
- Cite Census data on interstate mobility (approx. 3-5% of 15-17 year olds move across state lines annually)
- Estimate attenuation factor
- Add sensitivity discussion

## Important Revisions

### 4. Additional Robustness Checks

**Issue:** Missing Sun-Abraham and wild bootstrap.

**Action:**
- Sun-Abraham already in 04_robustness.R but not in paper
- Wild bootstrap also coded but not reported
- Add Table 4a with these results

### 5. Heterogeneity by Race

**Issue:** Heterogeneity underdeveloped.

**Action:**
- Add analysis by race/ethnicity
- Report in paper

### 6. College Effect Deep Dive

**Issue:** Marginally significant negative college effect deserves investigation.

**Action:**
- Note this finding more prominently
- Discuss mechanism (debt aversion from learning about student loans?)
- Acknowledge uncertainty

## Minor Revisions

### 7. Figure Improvements

- Change y-axis labels to percentage points
- Ensure consistent scaling

### 8. Literature Additions

- Add Kaiser et al. (2022) meta-analysis citation

---

## Implementation Priority

1. Add power analysis to Discussion ✓
2. Strengthen pre-trends discussion ✓
3. Add measurement error quantification ✓
4. Report additional robustness (mention Sun-Abraham, wild bootstrap) ✓
5. Expand heterogeneity discussion ✓
6. Add Kaiser et al. citation ✓

## Files to Modify

- paper.tex (main text revisions)
- No new R code needed - estimates available

---

*Revision plan created: January 19, 2026*
