# Internal Review Round 1 (Claude Code)

**Date:** 2026-01-20

## Reviewer 2 Assessment

### Summary
This paper examines the earnings premium associated with incorporation among self-employed workers using ACS PUMS data. The main finding is that incorporated self-employed earn approximately $24,000 more than unincorporated self-employed after controlling for demographics, education, and hours worked.

### Major Concerns

1. **Identification Strategy Weakness**: The paper relies on selection-on-observables, but the most plausible confounders (business scale, revenue, employees, growth orientation) are completely unobserved in the ACS. The sensitivity analysis shows a robustness value of 0.11, which sounds moderate, but business scale alone likely explains more than 11% of variance in both treatment and outcome.

2. **Measurement Issues**: The ACS "class of worker" question may not cleanly distinguish incorporated from unincorporated businesses. LLCs in particular may be classified inconsistently. The paper should acknowledge this measurement limitation more prominently.

3. **Simultaneity**: The paper mentions but doesn't adequately address that incorporation and income may be jointly determined. High earners face greater tax incentives to incorporate (S-corp salary optimization), creating reverse causality.

### Minor Concerns

1. The heterogeneity table (Table 5) shows raw differences without covariate adjustment. This is misleading given the paper's emphasis on selection bias.

2. The paper should discuss industry-specific incorporation norms more. Some industries (e.g., professional services, medical) have strong incentives to incorporate regardless of individual characteristics.

3. The propensity score model only includes individual characteristics, not business characteristics (unavailable in ACS). This limits its ability to model selection.

### Verdict: MAJOR REVISION

The paper is well-executed within the constraints of the data, but overclaims causality. Should be reframed more explicitly as high-quality descriptive evidence.

---

## Editor Assessment

### Strengths
- Clear research question with policy relevance
- Appropriate use of modern sensitivity analysis (Cinelli-Hazlett)
- Transparent about limitations
- Well-written prose

### Concerns
- The paper's contribution is limited by data constraints
- Similar questions have been studied with better identification (administrative data, panel variation)
- The abstract and introduction should more clearly state that this is primarily descriptive

### Recommendation
The paper should:
1. Reframe contribution as "high-quality descriptive evidence" rather than causal estimation
2. Add discussion of what administrative data would enable for causal inference
3. Be clearer in abstract about identification limitations
4. Consider adding a "bounds" analysis showing range of possible causal effects

### Verdict: MAJOR REVISION

---

## Summary Verdict: MAJOR REVISION

Key revisions needed:
1. Reframe as descriptive/correlational rather than causal
2. More prominently discuss measurement and identification limitations
3. Add adjusted heterogeneity estimates
4. Discuss what would be needed for causal identification
