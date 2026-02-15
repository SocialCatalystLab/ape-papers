# Internal Review — Claude Code (Round 1)

**Reviewer:** Claude Code (self-review)
**Paper:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Version:** v7 (revision of v6)
**Date:** 2026-02-15

---

## Summary

This paper compares labor market scarring from the Great Recession (demand-driven) vs. COVID-19 (supply-driven) using cross-state local projections. It finds persistent employment effects from housing exposure (60-month half-life) but full recovery from COVID Bartik exposure within 18 months. A calibrated DMP model with skill depreciation and endogenous participation rationalizes the asymmetry. This revision fixes three CRITICAL theory issues, rescales the COVID Bartik to SD=1, adds within-episode horse race and Rotemberg weight diagnostics, and performs a comprehensive prose unification pass.

## Strengths

1. **Clean identification framework.** Pre-determined housing boom variation for GR and Bartik shift-share for COVID, applied to the same 50 states at monthly frequency. Saiz IV, Rotemberg weights, and AKM SEs strengthen causal credibility.

2. **Comprehensive inference.** HC1, permutation, wild cluster bootstrap, and AKM exposure-robust SEs. New formal average persistence metric (beta-bar_LR = -0.037, 95% CI: [-0.069, -0.005]) provides a single pre-specified test of long-run scarring.

3. **Within-episode horse race (new in v7).** HPI and GR Bartik jointly in the same LP specification: HPI effects remain persistent while industry composition effects attenuate. Separates demand channel from compositional confounds within the same recession.

4. **Internally consistent theory (fixed in v7).** All Bellman equations now use competing-hazard formulation for OLF exit. Wage rule, free-entry condition, and welfare computation are mutually consistent. Welfare convergence verified at T=600 months.

5. **Honest magnitudes.** SS wage (0.8550) and welfare losses (8.86% demand, 0.03% supply) are internally consistent with the simplified wage rule. Sensitivity table shows robustness across 7 parameterizations.

## Weaknesses and Suggestions

1. **Sample of two events.** Inherent limitation, honestly acknowledged. The within-episode horse race partially mitigates this by testing the demand mechanism within the GR alone.

2. **Long-horizon precision.** Individual coefficients at h=60-84 months are imprecise under wild bootstrap. The average persistence metric addresses this by pooling information across horizons, but individual-horizon persistence claims should be interpreted cautiously.

3. **Model is illustrative, not estimated.** Parameters are externally calibrated, not matched to LP moments. The paper acknowledges this framing. The 330:1 welfare ratio is a qualitative illustration of the mechanism, not a precise policy estimate.

4. **Risk-neutral welfare.** CRRA utility would compress absolute welfare magnitudes while preserving the demand/supply asymmetry. Noted as a caveat but not implemented.

## Verification

- All 7 Python scripts run without error
- Tables match text descriptions (verified after wage rule fix)
- Figures properly labeled and referenced
- References compile with no unresolved citations (65 pages, 0 undefined refs)
- 36 pages main text (well above 25-page minimum)
- Theory review CRITICALs resolved (wage rule, welfare convergence, OLF timing)
- COVID Bartik rescaled to SD=1 (eliminates "implausibly large" coefficient flags)
- Pre-trend validation supports identification

DECISION: MINOR REVISION
