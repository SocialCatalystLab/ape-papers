# Revision Plan for Review 3

**Date:** 2026-01-17
**Paper:** Social Security Eligibility at 62 and Living Alone

## Summary of Review Feedback

Phase 1 (Format): PASS
Phase 2 (Content): MAJOR REVISION REQUIRED

### Critical Issues Identified

1. **Inference with Discrete Running Variable (FATAL)**
   - With only ~5 age support points in the ±2 bandwidth (ages 60-64), person-level HC1 standard errors are invalid
   - Effective variation is at the age-cell level, not person level
   - Must implement cell-level analysis or Kolesár-Rothe-consistent inference

2. **Fuzzy vs Sharp RD Estimand**
   - Currently presenting ITT of eligibility, not LATE of SS receipt
   - Need 2SLS estimates to interpret as "income security" effect

3. **Bandwidth Sensitivity**
   - Results significant at ±2, insignificant at ±3, significant at ±4
   - Suggests fragility in main estimate

4. **Placebo Test Concern**
   - Significant placebo at age 60 (p=0.045) raises concerns about functional form artifacts

5. **Missing Citations**
   - Placeholder citations ("(?)","???") throughout paper
   - Missing core RD references: Imbens & Lemieux 2008, Lee & Lemieux 2010, Calonico et al. 2014, McCrary 2008, Card et al. 2008

6. **Figure/Table Inconsistency**
   - Figure 2 shows jump of -0.004 but Table 3 shows -0.0067

## Planned Revisions

### 1. Implement Cell-Level Inference (Critical)

**Analysis Changes:**
- Collapse microdata to age×year cells (ages 58-66, years 2016-2022)
- Calculate cell-level means for outcome, treatment, and covariates
- Weight by cell population
- Run RD at cell level with cell-clustered standard errors
- This makes effective variation transparent: ~9 age points × 7 years = 63 cells

**Paper Changes:**
- Add new section 3.4 "Inference with Discrete Running Variable"
- Report cell-level estimates alongside individual-level as robustness
- Update standard errors and p-values in main results tables

### 2. Add 2SLS/Fuzzy RD Estimates

**Analysis Changes:**
- First stage: SS_receipt ~ age≥62 + age_centered + controls
- Second stage: living_alone ~ SS_receipt_hat + age_centered + controls
- Report both ITT and LATE estimates

**Paper Changes:**
- Add Table 4b with fuzzy RD results
- Clarify in text that main ITT estimate captures eligibility effect, LATE captures receipt effect
- Update discussion of mechanisms to acknowledge both estimands

### 3. Fix Citations

**Add BibTeX entries for:**
- Imbens & Lemieux (2008) - Journal of Econometrics
- Lee & Lemieux (2010) - Journal of Economic Literature
- Calonico, Cattaneo & Titiunik (2014) - Econometrica
- McCrary (2008) - Journal of Econometrics
- Card, Dobkin & Maestas (2008) - AER

**Fix placeholder citations:**
- Search for "(?" and "???" in paper.tex and replace with proper citations

### 4. Improve Placebo Testing

**Analysis Changes:**
- Run permutation test: estimate RD at cutoffs 58, 59, 60, 61, 63, 64, 65, 66
- Calculate distribution of placebo estimates
- Test whether age-62 estimate is outside placebo distribution

**Paper Changes:**
- Report full placebo distribution in appendix
- Discuss in text how main estimate compares to placebo distribution

### 5. Fix Figure/Table Inconsistency

**Analysis Changes:**
- Verify Figure 2 and Table 3 use same specification
- Update figure annotation to match table estimate

### 6. Add Mechanism Tests

**Analysis Changes:**
- Analyze living arrangements in detail:
  - Living with adult children
  - Living with other relatives
  - Living with nonrelatives
  - Single-person household vs other

**Paper Changes:**
- Add Table showing breakdown of living arrangement changes
- Update mechanisms discussion with empirical support

## Target After Revision

- Cell-level inference with valid standard errors
- Both ITT and LATE estimates reported
- All citations properly formatted
- Consistent figures and tables
- Stronger placebo evidence
- Empirically-grounded mechanism discussion

## Files to Modify

1. `analyze.py` - Add cell-level analysis, 2SLS, placebo permutation
2. `paper.tex` - Add references, fix citations, update results, add tables
3. `figures/` - Update figure annotations
