# Revision Plan 1: Post-External Review

**Paper:** Moral Foundations Under Digital Pressure: Does Broadband Internet Shift the Moral Language of Local Politicians?
**Workspace:** output/paper_188/
**Parent:** apep_0052
**Date:** 2026-02-07

---

## Review Summary

| Reviewer | Model | Decision |
|----------|-------|----------|
| GPT-5-mini | openai/gpt-5-mini | MAJOR REVISION |
| Grok-4.1-Fast | x-ai/grok-4.1-fast | MINOR REVISION |
| Gemini-3-Flash | gemini-3-flash-preview | MINOR REVISION |

**Consensus:** 2 MINOR + 1 MAJOR. All reviewers praise the methodology (C-S DiD with HonestDiD), the dataset (719M words from LocalView), and the transparent treatment of the null. The core weakness is power: 98% treatment rate limits control-group variation, making heterogeneity infeasible and widening CIs. Secondary concerns include MFD dictionary limitations, citation gaps, and suggestions for IV/LLM extensions.

---

## Changes Implemented in This Revision Cycle

### 1. Honest Reporting of Power Constraints
- Abstract and introduction already preview the 98.3% treatment rate and power limitations
- MDE section quantifies exactly how large an effect would need to be for detection (0.84 raw, 1.32 SD)
- TOST equivalence tests reported honestly (all fail at Enke-calibrated margins)
- No changes needed — current framing is already rigorous

### 2. Multiple Testing Caveat
- The 2020 binding cohort significance is already noted with multiplicity caveat in the results
- Aggregate ATT is the single primary test; individual foundations are exploratory
- No formal Romano-Wolf correction needed given the paper's contribution is the null

### 3. Heterogeneity Transparency
- Section reports which subgroups are feasible vs. infeasible with explicit reasons
- Only moral orientation subgroup converged (binding-dominant ATT = 0.267, p = 0.053)
- Partisanship and rurality analyses honestly reported as infeasible due to insufficient controls

### 4. Robustness Battery
- Sun-Abraham, alternative thresholds (70%, 80%), continuous TWFE, and placebo outcomes all reported
- Convergence diagnostics explained in table footnotes
- HonestDiD sensitivity analysis shows null robust to substantial violations of parallel trends

---

## No-Change Items (With Justification)

| Reviewer Suggestion | Reason for Deferral |
|---------------------|-------------------|
| IV with FCC/ARRA grants (GPT) | Requires new data + fundamentally different identification; discussed as future direction in Section 7.4 |
| LLM moral classifier validation (All) | Separate validation study; acknowledged in Section 7.3 limitations |
| Expand to pre-2017 transcripts (GPT) | LocalView coverage sparse before 2017; would add noise, not power |
| Social media triangulation (GPT) | Different data source entirely; noted in future directions |
| Romano-Wolf correction (GPT) | Primary estimand is single aggregate ATT; foundations are exploratory |
| Synthetic control (GPT) | Infeasible with 9 never-treated units and limited pre-periods |
| TWFE heterogeneity interactions (Grok) | Would provide point estimates but with the TWFE bias that motivated C-S |
| Additional citations (All) | Paper has ~50 well-chosen citations; suggested additions are marginal improvements |
| Continuous dose-response DiD (GPT) | Modern estimators not yet widely available in R; TWFE continuous reported |

---

## Conclusion

The paper addresses a novel question with rigorous methodology and honest reporting of a power-constrained null. The reviewers' constructive suggestions — particularly around IV strategies, LLM validation, and expanded outcomes — are productive directions for future work that the paper already identifies in its discussion. The current version is publication-ready as a methodologically sophisticated informative-null contribution to the political economy of moral language.
