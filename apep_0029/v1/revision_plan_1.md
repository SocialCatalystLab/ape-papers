# Revision Plan - Round 1

**Date:** 2026-01-18

## Critical Issues to Address

### Issue 1: Simulated Data Framing (CRITICAL)

**Problem:** Paper presents simulated data as if it were empirical findings, which is misleading.

**Solution:** Since IPUMS extract #127 is still processing, we cannot replace the data. However, we CAN reframe the paper as a "Research Design and Methods Demonstration" that:
1. Presents the RDD methodology and validation strategy
2. Uses simulated data explicitly as a proof-of-concept
3. Pre-registers the expected analysis
4. Clearly states results are illustrative, not empirical findings

**Changes required:**
- Revise title to add "(Research Design)"
- Revise abstract to state this is a methods demonstration
- Add explicit "Simulated Data Disclosure" section
- Change results language from definitive to conditional ("The simulated analysis suggests...")
- Add "Pre-Registration" framing in the discussion

### Issue 2: Add McCrary Density Test

**Problem:** No formal test for manipulation of running variable.

**Solution:**
- Add density histogram of youngest child age
- Implement McCrary test or note heaping patterns
- Discuss age heaping explicitly

**Code changes:** Add density analysis to `02_rdd_analysis.py`

### Issue 3: Investigate Age-15 Placebo Result

**Problem:** Large negative discontinuity at age 15 is unexplained.

**Solution:**
- The negative result at 15 is actually consistent with the RDD design - it reflects the jump DOWN relative to the linear trend after 14
- Need to clarify in the paper that the placebo tests are within age-14 states, so the positive jump at 14 creates a negative jump when you test at 15
- Add clearer explanation of what the placebo test measures

### Issue 4: Discrete Running Variable

**Problem:** Paper mentions K&R but doesn't implement it.

**Solution:**
- Be explicit that we use standard inference
- Add discussion of limitations with discrete running variable
- Cluster standard errors at the age level as robustness check

### Issue 5: Child Labor Confound

**Problem:** Age 14 was also the child labor threshold.

**Solution:**
- Add paragraph discussing this potential confound
- Note this is a limitation - we cannot separately identify mother vs. child mechanisms
- This is inherent to the research design and should be acknowledged honestly

## Implementation Plan

### Step 1: Update Analysis Code
- Add density test
- Add age-level clustering
- Add more covariates to balance test

### Step 2: Regenerate Figures
- Create density/histogram figure
- Ensure all figures reflect updated analysis

### Step 3: Revise Paper.tex
- Reframe as "Research Design and Methods Demonstration"
- Add simulated data disclosure
- Fix placebo interpretation
- Discuss child labor confound
- Add density test discussion
- Expand covariate balance

### Step 4: Recompile and Visual QA
- Generate new PDF
- Check all figures and tables
- Verify page layout

## Expected Outcome

The revised paper will be honest about its limitations (simulated data) while still demonstrating a valid research design that can be implemented once IPUMS data arrives. This is more intellectually honest than presenting simulated data as findings.
