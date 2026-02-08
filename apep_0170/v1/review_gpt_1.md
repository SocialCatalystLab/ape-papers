# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-03T20:16:06.105425
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 17334 in / 6657 out
**Response SHA256:** 869e1a8717db1294

---

Thank you for the opportunity to review this paper. The question—do salary history bans reduce overall wage inequality?—is important and policy-relevant. The author has assembled a plausible research design (staggered adoption, ACS microdata) and employs modern DiD methods (Callaway & Sant'Anna as primary estimator, Sun–Abraham, Goodman–Bacon decomposition, event studies, placebo outcomes). However, the paper in its current form is not ready for a top general-interest journal. Below I give a detailed, structured review covering format, statistical methodology, identification, literature, writing, constructive suggestions, and an overall assessment and decision. I am demanding: I flag substantive weaknesses that must be addressed before this work could be considered for AER/QJE/JPE/REStud/AEJ: Econ Policy.

1. FORMAT CHECK (explicit checklist)
- Length: The LaTeX source contains a long main text plus appendix. Excluding references and appendix, the main text appears to be roughly in the range of ~30–40 pages when compiled (Introduction + 7 main sections + figures/tables). That satisfies the page-length minimum (>=25). Please list exact page count in resubmission and ensure the compiled PDF pages match expectations.
- References: The manuscript cites many relevant papers (Callaway & Sant'Anna 2021; Goodman-Bacon 2021; Sun & Abraham 2021; Bertrand et al. 2004; Cameron et al. 2008; papers on pay transparency and salary history). However:
  - The bibliography at the end of the LaTeX file points to \bibliography{references} but the .bib contents are not included here. I cannot verify whether all cited papers have complete, correct bibliographic entries (journal, year, volume, pages). Ensure the compiled paper includes a full, formatted reference list with complete info for every in-text citation.
  - Several literatures and specific papers that bear directly on identification, measurement, or interpretation are missing (see Section 4 below). Add those citations and full BibTeX entries before resubmission.
- Prose: Major sections (Introduction, Institutional background & theory, Data, Empirical strategy, Results, Robustness, Discussion/Conclusion) are written in paragraph form (not bullets). Good.
- Section depth: Most major sections include multiple substantive paragraphs (e.g., Introduction is long and informative, Institutional + mechanisms are multi-paragraph). Satisfies the 3+ substantive paragraph expectation for main sections.
- Figures: The manuscript includes figures (event study, parallel trends). The LaTeX references to .pdf figures (e.g., figures/fig3_event_study.pdf) indicate figures are provided. In this source I cannot inspect the compiled figures; ensure all figures in the compiled PDF:
  - show the plotted data or point estimates,
  - have clearly labeled axes (units, variable definitions),
  - include legends and readable fonts,
  - include comprehensive figure notes describing the sample (N, clustering, estimator used).
  - Specifically, event-study plots should show a horizontal zero line, confidence bands, and the reference period identified.
- Tables: All presented tables in the source contain numeric values (no placeholders). However, a few issues that must be fixed (see detailed comments below): missing sample sizes for some subgroup analyses, clarity on how R^2 is computed on collapsed state-year outcome, and explicit reporting of 95% confidence intervals for main estimates in table notes (the paper reports CIs in the text for some specs, but not consistently).

Conclusion on format: broadly acceptable, but the bibliography must be included and figure/table annotations tightened (see specific items later).

2. STATISTICAL METHODOLOGY (critical checklist — this is the decisive part)
Overview: The author has made several good methodological choices: aggregation at state-year level for a state-year treatment, use of Callaway & Sant'Anna (CS) as primary estimator, reporting standard errors clustered by state, reporting wild cluster bootstrap p-values and Goodman-Bacon decomposition, event studies, placebo outcomes, heterogeneity analyses. These are important strengths. Nevertheless, several critical statistical/methodological issues remain that make the paper premature for publication in a top general-interest outlet.

I evaluate the mandatory elements one-by-one.

a) Standard errors / inference
- The paper does report standard errors in parentheses for coefficients in the main TWFE and CS tables (Table 3 / Table \ref{tab:main} and others). Wild cluster bootstrap p-values are reported for main specs. This passes the basic requirement that coefficients be accompanied by inference.
- However: the state-year outcome is an aggregated statistic computed from microdata without weighting (see Data, Section 3.4). Aggregating microdata to state-year percentiles then treating the state-year as an observation and clustering by state is acceptable in principle, but the author must be explicit and rigorous about sampling variability in the estimated percentiles. The standard errors reported appear to come solely from the DiD clustering across state-years; they do not account for estimation uncertainty in computing state-year percentiles. This introduces potential understatement/overstatement of uncertainty. Use a two-step variance estimator or bootstrap that accounts for both steps (percentile estimation and state-level panel regression), or show that percentile estimation error is negligible relative to panel-level variation. At present this is not addressed sufficiently.
- The number of clusters: ~50 states (22 treated, 28 controls) is borderline for cluster-robust inference. The author already uses wild cluster bootstrap p-values, which is good. But details are incomplete: number of bootstrap reps, method (Rademacher or Webb), whether bootstrap clustered by state preserves serial correlation — report implementation details. If the main CS estimator delivers standard errors by a different method, specify and justify.
- Report 95% confidence intervals for all main estimates in tables (not only in text) and report p-values (wild cluster bootstrap p-values) consistently.

b) Significance testing and CIs
- The manuscript reports standard errors, wild-cluster p-values and (for at least one spec) a 95% CI. But the main CS ATT has a very wide CI [-0.224, 0.124] and high p-value; the author acknowledges imprecision. This is honest, but the paper must not over-interpret point estimates when inference is weak. Be explicit throughout on which results are statistically distinguishable from zero.

