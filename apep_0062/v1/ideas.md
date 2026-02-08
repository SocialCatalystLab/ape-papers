# Research Ideas: Major Revision of APEP-0051

## Context

This document records the research idea for paper_80, which is a **major revision** of APEP-0051 following reviewer feedback.

## Idea: Employment Effects of Sports Betting Legalization (Revised)

### Research Question
Does sports betting legalization following *Murphy v. NCAA* (2018) create jobs in the gambling industry?

### Identification Strategy
Staggered difference-in-differences exploiting state-by-state legalization timing. Use Callaway-Sant'Anna estimator to address heterogeneous treatment effects.

### Data Sources
- **Outcome:** QCEW NAICS 7132 (Gambling Industries) state-year employment, 2014-2023
- **Treatment:** Legalization dates from Legal Sports Report

### Feasibility Assessment
- **Data availability:** QCEW publicly available via BLS API ✓
- **Policy variation:** 38 states legalized 2018-2024, 12 never-treated ✓
- **Identification:** Staggered adoption provides credible comparison ✓

### Key Improvements Over Parent Paper
1. Real QCEW data (parent had fabricated statistics)
2. Callaway-Sant'Anna estimator (parent used problematic TWFE)
3. Address iGaming confounding
4. Pre-trends validation with event study
5. Multiple robustness specifications

### Expected Contribution
Rigorous causal estimates of employment effects. Null finding (if obtained) would challenge industry job creation claims.

---

*Single idea selected as this is a major revision of an existing paper.*
