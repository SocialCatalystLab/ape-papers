# Internal Review - Round 1

**Reviewer:** CC-Reviewer-2 (Internal)
**Paper:** "Recreational Marijuana Legalization and Business Formation"
**Paper ID:** APEP-0110
**Date:** 2026-01-29
**Decision:** MAJOR REVISION

---

## Summary

This paper investigates whether the legalization of recreational marijuana affects new business formation, using a staggered difference-in-differences design applied to U.S. Census Bureau Business Formation Statistics (BFS) data from 2005 to 2024. The study exploits variation in the timing of first legal recreational retail sales across 21 treated states, employing both two-way fixed effects (TWFE) and Callaway and Sant'Anna (2021) estimators. The main TWFE estimate is -0.068 (SE 0.040), the CS overall ATT is -0.028 (SE 0.029), and the paper reports a randomization inference p-value of 0.093 and a pairs cluster bootstrap p-value of 0.064. An event study shows growing negative effects over post-treatment horizons. The paper also examines an alternative Census outcome, the Business Formation 8-Quarter (BF8Q) series, which shows a positive coefficient but is correctly noted to have limited causal interpretability.

The paper is well-written, clearly organized, and demonstrates competent application of modern DiD methods. At approximately 34 pages of main text, it meets length expectations for a serious empirical contribution. However, several issues require substantive attention before the paper can proceed.

---

## Major Issues

### 1. Treatment of the BF8Q Outcome Requires Greater Care

The paper includes analysis of the BF8Q (Business Formation within 8 Quarters) outcome, which shows a positive coefficient. The authors note that the BF8Q series is available only through 2020, creating a timing mismatch with many treatment cohorts. While I appreciate that the authors flag this as descriptive, the current treatment is insufficient.

**Specific concerns:**

- The BF8Q results appear in a regression table alongside other outcomes that are interpreted causally. This creates ambiguity for the reader. The descriptive caveat is mentioned in the text but may be missed by a reader scanning the tables.
- The paper should either (a) move the BF8Q analysis to a clearly labeled descriptive appendix section, (b) add explicit table notes stating "not causally identified" on the relevant rows/columns, or (c) provide a more detailed discussion of exactly which cohorts contribute post-treatment BF8Q observations and how this limits inference.
- The positive BF8Q coefficient juxtaposed with the negative application-based coefficients is an interesting pattern that warrants more discussion. Does this suggest compositional effects? Selection into which businesses actually form? The paper should at minimum speculate on mechanisms rather than simply reporting the coefficient and moving on.

**Required:** Substantially revise the presentation of BF8Q to eliminate any possibility of causal misinterpretation, and expand the discussion of what the BF8Q-application divergence might mean substantively.

### 2. Statistical Power Concerns with 21 Clusters

The design uses 21 treated states, which is a reasonable number for DiD but places the paper in a moderate-power regime that deserves more explicit discussion.

**Specific concerns:**

- With 21 treated states (and presumably 29 or fewer never-treated controls), cluster-robust inference is operating near the lower bound of asymptotic reliability. The paper provides randomization inference (RI p = 0.093) and pairs cluster bootstrap (p = 0.064), which is commendable, but these should be discussed as the primary inferential tools rather than supplements.
- The paper should report a minimum detectable effect (MDE) calculation. Given the standard errors, what is the smallest effect the design could reliably detect at conventional significance levels? If the MDE is, say, 8-10 log points, the paper should be transparent that it cannot rule out economically meaningful effects of smaller magnitude.
- The divergence between the TWFE estimate (-0.068) and the CS ATT (-0.028) is notable. While some attenuation of the CS estimate relative to TWFE is expected when there is treatment effect heterogeneity, the gap here is large enough to warrant a focused discussion. Is this driven by particular cohorts? Negative weights? The paper should decompose this difference.

**Required:** Add MDE analysis. Elevate RI and bootstrap inference. Discuss the TWFE-CS gap more thoroughly.

