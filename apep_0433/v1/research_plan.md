# Initial Research Plan: apep_0433

## Research Question

Does mandated gender parity in local government cause improvements in women's economic participation? I exploit France's 1,000-inhabitant threshold for mandatory gender parity in municipal elections to estimate the causal effect of female political representation on local labor market outcomes for women.

## Identification Strategy

**Design:** Sharp Regression Discontinuity Design (RDD)

**Running variable:** Legal population of French communes (from INSEE "populations légales")

**Threshold:** 1,000 inhabitants. Since the 2014 municipal elections, communes above 1,000 must use proportional list voting with strict "zipper" alternation (every other candidate must be of the opposite sex). Communes below 1,000 use majority ("scrutin plurinominal majoritaire") with no gender parity requirement.

**Treatment:** The electoral system change at 1,000 primarily operates through mandatory gender parity, which mechanically increases the share of female candidates and councilors. The first stage is the share of female municipal councilors.

**Key identification assumption:** Communes just above and just below 1,000 inhabitants are comparable in all observable and unobservable characteristics, differing only in the electoral system applied. The population threshold is set by national law using the most recent census, reducing scope for manipulation.

## Expected Effects and Mechanisms

**Main hypothesis:** Communes subject to mandatory gender parity will have higher female economic participation, operating through:

1. **Role model channel:** Visible female political leaders normalize women's economic ambition (Beaman et al. 2012)
2. **Policy channel:** Female politicians may prioritize childcare, family services, and gender-sensitive local policies (Chattopadhyay & Duflo 2004)
3. **Network channel:** Female politicians may create economic opportunities for women through procurement, hiring, and local connections

**Expected direction:** Positive effects on female employment rate, female labor force participation, and potentially female entrepreneurship. Effects may be modest given that French communes have limited fiscal autonomy.

**Alternative hypothesis (null):** In a developed economy with strong national labor law and welfare state, local political gender composition may have no marginal effect on economic outcomes — unlike developing country contexts where local governments have more discretion.

## Primary Specification

```
Y_c = α + τ · 1(Pop_c ≥ 1000) + f(Pop_c - 1000) + X_c'β + ε_c

where:
  Y_c = outcome for commune c (female employment rate, LFPR, etc.)
  1(Pop_c ≥ 1000) = treatment indicator
  f(·) = local polynomial in centered population (linear or quadratic)
  X_c = pre-determined covariates (department FE, urban/rural, etc.)
```

Estimation using `rdrobust` (Cattaneo, Idrobo, Titiunik) with:
- MSE-optimal bandwidth selection (cerrd)
- Triangular kernel
- Robust bias-corrected inference
- Covariates: department fixed effects, pre-treatment employment rates

## Planned Robustness Checks

1. **Manipulation test:** McCrary density test at the 1,000 cutoff
2. **Covariate balance:** Pre-treatment characteristics smooth at the threshold
3. **Bandwidth sensitivity:** Half, double, and optimal bandwidth
4. **Polynomial order:** Linear vs. quadratic local polynomial
5. **Kernel choice:** Triangular vs. uniform vs. Epanechnikov
6. **Placebo cutoffs:** Test at 800, 900, 1100, 1200 (should find no effect)
7. **First stage:** Verify that the parity threshold actually increases female representation
8. **Donut hole:** Exclude communes very close to threshold (within 10, 20 inhabitants)
9. **Historical comparison:** Compare effects at the old 3,500 threshold (2008 elections) as validation

## Data Sources

| Data | Source | Unit | Years | Access |
|------|--------|------|-------|--------|
| Legal population | INSEE Populations légales | Commune | 2014-2020 | Free CSV download |
| Election results | data.gouv.fr (Interior Ministry) | Candidate/commune | 2014, 2020 | Free CSV download |
| Employment by gender | INSEE Census (RP) | Commune | 2013-2020 | Free CSV/API |
| Business creation | INSEE Démographie entreprises | Commune | 2014-2020 | Free CSV download |

## Power Assessment

- ~35,000 communes in metropolitan France
- ~5,000-8,000 within typical MSE-optimal bandwidth
- First stage: ~7 percentage points increase in female council share (Bagues & Campa 2020)
- Effect size: Even modest effects (0.5-1 pp on female employment rate) should be detectable with this sample size
- Key concern: Outcome variation across small communes may be high
