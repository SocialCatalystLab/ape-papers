# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T16:55:21.234779
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 25328 in / 5796 out
**Response SHA256:** cce67f0bd8ee77ae

---

Thank you for the opportunity to review. This is an interesting, timely paper that asks a clear question with a plausible mechanism: why did the Great Recession produce persistent employment scarring while the COVID recession did not? The combination of cross‑state reduced‑form local projections and a calibrated search‑and‑matching model with skill depreciation is a natural and potentially valuable approach. The paper is generally well organized and the results are striking. That said, several substantive methodological, identification, inference, and framing issues must be addressed before this can be considered for a top general interest journal. Below I provide a comprehensive review organized around the required checklist, followed by constructive suggestions to improve the paper.

1. FORMAT CHECK

- Length: The LaTeX source is long; the main text + appendices appear to exceed 25 pages. My estimate: main text ~25–35 pages with extensive appendices and figures (hard to be exact from source). This meets the length expectation for a full AER/QJE/JPE-style paper. Ensure the rendered PDF clearly separates main text and online appendix per journal policy.

- References: The bibliography (as referenced in the text) cites many relevant papers (Mian & Sufi, Blanchard, Pissarides, Jorda, Autor, Cajner/Chetty/others for COVID, Guerrieri et al.). However, several foundational methodological references for modern inference and empirical design are missing (see Section 4 below). Add them (Callaway & Sant'Anna; Goodman‑Bacon; Borusyak et al.; Adao/Goldsmith‑Pinkham/others) and other shift-share/Bartik inference literature. Also include classic RDD and DiD references if any related methods are used or discussed.

- Prose: Major sections (Introduction, Institutional Background, Conceptual Framework, Data, Empirical Strategy, Results, Mechanisms, Model Estimation, Robustness, Conclusion) are written as paragraphs, not bullets — good.

- Section depth: Major sections are substantive. The Introduction, Conceptual Framework, and Model sections are long and contain multiple paragraphs each. The Data, Empirical Strategy, and Results sections are likewise substantive. Appendix is long and detailed.

- Figures: The LaTeX source includes figures via \includegraphics. I could not visually inspect the rendered figures here, but the captions describe axes and content. Ensure all figures in the submitted PDF have fully labeled axes, units, and sample periods, and that color/shading is legible in greyscale.

- Tables: Tables appear to be populated (e.g., LP results, calibration, welfare). There are no placeholder numbers in the LaTeX source I saw. Ensure all table notes fully explain variable definitions, sample sizes, SEs, and that any stars/p‑values are clearly defined.

2. STATISTICAL METHODOLOGY (CRITICAL)

This is the central part of my review. A paper cannot pass without solid inference. The paper does include standard errors and some inferential techniques, but several important issues need attention and clearer reporting.

a) Standard Errors
- Positive: Coefficient estimates in the LP regressions are reported with HC1 robust standard errors; the paper also reports permutation p‑values and checks clustering by census division (9 clusters). These are good practices.
- Action needed: For each reported coefficient table please include (i) the standard error in parentheses, (ii) the sample size N for each regression (the paper states N = 50 for GR and 48 for COVID, but include N in every table), and (iii) 95% confidence intervals for main results (either column or bracket). Many figures show shaded 95% CIs; ensure these are reported numerically in tables too.

b) Significance Testing
- Positive: HC1 p‑values and permutation p‑values (1,000 permutations) are reported in the text and appendix. Clustering by census division is performed as a robustness check.
- Action needed: The main tables should display both HC1 SE-based p-values and the permutation p-values side-by-side (e.g., bracketed or as an extra column) so a reader can assess finite-sample uncertainty.

c) Confidence Intervals
- The figures show 95% confidence intervals. The main tables should also display 95% CIs for the primary horizons (6, 12, 48 months). This is required by the checklist.

d) Sample Sizes
- The sample sizes are mentioned in the text (50 states for GR, 48 for COVID, LFPR subsample N=20). But every regression table should explicitly report N. Also, report the number of states used for each horizon and analysis (e.g., if Alaska/Hawaii excluded for COVID, say so in table notes).

e) DiD with Staggered Adoption
- Not applicable: the design is cross‑sectional local projections exploiting continuous cross‑state exposure measures at single event dates, not staggered DiD. The author correctly notes TWFE staggered DiD concerns are not applicable. Still, justify more explicitly why there is no staggered‑treatment bias given different trough dates across states (if any) and discuss whether any states experienced different local timings of peak/trough (and how you treat them).

