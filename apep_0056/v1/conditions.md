# Conditional Requirements

**Generated:** 2026-01-23T19:49:30.515468
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

## Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid Coverage? A Regression Discontinuity Design

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining restricted natality with month/date-of-birth or age-in-months

**Status:** [X] RESOLVED

**Response:**

We will proceed with the **public use natality microdata** which contains mother's age in **single completed years** (variable MAGER). While restricted data would provide month/date of birth, the public data provides sufficient variation for a discrete RD design.

The key insight is that with ~3.6 million births annually and ~150,000+ births to mothers age 25-26, we have enormous sample sizes at each integer age. The discrete RD approach following Kolesár & Rothe (2018) is well-suited to this setting.

**Mitigation:** We will implement a discrete/fuzzy RD design using local randomization inference (Cattaneo et al. 2015) rather than continuity-based RD. This is appropriate when the running variable has few mass points.

**Evidence:**

- NBER Natality Data: https://www.nber.org/research/data/vital-statistics-natality-birth-data
- Variable MAGER provides single year of age for mother
- Source of payment variable (PAY_REC) available in public use files since 2003 revision
- Sample size: ~150,000 births/year to mothers exactly age 25 or 26

---

### Condition 2: pre-registering a discrete-RD plan if restricted access fails

**Status:** [X] RESOLVED

**Response:**

We formally commit to a discrete-RD approach using public data. The analysis plan:

1. **Primary specification:** Local randomization RD using `rdlocrand` package in R (Cattaneo, Frandsen, & Titiunik 2015)
2. **Window selection:** Ages 23-28 (3 years on each side of cutoff)
3. **Inference:** Randomization-based p-values and confidence intervals rather than asymptotic normal approximation
4. **Bandwidth sensitivity:** Test narrower (24-27) and wider (22-29) windows
5. **Fuzzy RD:** Treatment is "lost parental coverage" which is imperfectly proxied by age 26; estimate ITT effects

**Evidence:**

- Kolesár, M., & Rothe, C. (2018). "Inference in Regression Discontinuity Designs with a Discrete Running Variable." American Economic Review.
- Cattaneo, M. D., Frandsen, B. R., & Titiunik, R. (2015). "Randomization Inference in the Regression Discontinuity Design." Journal of Causal Inference.
- `rdlocrand` R package: https://rdpackages.github.io/rdlocrand/

---

### Condition 3: explicit density/composition tests around 26

**Status:** [X] RESOLVED

**Response:**

We will conduct comprehensive density and balance tests:

**Density Tests:**
1. McCrary (2008) density test for bunching at age 26 (even with discrete running variable, can test for mass point differences)
2. Visual inspection of birth counts by single year of age
3. Test for manipulation: impossible to manipulate birthday, but can test if pregnancy timing/delivery timing shifts

**Composition Tests (Balance):**
1. Test for discontinuities in predetermined covariates at age 26:
   - Mother's education
   - Mother's race/ethnicity
   - Parity (birth order)
   - Prenatal care timing
   - Marital status (NOTE: marriage could be a mechanism, not balance test—will interpret cautiously per Paper 64 lesson)
2. Covariate balance plots showing means by single year of age
3. Joint F-test for all covariates at cutoff

**Evidence:**

- McCrary, J. (2008). "Manipulation of the Running Variable in the Regression Discontinuity Design." Journal of Econometrics.
- Will implement in R using `rddensity` and manual covariate balance tests
- Critical note from Paper 64: Marriage at age 26 is NOT predetermined and could be a response to coverage loss (marry for spousal coverage). We will test marriage but interpret it as potential mechanism, not validity failure.

---

## Do State Data Breach Notification Laws Affect Corporate Cybersecurity Investment? Evidence from Staggered Adoption (2002-2018)

**Rank:** #3 | **Recommendation:** CONSIDER

**Status:** NOT PURSUING — We are pursuing Idea #1 (Age-26 RDD) instead. These conditions are NOT APPLICABLE.

### Conditions 1-5: NOT APPLICABLE

We are not pursuing this idea. The Age-26 Medicaid RDD (Idea #1) scored higher and has cleaner identification.

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Status: RESOLVED — Ready to proceed to Phase 4**
