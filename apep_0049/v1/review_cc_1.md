# Internal Review Round 1

**Reviewer:** Claude Code (Internal)
**Date:** 2026-01-22
**Paper:** Transit Funding Discontinuity at 50,000 Population Threshold

---

## Summary

This paper uses a regression discontinuity design to examine whether crossing the 50,000 population threshold—which triggers eligibility for FTA Section 5307 formula grants—affects transit usage and labor market outcomes. The paper finds null effects on all outcomes: transit share, employment rate, vehicle ownership, and commute times. The design passes standard validity tests (McCrary, covariate balance, placebo thresholds).

---

## Major Comments

### 1. First Stage is Not Shown

**Concern:** The paper assumes that crossing the threshold leads to increased transit funding, but never demonstrates this empirically. We need to see:
- Actual Section 5307 funding allocations by urbanized area population
- A first-stage RDD showing a discontinuity in funding at the threshold

Without this, we cannot distinguish between "federal funding has no effect" and "areas near the threshold don't actually receive different funding levels."

**Recommendation:** Add a first-stage analysis showing the funding discontinuity. If possible, obtain FTA apportionment data and show the sharp increase in funding at 50,000.

### 2. Timing Mismatch

**Concern:** The paper uses 2020 Census population to define treatment but 2018-2022 ACS outcomes. This creates a timing problem:
- Urbanized area boundaries were redefined after the 2020 Census (published 2023)
- The ACS outcomes may reflect service levels based on *pre-2020* urbanized area definitions
- Many areas that crossed 50,000 in 2020 may not have received funding yet

**Recommendation:** Acknowledge this timing issue explicitly. Consider using 2010 Census definitions with 2015-2019 ACS outcomes as a check. Discuss how recently-eligible areas may not have had time to implement service changes.

### 3. Sample Definition Unclear

**Concern:** The paper reports N = 2,637 urbanized areas in the analysis sample, but then shows N left = 2,128 and N right = 509 in the RDD estimates. This suggests most areas are below the threshold. The effective sample near the threshold is much smaller.

**Recommendation:**
- Report the effective sample size within the bandwidth more clearly
- Show how many observations are actually within ±15,000 of threshold (the near-threshold sample)
- Discuss statistical power explicitly

### 4. Interpretation of Null

**Concern:** The paper interprets the null result as evidence that "marginal federal transit funding does not improve outcomes." But alternative interpretations are equally plausible:
- Transit funding takes 5-10 years to translate into service improvements
- The ACS measures don't capture relevant outcomes (transit quality, access, not just mode share)
- The null reflects measurement error, not a true absence of effects

**Recommendation:** Be more circumspect in the interpretation. The null could reflect true absence of effect, implementation lags, or measurement limitations. All deserve equal weight.

---

## Minor Comments

### Methods

1. **Bandwidth selection:** The MSE-optimal bandwidth of ~13,000 population is quite narrow relative to the threshold. At 50,000, this means only areas between ~37,000 and ~63,000 contribute substantially. Consider showing estimates with larger bandwidths more prominently.

2. **Kernel choice:** Only triangular kernel is used. Show robustness to uniform and Epanechnikov kernels in appendix.

3. **Polynomial order:** The paper uses local linear regression. Add robustness to local quadratic.

### Presentation

4. **Abstract:** The abstract states effects in percentage points but the actual estimates are in decimal form (e.g., -0.0014 vs -0.14 pp). Standardize throughout.

5. **Table 1:** Add mean of outcome variable to help interpret magnitude. A -0.14 pp effect relative to a 0.7% mean is a 20% reduction—this should be noted.

6. **Literature review:** Missing several relevant papers on transit and employment:
   - Holzer, Ihlanfeldt, Sjoquist (1994) - spatial mismatch
   - Raphael and Rice (2002) - car access and employment
   - Ong and Blumenberg (1998) - welfare-to-work and transit

7. **Figures:** Figure 2 (transit share RDD) should zoom in on the y-axis near the mean (0.5-1.5%) to show the discontinuity more clearly. Currently the scale makes it hard to see.

### Writing

8. The introduction is strong but could be tightened. The first three paragraphs could be condensed.

9. Section 6 (Discussion) is the weakest section. Expand the mechanisms discussion with more specific reasoning about why effects might be null.

10. The conclusion repeats too much from the introduction. Cut the summary and expand on policy implications.

---

## Verdict: MAJOR REVISION

The paper addresses an interesting and policy-relevant question with a clean identification strategy. However, the absence of a first-stage analysis is a significant gap. Without demonstrating that funding actually differs at the threshold, the null results are uninterpretable. The timing mismatch between population measurement and outcomes is also concerning.

### Required Changes for Resubmission

1. Add first-stage analysis showing funding discontinuity
2. Address timing mismatch explicitly
3. Clarify effective sample size
4. More balanced interpretation of null results
5. Add robustness checks (kernels, polynomial order)
6. Improve Figure 2 presentation

---

## Revision Priority

| Item | Priority |
|------|----------|
| First stage analysis | Critical |
| Timing discussion | High |
| Sample size clarity | Medium |
| Additional robustness | Medium |
| Writing improvements | Low |
