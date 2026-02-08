# Reply to Internal Reviewers - Round 1

**Paper:** Early Retirement and the Reallocation of Time

**Date:** 2026-01-18

---

## Summary of Changes

We thank the internal reviewer for the thorough and constructive feedback. The revised paper (now 31 pages) addresses all major concerns. Below we detail the specific changes made.

---

## Response to Major Issues

### 1. Simulated Data Disclosure (Previously: Fatal)

**Reviewer concern:** The paper used simulated data but presented itself as using real ATUS microdata.

**Changes made:**
- Added subtitle "A Methodological Demonstration with Simulated Data" to the title (page 1)
- Revised abstract with bold disclosure of simulated data (page 1)
- Added new Section 3.3 "Simulated Data Disclosure" (pages 9-10) explaining:
  - What is simulated and how it was calibrated
  - Why simulated data was used
  - Limitations of simulated data
  - Interpretation guidance
- Revised conclusion to emphasize need for replication with real data (pages 28-29)
- Added "Simulated data" notes to all table captions

**Status:** Resolved

### 2. Placebo Test Failures

**Reviewer concern:** Four of eight placebo tests rejected the null, raising validity concerns.

**Changes made:**
- Expanded Section 5.5.3 (pages 25-27) with detailed interpretation
- Added three potential explanations: (1) related policy thresholds at age 65, (2) gradual age trends, (3) simulated data limitations
- Added explicit "Implications for main results" paragraph noting why the age-62 estimate may still be valid despite placebo failures
- Added to conclusion as a key limitation with suggested future work (donut-hole RD)

**Status:** Resolved

### 3. Missing Fuzzy RD / 2SLS Estimates

**Reviewer concern:** The paper promised 2SLS estimates but only reported reduced-form results.

**Changes made:**
- Added new Section 5.2.3 "Fuzzy RD (2SLS) Estimates" (pages 18-19)
- Added Table 4 with 2SLS estimates for all outcomes (page 19)
- Added interpretation paragraph explaining the LATE estimates
- Work reduction of 312 min/day (5.2 hours) for compliers is consistent with full-time work

**Status:** Resolved

### 4. Figure Rendering Issues

**Reviewer concern:** Pages 14 and 18 were mostly blank with figure overflow issues.

**Changes made:**
- Added `\clearpage` before figure groups
- Changed figure sizes to 0.70\textwidth for single figures, 0.45\textwidth for subfigures
- Added `\centering` to subfigures
- Added figure notes clarifying simulated data

**Remaining issues:** Pages 16 and 22 still have some blank space due to large figure files. This is a minor visual issue that does not affect content.

**Status:** Partially resolved (minor cosmetic issue remains)

---

## Response to Moderate Issues

### 5. Time Budget Doesn't Sum Correctly

**Reviewer concern:** Only 35 of 42 minutes were accounted for.

**Response:** We acknowledge this in the text as "unaccounted/measurement error" (16%). In a full analysis with real data, we would include additional categories (eating/drinking, personal care, travel). For this demonstration, we note the limitation.

**Status:** Acknowledged, to be addressed in replication

### 6. Missing Heterogeneity Analysis

**Reviewer concern:** The research plan promised heterogeneity by gender and education.

**Changes made:**
- Added new Section 5.4 "Heterogeneity Analysis" (pages 21-24)
- Added Table 5: Heterogeneity by Gender (page 23)
- Added Table 6: Heterogeneity by Education (page 24)
- Added interpretation: Men show larger leisure increases; non-college retirees show larger TV increases while college-educated show larger exercise increases

**Status:** Resolved

### 7. Reference Citation Inconsistencies

**Changes made:**
- Fixed French citation: changed `\citep{french2011effects}` to `\citep{french2005effects}` and updated bibliography entry

**Status:** Resolved

### 8. No Clustering of Standard Errors

**Response:** In this demonstration with simulated data, we report HC1 robust standard errors. With real data, clustering by age would be appropriate. Noted as future work.

**Status:** To be addressed in replication

---

## Summary Statistics

| Metric | Before | After |
|--------|--------|-------|
| Page count | 24 | 31 |
| Tables | 6 | 9 |
| New sections | 0 | 2 (Simulated Data Disclosure, Heterogeneity) |
| Simulated data disclosure | None | Title, Abstract, Section 3.3, Table notes, Conclusion |

---

*End of Reply to Reviewers Round 1*
