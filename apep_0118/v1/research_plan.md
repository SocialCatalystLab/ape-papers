# Initial Research Plan: Sports Betting Employment Effects (Revision)

## Revision of apep_0038

This plan documents the research design for a revision of apep_0038, addressing all major reviewer concerns.

## Research Question

Did sports betting legalization create jobs in the gambling industry?

## Identification Strategy

**Design:** Staggered difference-in-differences

**Treatment:** State-level sports betting legalization following Murphy v. NCAA (May 2018)

**Control group:** Not-yet-treated states (primary); never-treated states (robustness)

**Key identifying assumption:** Parallel trends - absent treatment, employment in treated states would have evolved similarly to control states

## Expected Effects and Mechanisms

**Main hypothesis:** Sports betting legalization increases gambling industry employment

**Mechanisms:**
1. Direct hiring at sportsbook operations (retail counters, mobile customer service)
2. Compliance and technology staff for mobile operations
3. Spillovers to related gambling activities as customers visit establishments

**Expected heterogeneity:**
- Mobile-permitting states should show larger effects (larger market, more staff)
- Effects should grow over time as markets mature

## Primary Specification

Callaway-Sant'Anna estimator:
- Outcome: NAICS 7132 employment (Gambling Industries)
- Treatment: Year of first legal sports bet
- Unit: State
- Time: 2010-2024 (8 pre-years, 6 post-years)
- Controls: Not-yet-treated states

## Planned Robustness Checks

1. **Control group:** Never-treated only vs not-yet-treated
2. **COVID sensitivity:** Exclude 2020-2021
3. **iGaming controls:** Exclude NJ, PA, MI, WV, CT
4. **Pre-PASPA states:** Exclude DE, MT, OR
5. **HonestDiD:** Rambachan-Roth sensitivity analysis
6. **Leave-one-out:** Verify no single state drives results
7. **Placebo industries:** Manufacturing, Agriculture

## DiD Feasibility Assessment

| Criterion | Status | Notes |
|-----------|--------|-------|
| Pre-treatment periods | ✓ 8 years | 2010-2017 |
| Treated clusters | ✓ 34 states | Well above 20 threshold |
| Selection into treatment | ✓ Exogenous | Murphy decision external shock |
| Comparison group | ✓ Similar | 16 never-treated states |
| Outcome alignment | ✓ Direct | NAICS 7132 = Gambling Industries |

## Data Sources

1. **Employment:** QCEW (BLS) - NAICS 7132, 2010-2024
2. **Policy timing:** Legal Sports Report, verified against state announcements
3. **iGaming dates:** American Gaming Association

## Expected Timeline

This is a revision - analysis pipeline already built, data already fetched. Focus is on executing robustness checks and revising paper text.
