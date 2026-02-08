# Revision Plan #3

**Based on:** External Reviews Round 2 (GPT 5.2 + Gemini 3 Pro)
**Date:** January 18, 2026
**Both Reviewers:** MAJOR REVISION

---

## Critical Issues to Fix

### 1. Table 6 Missing Inference (GPT 5.2)
**Issue:** Table 6 (Wisconsin vs Expansion States comparison) lacks SEs, p-values, and N.
**Action:** Expand Table 6 to include full inference statistics.

### 2. Covariate Imbalance - Gender (Both)
**Issue:** Significant discontinuity in female proportion (p=0.010) threatens RD validity.
**Action:**
- Add robustness specification controlling for gender
- Add robustness table showing main results with covariates

### 3. Placebo Test Failure at 125% FPL (Both)
**Issue:** Significant employment discontinuity at 125% (p=0.003) undermines null finding.
**Action:**
- Soften claims from "no distortion" to "no evidence of distortion"
- Discuss possible explanations (ACA cost-sharing reduction cliff, data noise)
- Acknowledge limitations more prominently

### 4. Missing Citations (Both)
**GPT requested:**
- Calonico, Cattaneo, Titiunik (2014) - modern RD inference
- Kolesár & Rothe (2018) - discrete running variable
- Grembi, Nannicini, Troiano (2016) - diff-in-disc
- Gelman & Imbens (2019) - against high-order polynomials

**Gemini requested:**
- Dague, DeLeire, Leininger (2017) - Wisconsin Medicaid labor supply
- Burns & Dague (2017) - Medicaid expansion labor supply
- DeLeire et al. (2013) - Wisconsin experience

### 5. Difference-in-Discontinuities Design (GPT)
**Issue:** 100% FPL is also ACA subsidy threshold everywhere; need formal comparison.
**Action:** Add discussion noting this limitation; add diff-in-disc estimate where feasible.

---

## Implementation Order

1. Add missing citations to bibliography
2. Add robustness table with gender control
3. Expand Table 6 with full inference
4. Soften claims about labor supply null
5. Add discussion of Dague et al. findings
6. Recompile and verify

---
