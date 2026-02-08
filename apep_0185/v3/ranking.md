# Idea Ranking Summary

## Revision Context
This is a revision of apep_0186, which received feedback requiring causal identification.

## Selected Approach: Distance-Based IV for Network MW Exposure

### Scores
| Criterion | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| Novelty | 8/10 | 40% | 3.2 |
| Identification | 8/10 | 30% | 2.4 |
| Feasibility | 9/10 | 20% | 1.8 |
| Relevance | 9/10 | 10% | 0.9 |
| **Overall** | **8.4/10** | | |

### Recommendation: PURSUE

### Rationale
1. **Novelty:** First paper to use distance-filtered SCI weights as instrument
2. **Identification:** Geographic separation provides credible exclusion restriction
3. **Feasibility:** All data available (SCI, MW panel, QWI, election returns)
4. **Relevance:** Directly addresses reviewer concerns about causal identification

## Execution Plan
1. Fetch QWI employment data via Census API
2. Construct distance-based IV (400-600km window)
3. Run 2SLS with county + state×time FE
4. Validate with Goldsmith-Pinkham tests
5. Test political economy extension
