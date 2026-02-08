# Internal Review (Round 1)

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-21
**Paper:** Do State Automatic IRA Mandates Increase Retirement Savings Coverage?

---

## Summary

This paper provides the first quasi-experimental evaluation of state automatic IRA mandates using CPS ASEC data from 2010-2024. Using a Callaway-Sant'Anna difference-in-differences design exploiting staggered adoption across 11 states, the paper finds a null overall effect (ATT = 0.75pp, SE = 1.0pp) with substantial heterogeneity across treatment cohorts.

---

## Strengths

1. **Novel and policy-relevant question**: State auto-IRA mandates are a growing policy response to the retirement coverage gap, and this is the first quasi-experimental evaluation using nationally representative data.

2. **Methodologically sound**: The paper appropriately uses the Callaway-Sant'Anna estimator to address biases from staggered treatment timing and heterogeneous effects. The event study provides good support for parallel trends.

3. **Honest reporting of null results**: The paper does not oversell findings. It clearly states the null result and thoughtfully discusses multiple explanations including measurement error.

4. **Good figures**: The parallel trends figure and event study figure effectively communicate the main findings. The policy adoption map provides useful context.

5. **Clear writing**: The paper is well-organized and clearly written.

---

## Major Concerns

### 1. Measurement Error Discussion Needs Strengthening

The paper repeatedly mentions that CPS may not capture auto-IRA participation because the question asks about "employer" plans. This is a critical limitation that deserves deeper treatment:

- **Action needed**: Add a subsection in the Data section explicitly showing the CPS PENSION question wording and explaining why auto-IRA participants might not respond affirmatively.
- **Action needed**: Discuss validation. Could administrative enrollment data from OregonSaves/CalSavers be compared to CPS coverage rates in treated states to quantify potential measurement error?

### 2. Oregon's Negative Effect Needs Investigation

The finding that Oregon (the first-mover) shows a significant negative effect of -2.1pp is puzzling and undermines confidence in the overall findings:

- **Action needed**: Investigate whether Oregon experienced any confounding shocks in 2017 (labor market, policy changes, etc.)
- **Action needed**: Consider whether the CPS sample size in Oregon is sufficient for reliable state-level inference
- **Action needed**: Run a leave-one-out sensitivity analysis excluding Oregon

### 3. No Heterogeneity by Firm Size

The paper states that auto-IRA mandates primarily target small employers, but does not present heterogeneity analysis by firm size:

- **Action needed**: Estimate effects separately for workers at small firms (<100 employees) vs. large firms (100+). The effect should be concentrated among small firm workers if the mechanism operates as expected.

---

## Minor Concerns

1. **Missing robustness checks**: The paper mentions several robustness checks (not-yet-treated control, covariates) in the text but doesn't present these results in tables.

2. **Literature review**: Could cite more of the emerging state auto-IRA evaluation literature. Are there any working papers using administrative data?

3. **Power analysis**: Given the null result, a power analysis would help readers understand whether the study is adequately powered to detect economically meaningful effects.

4. **Standard errors**: The paper notes small treatment cohorts (warning from the `did` package). Should discuss implications for inference more explicitly.

5. **Figure quality**: Figure 1 (parallel trends) could use slightly larger axis labels for readability at journal column width.

---

## Verdict

**MAJOR REVISION**

The paper addresses an important question with appropriate methods and reports findings honestly. However, the measurement error concern is severe enough that readers may not know how to interpret the null finding. The Oregon puzzle also needs resolution. I recommend major revisions to address these issues before considering for publication.

---

## Revision Priorities

1. Strengthen the measurement error discussion with validation if possible
2. Investigate and discuss Oregon's negative effect
3. Add heterogeneity by firm size
4. Present robustness check results in tables
5. Minor edits to figures and text
