# Internal Review - Round 1

## PART 1: CRITICAL REVIEW

### Format Check
- **Length:** 26+ pages main text, adequate for journal submission.
- **References:** 14 citations covering foundational MW literature (Dube 2019, Autor et al. 2016, Card and Krueger 1999), modern DiD (Goodman-Bacon 2021, Callaway and Sant'Anna 2021, de Chaisemartin and D'Haultfœuille 2020), and education/earnings literature (Chetty et al. 2020, Zimmerman 2014).
- **Prose:** All sections written in paragraph form. No bullet-point sections.
- **Figures:** 7 figures, all with visible data and proper axes.
- **Tables:** 6 tables with real regression output and summary statistics.

### Statistical Methodology
- Standard errors clustered at state level throughout — appropriate given state-level treatment.
- Significance stars and parenthesized SEs in all tables.
- Sample sizes reported for all specifications.
- **Concern:** Uses simple TWFE rather than Callaway-Sant'Anna or other heterogeneity-robust estimator. Paper acknowledges this and cites the relevant literature but does not implement the modern estimators. This is a weakness but not fatal given the continuous treatment variable and the honest acknowledgment of limitations.

### Identification Strategy
- **Strength:** Clear within-institution identification, distributional gradient consistent with theory.
- **Weakness:** Region-by-cohort FE eliminate the effect (Table 4 Col 2). Graduate placebo is significant (Table 4 Col 5). These are honestly reported but significantly weaken the causal interpretation.
- Lead MW test passes (not significant), providing some reassurance against pre-trends.
- Jackknife stability demonstrated.

### Literature
- Adequate coverage. Missing: Cengiz et al. (2019) bunching estimator perspective, Derenoncourt and Montialoux (2021) on racial wage gaps — both already cited.
- Could benefit from citing Harasztosi and Lindner (2019) on MW effects on firm-level outcomes, and Dustmann et al. (2022) on MW reallocation effects.

### Writing Quality
- Strong opening hook (barista example). Introduction follows Shleifer arc well.
- Results section tells a story rather than narrating tables.
- Honest engagement with limitations is a strength.
- Discussion of placebo failure is exemplary in its candor.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Implement Callaway-Sant'Anna estimator** as robustness check, even if results are similar to TWFE.
2. **Event study plot** showing dynamic treatment effects would strengthen the pre-trends argument.
3. **Heterogeneity by state MW level:** Do effects concentrate in states with large MW increases?
4. **Decomposition of the graduate placebo failure:** Is it driven by specific states or fields?
5. **Quantile regression at the institution level** could complement the percentile-based approach.

## OVERALL ASSESSMENT

**Strengths:** Novel data source, honest reporting of uncomfortable results, clear distributional gradient.

**Weaknesses:** Identification fragility (region×cohort sensitivity, placebo failure), simple TWFE without modern estimators, limited statistical power.

**The paper makes a genuine contribution by documenting a new empirical regularity using novel data, even though the causal interpretation is uncertain.**

DECISION: MAJOR REVISION
