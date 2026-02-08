# Initial Research Plan: IV/2SLS Extension of apep_0186

## Research Question
Does network minimum wage exposure causally affect local employment?

## Identification Strategy

### Treatment
- **Endogenous variable:** Network MW exposure (SCI-weighted average of MW in other states)
- **Challenge:** Network structure may be correlated with unobserved local economic conditions

### Instrument
- **Distance-based IV:** MW in socially connected counties that are 400-600km away
- **Exclusion restriction:** Distant MW changes are plausibly exogenous to local economic shocks
- **Relevance:** Distant connections are subset of total connections, so distant MW predicts total network exposure

### Fixed Effects
- County FE: Absorb time-invariant county characteristics
- State × Quarter FE: Absorb own-state MW and state-specific trends

## Expected Effects and Mechanisms

### Primary Hypothesis
Network exposure transmits information about wages, affecting local labor supply.

### Expected Sign
- **Positive employment effect** if: Workers respond to information by increasing labor supply
- Mechanism: Higher reservation wages → increased job search → higher employment

### Industry Heterogeneity
- Effects should be larger in "high-bite" industries (retail, food service)
- Near-zero effects expected in "low-bite" industries (finance, professional services)

## Primary Specification

```
log(Emp)_ct = β × NetworkExposure_ct + α_c + γ_st + ε_ct

Instrumented: NetworkExposure_ct ~ IV_400-600km_ct
```

## Planned Robustness Checks

1. **Distance window sensitivity:** Test 200-400km, 400-600km, 600-800km
2. **Leave-one-state-out:** Exclude CA, NY, WA, MA, FL sequentially
3. **Pre-trends:** Event study by IV quartile
4. **Balance tests:** Pre-period characteristics by IV quartile
5. **Overidentification:** Use multiple distance windows as instruments
6. **Political placebo:** Test effect on GOP vote share (should be null)

## Power Assessment

- **Pre-treatment periods:** 2010-2014 (5 years, 20 quarters)
- **Post-treatment periods:** 2015-2022 (8 years, 32 quarters)
- **Treated clusters:** 51 states with varying MW changes
- **Counties:** ~3,100 with IV coverage
- **MDE:** With N ≈ 150,000 county-quarters, should detect effects > 0.5%

## Data Requirements

- [x] SCI county pairs (from parent paper)
- [x] State MW panel (from parent paper)
- [x] County centroids (from parent paper)
- [ ] QWI employment data (Census API)
- [ ] Presidential election returns (MIT Election Data Lab)
