# Reply to Reviewers - Round 1

## Overview

We thank the three reviewers for their thorough and constructive feedback. The reviews unanimously recommend "Reject and Resubmit" due to fundamental identification concerns that require substantial methodological redesign.

We acknowledge the validity of these concerns and document them here for future work.

---

## Reviewer 1

**Concern 1: Identification not credible due to rurality confounding**
> "Distance-to-dispensary is strongly entangled with within-state rurality/urbanity, border economics, road environment, EMS response, and enforcement"

*Response*: We acknowledge this concern. The state + year FE approach does not fully address within-state spatial confounding. A future version should implement a border-discontinuity design or county-month panel exploiting CA/NV openings.

**Concern 2: Composition estimand hard to interpret**
> "You estimate Pr(alcohol involved | fatal crash). Even if causal, this does not identify whether alcohol-involved fatal crashes fell in levels."

*Response*: We agree. A revised version should estimate crash counts/rates using Poisson/PPML with exposure offsets, not just conditional shares.

**Concern 3: Literature too thin**
*Response*: We will add citations for spatial inference (Conley 1999), modern DiD (Callaway & Sant'Anna 2021), and border designs (Dube-Lester-Reich 2010).

---

## Reviewer 2

**Concern 1: Design is cross-sectional, not quasi-experimental**
> "The design is essentially cross-sectional with state/year FE, and identification appears to come mostly from cross-sectional geographic differences in distance within state, not from quasi-experimental timing."

*Response*: Acknowledged. A redesign around the NV (2017) and CA (2018) openings would provide more credible time variation.

**Concern 2: Treatment measurement crude**
> "Driving time is approximated as: haversine × 1.3 ÷ 85 km/h"

*Response*: We will validate with actual routing (OSRM) for a subsample and consider using routing-based times in future work.

**Concern 3: Missing confidence intervals**
*Response*: We will report 95% CIs for all main specifications.

---

## Reviewer 3

**Concern 1: Spatial confounding**
> "The core problem is that the paper leans heavily on cross-sectional spatial variation... but does not convincingly rule out confounding by rurality/road type, enforcement, demographics"

*Response*: We agree this is the central identification challenge. A county FE + county-month panel design would better address this.

**Concern 2: Small-cluster inference**
> "Eight clusters (states) is extremely small for reliable cluster-robust inference"

*Response*: While we implement wild cluster bootstrap, moving to a county-level panel would provide more clusters and credible inference.

---

## Summary of Required Changes

1. Redesign around county-month panel with dispensary opening dates
2. Implement event-study/DiD around NV and CA openings
3. Estimate levels (crash counts/rates) in addition to composition
4. Upgrade inference with spatial HAC, county clustering, 95% CIs
5. Expand literature review substantially
6. Validate driving time measure with actual routing

These changes represent a fundamental methodological revision that goes beyond the scope of a standard paper revision.
