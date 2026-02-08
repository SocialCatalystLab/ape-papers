# Revision Plan

## Reviewer Summary

| Reviewer | Decision | Key Concerns |
|----------|----------|--------------|
| GPT-5-mini | MAJOR REVISION | SCM confidence intervals, monthly data, more robustness |
| Grok-4.1-Fast | MINOR REVISION | Explicit SCM weights, 3 missing citations |
| Gemini-3-Flash | CONDITIONALLY ACCEPT | Synthetic DiD robustness, SSP baseline discussion |

## Changes to Implement

### 1. Add Missing Citations (All Reviewers)

Add the following BibTeX entries:
- Arkhangelsky et al. (2021) - Synthetic DiD
- Callaway & Sant'Anna (2021) - DiD with multiple periods
- Goodman-Bacon (2021) - TWFE decomposition

### 2. Address Synthetic DiD (Gemini Condition)

Add discussion in robustness section explaining:
- Why we use traditional SCM + Augmented SCM rather than Synthetic DiD
- Note that Synthetic DiD is appropriate for future work with extended data
- The core finding is robust across methodological variants

### 3. Discuss SSP Baseline (Gemini Suggestion)

Add text clarifying that the treated sites were converted from existing syringe service programs (SSPs), and discuss how this affects interpretation. Note that the effect is the marginal impact of adding supervised consumption to existing SSP services.

### 4. Add SCM Weights Table (Grok Suggestion)

Add brief discussion of donor weights in the synthetic control section, noting that weights are available in the appendix/replication materials.

### 5. Discuss TWFE Limitations (GPT Suggestion)

Add brief paragraph explaining why TWFE DiD pathologies (Goodman-Bacon) do not apply here (simultaneous adoption) but why SCM remains preferred.

### 6. Note Data Constraints (GPT Requests)

For requests that cannot be addressed due to data constraints (monthly data, tract-level geography), add explicit discussion of these limitations and note as avenues for future research when finer-grained data becomes available.

## Changes NOT Implemented (with justification)

1. **Monthly/quarterly data**: NYC DOHMH releases annual UHF-level overdose data. Sub-annual data at this geographic level is not publicly available.

2. **Census tract analysis**: Overdose deaths are too sparse at tract level for reliable inference (many tracts have 0-1 deaths per year).

3. **Conformal SCM confidence intervals**: Would require substantial methodological extension; current RI p-values and bootstrap CIs provide adequate inference.

## Expected Outcome

After these revisions, the paper should satisfy:
- Gemini's conditional acceptance (Synthetic DiD discussion added)
- Grok's minor revision requests (citations, weights)
- GPT's feasible requests (methodological citations, data limitation discussion)
