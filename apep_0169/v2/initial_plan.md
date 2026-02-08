# Research Plan - Revision of apep_0169

## Research Question

Does the aggregate self-employment earnings penalty mask heterogeneity between incorporated and unincorporated self-employment?

## Identification Strategy

Doubly robust inverse probability weighting (IPW) comparing:
1. Self-employed (aggregate) vs. wage workers
2. Incorporated self-employed vs. wage workers  
3. Unincorporated self-employed vs. wage workers

## Expected Effects and Mechanisms

Based on Levine & Rubinstein (2017):
- **Incorporated:** Small penalty or null (positive selection of high-ability workers)
- **Unincorporated:** Large penalty (heterogeneous population including precarious gig workers)
- **Aggregate:** Weighted average reflecting compositional mix

## Primary Specification

- Treatment: Self-employment indicators (aggregate, incorporated, unincorporated)
- Outcome: Log annual earnings
- Propensity score covariates: Age, age², female, college, married, race, homeowner, COVID period
- Weights: IPW with 99th percentile truncation
- Inference: HC1 robust standard errors, 95% CIs

## Planned Robustness Checks

1. Propensity score trimming (1%, 5%, 10% thresholds)
2. Coefficient stability (Oster 2019 method)
3. E-value sensitivity analysis
4. Excluding COVID period
5. Quantile treatment effects (10th, 25th, 50th, 75th, 90th percentiles)
6. Placebo tests on pre-determined characteristics

## Data

ACS PUMS 2019-2022, 10 large U.S. states, prime-age workers (25-54)
N ≈ 1.4 million observations

## Key Changes from Parent Paper

1. Decompose by incorporation status
2. Add 95% CIs to all tables
3. Report ATT alongside ATE
4. Add quantile treatment effects
5. Add missing literature citations
6. Convert theory section to prose