f) RDD
- Not applicable.

Additional critical inference concerns and how to fix them:
- Small cross-section (N≈50) means standard asymptotic SEs are fragile. The paper rightly uses permutation tests and cluster robustness checks. However:
  - For the Bartik instrument, rely on exposure‑robust inference (Adao et al. 2019; Borusyak et al. 2022). The paper cites and uses Adao, but it needs to clearly report the exposure‑robust standard errors and (preferably) the Borusyak/Jaravel leave‑one‑out or quasi‑experimental corrections for Bartik SEs and inference. Report the first‑stage strength (if using IV) or at least the empirical relevance measures and show sensitivity to exposure‑robust inference.
  - For the housing boom instrument: the authors rely on reduced‑form LPs (they do not use housing as an instrument in an IV sense). That is acceptable provided the identifying assumption (housing boom only predicts employment via demand collapse) is defended and sensitivity/ placebo tests are extensive. But directly showing an IV (housing boom instrumenting local demand collapse) would strengthen causal claims and provide first‑stage F‑statistics.
- Multiple hypothesis testing: many horizons and outcomes are presented (employment, unemployment rate, LFPR). Consider adjusting for multiple comparisons or at least discuss the issue; permutation p‑values partly mitigate concerns but be explicit regarding how many tests and how robustness is judged.
- Spatial correlation: states are spatially correlated (spillovers; common shocks). Clustering by census division helps, but with 9 clusters inference may be noisy. Consider two approaches: (i) use spatial HAC (Conley) standard errors that allow for spatial decay; (ii) show the sensitivity of p‑values to different clustering choices (state pairs, region, CBSA grouping).
- Pre‑trend tests: The event-study/LP pre-period coefficients are shown and are small. Present joint pre‑trend tests (Wald tests across multiple pre‑period coefficients) to strengthen claim of parallel pre‑trends. With small N, consider permutation-based pre‑trend testing.
- Migration as mechanical driver: LP uses employment levels, which mix place and worker effects. The paper argues migration would understate scarring but does not fully rule out migration as an alternative explanation for long-run cross‑state employment differences. Add analyses using population controls, net migration flows, or per‑capita employment changes to check sensitivity. If data permit, show individual‑level CPS/LEHD evidence that long‑term earnings losses/history are present conditional on migration.

3. IDENTIFICATION STRATEGY

Is identification credible? Partly, but further work is needed.

- Great Recession / housing boom identification:
  - Strengths: classic identification strategy (Mian & Sufi) — housing boom intensity plausibly predicts variation in the demand shock at the local level.
  - Concerns:
    - The housing boom may correlate with other state trends that affect long-run employment (e.g., persistent industry composition shifts, pre-existing growth trends, differential demographic trends). The paper controls for pre-recession employment growth, log population, and region fixed effects, and reports flat pre-trends. Still, given N=50 one must be cautious.
    - Suggestion: implement additional balance tests (regress many pre‑recession state characteristics—pre‑2003 growth, education, industrial composition, pre‑2003 migration trends—on the housing boom to show no systematic correlation). Consider controlling flexibly for a polynomial in pre‑recession employment growth and other observables or using synthetic control-like checks.
    - If plausible instruments at different levels exist (e.g., exogenous credit supply shocks, mortgage origination intensity, local underwriting rules), consider an IV strategy that uses an instrument for housing boom rather than interpreting housing boom as an exogenous exposure variable itself.
- COVID Bartik identification:
  - Strengths: Bartik is a standard approach to predict local exposure to national industry shocks.
  - Concerns:
    - Bartik validity hinges on exogeneity of national industry shocks and exogeneity of pre‑period industry shares (the latter assumed exogenous conditional on controls). The paper uses leave‑one‑out national shocks and cites Adao et al. Good.
    - Action needed: explicitly report exposure‑robust inference (Adao), and implement Borusyak & Jaravel (2022) "quasi-experimental" approach or the Goldsmith‑Pinkham et al. (2020) corrections. Include the first‑stage statistics and the variation decomposition showing how much variation comes from industry shocks vs. local shares.
