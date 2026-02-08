# Revision Plan - Round 3 (External Review Round 2)

**Responding to:** GPT 5.2 Review + Gemini 3 Pro Review (Round 2)
**Date:** January 2026
**Verdict:** Both REJECT on methodological grounds

---

## Critical Issues Identified

### 1. Fundamental Design Flaw: State-Level Data for Municipal Policy
**Both reviewers:** SB 323 (duplex legalization) applies only to cities >5,000 pop. Using state-level data "dilutes the treatment effect" and "discards the most valuable variation."

**Assessment:** This is a valid critique. However, acquiring and processing place-level BPS microdata would require:
- FOIA request or special tabulation from Census
- Several months of lead time
- Different analysis framework

**Decision:** Acknowledge as major limitation. Note that statewide ADU reform (SB 528) does apply universally, making state-level analysis more appropriate for that component.

### 2. TWFE Inappropriate for N=1 Treated Unit
**Both reviewers:** Should use Synthetic Control Method (SCM) instead of unweighted average of neighbors.

**Action:** Implement Synthetic Control Method as primary estimator
- Use all 49 non-Montana states as donor pool
- Report donor weights and pre-fit diagnostics
- Keep DiD as secondary/robustness check

### 3. Pre-Trends Violated
**Both reviewers:** Figure 2 shows problematic pre-period fluctuation.

**Action:**
- Report formal joint F-test for pre-treatment coefficients
- SCM will construct counterfactual matching pre-period
- Acknowledge this limitation explicitly

### 4. Need Permutation Inference
**Both reviewers:** With N=1, need placebo tests (run "treatment" on each control state).

**Action:** Implement Abadie et al. (2010) style permutation test
- Run SCM treating each donor state as "treated"
- Generate distribution of placebo effects
- Report where Montana's estimate falls

### 5. Missing Core DiD/SCM Citations
**GPT provides BibTeX for:**
- Callaway & Sant'Anna (2021)
- Goodman-Bacon (2021)
- Sun & Abraham (2021)
- de Chaisemartin & d'Haultfoeuille (2020)
- Conley & Taber (2011)
- Ferman & Pinto (2019)
- Cameron, Gelbach & Miller (2008)
- MacKinnon & Webb (2017)
- Arkhangelsky et al. (2021) Synthetic DiD
- Ben-Michael, Feller, Rothstein (2021)

**Gemini adds:**
- Greenaway-McGrevy & Phillips (2021) - Auckland upzoning

**Action:** Add all 11 citations with proper BibTeX

### 6. Literature Review Too Thin
**Action:** Expand literature review with:
- Modern DiD methodology section
- Synthetic control discussion
- Auckland upzoning results (Greenaway-McGrevy)
- More ADU/upzoning empirical literature

---

## Implementation Plan

### Phase A: Add Missing Citations (11 new references)
All BibTeX entries provided by reviewers - add to paper.tex

### Phase B: Implement Synthetic Control Method
1. Create `code/03_synthetic_control.py`
2. Use all 49 non-treated states as donor pool
3. Construct synthetic Montana matching pre-period outcomes
4. Generate:
   - Donor weights table
   - Pre-period fit diagnostics (RMSPE)
   - Main treatment effect estimate
   - Placebo permutation tests (all donors)
   - Rank of Montana in placebo distribution

### Phase C: Update Paper
1. Add SCM to methodology section
2. Report SCM as primary estimator in results
3. Move DiD to robustness
4. Add formal pre-trends test
5. Expand literature review
6. Update discussion to acknowledge data limitations
7. Reframe contribution as "early monitoring" not causal

### Phase D: Visual QA
1. Recompile PDF
2. Verify all new citations render
3. Check figure/table references
4. Verify page count

---

## Honest Assessment

The reviewers are correct that this design has fundamental limitations:
- State-level aggregation masks relevant variation
- N=1 requires specialized inference
- Pre-trends are imperfect

We can address #2 and #3 with SCM/permutation tests. We cannot address #1 without different data. The paper should be reframed as:
- A preliminary policy monitoring exercise
- Demonstrating methodological improvements
- Clearly acknowledging limitations
- Not claiming strong causal identification

This is likely a **field journal** paper (JUE, RSUE) not AER/QJE.
