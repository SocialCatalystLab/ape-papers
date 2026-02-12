# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T14:37:30.066583
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 30777 in / 6122 out
**Response SHA256:** ac8c02056fa2bb13

---

Thank you for the opportunity to review this carefully crafted and timely paper. The topic is important, the comparison between the Great Recession and the COVID shock is interesting, and the combination of cross-state reduced-form LPs with a structural DMP model is a plausible way to link facts to mechanisms. Below I give a detailed, constructive review organized along the requested checklist: format, statistical methodology, identification, literature, writing quality, robustness / constructive suggestions, and an overall assessment and decision.

Summary (one-paragraph)
- The paper documents that (i) cross-state exposure to the housing boom predicts persistent employment losses after the Great Recession (negative LP coefficients that remain significant out to 60–84 months); (ii) cross-state industry exposure (Bartik) predicts large but short-lived employment losses in COVID that dissipate by ~18 months. A calibrated search-and-matching model with endogenous participation and skill depreciation rationalizes the asymmetry: demand shocks reduce hiring and lengthen durations leading to scarring; supply shocks are transient and do not produce scarring. The author(s) support the reduced-form evidence with a variety of robustness checks and use the model for counterfactuals and welfare calculations.

1) FORMAT CHECK
- Length: The LaTeX source is long. Excluding references and appendices, the main text clearly exceeds 25 pages (I estimate ~35–45 pages of main text plus appendices and tables/figures). So length is adequate for a top general-interest submission.
- References: The bibliography cited many relevant contributions across hysteresis, regional adjustment, COVID labor market research, and shift-share methods. However, a few central methodological and applied references are missing (see Section 4 below for explicit additions with BibTeX).
- Prose: Major sections (Introduction, Institutional Background, Conceptual Framework, Data, Empirical Strategy, Results, Mechanisms, Model, Robustness, Conclusion) are written as paragraphs—not bullets. Good.
- Section depth: Each major section contains multiple substantive paragraphs. Sufficient depth overall.
- Figures: From the LaTeX source I see figure includes (e.g., fig3_lp_employment_irfs.pdf). The figures as referenced appear to show data and are described with axes and legends in the captions. (I did not render the PDF here, but the code and captions indicate proper plotting.)
- Tables: The document includes tables with numbers and (in the appendix) standard errors. I did not see placeholder entries; tables appear substantive.

Minor format nits to fix before resubmission:
- Ensure every figure and table is directly referenced in the main text where appropriate (some figures are referenced, but confirm none are left unused).
- Add explicit table and figure numbers (e.g., Tab X, Fig Y) in the text when discussing magnitudes so readers can follow easily.
- Ensure the bibliography is compiled and includes all cited works (I could not confirm rendered refs from source).

2) STATISTICAL METHODOLOGY (CRITICAL)
This section is the most important. The paper must satisfy the inference standards expected by top journals.

What the paper does well:
- Reports sample sizes (N = 46 for Great Recession due to FHFA coverage; N = 48 for COVID).
- Uses local projections (Jordà) to estimate horizon-specific reduced-form effects—appropriate for tracing dynamics.
- Displays standard errors (HC1 robust) in tables and reports p-values for key coefficients.
- Performs permutation tests (random reassignment) to provide finite-sample inference and reports permutation p-values—this is a valuable robustness check given the small cross-sectional sample (46–48).
- Reports clustering by census division (9 clusters) in robustness and uses exposure-robust standard errors for the Bartik instrument (cites Adao et al., Borusyak et al.).
- Performs leave-one-out analyses and outlier exclusions.

Concerns / issues that must be addressed (these are material):
a) Terminology & causal claims: "Instrument" vs. reduced-form
- The manuscript sometimes calls the housing boom and Bartik measures “instruments,” but the main reported estimates are reduced-form LP regressions of outcomes on exposure (eq. (8)). If the paper claims causal identification, the language must be precise. Either:
  - Present and report a proper IV (first-stage and second-stage) strategy and associated diagnostics (first-stage F-statistics, exclusion restriction argument), or
  - Explicitly state that the results are reduced-form cross-sectional associations exploiting plausibly exogenous exposure and avoid implying that the regressors are used as instruments in a 2SLS sense.