- Mechanism identification:
  - The proposed mechanism is skill depreciation via prolonged unemployment durations leading to LFPR exit. The LP results alone cannot identify this channel. The paper uses national-level duration statistics, JOLTS, and model calibration. These are suggestive but do not establish the channel at the state level.
  - Suggestion: add micro-level evidence (CPS/ACS/LEHD) to show that workers in high‑housing‑exposure states experienced longer unemployment durations, larger declines in earnings, higher exit rates from the labor force, and worse reemployment wages relative to less‑exposed states. If micro data linking workers to states is not feasible, show state‑level series for long-term unemployment shares and LFPR and regress their changes on the exposure measures with LPs — that would strengthen the mechanism.
- Policy endogeneity:
  - The paper notes that fiscal response is endogenous to shock type and severity. That is correct. But the interpretation that the reduced‑form LP captures the "total effect of shock type, inclusive of endogenous policy" should be made more explicit as a limitation: the cross‑state correlation could be reflecting different policy responses across states/localities (e.g., differences in state unemployment benefit expansions, PPP take‑up, or local fiscal resources). Consider controlling for state‑level measures of fiscal response (PPP intensity, FEMA funds, state UI generosity changes) as robustness checks—while acknowledging potential post‑treatment bias, these checks can be treated as bounding exercises.

4. LITERATURE (MISSING REFERENCES; provide BibTeX)

The paper cites a lot of relevant empirical literature but is missing a set of methodological and relevant recent empirical papers that are essential to position the contribution and to justify inference choices. Below I list the missing/important papers and explain why they should be cited, and provide BibTeX entries.

a) Modern DiD/Inference / Bartik literature (must cite):
- Goodman‑Bacon (2021) — explains TWFE problems with staggered adoption; mentioned in passing but not in references.
- Callaway & Sant'Anna (2021) — modern DiD estimator (for completeness, even if not using DiD).
- Adao, Kolesar, and Morales (2019) — on inference for shift‑share (Bartik) designs: exposure‑robust standard errors.
- Borusyak, Jaravel, Spiess (2022) — quasi‑experimental properties of shift‑share/Bartik and inference corrections (and leave-one-out).
- Goldsmith‑Pinkham, Sorkin, and Swift (2020) — Bartik as an IV and general critique.

Provide BibTeX entries below.

b) RDD & causal inference classics (if the paper mentions RDD or thresholds/continuity):
- Imbens & Lemieux (2008) and Lee & Lemieux (2010) — RDD foundations (not strictly needed unless RDD used).

c) Additional relevant labor literature:
- Borusyak & Jaravel (again) for Bartik.
- Papers that use housing boom instrumentals for local demand collapse (Mian & Sufi are cited, but also consider citing Hendren & Sprunger? Not essential but consider Yagan 2019 is cited).

BibTeX entries (minimal fields): (I include a set that I judge essential)

```bibtex
@article{GoodmanBacon2021,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}

@article{CallawaySantAnna2021,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}

@article{GoldsmithPinkham2020,
  author = {Goldsmith-Pinkham, Paul and Sorkin, Isaac and Swift, Henry},
  title = {Bartik Instruments: What, When, Why, and How},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  pages = {2586--2624}
}

@article{adao2019shift,
  author = {Adao, Rodrigo and Koles{\'a}r, Michal and Morales, Eduardo},
  title = {Shift-Share Designs: Theory and Inference},
  journal = {Quarterly Journal of Economics},
  year = {2019},
  volume = {134},
  pages = {1949--2010}
}

@article{borusyak2022quasi,
  author = {Borusyak, Kirill and Jaravel, Xavier and Spiess, J.},
  title = {Quasi-Experimental Shift-Share Research Designs},
  journal = {Review of Economic Studies},
  year = {2022},
  volume = {89},
  pages = {1811--1848}
}
```

(If you want more BibTeX entries for RDD papers (Imbens & Lemieux; Lee & Lemieux), I can provide them.)

Why each is relevant:
- Goodman‑Bacon & Callaway & Sant'Anna: modern DiD literature; referenced in the paper for TWFE concerns — include their references to be complete and to justify the LP choice.
- Goldsmith‑Pinkham & Adao & Borusyak et al.: directly relevant to the Bartik shift‑share identification and inference. The paper cites Adao 2019 and Goldsmith 2020 in text, but make sure they are properly included in the bibliography and that exposure‑robust methods are used and reported.
- Borusyak et al. (2022) provide important formal justification and inference methods for shift‑share designs and should be used (or at least discussed) for the Bartik COVID instrument.

