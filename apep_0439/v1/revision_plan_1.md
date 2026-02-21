# Revision Plan 1 — apep_0439 v1

## Overview

This revision plan addresses feedback from the tri-model external referee review (Stage B) and the exhibit/prose reviews (Stages A.5/A.6). The paper received 1 Major Revision (GPT-5.2) and 2 Minor Revisions (Grok-4.1-Fast, Gemini-3-Flash).

## Workstream 1: Statistical Improvements (HIGH PRIORITY)

1. **Fix permutation p-values**: Report as "p < 0.002" (not "0.000") throughout text and Table 5
2. **Add 95% CIs**: Include confidence intervals in text discussion of main interaction results
3. **Voter-weighted regression**: Add as Column (7) in robustness Table 4
4. **Add SEs to Table 6**: Include standard errors for language gap and interaction in time-varying gaps table

## Workstream 2: Exhibit Fixes (HIGH PRIORITY)

1. **Remove LOESS curves** from Figure 4 (convergence plot) — exhibit review flagged as visual clutter
2. **Verify Table 1 column headers** are clean

## Workstream 3: Prose Revisions (MEDIUM PRIORITY)

1. **Delete roadmap paragraph** from introduction (prose review: "Kill it")
2. **Descriptive results section headers** replacing generic ones
3. **Tighten "three literatures" passage** (~30% reduction)
4. **Punchy final sentence** in conclusion
5. **Soften causal language** around interaction term (GPT reviewer concern G7)

## Workstream 4: Acknowledged but Deferred

- Conley SEs: Requires spatial coordinates not available in swissdd
- Wild cluster bootstrap: fwildclusterboot not available for current R version
- Observable controls: Municipality-level covariates not available in swissdd
- Conceptual framework for sub-additivity: Acknowledged as future work
- Italian municipalities: Acknowledged as extension in conclusion
