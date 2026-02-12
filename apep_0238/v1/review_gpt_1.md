# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T13:28:11.643116
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 29928 in / 5580 out
**Response SHA256:** 199a9e08b3a09965

---

Thank you for the careful, interesting draft. This is a timely and important paper: the empirical contrast between the Great Recession and COVID recessions is compelling, the LP framework is appropriate for comparing dynamic responses, and the structural DMP model with an explicit scarring channel is a useful way to interpret the reduced-form facts. The paper has the potential to make a strong contribution to macro/labor literatures and to policy debates about the limits of match-preserving interventions and the need for rapid demand stimulus.

Below I give a comprehensive referee report covering format, inference, identification, literature, writing, concrete robustness checks and constructive suggestions to improve clarity and credibility. I close with an overall assessment and my recommended decision.

1. FORMAT CHECK (quick checklist and items to fix)
- Length: The LaTeX source, with a long main text and many appendices/figures/tables, looks substantial — I estimate ~45–70 pages rendered (main text ~30–40 pages; appendices add many pages). Top journals typically expect ≳25 pages of main text (excluding appendices); your main text is long enough but check the journal-specific limit for the target outlet. If you aim for AER/QJE/JPE, you should ensure the main narrative is tight and relegate technical material to appendices.
- References: The bibliography is extensive and cites many relevant empirical and modeling papers (Mian/Sufi, Cajner, Autor, Shimer, Hall, Blanchard). However, some key methodological/identification papers are missing — see Section 4 below where I recommend specific citations and BibTeX entries.
- Prose: Major sections (Intro, Background, Framework, Data, Strategy, Results, Mechanisms, Model, Robustness, Conclusion) are in paragraph form (good). Predictions are briefly enumerated but appear in paragraph form; that’s acceptable.
- Section depth: Each major section has substantive material and multiple paragraphs — overall depth is good.
- Figures: In the LaTeX source I see \includegraphics calls. I could not visually inspect the rendered figures; when you submit the rendered PDF ensure that every figure has readable axes, units, legend, and clear captions. In particular: (i) show the units (percentage points vs log differences); (ii) annotate which line corresponds to a one-standard-deviation shock; (iii) include number of observations in figure notes.
- Tables: Tables appear to contain real numbers; no placeholders detected. Make sure every table has a clear note explaining data sources, definitions, and how SEs are computed (HC1, cluster, permutation, exposure-robust, etc.).

2. STATISTICAL METHODOLOGY (critical)
A paper cannot pass without solid statistical inference, and you have addressed many inference concerns. Nevertheless several methodological issues deserve emphasis and, in some cases, additional analysis or reporting.

a) Standard errors & inference
- You report HC1 robust SEs, cluster-by-division SEs, and permutation tests. This is good. Make sure that every coefficient reported in every table has SEs (and p-values or stars) — I saw HC1 SEs in tables and permutation p-values in the text, so this requirement appears satisfied.
- Recommendation: In main tables report both the point estimate, the HC1 SE (in parentheses), and parenthetical permutation p-value or a second-line exposure-robust SE (for Bartik). This makes inference transparent to the reader. Also explicitly report 95% confidence intervals (not just p-values). The paper states it displays 95% CIs in figures; include numerical 95% CI bounds in key tables or in online replication files.

b) Small-sample inference (N=46–48)
- Your regressions are cross-sectional (one observation per state at each horizon), so N is small. You address this with permutation tests and leave-one-out analysis — that is appropriate and necessary. It would strengthen the paper to present the permutation p-values in the main tables for the key horizons (e.g., h=48 for GR, h=18 for COVID). Also show wild cluster bootstrap-t results if feasible (with 9 clusters it may be borderline), but since you already use permutation inference, explain why that is preferred in this setting.
- Recommendation: For transparency, show the distribution of permuted coefficients (e.g., histogram) for the key horizon(s) in an appendix (you reference placebos, but include the plots and exact p-values).

