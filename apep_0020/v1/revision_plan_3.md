# Revision Plan - Round 3

## Review Summary

Phase 1 (Format): **PASS**
Phase 2 (Content): **Major revision required**

## Critical Issues to Address

### 1. Inference with Discrete Running Variable (HIGH PRIORITY)
**Issue:** Standard RDD inference relies on continuous running variable. With only 9 age points (58-66), standard errors are unreliable.

**Solution:**
- Cluster standard errors at the age level following Lee & Card (2008)
- Add explicit discussion of discrete running variable limitations
- Include permutation inference as robustness check

### 2. Household-Level Clustering for Spillovers (HIGH PRIORITY)
**Issue:** Multiple parents per household share treatment, person-level SEs overstate precision.

**Solution:**
- Cluster standard errors at household level for spillover regressions
- Report both person-clustered and household-clustered SEs

### 3. Treatment Validation - Social Security Receipt (HIGH PRIORITY)
**Issue:** No evidence that SS claiming actually jumps at 62 in our sample.

**Solution:**
- Add Figure 4: RDD plot of Social Security income receipt by age
- Add Table showing first-stage on SS receipt indicator
- Use SSIP (Social Security income) variable from PUMS

### 4. Missing Key Citations (MEDIUM PRIORITY)
**Issue:** Missing foundational RDD methodology papers.

**Add citations:**
- Lee & Card (2008) - discrete running variable inference
- McCrary (2008) - density test
- Calonico, Cattaneo & Titiunik (2014) - robust bias-corrected inference
- Imbens & Kalyanaraman (2012) - optimal bandwidth
- Coile & Gruber (2007) - SS incentives and retirement
- Friedberg (2000) - SS earnings test

### 5. Covariate Balance Tests (MEDIUM PRIORITY)
**Issue:** Asserted smoothness but not displayed.

**Solution:**
- Add table showing covariate means by age around cutoff
- Test for discontinuities in education, sex, race, marital status

### 6. Selection into Multigenerational Households (MEDIUM PRIORITY)
**Issue:** Household composition may change at 62.

**Solution:**
- Add robustness test: RDD for probability of multigenerational living in full 58-66 population
- Discuss limitation in text

### 7. Grandparent Identification (ACKNOWLEDGE LIMITATION)
**Issue:** Age-only definition includes non-grandparents.

**Solution:**
- Acknowledge as limitation in Discussion section
- Note that RELSHIPP variable could be used but requires more complex sample construction
- Attenuation bias works against finding effects

## Implementation Order

1. Update analysis.py:
   - Add age-clustered SEs
   - Add household-clustered SEs for spillovers
   - Add SS income receipt RDD
   - Add covariate balance tests

2. Generate new Figure 4 (SS receipt by age)

3. Update paper.tex:
   - Add new citations to bibliography
   - Add Figure 4 and discussion
   - Add covariate balance discussion
   - Expand discrete running variable discussion
   - Add new table with clustered SEs
   - Expand limitations section

4. Recompile and re-review
