# Human Initialization
Timestamp: 2026-02-06T18:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0052
**Parent Title:** Does Broadband Internet Change How Local Politicians Talk?
**Parent Decision:** REJECT AND RESUBMIT (2 of 3 reviewers)
**Revision Rationale:** Ground-up rebuild reframing around Ben Enke's universalism/communalism framework. Parent paper had critical integrity issues: fake IV (rurality proxy labeled as terrain ruggedness), inconsistent sample sizes across tables, missing data provenance, blank figures, and uninformative null result. This revision drops the IV, focuses on Callaway-Sant'Anna DiD with comprehensive diagnostics, and transforms the null result into an informative contribution via MDE calculations, equivalence tests, and comparison to Enke's effect sizes.

## Key Changes Planned

- Reframe theory around Enke (2020 JPE, 2023 REStud) universalism/communalism
- Drop fake IV entirely, use staggered DiD with Callaway-Sant'Anna estimator
- Fix data provenance: reproducible download from Harvard Dataverse
- ONE consistent sample, ONE clustering (state), ONE outcome scaling everywhere
- Informative null: MDE, equivalence tests (TOST), HonestDiD, Enke benchmarks
- 12+ epic figures including choropleth maps, kernel densities, heat maps
- Rich heterogeneity: partisanship, rurality, baseline moral orientation
- Cheap talk discussion using Enke's "values as luxury goods" framework
- Time-varying demographics (not just 2018 cross-section)
- County presidential vote shares for partisanship heterogeneity

## Original Reviewer Concerns Being Addressed

1. **Reviewer 1 (MAJOR):** Fake IV, sample inconsistency → IV dropped entirely; ONE sample throughout
2. **Reviewer 2 (R&R):** Missing data provenance, weak null interpretation → Reproducible API fetches; MDE/equivalence tests
3. **Reviewer 3 (R&R):** Blank figures, shallow heterogeneity → 12+ epic visuals; rich heterogeneity analysis

## Inherited from Parent

- Research question: Does broadband internet affect politicians' moral language?
- Primary data source: LocalView transcripts (Harvard Dataverse)
- Outcome measurement: Moral Foundations Dictionary word counts
- ACS broadband subscription data
