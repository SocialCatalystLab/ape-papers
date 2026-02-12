# Research Plan: Who Bears the Burden of Monetary Tightening?

*Living document — updated as analysis progresses.*

See initial_plan.md for the pre-registered plan committed before data fetch.

## Status

- [x] Phase 1: Setup (initialization.md)
- [x] Phase 2: Discovery (ideas.md)
- [x] Phase 3: Ranking (ranking.md, conditions.md)
- [ ] Phase 4: Execution (data, analysis, model, paper)
- [ ] Phase 5: Review & Revise
- [ ] Phase 6: Publish

## Current Focus

Executing Phase 4: Fetching data, running analysis, building model, writing paper.

## Key Design Decisions

1. **Python for all analysis** (user preference) — local projections via statsmodels, model via scipy
2. **JK shocks only** (no VAR) — cleanest identification, avoids recursive ordering debates
3. **Two-sector model** (goods/services) — simplest structure that captures the key heterogeneity
4. **Full JOLTS decomposition** — mechanisms, not just reduced form
5. **Welfare via consumption equivalents** — comparable to HANK literature

## Deviations from Initial Plan

None yet — executing as planned.
