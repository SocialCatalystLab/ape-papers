# Initial Research Plan (Revision of apep_0202)

## Research Question
Do social network connections to high-wage labor markets improve local employment outcomes?

## Identification Strategy
Shift-share IV: population-weighted out-of-state SCI network minimum wage exposure instruments for total network exposure. State-by-time fixed effects absorb own-state MW and state-level shocks.

## Key Changes from Parent (apep_0202)
1. Fix population weight construction to use pre-treatment (2012-2013) employment only
2. Reframe from "information volume" to core economics/labor market questions
3. Drop event study analysis entirely
4. Restructure to 35-40 page main text + proper appendix
5. Add new citations (Kline & Moretti 2014, Jardim et al. 2024, Schmutte 2015)

## Expected Effects
- Population-weighted network exposure positively predicts employment and earnings
- Probability-weighted exposure (share only) shows weaker/null effects
- Distance-restricted instruments strengthen results

## Primary Specification
log(emp)_{ct} = beta * NetworkMW_{ct} + gamma * OwnMW_{st} + alpha_c + delta_st + X'_{ct}*theta + epsilon_{ct}

Instrumented with out-of-state population-weighted network MW.

## Robustness Checks
- Distance-restricted instruments (200km, 500km, 1000km thresholds)
- Placebo shocks (GDP, employment shocks through same network)
- Leave-one-out state exclusion
- Anderson-Rubin confidence sets
- Permutation inference (2,000 draws)
- County-specific linear trends
- Sun and Abraham heterogeneity-robust estimator
