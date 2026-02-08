# Revision Plan - Round 1

## Critical Issues to Address

### 1. Internal Inconsistency (Table 2) - HIGHEST PRIORITY
**Problem:** Interaction model implies smaller effect for high-automation workers (-2.0pp), but stratified models show larger effect (-4.3pp vs -2.5pp).

**Root cause:** The interaction coefficient in a pooled model doesn't directly give the difference between stratified coefficients because:
- The interaction model constrains other coefficients (age slopes) to be the same across groups
- Different group sizes affect weighting
- The `high_automation_proxy` main effect absorbs level differences

**Fix:**
- Remove the misleading interpretation of the interaction model
- Present stratified results as the main evidence
- Report a proper difference-in-discontinuities test using the delta method or bootstrap

### 2. RDD Implementation
**Problems identified:**
- Discrete running variable (age in years) requires special inference
- Quadratic polynomials over 10-year windows is not best practice
- Bandwidth choice is ad hoc

**Fixes:**
- Add rdrobust with CCT robust bias-corrected inference (already in analysis but not emphasized)
- Note the discrete RV limitation explicitly
- Add optimal bandwidth selection
- Add covariate balance tests at cutoff

### 3. Education as Automation Proxy
**Problem:** Education correlates with many factors beyond automation exposure.

**Fix:**
- Reframe as "education-based heterogeneity" with automation as one interpretation
- Acknowledge explicitly that this is a proxy
- Discuss alternative interpretations (health, wealth, pension coverage, etc.)
- Note that occupation-based measures would require addressing selection into employment

### 4. Paper Length
**Problem:** 16 pages is too short.

**Fixes:**
- Expand institutional background with more detail on Medicare enrollment
- Expand literature review with suggested citations
- Add covariate balance table
- Add first-stage check (insurance coverage discontinuity)
- Expand mechanism discussion
- Add more detailed robustness checks

## Specific Changes to Make

### paper.tex revisions:
1. ~~Remove the interaction model interpretation that contradicts stratified results~~
2. Add covariate balance figure/table
3. Add rdrobust results with CCT inference as main specification
4. Expand literature with BibTeX entries from review
5. Add first-stage insurance check (if data available)
6. Add explicit discussion of discrete RV limitation
7. Expand each section to meet length requirements

### code/06_revisions.R:
1. Add covariate balance checks
2. Implement rdrobust with all proper options
3. Create first-stage figure (if insurance data available)