c) Shift-share (Bartik) inference
- You correctly cite and (I read) implement exposure-robust inference (Adao et al. and Borusyak et al.). Make sure the main tables explicitly state which standard errors are used for Bartik regressions (e.g., HC1 vs exposure-robust). Also provide the first-stage strength (correlation of Bartik with actual initial employment loss) and an F-statistic-type analogue for the shift-share (see Adao et al., and Goldsmith-Pinkham et al.).
- Recommendation: Report the effective first-stage R^2 or F-stat for the Bartik (the correlation between B_s and peak-to-trough employment decline). If the Bartik is weak, interpret the point estimates cautiously.

d) Local projections (LP) and use of “instrument”
- You run reduced-form LP regressions: Delta y_{s,h} on exposure Z_s. You sometimes call Z an “instrument” — be precise: in the main specification Z is an exposure variable / source of exogenous cross-state variation; it is not being used as an instrument in a two-stage least squares (2SLS) sense in the paper’s main LPs. Readers will want to see justification that Z is plausibly exogenous. You already discuss exogeneity, but it should be accompanied by balance/pre-trend and placebo checks (see below).
- If you present any IV estimates (e.g., instrumenting a state-level “treatment intensity” with HPI or Bartik), provide the first- and second-stage regression results and show standard IV diagnostics (F-statistics, overidentification if multiple instruments).

e) DiD / staggered adoption concerns
- Not applicable here (you do not use TWFE with staggered adoption). Good.

f) RDD
- Not applicable.

Summary for methodology: The core inference framework is acceptable because you (i) use permutation tests to deal with small N, (ii) use exposure-robust SEs for Bartik, (iii) cluster by census division as a robustness check. But you should:
- Add explicit 95% confidence intervals in main tables,
- Report permutation p-values and exposure-robust SEs in main tables,
- Report first-stage correlations for your exposure measures (how strongly they predict initial severity),
- Add balance/pre-trend tables and placebo outcomes in main text or appendix (some are in Appendix but bring key pre-trend check to the main text).

3. IDENTIFICATION STRATEGY — credibility and tests
The identifying approach relies on cross-state variation in exposure (housing boom for GR; Bartik for COVID). This is an appealing cross-episode comparison, but several identification threats must be addressed more fully.

A) Housing boom → demand exposure (Great Recession)
- Relevance: this is a well-known approach (Mian/Sufi). You provide evidence that housing booms correlate with deeper employment declines. Still, you should present a clear first-stage table: regress initial state-level peak-to-trough employment decline on HPI and controls. Report the coefficient, SE, R^2, and plot the relationship. This first-stage should be in the main text/table.
- Exogeneity: the main concern is that states with large housing booms may have had other systematic differences (e.g., pre-existing employment trends, demographics, migration, or labor market institutions) that also affect long-term outcomes (or migration of workers after the shock). You do control for pre-recession trends and show no pre-trend correlations in Appendix; that is good, but you should:
  - Present balance tests more systematically: regress pre-recession employment growth, demographic covariates, pre-recession unemployment duration, net migration, and state fiscal variables on HPI. Show that observable confounders are not correlated (or control for them).
  - Provide placebo regressions: regress later-period outcomes in pre-2007 periods on HPI to test for spurious relationships.
  - Discuss possible channels through which housing booms could be correlated with long-run supply-side changes (e.g., persistent changes in industry mix, state-level policy) and show robustness to controlling for industry shares, energy exposure, and migration flows.
  - Migration: migration could attenuate or amplify cross-state LP coefficients. You note compositional concerns; but ideally include net migration as a dependent variable/regressor or at least show robustness controlling for net migration 2007–2017. If data on state-to-state migration are noisy, show robustness using IRS migration flows or ACS 1-year migration rates.

B) Bartik (COVID)
- You construct a leave-one-out national industry shock and interact with pre-recession industry shares — standard. You cite Goldsmith-Pinkham et al. and Adao et al. and say you use exposure-robust SEs — good. Still:
  - Report the leave-one-out first-stage: correlation of Bartik with actual early employment declines (peak-to-trough). That shows relevance.
  - Provide diagnostics for the exogeneity of industry shares: show that pre-pandemic industry composition is not correlated with pre-pandemic trends in employment or with state policy variables that could have influenced the recovery (e.g., stringency of lockdowns, state-level fiscal support).
  - Consider adding an alternative instrument based on pre-pandemic teleworkability exposure (Dingel/Neiman, Mongey/Pilossoph) or a variant Bartik using cross-state tourism intensity, as robustness.

