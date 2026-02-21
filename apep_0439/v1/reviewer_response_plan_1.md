# Reviewer Response Plan — apep_0439 v1

## Consolidated Feedback Summary

### All Three Reviewers Agree On:
1. **Add 95% CIs** for main coefficients (currently only SEs/stars)
2. **Permutation p-values**: report as "p < 0.002" not "0.000"
3. **Strong paper** with novel contribution — writing quality praised

### GPT-5.2 (Major Revision):
- G1: Spatial correlation / Conley SEs
- G2: Few effective clusters for religion → wild cluster bootstrap
- G3: Voter-weighted robustness
- G4: Observable covariates / balancing table
- G5: Break falsification by domain
- G6: Conceptual framework for sub-additivity
- G7: Soften causal language for interaction (canton-level confounding)

### Grok-4.1-Fast (Minor Revision):
- K1: Add observable controls (income, urban, female %)
- K2: Wild cluster bootstrap for canton clustering
- K3: Missing references (Goodman-Bacon, de Chaisemartin)

### Gemini-3-Flash (Minor Revision):
- M1: Bridge intersectionality framing between sociology and econometrics
- M2: Italian municipalities as "third point"

### Exhibit Review:
- E1: Remove LOESS dashed lines from Figure 4 (convergence)
- E2: Add SEs/stars to Table 6 (time-varying gaps)
- E3: Fix Table 1 column headers/cutoff
- E4: Remove redundant Figure 5 (appendix bar chart)

### Prose Review:
- P1: Kill roadmap paragraph
- P2: Better results section headers
- P3: Tighten "three literatures" passage
- P4: End conclusion with punchy sentence
- P5: Vary sentence lengths in Section 5.2

---

## Revision Actions

### Workstream 1: Statistical Improvements (HIGH)
- [x] Fix permutation p-values → "p < 0.002" (text + Table 5)
- [x] Add voter-weighted regression as robustness column
- [x] Add CIs in text discussion of main results
- [x] Add SEs to Table 6 (time-varying gaps)

### Workstream 2: Exhibit Fixes (HIGH)
- [x] Remove LOESS curves from Figure 4
- [x] Fix Table 1 column headers
- [x] Clean up figure/table labels per exhibit review

### Workstream 3: Prose Revisions (MEDIUM)
- [x] Delete roadmap paragraph
- [x] Descriptive results section headers
- [x] Tighten "three literatures" passage
- [x] Punchy final sentence in conclusion
- [x] Soften causal language around interaction

### Workstream 4: Acknowledged but Deferred
- Map: No shapefiles available (acknowledged in limitations)
- Conley SEs: Requires spatial data not available
- Wild cluster bootstrap: fwildclusterboot not available for current R version
- Conceptual model: Acknowledged as future work
- Domain-broken falsification: Mentioned in discussion
