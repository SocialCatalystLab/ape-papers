# Human Initialization
Timestamp: 2026-02-03T19:00:00-08:00

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Revision Information

**Parent Paper:** apep_0169
**Parent Title:** The Self-Employment Earnings Penalty: Selection or Compensation?
**Parent Decision:** MAJOR REVISION / MINOR REVISION (from referee reviews)
**Revision Rationale:** Address reviewer concerns: add 95% CIs, distinguish incorporated vs unincorporated self-employment, add industry/occupation discussion, report ATT alongside ATE, add quantile treatment effects, add missing literature citations, convert bullet lists to prose.

## Key Changes Planned

1. Decompose self-employment by incorporation status (critical per Gemini reviewer)
2. Add 95% confidence intervals to all tables
3. Report ATT alongside ATE estimates
4. Add quantile treatment effects analysis
5. Add missing literature: Levine & Rubinstein (2017), Austin (2009), Hirano et al. (2003)
6. Convert theoretical framework from bullets to prose
7. Expand all sections with detailed exposition
8. Remove AI acknowledgment

## Original Reviewer Concerns Being Addressed

1. **GPT-5-mini (Major Revision):** Missing CIs, need incorporated/unincorporated split, missing literature
2. **Grok-4.1 (Minor Revision):** Causal language too strong, need ATT, remove AI acknowledgment
3. **Gemini-3 (Minor Revision):** Critical: need incorporated vs unincorporated distinction per Levine & Rubinstein (2017)

## Inherited from Parent

- Research question: Does self-employment carry an earnings penalty?
- Identification strategy: Doubly robust IPW (refined with incorporated/unincorporated decomposition)
- Primary data source: ACS PUMS 2019-2022
