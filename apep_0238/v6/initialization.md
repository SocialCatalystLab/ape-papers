# Human Initialization
Timestamp: 2026-02-14T21:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0238
**Parent Title:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Parent Decision:** REVISION (empirical upgrade addressing referee concerns)
**Revision Rationale:** Full empirical upgrade addressing all three referee reports (GPT=MAJOR, Gemini=MINOR, Grok=MINOR): (1) Saiz (2010) IV for housing exposure via 2SLS, (2) wild cluster bootstrap inference for 9 census divisions, (3) Adao-Kolesar-Morales exposure-robust SEs, (4) employment-to-population migration decomposition, (5) formal unemployment persistence mechanism test, (6) exhibit improvements (harmonized axes, lighter grids, mechanism diagram), (7) prose polish, (8) theory review compliance.

## Key Changes Planned

- Add Saiz (2010) supply elasticity IV: first stage F-stat, 2SLS estimates, Anderson-Rubin CIs
- Wild cluster bootstrap with Rademacher weights at census division level (999 iterations)
- AKM exposure-robust standard errors for COVID Bartik specification
- Employment-to-population ratio LP to rule out migration as driver
- Formal mechanism test: UR persistence comparison across recessions
- Harmonize Figure 4 x-axes to 120 months both panels
- Negate COVID Bartik sign in Table 2 for consistent interpretation
- Promote JOLTS panels to main text; remove redundant welfare bar chart
- Add mechanism flow diagram
- Prose polish per prose review feedback
- Theory review (GPT-5.2-pro) for formal DMP model
- 5 new references (Saiz 2010, Fujita-Moscarini 2017, Cerra et al 2020, MacKinnon-Webb 2017, Cameron-Gelbach-Miller 2008)

## Inherited from Parent

- Research question: Same (demand vs supply recession scarring)
- Identification strategy: Same LP framework with controls, now augmented with Saiz IV
- Primary data source: Same (FRED API, BLS CES/LAUS, FHFA, JOLTS)
