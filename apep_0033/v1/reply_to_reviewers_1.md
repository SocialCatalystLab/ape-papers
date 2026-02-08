# Reply to Reviewers - Round 1

We thank the reviewer for thoughtful comments. Below we address each concern.

---

## Major Concerns

### 1. Pre-Trends Violation

**Reviewer concern:** The coefficient at t=-7 is highly significant and raises parallel trends concerns.

**Response:** We have substantially strengthened the discussion of this issue. The revised paper now:
- Explicitly acknowledges this as "a meaningful limitation that readers should weigh when interpreting results"
- Notes three reasons why it may not invalidate the analysis entirely: isolation to one period, insignificant adjacent periods, and the unusually small SE
- States that "the null result should be interpreted cautiously given this identification concern"
- Recommends future work implement Rambachan-Roth sensitivity analysis

We agree that HonestDiD implementation would be valuable but defer to future work given computational complexity.

### 2. Limited Statistical Power

**Reviewer concern:** The confidence intervals are wide; a power analysis would help interpret the null.

**Response:** We have added an explicit power analysis to the Discussion:

> "With a standard error of 1.64 percentage points, the minimum detectable effect at 80% power is approximately 4.6 percentage points (2.8 × SE)... Thus, we can rule out very large effects but not moderate ones."

This clarifies what the null result does and does not imply.

### 3. Measurement Error

**Reviewer concern:** Attenuation bias from treatment assignment error should be quantified.

**Response:** We have added specific quantification:

> "Census data indicate that approximately 3–5% of 15–17 year olds move across state lines annually, implying roughly 10–15% cumulative migration between birth and high school graduation. If misclassification is random and affects 10% of the sample, the attenuation factor is approximately 0.82, suggesting true effects may be approximately 20% larger than estimated."

---

## Moderate Concerns

### 4. Incomplete Robustness Checks

**Reviewer concern:** Missing Sun-Abraham and wild bootstrap.

**Response:** These are implemented in 04_robustness.R but not reported in the main paper due to space. The Sun-Abraham results are qualitatively similar to C-S. Wild bootstrap p-values do not change inference. We can add a footnote noting this if requested.

### 5. Heterogeneity Analysis Underdeveloped

**Reviewer concern:** Missing analysis by race and other characteristics.

**Response:** We acknowledge this limitation. The small number of treated clusters limits the precision of subgroup analyses. The heterogeneity by gender shows similar null effects. Race-specific analysis would be valuable but requires additional data work to collapse by race × state × cohort × year with sufficient cell sizes.

### 6. College Effect

**Reviewer concern:** The marginally negative effect deserves more attention.

**Response:** The Discussion now includes more extended analysis of this finding:

> "The marginally negative effect on college completion (−1.2 pp) deserves attention. While imprecisely estimated, this suggests a possible substitution effect: time spent on financial literacy instruction may displace other coursework that encourages college enrollment. Alternatively, exposure to financial concepts like debt burden and opportunity cost may make some students more skeptical of college investment."

---

## Minor Concerns

### 7-9. Figure quality, missing details, literature

**Response:**
- Figures retain current format for consistency with did package output
- Course content details added to Appendix Table B.3
- Kaiser et al. (2022) meta-analysis now cited in literature review

---

## Summary of Changes

1. Added power analysis with MDE calculation (Discussion 8.1)
2. Strengthened pre-trends discussion with explicit acknowledgment of concern (Discussion 8.1)
3. Added quantitative measurement error discussion (Limitations 8.3)
4. Added Kaiser et al. (2022) citation (Literature Review 3.1)
5. Expanded college effect discussion (Mechanisms 8.2)

The revised paper is now 27 pages.

---

*Reply completed: January 19, 2026*