C) General equilibrium / omitted-policy channels
- You discuss policy differences and argue that policy is endogenous to shock type; still, some of the cross-state variation in recovery speed could be explained by differences in state-level fiscal/health responses, Medicaid expansion, timing and generosity of UI supplements, or the share of PPP dollars by state. Consider adding robustness controls:
  - State-level fiscal support intensity (PPP dollars per capita, CARES funding per capita, timing of reopening orders).
  - Pandemic severity (COVID death rates, case rates) and timing of state-level lockdowns.
  - Unemployment insurance recipiency or duration differences across states.
  - Include these controls in the COVID LP (or show coefficients are robust to including them).
- Alternatively, present mediation analysis showing how much of the COVID rapid recovery is explained by PPP/CARES/benefits vs. being intrinsic to shock type. This can be done as a decomposition/regression of recovery speed on Bartik exposure and policy measures.

D) Mechanisms: duration & participation
- You present national JOLTS and duration evidence convincingly. To strengthen causal mediation:
  - Use state-level time series on long-term unemployment shares and durations and show that the Great Recession exposure predicts an increase in long-term unemployment and LFP decline at the state level (LP regressions analogous to employment). You show some of this in Figures/tables — ensure these are front-and-center.
  - Ideally, use microdata (CPS or administrative UI data) to link pre-recession housing exposure (or being in a boom state) to individual-level duration, re-employment rates, and earnings losses. You note that as future work; I recommend adding a short worker-level mediation exercise (CPS panel regressions) to directly show that the scarring effect operates through duration and exit and not purely through replacement of jobs by different workers or migration.
  - Distinguish scarring (lower productivity of reemployed workers) from composition/migration: e.g., if low-skilled workers moved out, average employment in-place could recover while worker welfare remains damaged. Micro analysis can separate place vs worker effects (as in Amior et al., Autor et al.).

E) External validity and sample-of-two concern
- You acknowledge that comparing two recessions is a sample-of-two exercise. Strengthen discussion of external validity and consider cross-country evidence or additional episodes (e.g., Spain after 2008, UK) if possible as suggestive evidence.

4. LITERATURE — missing and suggested citations (you must add them)
The paper cites many relevant works, but several methodological and recent identification papers should be added, especially because your empirical strategy uses LPs and shift-share instruments and operates with small cross-sectional samples. Below are specific recommended additions and why they matter, plus BibTeX entries you can include.

- Callaway, Sant’Anna (2021): important if you ever use DiD/event-study-style inference or staggered adoption. Even if you do not use DiD, cite as best practice when comparing dynamic effects across groups.
  BibTeX:
  @article{callaway2021difference,
    author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
    title = {Difference-in-Differences with multiple time periods},
    journal = {Journal of Econometrics},
    year = {2021},
    volume = {225},
    pages = {200--230}
  }

- Goodman-Bacon (2021): explains decomposition of TWFE with staggered adoption — cite if you discuss event-study inference and why you use LPs.
  BibTeX:
  @article{goodman2021difference,
    author = {Goodman-Bacon, Andrew},
    title = {Difference-in-Differences with Variation in Treatment Timing},
    journal = {Journal of Econometrics},
    year = {2021},
    volume = {225},
    pages = {254--277}
  }

- Adao, Kolesar, Morales (2019) and Borusyak, Hull (2022) — you cite these, but ensure the exact references and BibTeX are included. (I think you cite adao2019shift and borusyak2022quasi; make sure the entries are in your references with correct details.) These are important for shift-share inference.

- Imbens & Lemieux (2008): standard RDD and causal inference practices; cite if you discuss IV/identification broadly.
  BibTeX:
  @article{imbens2008regression,
    author = {Imbens, Guido W. and Lemieux, Thomas},
    title = {Regression discontinuity designs: A guide to practice},
    journal = {Journal of Econometrics},
    year = {2008},
    volume = {142},
    pages = {615--635}
  }

