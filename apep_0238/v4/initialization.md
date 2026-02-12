# Human Initialization
Timestamp: 2026-02-12T19:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0238
**Parent Title:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Parent Decision:** REVISION (the Shleifer cut — integrity + structure + prose)
**Revision Rationale:** Two-pillar revision: (1) Fix code scanner integrity flags — implement LP controls described in Eq.(1), fix hardcoded N, document rescaling, fix horizon mismatch; (2) The Shleifer cut — restructure 68-page paper into ~45-page main text + focused appendix, keeping full DMP model inline, with economics-first prose.

## Key Changes Planned

- Implement LP controls (log population, pre-recession growth, industry shares, region dummies) to match Eq.(1)
- Fix N=46 hardcoding → dynamic computation from regression objects
- Document 0.3 rescaling factor in Figure 10 caption
- Fix COVID scatter horizon mismatch (h=12 in code vs h=48 in caption)
- Move 6 figures and secondary tables to appendix (Shleifer cut)
- Trim robustness, inference, JOLTS, and background sections
- Add appendix table of contents with clickable hyperlinks
- Shleifer prose pass: active voice, economics-first narration, earned sentences only

## Inherited from Parent

- Research question: Same (demand vs supply recession scarring)
- Identification strategy: Same LP framework with controls
- Primary data source: Same (FRED API, BLS CES/LAUS, FHFA, JOLTS)
