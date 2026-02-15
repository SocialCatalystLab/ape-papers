# Revision Plan: apep_0238 v6 → v7

## Overview

This revision addresses feedback from v6 referee reviews (GPT=MAJOR, Grok=MINOR, Gemini=MINOR), Gemini advisor FAIL, theory review CRITICALs, and exhibit/prose reviews. The overarching goal is a unified-voice polish round that also makes targeted substantive additions.

## Workstreams Completed

### WS1: Unified Prose Pass
- Rewrote introduction arc: hook → puzzle → contribution
- Tightened contribution section with woven citations
- Sharpened data section lead
- Moved guitar string metaphor higher
- Ensured consistent first-person active voice throughout
- Removed redundant "as shown in Table X" roadmap sentences

### WS2: Rescaled COVID Bartik to SD=1
- Standardized COVID Bartik in `02_clean_data.py` (mean=0, SD=1)
- All COVID LP coefficients now directly interpretable as per-SD effects
- Eliminates "implausibly large" coefficient flags from Gemini advisor

### WS3: Within-Episode Horse Race
- Added horse race LP: HPI + GR Bartik simultaneously
- HPI remains persistent (half-life 60mo); GR Bartik less persistent
- New Table 5 in paper

### WS4: Rotemberg Weight Diagnostics
- Computed Rotemberg weights for COVID Bartik
- Top industries: Leisure/Hospitality dominant
- Leave-one-out industry robustness
- New Table 4 in paper

### WS5: AKM SEs in Main Table
- Added AKM exposure-robust SEs to COVID panel of Table 2

### WS6: Exhibit Streamlining
- Moved scatter and recovery maps to appendix
- Promoted placebo/permutation test to main text
- Normalized JOLTS figure to rates
- Clarified Saiz scatter axis labels

### WS7: References
- Added Goldsmith-Pinkham et al. (2020), Jordà et al. (2017), Hall & Kudlyak (2022), Gertler & Trigari (2009), Romano & Wolf (2005)

### WS8: Inference Narrative Tightening
- Wild bootstrap p-values as preferred inference
- Added formal average persistence metric: β̄_LR = −0.037 (95% CI: [−0.069, −0.005])
- Romano & Wolf (2005) cited for multiple testing

### Theory Fixes (from GPT-5.2-pro theory review)
- **CRITICAL 1 (Fixed):** Wage rule inconsistency — changed from full Nash to simplified wage consistently. SS wage now 0.8550 (was 1.6314).
- **CRITICAL 2 (Fixed):** Welfare terminal value — extended simulation to T=600 months with convergence verification.
- **CRITICAL 3 (Fixed):** OLF timing inconsistency — rewrote all Bellman equations from sequential max{U,V^OLF} to competing-hazard formulation.
- 7 WARNINGs fixed: scarring threshold, V^OLF time-indexing, missing parameters (χ₀, χ₁, d*, a), s_t bounds, welfare concept, notation slips.
- 2 NOTEs fixed: tightness amplification direction, discount rate approximation.

## Key Quantitative Changes

| Metric | v6 | v7 |
|--------|----|----|
| SS wage | 1.6314 | 0.8550 |
| Demand CE welfare loss | 39.61% | 8.86% |
| Supply CE welfare loss | 0.09% | 0.03% |
| D/S welfare ratio | 442:1 | 330:1 |
| Scarring share | 58% | 66% |
