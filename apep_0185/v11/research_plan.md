# Initial Research Plan (Revision of APEP-0193)

## Research Question
How do social networks transmit minimum wage shocks across local labor markets? Does the *volume* of information (population-weighted exposure) matter more than the *share* of network providing it (probability-weighted exposure)?

## Identification Strategy
Shift-share instrumental variable:
- **Shares:** Facebook Social Connectedness Index (SCI) — pre-determined network structure
- **Shocks:** Out-of-state minimum wage changes — plausibly exogenous to focal county employment
- **Instrument:** Population-weighted average of minimum wages in out-of-state connected counties

## Expected Effects
- Population-weighted exposure: positive, significant effect on employment
- Probability-weighted exposure: null (mechanism test)
- No migration mediation (information, not relocation)

## Primary Specification
```
log(Emp_ct) = β₁ NetworkMW_ct + α_c + γ_st + ε_ct
```
Instrumented with out-of-state network MW. County FE + state×time FE.

## Revision Improvements (v9)
1. Fix 3 Gemini fatal errors (sample size text, figure-text mismatch, broken sentence)
2. Industry heterogeneity analysis (high-bite vs low-bite sectors)
3. Placebo shock tests (GDP/employment-weighted instruments)
4. Joint state exclusion (CA+NY, CA+NY+WA)
5. COVID period analysis (interaction specification)
6. Sun & Abraham discussion and robustness
7. Missing literature citations
8. Fix Figure 8 placeholder
