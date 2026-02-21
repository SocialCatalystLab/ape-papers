# Reviewer Response Plan

## Priority 1: Inference Strengthening (GPT, Grok)
- **Add permutation inference for DiDisc interaction (β₃)**: Currently only permute the level effect. Add permutation of β₃ to 04_robustness.R and report in paper.
- **Add DiDisc with two-way clustering**: Municipality + referendum date clustering.
- **Add voter-weighted regressions**: Weight by eligible voters as robustness.

## Priority 2: Missing References (All three)
- Add Grembi, Nannicini & Troiano (2016) — foundational DiDisc reference
- Add GelmanImbens2019 — on polynomial order in RDD
- Add Hansen2015 — agricultural history and gender norms
- Cite Grembi et al. in the DiDisc methodology section

## Priority 3: Framing/Interpretation (GPT)
- Soften "first causal test" language — clarify it tests spillover from cantonal institution to federal voting
- Emphasize that null is about marginal change from abolition, not total historical effect
- Clarify the indirect mechanism more prominently in the introduction

## Priority 4: Additional Robustness (GPT, Gemini)
- **Placebo treatment dates**: Estimate DiDisc at 1993 and 2001 as placebo dates
- **Pre-period restriction**: Test restricting pre-period to 1991-1997 (after AI women's suffrage)
- **Exclude influential units**: Drop Herisau (AR capital) and Appenzell (AI capital) separately

## Priority 5: Prose and Exhibits
- Table units: Add footnote clarifying coefficients are in share points (0-1 scale)
- Incorporate exhibit review suggestions already implemented

## Will NOT address (explain in reply):
- Cantonal referendum data: Not available in swissdd (federal only)
- Individual-level survey data: Not available for these small municipalities
- Wild cluster bootstrap: fwildclusterboot not available on this R version (note in paper)
