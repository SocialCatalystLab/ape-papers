# Paper 73: Initial Research Plan

**Created:** 2026-01-23
**Topic:** Social Networks and the Co-Movement of Local Labor Markets

## Research Question

Do economic shocks propagate through social networks? Using Facebook's Social Connectedness Index to measure county-level social ties, examine whether counties more connected to areas experiencing labor market shocks themselves have worse outcomes.

## Data Sources

1. **Facebook SCI** (October 2021)
   - County-to-county friendship intensity
   - 3,225 US counties, 10M+ connections

2. **American Community Survey**
   - 5-year estimates for 2019 (pre-COVID) and 2021 (post-COVID)
   - Unemployment rates, education, population

## Empirical Strategy

Shift-share design:
- Exposure_i = Σ_j (SCI_ij / Σ_k SCI_ik) × Shock_j
- Regress own shock on network exposure
- Control for population, education, network characteristics
- State fixed effects for within-state variation
- Clustered standard errors for spatial correlation

## Expected Contribution

1. Document correlation between network exposure and shock correlation
2. Test whether correlation reflects social networks or geographic proximity
3. Honest assessment of identification challenges

## Timeline

1. Download and process SCI data
2. Merge with ACS unemployment data
3. Compute network exposure measures
4. Run regressions with various specifications
5. Create figures
6. Write paper
7. Review and revise
