# Revision Plan - Round 3

## Review Feedback Summary

Phase 1: PASS (format requirements met)
Phase 2: Reject / Major revision (fundamental design limitations)

### Critical Issues Identified

1. **Fundamental design limitation**: 1 treated state + 2-4 controls is insufficient for credible inference
2. **Event study figure shows raw means, not coefficient plot with CIs**
3. **Missing few-cluster inference citations**: Conley & Taber (2011), Abadie et al (2010)
4. **Outcome measurement not validated against external data (QCEW)**
5. **Internal inconsistency**: Figure 3 shows significance stars but text says no significance

## Reviewer's Core Point

The reviewer correctly notes that the fundamental limitation is the design itself - this cannot be fixed with statistical methods alone. The paper should be positioned as a **methodological cautionary tale** rather than a definitive causal study.

## Planned Changes

### 1. Add Missing Citations

Add:
- Conley and Taber (2011) - inference with few policy changes
- Abadie, Diamond, Hainmueller (2010) - synthetic control
- Arkhangelsky et al (2021) - synthetic DiD

### 2. Reframe the Paper

Position more explicitly as:
- A methodological illustration of the few-cluster inference problem
- An exploratory case study, not definitive causal evidence
- A cautionary tale for state-level policy evaluation

### 3. Remove Significance Stars from Figure

Update Figure 3 caption/presentation to not show significance stars, consistent with the wild bootstrap finding of no significance.

### 4. Acknowledge Fundamental Limitations More Explicitly

In Discussion/Conclusion:
- State clearly that with 1 treated state and 2-4 controls, definitive causal conclusions are not possible
- Suggest alternative designs (synthetic control, QCEW data) for future research

### 5. Clarify Estimand

Be explicit about:
- Denominator: all working-age adults (18-64)
- Outcome is an indicator for industry among ALL working-age, not just employed

## Acceptance Path

Given fundamental design limitations, the paper may not reach "Accept" at a top journal standard. However, it has value as:
1. A methodological illustration
2. A data collection and organization effort
3. An honest presentation of uncertainty

The key is to be explicit about what the paper CAN and CANNOT conclude.

## Implementation

Since this is round 3 of 5+ required, proceed with incremental improvements and continue review cycles.
