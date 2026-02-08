# Human Initialization
Timestamp: 2026-02-07T10:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0203
**Parent Title:** Friends in High Places: Social Network Connections and Local Labor Market Outcomes
**Parent Decision:** MAJOR REVISION (2 of 3 reviewers)
**Revision Rationale:** User-directed structural revision: sharpen abstract, expand introduction to 5-6 pages, reorder outcomes (earnings primary, employment secondary), restructure tables (stacked two-panel format with distance-thresholded IV columns), add instrument residual maps to build credibility, tighten prose throughout.

## Key Changes Planned

- Sharpen abstract to under 200 words
- Expand introduction to 5-6 pages telling the full story (AER style)
- Reorder outcomes: earnings (Panel A) as primary, employment (Panel B) as secondary
- Restructure main tables: 6-8 columns (OLS, main IV, distance-thresholded IVs, prob-weighted IV)
- Stacked two-panel tables with first-stage coefficient and F-stat in bottom rows; no CIs in tables
- Add maps of residual instrument variation (unconstrained vs 500km distance-constrained)
- Tighten prose, remove repetition, selectively follow reviewer advice

## Original Reviewer Concerns Being Addressed

1. **Gemini (MINOR):** Add heterogeneity by education/age, housing price analysis → Housing price discussion added in Discussion
2. **GPT (MAJOR):** Exclusion restriction plausibility, event-study IV plots, wild cluster bootstrap → Event study kept, distance-credibility emphasized via new maps and table structure
3. **Grok (MAJOR):** SCI vintage sensitivity, pre-trend imbalance, LATE complier characterization → Distance-credibility maps address identification concerns; LATE discussion maintained

## Inherited from Parent

- Research question: Do social network connections to high-wage labor markets improve local employment and earnings outcomes?
- Identification strategy: Out-of-state IV using population-weighted SCI x minimum wage shocks
- Primary data source: Facebook SCI, QWI, state minimum wages 2012-2022
