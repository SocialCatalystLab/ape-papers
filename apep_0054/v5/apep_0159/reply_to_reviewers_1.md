# Reply to Reviewers - External Review Round 1

**Date:** 2026-02-04
**Paper:** "Shining Light on Paychecks: The Effects of Salary Transparency Laws on Wages and the Gender Pay Gap"

---

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

### Concern 1: Bootstrap vs. Permutation p-value discrepancy
> "The asymmetry between bootstrap and permutation p-values for the gender DDD (bootstrap p = 0.004, Fisher permutation p = 0.11) is a red flag."

**Response:** We have added a detailed paragraph in Section 6.12 (Fisher Randomization Inference) explaining why these two methods produce different p-values. The bootstrap analytically adjusts cluster-robust standard errors using the Webb 6-point distribution on collapsed state-year-gender cells, while the permutation re-estimates the full TWFE model under each random reassignment of treated states. The permutation approach has lower power because: (1) it tests the sharp null of zero effect for all units, a stronger null than the bootstrap's weak null; (2) with only 6 treated states and 5,000 draws, the discrete permutation distribution has limited resolution; and (3) the TWFE approximation used in permutations is less efficient than the analytical bootstrap. Both methods provide evidence against the null, though the permutation result is suggestive rather than decisive. We have tempered all "highly significant" language throughout the paper.

### Concern 2: Pre-trend coefficients at t-3 and t-2
> "Two individually significant pre-treatment coefficients undermine the credibility of the parallel trends assumption."

**Response:** We have added a footnote reporting the joint Wald test of all five pre-treatment coefficients ($\chi^2(5) = 10.2$, $p = 0.069$), which is marginal at the 10% level. We note that the oscillating pattern (positive at t-3, negative at t-2) is inconsistent with a monotonic violation and more consistent with sampling variation given only 6 treated clusters. The HonestDiD sensitivity analysis directly incorporates these pre-treatment deviations into the confidence intervals, and we reference this throughout the pre-trends discussion. Cohort-specific event studies are an important suggestion for future work but are limited by the small number of treated states per cohort.

### Concern 3: Overclaiming
> "Do not call the gender result 'highly significant' if permutation p>0.05."

**Response:** We have removed all instances of "highly significant" and "highly robust" from the paper. The abstract, introduction, results, discussion, and conclusion now use precise language: "statistically significant at the 1% level" for asymptotic inference, "bootstrap p = 0.004" for design-based inference, and "permutation p = 0.11, suggestive rather than decisive" for randomization inference. The overall framing now acknowledges that evidence is strong under bootstrap inference but more moderate under permutation.

### Concern 4: Compliance/TOT
> "Readers will want an estimate of the treatment-on-treated effect."

**Response:** We have added a paragraph in the Limitations section providing back-of-envelope TOT estimates under assumed compliance rates of 60-90%, yielding gender DDD TOT estimates of 5.1-7.7 percentage points. We acknowledge this is a rough calculation and note that direct measurement using job-posting data (Burning Glass, Indeed) would enable formal IV estimation.

### Concern 5: Missing references
> "Bertrand, Duflo & Mullainathan (2004) on serial correlation."

**Response:** Added and cited in Section 6.11 (Collapsed-Cell Wild Cluster Bootstrap) alongside the existing Cameron et al. (2008) and Conley and Taber (2011) citations. The Imbens & Lemieux (2008) and Lee & Lemieux (2010) references are not cited as they address RDD rather than DiD methods.

### Concern 6: Weighting and collapsing
> "Collapsing with weights can change the estimand."

**Response:** The collapse uses unweighted state-year-gender cells, which weights each cell equally regardless of population. This differs from the individual-level estimates that weight by ASECWT. We note this in the paper as a limitation of the collapsed approach but emphasize that the purpose is inference testing rather than point estimation — the collapsed bootstrap p-values test the null of zero effect, and the point estimates from the preferred individual-level specification remain the primary results.

---

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Concern 1: AI generation footnote
> "Top journals may query."

**Response:** This footnote is required by the APEP project infrastructure and accurately reflects the paper's provenance. We maintain it for transparency.

### Concern 2: Integrate Kroft et al. (2024) citation
**Response:** Kroft et al. (2024) is already in the bibliography and cited. We have not added additional discussion as the paper is a working paper without published details to engage with substantively.

### Concern 3: Synthetic control for aggregate effect
**Response:** This is a valuable suggestion. The aggregate ATT is already acknowledged as marginal and imprecisely estimated; synthetic control methods could provide an alternative visualization but are unlikely to change the substantive conclusion given the small number of treated units and marginal effect size. We note this as a direction for future work.

---

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: High-bargaining occupation shift
> "Suggest a 'Leaver-Stayer' analysis."

**Response:** The composition tests (Table 13) show a 2 percentage point shift into high-bargaining occupations (p=0.012). We discuss this as potentially consistent with a mechanism story: transparency enables workers—particularly women—to identify and transition to higher-bargaining occupations where salary information was previously opaque. A leaver-stayer analysis would require linked panel data (e.g., LEHD); the repeated cross-section CPS ASEC does not identify individuals across years. We note this as a limitation.

### Concern 2: Contextualize magnitude against residual gap
**Response:** The paper notes that the 4.6-6.4 percentage point reduction corresponds to approximately half of the residual gender wage gap (the gap remaining after controlling for education, experience, and occupation). This contextualization is provided in the Introduction (paragraph 4) and Discussion section.

### Concern 3: Synthetic control or restricted donor pool
**Response:** As noted in our response to Reviewer 2, synthetic control methods are a valuable complementary approach. We acknowledge this in the limitations and future work discussion. The current DiD framework with Callaway-Sant'Anna estimators and extensive robustness checks provides credible identification for the gender gap result.