- The paper currently mixes the terms; please clarify in the text and, if you prefer to remain with reduced-form LPs, replace "instrument" with "exogenous exposure measure" (or similar). If you want to instrument an endogenous local demand collapse variable using the housing boom, show the first-stage and explain the endogenous variable you intend to instrument.

b) Standard errors and small-sample inference
- You report HC1 SEs and permutation tests—good. But HC1 SEs are asymptotic and with N≈46 may be unreliable; permutation inference is useful but must be fully described in the main-methods and not only in an appendix.
- For shift-share/Bartik inference, exposure-robust SE is needed (you cite Adao et al. and Borusyak et al. and say you implement them). Please (i) report results using Goldsmith-Pinkham–Sorkin–Swift (GPS) adjustments (see missing citation below), (ii) explicitly present exposure-robust standard errors in main tables for the Bartik estimates, and (iii) include permutation p-values for the Bartik as well.
- The clustering by census division (9 clusters) is reported; but wild-cluster bootstrap with 9 clusters can be attempted (if feasible)—or if not, discuss its infeasibility and justify reliance on permutation methods.

c) Shift-share / Bartik inference
- You cite Borusyak (2022) and Adao (2019). You should also cite Goldsmith-Pinkham, Sorkin & Swift (2020, AER) and implement their recommended diagnostics for Bartik instruments (e.g., show the distribution of industry shocks, report the leave-one-out construction you use, and show robustness to alternative industry aggregation).
- Show first-stage strength of the Bartik instrument for the immediate impact and report cross-sectional R^2 and first-stage F if you move to a 2SLS formulation.

d) Cross-sectional identification and omitted variables
- The housing boom measure may be correlated with other determinants of long-run employment (e.g., industrial composition, population growth, housing supply elasticity, natural resource booms). You control for pre-recession employment growth and include some controls. But more must be done:
  - Present a baseline table showing how the housing boom correlates with pre-recession levels and changes in a battery of covariates (pop density, pre-trend employment growth, industry shares, median income, credit conditions).
  - Alternatively, implement a more flexible control set (e.g., include pre-recession trends as covariates or include principal components of pre-2007 state characteristics).
  - Run a covariate balancing / reweighting or a matching-on-pretrends robustness check: do the results hold in a restricted sample of states that were similar before the bust?
- Because you use cross-sectional LPs with one observation per state per horizon, there is limited scope to absorb unobserved state-level confounders. Address this explicitly in limitations and consider additional robustness (see constructive suggestions).

e) DiD/staggered adoption concerns: not directly applicable
- You do not use TWFE DiD with staggered adoption, so the specific TWFE concerns (Goodman-Bacon) are not fatal here. But when comparing episodes across time, ensure that you are not conflating composition changes driven by common shocks or national policies. You already discuss policy differences (ARRA vs CARES) but be explicit about limitations.

f) RDD not used: not applicable. No RDD-specific tests are needed.

To summarize the statistical-inference checklist:
- Standard errors are present. PASS for the minimum requirement that estimates have SEs.
- Significance testing / permutation inference is present. PASS but expand presentation (see above).
- 95% CIs: Figures report 95% CIs; ensure CIs are also shown in main tables or numbers are reported. PASS if included.
- Sample sizes reported for regressions (N=46/48). PASS.
- Staggered DiD: not used. N/A.
- RDD: not used. N/A.

3) IDENTIFICATION STRATEGY
Is identification credible? The central identification claim hinges on two cross-state, exogenous sources of variation:
- Housing boom (2003–2006) as exogenous demand exposure that predicts the severity of the Great Recession in a state.
- Bartik (2019 industry shares × national industry shocks during the pandemic) as exogenous exposure to the COVID shock.

Strengths:
- The housing-boom exposure is a well-used strategy in the literature (Mian & Sufi and follow-ups). The author(s) present pre-trend tests and outlier robustness checks.
- The Bartik construction uses leave-one-out national industry shocks and references the recent shift-share literature (Adao, Borusyak).
- Permutation and leave-one-out robustness checks are provided.

