# Revision Plan

**Paper:** High on Employment? A Spatial Difference-in-Discontinuities Analysis
**Reviews:** GPT (MAJOR), Grok (MINOR), Gemini (MAJOR)
**Date:** 2026-02-04

---

## Summary of Key Issues Across All Reviewers

### Critical Issues (Raised by Multiple Reviewers)

1. **McCrary Density Test Missing** (GPT, Grok, Gemini)
   - All reviewers note absence of manipulation/density test for the spatial running variable
   - Action: Add discussion explaining why McCrary is not directly applicable (continuous geographic variable, not sharp individual assignment) and provide alternative checks

2. **Staggered DiD Literature** (GPT, Gemini)
   - Missing citations to Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Sun & Abraham (2021)
   - Action: Add these citations and explain why TWFE bias is minimal (only 2 treatment cohorts, never-treated controls, no "already-treated" contamination)

3. **Literature Gaps** (All reviewers)
   - Missing key methodological references
   - Action: Add references to Lee & Lemieux (2010), McCrary (2008), Cattaneo et al. (2017)

4. **Information Sector Result** (GPT, Gemini)
   - The -13% effect is suspicious and needs more robustness
   - Action: Add discussion acknowledging this is exploratory, suggest future work with leave-one-border-out analysis

5. **Small Cluster Inference** (GPT, Grok)
   - 8 clusters is borderline for cluster-robust inference
   - Action: Emphasize wild bootstrap results more prominently in main tables

---

## Revision Actions

### A. Bibliography Updates

Add the following references to references.bib:

```bibtex
@article{callaway2021did,
  author = {Callaway, Brantly and Sant'Anna, Pedro H.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}

@article{goodmanbacon2021did,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}

@article{sunabraham2021,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating Dynamic Treatment Effects in Event Studies},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {175--199}
}

@article{lee2010rd,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  pages = {281--355}
}

@article{mccrary2008manipulation,
  author = {McCrary, Justin},
  title = {Manipulation of the Running Variable},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {698--714}
}

@article{cattaneo2017comparing,
  author = {Cattaneo, Matias D. and Titiunik, Rocío and Vazquez-Bare, Gonzalo},
  title = {Comparing Inference Approaches for RD Designs},
  journal = {Journal of Business and Economic Statistics},
  year = {2017},
  volume = {37},
  pages = {732--749}
}
```

### B. Paper.tex Edits

1. **Section 5.1 (Empirical Strategy)**: Add paragraph discussing why TWFE bias is minimal in this design (2 cohorts, never-treated controls) and cite Callaway & Sant'Anna, Goodman-Bacon.

2. **Section 5.2 (Identifying Assumption)**: Add paragraph on McCrary test—explain that traditional density testing is not applicable to continuous geographic running variables but note that pre-treatment covariate balance provides analogous evidence.

3. **Section 6.4 (Industry Heterogeneity)**: Strengthen cautionary language around the Information sector result, explicitly noting it is exploratory and may be a false positive.

4. **Introduction**: Add citations to the modern DiD literature in the contribution paragraph.

5. **Literature Review**: Expand the contribution section to engage more with spatial RDD/DiDisc precedents.

### C. Items NOT Addressed (Would Require New Data/Analysis)

- Leave-one-border-out analysis for Information sector (deferred to future work)
- Cannabis license location data mapping (noted as limitation)
- LEHD Origin-Destination commuting flows (noted as future work)
- Full McCrary test implementation (justified as not applicable)

---

## Implementation Priority

1. **HIGH**: Add missing references to references.bib
2. **HIGH**: Add staggered DiD discussion to Section 5.1
3. **HIGH**: Add McCrary test discussion to Section 5.2
4. **MEDIUM**: Strengthen Information sector caveats in Section 6.4
5. **MEDIUM**: Add Lee & Lemieux and Cattaneo citations
6. **LOW**: Minor prose improvements per reviewer suggestions

---

## Expected Outcome

After revisions:
- Paper will engage with modern DiD literature as required by all top journals
- McCrary test absence will be justified and alternative checks noted
- Information sector result will be appropriately caveated as exploratory
- Bibliography will be complete with all essential methodological references
