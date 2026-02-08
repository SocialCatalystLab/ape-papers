# Human Initialization
Timestamp: 2026-02-05T23:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Revision Information

**Parent Paper:** apep_0187
**Parent Title:** Social Network Minimum Wage Exposure: Causal Evidence from Distance-Based Instrumental Variables
**Parent Decision:** MAJOR REVISION / REJECT AND RESUBMIT
**Revision Rationale:** Complete restructuring of identification strategy per user specification

## Key Changes Planned

1. **Redefine endogenous variable:** "MW in Social Network" = SCI-weighted MW excluding only own-county (include same-state connections). This is the natural definition of "what MW are my social connections exposed to?"

2. **New IV strategy:** Use "MW in Out-of-State Social Network" (exclude own-state entirely) as instrument for full network MW. This should have stronger first stage than current design.

3. **Distance robustness:** Add "MW in Distant Out-of-State Network" (exclude own-state + min distance X km) as more aggressive robustness check.

4. **Incremental presentation:** Build up results step by step:
   - OLS with full network MW
   - First stage and balancedness tests for out-of-state IV
   - 2SLS if IV is strong
   - Distance robustness if basic IV works

5. **Mechanism discussion:** Compare OLS vs 2SLS estimates to discuss endogeneity direction and mechanisms.

## Original Reviewer Concerns Being Addressed

1. **Weak IV (F≈1.18):** New identification strategy with stronger first stage
2. **No credible causal inference:** If new IV works, paper delivers causal estimates
3. **Framing as data paper:** If IV works, reframe as causal paper

## Inherited from Parent

- Research question: Effect of network MW exposure on employment
- Data sources: SCI, QWI, state minimum wages
- Sample period: 2012-2022
