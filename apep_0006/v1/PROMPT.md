# Research Prompt: Universal License Recognition and Interstate Migration

## Research Question

**Do Universal License Recognition (ULR) laws increase interstate migration of workers in licensed occupations?**

## Policy Background

Arizona became the first state to enact a Universal License Recognition law (HB 2569) in August 2019. Under ULR, workers who hold a valid occupational license from another state can receive a comparable license in the adopting state if they:
- Have held the license for at least one year
- Are in good standing in all states where licensed
- Pay applicable fees
- Meet residency and background check requirements

By 2022, over 20 states had adopted some form of ULR policy.

## Method

**Difference-in-Differences (DiD)** comparing interstate migration rates of licensed occupation workers in ULR-adopting states versus non-adopting states, before and after adoption.

## Key Variables (Census PUMS)

- **Outcome:** MIG (mobility status), MIGSP (migration state)
- **Treatment:** State-year ULR adoption indicators
- **Occupation:** OCCP (occupation codes for licensed professions)
- **Controls:** AGEP, SEX, RAC1P, SCHL, WAGP, ST
- **Weight:** PWGTP (person weight)

## Identification

The key identifying assumption is that, absent ULR adoption, interstate migration trends for licensed workers would have been parallel between adopting and non-adopting states.

## Expected Effect

ULR should reduce licensing barriers for movers, increasing in-migration of licensed workers to adopting states. Effect should be concentrated in:
- Occupations with historically difficult reciprocity (cosmetology, contractors)
- Workers near state borders (lower moving costs)

## Staggered Adoption

YES - treatment is staggered across states (Arizona 2019, Pennsylvania 2019, Montana 2019, Idaho 2020, etc.). Must use modern DiD methods (Callaway & Sant'Anna 2021) to avoid negative weighting bias from TWFE.