Main identification concerns and suggestions:
- Housing boom exogeneity: As noted above, housing price growth could reflect local demand booms or other attributes correlated with long-run employment. The paper offers pre-trend tests, but I recommend the following additional checks:
  1) Include additional pre-recession controls: 2000–2007 trend in employment, real wages, industry employment shares, housing supply elasticity proxies (Saiz 2010), measures of credit supply expansion (mortgage origination rates), and demographic controls. Show that results are robust.
  2) Instrumental strategy (optional): If you intend to interpret the housing boom as an instrument for local demand collapse, present a 2SLS estimation: first-stage: local employment decline during bust on housing boom; second-stage: long-run employment on predicted local demand collapse. Report first-stage F-stat, overidentification if possible, and LATE interpretation.
  3) Placebo outcomes: regress the housing boom on other long-run outcomes that should not be affected except through demand (e.g., long-run manufacturing employment changes in industries not related to housing or pre-recession land-use regulations) to probe potential channels.
- Bartik instrument concerns: As with any shift-share, need to ensure industry shocks are exogenous to state-level unobservables that affect recovery. You do leave-one-out and cite Adao and Borusyak, which is good. Add:
  1) Use GPS (Goldsmith-Pinkham, Sorkin & Swift) inference and present both conventional and exposure-robust standard errors.
  2) Show sensitivity to alternative industry aggregations and teleworkability-based exposure metrics (Mongey & Weinberg, Dingel & Neiman). This addresses the concern that industry shares proxy for urbanization / density which in turn affected COVID restrictions and recovery speed.
- Migration and composition: You discuss migration but do not control for state-level net migration flows. A robustness specification including net migration rates (or using place-of-work vs place-of-residence) would help. If the data do not permit this, stress this limitation and (ideally) run CPS/ACS-based migration adjustments or control for housing inventory changes.
- Policy endogeneity: States varied in policy responses (timing of lockdowns, unemployment supplements, PPP uptake). Some of these policies may be correlated with industry composition or housing exposure. Consider controlling for state-level policy stringency indices, or at a minimum discuss this potential confound more fully and report robustness excluding states with particularly idiosyncratic policy responses.

Placebo and mediation:
- The paper runs pre-trend and placebo permutation checks—good.
- I strongly recommend a mediation analysis: show that the long-run effect of housing exposure (on employment) is substantially attenuated when controlling for long-term unemployment share and labor force participation decline (this would be direct evidence that duration and participation mediate the exposure → employment relationship). The model predicts that controlling for duration should reduce the reduced-form effect.

4) LITERATURE (MISSING REFERENCES I RECOMMEND)
The paper engages the main literatures, but several highly-relevant methodological and applied papers should be explicitly cited and (in places) used for diagnostics:

- Goldsmith-Pinkham, Sorkin & Swift (2020, AER) — canonical paper on shift-share/Bartik inference that offers both diagnostic guidance and alternative inference procedures. Even if you cite Adao and Borusyak, GPS 2020 is expected in this literature.
  BibTeX:
  @article{GoldsmithPinkhamSorkinSwift2020,
    author = {Goldsmith-Pinkham, Paul and Isaac Sorkin and Henry Swift},
    title = {Bartik Instruments: What, When, Why, and How},
    journal = {American Economic Review},
    year = {2020},
    volume = {110},
    pages = {2584--2624}
  }

- Imbens & Lemieux (2008) and Lee & Lemieux (2010) for RDD best-practices (if you discuss RDD in methodology notes, though RDD is not used here). If not directly used, they aren't required.

- Autor, Dorn, Hanson & Song and Goldsmith-Pinkham et al. (for shift-share literature). You already cite Autor et al. (China shock) but be explicit in connecting methods.

- Jarosch, Kay, and others on scarring (you cite Jarosch 2023). Good.

- A couple more applied references that would strengthen framing:
  - Saiz, Albert (2010). “The Geographic Determinants of Housing Supply.” Quarterly Journal of Economics. (You cite Saiz 2010 in the background; good. BibTeX not necessary unless missing.)
  - Goldsmith-Pinkham may be the most important missing citation for the Bartik/inference side.

I include the GPS bibtex above. If you would like, I can provide additional BibTeX entries for other canonical references you cited (Callaway & Sant'Anna, Goodman-Bacon, Adao, Borusyak) — you cite many of them already.

Why these are relevant:
- GPS (2020) gives practical diagnostics and inference methods for shift-share instruments and is now standard when a Bartik is used. Since the paper leans on a Bartik for the COVID exposure, GPS must be invoked and their recommended diagnostics performed.
- Imbens/Lee/Lemieux are standard for RDD and methodological transparency; if you discuss RDD requirements in the checklist, reference them.

5) WRITING QUALITY (CRITICAL)
Overall the prose is high quality: clear motivation, crisp description of the two episodes, and logical flow from facts to mechanisms to model.

