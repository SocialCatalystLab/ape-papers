# Revision Plan 1 — apep_0214

## Summary

This revision addresses feedback from the tri-model referee panel (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash) plus exhibit and prose reviews.

## Changes Made

### 1. Not-Yet-Treated Control Group (Grok, Gemini)
- Estimated CS model with `control_group = "notyettreated"` as alternative to never-treated baseline
- Result: ATT = -0.0767 (SE = 0.0234), virtually identical to primary estimate
- Added to Table 3 and discussed in main text robustness section and appendix

### 2. Exclude California Robustness (Gemini)
- Attempted to estimate CS model excluding California
- Result: Model fails to converge ("No valid groups") because remaining 12 treated states have insufficient post-treatment data
- Discussed as a limitation in new appendix subsection "Sensitivity to California"

### 3. Expanded Randomization Inference Discussion (GPT, Grok)
- Clarified permutation scheme: state-level treatment reassignment preserving cohort sizes
- Explained why only 156 of 500 permutations are valid (many produce no post-treatment variation)
- Noted the marginal significance (p = 0.077) and its interpretation

### 4. Additional References (Grok)
- Added Rambachan & Roth (2023) — more credible parallel trends
- Added Abadie et al. (2010) — synthetic control
- Added Vogel (1995) — regulatory fragmentation / "California Effect"

### 5. Exhibit Improvements (Exhibit Review)
- Dropped wages from Figure 4 event study panel (CI range -5 to +2.5 was uninformative)
- Moved heterogeneity figure to appendix (imprecise due to small subgroups)
- Figure 4 now shows 3 panels: Software Publishers, Establishments, BFS

### 6. Prose Improvements (Prose Review)
- Improved conclusion's final sentence
- Minor tightening throughout

### 7. Appendix Additions
- Updated "Sensitivity to Control Group" section with not-yet-treated results
- Added new "Sensitivity to California" subsection
- Updated "Alternative Industry Classifications" to reflect 5112 as primary spec

## Not Addressed (with rationale)

- **Wild cluster bootstrap** (GPT): With N=13 treated clusters, wild cluster bootstrap is not well-suited; state-clustered SEs with block bootstrap are more appropriate for CS estimator
- **More RI permutations** (GPT): Already at 500 draws; fundamental limitation is that many permutations produce invalid configurations, not the number of draws
- **Border county spillovers** (Gemini): Would require county-level QCEW data not available in current extract; noted as future work
- **Revenue threshold heterogeneity** (Gemini): State-level data cannot identify firm-size heterogeneity; acknowledged as limitation
- **Synthetic control for CA BFS** (GPT): Single treated unit makes CS estimator inappropriate; BFS results already clearly labeled as suggestive
- **Formal pre-trend F-test** (Grok): CS package Wpval is 0 (ambiguous); manual Wald test rejects due to correlation structure of pre-period estimates; visual evidence from event studies provides more informative assessment per Roth (2022)
