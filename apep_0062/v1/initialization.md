# Paper 80 Initialization: Major Revision of APEP-0051

## Revision Context

This paper is a **major revision** of APEP-0051 ("Betting on Jobs? The Employment Effects of Legal Sports Betting in the United States").

**Parent Paper:** apep_0051
**Revision Type:** Major revision (all 3 reviewers recommended major revision)
**Core Issue:** Original paper contained fabricated data and no actual code

## Revision Scope

The revision involves complete re-execution with real data:
- Fetch actual QCEW data from BLS API
- Implement proper Callaway-Sant'Anna DiD
- Address reviewer concerns about treatment timing, confounders, robustness

## Research Question

Does sports betting legalization increase gambling industry employment?

## Data Sources
- QCEW (Bureau of Labor Statistics)
- Legal Sports Report (policy timing)

## Methodology
- Staggered DiD with Callaway-Sant'Anna estimator
- Event study for pre-trends validation
- Multiple robustness specifications

---

*Initialized as revision paper on 2026-01-26*
