# Research Plan: Paper 83

**Parent:** apep_0081 - "Time to Give Back? Social Security Eligibility at Age 62 and Civic Engagement"
**Decision:** REJECT AND RESUBMIT
**Status:** Revision Complete

---

## Research Question

Does Social Security eligibility at age 62 increase civic engagement (volunteering, grandchild care) by enabling retirement?

## Identification Strategy

**Regression Discontinuity Design (RDD)** at age 62, the earliest age for Social Security retirement benefits.

### Key Methodological Challenge: Discrete Running Variable

Age is observed in integer years (16 values: 55-70), so standard RD asymptotics may not hold. This revision implements multiple inference approaches:

1. **Standard rdrobust** (baseline, potentially overstates precision)
2. **Clustered SEs by age** (accounts for age-cell dependence)
3. **Clustered SEs by age × year** (additional robustness)
4. **Kolesar-Rothe honest CIs** (RDHonest package)
5. **Local randomization RD** (permutation test, ages 61 vs 62)
6. **Donut RD** (exclude age 62)

## Data

**American Time Use Survey (ATUS)** 2003-2023 from Bureau of Labor Statistics
- Sample: Ages 55-70
- N = 57,900 observations
- Key outcomes: Any volunteering, volunteering minutes, grandchild care

## Expected Results

1. **First Stage**: Strong discontinuity in work time at age 62 (~23 minutes decline)
2. **Reduced Form**: Small positive effect on volunteering (~0.5 pp), but not robust to discrete-RD corrections
3. **Mechanism**: SS eligibility enables retirement, freeing time for volunteering

## Primary Specification

```
Y_i = α + β·Post62_i + γ·(Age_i - 62) + δ·Post62_i·(Age_i - 62) + ε_i
```

With clustered standard errors by age (16 clusters).

## Robustness Checks

1. Bandwidth sensitivity (h = 3 to 8 years)
2. Placebo cutoffs (ages 58-66)
3. Period exclusions (Great Recession 2008-2011, Pandemic 2020-2021)
4. Subgroup analyses (gender, education, marital status)
5. Donut RD (exclude age 62)
6. Local randomization inference

## Key Findings (Implemented)

| Inference Method | Estimate | SE | Significant? |
|------------------|----------|-----|--------------|
| rdrobust (standard) | 0.78 pp | 0.97 pp | No |
| Parametric, HC1 | 0.54 pp | 0.33 pp | No |
| Parametric, cluster(age) | 0.54 pp | 0.25 pp | Yes (p~0.05) |
| Local randomization | 0.55 pp | - | No (p=0.36) |
| Cell-level weighted | 0.54 pp | 0.48 pp | No |

**Conclusion**: Effect is marginal; only 1/6 inference methods significant at 5%.

## Revision Changes Made

1. Fixed discrete running variable inference (FATAL issue)
2. Added first-stage evidence (employment discontinuity)
3. Expanded paper from ~15 to 28 pages
4. Added missing literature citations
5. Comprehensive robustness checks