c) Sample sizes
- State-year sample size is clearly reported as 600 observations (50 states x 12 years). But some subgroup analyses (gender-specific 300 cells, etc.) are less precisely described. For each regression/table the author must report exact N (state-year cells used), number of treated states, number of never-treated states used as controls, number of cohorts and their sizes, and how many state-year cells were excluded due to small cell size (<100 observations when computing percentiles).
- When computing gender-specific state-year percentiles the author notes that ~300 state-year cells remain per gender. Provide a table listing the number of observations (state-year cells) for every reported regression (main, job changers, industry groups, gender splits, etc.). In some tables Observations column shows 600 even for gender splits—this is inconsistent with the data appendix text that says fewer cells remain for gender subsamples. Fix inconsistencies.

d) DiD with staggered adoption
- PASS on the crucial methodological point: the author uses Callaway & Sant'Anna (2021) estimator as the primary approach, uses Sun & Abraham as robustness, and reports a Goodman-Bacon decomposition. This is excellent and appropriate for staggered adoption. The manuscript also reports cohort-specific group-time ATTs and dynamic event studies using CS. That addresses concerns about negative weights and heterogeneous effects in TWFE. Good.
- A couple of caveats:
  - The CS estimator requires choosing a control group (never-treated vs not-yet treated) and models for propensity scores / covariate adjustment. The paper reports results using never-treated and not-yet-treated controls in robustness, which is good. But it is important to document how many states are never-treated in the sample and how CS weights cohorts and time periods — provide exact numbers and show sensitivity to alternative CS specifications (e.g., with/without covariate adjustment, different covariate sets).
  - Late-adopting cohorts (2021–2023) have few or zero true post-treatment income observations due to the ACS income reference year lag (INCOME measured over the prior 12 months). The paper acknowledges this, but it is essential to demonstrate that CS dynamic estimates correctly omit group-time cells without valid post-treatment income, and to show robustness when restricting to cohorts with at least two full post-treatment years. If many cohorts have few post periods, the CS ATT may be driven mainly by early cohorts; show cohort-specific weights and contributions (some of this is in the Bacon decomposition but do more).

e) RDD
- Not applicable.

Overall methodological verdict: The paper meets the basic statistical inference requirements (coefficients reported with SEs, p-values, CIs; uses CS estimator). But there are critical omissions in uncertainty accounting (two-step percentile estimation), insufficient reporting of sample sizes and cohort composition, and sensitivity checks for CS implementation that must be addressed. These issues are substantive: they affect the reliability and interpretability of the inference. If not corrected, they make the paper unacceptable for a top journal.

