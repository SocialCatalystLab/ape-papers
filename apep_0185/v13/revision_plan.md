# Revision Plan: apep_0052 → Ground-Up Rebuild

## Summary

This is a ground-up rebuild of apep_0052 ("Does Broadband Internet Change How Local Politicians Talk?") reframed around Ben Enke's universalism/communalism framework. The parent paper found a null result but had critical integrity issues (fake IV, data provenance, sample inconsistencies). This revision fixes everything from scratch.

## Research Question

**Does the internet affect the moral foundations of politicians?** Specifically, does broadband expansion shift local government officials' moral language along Enke's universalism-communalism axis?

## Key Changes from Parent

1. **Theory:** Enke (2020 JPE, 2023 REStud) universalism/communalism framework replaces generic Haidt MFT framing
2. **IV dropped:** Parent's IV claimed terrain ruggedness but used rurality index. Removed entirely. DiD with strong diagnostics instead.
3. **Data provenance fixed:** LocalView downloaded reproducibly from Harvard Dataverse
4. **ONE consistent sample:** Single N, single clustering (state), single outcome scaling everywhere
5. **Informative null:** MDE, equivalence tests, HonestDiD, Enke effect size comparisons
6. **Epic visuals:** 12+ figures including choropleth maps, kernel densities, heat maps
7. **Rich heterogeneity:** By partisanship, rurality, baseline moral orientation
8. **Cheap talk discussion:** Theoretical treatment using Enke's "values as luxury goods"
9. **Time-varying demographics:** Not just 2018 cross-section
10. **Election data added:** County presidential vote shares for partisanship heterogeneity

## Identification Strategy

Staggered DiD using Callaway-Sant'Anna (2021):
- Treatment: First year place crosses 70% broadband subscription threshold
- Control group: Never-treated places
- Clustering: State level (throughout)
- Covariates: Time-varying demographics (doubly robust)
- Anticipation: 1 year allowed (addresses ACS 5-year smoothing)

## Execution Order

1. Data pipeline (01_fetch_data.R)
2. Data cleaning (02_clean_data.R)
3. Descriptive analysis (03_descriptive.R)
4. Main DiD analysis (04_main_analysis.R)
5. Robustness battery (05_robustness.R)
6. Heterogeneity analysis (06_heterogeneity.R)
7. Figures (07_figures.R)
8. Tables (08_tables.R)
9. Paper writing (paper.tex)
10. Review and publish

## Workstreams

### WS1: Data Pipeline (01_fetch_data.R)
| Dataset | Source | Fix from Parent |
|---------|--------|----------------|
| LocalView | Harvard Dataverse DOI:10.7910/DVN/NJTBEM | Reproducible download (parent loaded from mystery path) |
| ACS Broadband | Census API B28002, 2013-2022 | Also fetch 1-year for robustness |
| ACS Demographics | Census API, place-level | Time-varying (parent only got 2018) |
| Election Data | MIT Election Data Lab | New — county presidential vote shares |
| USDA RUCC | USDA ERS | New — rural-urban classification |
| TIGRIS shapefiles | tigris R package | New — for choropleth maps |

### WS2: Data Cleaning (02_clean_data.R)
- ONE sample, ONE clustering (state), ONE outcome scaling
- Construct Enke-framed outcomes: universalism_index = individualizing - binding
- Single `analysis_panel.parquet` used by all downstream scripts

### WS3: Analysis (03-06)
- Callaway-Sant'Anna DiD with doubly robust estimation
- HonestDiD sensitivity, MDE, equivalence tests
- Heterogeneity by partisanship, rurality, baseline moral orientation

### WS4: Visualizations (07_figures.R) — 12+ figures
- Universalism map, treatment timing map, broadband trends
- Kernel densities, event studies, heterogeneity panels
- Binscatter, HonestDiD sensitivity, MDE visualization
- Moral composition heat map

### WS5: Tables (08_tables.R) — 7 main tables
- Summary stats, treatment cohorts, main DiD, individual foundations
- Robustness battery, heterogeneity, MDE/equivalence

### WS6: Paper (paper.tex) — 30+ pages
- Full Enke framing, cheap talk discussion, honest limitations
- Suggest FCC grants as future IV

## Verification Criteria

1. All R scripts run end-to-end without error
2. `analysis_panel.parquet` is single source of truth
3. N identical in every table and figure
4. All figures render with visible data
5. PDF compiles to 25+ pages main text
6. Advisor review: 3/4 PASS
7. 3 external reviews completed