Specific notes and suggestions:
a) Prose vs bullets: The main sections are paragraph-based; good. The paper uses some small headline-style phrases (“Prediction 1...”)—these are fine.
b) Narrative Flow: Strong. The opening juxtaposition (two big recessions, different recoveries) is effective.
c) Sentence quality: Generally crisp and varied. A few sentences are long and could be tightened for clarity (e.g., the paragraph reporting welfare numbers could be split and the interpretation of CE losses clarified).
d) Accessibility: Technical terms are explained when introduced (e.g., LP, Bartik). Some econometric concepts (exposure-robust SE) could be given more intuition for non-specialists.
e) Tables: Mostly self-contained, but table notes should explicitly state the sample (number of states), the SE type (HC1, clustered, permutation), and the scaling (e.g., coefficients per log point or per standard-deviation increase). Some main tables use dollar or percent magnitudes—make sure units are clear.

Major writing recommendation:
- When discussing welfare numbers (CE losses of 33.5% vs 0.23% and a 147:1 ratio), add a careful note about interpretation and calibration sensitivity. Those numbers are startling and risk eliciting skepticism; briefly explain why they are so large (normalization, consumption concept, representative agent abstraction) and caution the reader about their quantitative realism. You do mention that the model abstracts, but a more explicit caveat when presenting the numbers would be helpful.

6) CONSTRUCTIVE SUGGESTIONS (analyses to strengthen the paper)
The paper is promising; the suggestions below would make it substantially stronger and increase its chance at a top journal.

Empirical robustness & identification
- Clarify "instrument" language: either present IV (with first-stage diagnostics) or stick with reduced-form exposure language and justify causal interpretation. If you present IV, report first-stage F statistics and show that exclusion restriction is plausible.
- Expand the pre-trend and placebo analyses: show event-study style pre-trend figures (coefficients at h = -36, -24, -12 months) with CIs to be fully convincing that pre-trends are flat.
- Mediation analysis: Show that including mediators (long-term unemployment share, mean duration, change in LFPR) attenuates the housing exposure coefficient at long horizons. This would directly support the model mechanism.
- Migration controls: Include net migration changes (ACS or CPS-based) as covariates, or show that results are robust to controlling for net migration flows; at a minimum, quantify how much of state employment losses could plausibly be due to migration.
- Policy controls: Add controls for state-level policy responses during COVID (timing of lockdowns, PPP loan per capita, state-level UI top-ups) to probe whether differential policies drove recovery speed heterogeneity.
- First-stage for housing instrument: If the housing boom is to be treated as an instrument for local demand collapse, report the first-stage regression (housing boom → measured local demand collapse during 2007–2009) and its F-statistic.
- Bartik diagnostics: Implement GPS diagnostics, show distribution of industry shocks and correlation of industry shocks with pre-trend covariates; report exposure-robust SEs and alternative industry aggregations (e.g., 2-digit NAICS vs 1-digit).

Modeling & calibration
- Calibration transparency and sensitivity: Provide (a) more intuition for the choice of key parameters (λ = 12% human capital loss; χ, ψ values), (b) a table showing a range of plausible λ and how key outcomes (48-month employment, CE loss, half-life) change (you do some sensitivity but expand and move to main text).
- Welfare magnitudes: Given the extremely large consumption-equivalent losses, either tone down headline magnitudes or expand discussion of why the model produces such large CE losses and whether alternative calibrations (e.g., lower λ, different discounting, different b) produce smaller CE losses. Present CE losses under several calibrations in a table.
- Micro validation: Where possible, link model-implied duration distributions and shares of long-term unemployed to observed state-level or national data. This helps validate the calibrated scarring mechanism.
- Heterogeneity in the model: The structural model is aggregate (unit mass of workers). Consider whether introducing simple heterogeneity (age groups, industry-specific human capital) would change qualitative predictions regarding demand vs supply shock persistence. If full heterogeneity is infeasible, at least discuss it as a limitation.

