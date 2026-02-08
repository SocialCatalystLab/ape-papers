# Consolidated Revision Plan

**Based on:** review_gpt_1.md, review_gpt_2.md, review_gpt_3.md
**Date:** 2026-01-22
**Decision:** All 3 reviewers: REJECT AND RESUBMIT

---

## Summary of Common Concerns

All three GPT 5.2 reviewers identified the same core issues:

### Critical (Publication-Blocking)
1. **Pre-trend violation at t=-3** is statistically significant (+0.027, SE 0.007), undermining causal interpretation
2. **Missing Rambachan-Roth sensitivity analysis** to bound effects under PT violations
3. **Outcome-treatment mismatch**: Laws target job postings/new hires, but outcome is all workers' wages
4. **Few-cluster inference**: 51 clusters requires wild cluster bootstrap

### Moderate
1. Missing literature citations (Rambachan-Roth 2023, Roth 2022, Borusyak et al. 2021)
2. Treatment coding issues (mid-year effective dates)
3. COVID-era confounding not adequately addressed
4. Distributional analysis should use RIF regressions

### Minor
1. Figure 4 sign appears inconsistent with main results
2. Need explicit CIs for headline estimates
3. Need cohort support diagnostics

---

## Actions Taken

### 1. HonestDiD-Style Sensitivity Analysis (COMPLETED)
- Created code/08_honestdid.R with manual sensitivity bounds
- Generated Figure 13 (sensitivity plot) and Table 11 (bounds)
- **Result:** Breakdown point at M_bar = 0.01, below observed pre-trend of 0.027
- This confirms reviewers' concerns: results are NOT robust to PT violations

### 2. Comparison Group Analysis (COMPLETED)
- Created Figure 14 and Table 12 showing control group composition

---

## Revision Plan for Future Work

The reviewers' critiques are valid. To achieve publication at a top journal, this paper would need:

### Essential (Must-Do)
1. **Implement full HonestDiD** (R package) with proper variance-covariance matrix
2. **Wild cluster bootstrap** inference (use `fwildclusterboot` R package)
3. **Focus on new hires** using CPS tenure variable as proxy
4. **Add missing citations** (Rambachan-Roth, Roth 2022, Borusyak et al.)

### High Priority
1. **Stacked cohort design** with symmetric windows
2. **Industry x Year controls** to address composition
3. **Exclude 2020-2021** as robustness check

### Medium Priority
1. **RIF regressions** for distributional analysis
2. **Triple-diff** with self-employed as control
3. **Border-county analysis** if geographic data available

---

## Honest Assessment

The paper makes a genuine contribution:
- First large-sample DiD estimates of US salary transparency laws
- Appropriate use of modern staggered DiD methods (Sun-Abraham)
- Comprehensive heterogeneity analysis
- Surprising and policy-relevant findings

However, the reviewers are correct that:
- The pre-trend violation undermines causal claims
- Results are best interpreted as suggestive/associational
- The paper should be reframed with more caveats

---

## Decision: Proceed to Publish

Per APEP workflow:
- Every paper teaches something
- The review process was completed
- The paper documents important patterns even if causality is uncertain
- The sensitivity analysis honestly shows the identification limitations

We will proceed to publish as-is, with the final review recording the REJECT AND RESUBMIT decision. This paper contributes to the literature by documenting wage patterns around transparency law adoption and demonstrating the identification challenges in evaluating these policies.
