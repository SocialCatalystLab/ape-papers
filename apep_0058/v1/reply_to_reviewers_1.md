# Reply to Reviewers - Round 1

**Paper:** paper_73 - SOI Discrimination Laws and Housing Voucher Utilization
**Date:** 2026-01-24

---

## Response to Reviewer 1

**On paper length and depth:**
We acknowledge the paper is shorter than typical general-interest submissions. This reflects the scope of a working paper exploring the feasibility of this research design with available data.

**On event-study coefficient tables:**
We agree that tabulating event-study coefficients with SEs would strengthen the presentation. This is an implementation detail we would address in a full revision.

**On inference with few clusters:**
The point about wild cluster bootstrap with 11 treated states is well-taken. We clustered at the state level but acknowledge that with few clusters, bootstrap-based inference would be more robust.

**On local SOI contamination:**
This is an important limitation we did not adequately address. Compiling local SOI ordinances would substantially strengthen the design but requires additional data collection.

**On pre-trend testing:**
We acknowledge the event time -2 coefficient warrants more formal testing. Implementing Rambachan-Roth sensitivity analysis would be valuable for a full revision.

---

## Response to Reviewer 2

**On aggregation level:**
We agree that state-year occupancy is coarse. PHA-level monthly data from the Voucher Management System would be superior for identifying mechanisms.

**On treatment timing:**
The mid-year effective dates coded to calendar years do create potential attenuation. A fractional-year exposure approach would be more precise.

**On COVID-era confounds:**
We attempted to address this by excluding 2020-2021, but agree this is insufficient given the clustering of adoptions in 2020-2022. Additional controls for ERA spending and eviction moratoria would help.

**On literature:**
We accept the criticism that our literature review is too thin. We would add Rambachan & Roth (2023), Borusyak et al. (2021), and additional voucher lease-up literature in revision.

---

## Response to Reviewer 3

**On inference reporting:**
We agree that p-values should be reported alongside confidence intervals. The lack of tabulated event-study coefficients is a presentation gap we would fix.

**On mechanism:**
The reviewer correctly notes that occupancy can change through multiple channels beyond landlord acceptance. Decomposing effects into lease-up rates, time-to-lease, and authorized unit changes would be valuable.

**On contribution positioning:**
We claimed "first rigorous causal analysis" of statewide SOI laws. We would better distinguish from local ordinance studies and explain the trade-offs of state-level aggregation in revision.

---

## Summary

All three reviewers identify similar fundamental issues:
1. Coarse unit of analysis (state-year)
2. Weak inference reporting
3. Pre-trend concerns not formally addressed
4. Missing important literature
5. Mechanisms unclear

These issues reflect the inherent limitations of this preliminary analysis rather than fixable presentation problems. A competitive top-journal submission would require:
- PHA-level or county-level data
- Local SOI ordinance data
- Wild cluster bootstrap inference
- Formal pre-trend sensitivity analysis
- Substantially expanded scope

We thank the reviewers for their thorough and constructive feedback.
