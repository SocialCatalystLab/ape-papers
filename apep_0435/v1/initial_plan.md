# Initial Research Plan — apep_0435

## Research Question

Do communities that were more gender-progressive in 1981 remain more progressive 40 years later, or have Swiss municipal gender attitudes converged? We study the persistence and convergence of revealed gender policy preferences using Gemeinde-level voting on six gender-relevant federal referenda spanning 1981–2021.

## Identification Strategy

**Primary method: Doubly Robust / AIPW (Augmented Inverse Probability Weighting)**

The core estimand is the association between baseline gender progressivism (1981 Gleichstellungsartikel YES share) and contemporary gender policy preferences (2020 paternity leave, 2021 same-sex marriage YES shares), conditional on a rich set of municipal characteristics. AIPW combines an outcome model (OLS with controls) and a treatment model (generalized propensity score for continuous treatment) to achieve double robustness.

We frame the paper as measuring **persistence and convergence** rather than strict causality. The 1981 vote share is a revealed-preference measure of community gender norms — a "sufficient statistic" for local gender progressivism. The question is: how sticky is this measure over 40 years?

**Secondary analysis: β-convergence test**

Following Barro & Sala-i-Martin (1992), we regress the change in gender progressivism (Δ YES share, 1981→2020) on the initial level (1981 YES share). Negative β = convergence (laggards catch up); positive β = divergence (leaders pull further ahead).

## Expected Effects and Mechanisms

**Primary hypothesis:** Substantial persistence — communities that voted YES on equal rights in 1981 are more likely to support paternity leave (2020) and same-sex marriage (2021), even conditional on observables. We expect a strong positive correlation (R² > 0.3) between 1981 and 2020 gender votes at the municipal level.

**Secondary hypothesis:** Partial β-convergence — the overall Swiss trend toward gender progressivism implies that conservative municipalities have "caught up" somewhat, but not completely. We expect β ∈ (−1, 0), with |β| < 1 indicating incomplete convergence.

**Mechanisms:**
1. Intergenerational transmission of political attitudes (parents → children)
2. Self-sorting: progressive people move to progressive municipalities
3. Institutional path dependence: early progressive cantons built gender-supportive institutions
4. National policy homogenization eroding local differences

## Primary Specification

```
Y_i(2020) = α + τ · Y_i(1981) + X_i'β + γ_c + ε_i
```

Where:
- Y_i(2020) = paternity leave YES share in Gemeinde i
- Y_i(1981) = Gleichstellungsartikel YES share in Gemeinde i
- X_i = controls (language, religion, population, urbanization, altitude)
- γ_c = cantonal fixed effects
- ε_i = error clustered at canton level (26 clusters)

AIPW augments this with a generalized propensity score model to achieve double robustness.

## Planned Robustness Checks

1. **Within-language-region analysis**: Restrict to German-speaking municipalities only (largest group, ~1,400 Gemeinden) to remove the French-progressive confound
2. **Within-canton analysis**: Include canton FE to isolate within-canton persistence
3. **Gemeente merger robustness**: Show results are stable using different harmonization choices (SMMT concordance vs. dropping merged municipalities)
4. **Multiple gender referenda**: Repeat analysis for 2004 maternity insurance, 1999 maternity insurance (rejected), and 1984 maternity insurance (rejected)
5. **Falsification with non-gender referenda**: Test whether 1981 gender progressivism predicts voting on non-gender issues (military, agriculture, immigration) — it should NOT, or at least much less
6. **Sensitivity to unobservables**: Oster (2019) δ statistic for omitted variable bias
7. **Panel convergence**: σ-convergence (declining cross-Gemeinde variance) in addition to β-convergence
8. **Wild cluster bootstrap**: For inference with 26 cantonal clusters
9. **Spatial clustering**: Conley standard errors for geographic correlation

## Data Sources

| Data | Source | Granularity | Access |
|------|--------|-------------|--------|
| Referendum results 1981–2021 | swissdd R package / opendata.swiss | Gemeinde | Public, no key |
| Population, religion, language | BFS PXWeb API | Gemeinde | Public, no key |
| Municipal boundaries/mergers | SMMT R package | Gemeinde | Public |
| Urban/rural classification | BFS | Gemeinde | Public |

## Timeline of Gender Referenda

| Date | Topic | National Result | swissdd ID |
|------|-------|----------------|------------|
| 1981-06-14 | Gleichstellungsartikel (equal rights) | 60.3% YES | ~300 |
| 1984-12-02 | Maternity insurance initiative | 15.8% YES | TBD |
| 1999-06-13 | Maternity insurance (revised) | 38.9% YES | TBD |
| 2004-09-26 | Maternity insurance (final) | 55.5% YES | TBD |
| 2020-09-27 | Paternity leave (Vaterschaftsurlaub) | 60.3% YES | 634 |
| 2021-09-26 | Same-sex marriage (Ehe für alle) | 64.1% YES | TBD |

## Falsification Referenda (Non-Gender)

| Date | Topic | Why Falsification |
|------|-------|-------------------|
| 2014-02-09 | Masseneinwanderung (mass immigration) | Immigration, not gender |
| 2020-11-29 | Konzernverantwortung (corporate responsibility) | Corporate, not gender |
| 2020-09-27 | Kampfflugzeuge (fighter jets) | Military, same vote date as paternity |
| Various | Agricultural policy votes | Rural policy, not gender |
