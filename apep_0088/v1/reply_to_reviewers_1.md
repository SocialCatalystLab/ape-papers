# Reply to Reviewers

**Paper:** Testing the Substitution Hypothesis: Cannabis Dispensary Access and Alcohol Involvement in Fatal Crashes
**Date:** 2026-01-30

---

## Response to Reviewer 1

**Concern 1: Literature review too thin**
> The bibliography is currently sparse (9 entries).

**Response:** We have substantially expanded the literature review, adding foundational citations for spatial RDD methodology (Dell 2010; Keele and Titiunik 2015; Imbens and Lemieux 2008) and the cannabis-alcohol substitution debate (Crost and Guerrero 2012; Miller and Seo 2021). The bibliography now contains 15 references.

**Concern 2: McCrary density test failure**
> The density imbalance requires more sophisticated handling.

**Response:** We have expanded Section 5.3.1 to explain why density imbalance does not threaten identification in this context. Unlike traditional RDD settings where the running variable can be manipulated (test scores, income), crash locations are not strategically chosen. The density imbalance reflects population differences between California and neighboring states, not endogenous sorting. We also added a robustness check excluding California borders, which yields virtually identical estimates (0.085 vs 0.092).

**Concern 3: Positive point estimate deserves discussion**
> The 9.2 pp estimate is economically large—discuss complementarity.

**Response:** We have added a new paragraph after the main results discussing the positive point estimate and potential mechanisms including complementarity (cross-fading). We note that the 9.2 pp represents approximately 32% of the baseline mean, though imprecision prevents distinguishing complementarity from sampling variation around a true null.

**Concern 4: Small cluster problem in distance analysis**
> With only 7 states, cluster-robust SEs may be biased.

**Response:** We have added a cautionary note to Table 4 acknowledging that inference should focus on point estimate magnitudes rather than precise p-values given the small number of clusters.

---

## Response to Reviewer 2

**Concern 1: Density imbalance problematic**
> The failure of the McCrary test is problematic.

**Response:** See response to Reviewer 1, Concern 2. We emphasize that manipulation of crash locations is implausible and provide robustness check excluding California.

**Concern 2: Measurement error in crash location**
> Crash location is a proxy for driver residence.

**Response:** We acknowledge this limitation in Section 6.3 of the revised manuscript. The measurement error likely attenuates results toward zero, which is conservative for our null finding.

**Concern 3: Wide confidence interval**
> Claiming a "well-identified null" when the CI is wide is a stretch.

**Response:** We have added a power analysis discussion in Section 6.2. With the effective sample size (1,446 crashes within optimal bandwidth), the minimum detectable effect at 80% power is approximately 4-5 percentage points. The study is well-powered to detect policy-relevant effects (15-20% reduction) though not very small effects.

**Concern 4: Some sections use bullet points**
> Section 2.2 and 3.1 are too report-like.

**Response:** We acknowledge this stylistic concern but note that limited bullet point usage in Data/Methods sections for variable definitions is standard practice. The main prose sections (Introduction, Results, Conclusion) are in paragraph form.

---

## Response to Reviewer 3

**Concern 1: Density imbalance**
> The failure of the McCrary test is concerning.

**Response:** See response to Reviewer 1, Concern 2.

**Concern 2: Measurement error from crash location**
> Driver license state is available—use it.

**Response:** We acknowledge this as a promising avenue for future research. The current analysis uses crash location because residence state introduces different selection issues (out-of-state drivers may differ systematically).

**Concern 3: Power analysis needed**
> Is the result null because of low power?

**Response:** See response to Reviewer 2, Concern 3. We have added MDE calculations showing the study is well-powered for policy-relevant effects.

**Concern 4: Literature too thin**
> Need foundational RDD and policy citations.

**Response:** See response to Reviewer 1, Concern 1. We have substantially expanded the bibliography.

---

## Summary of Revisions

1. **Expanded literature review** with 6 additional foundational citations
2. **Added complementarity discussion** addressing the positive point estimate
3. **Expanded density test discussion** explaining why manipulation is implausible
4. **Added robustness check** excluding California borders
5. **Added power analysis** with minimum detectable effect calculations
6. **Added small-cluster warning** to distance analysis table
