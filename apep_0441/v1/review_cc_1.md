# Internal Review -- Round 1

**Paper:** "Smaller States, Bigger Growth? Two Decades of Evidence from India's State Bifurcations"
**Reviewer:** Reviewer 2 (harsh) + Editor (constructive)
**Date:** 2026-02-22

## Verdict: Minor Revision

The paper asks a genuinely important question -- whether creating smaller subnational units accelerates economic development -- and studies it in a compelling setting (India's 2000 trifurcation). The writing is strong, the institutional background is excellent, and the author deserves real credit for the unusual degree of honesty about identification failures. However, the paper has substantive methodological limitations that, while mostly acknowledged, need sharper treatment before the analysis can support the weight the discussion places on it.

---

## Major Concerns

1. **The pre-trends violation is more damaging than the paper lets on.** The author commendably flags the parallel trends failure (p = 0.005) throughout the paper and calls it a "first-order feature." But the paper then proceeds to interpret the results as if they are informative about the causal effect of state creation, offering "optimistic" versus "skeptical" interpretations (Section 8.1) and drawing policy implications (Section 8.3). If the identifying assumption is decisively rejected, the DiD estimates -- including the CS-DiD ATT of 0.29 -- have no clean causal interpretation. The paper should be more disciplined about what can and cannot be learned from estimates whose identifying assumption fails. Specifically, the placebo test coefficient of 0.25 (Section 6.1) is roughly comparable to the CS-DiD ATT of 0.29, which should alarm the author: the "treatment effect" is of similar magnitude to what convergence alone produces in a placebo window. This comparison deserves prominent discussion.

2. **Six state clusters is a fundamental constraint that cannot be fully remedied.** The paper acknowledges this but still presents conventional clustered standard errors as the primary inference method, supplemented by wild bootstrap (p = 0.066) and RI (p = 0.05). With 6 clusters (3 treated, 3 control), even the wild cluster bootstrap is operating at the very edge of its validity -- Cameron, Gelbach, and Miller (2008) recommend a minimum of around 10 clusters. The RI test has a minimum achievable p-value of 0.05, so the "borderline significant" result is actually the most extreme possible outcome -- this is not borderline evidence, it is literally the strongest possible rejection with this test. The paper should state clearly that with 3 treatment events, there is insufficient statistical information to draw general conclusions about the effect of state creation. The paper's external validity claims should be tempered accordingly.

3. **The TWFE vs. CS-DiD discrepancy (0.80 vs. 0.29) is underexplored.** The paper attributes this gap to "the heterogeneity-robust estimator's accounting for differential treatment timing and effect heterogeneity" (Section 5.1). But all three bifurcations occurred simultaneously in November 2000 -- there is no staggered adoption. So the standard explanation for TWFE bias from heterogeneous treatment effects across cohorts does not apply. The paper needs a clearer explanation of why these estimators diverge so dramatically in a single-cohort setting. Possibilities include: (a) different weighting of pre- versus post-treatment periods, (b) different handling of the pre-trend, or (c) the CS estimator using never-treated units as controls differently from TWFE. Without understanding why the estimates differ by a factor of nearly 3x, the reader cannot assess which (if either) is credible.

4. **The pair-specific heterogeneity regressions (Table 4) have 2 clusters each.** Estimating separate DiD regressions for each parent-child pair means clustering at the state level with only 2 clusters. This renders the standard errors meaningless -- the t-statistics and significance stars in Table 4 are not interpretable under any standard asymptotic or finite-sample theory. The paper should either drop significance stars from Table 4 entirely or present the pair-specific results purely as descriptive decompositions without inference.

5. **Missing: HonestDiD or trend-extrapolation bounds.** Given the clear pre-trend violation, the natural next step is to implement Rambachan and Roth (2023) HonestDiD bounds that allow for violations of parallel trends up to some degree of nonlinearity. The paper identifies the problem but does not use the most appropriate tool available for bounding the treatment effect under trend deviations. This is a significant omission given that the `HonestDiD` R package is widely available and directly applicable.

---

## Minor Concerns

1. **The abstract leads with the CS-DiD ATT of 0.29 but the main results table leads with the TWFE of 0.80.** This creates a disconnect. The abstract wisely foregrounds the more conservative estimate, but the body of the paper gives the TWFE estimate more prominence (it occupies Column 1 of Table 2 and is the number used for RI and wild bootstrap). The paper should be consistent about which estimate it considers the "headline" result.

2. **The extended panel (Section 6.4) conflates DMSP and VIIRS measurements.** The district-specific calibration ratios computed from the 2012-2013 overlap are a reasonable approach, but the paper does not assess how much measurement error this introduces. A simple sensitivity check -- e.g., restricting to the DMSP-only period and showing the treatment effect is stable -- would strengthen this section. The extended panel coefficient (0.70) is presented without a standard error in the text, only in Table 3 (0.6958, SE = 0.2903). This should be reported consistently.

3. **The Telangana analysis (Section 6.5) adds little.** With only 2 pre-treatment years and a fundamentally different setting (Telangana inherited Hyderabad), this is not a useful validation exercise. The paper acknowledges this, but including it risks padding the robustness section without adding substantive information. Consider relegating it entirely to the appendix or dropping it.

4. **The mechanisms discussion (Section 7.4) is entirely speculative.** Five mechanisms are proposed -- fiscal decentralization, administrative proximity, political voice, identity/aspiration, and institutional capacity -- but none is formally tested. The paper should be explicit that these are interpretive frameworks, not tested channels. The fiscal channel, for instance, could be quantified using Finance Commission data on actual per capita transfers before and after bifurcation.

5. **The Sun-Abraham estimator (Section 6.6) is irrelevant and the paper knows it.** With a single treatment cohort, the SA estimator is numerically identical to TWFE by construction (or nearly so). Including it as a "robustness check" when the paper itself explains why it should not matter is filler.

6. **Bibliography is thin.** Only 13 references for a paper claiming contributions to multiple literatures (fiscal federalism, political economy of India, econometric methodology). Key missing references include: Rambachan and Roth (2023) on HonestDiD, de Chaisemartin and D'Haultfoeuille (2020) on TWFE decomposition, Asher and Novosad (2020) on nightlights in India, Iyer (2010) on colonial institutions in India, and the broader literature on state creation in developing countries.

7. **Figure numbering in the PDF does not match the LaTeX labels.** The LaTeX uses `fig2_event_study.pdf` but the PDF shows "Figure 1" for the event study. This suggests automated figure numbering, which is fine, but the cross-references should be verified.

8. **The log(NL + 1) transformation.** While standard, the +1 addition creates a nonlinearity at the bottom of the distribution that disproportionately affects the darkest districts -- which are overrepresented in the treatment group. An inverse hyperbolic sine transformation or Poisson pseudo-maximum likelihood specification would be preferable as robustness checks.

---

## Suggestions

1. **Implement HonestDiD bounds.** This is the single most impactful revision. Use the Rambachan and Roth (2023) framework to construct confidence sets under various assumptions about the degree of nonlinearity in the pre-trend. If the bounds include zero under reasonable extrapolation of the pre-trend, say so. If they exclude zero, that would substantially strengthen the paper's conclusions.

2. **Compute a back-of-the-envelope trend-adjustment.** The pre-treatment coefficients follow a roughly linear path from -0.66 (k=-7) to -0.31 (k=-2). Extrapolating this trend into the post-period and subtracting it from the post-treatment event study coefficients would provide a simple bias-corrected estimate. Even if rough, this would help the reader assess whether the acceleration after 2000 exceeds what the pre-existing trend would predict.

3. **Present the placebo coefficient (0.25) alongside the CS-DiD ATT (0.29) prominently.** This comparison is devastating for the causal interpretation and should appear in the introduction, not just in Section 6.1.

4. **Expand the bibliography.** A paper of this scope, touching fiscal federalism, Indian political economy, nightlights methodology, and modern DiD econometrics, should engage with at least 25-30 references.

5. **Consider a spatial RDD at the new state boundary.** Districts adjacent to the new state boundary share geographic proximity but different governance post-2000. A border-district analysis, while reducing the sample, would provide a sharper identification strategy that does not rely on parallel trends across the entire state.

6. **Report the effective number of treated clusters prominently.** The paper should include a prominent statement -- perhaps boxed or bolded -- that the analysis has exactly 3 independent treatment events, and that no amount of econometric sophistication can overcome this fundamental limitation for external validity.

7. **Add a power calculation.** Given the small number of clusters, what is the minimum detectable effect? This would contextualize whether the null result for Jharkhand reflects genuine absence of effect or simply lack of power.
