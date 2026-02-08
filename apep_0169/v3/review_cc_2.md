# Internal Review - Round 2

**Reviewer:** Claude Code (Reviewer 2 mode - Second pass)
**Paper:** The Atlas of Self-Employment in America
**Date:** 2026-02-03

---

## PART 1: CRITICAL REVIEW (Deeper scrutiny)

### 1. METHODOLOGICAL CONCERNS

**Selection on Observables Assumption:**
The paper uses IPW under selection on observables. This is a strong assumption that may not hold:
- Entrepreneurial ability is unobserved and likely correlated with both self-employment choice and earnings
- Risk preferences are unobserved
- Business-specific human capital is unobserved

The sensitivity analyses (E-value = 1.91, Oster delta = 2,589) suggest robustness, but these assume confounders have limited correlation with observables. If entrepreneurial ability is highly correlated with education and homeownership (which it likely is), then the actual robustness may be lower.

**Recommendation:** Acknowledge more explicitly that IPW under selection-on-observables identifies conditional associations, not causal effects. The current hedging is adequate but could be strengthened.

**Weight Truncation:**
Weights truncated at 99th percentile. This is standard but the paper doesn't show sensitivity to different truncation levels (95th, 97th percentile).

**Recommendation:** Add a brief note about sensitivity to truncation threshold.

### 2. DATA CONCERNS

**2020 Exclusion:**
The exclusion of 2020 is well-justified, but raises questions about external validity. The 2021-2022 data may reflect post-pandemic labor market patterns that differ from pre-pandemic. The paper could more explicitly discuss whether findings generalize beyond this period.

**Self-Reported Incorporation Status:**
The ACS relies on self-report for incorporation status. Some respondents may misreport (e.g., LLCs may not be sure if they count as "incorporated"). No validation of this variable is possible.

### 3. INTERPRETATION CONCERNS

**Incorporated Premium for Men Only:**
The finding that incorporated premium accrues only to men (not women) is striking but not fully explained. The paper offers three potential mechanisms but doesn't test any. Which industries are men vs. women in? Are there differences in firm size or growth orientation?

**Geographic Variation:**
The state-level variation is interesting but interpretation is speculative. The paper suggests Texas's premium reflects "oil and gas" opportunities but provides no industry-specific evidence.

### 4. STATISTICAL PRECISION

All point estimates have appropriate CIs. State-level estimates with CIs are properly reported. The statistical infrastructure is sound.

### 5. LITERATURE GAPS (Specific citations needed)

**Missing foundational IPW papers:**
```bibtex
@article{rosenbaum1983propensity,
  author = {Rosenbaum, Paul R. and Rubin, Donald B.},
  title = {The Central Role of the Propensity Score in Observational Studies for Causal Effects},
  journal = {Biometrika},
  year = {1983},
  volume = {70},
  number = {1},
  pages = {41--55}
}
```

**Missing entrepreneurship papers:**
```bibtex
@article{hurst2011small,
  author = {Hurst, Erik and Pugsley, Benjamin Wild},
  title = {What Do Small Businesses Do?},
  journal = {Brookings Papers on Economic Activity},
  year = {2011},
  volume = {Fall},
  pages = {73--118}
}

@article{fairlie2005racial,
  author = {Fairlie, Robert W.},
  title = {Entrepreneurship and Earnings Among Young Adults from Disadvantaged Families},
  journal = {Small Business Economics},
  year = {2005},
  volume = {25},
  number = {3},
  pages = {223--236}
}
```

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

### Strengthening the Contribution

1. **Test mechanisms for gender gap:**
   - Show industry distribution by gender × incorporation status
   - Show hours worked and firm revenue proxies
   - This would elevate the paper significantly

2. **Decomposition analysis:**
   - Use Oaxaca-Blinder decomposition to quantify how much of the incorporated-unincorporated gap is explained by observable characteristics
   - This would help distinguish selection from structural explanations

3. **Policy implications section:**
   - Currently brief. Could calculate welfare implications of policies that encourage incorporation (e.g., subsidized incorporation fees, education programs)

4. **Historical context:**
   - How has the incorporated premium changed over time? Even a comparison of 2019 vs. 2021-2022 within your data would be informative

---

## OVERALL ASSESSMENT

### Strengths (unchanged from Round 1)
1. Novel three-way decomposition
2. Large sample enabling precise estimates
3. Striking gender finding
4. Appropriate methodology with sensitivity analyses
5. Strong writing

### Weaknesses
1. Cannot claim causality (acknowledged but could be clearer)
2. Gender mechanism untested
3. Geographic interpretation speculative
4. Some missing literature

### This paper is almost ready for external review.

The main issues are relatively minor:
- Add 2-3 missing citations
- Strengthen causal language hedging
- Consider adding one mechanism test for gender finding

---

DECISION: MINOR REVISION
