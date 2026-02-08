# Reply to Reviewers

**Paper:** High on Employment? A Spatial Difference-in-Discontinuities Analysis
**Date:** 2026-02-04

---

## Reply to Reviewer 1 (GPT-5-mini)

Thank you for your thorough and constructive review. We have addressed your major concerns as follows:

### Staggered DiD Literature

**Concern:** Missing engagement with Callaway & Sant'Anna, Goodman-Bacon, and Sun & Abraham on TWFE bias.

**Response:** We have added a new paragraph in Section 5.1 explaining why TWFE bias is minimal in our design. The key points are: (1) our control group consists entirely of never-treated states, and (2) treatment timing is limited to two cohorts. We cite Goodman-Bacon (2021), Callaway & Sant'Anna (2021), Sun & Abraham (2021), and de Chaisemartin & d'Haultfoeuille (2020). As Goodman-Bacon shows, TWFE bias is most severe with many treatment cohorts; with only two cohorts and never-treated controls, our estimator is equivalent to a weighted average of cohort-specific ATTs.

### McCrary/Density Test

**Concern:** No manipulation test for the spatial running variable.

**Response:** We have added discussion in Section 5.2 explaining why traditional density testing is not directly applicable to geographic running variables (following Keele & Titiunik 2015). County boundaries are fixed administrative units that cannot be manipulated. We address sorting concerns through (1) pre-treatment balance shown in the event study and (2) temporal placebo tests that would detect anticipatory sorting.

### Bibliography

**Concern:** Essential methodological references missing.

**Response:** The bibliography has been updated to include all requested citations including Lee & Lemieux (2010), McCrary (2008), Cattaneo et al. (2017), and Keele & Titiunik (2015) on geographic RDD.

### Information Sector Result

**Concern:** The -13% effect needs more robustness investigation.

**Response:** We have substantially expanded the caveat around this result in Section 6.4, noting: (1) this industry was not pre-specified, making the result exploratory; (2) the expected false discoveries under the global null is ~0.45, consistent with one significant result by chance; (3) tech sector geographic shifts during 2014-2019 may confound the estimate; (4) leave-one-border-out analysis suggests sensitivity to specific borders.

---

## Reply to Reviewer 2 (Grok-4.1-Fast)

Thank you for your positive assessment and helpful suggestions.

### Literature Review

**Concern:** Literature review sparse; needs 10+ more references.

**Response:** We have added citations to the modern DiD literature (Callaway & Sant'Anna, Goodman-Bacon, Sun & Abraham, de Chaisemartin & d'Haultfoeuille) and spatial RDD literature (Keele & Titiunik 2015, Cattaneo et al. 2017). The bibliography now includes comprehensive methodological coverage.

### McCrary Test

**Concern:** McCrary density test suggested.

**Response:** Added discussion explaining why traditional density testing differs in geographic RDD settings, with citation to Keele & Titiunik (2015).

---

## Reply to Reviewer 3 (Gemini-3-Flash)

Thank you for your detailed methodological feedback.

### TWFE Concerns

**Concern:** Standard fixed-effects approach may be biased with heterogeneous treatment effects.

**Response:** New paragraph in Section 5.1 addresses this. Our design uses never-treated controls exclusively (no "already-treated" contamination) and only two treatment cohorts. The event study shows similar dynamics for both cohorts, suggesting limited treatment effect heterogeneity.

### McCrary Test

**Concern:** Lack of formal density test.

**Response:** Added paragraph in Section 5.2 explaining why traditional McCrary tests are not applicable to continuous geographic running variables, following the geographic RDD literature (Keele & Titiunik 2015). Alternative checks (pre-treatment balance, temporal placebos) address the underlying sorting concern.

### Information Sector

**Concern:** -13% effect is a "red flag" for false positive or omitted spatial trend.

**Response:** Substantially expanded caveats in Section 6.4 acknowledging this is an exploratory result that may reflect tech industry geographic shifts rather than marijuana policy effects. We emphasize the result should not be interpreted as causal evidence.

---

## Summary of Revisions

1. **Added new paragraph** in Section 5.1 discussing staggered DiD literature and why TWFE bias is minimal
2. **Added new paragraph** in Section 5.2 discussing McCrary tests and geographic RDD considerations
3. **Strengthened caveats** around Information sector result in Section 6.4
4. **Updated bibliography** with all requested methodological citations
5. **Recompiled PDF** incorporating all changes
