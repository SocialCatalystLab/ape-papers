# Revision Plan - Round 1

Based on Internal Review from Claude Code

---

## Critical Priority

### 1. Fix Event Study and Add Figure

**Problem:** Event study code failed with formula parsing error.

**Solution:**
- Rewrite event study to use properly constructed dummy variables
- Generate event study plot showing pre/post coefficients
- Add as Figure 2 in paper with discussion of parallel trends

### 2. Add Wages to Results OR Remove from Abstract

**Problem:** Abstract mentions wages but results don't include them.

**Decision:** Remove "wages" from abstract. The log wage variable has many missing values (only for employed workers with positive wages), which would reduce sample size substantially and introduce sample selection. Better to remove the claim.

---

## Major Priority

### 3. Explain Sample Size Difference

**Problem:** N drops from 3.2M to 2.66M without explanation.

**Solution:** Add note to Table 2 explaining:
- Main regression excludes partially treated individuals (~551,683 obs)
- Confirm: 719,990 (fully treated) + 1,937,850 (never treated) = 2,657,840 ✓

### 4. Address Few Clusters Issue

**Problem:** Only 16 state clusters may cause inference problems.

**Solution:** Add paragraph to Section 5 acknowledging this limitation. Note that wild cluster bootstrap would be computationally intensive with 2.6M observations, but the direction of bias (likely understated SEs) reinforces our null findings.

### 5. Add Robustness Checks

**Solution:** Add new section 4.4 "Robustness Checks" with:
- Alternative treatment definition (include partially treated)
- Continuous exposure measure (years of ban exposure)
- Results without demographic controls

---

## Minor Priority

### 6. Add Disability to Table 2

Add Column (5) showing disability results.

### 7. Strengthen Wikipedia Citation

Revise to: "We compile state-level ban years from legal records, state education codes, and secondary sources. We verify dates against state legislative records where available."

### 8. Note ACS 2020 Gap

Add sentence: "Note that ACS 1-year estimates for 2020 were not released due to data collection disruptions from COVID-19."

### 9. Clarify Age Control

Change "age at time of survey" to "age at time of survey (entered as a continuous linear control)"

### 10. Improve Table 2

- Add treated group means
- Add note about sample restriction to fully/never treated

### 11. Fix Heterogeneity Table

Keep Table 3 for education only. The employment heterogeneity is secondary and can remain in text only.

### 12. Clarify Birth Year Logic

Add sentence explaining that fully treated individuals must be born after (ban_year - 6) to have entered school entirely after the ban.

---

## Implementation Order

1. Fix analysis code (event study)
2. Re-run analysis
3. Update paper.tex with all changes
4. Recompile PDF
5. Visual check

---

**Target:** Complete revisions and proceed to Internal Review Round 2
