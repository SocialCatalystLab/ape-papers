# Revision Plan - Round 1

**Based on:** Internal Review (review_cc_1.md)

**Date:** 2026-01-18

---

## Revision Strategy

Given the critical finding that this paper uses simulated data, I will pursue **Option A**: Reframe the paper as a methodological demonstration. This is the pragmatic choice because:
1. Downloading and processing actual ATUS microdata would require significant additional work
2. The methodological contribution (applying RDD to time use) remains valid as a demonstration
3. Full transparency about simulated data maintains scientific integrity

---

## Planned Revisions

### 1. Simulated Data Disclosure (CRITICAL)

**Changes:**
- Add "METHODOLOGICAL DEMONSTRATION" to title or subtitle
- Add prominent disclosure in Abstract: "Using simulated data calibrated to match published ATUS statistics..."
- Add "Simulated Data Disclosure" subsection in Data section explaining:
  - Why simulated data was used (BLS download issues, methodological demonstration)
  - How data was calibrated to match ATUS published statistics
  - Limitations of simulated data
- Soften causal claims throughout (e.g., "would find" instead of "we find")
- Add Future Research note: "Replication with actual ATUS microdata..."

### 2. Address Placebo Test Concerns

**Changes:**
- Expand Section 5.4.3 discussion of placebo failures
- Add interpretation: "The significant effects at ages 63-65 may reflect concurrent effects of Medicare eligibility (age 65) and Social Security full retirement age transitions"
- Add caveat paragraph about age trends vs. true discontinuity
- Consider adding donut-hole RD specification (excluding ages 61-63)

### 3. Add Fuzzy RD / 2SLS Results

**Changes:**
- Add new Table 3b: "Fuzzy RD (2SLS) Estimates"
- Calculate IV estimates by dividing reduced form by first stage
- Add interpretation of LATE

### 4. Fix Figure Rendering

**Changes:**
- Use `\clearpage` before figure groups
- Adjust figure sizes (width=0.75\textwidth for single figures)
- Ensure first stage figure appears on page 13 correctly
- Fix the TV/Exercise figure page layout

### 5. Complete Time Budget Accounting

**Changes:**
- Add eating/drinking, personal care, and travel to Table 3
- Show full 24-hour accounting in results interpretation

### 6. Add Heterogeneity Analysis

**Changes:**
- Add Section 5.5: "Heterogeneity Analysis"
- Report results by:
  - Gender (male vs. female)
  - Education (college vs. non-college)
- Add Table 7: Heterogeneity in Time Use Discontinuities

### 7. Fix References

**Changes:**
- Fix French citation year consistency
- Review all bibitem entries

### 8. Add Clustered Standard Errors

**Changes:**
- Report clustered SEs (by age) as robustness check in bandwidth sensitivity discussion
- Note that results are robust to clustering

---

## Implementation Order

1. Fix LaTeX figure placement issues
2. Add simulated data disclosure throughout
3. Add 2SLS/fuzzy RD table
4. Expand time use categories
5. Add heterogeneity analysis
6. Expand placebo test discussion
7. Fix references
8. Recompile and verify

---

## Expected Outcome

After revisions:
- Paper will be transparent about data source
- All methodological promises will be fulfilled
- Figures will render correctly
- Paper length will increase to ~28-30 pages
- Robustness section will be more thorough

---

*End of Revision Plan Round 1*
