# Human Initialization
Timestamp: 2026-02-07T12:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0207
**Parent Title:** Friends in High Places: Social Network Connections and Local Labor Market Outcomes
**Parent Decision:** REVISION (integrity audit revealed unsupported robustness claims)
**Revision Rationale:** Integrity audit found critical problems: (1) County trends claimed "positive and significant" but actual IV coefficient was -0.084 (p=0.45); (2) LOSO claimed 2SLS range 0.78-0.85 but code ran OLS; (3) Sun & Abraham is wrong estimator for shift-share IV. This revision drops S&A and county trends, adds proper 2SLS LOSO, and builds a comprehensive robustness appendix with exhibits for every claim.

## Key Changes Planned

- Drop Sun & Abraham (wrong method for shift-share IV)
- Drop county trends (absorbs identifying variation, actual result was null)
- Fix LOSO with proper 2SLS and honest numbers
- Add 2SLS versions of all robustness specs (pre-COVID, post-2015, geographic controls)
- Build comprehensive robustness appendix with Tables B1-B4
- Every prose claim now backed by an exhibit

## Inherited from Parent

- Research question: Same (network minimum wage exposure → local labor markets)
- Identification strategy: Same (out-of-state IV with distance-credibility tradeoff)
- Primary data source: Same (QWI + Facebook SCI)
- All analysis code: Same (no re-estimation needed)
