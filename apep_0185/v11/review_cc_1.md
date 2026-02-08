# Internal Review - Round 1

**Reviewer:** Claude Code (self-review)
**Date:** 2026-02-06

## Summary

This paper examines how social network connections transmit minimum wage shocks across labor markets, using Facebook Social Connectedness Index (SCI) data combined with county-level QWI employment data. The key revision from the parent paper (apep_0201) is the introduction of reduced-form event studies that resolve the pre-trend critique.

## Key Strengths

1. **Identification innovation**: The reduced-form event study (regressing outcomes directly on the instrument) provides a compelling resolution to the pre-trend problem. The structural ES rejects parallel trends (F=3.90, p=0.008) but the RF ES using exclusively out-of-state variation shows clean pre-trends (F=1.53, p=0.207). This distinction is well-motivated and clearly presented.

2. **Distance-credibility analysis**: The systematic table showing how first-stage F, balance, RF pre-trends, and 2SLS estimates evolve across distance cutoffs (0-500km) is an excellent contribution. The pattern is exactly what one would hope: more distant connections provide cleaner identification (better balance, cleaner pre-trends) while the coefficient remains stable.

3. **Strong first stage**: F=558 is exceptional for a shift-share design. The instrument has real bite.

4. **Comprehensive robustness**: AR confidence sets, LOSO analysis, placebo shocks (GDP, employment), two-way clustering, distance robustness — the paper addresses a wide range of concerns.

## Weaknesses

1. **County-specific trends attenuation**: The 99% attenuation with county trends (Section 17) is concerning. The paper should discuss this more carefully — it could mean the identifying variation is truly local and absorbed by trends, or it could indicate that trends absorb meaningful variation. Currently mentioned but not adequately discussed.

2. **Sun & Abraham**: The SA estimate is small and insignificant (ATT=0.005, p=0.11). The paper needs to discuss why this differs from the 2SLS result — likely because SA defines cohorts based on the timing of network shocks, which is fundamentally different from the continuous shift-share treatment.

3. **Complier characterization**: The IV sensitivity ratios are all very close to 1.0 (0.998-1.003), suggesting very little variation in "compliance." This could be better interpreted.

4. **Short pre-period**: Only 4 quarters of pre-treatment data remains a limitation that should be acknowledged more prominently.

## Suggestions

- Add explicit discussion of county-trends attenuation
- Explain SA vs 2SLS difference
- Strengthen LATE interpretation

DECISION: MINOR REVISION
