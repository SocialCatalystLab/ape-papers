# Reply to Reviewers — Round 1

## Referee 1 (GPT-5-mini)

**On placebo test and identification (Critical):**
> "Pre-FOMC employment growth is positively and significantly correlated with contemporaneous shocks... This is a major concern."

We share the referee's concern and have implemented two responses. First, we now present an "augmented shock" robustness check: we regress JK shocks on lagged macro fundamentals and use the residuals as cleaned shocks. The main results survive this orthogonalization. Second, we have strengthened the framing by noting that the bias direction is toward zero (the Fed tightens into strong labor markets, so the identified response understates the true contractionary effect). We have also systematically replaced causal language with associational framing throughout.

**On 95% confidence intervals:**
> "Main results lack 95% CIs."

We have added 95% CIs to all main IRF figures and report 95% CI bounds in table notes. We retain 68% and 90% bands per monetary VAR convention but add 95% as the outermost band.

**On cross-sectional dependence and clustering:**
> "Residuals will be cross-sectionally dependent... two-way clustering or wild cluster bootstrap needed."

We now report cluster counts (13 industries) in all panel tables. We acknowledge that 13 clusters is small for cluster-robust inference and note this limitation. We add a Driscoll-Kraay SE check in the appendix. With a common shock and 13 cross-section units, the binding constraint is the time-series dimension, which the HAC bandwidth addresses.

**On cumulative effects:**
> "Report cumulative effect (0-12, 0-24) and trough with 95% CIs."

Added cumulative effects (sum of coefficients 0-12 and 0-24) with 95% CIs to Table 2.

**On multiple testing:**
We emphasize the cumulative and trough estimates as primary, and note that the pattern of significance across horizons should be interpreted as a whole rather than at individual horizons.

**On missing references:**
Added Plagborg-Moller & Wolf (2021), Cameron et al. (2008), and others as suggested. We do not add Callaway & Sant'Anna or Goodman-Bacon as these are DiD-specific and not directly applicable to our LP framework.

---

## Referee 2 (Grok-4.1-Fast)

**On placebo failure:**
> "Placebo failure is a core weakness—emphasize in abstract/conclusion as limiting causality."

Done. Abstract now reads "responses to the identified monetary policy shock component" rather than implying causality. Conclusion frames all results as conditional on the identification assumption.

**On missing references:**
> Sun & Zhuravskaya (2022), Caldara & Iacoviello (2022), Ottonello & Winberry (2020).

Added Ottonello & Winberry (2020) with discussion in Section 2.1 distinguishing firm-level from industry-level heterogeneity. We note Caldara & Iacoviello as an alternative shock measure in the robustness discussion.

**On model derivations:**
> "Shorten model derivations to appendix-only."

The main text already keeps derivations minimal, with full details in Appendix A. No change needed.

**On framing:**
> "Lead abstract/conclusion with cyclicality (not goods-services)."

Revised to emphasize cyclicality as the primary finding, with the goods-services binary as a secondary, more nuanced result.

---

## Referee 3 (Gemini-3-Flash)

**On augmented shock approach:**
> "Regress JK shocks on macro-fundamentals and use residuals."

Implemented. We regress JK shocks on 4 lags of employment growth, inflation, and IP growth, then use residuals as the shock measure. The main aggregate and interaction results survive with similar magnitudes and significance.

**On state-level variation:**
> "Adding state CES data would significantly strengthen identification."

We agree this would strengthen the paper and note it prominently as future work. The current national-level analysis establishes the cross-industry patterns that state-level analysis could further exploit.

**On TANK extension:**
> "Adding hand-to-mouth component would amplify welfare losses."

Acknowledged as a limitation. We note in Section 8 that incomplete-markets extensions would likely amplify the distributional consequences, making our complete-markets estimates conservative.