If the author does not address these methodological points, the paper is effectively unpublishable in a top general-interest outlet in its current form. I therefore recommend substantial revision on methodology.

3. IDENTIFICATION STRATEGY (credibility assessment)
- Credibility: The staggered DiD exploiting variation in state adoption timing is a natural design. The author makes a sensible decision to aggregate the outcome to the state-year level (treatment varies at that level) and to focus analytically on job changers (the group directly affected).
- Assumptions discussed: The paper discusses parallel trends, shows event studies (CS dynamic ATT), plots pre-trends (Figure \ref{fig:trends}), runs joint pre-treatment test (p=0.42), and runs placebo outcomes. These are all appropriate.
- Remaining identification concerns:
  1. Measurement of treatment exposure:
     - The policy applies at hiring. The ACS does not identify job-to-job transitions directly; the author uses residential migration (MIGRATE1) as a proxy for job-changing. This is acknowledged as imperfect. This measurement error is directional: it likely attenuates estimated effects toward zero if the job-changer sample includes many non-job-changers and misses some job-changers. But the magnitude of bias is unknown. Better data (CPS matched data, J2J flows, LEHD job-to-job flows, or other longitudinal data that identifies job transitions) would vastly strengthen inference. At minimum, validate the migration → job-change proxy with another dataset and quantify its sensitivity.
  2. ACS income timing:
     - INCWAGE measures previous 12 months of income; treatment effective date coding (assigning quarter to analysis year or next year) partially addresses this, but late adopters still have effectively 0 post-treatment income in annual ACS. This produces unequal treatment exposure across cohorts and potentially contaminates event-study interpretation. The paper acknowledges this but must do more: for dynamic/event-study estimates, drop cohorts without reliable post-treatment observations or show robustness when restricting to cohorts with at least X post-treatment years (e.g., cohorts that adopted by 2019).
  3. Aggregation bias and percentile estimation uncertainty:
     - The author computes percentiles within each state-year cell without person weights. This choice may bias percentiles if ACS sampling probabilities vary systematically across states or over time (e.g., differential non-response), and the percentile standard errors from aggregated regressions do not incorporate sampling error in the percentiles. Remedy: compute weighted percentiles using PERWT and demonstrate sensitivity to weighting. Also compute standard errors that account for the two-step estimation (e.g., cluster bootstrap across individuals within states and years, or analytical delta method).
  4. Spillovers and general equilibrium:
     - Multi-state employers may change hiring practices nationwide or across borders; control states that are "never-treated" may in practice be partially treated via firm-level policy. The manuscript mentions the possibility (in Limitations) but does not check for cross-border spillovers, e.g., by excluding border counties or analyzing firms that operate only within-state. Consider tests for spillovers (e.g., distance to treated state) or using county-level variation where feasible.
  5. Confounding concurrent policies:
     - Some states adopted salary history bans together with other pay transparency or labor laws (e.g., salary range posting, equal pay audits). The paper mentions concurrent policies as a concern; do DID specifications controlling for other contemporaneous policy adoptions (or explicitly excluding states with multiple simultaneous labor policy changes) and show that results persist.
- Placebo and robustness tests: Good set of placebo outcomes (mean wage, employment rate, labor force participation) that are null. Also shows alternative control groups and alternative estimators. But more robustness is needed along the lines above.

Bottom line on identification: The strategy is plausible and the author takes appropriate steps (modern estimators, event study, heterogeneity). However, identification still hinges on (i) the job-changer proxy, (ii) correct timing of treatment given ACS income lag, and (iii) accounting for percentile estimation uncertainty and potential spillovers. These must be addressed quantitatively before I would accept the identification as credible for a top journal.