5. WRITING QUALITY (CRITICAL)

Overall the paper is well written and readable for a specialist audience, but some style and clarity issues should be addressed for a top‑journal submission.

a) Prose vs Bullets:
- The paper uses paragraphs; no major bullet usage in core sections — good.

b) Narrative Flow:
- Strengths: The Intro hooks well with striking facts about job losses and recovery; conceptual framework logically follows and the model is clearly presented.
- Improvements:
  - The Introduction and Conclusion at times make large, strong claims (e.g., “Demand shock imposes 146 times the welfare cost of the supply shock” or the 147:1 ratio). These precise ratios are very sensitive to model calibration and parameter choices (authors acknowledge this to some extent). So temper strong summary statements and emphasize robustness/sensitivity. Replace absolute language with qualified language: “order‑of‑magnitude larger” or “substantially larger under baseline calibration; sensitive to parameter choices.”
  - Clarify early what exactly is being estimated in the LPs (reduced‑form exposure → outcome; not an IV estimate of local demand shock) so readers don’t conflate “instrument” with “instrumental variables/first stage.”

c) Sentence Quality:
- Prose is generally crisp. A few long sentences can be tightened for clarity (e.g., in the introduction when summarizing model results and welfare numbers).

d) Accessibility:
- The conceptual model is accessible to an economics audience, but some parameters and mechanisms (e.g., the ad hoc s_t updating rule in transition algorithm) should be explained with intuition and caveats. Explain the choice of parameter values more explicitly where they are less conventionally calibrated (e.g., λ = 0.12 skill depreciation — what micro evidence directly pins this?).
- Provide intuitive magnitudes alongside percentages: e.g., “0.8 percentage points lower employment” — clarify whether that’s percent of population or percent point of employment rate etc.

e) Tables:
- Improve table notes: define variables, list controls, report N, show SEs and permutation p‑values. Make sure all table captions explain the model, controls, and inference method used.

6. CONSTRUCTIVE SUGGESTIONS

If the authors want to make this paper stronger and more likely to pass top‑journal review, consider the following concrete improvements and additional analyses.

