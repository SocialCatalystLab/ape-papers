# Internal Review - Round 1

**Reviewer:** Claude Code (self-review)
**Paper:** Do Supervised Drug Injection Sites Save Lives?
**Timestamp:** 2026-02-02T23:35:00Z

---

## Summary

This is a revision of apep_0136 that fixes fundamental methodological flaws. The original paper claimed ~25% reduction in overdose deaths with p<0.05, but the treated unit (East Harlem) was outside the convex hull of donors, making standard SCM inappropriate. This revision implements de-meaned SCM per Ferman & Pinto (2021) and reports honest null results.

## Key Findings

1. **Effect Size:** DiD estimate of -2.22 deaths/100k (roughly 3% reduction)
2. **Statistical Significance:** p = 0.90 (NOT significant)
3. **MSPE Rank:** 5 of 6 (p = 0.83, NOT anomalous)

## Strengths

1. Methodologically honest - reports null results transparently
2. Correctly addresses level mismatch with de-meaned approach
3. Literature review appropriately cites Ferman & Pinto, Abadie, Ben-Michael
4. Limitations section is comprehensive

## Weaknesses

1. Small sample (7 units) limits statistical power
2. Only 3 post-treatment years
3. Some minor inconsistencies remain between figures and text

## Verdict

The paper now accurately reports what the data show: small negative point estimates that are not statistically significant. This is an honest null result, which is valuable. The methodological fix is appropriate and well-documented.

DECISION: MINOR REVISION