4. LITERATURE (missing references and required citations)
- The paper cites many relevant works, including Callaway & Sant'Anna (2021), Goodman-Bacon (2021), Sun & Abraham (2021), Bertrand et al. (2004), Cameron & Miller (2008), and literature on pay transparency and salary history effects. Good.
- However, the literature review can be strengthened by adding papers in three categories: (A) methodological DiD literature on inference in staggered designs and alternative inference methods beyond CS/Sun-Abraham; (B) labor-market/job-to-job flows and measurement of job changers; (C) related empirical evidence on policies restricting employer access to information and their unintended consequences (e.g., "ban the box" literature), and on wage dispersion measurement issues (top-coding, percentile estimation).
- Specific recommended additions (minimum set). Please add these citations and short discussion of why they matter to this project:

  1) De Chaisemartin & D’Haultfœuille (2020) — develops alternative DiD estimator for staggered adoption and discusses inference. The author cites "dechaisemartin2020two" in the Related Literature (Section 2.3), but ensure full citation and engagement (how does CS compare to de Chaisemartin in small samples?).

  Provide BibTeX (example):
  ```bibtex
  @article{deChaisemartin2020two,
    author = {de Chaisemartin, Clément and D'Haultfœuille, Xavier},
    title = {Two-way fixed effects estimators with heterogeneous treatment effects},
    journal = {American Economic Review},
    year = {2020},
    volume = {110},
    pages = {  1--40 } 
  }
  ```

  2) Abadie, Athey, Imbens, and Wooldridge (2022) — recent survey on inference in causal studies and DiD settings (if relevant). If including, explain how it informs inferential choices (two-step estimation, bootstrap).

  Example BibTeX:
  ```bibtex
  @article{abadie2022inference,
    author = {Abadie, Alberto and Athey, Susan and Imbens, Guido and Wooldridge, Jeffrey},
    title = {When should you adjust standard errors for clustering?},
    journal = {Journal of Econometrics},
    year = {2022},
    volume = {232},
    pages = {1--38}
  }
  ```
  (If journal/volume info differs, replace with correct bibliographic details.)

  3) Moscarini & Postel-Vinay (or better: Davis & Haltiwanger) — job-to-job flow literature that can be used to motivate better proxies or to claim that migration is an imperfect proxy. Papers documenting measurement of job changes and matched employer-employee data would be useful. Suggested: Fallick & Fleischman (2004) on job-to-job flows or Davis & Haltiwanger (1999) on shocks and reallocation.

  Example BibTeX:
  ```bibtex
  @article{fallick2004job,
    author = {Fallick, Bruce and Fleischman, Charles A.},
    title = {Employer-to-employer flows in the U.S. labor market: the complete picture of gross worker flows},
    journal = {Economic Perspectives (Federal Reserve Bank of Chicago)},
    year = {2004},
    volume = {QII},
    pages = {  28--51}
  }
  ```

  4) "Ban the Box" literature and papers on information restriction unintended consequences — e.g., Doleac & Hansen (2016), and possibly Agan & Starr work. The manuscript cites Agan (ban the box) but should cite Doleac & Hansen and others to emphasize potential unintended consequences when employers substitute to other signals.

  Example BibTeX:
  ```bibtex
  @article{doleac2016ban,
    author = {Doleac, Jennifer L. and Hansen, Benjamin},
    title = {Does 'Ban the Box' Help or Hurt Low-Skilled Workers? Statistical Discrimination and Employment Outcomes When Criminal Histories Are Hidden},
    journal = {NBER Working Paper},
    year = {2016},
    volume = {},
    pages = {}
  }
  ```

  5) Papers on calculating percentiles and survey weighting / top-coding concerns in inequality measurement: use Pachucki? More properly: use Jenkins 2015 on inequality measurement or von Hippel on top-coding imputation; or use "Jenkins, S. P. (2015)" as example for complex survey percentiles and standard errors. Include citation and explain that computing unweighted percentiles may bias state-level inequality estimates.

  Example BibTeX:
  ```bibtex
  @article{jenkins2015measuring,
    author = {Jenkins, Stephen P.},
    title = {Measuring income inequality using probability sampling data},
    journal = {Oxford Bulletin of Economics and Statistics},
    year = {2015},
    volume = {77},
    pages = {2--15}
  }
  ```

- Explain why each is relevant: Each recommended citation illuminates a specific threat/approach the paper must contend with (staggered DiD inference, measurement of job changes, substitution/unintended effects, percentile estimation and survey weighting, etc.). Add them and discuss briefly in the literature or methods sections.