A. Strengthen inference and identification
- Report and emphasize permutation p‑values and exposure‑robust SEs for Bartik (Adao) and Borusyak/Jaravel corrections. Report 95% CIs numerically in main tables and figures.
- For the Great Recession housing measure, present alternative identification checks:
  - Balance tests showing housing boom is not correlated with pre‑2003 trends (education, population change, industry mix, net migration).
  - An IV strategy (if feasible): instrument local housing booms with plausibly exogenous determinants of credit supply or exogenous supply constraints (Saiz 2010's geographic supply elasticity?); at minimum provide a sensitivity analysis showing how the LP coefficient changes when including many pre‑treatment covariates.
- Present joint pre‑trend tests (Wald) rather than just individual pre‑period coefficients.
- For small‑N inference:
  - Provide Conley spatial HAC SEs.
  - Present wild cluster bootstrap results where relevant (if clustering by region).
  - Report how inference changes under different clustering/SE choices.
- Multiple testing: consider reporting false discovery rate (FDR) adjusted p‑values across horizons, or at minimum discuss multiple testing.

B. Bolster the mechanism evidence
- Micro evidence: Use CPS (or ideally LEHD/CEW individual match data if feasible) to show that within high‑housing‑exposure states, unemployed workers experienced longer durations, larger reemployment wage losses, and higher exit to OLF than in low‑exposure states. If individual data linking can’t be done, do state‑level regressions for long‑term unemployment share and LFPR with the housing exposure and present LPs; authors already partly do this, but clarify sample and improve LFPR measurement (use ACS/CPS if LAUS limited).
- Migration: demonstrate that long‑run employment differences are not purely explained by net migration. Re-estimate LPs for per‑capita employment or employment rates (employment/population) and/or include net migration controls from IRS or ACS.
- Policy responsiveness: provide bounding exercises controlling for PPP intensity, state PPP take‑up, enhanced UI generosity at the state level, or state fiscal space—present results as robustness checks rather than main identification (since they could be post‑treatment).

C. Robustness and heterogeneity
- Heterogeneity: show heterogeneity by state characteristics (education, initial LFPR, industry concentration). Are scarring effects concentrated among lower‑skill or non‑college states?
- Alternative exposure definitions: For the Great Recession, show results using Bartik (industry shares * national industry decline) as an alternative exposure measure (the authors mention they did a Bartik for GR in appendix). Consider using multiple exposure measures jointly.
- Placebo tests: apply the same LP framework to other recessions (e.g., 2001 recession) or to simulated placebo shocks (permutation/lead exposures) to show the pattern is unique to GR vs COVID.
- Sensitivity of the model: present more sensitivity analysis for key calibration parameters (discount factor, λ, matching elasticity α, cost κ). The appendix includes some sensitivity but bring key ones to main text or appendix front and center.

D. Model improvements and calibration transparency
- The model uses an ad‑hoc rule for evolving s_t (scarred fraction). Explain, justify, and test the sensitivity of results to different dynamic specifications (e.g., micro‑founded duration distribution with tracking of cohorts).
- Justify λ = 0.12 more explicitly with micro evidence (e.g., reemployment wage loss estimates from Jacobson et al., Kroft et al.) and show how scaling λ changes welfare ratios.
- Emphasize that welfare numbers are illustrative and sensitive; tone down absolute claims regarding 147:1 ratio.

E. Presentation clarity
- In tables and figures, always show N and inference method in captions/notes.
- For LP figures, annotate key horizons (peak, 48 months, half‑life) and state what the scaling is (e.g., per one SD of exposure).
- Rework the conclusion: remove numerical hyperbole and emphasize policy implications with caution (e.g., “these results suggest that demand shocks that produce long unemployment durations require rapid demand‑side policy to avoid scarring”).

7. OVERALL ASSESSMENT

Key strengths
- Clear, important research question with high policy relevance.
- A sensible combination of reduced‑form cross‑state LPs and an economic model that ties the mechanism to observable outcomes (durations, LFPR).
- Use of multiple inference approaches (HC1, permutation tests, cluster SEs) and robustness checks in the appendix.
- Thoughtful calibration and welfare accounting that illustrate the mechanism's quantitative importance.

Critical weaknesses (fatal if not addressed)
- Inference and identification require additional robustness and clearer presentation: small cross-section, spatial correlation, and Bartik exposure inference need fuller treatment (exposure‑robust SEs; Borusyak corrections). The paper currently mixes HC1, clustering, and permutation tests but must present these consistently and transparently in main tables.
- Mechanism not directly established at the state level: the paper leans heavily on national duration aggregates and model calibration to claim skill depreciation causes persistence. Without micro/state‑level evidence linking exposure → durations → LFPR exit, causality is weaker.
- Overconfident presentation of welfare magnitudes (147:1) without enough emphasis on calibration sensitivity. The authors already note sensitivity but must tone down summaries in abstract/introduction/conclusion.
- Potential omitted variable bias: housing booms may correlate with other long-run growth drivers. More balance tests and robustness to rich pre‑treatment controls are needed.

Specific suggestions for improvement
- Report 95% CIs and permutation p‑values for main tables; include N in every regression table.
- For Bartik/COVID: report exposure‑robust SEs per Adao (2019) and Borusyak et al. (2022); show first‑stage diagnostics if IV used.
- Add micro evidence on durations, reemployment earnings, and LFPR by exposure to directly support the mechanism.
- Provide joint pre‑trend tests (Wald) and additional balance tests for housing boom.
- Moderate language about welfare ratios and make clear that model numbers are illustrative and calibration‑dependent.
- Consider performing per‑capita employment regressions and controlling for migration flows.

8. DECISION

This paper is promising, tackles an important question, and already does many things well. But the methodological and identification issues described above are material and must be remedied before the paper can meet the standards of a top general interest journal. The necessary additional analyses (micro evidence on mechanisms, clearer Bartik inference, pre‑trend and balance checks, migration checks, and a toned‑down presentation of welfare magnitudes) are substantial but feasible.

DECISION: MAJOR REVISION

If the authors revise, I will re‑evaluate with close attention to:
- main LP tables updated to show 95% CIs, permutation p‑values, exposure‑robust SEs, and N,
- direct empirical evidence tying exposure → unemployment duration → LFPR exit (micro or improved state series),
- clear balance/pre‑trend tests and sensitivity to pre‑treatment controls,
- convincing discussion and sensitivity analysis of the model calibration and welfare decomposition,
- treatment of potential spatial correlation and migration as alternative explanations.