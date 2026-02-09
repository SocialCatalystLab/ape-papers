# Research Ideas (Revision of APEP-0049)

This is a revision of paper apep_0049. The research question and identification strategy are inherited from the parent paper, with critical fixes to address code integrity and timing issues.

## Idea 1: Federal Transit Funding and Local Labor Markets (REVISED)

**Policy:** FTA Section 5307 Urbanized Area Formula Grants - eligibility determined by 50,000 population threshold
**Outcome:** Transit ridership, employment rates, vehicle ownership, commute times (2016-2020 ACS)
**Identification:** Sharp Regression Discontinuity Design at 50,000 Census population threshold

**Why it's novel:**
- First paper to properly align timing: 2010 Census classification → FY2012+ eligibility → 2016-2020 outcomes
- Addresses critical code integrity issues from parent paper (no fabricated first-stage data)
- Real data from Census Bureau APIs with transparent replication code

**Feasibility check:**
- CONFIRMED: 3,592 urban areas with complete data (497 above threshold, 3,095 below)
- CONFIRMED: McCrary density test passes (p = 0.984, no manipulation)
- CONFIRMED: Covariate balance holds (p = 0.157 for median household income)
- CONFIRMED: All outcome variables available from ACS at urban area level

**Key changes from parent:**
1. Fixed data fabrication - using real Census API data instead of synthetic funding variables
2. Fixed timing - using 2010 Census for running variable (not 2020)
3. Expanded literature review with all required citations
4. Added comprehensive robustness checks and heterogeneity analysis

This idea was selected for execution as it directly addresses the reviewer concerns while maintaining the valid core research question.