5. WRITING QUALITY (critical)
Overall, the prose is competent and organized. The paper is generally readable and the structure is logical. Still, for a top general-interest journal the writing must be crisp, concise, and narrative-driven. Below are specific writing-related critiques and suggestions.

a) Prose vs. bullets: The paper is written in paragraphs; there are only limited bulleted lists (e.g., variable lists in Data). This is acceptable.

b) Narrative flow:
- The Introduction clearly motivates the question and situates the contribution. However, the Introduction is long and attempts to cover related literatures, mechanisms and preview findings in great detail; tighten this to sharpen the narrative hook. Put substantive robustness checks and caveats into later sections.
- State more prominently (in the Introduction) the magnitude and statistical precision of the main results. The current intro focuses on point estimates; be explicit about the imprecision as a limitation.

c) Sentence quality:
- Some paragraphs are long and include many subordinate clauses. Shorten sentences in key paragraphs (Intro, Results summary, Limitations) to improve clarity.
- Avoid normative language that is not strictly supported by results (e.g., "These results suggest" is fine; avoid stronger causal claims when CIs include zero).

d) Accessibility:
- Explain technical terms on first use for a non-specialist reader (e.g., "staggered adoption", "two-way fixed effects" (TWFE), "Callaway-Sant’Anna" — give one-sentence intuition for the estimator).
- Provide substantive intuition for why the 90-10 log gap is the preferred metric versus variance or other inequality measures; clarify units (log points) and what a 0.05 log-point change means in percentage terms. The paper does some of this, but ensure clarity and consistent units in tables and text.

e) Figures/tables:
- Each figure/table must be entirely self-contained: title, clear axis labels (units), legend, sample description (N, state count, treatment coding), estimator used, standard error method, and any weights.
- The event study figure must show the omitted period, confidence bands, and annotate whether CIs are bootstrap or analytic. Current figure notes mention multiplier bootstrap but do not state exact implementation.

6. CONSTRUCTIVE SUGGESTIONS (how to make the paper stronger)
If the paper is to be pushed to a resubmission likely to be considered publishable in a top outlet, the author should do the following.

High-priority methodological fixes (required):
1. Account for two-step uncertainty: When the dependent variable is an estimated percentile computed from survey microdata, the regression standard errors should incorporate that estimation error. Implement a two-step bootstrap that resamples individuals within state-year cells (or performs a block bootstrap by state-year) to compute uncertainty in state-year percentiles and then re-estimate DiD effects. Alternatively, analytically derive the variance of estimated percentiles and include that in inference. Show results (SEs, CIs, p-values) with this corrected inference; discuss whether results change.

2. Use survey weights for percentile estimation (PERWT) and show sensitivity: Compute weighted percentiles (using ACS person weights) for state-year cells and re-run all main regressions. Report whether results change in magnitude or precision. If computational time is a concern, provide a clear justification for unweighted percentiles and demonstrate minimal difference in a subset of states/times.

3. Improve measurement of job changers: The migration proxy (MIGRATE1) is an imperfect measure. Two paths:
   - Best: supplement ACS results with an analysis using a dataset that tracks job-to-job transitions directly (CPS matched files, JOLTS, LEHD/OD), even for a subset of years, to validate or replicate findings on job changers. If possible, show CS/TWFE estimates on a dataset with direct job-change indicators.
   - If not possible, quantify the sensitivity of results to misclassification. Use bounding exercises or simulation showing how much attenuation to expect given plausible misclassification rates. Cite literature on migration → job-change correlation.

4. Address ACS income timing explicitly:
   - Re-code treatment assignment with more precise timing: use survey interview month to align the 12-month income reference period with policy effective dates as closely as possible (the paper mentions interview month but does not fully exploit it). Use month-level treatment coding or limit the sample to respondents whose income reference period is entirely post-treatment for treated units.
   - Alternatively, restrict analyses to cohorts with sufficient true post-treatment observations (e.g., exclude 2021–2023 adopters lacking at least two full post-treatment years) and show how results change.

