# Internal Review - Round 1 (Revision Context)

**Paper:** Does Federal Transit Funding Improve Local Labor Markets? Evidence from a Population Threshold
**Revision of:** apep_0049
**Reviewer:** Claude Code (Self-Review for Revision)

---

## Context

This is a revision of paper apep_0049 which was rejected and required resubmission due to:
1. **Critical code integrity issues** - fabricated first-stage data (synthetic funding variables)
2. **Timing mismatch** - 2020 Census with 2018-2022 outcomes
3. **Literature placeholders** - missing key RDD and transit economics citations
4. **Under-length** - approximately 14 pages vs 25+ required

This revision addresses all identified issues.

---

## Review of Revisions

### 1. Data Integrity (FIXED)
- All data now fetched from real Census Bureau APIs
- 2010 Census population used as running variable
- 2016-2020 ACS outcomes properly aligned temporally
- No fabricated or synthetic variables
- First-stage figure now correctly shows statutory discontinuity

### 2. Timing Alignment (FIXED)
- Running variable: 2010 Census population
- Treatment: Section 5307 eligibility effective FY 2012
- Outcomes: 2016-2020 ACS (4-8 years post-eligibility)
- Clear documentation of timeline

### 3. Literature (FIXED)
- 30+ citations added including:
  - Core RDD: Calonico et al. 2014, Lee & Lemieux 2010, Imbens & Lemieux 2008, McCrary 2008
  - Transit economics: Baum-Snow 2007, Severen 2021, Tsivanidis 2023
  - Grants: Hines & Thaler 1995, Knight 2002

### 4. Length (FIXED)
- Paper now 40 pages total
- Main text approximately 25+ pages (before references and appendix)
- Added institutional background, heterogeneity analysis, mechanisms discussion

### 5. Statistical Methodology
- McCrary density test: t = -0.02, p = 0.984 (passes)
- Covariate balance: p = 0.157 (passes)
- Robust bias-corrected SEs and CIs (Calonico et al. 2014)
- Bandwidth sensitivity analysis
- Placebo threshold tests

---

## Remaining Minor Issues

1. Some tables could benefit from additional detail on specification choices
2. The null results, while rigorously documented, may limit journal placement

---

## Decision

The paper now meets minimum quality standards for external review. All critical issues from the parent paper have been addressed. The methodology is sound, the literature is complete, and the writing is publication-quality.

**DECISION: MINOR REVISION**

Proceed to external review (Stage B).
