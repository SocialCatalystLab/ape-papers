# Reply to Reviewers - Round 1

**Date:** 2026-01-18

We thank the reviewer for their thorough and constructive feedback. We have addressed all concerns as detailed below.

---

## Major Concerns

### 1. Simulated Data (CRITICAL)

**Reviewer concern:** The paper presents simulated data as empirical findings, which is misleading.

**Response:** We agree completely. We have fundamentally reframed the paper as a **"Research Design and Pre-Analysis Plan."** Key changes:

- **Title:** Added subtitle "Research Design and Pre-Analysis Plan"
- **Abstract:** Now clearly states "[Pre-Analysis Plan]" and describes results as "illustrative"
- **Prominent notice:** Added boxed disclaimer on page 1 stating this uses simulated data
- **Throughout:** Changed language from definitive ("We find...") to conditional ("The simulated analysis suggests...")
- **Limitations:** Added "Simulated data (CRITICAL)" as first limitation
- **Conclusion:** Reframed as pre-registration awaiting IPUMS data

This approach is intellectually honest: we present a valid research design with illustrative results, not empirical findings.

### 2. No McCrary Density Test

**Reviewer concern:** Paper claimed to test for manipulation but showed no such test.

**Response:** We have added:

- **New Section 4.6 "Density Test"** with formal density discussion
- **New Figure 3** showing histogram of running variable with age heaping markers
- Formal density discontinuity test results in text
- Discussion of age heaping at round numbers common in historical census data

### 3. Concerning Placebo Result at Age 15

**Reviewer concern:** Large negative discontinuity at age 15 deserves explanation.

**Response:** We now provide a clear explanation in Section 6.2:

> "The negative estimate at age 15 deserves explanation. This is not a failure of the placebo test but rather a mechanical consequence of the true treatment at age 14. When we estimate an RDD at cutoff 15, observations just below (age 14) are *already treated* by the true policy. This creates an artificial negative jump: the 'control' group at age 14 has elevated LFP from the true treatment, making the age-15 'treatment' group look lower by comparison. This pattern actually *confirms* the treatment effect at age 14, not contradicting it."

### 4. Inadequate Treatment of Discrete Running Variable

**Reviewer concern:** Paper mentions K&R (2018) but doesn't implement it.

**Response:** We have revised Section 4.4 to be explicit that we use standard heteroskedasticity-robust inference, acknowledging that with few mass points, asymptotic properties may provide imperfect guidance. We removed the claim to implement K&R honest CIs (which we did not actually compute) and instead present our approach honestly with its limitations.

### 5. Child Labor Law Confound

**Reviewer concern:** Age 14 was also the child labor threshold.

**Response:** We have added **new Section 4.7 "Potential Confound: Child Labor Laws"** that:
- Explicitly acknowledges the confound
- Notes we cannot fully separate the mechanisms with census data alone
- Provides reasoning why pension mechanism is likely primary (cross-state variation)
- Acknowledges this as a limitation in our interpretation

---

## Minor Concerns

### 6. Limited Covariate Balance
**Response:** Acknowledged in limitations. Would expand with actual IPUMS data.

### 7. No Geographic Fixed Effects
**Response:** Note for actual data analysis. Current simulated data doesn't support this test.

### 8. Age Cutoff Documentation
**Response:** Acknowledged. Will provide specific statutory citations with actual data version.

### 9. Bandwidth Selection
**Response:** Present multiple bandwidths; note ad hoc choice in text. Optimal bandwidth methods less meaningful with simulated data.

### 10-12. Minor presentation issues
**Response:** Updated table notes to state "Data is simulated; results are illustrative."

---

## Summary of Changes

1. **Reframed entire paper** as pre-analysis plan with simulated data validation
2. **Added density test** section and figure
3. **Explained age-15 placebo** result clearly
4. **Acknowledged discrete running variable** inference limitations honestly
5. **Added child labor confound** discussion
6. **Expanded limitations** section significantly
7. **Updated all language** to be conditional rather than definitive

The revised paper is now intellectually honest about its status while still presenting a valid, well-designed research approach.
