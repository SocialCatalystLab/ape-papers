# Paper 73: Research Ideas

## Selected Idea: Social Networks and Labor Market Co-Movement

### Research Question
Do economic shocks propagate through social networks? Are local labor markets more synchronized when they are socially connected?

### Data
- **Facebook Social Connectedness Index (SCI)**: County-to-county measure of Facebook friendship intensity, October 2021
- **American Community Survey**: County-level unemployment rates for 2019 and 2021

### Identification Strategy
Shift-share design using SCI as exposure weights:
- Exposure_i = Σ_j (w_ij × Shock_j)
- Where w_ij are normalized SCI weights and Shock_j is unemployment change in county j

### Key Findings
1. Strong positive correlation: β = 0.28 (1 SD network exposure → 0.28 pp larger shock)
2. Q5 vs Q1 difference: 0.69 pp
3. Survives state fixed effects: β = 0.14
4. BUT: Loses significance with clustered SEs
5. BUT: Leave-out-state exposure is negative

### Interpretation
Correlation likely reflects within-state spatial dependence rather than pure social network transmission. Still valuable descriptive finding.

---

## Alternative Ideas Considered

### Idea 2: SCI Diversity and Economic Resilience
- Do counties with more diverse networks recover faster from shocks?
- Cross-sectional design limits causal claims
- Deferred for future work

### Idea 3: Social Networks and Policy Diffusion
- Do socially connected states adopt similar policies?
- Would require policy adoption data
- Interesting but complex identification

### Idea 4: Housing Price Contagion via SCI
- Did housing crash spread through social networks?
- Timing mismatch (SCI is 2021, crash was 2008)
- Would need to assume network stability
