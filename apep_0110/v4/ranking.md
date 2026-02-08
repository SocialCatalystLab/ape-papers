# Idea Ranking

## Summary

| Idea | Novelty | Identification | Feasibility | Relevance | Score | Verdict |
|------|---------|----------------|-------------|-----------|-------|---------|
| SpatialRDD Cannabis-Alcohol Substitution | 9/10 | 9/10 | 9/10 | 8/10 | 35/40 | PURSUE |

## Detailed Evaluation

### Idea 1: The Border Discontinuity in Substance Substitution

**Research Question:** Does geographic access to legal cannabis dispensaries reduce alcohol-involved fatal traffic crashes?

**Method:** Spatial Regression Discontinuity Design at state borders

#### Novelty (9/10)
- First application of SpatialRDD to cannabis-alcohol substitution
- Existing literature uses difference-in-differences at state level
- Border discontinuity provides cleaner identification than aggregate state comparisons
- Novel use of crash location data with signed distance to borders

#### Identification (9/10)
- Sharp discontinuity at state borders (legal status changes discretely)
- No manipulation of crash locations (quasi-random events)
- Continuity assumption plausible (crash characteristics smooth across borders)
- Running variable (distance to border) is clean and well-defined
- Complementary distance-to-dispensary analysis provides robustness

#### Feasibility (9/10)
- FARS data publicly available via NHTSA
- State boundaries available from Census TIGER/Line
- Dispensary locations extractable from OpenStreetMap
- Sample size sufficient (~5,000+ crashes within 150km of borders)
- R implementation with rdrobust package straightforward

#### Relevance (8/10)
- Speaks to active policy debate on cannabis legalization
- Harm reduction argument frequently cited by legalization proponents
- Null result would also be policy-relevant
- Traffic safety is a major public health concern

#### Verdict: PURSUE

The idea combines methodological innovation (SpatialRDD) with a highly relevant policy question. Identification is clean, data are accessible, and even a null result contributes to scientific understanding of the substitution hypothesis.

---

## Decision

**Proceed to execution with Idea 1: SpatialRDD Cannabis-Alcohol Substitution**
