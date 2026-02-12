# Revision Plan — Round 1

## Summary of Referee Feedback

All three referees (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash) recommend **MAJOR REVISION**. The paper is praised for its ambition, narrative quality, and policy relevance, but three cross-cutting concerns dominate:

1. **Placebo test failure**: All referees flag the significant pre-trends as the primary threat to causal interpretation.
2. **Inference reporting**: GPT requires 95% CIs (currently 68%/90%), cluster counts, and more conservative inference methods.
3. **Literature gaps**: Several missing methodological references.

## Planned Changes

### A. Identification & Robustness (Critical)

1. **Augmented shock approach** (Gemini suggestion): Regress JK shocks on lagged macro fundamentals (prior employment growth, inflation, output gap) and use residuals as "cleaned" shocks. Re-estimate main IRFs and interactions. If results hold, endogeneity concern is substantially mitigated.

2. **Cumulative effects test** (GPT suggestion): Report cumulative effects (0-12, 0-24) with 95% CIs as primary summary statistics, reducing multiple-testing concerns across individual horizons.

3. **Strengthen placebo discussion**: Reframe the three reassurances (reaction function consistency, robustness to controls, cross-specification stability) more prominently. Note that bias direction is toward zero (conservative).

### B. Inference Upgrades (Critical)

1. **Add 95% CIs** to all main figures (Figures 2, 4, 7) and report 95% CI bounds in table notes.
2. **Report cluster counts** (13 industries) in all panel regression tables.
3. **Add Driscoll-Kraay SE check** as appendix robustness for cross-sectional dependence.

### C. Literature & References

Add the following references:
- Plagborg-Moller & Wolf (2021) — LP inference (strengthen existing citation)
- Cameron, Gelbach & Miller (2008) — wild cluster bootstrap
- Ottonello & Winberry (2020) — firm-level heterogeneity in MP transmission
- Guerrieri et al. (2021) — sectoral shocks and demand spillovers

### D. Language & Framing

1. Systematically replace remaining causal language with associational ("associated with," "responses to the identified shock").
2. Frame welfare results as "conditional on the structural model" / "illustrative of mechanisms."
3. Lead abstract/conclusion with cyclicality finding (not goods-services, per Grok).

### E. Presentation

1. Add Table A.X: Augmented shock results (residualized JK).
2. Add cumulative effect estimates to existing tables.
3. Report p-values more prominently in table notes.

## Changes NOT Made (with justification)

- **State-level CES analysis** (Gemini): Requires significant new data infrastructure; noted as future work.
- **Wild cluster bootstrap** (GPT): With 13 clusters, implementation is feasible but may not change conclusions much vs. clustered SEs. Note limitation in text.
- **TANK/hand-to-mouth extension** (Gemini): Major model rewrite; acknowledged as limitation.
- **Romer-Romer narrative shocks** (GPT/Grok): Different shock construction methodology; would require new data pipeline. The augmented shock approach addresses the same concern more directly.
- **Multi-sector model** (Grok): 13-sector model is a separate paper.
