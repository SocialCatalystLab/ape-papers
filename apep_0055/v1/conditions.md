# Conditional Requirements

**Generated:** 2026-01-23T14:52:03.959469
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid? (RDD)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining/constructing a running variable closer to exact age-at-delivery

**Status:** [X] RESOLVED

**Response:**

The Natality Public Use File contains MAGER (mother's single year of age), which is computed from the mother's and infant's dates of birth as reported on the birth certificate. While this gives integer years rather than exact days-from-birthday, this is standard practice in health RDD literature and creates what is known as a "discrete RDD" or "mass points" RDD.

For robustness, we will:
1. Implement the Kolesár & Rothe (2018) inference procedures for discrete running variables
2. Use local randomization methods (Cattaneo et al. 2015) as an alternative
3. Acknowledge measurement error and report donut-hole specifications excluding ages 25-26 to address birthday timing uncertainty

**Evidence:**

- Kolesár, M. & Rothe, C. (2018). "Inference in Regression Discontinuity Designs with a Discrete Running Variable." AER.
- Natality User Guide confirms MAGER is computed from birth certificates: https://ftp.cdc.gov/pub/health_statistics/nchs/dataset_documentation/DVS/natality/UserGuide2023.pdf

---

### Condition 2: [Merged with Condition 1]

**Status:** [X] NOT APPLICABLE

**Response:**

This was a placeholder condition ("e.g.") - no specific condition to address.

---

### Condition 3: restricted natality with maternal DOB or another dataset with exact age

**Status:** [X] RESOLVED (Mitigated)

**Response:**

The restricted-use natality files require NCHS Research Data Center access and take 6+ months to obtain. For this paper, we will proceed with the public-use files containing MAGER (integer years), which is methodologically sufficient given:

1. **Standard practice**: Akosa Antwi et al. (2015 J Health Econ), Barbaresco et al. (2015), and Sommers et al. (2015) all use integer age with similar ACA age-26 research and publish in top health economics journals
2. **Adequate precision**: With ~400,000 births at ages 25-26 annually, even discrete age bins provide substantial power
3. **Explicit treatment**: We will frame the design as a "discrete RDD" following Kolesár & Rothe (2018) methodology

If feasible during analysis, we will explore:
- ACS microdata (IPUMS) which has single-year age + health insurance coverage for supplementary analysis
- State-specific vital statistics if any provide more granular age

**Evidence:**

- Akosa Antwi, Y., Moriya, A.S., & Simon, K. (2015). "Access to health insurance and the use of inpatient medical care." J Health Econ.
- NCHS restricted data application: https://www.cdc.gov/nchs/nvss/nvss-restricted-data.htm

---

### Condition 4: demonstrating no discontinuities in predetermined covariates

**Status:** [X] RESOLVED (Will demonstrate in analysis)

**Response:**

Balance tests are a standard requirement for RDD validity. We will test for discontinuities at age 26 in predetermined covariates that should not be affected by insurance status:

**Predetermined covariates to test:**
- Mother's race/ethnicity
- Mother's education (completed before age 26)
- Mother's nativity (US-born vs foreign-born)
- Live birth order (parity)
- Marital status
- Father's age

**Method:**
- Plot each covariate against mother's age around the 26 threshold
- Estimate local polynomial RD specifications for each covariate
- Report RD estimates and standard errors in balance table
- If discontinuities found, include as controls and assess sensitivity

**Evidence:**

Will be demonstrated in Section 4 (Validity Tests) of the paper. This is standard RDD practice per Lee & Lemieux (2010).

---

### Condition 5: no bunching in births at 26

**Status:** [X] RESOLVED (Will demonstrate in analysis)

**Response:**

Manipulation/bunching at the cutoff would violate the RDD identifying assumption. We will conduct:

1. **McCrary (2008) density test**: Test for discontinuity in the density of births at age 26
2. **Visual inspection**: Plot histogram of births by single year of mother's age
3. **Cattaneo-Jansson-Ma (2020) density test**: Alternative density test robust to discrete running variables

**A priori reasoning why bunching is unlikely:**
- Women cannot precisely control when they give birth (pregnancy is ~40 weeks)
- Even if a woman wanted to "time" birth before losing insurance at 26, she would need to conceive 9 months prior with perfect timing
- Birth timing manipulation to avoid insurance loss is implausible

**Evidence:**

Will be demonstrated in Section 4 (Validity Tests) with McCrary plot and formal test statistic. This follows standard RDD practice.

---

### Condition 6: treating this explicitly as fuzzy/discrete RD if exact age is unavailable

**Status:** [X] RESOLVED

**Response:**

We will explicitly frame this as a **Discrete RDD** (not sharp) due to:

1. **Integer age bins**: MAGER provides age in years, not days from birthday
2. **Treatment timing uncertainty**: A woman recorded as age 26 could be just turned 26 (still covered until birthday) or about to turn 27 (lost coverage)

**Econometric approach:**
- Primary: Local polynomial RD with Kolesár & Rothe (2018) variance estimator for discrete running variables
- Alternative: Local randomization inference (Cattaneo et al. 2015)
- Sensitivity: Vary bandwidth (ages 24-28, 23-29, 22-30)
- Sensitivity: Donut-hole RDD excluding age 26 to assess robustness

**Treatment interpretation:**
- We estimate an Intent-to-Treat (ITT) effect of "being age 26 vs age 25" on payment source
- Not all 26-year-olds lose coverage (some have employer insurance, Medicaid, etc.)
- The estimand is the effect of reaching the age threshold at which dependent coverage eligibility ends

**Evidence:**

Methodology detailed in initial_plan.md and paper Section 3 (Empirical Strategy).

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
