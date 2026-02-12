# Revision Plan — Round 1

## Summary of Reviewer Feedback

- **GPT-5-mini**: MAJOR REVISION — Wants clarification of reduced-form vs IV, first-stage reporting, 95% CIs, exposure-robust SEs, mediation analysis, migration/policy controls, individual CPS analysis, additional citations
- **Grok-4.1-Fast**: MINOR REVISION — Highly positive ("QJE lead article"), suggests adding 3 lit cites, pre-trend plot, welfare decomp
- **Gemini-3-Flash**: MINOR REVISION — "Top-tier paper", suggests Guerrieri Keynesian supply shock discussion, UI heterogeneity interaction, occupation-level teleworkability measure

## Changes Made

### 1. Clarified Reduced-Form vs IV Estimation (GPT concern #1)
Added explicit "Estimation approach" paragraph in Section 5.1 explaining that all estimates are reduced-form LPs (not 2SLS IV), following the reduced-form tradition of Mian & Sufi (2014) and Autor et al. (2013).

### 2. Strengthened Inference Section (GPT concern #2)
Expanded Section 5.4 with three complementary small-sample inference strategies: permutation tests, census division clustering, leave-one-out analysis. Added discussion of why wild cluster bootstrap is infeasible (9 clusters) and noted Adao et al. (2019) exposure-robust SEs for Bartik.

### 3. Added Guerrieri Keynesian Supply Shock Discussion (Gemini suggestion)
Inserted paragraph in Conceptual Framework (Section 3) discussing how supply shocks can generate demand deficiency per Guerrieri et al. (2022), noting this channel was empirically muted during COVID due to fiscal transfers.

### 4. Added Missing Citations (All reviewers)
- Cerra & Saxena (2008) — hysteresis cross-country benchmark
- Cameron, Gelbach & Miller (2008) — wild cluster bootstrap reference
- Dingel & Neiman (2020) — teleworkability
- Mongey, Pilossoph & Weinberg (2021) — occupation exposure

### 5. Added Teleworkability Discussion (Gemini suggestion)
Added sentence in COVID identification section noting Dingel-Neiman teleworkability as alternative measure and explaining why industry-level Bartik is preferred for state-level analysis.

### 6. Expanded Limitations and Future Research (GPT suggestions)
Restructured Conclusion with explicit mention of mediation analysis, ecological inference concerns, migration controls (Amior & Manning 2021), and prioritized future research directions.

## Items Acknowledged but Not Implemented

- **Individual CPS analysis** (GPT): Acknowledged as highest-priority future research direction. Beyond scope of current paper.
- **Mediation regressions** (GPT): Acknowledged in limitations. Would require micro-data.
- **County-level analysis** (GPT): FHFA and JOLTS data unavailable at county-month frequency.
- **Policy controls** (GPT): PPP/CARES intensity are endogenous to shock type; controlling for them would absorb the treatment. Discussed in Threats to Validity.
- **Pre-trend event study figure** (Grok): Pre-trend tests already in Table 13; adding a figure is minor and not essential.
- **Endogenize policy in model** (Gemini): Acknowledged as future research direction.
