# Revision Plan (Round 1)

**Date:** 2026-01-21
**Responding to:** Internal Review (review_cc_1.md)
**Verdict Received:** MAJOR REVISION

---

## Major Concerns to Address

### 1. Measurement Error Discussion Needs Strengthening

**Reviewer concern:** The CPS PENSION question asks about "employer" plans, which may not capture auto-IRA participation. This is a critical limitation deserving deeper treatment.

**Revision plan:**
- Add new subsection 4.4 "Measurement Considerations" explicitly showing CPS PENSION question wording
- Explain why auto-IRA participants might respond "No" (auto-IRAs are state-facilitated, not employer-provided)
- Discuss validation: Note that administrative enrollment data from OregonSaves shows 150,000+ enrollees by 2024, while CPS would likely not capture this
- Frame null result as potentially reflecting measurement limitations rather than policy ineffectiveness
- Add caveat that our estimates should be interpreted as effects on self-reported employer-sponsored coverage, not total retirement savings participation

### 2. Oregon's Negative Effect Needs Investigation

**Reviewer concern:** The -2.1pp effect in Oregon (first-mover) is puzzling and undermines confidence.

**Revision plan:**
- Add new paragraph in Section 6.3 investigating Oregon specifically
- Check Oregon's CPS sample size and calculate effective sample for inference
- Conduct leave-one-out sensitivity analysis excluding Oregon from the sample
- Report whether aggregate ATT changes when Oregon is excluded
- Discuss potential explanations: measurement timing, concurrent policies, composition changes
- Add footnote noting Oregon's unique position as first mover may have affected employer behavior differently

### 3. No Heterogeneity by Firm Size

**Reviewer concern:** Auto-IRA mandates target small employers, but no firm size heterogeneity is presented.

**Revision plan:**
- Add new subsection 6.4 "Heterogeneity by Firm Size"
- Estimate effects separately for workers at small firms (<100 employees) vs. large firms (100+)
- The effect should be concentrated among small firm workers if mechanism operates as expected
- Create additional table showing firm size heterogeneity
- Discuss whether null finding reflects genuine policy ineffectiveness vs. targeting of already-covered workers

---

## Minor Concerns to Address

### 4. Missing Robustness Check Tables
- Add Appendix D with robustness check results in tabular form
- Include: not-yet-treated control group comparison, covariate-adjusted estimates

### 5. Power Analysis
- Add power calculation to Discussion section
- Calculate minimum detectable effect given sample size and standard errors
- Frame null result in context of statistical power

### 6. Figure Quality
- Increase axis label font sizes in Figure 1 for journal readability

---

## Implementation Order

1. Run additional R analysis: firm size heterogeneity, leave-one-out, power analysis
2. Update paper.tex with new sections 4.4 and 6.4
3. Add robustness tables to appendix
4. Improve figure quality
5. Recompile and visual QA

---

## Files to Modify

- `code/03_main_analysis.R` - Add firm size heterogeneity, leave-one-out
- `code/04_robustness.R` - Add power analysis
- `paper.tex` - Add sections 4.4, 6.4, Appendix D; revise discussion
- `figures/fig2_parallel_trends.pdf` - Larger axis labels
