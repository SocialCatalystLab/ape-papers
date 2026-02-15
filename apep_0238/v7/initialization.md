# Human Initialization
Timestamp: 2026-02-15T09:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0238
**Parent Title:** Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets
**Parent Decision:** REVISION (polish round — unified prose, targeted substantive additions)
**Revision Rationale:** Polish revision of v6 addressing: (1) unified prose voice (v6 was patched by 4 agents across 5 rounds), (2) rescaled COVID Bartik to SD=1 units (preempting Gemini "implausibly large" flag), (3) within-GR horse race (HPI vs GR Bartik) to address GPT demand-vs-episode concern, (4) Rotemberg weight diagnostics for COVID Bartik, (5) AKM SEs promoted to main table, (6) exhibit streamlining (scatter + recovery maps to appendix, placebo promoted), (7) 5 new references, (8) inference narrative tightening.

## Key Changes Planned

- Standardize COVID Bartik to mean=0, SD=1 (all coefficients directly interpretable)
- Within-GR horse race: HPI (demand) vs GR Bartik (industry) in same regression
- Rotemberg weight decomposition for COVID Bartik (top industries, leave-one-out)
- Promote AKM exposure-robust SEs from appendix to main Table 2
- Move scatter and recovery maps to appendix; promote placebo test to main text
- Normalize JOLTS to rates; clarify Saiz scatter x-axis label
- Comprehensive prose pass for unified voice (first person, active, specific)
- Add 5 references (Goldsmith-Pinkham+ 2020, Jorda+ 2016, Hall-Kudlyak 2022, Gertler-Trigari 2009, Romano-Wolf 2005)
- Inference narrative: lead with bootstrap, add CIs, note multiple testing

## Inherited from Parent

- Research question: Same (demand vs supply recession scarring)
- Identification strategy: Same LP framework with Saiz IV, wild bootstrap, AKM SEs
- Primary data source: Same (FRED API, BLS CES/LAUS, FHFA, JOLTS)
