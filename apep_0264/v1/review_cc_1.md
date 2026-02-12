# Internal Review — Round 1

**Date:** 2026-02-12
**Based on:** Quad-model advisor review (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash, Codex-Mini)

## Summary

The paper examines the macroeconomic consequences of business combination (BC) statutes using staggered DiD. Three outcomes are studied: establishment size, net entry rate, and payroll per employee.

## Verdict: MINOR REVISION

### Strengths
1. Novel question bridging corporate governance and macro dynamism
2. Significant finding on net entry rate (ATT = -0.0083, p=0.021)
3. Honest engagement with surprising establishment size result (negative, not positive)
4. Modern methodology (Callaway-Sant'Anna, randomization inference)
5. TWFE vs CS-DiD sign reversal is a genuine methodological contribution

### Issues Identified (from advisor review)
1. **Data coverage inconsistency** — Paper claimed CBP starts 1986 but analysis uses 1988-2019. FIXED: clarified that 1988 is the first year with consistent variables, and that 17 early-treated units are dropped.
2. **Missing N in Table 3** — FIXED: added observation counts.
3. **Treated states count** — Table 3 reported 32 treated states but 17 are dropped by CS-DiD. FIXED: now reports "effective treated states."
4. **P-value rounding** — Abstract had p=0.022 but exact calculation gives p=0.021. FIXED.
5. **TWFE result not in table** — FIXED: added Panel B to Table 3.

### Remaining Concerns
- Pre-trends for net entry at longer horizons (e-7 to e-6) show some positive coefficients; acknowledged in appendix
- Establishment size result only marginally significant (p=0.108); honestly reported
- Placebo test failed due to data limitations; acknowledged
