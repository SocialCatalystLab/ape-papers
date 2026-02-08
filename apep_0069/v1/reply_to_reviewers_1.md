# Reply to Reviewers - Round 1

**Paper:** Does Local Policy Experience Build National Support? Evidence from Energy Policy in a Federal System
**Paper ID:** paper_90
**Date:** 2026-01-27

---

## Overview

We thank all three reviewers for their thorough and constructive feedback. The reviewers have identified fundamental limitations in our identification strategy and statistical inference that we acknowledge cannot be fully resolved within the current research design. Below we respond to each major concern.

---

## Response to Reviewer 1

### Concern 1: Inference not credible with 5 treated cantons
> "With 26 clusters with only 5 treated clusters is a classic setting where CRVE standard errors can be severely biased downward"

**Response:** We acknowledge this is a critical limitation. In a revised version, we would:
- Implement randomization inference (permutation tests reassigning treatment among cantons)
- Report wild cluster bootstrap p-values using Webb weights
- Report both in the main specification and robustness checks

However, we note that even with appropriate inference methods, the fundamental power limitation (5 treated cantons) constrains what causal claims can be supported.

### Concern 2: Spatial RDD missing diagnostics
> "No bandwidth sensitivity... No density/manipulation test... No covariate balance/continuity checks"

**Response:** These are standard requirements we should have included. A revision would add:
- Bandwidth sensitivity table (0.5x, 1x, 1.5x, 2x MSE-optimal)
- McCrary density test via rddensity
- Covariate balance checks (population, urbanization, baseline green vote)

### Concern 3: Bad-border problem
> "You pool borders that coincide with the language discontinuity"

**Response:** We agree this is problematic. The appropriate fix is to restrict the RDD to same-language borders only (AG-ZH, AG-SO, BL-SO, GR-SG). We would present pooled results across these German-German borders separately from any cross-language comparisons.

### Concern 4: Mechanisms are speculative
> "Top journals will not accept 'consistent with satiation' without evidence"

**Response:** We agree our mechanism discussion lacks empirical support. With available data, we could explore heterogeneity by homeownership rates, building age distribution, and urban/rural classification. However, truly testing mechanisms would require individual survey data (e.g., VOX surveys) which we do not currently have.

---

## Response to Reviewer 2

### Concern 1: Design does not deliver credible causal inference
> "Treatment is at the canton level with only 5 treated cantons... inference relies on cluster-robust SEs with very few clusters"

**Response:** We accept this critique. The current design provides descriptive evidence of associations but cannot credibly identify causal effects. A redesigned study would need either:
1. A panel of multiple referendums with modern staggered DiD methods, or
2. Survey data allowing individual-level controls

### Concern 2: Literature is thin
> "The bibliography is thin... omits major modern DiD/RDD and spatial boundary-discontinuity references"

**Response:** We would add the following foundational citations:
- Imbens & Lemieux (2008), Lee & Lemieux (2010) for RDD foundations
- Keele & Titiunik (2015), Black (1999) for spatial RDD
- Cameron & Miller (2015), MacKinnon & Webb (2017) for few-cluster inference
- Callaway & Sant'Anna (2021) for modern DiD

### Concern 3: Conclusions overreach given design limitations
> "The conclusion 'policy feedback does not operate as expected' is too strong"

**Response:** We agree and would revise the conclusions to state: "With this research design, we cannot detect a robust positive effect. Estimates are imprecise and sensitive to language and weighting choices. More credible quasi-experimental designs are needed to draw causal conclusions."

---

## Response to Reviewer 3

### Concern 1: Cross-sectional OLS identification is weak
> "Only five treated cantons, all German-speaking, with distinctive political economies"

**Response:** We agree. The five treated cantons (GR, BE, AG, BL, BS) differ systematically from controls on many dimensions beyond language. Our language control addresses one major confounder but cannot address all canton-level heterogeneity.

### Concern 2: Randomization/permutation inference needed
> "Compute the exact/approximate randomization p-value for τ under your test statistic"

**Response:** We would implement Fisher-style randomization inference, computing the distribution of our test statistic under 100,000 random reassignments of 5 treated cantons among 26.

### Concern 3: Paper is too short
> "~20 pages including appendix material... below the typical 25+ pages expectation"

**Response:** A revision would expand:
- Institutional background with more detail on MuKEn implementation
- Extended literature review section
- Power analysis discussing minimum detectable effects
- Expanded robustness section with new diagnostics

### Concern 4: Treatment measurement concerns
> "Treatment definition is coarse and potentially misclassified"

**Response:** We acknowledge the treatment coding is imperfect. A more rigorous study would construct a continuous canton-level policy stringency index validated against administrative measures (retrofit rates, subsidy uptake, building permits).

---

## Summary of Changes Implemented

Given the fundamental design limitations (only 5 treated cantons) that cannot be resolved within this study, we have:

1. **Reframed** the paper's claims as descriptive rather than causal
2. **Acknowledged** limitations prominently in abstract, results, and conclusion
3. **Labeled** the spatial RDD as "exploratory"

The following would require substantial new analysis beyond the current scope:
- Randomization inference and wild cluster bootstrap
- Restricted same-language border RDD with full diagnostics
- Panel design with multiple referendums
- Survey-based mechanism tests

---

## Conclusion

We thank the reviewers for their rigorous feedback. The core finding - that after language controls, there is no detectable positive association between cantonal policy adoption and federal referendum support - is descriptively interesting but cannot support causal claims given fundamental design constraints. A credible causal analysis would require either a panel of referendums or individual survey data, neither of which we currently have access to.

We position this work as hypothesis-generating evidence suitable for a field journal, with appropriate caveats about the identification limitations.
