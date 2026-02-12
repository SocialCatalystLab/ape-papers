# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini)

**Concern 1: Incorporation vs. location mismatch needs more attention.**
We agree this is the primary limitation. We have strengthened the discussion in Section 8.4 (Limitations), explicitly noting the need for incorporation-weighted exposure measures from Compustat as a natural extension.

**Concern 2: Multiple testing across 3 outcomes.**
Added Section 6.5 (Multiple Testing) noting that the primary finding (net entry, p=0.021) survives Bonferroni correction (0.063 < 0.10), and that the three outcomes test distinct theoretical predictions.

**Concern 3: Wild cluster bootstrap for inference.**
Added reference to Cameron et al. (2008) and noted that randomization inference provides complementary finite-sample evidence. The RI p-value of 0.102 is consistent with the clustered SE inference.

**Concern 4: Industry heterogeneity analysis.**
Acknowledged as a limitation. State-level all-industry aggregates are the appropriate unit for the macro consequences question posed in this paper. Sector-specific analysis is a natural extension.

## Reviewer 2 (Grok-4.1-Fast)

**Concern 1: Early cohorts lack pre-treatment data.**
This is already handled correctly by the Callaway-Sant'Anna estimator, which drops the 17 already-treated units. We have made this explicit in Section 4.2 and the Data Appendix, and Table 3 now reports "Effective treated states: 24 (of 32 adopters)."

**Concern 2: Pre-trends in net entry at longer horizons.**
Acknowledged in updated Appendix B.2 that longer-horizon pre-treatment coefficients for entry rates show some positive values, while coefficients near the treatment date are close to zero.

**Concern 3: Need for cumulative long-run effect estimates.**
The event study figures already show the cumulative path of effects. Formal cumulative estimates could be added in a revision but do not change the qualitative conclusions.

## Reviewer 3 (Gemini-3-Flash)

**Concern 1: Incorporation-location problem is the main threat.**
See response to Reviewer 1, Concern 1. Strengthened throughout.

**Concern 2: Missing TWFE result in tables.**
FIXED: Table 3 now includes Panel B with the TWFE benchmark coefficient, directly showing the sign reversal.

**Concern 3: N missing from Table 3.**
FIXED: Observation counts now reported for all three regressions.

## Exhibit Review Actions
- Removed roadmap paragraph per prose review suggestion
- Polished conclusion's final sentence
- Acknowledged Table 2 can be moved to appendix in future revision

## Prose Review Actions
- Cut roadmap paragraph (p. 4)
- Polished conclusion ending
- Maintained opening hook and narrative arc (rated "Shleifer-ready")