5. Document CS implementation details and sensitivity:
   - Report number of never-treated states and not-yet-treated states, cohort sizes, exactly which states contribute to which group-time ATTs.
   - Show cohort-specific ATTs with bootstrapped CIs and the weight each cohort contributes to the aggregate ATT. Some of this is in the appendix but expand it and be explicit.
   - Show CS results with and without covariate adjustment (which covariates?), and with different choices of control group (never-treated only, not-yet-treated only, combined). Show that results are robust to these variations.

6. Spillover and concurrent policy checks:
   - Test for spillovers by (a) excluding border counties or states next to treated states, or (b) examining whether firms that operate multi-state show pre/post changes in control states, if possible.
   - Control for other contemporaneous policy adoptions (e.g., pay transparency laws, changes in minimum wage, equal pay audits) that could confound estimates. Construct a state-year policy index or include binary indicators for major simultaneous policies as controls.

Medium-priority robustness and extensions (strongly recommended):
7. Weighted regressions and population inference: If percentiles are computed with person weights, consider weighting regressions by state population or otherwise showing population-representative effects.

8. Alternative outcome measures: Include standard deviation of log wages (already included), variance explained at firm/industry level if firm-level data can be obtained, and consider quantile regressions at the micro-level (if you can identify treated individuals and use individual-level outcomes with suitable clustering).

9. Mechanism tests: The paper hypothesizes standardization, anchor removal, bargaining-power equalization. Provide more direct evidence on mechanisms:
   - Use microdata on posted salary ranges (if available in some job-posting datasets) to show if employers in treated states post ranges more often after bans.
   - Survey or administrative evidence on employer practices (HR policies) would be very valuable.
   - Show whether offers (if any dataset with offers exists) compress from above by comparing changes in upper-tail percentiles within occupation × firm-size buckets.

10. Present magnitudes and welfare implications more clearly: A 0.05 log-point change in a 2.05 log gap is small in percent terms. Provide intuitive examples (e.g., “a 0.05 log-point decline corresponds to a change of X percent in the 90th relative to 10th percentile”) and discuss economic significance, not just statistical.

7. OVERALL ASSESSMENT
- Key strengths:
  - Policy-relevant question with real-world experiments (staggered state adoptions).
  - Use of modern staggered DiD estimators (Callaway–Sant’Anna primary, Sun–Abraham robustness).
  - Comprehensive empirical program: event-study, cohort ATTs, Goodman–Bacon decomposition, heterogeneity, placebo outcomes.
  - Thoughtful discussion of mechanisms and limitations.

- Critical weaknesses:
  - Inference does not fully account for estimation uncertainty in state-year percentiles (two-step inference issue).
  - Job-changer exposure is proxied imperfectly by migration; lack of direct job-to-job transition data undermines causal interpretation for the “directly affected” population.
  - ACS income timing (12-month recall) and treatment coding for late adopters introduces measurement error in treatment exposure; this is only partially addressed.
  - Precision: main CS ATT confidence intervals are wide and include zero. The author must avoid over-stating results.
  - Some aspects of the methodology and data processing (weighted vs unweighted percentiles, excluded state-year cells, bootstrap details) are not reported with sufficient clarity to evaluate robustness.
  - Bibliography inclusion and some literature engagement are incomplete.

- Specific suggestions for improvement (summary):
  - Implement two-step bootstrap or analytic variance that accounts for percentile estimation error.
  - Use PERWT to compute weighted percentiles and report robustness.
  - Validate the job-change proxy with alternate data or quantify attenuation bias.
  - Re-code treatment timing using interview month and/or restrict to cohorts with sufficient post-treatment observation.
  - Expand discussion of cohort composition and how CS aggregates group-time ATTs; provide exact cohort contributions.
  - Add missing citations and BibTeX entries as noted above.
  - Tighten prose and reposition some robustness details from Intro to Appendix to focus the narrative.

Decision (required)
Given the substantial methodological and measurement issues that must be addressed—especially the two-step inference problem for percentiles and the imperfect job-changer proxy—I recommend:

DECISION: MAJOR REVISION

You have a promising research agenda and the right broad approach, but the paper requires substantial methodological and empirical improvements and clearer presentation before it can be considered for a top general-interest journal. I look forward to seeing a revision that addresses the points above.