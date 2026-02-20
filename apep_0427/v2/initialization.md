# Human Initialization
Timestamp: 2026-02-20T15:53:00Z

## Contributor (Immutable)

**GitHub User:** @olafdrw

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Questions Asked

1. **Research agenda:** Which research agenda?
   - Options: Medicaid provider spending (T-MSIS), India economic development (SHRUG), Open topic (any policy/data)

**Open Topic Path:**
2. **Method:** Which identification method?
3. **API keys:** Did you configure data API keys?
4. **External review:** Include external model reviews?
5. **Risk appetite:** Exploration vs exploitation?
6. **Other preferences:** Any other preferences or constraints?

## User Responses

1. Open topic (any policy/data)
2. Surprise me → Random selection: DiD
3. Yes
4. Yes (Recommended)
5. Follow the initial prompt (user-specified: training subsidies / early-career hiring incentives, France focus, vacancy microdata, novel quasi-experiments)
6. Trust your judgment — full freedom on design choices within the brief provided

## User Brief (Verbatim)

The user requested a paper on how training subsidies / early-career hiring incentives affect the entry-level labor market (hiring pipelines, substitution toward seniors/AI, and long-run career outcomes). Key specifications:
- Avoid canonical programs (German dual system, US ALMP)
- Prioritize newer quasi-experiments with high-frequency vacancy data
- Suggested policy shocks: France apprenticeship aid phase-outs, Australia BAC, UK levy threshold, Canadian tax credits
- Suggested data: Indeed/LinkedIn vacancy data, firm hiring composition, application congestion, career ladder persistence
- Conceptual questions: net creation vs relabeling, substitution vs automation, training externality repair, pipeline thinning effects

## Revision Information

**Parent Paper:** apep_0427
**Parent Title:** The €6,000 Question: Do Apprenticeship Subsidies Create Jobs or Relabel Hiring?
**Parent Decision:** MAJOR REVISION (GPT), MINOR REVISION (Grok, Gemini)
**Revision Rationale:** Fix RI permutation bug, add wild cluster bootstrap, add synthetic control method, address sectoral demand confound, fix claimed-but-unfixed revisions from v1

## Key Changes Planned

- Fix RI code to permute at sector level (was per-row)
- Add wild cluster bootstrap for few-cluster inference
- Add synthetic control method for cross-country analysis
- Fix all claimed-but-unfixed revisions from v1 reply_to_reviewers
- Rescale exposure variable for interpretability
- Add sector-specific linear trends to address demand confound
- Add pre-2025 robustness check

## Original Reviewer Concerns Being Addressed

1. **GPT-5.2:** Sectoral demand confound, missing WCB, RI bug → Fixed with sector trends, manual WCB, sector-level permutation
2. **Grok:** Total employment red flag, marginal significance → Resolved with sector trends robustness
3. **Gemini:** Table rendering, exposure scaling → Fixed with adjustbox package and rescaled exposure

## Inherited from Parent

- Research question: Do apprenticeship subsidies create jobs or relabel hiring?
- Identification strategy: Exposure DiD + cross-country DiD (improved with SCM, WCB, sector trends)
- Primary data source: Eurostat LFS + Indeed Hiring Lab (same)

## Setup Results

- **Research agenda:** none (open topic)
- **Domain:** Labor & employment (training subsidies, apprenticeships, youth labor markets)
- **Method:** DiD (random)
- **Data era:** Modern
- **Risk appetite:** Novel policy (user-directed: France apprenticeship subsidy phase-outs)
- **Other preferences:** Focus on France's post-pandemic apprenticeship subsidy as main quasi-experiment; combine with Indeed vacancy data; test relabeling hypothesis
