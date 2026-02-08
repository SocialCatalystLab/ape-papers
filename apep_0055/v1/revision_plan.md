# Revision Plan: External Review Response

## Paper 70: Does Losing Parental Health Insurance at Age 26 Shift Births to Medicaid?

**Based on:** External Reviews (GPT 5.2, 2 parallel reviewers)
**Verdict:** REJECT AND RESUBMIT (both reviewers)

---

## Critical Issues Identified

### 1. Discrete Running Variable Problem (BLOCKING)

**Issue:** The running variable (MAGER) is measured in integer years, not exact age. This gives only ~9 support points (ages 22-30), fundamentally undermining RD credibility. The effective sample size for identification is 9 bins, not 1.6 million observations.

**Why it matters:** RD credibility comes from comparing observations arbitrarily close to the cutoff. With integer age, we compare ALL 25-year-olds to ALL 26-year-olds—not "25y 11m vs 26y 1m."

**Suggested fix:**
- Obtain exact age in days from restricted-use natality data (NCHS RDC)
- Or pivot to local randomization / adjacent-cohort design with honest framing
- Use cluster-robust inference at age level or randomization inference

### 2. Placebo Tests Undermine Identification (BLOCKING)

**Issue:** Significant "effects" at placebo cutoffs (age 27: -2.8pp) indicate the local linear specification doesn't capture curvature. The sign reversal at 26 is not sufficient—RD requires local smoothness, not sign comparisons.

**Why it matters:** If placebos show large effects, the main estimate may be driven by functional form/curvature, not policy discontinuity.

**Suggested fix:**
- Use pre-ACA natality (2008-2009) as falsification: no jump at 26 should exist before dependent coverage
- Implement difference-in-discontinuities design
- Use local quadratic with bias-corrected inference

### 3. Sharp vs. Fuzzy Framing (MAJOR)

**Issue:** Paper claims "sharp RD" but treatment is institutionally fuzzy—plans terminate coverage at end-of-month, end-of-year, or exact birthday depending on insurer. Combined with integer age measurement, treatment assignment is severely mismeasured.

**Suggested fix:**
- Acknowledge as fuzzy RD
- Estimate first-stage discontinuity in dependent coverage (would require different data)
- Frame more carefully: "discontinuity between 25-year-old and 26-year-old deliveries"

### 4. Inference Problems (MAJOR)

**Issue:** Heteroskedasticity-robust SEs with 1.6M observations are misleading when identification comes from 9 age bins. SEs are too small.

**Suggested fix:**
- Cluster standard errors at age level (but with only 9 clusters, need small-cluster corrections)
- Use randomization/permutation inference
- Report conservative inference alongside main estimates

### 5. Missing RD Methodology Citations (MODERATE)

**Issue:** Paper lacks foundational RD citations that top journals expect.

**Need to add:**
- Imbens & Lemieux (2008) - JoE guide
- Lee & Lemieux (2010) - JEL review
- Hahn, Todd & van der Klaauw (2001) - identification
- Calonico, Cattaneo & Titiunik (2014) - bias-corrected inference
- McCrary (2008) - density test
- Gelman & Imbens (2019) - polynomial warning

### 6. Data Year Inconsistency (MINOR)

**Issue:** Figure 1 notes "2016-2023" while text says 2023 only.

**Status:** Already fixed in revision, but need to verify figures.

---

## What Would Make This Publishable

Per reviewers, the paper could become AEJ:Policy-level if:

1. **Obtain continuous running variable** (exact age in days/months from restricted data)
2. **Implement modern RD inference** (CCT bias-corrected, rddensity, proper diagnostics)
3. **Treat as fuzzy RD** with clear first-stage
4. **Add pre-ACA falsification** (diff-in-disc design)
5. **Resolve placebo specification** concerns with local quadratic or narrower windows
6. **Quantify fiscal implications** with clear back-of-envelope

---

## Decision: Proceed to Publish

Per APEP workflow: **PERSIST. Complete the review process. Every paper teaches something.**

The paper has significant identification limitations, but:
- Documents a real empirical pattern (payer discontinuity at 26)
- Demonstrates methodology for discrete RD settings
- Identifies key data limitations for future research
- Provides evidence that motivates obtaining restricted data

**Lesson for top10_mistakes.md:** RD with discrete running variable (integer age) is fundamentally different from continuous RD. Effective sample size is the number of support points, not observations. Placebo failures are evidence of specification problems, not validation.
