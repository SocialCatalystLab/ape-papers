# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-28
**Paper:** ERPOs and Firearm Suicide

## Summary

This paper evaluates Extreme Risk Protection Order (ERPO) laws on suicide rates using a staggered DiD design with Callaway-Sant'Anna estimation. The analysis uses four early-adopting states (CT, IN, CA, WA) with a 1999-2017 panel.

## Key Issues Identified

### 1. Design Limitations (Critical)

- **Few treated clusters**: Only 3-4 treated states, effectively 2 with meaningful post-periods
- **Connecticut pre-period contamination**: Law effective October 1999, no clean pre-year → excluded from main spec
- **Thin post-treatment support**: CA has 2 post-years, WA has 1 post-year

### 2. Inference Concerns (Critical)

- With 3 treated clusters, standard clustered SEs are unreliable
- No randomization inference or wild cluster bootstrap implemented
- Cohort-specific effects reported without valid inference → moved to appendix

### 3. Outcome Mismatch (Moderate)

- Total suicide used instead of firearm-specific suicide
- Attenuates any true effect given ERPO mechanism targets firearms

### 4. Internal Consistency Issues (Addressed)

Multiple consistency issues were identified and fixed during advisor review:
- Table references corrected
- Group definitions clarified
- Sample counts aligned across tables
- Transition year treatment documented

## Format Check

- **Length**: ~14 pages main text + appendices = ~22 total. Below 25-page minimum for top journals.
- **References**: Core DiD methodology cited; some inference references missing
- **Prose**: Major sections in paragraph form
- **Figures**: Publication-ready with clear labels
- **Tables**: Real numbers with SEs where feasible

## Assessment

The paper passes advisor review (no fatal errors) but has fundamental design limitations that make credible causal inference impossible with the current data. The paper honestly acknowledges this, framing results as likely reverse causation.

## Recommendation

The paper can be published as-is with REJECT AND RESUBMIT verdict, representing an honest null result that documents why ERPO evaluation with early adopters is empirically challenging.

## DECISION: MAJOR REVISION
