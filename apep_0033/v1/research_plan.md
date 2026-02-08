# Paper 44: Research Plan (Working Document)

**Created:** 2026-01-19
**Last Updated:** 2026-01-19
**Status:** ACTIVE

---

## Feasibility Assessment (Added 2026-01-19)

### Critical Finding: Limited Early Adopters

Most state adoptions (24 of 30) occurred 2022-2025, meaning affected cohorts haven't graduated or entered the labor market yet. Only **5 early-adopter states** have cohorts old enough to observe labor market outcomes:

| State | Law Year | First Class | Age in 2024 ACS | Post-Treatment Years |
|-------|----------|-------------|-----------------|---------------------|
| Utah | 2008 | 2010 | 32 | 14 |
| Virginia | 2011 | 2015 | 27 | 9 |
| Alabama | 2013 | 2014 | 28 | 10 |
| Tennessee | 2013 | 2015 | 27 | 9 |
| Missouri | 2017 | 2020 | 22 | 4 |

**Power concern:** With only 4-5 states showing meaningful treatment exposure, standard DiD inference at the state-cluster level may be underpowered. However:
- 45 control states provide robust counterfactual
- Large ACS sample sizes (~50K per state-year)
- Can use wild bootstrap for inference with few treated clusters

**Decision:** Proceed with caution. If pre-trends fail or estimates are very noisy, pivot to alternative design or different research question.

---

## Research Question

Do state-mandated financial literacy graduation requirements improve long-run employment outcomes and earnings for exposed student cohorts?

## Policy Background

Beginning with Utah in 2008, states have progressively required high school students to complete personal finance or financial literacy coursework as a graduation requirement. By 2025, 29 states have adopted such mandates, with staggered implementation creating natural variation for causal identification.

## Identification Strategy

**Cohort-based Difference-in-Differences**

1. **Treatment definition:** A cohort is treated if the state required financial literacy for graduation by the time that cohort reached grade 12 (age ~18).

2. **Treatment assignment:** Use birth year and state of birth to assign treatment status. Acknowledge this introduces measurement error from cross-state migration, which will attenuate estimates toward zero.

3. **Comparison:** Compare labor market outcomes for cohorts exposed to mandatory financial literacy vs. unexposed cohorts, relative to never-treated states.

4. **Estimator:** Use Callaway-Sant'Anna (2021) estimator for staggered DiD with heterogeneous treatment effects. Report group-time ATTs and event-study coefficients.

## Data

**Primary source:** IPUMS ACS 2010-2024
- Identify individuals by birth year (BIRTHYR) and state of birth (BPL)
- Outcome variables: EMPSTAT, WKSWORK1, UHRSWORK, INCWAGE
- Sample: Adults aged 20-30 who would have been in high school during the policy rollout

**Policy data:** Hand-collected from state education department records and NEFE legislative tracker

## Expected Sample Size

- ~3.5 million observations per ACS year (1% sample)
- ~500,000 observations per year for ages 20-30
- ~15 years of ACS data = ~7.5 million person-year observations
- Cluster-robust standard errors at state level (50 clusters)

## Outcomes

1. **Primary:** Employment rate (employed vs. not employed)
2. **Secondary:**
   - Weeks worked per year
   - Usual hours worked per week
   - Wage/salary income (logged)
   - Educational attainment (as mediator)

## Pre-Analysis Checks

1. **Parallel trends:** Event-study plot showing pre-treatment coefficients are zero
2. **Stacked DiD:** Robustness to heterogeneous treatment effects
3. **Placebo tests:**
   - Older cohorts from treated states (should show no effect)
   - Treated cohorts on outcomes unaffected by financial literacy

## Threats to Identification

1. **Measurement error in treatment:** State of birth ≠ state of schooling for movers
   - Mitigation: Report bounds assuming different mover rates

2. **Coincident reforms:** States adopting financial literacy may also adopt other education reforms
   - Mitigation: Control for state-year policy indices; test event-study pre-trends

3. **Selective adoption:** Early adopters may differ systematically
   - Mitigation: Compare early vs. late adopters; use never-treated as control

## Timeline

1. Document policy adoption dates
2. Build IPUMS extract
3. Construct treatment assignment
4. Estimate main DiD specification
5. Run robustness checks
6. Write paper

---

*This plan is immutable after initial commit. Working document: research_plan.md*
