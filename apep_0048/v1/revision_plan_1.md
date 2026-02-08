# Revision Plan - Round 1 (Responding to GPT 5.2 Review)

**Date:** 2026-01-21
**Reviewer:** GPT 5.2 (External)
**Decision:** REJECT AND RESUBMIT

## Critical Issues to Address

### Issue 1: Urban/Rural Status is Imputed Randomly (PUBLICATION-BLOCKING)

**Reviewer's concern:** The paper assigns urban status probabilistically based on state-year urbanization rates, which is "random misclassification by design" that:
1. Pushes urban-rural difference toward zero (attenuation)
2. Breaks interpretability (not estimating effect on actually-urban women)
3. Invalidates standard errors

**Resolution:** This is a fundamental limitation of the data. Options:

**Option A (Preferred):** Reframe the paper honestly:
- Acknowledge the limitation explicitly in the abstract and throughout
- Reframe the contribution as examining state-level heterogeneity correlated with urbanization rates, not individual urban/rural effects
- Add robustness showing the pattern holds using state-level urbanization rate as a continuous moderator (no imputation needed)
- Tone down claims about "rural > urban" to "effects correlate with lower state urbanization"

**Option B:** Use alternative urban classification:
- Check if IPUMS has URBAN variable available for some census years
- Use county-level urbanization shares from NHGIS
- Use farm vs non-farm household status (FARM variable)

**Action:** Implement Option A plus check Option B feasibility

### Issue 2: Event Study Figures Have Impossible Scales (PUBLICATION-BLOCKING)

**Reviewer's concern:** Figures 3 and 4 show y-axis values ranging into thousands (-3000 to 3000 percentage points), which is impossible for a 0-1 binary outcome.

**Diagnosis:** The R code looks correct - it uses the regression coefficients directly. Need to inspect the actual figures to verify the issue.

**Action:**
1. Re-examine the generated figures
2. Check if the issue is in the Sun-Abraham model (which has SE=5925)
3. If needed, regenerate figures with proper scaling
4. Ensure y-axis is labeled correctly (percentage points, roughly -0.1 to 0.1 scale)

### Issue 3: Sun-Abraham SE of 5925 is Nonsensical (PUBLICATION-BLOCKING)

**Reviewer's concern:** Table 2 column (4) shows Sun-Abraham ATT with SE = 5925.056, indicating implementation problems.

**Diagnosis:** The Sun-Abraham estimator may have collinearity or cohort identification issues with our coarse time structure (only 4 census years). Many cohorts have only 1 post-treatment observation.

**Resolution:**
1. Remove or de-emphasize Sun-Abraham results given data limitations
2. Focus on TWFE and basic event study as main specifications
3. Acknowledge that modern heterogeneity-robust estimators require richer time variation than decennial census data provides
4. Report Goodman-Bacon decomposition to show which comparisons drive estimates

### Issue 4: Overclaiming Relative to Evidence

**Reviewer's concern:** Paper claims rural > urban "directly contradicts" the policy channel, but:
- Urban-rural difference is not statistically significant in Table 3
- Urban status is imputed (see Issue 1)
- Claims are overstated

**Resolution:**
- Soften language throughout: "suggestive patterns" not "directly contradicts"
- Report p-value for urban-rural difference explicitly
- Acknowledge that we cannot reject equality of urban and rural effects
- Reframe as "exploring heterogeneity" not "rejecting the policy channel"

### Issue 5: Missing References

**Action:** Add citations for:
- Borusyak, Jaravel & Spiess (2021) - imputation estimator
- de Chaisemartin & D'Haultfoeuille (2020) - alternative DiD
- Wooldridge (2021) - two-way FE methods

### Issue 6: Missing Male Placebo

**Reviewer's concern:** Male LFP placebo is mentioned but not shown in main results.

**Action:** Add male placebo analysis to robustness section and potentially main text.

### Issue 7: Paper Too Long

**Reviewer's concern:** 90+ pages is too long; target 40-55 pages.

**Action:** This is acceptable for draft stage but will need trimming for submission.

## Revision Priority Order

1. **CRITICAL:** Fix event study figures (verify scales, regenerate if needed)
2. **CRITICAL:** Fix or remove Sun-Abraham results
3. **CRITICAL:** Reframe urban/rural analysis to acknowledge imputation limitation
4. **HIGH:** Soften language about mechanism claims
5. **MEDIUM:** Add male placebo analysis
6. **MEDIUM:** Add missing references
7. **LOW:** Trim paper length

## Implementation Plan

### Step 1: Diagnose and Fix Figures
- Rerun R code and inspect figures
- Verify y-axis scales
- Fix any scaling issues

### Step 2: Address Sun-Abraham Issues
- Either fix the implementation or remove from main results
- Report as sensitivity analysis with appropriate caveats

### Step 3: Reframe Urban/Rural Analysis
- Add state-level urbanization rate as continuous moderator
- Rewrite interpretation to be more careful
- Acknowledge limitations prominently

### Step 4: Soften Claims Throughout
- Find-replace overclaiming language
- Add explicit statistical caveats

### Step 5: Add Robustness Analyses
- Male placebo
- Additional missing references

### Step 6: Recompile and Re-review
