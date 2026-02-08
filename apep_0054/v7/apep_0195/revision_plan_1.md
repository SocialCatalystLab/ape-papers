# Revision Plan - Round 1

**Paper:** "Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap"
**Date:** 2026-02-06
**Reviews:** GPT-5-mini (MAJOR), Grok-4.1-Fast (MINOR), Gemini-3-Flash (MINOR)

---

## Key Themes Across Reviewers

1. **Inference tension (all 3):** Permutation p=0.154 for gender DDD vs asymptotic p<0.001. Paper must treat design-based inference as primary and soften language.
2. **Pre-trend diagnostics (GPT, Grok):** Joint pre-trend p=0.069 is marginal; t-2 coefficient significant at 10%.
3. **Lee bounds documentation (GPT):** Need clearer trimming fractions and sensitivity.
4. **Missing references (Grok):** Ibragimov-Muller (2010), Obloj-Zenger (2023).
5. **Discussion bullets (GPT, Grok):** Convert to prose.
6. **Compliance/ITT vs TOT (GPT):** Acknowledged as future work limitation.

## Changes Made

### Already Addressed in This Revision (vs parent apep_0162)

1. **Data extension:** CPS ASEC 2025 added (income year 2024), expanding N from 566K to 614K and treated states from 6 to 8.
2. **Lee (2009) bounds:** Implemented for composition concern; bounds [0.042, 0.050] both positive.
3. **Synthetic DiD:** Colorado cohort SDID estimate added (0.0003).
4. **HonestDiD sensitivity:** Updated with extended data; DeltaSD bounds reported.
5. **Inferential hierarchy:** Explicit statement added to Section 5.2 naming C-S + Fisher RI as primary.
6. **DDD as primary estimand:** Explicit statement added to Section 5.3.
7. **Language softened:** All "strong evidence" claims for DDD paired with permutation p-value caveat.
8. **Discussion bullets converted to prose.**
9. **Ibragimov-Muller (2010) reference added.**
10. **NY/HI exclusion robustness added.**

### Deferred to Future Work

- Job-posting compliance data (Burning Glass/Indeed) for IV/TOT estimation
- Quantile treatment effects
- Firm fixed effects via LEHD
- Goodman-Bacon decomposition plot
- Wild cluster bootstrap (fwildclusterboot unavailable for current R version)
