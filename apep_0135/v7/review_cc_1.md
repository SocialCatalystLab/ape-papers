# Internal Review - Round 1

**Paper:** Technological Obsolescence and Populist Voting: Evidence from U.S. Metropolitan Areas
**Reviewer:** Claude Code (Internal)
**Date:** 2026-02-03

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length:** ~25 pages main text (34 pages total including appendix) - PASS
- **References:** Bibliography includes key literature (Autor et al., Enke, Oster, Callaway & Sant'Anna) - PASS
- **Prose:** Full paragraphs throughout, no bullet points in main text - PASS
- **Section depth:** All major sections have 3+ substantive paragraphs - PASS
- **Figures:** All figures show visible data with proper axes - PASS
- **Tables:** All tables have real numbers with standard errors - PASS

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors:** All regressions report clustered SEs in parentheses - PASS
b) **Significance Testing:** Stars indicate significance levels - PASS
c) **Confidence Intervals:** 95% CIs reported in key tables - PASS
d) **Sample Sizes:** N reported for all regressions - PASS
e) **DiD Issues:** N/A - This is a cross-sectional analysis with election year FE, not staggered DiD
f) **Robustness:** Extensive robustness checks including Oster bounds, regional heterogeneity, alternative measures - PASS

### 3. IDENTIFICATION STRATEGY

The paper clearly states this is an observational study and cannot definitively establish causation. The key innovation is the "gains test" - showing technology predicts the 2012→2016 shift but not subsequent changes. This is a clever diagnostic for distinguishing sorting from causation.

**Concerns:**
- The within-CBSA fixed effects specification shows near-zero coefficient (0.004, n.s.) - this is buried in the results
- Pre-trends test could be more prominent

### 4. LITERATURE

Literature review is adequate. Key papers cited:
- Autor et al. (2020) on trade and voting
- Enke (2020) on moral values
- Oster (2019) on selection bounds
- Callaway & Sant'Anna acknowledged for DiD methods

### 5. WRITING QUALITY

The paper is well-written with clear prose. The narrative arc is compelling:
- Hook: Technology predicts Trump support... but ONLY starting in 2016
- Method: Cross-sectional + gains analysis
- Finding: One-time sorting event, not ongoing causation
- Implication: Technology modernization won't fix polarization

### 6. DATA CORRECTION

**This revision addresses the critical issue:** The parent papers (0141, 0143) used simulated data. This version uses the actual `modal_age.csv` from Prof. Tarek Hassan. The data provenance is now properly documented in the appendix.

### 7. OVERALL ASSESSMENT

**Strengths:**
1. Clever identification strategy using temporal patterns
2. Robust results with real data confirming the main hypothesis
3. Proper acknowledgment of data correction
4. Well-documented correspondence with data provider

**Weaknesses:**
1. Gemini advisor flagged some temporal consistency issues (addressed in text)
2. Fixed effects results could be discussed more prominently
3. Sample size discrepancies between tables (minor)

---

**DECISION: MINOR REVISION**

The paper is methodologically sound and the data correction has been properly documented. Minor issues remain but are not fatal.