### 3. Event Study Interpretation and Pre-Trends

The paper reports an event study showing growing negative effects over post-treatment horizons. Several concerns arise:

- Are pre-treatment coefficients precisely estimated zeros? The paper should present and discuss formal pre-trend tests (e.g., joint F-test on pre-treatment coefficients).
- Growing negative effects over time could reflect either genuine dynamic treatment effects or confounding trends that emerge post-treatment. The paper needs to address this identification concern more directly. What state-level confounders might generate this pattern?
- How sensitive is the event study pattern to the exclusion of specific cohorts, particularly the earliest adopters (Colorado, Washington)?

**Required:** Strengthen pre-trend analysis with formal tests and discuss robustness of the event study pattern to cohort composition.

---

## Minor Issues

### 4. Literature Gaps

The paper would benefit from engaging with several additional literatures:

- **Marijuana legalization and labor markets:** Chakraborty, Doremus, and Stith (2023) on employment effects; Sabia and Nguyen (2018) on labor supply. Business formation is downstream of labor market conditions.
- **Regulatory burden and entrepreneurship:** If legalization changes the regulatory environment (licensing requirements, compliance costs), this could affect business formation broadly, not just cannabis businesses. The paper should cite the regulatory burden literature (Djankov et al., 2002; Branstetter et al., 2014).
- **Cannabis industry-specific business dynamics:** Hansen, Miller, and Weber (2020) on crime; Chu and Gershenson (2023) on related market effects. These provide context for the mechanisms.

**Suggested:** Expand the literature review to situate the contribution relative to these adjacent literatures.

### 5. Robustness to Sample Restrictions

- The paper mentions excluding COVID years as a robustness check. Does the main result survive restricting to 2005-2019 only? This is important because the bulk of treatment variation is post-2018.
- How sensitive are results to excluding the 2024 cohort (Ohio), which has only one post-treatment year?
- The medical marijuana control analysis is mentioned but should be discussed in more detail. Which states had medical but not recreational programs? How does the comparison group change?

**Suggested:** Provide additional detail on these robustness exercises.

### 6. Outcome Variable Construction

- Log per-capita transformations require discussion of zeros. Are there any state-year cells with zero applications? If so, how are they handled?
- The annualization from monthly BFS data should be described more precisely. Is it a simple sum? Average? Does seasonality matter?

**Suggested:** Clarify data construction details.

### 7. Presentation

- At 34 pages, the paper is appropriately sized but could tighten some sections. The institutional background on marijuana legalization is somewhat longer than necessary for an audience familiar with the policy landscape.
- Tables should include mean of the dependent variable for reference.

**Suggested:** Minor tightening of institutional background; add dependent variable means to tables.

---

## Strengths

To be clear, this paper has real strengths that should be acknowledged:

1. **Methodological rigor.** The dual TWFE + Callaway-Sant'Anna approach is the current standard for staggered DiD, and the paper applies it correctly.
2. **Inference.** Providing both RI and pairs cluster bootstrap is above-average for applied work and shows awareness of the challenges of clustered inference with moderate N.
3. **Data.** The Census BFS is a high-quality, nationally representative data source that is well-suited to this question.
4. **Honesty about results.** The paper does not oversell borderline-significant results and is appropriately cautious about the BF8Q limitation. This scientific integrity is appreciated.
5. **Clear writing.** The paper is well-organized and clearly written throughout.

---

## Decision: MAJOR REVISION

The paper presents a sound empirical design applied to an interesting policy question with appropriate data. The core methodology (TWFE + CS DiD with inference diagnostics) is well-executed. However, the treatment of the BF8Q outcome needs substantial revision to prevent causal misinterpretation, the power analysis is insufficient for a paper operating in a moderate-power regime, and the event study discussion needs strengthening. I recommend major revision with particular attention to the three major issues identified above. I expect a revised version could be brought to publishable quality.
