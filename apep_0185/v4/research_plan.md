# Initial Research Plan (Revision of APEP-0187)

## Research Question
What is the causal effect of social network minimum wage exposure on local employment and earnings?

## Identification Strategy
- **Endogenous variable:** Full network MW (SCI-weighted, leave-own-county-out)
- **Instrument:** Out-of-state network MW (SCI-weighted, leave-own-state-out)
- **Key insight:** Out-of-state MW predicts full network MW but doesn't directly affect local employment

## Expected Effects
- Information transmission: workers learn about wages through networks
- Positive effects on earnings (higher wage expectations)
- Ambiguous effects on employment

## Primary Specification
```
First Stage: FullNetworkMW = π × OutOfStateMW + CountyFE + State×TimeFE + ε
Second Stage: log(Emp) = β × FittedFullNetworkMW + CountyFE + State×TimeFE + ε
```

## Planned Robustness
1. Distance thresholds for IV (100km, 200km, 300km+)
2. Balancedness tests
3. Earnings as alternative outcome