- Goldsmith-Pinkham, Sorkin, Swift (2020): provides formal framework for Bartik inference (you cite Goldsmith 2020 but ensure full reference).
  BibTeX:
  @article{goldsmith2020good,
    author = {Goldsmith-Pinkham, Paul and Sorkin, Isaac and Swift, Henry},
    title = {Bartik Instruments: What, When, Why, and How},
    journal = {American Economic Review: Insights},
    year = {2020},
    volume = {2},
    pages = {163--182}
  }

- Borusyak, Hull, Jaravel (2022) (Quasi-experimental shift-share inference): you cite Borusyak 2022 — ensure the correct reference is included.
  BibTeX:
  @article{borusyak2022quasi,
    author = {Borusyak, Kirill and Hull, Patrick and Jaravel, Xavier},
    title = {Quasi-Experimental Shift-Share Designs},
    journal = {Econometrica},
    year = {2022},
    volume = {90},
    pages = {23--69}
  }

- Goldsmith-Pinkham et al. (2018) earlier relevant paper about Bartik: include if not present.
  BibTeX:
  @article{goldsmith2018shock,
    author = {Goldsmith-Pinkham, Paul and Sorkin, Isaac and Swift, Henry},
    title = {Bartik instruments and the impact of local economic shocks},
    journal = {Journal of Econometrics},
    year = {2018},
    volume = {201},
    pages = {125--146}
  }

- Amior, Shah, Lydon, Van Reenen (recent papers on local labor markets and scarring) — you cite Amior et al., but check for other papers on place vs people (Autor et al. 2013, Notowidigdo).

Add these and check the bibliography for completeness and correct formatting. Provide BibTeX entries in your references file.

5. WRITING QUALITY (critical, but mostly strong)
Overall the paper is well-written, clear, and structured. A few stylistic and organizational suggestions:

a) Clarity around “instrument” usage:
- As noted above, be precise when you call HPI or Bartik an “instrument.” If you are estimating reduced-form LPs treating Z_s as a plausibly exogenous exposure, say so explicitly. Reserve “instrument” for the IV context and label the regressions “reduced-form LPs” or “exposure regressions.”

b) Narrative flow:
- The introduction is strong and hooks the reader — good.
- Some of the model derivation sections are dense. Consider moving lengthy technical derivations to the appendix and keeping the conceptual discussion in the main text concise and intuitive (with equations only where necessary).

c) Paragraph structure:
- Most sections are paragraphs; however, the “Testable Predictions” section uses bolded enumerated predictions. That’s fine, but make sure the flow remains narrative and not a checklist. Keep the lead sentences of paragraphs to emphasize main insight.

d) Accessibility:
- For readers who are not DMP specialists, briefly explain the mechanism by which a permanent productivity decline reduces vacancy creation (free-entry condition intuition) — you do, but a short intuition sentence early in the model section helps.

e) Table and figure notes:
- Ensure every table and figure includes enough notes to be self-contained: data sources, sample sizes (N), SE type, definition of exposure variable (units), and clustering/permutation details.

6. CONSTRUCTIVE SUGGESTIONS — analyses and extensions to increase impact
The paper is promising; the following additions would materially strengthen identification and the paper’s contribution.

A) First-stage / reduced-form clarity
- Add first-stage or reduced-form regressions that show how strongly HPI and Bartik predict the initial depth of the recession (peak-to-trough employment decline). Put these in a compact table in the main text.

B) Balance / pre-trend and migration controls
- Move a concise pre-trend table from the appendix to the main text (or at least highlight the key result) showing no statistically significant pre-trends for employment/unemployment/LFP with respect to HPI and Bartik.
- Control for net migration in the LPs or show that the results are robust to inclusion of migration flows (IRS or ACS). If migration is an important channel, show the implications for “place vs. person” effects.

