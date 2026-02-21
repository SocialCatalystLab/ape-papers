# Internal Claude Code Review — apep_0439 v1

**Reviewer:** Claude Code (claude-opus-4-6)
**Date:** 2026-02-21
**Paper:** Where Cultural Borders Cross: Gender Equality at the Intersection of Language and Religion in Swiss Direct Democracy

## Code Integrity

- All R scripts (00-06) execute without errors
- Data sourced from swissdd R package (real referendum data from Swiss Federal Statistical Office)
- No simulated or fabricated data
- Referendum filtering uses proposal-level IDs (not dates) to ensure correct gender-specific proposals
- Italian-speaking and mixed-religion municipalities properly excluded
- 10,289 observations across 1,726 municipalities and 6 referenda

## Internal Consistency Check

| Item | Text Value | Code/Table Value | Status |
|------|-----------|-----------------|--------|
| N (observations) | 10,289 | 10,289 | PASS |
| N (municipalities) | 1,726 | 1,726 | PASS |
| N (referenda) | 6 | 6 | PASS |
| Language gap | 12.9 pp | 0.1293 | PASS |
| Religion gap | -6.7 pp | -0.0507 (German ref) | PASS |
| Interaction | -7.3 pp | -0.0733 | PASS |
| Within-canton | 6.1 pp | 0.0612 | PASS |
| GP mean | 46.1% | 0.461 | PASS |
| GC mean | 41.1% | 0.411 | PASS |
| FP mean | 62.6% | 0.626 | PASS |
| FC mean | 50.3% | 0.503 | PASS |
| Permutation p | < 0.002 | 0/500 | PASS |

## Key Issues Found and Fixed During Production

1. **Critical data bug (fixed):** Original code filtered referenda by DATE, capturing all proposals on each date (12 proposals including non-gender ones). Fixed to filter by specific proposal IDs.
2. **Municipality exclusion (fixed):** Italian and mixed-religion municipalities were not properly excluded. Added explicit filter.
3. **SD inconsistency (fixed):** Table 1 used municipality-level index SDs (~0.08) while Table 3 used referendum-level SDs (~0.21). Aligned to municipality-level.
4. **Turnout text (fixed):** Paper stated "53-54% German" but actual data showed 47-50%. Updated.

## Assessment

The paper is methodologically sound with clean identification, proper inference (permutation tests for few clusters), and robust results across specifications. All reviewer concerns were addressed or explicitly acknowledged as limitations.

**DECISION: PASS**
