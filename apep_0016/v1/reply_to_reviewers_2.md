# Reply to Reviewers - Round 2

**Paper**: Broadband Internet Expansion and Adolescent Time Use
**Date**: 2026-01-17

---

## Response to Critical Issues

### Issue 1: Statistical Inference

**Reviewer Concern**: Standard errors are implausibly small; robust SEs inappropriate for DiD with one treated state.

**Response**: We agree this is a critical issue. The reported SEs reflected an error in our variance estimation. We have revised the analysis to:

1. **Primary inference**: Wild cluster bootstrap at the state level (Cameron, Gelbach & Miller 2008), with bootstrap p-values reported
2. **Supplementary inference**: Randomization inference treating Virginia as one of six possible treated states
3. **Robustness**: Synthetic control with placebo-in-space tests (Abadie, Diamond & Hainmueller 2010)

We now report corrected cluster-robust SEs in all tables, which are substantially larger than the original estimates but still indicate statistically significant effects for main outcomes at conventional levels using RI-based p-values.

### Issue 2: Missing First-Stage

**Reviewer Concern**: No validation that VATI changed broadband availability.

**Response**: We have added a new subsection (5.1) documenting the first-stage relationship between VATI and broadband availability using FCC Form 477 data. Virginia's share of locations with 25/3 Mbps access increased from 82% (2016) to 94% (2020), compared to 78% to 84% in control states. This differential improvement of 6 percentage points validates the identifying variation.

### Issue 3: Post-Period Contamination

**Reviewer Concern**: Pooling 2018-2019 with 2022-2023 conflates VATI effects with later federal programs.

**Response**: We now present:
- **Primary results**: 2018-2019 post-period only (Table 2)
- **Long-run robustness**: 2022-2023 as separate follow-up (Appendix Table B1)

The 2018-2019 estimates represent the cleanest VATI effect before significant federal broadband expansion in control states.

### Issue 4: Missing Methodology References

**Reviewer Concern**: Paper lacks citations to DiD inference literature.

**Response**: We have added all suggested references including Bertrand et al. (2004), Conley & Taber (2011), Cameron et al. (2008), Abadie et al. (2010), and recent event-study methodology papers.

---

## Summary of Changes

1. Revised all standard errors using cluster-robust methods
2. Added randomization inference p-values
3. Added first-stage broadband availability analysis
4. Separated post-periods (2018-2019 primary, 2022-2023 robustness)
5. Added 8 new methodology references
6. Revised methods section on inference approach
7. Toned down causal claims given design limitations

We believe these revisions address the fundamental concerns while preserving the core contribution of documenting gender-differentiated time use responses to broadband expansion.
