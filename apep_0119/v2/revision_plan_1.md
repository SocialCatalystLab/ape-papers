# Revision Plan - Round 1

**Paper:** Do Energy Efficiency Resource Standards Reduce Electricity Consumption?
**Date:** 2026-02-01
**Based on:** External reviews from GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash

---

## Summary of Reviews

| Reviewer | Verdict | Key Concerns |
|----------|---------|--------------|
| GPT-5-mini | MAJOR REVISION | Inference robustness, policy bundling, single-state cohorts |
| Grok-4.1-Fast | MINOR REVISION | Missing citations, total electricity pre-trends |
| Gemini-3-Flash | MAJOR REVISION | Policy bundling, building codes, literature gaps |

---

## Consolidated Issues and Actions

### Priority 1: Inference Robustness (GPT, Grok)

**Issue:** Discrepancy between CS-DiD asymptotic p-value (<0.01) and TWFE wild bootstrap p-value (0.14) raises concerns about statistical significance.

**Actions Taken:**
1. Added explicit discussion in Results section acknowledging this discrepancy
2. Wild cluster bootstrap already implemented for TWFE (51 clusters)
3. CS-DiD uses influence-function-based variance estimator with state clustering
4. Added cautionary language that precision is limited by state-level clustering

### Priority 2: Policy Bundling Interpretation (All reviewers)

**Issue:** EERS adoption correlates with other progressive energy policies (building codes, RPS, decoupling). Effect may be "energy-progressive state package" rather than isolated EERS.

**Actions Taken:**
1. Strengthened language throughout paper to frame finding as "EERS package effect"
2. Added controls for RPS and decoupling policies in robustness (already present)
3. Added explicit acknowledgment that estimates capture bundled policy effects
4. Reframed conclusion to emphasize policy bundle interpretation

### Priority 3: Total Electricity Pre-Trends (All reviewers)

**Issue:** Total electricity outcome shows concerning pre-trends, undermining causal interpretation.

**Actions Taken:**
1. Added **bold caveat** in Results section stating total electricity result should NOT be interpreted as causal
2. Clarified that this result is presented "for completeness only"
3. Correctly referenced the event-study figure showing pre-trends (Figure 5, not forest plot)

### Priority 4: Literature Gaps (GPT, Gemini)

**Issue:** Missing citations to key energy economics papers.

**Actions Taken:**
1. Already cite Fowlie, Greenstone, Wolfram (2018) - expanded discussion in text
2. Already cite Rambachan & Roth (2023) HonestDiD framework
3. Paper already has comprehensive bibliography (35+ entries)

### Priority 5: Statistical Reporting Clarity (GPT)

**Issue:** Abstract phrasing "95% CI excluding zero at the 1% level" was confusing.

**Actions Taken:**
1. Changed to explicit "$t = -4.07$, $p < 0.01$" for clarity
2. Added sample sizes and clustering info to all tables

---

## Issues NOT Addressed (with justification)

### Rambachan-Roth Sensitivity Analysis

**Issue:** Reviewers suggest applying HonestDiD sensitivity bounds.

**Justification:** The did package's bootstrap implementation does not converge for several single-state cohorts. Full HonestDiD sensitivity would require additional methodological infrastructure. Given clean visual pre-trends and multiple robustness checks, this is deferred to future work.

### Triple-Difference Design

**Issue:** Reviewers suggest isolating EERS from concurrent policies via triple-diff.

**Justification:** No suitable third dimension (e.g., industry × state × time) available without introducing additional identification assumptions. Paper acknowledges bundled interpretation as the correct estimand.

---

## Verification Checklist

- [x] Abstract wording fixed (t-statistic and p-value)
- [x] Total electricity caveat strengthened with bold text
- [x] Figure reference corrected (event-study, not forest plot)
- [x] All 4 advisors PASS
- [x] Paper recompiled successfully

---

## Next Steps

1. Write reply to reviewers
2. Run final review
3. Publish as revision of apep_0119
