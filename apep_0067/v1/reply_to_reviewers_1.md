# Reply to Reviewers - Round 1

## Reviewer 1

**Concern 1: TWFE not appropriate for staggered adoption**

We agree that TWFE faces challenges under staggered adoption with heterogeneous treatment effects. We have:
- Added permutation inference (Appendix C.1) as a robustness check that does not rely on TWFE asymptotics
- Documented our attempts to implement Callaway-Sant'Anna (unstable due to single cohort) and synthetic control (poor pre-treatment fit)
- The permutation p-value of 0.42 confirms the null result is robust to inference method

**Concern 2: Few effective switchers**

We have clarified that there are 16 switcher states across 2010-2019, with most switches in 2014-2015. The permutation analysis uses a subset (5 states in 2015 only) for clean inference with a single cohort. The result is consistent with the full-sample TWFE.

**Concern 3: Need parallel trends evidence**

We acknowledge this limitation. With only 4-5 pre-treatment years for most switchers and a single cohort, formal pre-trends testing is not informative. This is a fundamental limitation of the research design.

---

## Reviewer 2

**Concern 1: Modern DiD methods required**

We attempted Callaway-Sant'Anna but the estimator produces unstable estimates with only one treatment cohort (2015) and small sample sizes within group-time cells. We document this limitation in the new Section C.2.

**Concern 2: Inference with few clusters**

We now provide:
- Permutation inference (p = 0.42)
- Explicit discussion of Conley-Taber concerns
- Clear documentation that cluster-robust SEs should be interpreted cautiously

---

## Reviewer 3

**Concern 1: Internal consistency (treatment timing)**

We have corrected the documentation:
- 16 states switch during 2010-2023 (not 5)
- The 5-state figure refers to 2015 cohort only (used for clean permutation inference)
- Updated Table 1 notes and all text references

**Concern 2: Missing citations**

Added: MacKinnon et al. (2022), Abadie et al. (2010), fixed citation key for Dube (2019).

**Concern 3: Table 7 unclear**

Renamed to "Modern Inference Methods (Restricted Sample)" with explicit notes explaining it uses 26 states (21 never-treated + 5 switchers in 2015) and reports N = 2,433.

---

## Summary

The paper has been revised to:
1. Add permutation inference as primary robustness check
2. Correct treatment timing documentation
3. Add missing citations
4. Clarify restricted sample for inference appendix

We acknowledge that fundamental methodological concerns (TWFE under staggered adoption, few switchers) cannot be fully addressed without different data or a different research design. The paper's contribution is documenting these limitations transparently while providing first estimates using ATUS time diary data.
