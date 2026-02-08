# Research Plan: Revision of apep_0089

## Parent Paper
- **ID:** apep_0089
- **Title:** The Thermostatic Voter: Why Local Policy Success Fails to Build National Support
- **Decision:** MAJOR REVISION

## Research Question
Does prior experience with sub-national climate policy affect citizens' willingness to support national climate action?

## Identification Strategy
Spatial RDD at Swiss canton borders comparing municipalities in cantons with comprehensive energy laws (MuKEn) vs. control cantons.

**Primary Specification:** Same-language borders only (eliminates French-German confounding)

### Exposure Alignment (for panel DiD component)
- **Who is actually treated?** Residents of cantons where MuKEn energy law was in force before May 2017 (GR, BE, AG, BL, BS)
- **Primary estimand population:** All voters in treated cantons who experienced building/energy regulations
- **Control population:** Voters in the 21 cantons without comprehensive energy laws before May 2017
- **Measurement:** Canton-level vote shares for 4 energy referendums (2000, 2003, 2016, 2017)

## Key Improvements in This Revision

### 1. Border-Pair Fixed Effects
- Added segment-specific fixed effects
- Allow distance slopes to vary by border segment
- Report which borders drive results transparently

### 2. Improved Inference
- Canton-level clustered standard errors
- Stratified permutation tests by language region

### 3. Expanded Balance Tests
- Log population, population density, turnout
- Pre-treatment referendum voting patterns

### 4. Placebo RDD
- Test same specification on unrelated 2016-2017 referendums
- Immigration, Basic Income, Corporate Tax
- Result: Borders show generic discontinuities, not energy-specific

### 5. Honest Framing
- Lead with same-language estimate (−1.4pp, p=0.36) as primary
- Present pooled estimate as sensitivity check
- Acknowledge placebo concerns in discussion

## Data Sources
- **swissdd R package:** Swiss referendum results at Gemeinde level
- **BFS:** Municipality boundaries and demographics
- **Treatment:** Five cantons with MuKEn in force before May 2017

## Primary Results

| Specification | Estimate | SE | p-value |
|---------------|----------|-----|---------|
| Same-Language Borders (PRIMARY) | −1.4 pp | 1.53 | 0.36 |
| Pooled Borders | −2.7 pp | 1.10 | 0.01 |
| OLS + Language Controls | −1.8 pp | 1.93 | 0.35 |

## Conclusion
No evidence of positive policy feedback. Point estimates are negative but imprecise when using cleanest design. Placebo tests suggest caution in interpreting pooled estimates.
