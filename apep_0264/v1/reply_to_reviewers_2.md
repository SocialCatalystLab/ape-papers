# Reply to Reviewers — Round 2 (Stage C)

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

**Concern 1: Incorporation-weighted exposure measure using Compustat.**
This is a substantial extension requiring firm-level data that goes beyond the current state-level CBP design. We agree this is the single most important avenue for strengthening causal claims and have flagged it prominently in Section 8.4 (Limitations) and Section 8.5 (Threats to Validity). A Compustat-based analysis is the natural next step for a future revision.

**Concern 2: Complete inference reporting (SEs, CIs, N, clusters).**
Table 3 already reports coefficient estimates, standard errors in parentheses, 95% confidence intervals, observation counts, number of effective treated states, control states, and clustering level. Table 4 (robustness) also includes 95% CIs.

**Concern 3: Cohort-specific ATTs in appendix.**
This is a reasonable request. The current paper follows standard CS-DiD aggregation practice (Callaway & Sant'Anna 2021). Cohort-decomposed figures would be a valuable appendix addition in a revision.

**Concern 4: Formal pre-trend joint F-tests.**
The event-study figures display pre-treatment coefficients with 95% CIs. For net entry, we transparently note longer-horizon pre-trend deviations in Appendix B.2. Formal joint F-tests are a useful addition for future revision.

**Concern 5: Spatial spillover tests.**
Interesting suggestion. Cross-state spillovers through firm relocation are plausible but would require county-level border analysis. Acknowledged as future work.

**Concern 6: Mechanism evidence (M&A, patenting, investment).**
These require separate datasets (SDC Platinum, USPTO, Compustat). The paper provides macro evidence; micro mechanisms are complementary extensions.

**Concern 7: Missing references.**
Added Hopenhayn (1992) and Bebchuk et al. (2009) to references. Gutiérrez & Philippon (2017) was already included.

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

**Concern 1: Industry heterogeneity (Giroud-style by concentration).**
Acknowledged as a high-value extension. The paper's macro question intentionally aggregates across industries; sector-specific decomposition is complementary.

**Concern 2: Compustat incorporation weights.**
See response to Reviewer 1, Concern 1.

**Concern 3: CIs in Table 3.**
Already included (95% CIs in Table 3, Panel A).

**Concern 4: Missing references (Cunningham & Ederer 2022, Roth 2022).**
Roth (2022) is already cited. Cunningham & Ederer is noted for future revision.

**Concern 5: Rephrase "autonomously generated" note.**
Noted for journal submission formatting.

## Reviewer 3 (Gemini-3-Flash) — MAJOR REVISION

**Concern 1: Industry heterogeneity with HHI.**
See response to Reviewer 2, Concern 1. This is the highest-priority extension for a revision.

**Concern 2: Delaware-to-local incorporation ratios as treatment intensity.**
Creative suggestion. Would require external data on incorporation patterns. Acknowledged as a feasible intermediate step toward full Compustat analysis.

**Concern 3: Decompose net entry into gross entry and gross exit.**
CBP provides establishment counts but not direct gross entry/exit flows. The BDS (Business Dynamics Statistics) could provide this decomposition but at a different aggregation level. Noted for future work.

**Concern 4: Missing references (Hopenhayn 1992, Gutiérrez & Philippon 2017).**
Both now included in references.bib.

## Summary of Changes Made
- Added Hopenhayn (1992) and Bebchuk et al. (2009) to references.bib
- All other suggestions are acknowledged as valuable extensions for future revision
- Core paper already addresses most reporting concerns (CIs, N, clustering details)