C) Micro-level mediation analysis
- Add a short CPS-based analysis showing that individual-level outcomes (duration, re-employment wage, exit to non-participation) are predicted by living in a high-HPI state during the Great Recession but not by living in a high-Bartik COVID-exposed state during COVID. Even a basic difference-in-differences on CPS microdata would bolster the claim that scarring operates at the worker level through duration.

D) Policy mediation (PPP / CARES)
- Attempt to quantify how much of the COVID rapid recovery is explicable by PPP/CARES relative to the shock type. For example, regress state-level recovery speed on Bartik exposure and PPP dollars per capita (or PPP loans per business) and show coefficients. This will help disentangle policy vs shock-type effects.

E) Alternative measures of exposure
- For Great Recession, an alternative exposure measure: state-level mortgage leverage or foreclosure rates pre-crisis. For COVID, alternative exposure: teleworkability-weighted shares or tourism-dependency index. Show robustness to these.

F) Present counterfactual IV estimates
- If you can construct a 2SLS where you instrument an endogenous mediator (e.g., change in hiring or vacancy creation) with HPI, that could provide causal evidence about the mechanism (demand → lower vacancies → longer durations → scarring). At minimum, show mediation regressions (Baron-Kenny style) with appropriate caveats.

G) Report computational replication files and code
- For journal and referee reproducibility, provide replication code and data scripts in the repo. Make sure the repo is complete and documented.

7. OVERALL ASSESSMENT

Key strengths
- Clear, important question: why similar-sized aggregate contractions (in employment) have very different long-run effects.
- Good empirical design: cross-state LPs comparing two recessions in the same units, using well-motivated exposure measures.
- Thoughtful modeling: DMP model with endogenous participation and scarring provides intuition and counterfactuals that align with the data.
- Robustness: you implement permutation tests, leave-one-out checks, exposure-robust SEs for Bartik, clustering by division — these are the right tools for the small-N, shift-share setting.

Critical weaknesses (fixable)
- Small N inference and the presentation of inference need tightening: main tables should show 95% CIs, permutation p-values, and exposure-robust standard errors explicitly.
- Identification threats remain around the housing-boom instrument’s exogeneity (migration, pre-existing trends, persistent supply-side differences). You have some pre-trend checks in the appendix, but these should be synthesized and put in the main text plus additional controls (migration, demographics).
- Limited micro-level evidence that scarring operates at the worker level (duration → lower reemployment wages/productivity). Adding a short CPS or administrative data analysis would materially strengthen the mechanism claim.
- Policy channels (PPP, CARES, UI supplements) could be confounders of cross-state recovery speed for COVID; quantify their role.

Specific suggestions for improvement (actionable)
1. Add a compact table in main text: first-stage/relevance regressions of initial employment decline on exposure (HPI/Bartik), with HC1 SEs and permutation p-values.
2. In main tables, present point estimates, HC1 SEs, permutation p-values, and 95% CIs; for Bartik regressions present Adao et al. exposure-robust SE as the standard cell and HC1 as robustness row.
3. Move the most important pre-trend and leave-one-out figures/tables from the appendix into the main text (or at least the top of the robustness section) and explicitly state that HPI/Bartik are uncorrelated with pre-trends.
4. Add state-level controls for migration, PPP funding per capita, CARES funding, state policy stringency, and show that main results are robust.
5. Add a brief micro-level analysis using CPS (or another micro dataset) to show that the Great Recession exposure predicts longer durations and larger earnings losses at the individual level, while COVID exposure does not.
6. Add an explicit decomposition table that quantifies how much of the cross-state employment gap is explained by (a) long-term unemployment increases, (b) participation decline, (c) migration — using regression-based mediation or Oaxaca-Blinder style decomposition.
7. Tighten the model presentation in the main text: move algebraic derivations to the appendix and keep the main intuition and calibrations in the body.
8. Add/verify the methodological literature citations listed in Section 4 and ensure BibTeX entries are present.

8. DECISION

The paper is promising and largely methodologically sound, but it requires additional empirical robustness and clearer presentation of inference (especially first-stage, CIs, permutation p-values) and more direct worker-level evidence for the scarring mechanism. These are substantive but feasible revisions.

DECISION: MAJOR REVISION