Extensions (would increase contribution)
- Individual-level mediation: Use CPS or administrative data (if available) to show at the worker level that job losses during Great Recession led to longer durations, larger human-capital- or earnings-losses, and higher exit rates than COVID job losses, conditional on similar initial characteristics. This would directly validate the mechanisms you emphasize.
- International evidence: The paper's argument is general; where possible, show analogous cross-region comparisons (UK, Spain) or cite corroborating studies.
- Policy counterfactuals: Use the structural model to quantify how alternative fiscal interventions (earlier ARRA-style stimulus, larger PPP-like match-preserving support) would have altered scarring in the Great Recession counterfactual. This would strengthen your policy implications.

7) OVERALL ASSESSMENT

Key strengths
- Clear, important question with timely policy relevance.
- Nice comparison of two very different shocks using the same empirical framework.
- Carefully documented reduced-form LPs with multiple robustness checks (permutation tests, leave-one-out, alternative Bartik base years).
- Structural DMP model that is well-integrated with the reduced-form facts and provides intuition for mechanisms.

Critical weaknesses
- Terminology and causal language are sometimes imprecise (calling exposure measures “instruments” while reporting reduced-form results). Authors must clarify whether they estimate reduced-form causal effects or IV estimates and, if the latter, present first-stage diagnostics.
- Housing-boom exogeneity requires more convincing evidence: additional covariate balance checks, matching/reweighting or an IV specification with diagnostics would strengthen causal claims.
- Bartik/shift-share inference needs to show GPS diagnostics and exposure-robust SEs in main results.
- Welfare claims (CE losses of 33.5% and 147:1 ratio) are striking; more sensitivity analysis and clearer interpretation are needed so readers do not dismiss them as calibration artifacts.
- The paper relies on state-level cross-sectional variation; individual-level evidence linking scarring channels (duration → human capital -> exit) is only indirect. A direct micro-level mediation test would substantially strengthen the paper.

Specific suggestions for improvement (prioritized)
1. Clarify/repair the instrument language. Either:
   - Present IV estimates (2SLS) with first-stage and Sargan (if overidentified) diagnostics, or
   - Explicitly present the results as reduced-form causal estimates under the maintained exogeneity assumptions, with language carefully adjusted.
2. Add GPS (Goldsmith-Pinkham et al., 2020) diagnostics and implement exposure-robust SEs for Bartik. Report these SEs in main tables.
3. Strengthen housing-boom exogeneity: show more balance/pre-trend checks; include richer pre-recession controls; consider a matching or reweighting robustness check.
4. Present mediation analysis: add regressions that show the Great Recession housing effect on long-run employment is attenuated when controlling for long-term unemployment share and LFPR declines.
5. Expand model sensitivity and temper welfare point estimates: show CE losses across a range of λ, A, β and provide clearer interpretation.
6. If possible, add worker-level evidence (CPS or administrative) documenting that Great Recession layoffs produced longer durations and larger human capital/earnings losses than COVID layoffs conditional on worker characteristics.

8) DECISION (required)
I find the paper promising and potentially publishable in a top journal after the authors address the methodological and interpretational issues above. The core empirical pattern is plausible and backed by tests, but the identification claims and inference for the Bartik exposure, as well as the sensational welfare numbers, require additional work and clearer presentation.

DECISION: MAJOR REVISION

Appendix — Suggested missing references (BibTeX)
- As noted above, the most important missing methodological reference for Bartik inference is Goldsmith-Pinkham, Sorkin & Swift (2020). Please include it and implement recommended diagnostics.

BibTeX for Goldsmith-Pinkham, Sorkin & Swift (AER 2020):
@article{GoldsmithPinkhamSorkinSwift2020,
  author = {Goldsmith-Pinkham, Paul and Isaac Sorkin and Henry Swift},
  title = {Bartik Instruments: What, When, Why, and How},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  pages = {2584--2624}
}

If you would like, I can prepare BibTeX entries for any other canonical papers (Callaway & Sant'Anna, Goodman-Bacon, Imbens & Lemieux, Lee & Lemieux, Adao et al., Borusyak et al., etc.) and propose exact empirical specifications (e.g., an IV LP specification, mediation regression forms) to implement the suggestions above.