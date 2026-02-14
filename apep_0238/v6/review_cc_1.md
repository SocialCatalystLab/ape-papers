# Internal Review — Claude Code (Round 1)

**Reviewer:** Claude Code (self-review)
**Paper:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Version:** v6 (revision of v5)
**Date:** 2026-02-14

---

## Summary

This paper compares labor market scarring from the Great Recession (demand-driven) vs. COVID-19 (supply-driven) using cross-state local projections. It finds persistent employment effects from housing exposure (60-month half-life) but full recovery from COVID Bartik exposure within 18 months. A calibrated DMP model with skill depreciation rationalizes the asymmetry.

## Strengths

1. **Clean identification framework.** The paper uses well-established instruments (housing prices for GR, Bartik for COVID) applied to the same 50 states at the same monthly frequency. The Saiz IV adds causal credibility.

2. **Multiple inference approaches.** HC1, permutation, wild cluster bootstrap, and AKM exposure-robust SEs — comprehensive for N=50.

3. **Strong mechanism test.** The UR persistence ratio (1.86 for GR vs. 0.09 for COVID) directly tests the duration channel.

4. **Migration decomposition.** Emp/pop ratio results confirm scarring is not an artifact of population reshuffling.

5. **Honest theory.** The paper transparently acknowledges the simulation uses a reduced-form proxy for the scarring dynamics rather than solving the full distributional model.

## Weaknesses and Suggestions

1. **Sample of two events.** This is inherent and acknowledged in the conclusion. The paper would benefit from a brief discussion of historical demand vs. supply recessions (1973 oil shock, 2001 dot-com) even if data limitations preclude formal analysis.

2. **Table 2 complexity.** Three inference methods per cell makes the table hard to scan. Consider moving wild bootstrap and permutation to a separate inference comparison table.

3. **Model sensitivity.** The welfare ratio (442:1) is an order-of-magnitude illustration, not a precise estimate. The paper acknowledges this but could state it even more prominently.

4. **LFPR results are noisy.** The cross-state LP for LFPR yields imprecise estimates. This is honestly acknowledged but limits the paper's ability to test the participation channel empirically.

## Verification

- All code scripts run without error
- Tables match text descriptions
- Figures are properly labeled and referenced
- References compile with no unresolved citations
- 32 pages main text (well above 25-page minimum)
- Pre-trend validation supports identification

DECISION: MINOR REVISION
