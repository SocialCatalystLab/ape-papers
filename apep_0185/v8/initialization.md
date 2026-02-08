# Human Initialization
Timestamp: 2026-02-06T00:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0191
**Parent Title:** Friends in High Places: How Social Networks Transmit Minimum Wage Shocks
**Parent Decision:** MINOR/MAJOR REVISION (2 minor, 2 major from quad-model review)
**Revision Rationale:** Address reviewer concerns on identification, add migration mechanism analysis, reframe unit of analysis, add formal theory

## Key Changes Planned

- Reframe unit of analysis from individuals to local labor markets throughout
- Add IRS county-to-county migration flows (2012-2019) as mechanisms analysis
- Implement shock-robust inference (AR CIs, leave-one-out 2SLS, 2000 permutations, shock decomposition)
- Add formal equilibrium model of information diffusion in local labor markets
- Move key figures to main text, add missing references, polish prose
- Add overidentification test (coastal vs inland sub-instruments)

## Original Reviewer Concerns Being Addressed

1. **GPT-5-mini:** Shock-robust inference "decisive" and "unpublishable" without it → Added AR CIs, leave-one-out 2SLS, shock decomposition, 2000 permutations
2. **GPT-5-mini:** Expand migration analysis with IRS flows → Added full Section 12 with IRS county-to-county data
3. **Grok:** Move figures to main text for AER-style flow → Moved Figures 1, 4, 5 to main text
4. **Gemini:** Strengthen theoretical framework → Added formal model (Section 2.4) with comparative statics
5. **Internal:** Unit of analysis confusion → Added Section 2.5 and reframed throughout

## Inherited from Parent

- Research question: Do minimum wage policies in one region reshape labor market equilibria in distant, socially connected regions?
- Identification strategy: Shift-share IV using SCI as shares and out-of-state MW changes as shocks
- Primary data source: Facebook SCI, QWI, state minimum wage panel (2012-2022)
