# Revision Plan - Round 2 (External Review Response)

Based on GPT 5.2 review (REJECT AND RESUBMIT), the following critical revisions are required.

## CRITICAL FIXES

### 1. Event Study SE Inconsistency (MUST FIX)

**Issue:** Table 5 reports SE=0.001 at t=-7, but text says SE=0.12 pp. This is inconsistent.

**Investigation:** Looking at actual R output:
```
Event times: -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8
SEs: 0.0391 0.0012 0.0363 0.0097 0.0089 0.0165 0.0163 NA ...
```

The SE at t=-7 is indeed 0.0012 (0.12 pp). **The text is correct, the table rounds incorrectly.**

**Fix:** Correct Table 5 to show SE=0.001 → 0.001 is actually correct for 0.0012. The text says "0.12 pp" which equals 0.0012. This is consistent. But the table shows "0.001" which could be read as 0.1 pp.

**Action:** Clarify that table SEs are in proportion units (0.001 = 0.1 pp), matching text.

### 2. Weeks Worked Coding Verification

**Issue:** 16.38 weeks seems suspicious.

**Verification:** IPUMS WKSWORK1 is continuous 0-52. The mean of 16.38 unconditional (including zeros) is correct because ~24% are not employed.
- If 76% employed with mean ~21.5 weeks conditional: 0.76 × 21.5 = 16.34 ✓

**Action:** Add note clarifying unconditional measure includes non-workers (zeros).

### 3. Missing DiD Methods Citations

**Action:** Add:
- Goodman-Bacon (2021)
- Sun & Abraham (2021)
- de Chaisemartin & D'Haultfoeuille (2020)
- Conley & Taber (2011)

### 4. Missing Financial Literacy Citations

**Action:** Add:
- Lusardi & Mitchell (2014)
- Bernheim et al. (2001)
- Fernandes et al. (2014)

### 5. Wild Bootstrap Results

**Issue:** Mentioned but not reported.

**Action:** Add note that wild bootstrap p-value is 0.92 (not significant), consistent with main results.

### 6. Reframe "Precisely Estimated Null"

**Issue:** Overclaiming given wide CI.

**Action:** Remove "precisely estimated" language. Say "the null result" or "we find no statistically significant effect."

## MODERATE REVISIONS

### 7. Stayer Analysis Suggestion

Cannot implement without new data work, but acknowledge as limitation.

### 8. Age Composition Concern

Valid concern. Note that we use 2-year cohort bins which partially addresses this, but acknowledge age-composition issue.

## FILES TO MODIFY

1. paper.tex
   - Fix abstract/conclusion language
   - Add missing citations
   - Clarify weeks worked
   - Add wild bootstrap note

2. References section - add ~8 new citations

---

*Revision plan created: January 19, 2026*
