# Internal Review - Round 1

**Paper:** "The End of Aid: How Losing Mothers' Pension Eligibility Affected Maternal Labor Supply in Early 20th Century America"

**Reviewer:** Claude Code (Internal - Acting as Reviewer 2)

---

## Overall Assessment

This paper proposes an interesting RDD design using an understudied policy cutoff. The research question is well-motivated and the cross-state validation is a creative identification strategy. However, there are **major concerns** that must be addressed before this paper can be considered credible.

**Recommendation: Major Revision Required**

---

## Major Concerns

### 1. Simulated Data (CRITICAL)

The paper states it uses "simulated data calibrated to historical census statistics." **This is fundamentally problematic.** The entire empirical contribution rests on data where the treatment effect was programmed in by the researcher:

```python
# From 01_simulate_data.py, line 90-92:
lfp_prob = (PARAMS['lfp_base'] +
            PARAMS['lfp_age_trend'] * (youngest_age - cutoff) +
            PARAMS['lfp_jump_at_14'] * above_cutoff)  # <-- 0.08 jump built in!
```

The "finding" of an 8.2 pp effect is simply recovering the 8 pp parameter the researcher hard-coded. The cross-state validation "works" because the code assigns different cutoffs to different states. **This is circular reasoning, not empirical analysis.**

**Required action:** The paper cannot be published with simulated data. The IPUMS extract (#127) must be processed, or the paper must be clearly designated as a "pre-registration" or "methods demonstration" rather than an empirical study.

### 2. No McCrary Density Test

The paper claims "We test this by examining the density of the running variable around the cutoff" but **no such test appears in the paper**. A McCrary (2008) or Cattaneo, Jansson, Ma (2020) density test is standard in RDD papers.

In historical census data, age heaping is a known issue. Ages 10, 15, and 20 typically show excess mass. If mothers systematically misreported children's ages, this could bias estimates.

**Required action:** Add formal density test and histogram of the running variable.

### 3. Concerning Placebo Result at Age 15

The paper finds a large, statistically significant NEGATIVE discontinuity at age 15 (-9.8 pp, p < 0.001). This is **as large as the main effect but opposite in sign**. The paper dismisses this as a "composition effect" without investigation.

If there's a true discontinuity at 15, this undermines the RDD assumptions. Why would composition suddenly change at 15 but not at 14? This pattern is suspicious and needs explanation.

**Required action:** Investigate the age 15 discontinuity. Consider whether this reflects methodological problems with the discrete running variable.

### 4. Inadequate Treatment of Discrete Running Variable

The paper mentions Kolesár & Rothe (2018) but doesn't actually implement their methods:

- No honest confidence intervals reported
- Standard errors are simply HC1 robust, not adjusted for discrete running variable
- With only ~6 unique age values in the typical bandwidth, asymptotic properties may not hold

**Required action:** Either implement K&R honest CIs or be explicit that standard inference is used with a discrete running variable and discuss limitations.

### 5. Child Labor Law Confound

Age 14 was the minimum working age under most state child labor laws during this period. The discontinuity at age 14 could reflect:

1. Mother increasing LFP when pension is lost (the claimed mechanism)
2. Child entering labor force, changing household dynamics
3. Interaction between these mechanisms

The paper does not adequately distinguish these channels. If the child's age 14 itself changes household labor supply composition, this is a confound to interpreting the effect as purely mother's response to pension loss.

**Required action:** Discuss child labor laws explicitly. Consider whether you can test for this using variation in state child labor age minimums.

---

## Minor Concerns

### 6. Limited Covariate Balance

Only 3 covariates tested (mother's age, number of children, urban). Historical census data contains:
- Race
- Nativity (foreign-born status)
- Literacy
- Homeownership/rent status

These should be tested for balance.

### 7. No Geographic Fixed Effects

The paper does not use county or state fixed effects despite having geographic identifiers. This is unusual for RDD papers using geographic data.

### 8. Age Cutoff Documentation

The paper's Table 1 lists state cutoffs but provides only a general citation to "Children's Bureau publications." Each cutoff should be documented with specific statutory or archival citations.

### 9. Bandwidth Selection

The paper uses ad hoc bandwidth selection (BW=2 as "preferred"). Why not implement IK or CCT optimal bandwidth selection?

### 10. Missing Weights

Census data requires person weights (PERWT) for population-representative estimates. The code doesn't appear to use weights.

### 11. Standard Error Clustering

With a discrete running variable, clustering at the age level is recommended but the paper clusters only with HC1 robust SEs.

---

## Presentation Issues

### 12. Abstract Overstates

The abstract states findings as fact ("We find that losing pension eligibility caused an 8.2 percentage point increase...") when the underlying data is simulated. This is misleading.

### 13. Sample Size Asymmetry

Table 3 shows 9,789 observations below cutoff vs 15,112 above within BW=2. This asymmetry (ages 12-13 vs 14-16) should be discussed.

---

## Summary of Required Revisions

**Critical (must address):**
1. Replace simulated data with actual IPUMS data, OR clearly frame as pre-registration
2. Add McCrary density test
3. Investigate and explain age-15 placebo result
4. Address discrete running variable inference properly

**Important:**
5. Discuss child labor law confound
6. Expand covariate balance tests
7. Consider geographic fixed effects
8. Provide specific citations for age cutoffs

**Minor:**
9. Implement optimal bandwidth selection
10. Use sampling weights
11. Consider clustering at age level
12. Acknowledge sample size asymmetry

---

## Questions for Authors

1. When will the IPUMS extract be available? Can this be expedited?
2. Do you have state-level variation in child labor laws to distinguish mechanisms?
3. What explains the negative discontinuity at age 15?
4. Have you verified the age cutoffs in primary sources (state statutes)?
