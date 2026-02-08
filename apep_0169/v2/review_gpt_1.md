# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-03T21:31:18.097333
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 17894 in / 6477 out
**Response SHA256:** 6bb47a2df1181367

---

Summary
This is an interesting and policy-relevant paper that documents very large heterogeneity in the “self‑employment earnings penalty” by legal form (incorporated vs unincorporated), using ACS PUMS data and (what the author calls) doubly robust inverse‑probability weighting on a very large sample (≈1.4 million observations). The headline findings (Table 2 / Panel B, pp. 18–19 of the source) — a modest earnings premium for incorporated self‑employed (+0.069 log points, 95% CI [+0.058, +0.079]) and a very large penalty for unincorporated self‑employed (−0.623 log points, 95% CI [−0.635, −0.610]) — are potentially important for both the entrepreneurship literature and policy. The paper is well motivated (Introduction, pp. 2–4), situates the empirical question in a clear Roy/selection framework (Section 2, pp. 6–12), and presents many sensible robustness checks.

That said, for a submission to a top general interest journal (AER/QJE/JPE/ReStud/REStat/AEJ Policy) the paper is not yet ready. I identify format issues, major methodological/identification weaknesses that must be addressed, missing citations in methods literature, problems in the estimation and inference implementation, and several writing/clarity issues. Many of these are fixable; others require additional analysis or reframing. I recommend MAJOR REVISION.

Below I provide a rigorous, point-by-point review (format, methodology/inference requirement checklist, identification, literature, writing, constructive suggestions), conclude with strengths/weaknesses and specific required fixes, and end with a one‑line decision per your instructions.

1. FORMAT CHECK (explicit checklist)
- Length: The LaTeX source provided is substantial. Excluding references and appendix, the main text appears to be roughly 25–35 pages (Introduction through Conclusion, plus section headings and tables/figures embedded). I estimate ≈30 pages excluding references/appendix. That meets your minimum page requirement, but please confirm final compiled PDF page count. (I refer to sections by their LaTeX headings: Introduction, Theoretical Framework, Data, Empirical Strategy, Results, Heterogeneity, Robustness, Discussion, Conclusion.)
- References: The bibliography is broadly relevant to entrepreneurship and causal inference (many classic papers are present: Hamilton 2000, Heckman 1979, Hirano et al. 2003, Oster 2019, VanderWeele & Ding 2017, etc.). However, several important recent methodological papers relevant to causal inference with multi‑valued treatments, staggered DiD, and sensitivity/robustness are missing (see Section 4 below for explicit required references and BibTeX entries). Also, I expect additional policy/legal literature on incorporation costs and state variation (see suggestions).
- Prose: Major sections (Introduction, Theoretical Framework, Data, Empirical Strategy, Results, Discussion, Conclusion) are written in paragraph form (good). I note no major use of bullets in the core sections. (Good.)
- Section depth: Each major section has substantive text and multiple subsections (e.g., Theoretical Framework has subsections, Data has several subsections). However, some sections (e.g., Empirical Strategy pp. 15–18, Robustness pp. 24–26, Discussion pp. 26–29) rely heavily on assertions without granular sub‑analyses — see below.
- Figures: The source includes no standalone figures (no overlap plots, no propensity score histograms, no balance plots). You do present tables (summary and model tables) but the manuscript lacks visible diagnostic figures (PS overlap, standardized mean difference dotplot, trimmed-weight distribution). This is a problem — include at least: (i) histogram/density of propensity scores for treated and control (for each binary comparison), (ii) love/standardized mean difference plot pre/post weighting, (iii) distribution of IPW weights (show trimming impact). These are required diagnostics for IPW.
- Tables: Tables contain real numbers, CIs, Ns and appear not to be placeholders (good). Make sure all table notes fully explain estimation (e.g., whether person weights are used in estimation, how SEs are computed), and ensure every regression coefficient has SE or CI (the paper reports CIs in brackets — good).

2. STATISTICAL METHODOLOGY (critical)
The journal standards you asked me to apply are strict: a paper cannot pass without proper statistical inference. Below I check the manuscript against your required items.

a) Standard Errors
- Pass on the surface: every main point estimate in Tables 2, 3, and robustness tables is accompanied by a 95% confidence interval in brackets (e.g., Table 2 Panel B, pp. 18–19). Table A.3 (propensity score logistic) reports coefficients and SEs (Appendix Table \ref{tab:pscore_model}). So coefficients are accompanied by inference. However, how SEs/CIs were computed needs clarification and likely improvement (see below).

b) Significance testing
- Pass: p‑values and stars are reported (*** p < 0.01). However: reporting statistical significance is insufficient if inference is not implemented correctly (see c and d).

c) Confidence intervals
- Pass: 95% CIs are reported for main estimates. But the method used to generate CIs needs to be carefully justified given estimated propensity scores, trimmed and truncated weights, survey weights (person weights), and two‑step estimation. Using heteroskedasticity‑robust HC1 standard errors may understate sampling variability if the propensity score is estimated (and if survey design/weights are used). The paper currently states SEs computed using HC1 (p. 17 Empirical Strategy). This is not adequate for publication-quality inference. Recommended: (i) report bootstrap CIs that resample the survey design (or at least resample clusters/PSUs if available) and reestimate propensity scores and weights, (ii) present influence function‑based standard errors for AIPW estimators, or (iii) show that HC1 SEs are similar to bootstrap SEs in an appendix. Also account for person weights in the estimation and variance; the current description is ambiguous (see next point).

d) Sample sizes
- Pass: N is reported for analyses (e.g., summary Table 1, Table 2 bottom rows, heterogeneity Table 3). But when the author runs separate binary comparisons (incorporated vs wage, unincorporated vs wage) Ns differ; be explicit in all tables about the sample used (the notes in Table 2 do this, but clarify whether the wage worker sample is identical across the two binary comparisons and whether it is reweighted in each estimation). Also report effective sample sizes after weighting/trimming.

e) DiD with staggered adoption
- Not applicable (paper does not use DiD). No failure.

f) RDD
- Not applicable.

Conclusion on methodology checklist: The paper passes the basic inference checklist superficially (CIs, Ns present), but the current inference implementation is insufficiently credible for a top‑journal empirical paper. Specifically:
- The author claims “doubly robust” but implements IPW (Section 5). It is not clear whether an augmented IPW (AIPW/DR) estimator combining propensity score weighting and an outcome regression was used. The manuscript should: (i) clearly describe and implement the doubly robust estimator (AIPW) if claimed; (ii) if using simple IPW, remove “doubly robust” or explain the augmentation; (iii) present results from both IPW and AIPW and show they are similar.
- Standard errors must account for estimated propensity scores and weight truncation; HC1 is not sufficient. Use bootstrap (re‑estimating PS each draw) and/or influence‑function standard errors and report results.
- The ACS is a complex survey with person weights and replicate weights available. The paper must state explicitly whether and how survey weights (PWGTP) were used in estimation and in SE calculation. If survey replication (BRR, jackknife) is feasible, use replicate weights to compute robust SEs (and show they are similar to bootstrap). If the author chooses not to incorporate person weights in causal estimation, provide justification and show sensitivity.
- The IPW approach uses separate binary comparisons instead of a multinomial treatment estimator. This is defensible but requires discussion of the estimand (ATE for “being incorporated self‑employed vs wage worker in a sample where incorporated treated group and wage control group are compared”) and potential issues with non‑nested comparisons. Consider multinomial propensity score methods (Imbens 2000 / Lechner) and present those results as robustness.

If these issues are not addressed, the paper is unpublishable in a top general interest journal.

3. IDENTIFICATION STRATEGY (credibility)
- Main identification assumption: selection on observables (conditional independence) (p. 15). The author states this clearly and acknowledges it is strong (pp. 16, 27). Good to be explicit and candid.
- Diagnostics provided: propensity score overlap, covariate balance with maximum SMD = 0.007 after weighting (p. 19 Propensity Score Diagnostics), E-values and Oster (2019) coefficient‑stability analyses (Robustness Section). These are helpful but not sufficient.
What is missing / needs to be added:
  - Exact balance tables: show pre‑ and post‑weight standardized mean differences for each covariate for both binary comparisons (incorporated vs wage; unincorporated vs wage). Currently only the maximum SMD is reported; show full table and love plots (graphical).
  - Propensity score overlap plots (densities for treated/control) for each binary comparison and for key subgroups (college/no‑college). Appendix Table \ref{tab:pscore_model} reports PS model coefficients but no plot.
  - Show distributions of IPW weights (raw and truncated) and how trimming at 99th percentile affects estimates. Table A.1 shows some trimming sensitivity but more detail (plots, table of extreme weights counts) is needed.
  - Clarify whether person weights (PWGTP) were used in PS estimation, in weighting, and in outcome estimation. Mixing survey weights and IPW is nontrivial; document approach and show sensitivity to using survey weights vs not.
  - Conduct placebo/negative‑control tests: e.g., predict wages for a subsample where treatment cannot plausibly cause outcome (age group small), or use pre‑treatment variables as “outcomes” to show no effect. Since the data are cross‑sectional, consider falsification tests using outcomes that should not be affected by current employment status (e.g., height, childhood location).
  - Consider bounding approaches: This is cross‑sectional with selection on observables. Use partial identification / bounding (Manski or Lee-style bounds), or use Rosenbaum sensitivity bounds to show how much unobserved selection would be needed. The E‑value and Oster are reported, but complement with Rosenbaum bounds and demonstrate sensitivity result numerically.
  - Consider using quasi‑experimental variation to validate selection vs structural mechanisms. For example, exploit state variation in legal/administrative costs of incorporation (registration fees, processing complexity) as plausibly exogenous instrument/encouragement for incorporation. If any plausible instrument exists, present IV or difference‑in‑differences evidence; if not, clearly label estimates as conditional associations and be cautious in causal language.

Do the conclusions follow the evidence? The author’s interpretation is plausible but currently over‑confident about causality. The tone should be moderated until the additional identification analyses above are performed. The Discussion (pp. 26–29) acknowledges limitations but needs stronger caveats in the Abstract and Introduction that the results are local to the selection‑on‑observables assumption.

4. LITERATURE (missing / required references)
The paper cites many appropriate works, but several important methodological papers that a rigorous reviewer would expect are missing. Because the author uses propensity‑score and multi‑group comparisons and invokes “doubly robust” methods, they must cite and engage with these papers and potentially implement relevant estimators.

Please add (at minimum) the following references and discuss where they are relevant in the text (preferably in Empirical Strategy and Robustness):

- Goodman‑Bacon (2021) on staggered DiD (only relevant if the paper later expands to panel/DiD). If the author considers dynamic or policy variation across states (e.g., incorporation law changes) this is essential.
- Callaway & Sant’Anna (2021) for DiD with heterogeneous timing (again only if DiD is used); if not used, you can still cite to show awareness when discussing panel approaches for future research.
- Imbens (2000) on multiple treatments and interpretation of propensity scores in multi‑valued treatment settings.
- Rosenbaum and Rubin (1983) on the central propensity score literature (classic reference). The paper currently cites Abadie & Imbens (2016), Hirano et al. (2003), Bang & Robins (2005), Robins et al. (1994), but Rosenbaum & Rubin 1983 and Imbens & Rubin 2015 should also be present.
- van der Weele & Ding (2017) is cited (E‑value), good. Also add a reference to Lechner’s work on multiple treatments or Sant’Anna & Zhao (if used). If you use the AIPW estimator, cite Robins & Rotnitzky (already present) and targeted maximum likelihood literature if relevant.
- For survey weighting and variance with IPW, cite Lumley (2004) or Kerby & Carlson (if needed). (At minimum, say how you combine survey weights and IPW.)

I provide BibTeX entries for a short set of crucial missing items below (please include them and cite where appropriate):

1) Goodman‑Bacon (2021)
```bibtex
@article{goodmanbacon2021difference,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}
```

2) Callaway & Sant'Anna (2021)
```bibtex
@article{callaway2021diff,
  author = {Callaway, Brantly and Sant'Anna, Gabriel},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}
```

3) Imbens (2000) — multiple treatments / role of propensity score
```bibtex
@article{imbens2000role,
  author = {Imbens, Guido W.},
  title = {The Role of the Propensity Score in Estimating Dose–Response Functions},
  journal = {Biometrika},
  year = {2000},
  volume = {87},
  pages = {706--710}
}
```

4) Rosenbaum & Rubin (1983) — central propensity score reference
```bibtex
@article{rosenbaum1983central,
  author = {Rosenbaum, Paul R. and Rubin, Donald B.},
  title = {The Central Role of the Propensity Score in Observational Studies for Causal Effects},
  journal = {Biometrika},
  year = {1983},
  volume = {70},
  pages = {41--55}
}
```

5) Lechner (2001) or Imai & van Dyk (2004) on multiple treatments / matching
(If you plan on using multinomial approaches.)
```bibtex
@article{lechnermult,
  author = {Lechner, Michael},
  title = {Program Heterogeneity and Propensity Score Matching: An Application to the Evaluation of Active Labor Market Policies},
  journal = {The Review of Economics and Statistics},
  year = {2001},
  volume = {83},
  pages = {205--220}
}
```

Explain why these are relevant in the paper:
- Imbens (2000) & Rosenbaum & Rubin (1983) are the methodological foundation for propensity‑score approaches; since the paper relies heavily on IPW and claims doubly robust estimation, these belong in the methods discussion (Section 4).
- Lechner (2001) / Imbens (2000): the self‑employment treatment is multi‑valued (wage, unincorporated SE, incorporated SE). The paper currently runs separate binary comparisons; discussing multinomial treatments and the estimand differences is necessary.
- Goodman‑Bacon and Callaway & Sant’Anna: cite them in the Discussion or Future Work if arguing for panel or policy‑variation strategies (state incorporation costs) as future identification strategies.

5. WRITING QUALITY (critical)
Overall the manuscript is readable and well organized, but improvements are required to reach top‑journal standards.

a) Prose vs. Bullets
- Pass. Major sections are paragraph‑based. Good.

b) Narrative flow
- The Introduction effectively motivates the puzzle (pp. 2–4). The paper tells a coherent story from motivation → theory → data → method → results. However, the narrative sometimes overstates causal claims. Tighten language throughout (Abstract, Introduction, Conclusion) to emphasize conditional/associational nature of results unless stronger identification is provided.
- The Results section is clear but would benefit from more intuition and interpretation after each table (for example: decompose the log estimates into percentage changes and dollars routinely in the text; Table 1 includes mean earnings which is helpful — continue that practice).

c) Sentence quality
- Prose is generally crisp. A few sentences are long and could be split for clarity (e.g., in Discussion pp. 26–28). Use active voice more often. Place the key takeaways at paragraph starts.

d) Accessibility
- The paper is fairly accessible to an intelligent non‑specialist, but you must better explain:
  - What the IPW/AIPW estimand precisely is (ATE vs ATT), and how the separate binary comparisons map to overall inferences about “self‑employment”.
  - The meaning of “doubly robust” and what was implemented.
  - How survey weights and truncation interact with IPW.
- Define abbreviations on first use (e.g., IPW, PS, ATE, ATT). Some are defined but be consistent.

e) Figures/Tables (publication quality)
- As noted, add diagnostic figures: PS overlap, love plots for balance, IPW weight histograms, and a figure that shows how the aggregate result decomposes into within‑group effects (a bar chart of the three estimated coefficients with CIs). Tables must have clear notes explaining estimation, standard errors, weights, trimming, and sample composition. In Table 2 note how many observations are in the control group for each binary comparison and whether the wage sample is identical across comparisons.

6. CONSTRUCTIVE SUGGESTIONS (analytical & presentation improvements)
The paper is promising. To make it publishable at a top journal, I recommend the following substantive and methodological additions.

A. Estimation and Inference
1. Implement and report AIPW (augmented inverse probability weighted) / doubly robust estimators, and present both the IPW and AIPW estimates side‑by‑side. If the paper claims “doubly robust” it must actually use or clearly describe the augmented estimator.
2. Compute standard errors that account for the first‑stage propensity score estimation and weight truncation. Use nonparametric bootstrap (resample the data, reestimate PS and outcome models, recompute estimator) and report bootstrap CIs. If using person weights, use survey bootstrap or replicate weights if available.
3. Clearly document how person weights (PWGTP) are used: are they used to compute descriptive statistics only, or incorporated into PS estimation and outcome estimation? Show sensitivity to including/excluding survey weights.
4. Report effective sample sizes (e.g., sum of weights^2 / sum of weights) and provide count of observations trimmed by each trimming rule.
5. Provide pre/post balance tables (SMDs) and love plots for all covariates for each binary comparison and each education subgroup.
6. Present overlap diagnostics (propensity score density plots).
7. Report the estimated outcome regression model used in the augmentation step (if AIPW is used) and show robustness to different specifications.

B. Identification and robustness
1. Add falsification/negative‑control tests and show that the method does not produce spurious “effects” for baseline variables that cannot be affected by current employment status.
2. Provide Rosenbaum sensitivity bounds in addition to E‑value and Oster. Present a short table that shows how strong unobserved confounding must be to overturn results.
3. Consider multinomial propensity score estimation (generalized propensity scores) and techniques for multi‑valued treatments (Imbens 2000, Lechner), and show whether results are robust to that approach.
4. Explore quasi‑experimental instruments if feasible: e.g., exploited state variation in incorporation costs or a state policy change in business registration from public records — even if only as an exploratory IV or difference‑in‑differences test. If not feasible, state explicitly why.
5. Examine heterogeneity by industry and occupation where possible. The ACS contains occupation and industry codes — decompose unincorporated category by major industry/occupation groups to assess within‑category heterogeneity (e.g., gig/platform workers vs professional sole proprietors vs tradespeople).
6. Decompose earnings differences into hours vs returns per hour: present results on hourly wages or log earnings per hour conditional on working (if WAGP and WKHP permit) to see how much of the gap is intensive margin vs price.
7. Address measurement issues: the paper discusses the possibility that incorporated owners receive compensation not captured in WAGP (p. 27). Use auxiliary data or sensitivity calculations to bound possible bias from retained earnings or fringe benefits (e.g., cite Hurst et al. 2014 on underreporting).
8. Dynamics: While ACS is cross‑sectional, you can examine age cohorts, tenure proxies, or use pooled years to see whether incorporated owners’ higher earnings are concentrated at older ages (consistent with business maturation). Discuss more strongly as limitation.

C. Presentation and framing
1. In the Abstract and Introduction, be explicit and careful about causal language. Prefer “conditional on observables” or “associations controlling for rich observables” unless you augment with stronger identification.
2. Add the diagnostic plots mentioned above to the main text (or at least to an early appendix), and move some robustness tables to the Appendix but reference them clearly in the main text.
3. Clarify why 2020 was dropped (you do explain but expand briefly — p. 9), and show robustness to 2019 only and to 2019+2021 (already claimed but show the table).
4. Add a short policy subsection that discusses state heterogeneity and potential instrument strategies to tie policy claims more directly to possible interventions.

7. OVERALL ASSESSMENT — strengths and critical weaknesses
Key strengths
- Timely and policy‑relevant question: decomposition of self‑employment by legal form is important and underexplored.
- Huge sample from ACS PUMS and careful descriptive work (Table 1).
- Clear theoretical framing (Roy model + non‑pecuniary benefits).
- Offers a plausible reconciliation of conflicting literature (Hamilton 2000 vs Levine & Rubinstein 2017).
- Includes a number of robustness exercises (trim sensitivity, Oster, E‑values).

Critical weaknesses (must be addressed)
1. Inference implementation is inadequate for top‑journal standards: standard errors do not account for estimated PS, truncation, and survey design. The claimed “doubly robust” approach is not transparently implemented.
2. Diagnostics and figures are missing (propensity score overlap plots, balance tables, weight distributions).
3. Identification relies entirely on selection‑on‑observables. Additional sensitivity analyses or quasi‑experimental validation (e.g., instrument for incorporation, state policy variation) are needed to move from association to credible causal claims. At minimum, authors must substantially strengthen and present sensitivity analyses (Rosenbaum bounds, bootstrap SEs) and temper causal language throughout.
4. The multi‑valued nature of treatment is handled via separate binary comparisons. This is acceptable only with careful discussion of estimands and with robustness to multinomial methods.
5. The unincorporated category is highly heterogeneous. The paper needs more decomposition (industry/occupation, hours, part‑time vs full‑time) or caveats that the average reflects a wide mix.

Specific suggestions for improvement (concrete)
- Implement AIPW and re‑compute estimates with bootstrap CIs that reestimate PS in each replication.
- Use person weights properly (or document and justify not using them); if using survey replicate weights, use them to compute SEs.
- Add balance tables/plots and PS overlap plots to the main appendix and reference them in the text (Section 5).
- Run estimations on earnings per hour (where feasible) to separate price vs quantity effects.
- Decompose the unincorporated category by occupation/industry codes (ACS has occ/ind codes) and present heterogeneity — show which subgroups drive the large penalty.
- Add sensitivity results: Rosenbaum bounds and additional bounding calculations for possible retained earnings / measurement bias.
- Add multinomial propensity score estimates as robustness, and discuss differences in estimands.

8. MINOR/FORMAT POINTS (to be fixed)
- Table and figure numbering: ensure consistent referencing (Table 1 is called Table \ref{tab:summary_type} in LaTeX — fine, but check final PDF numbering).
- Spell out all acronyms on first use (e.g., PUMS, COW, WAGP).
- In Table notes, always state whether person weights are used in estimation and standard error calculation.
- In Appendix Table \ref{tab:pscore_model}, add p‑values or stars to coefficient table for clarity.
- Include propensity score model goodness‑of‑fit metrics (AUC) and compare PS from logistic vs random forest (you say you tried RF; show one table with PS model robustness).
- Clarify the definition of incorporated self‑employment (COW=7) — you do, but add brief note on what forms are included (S‑corp, LLC, etc.) and heterogeneity (S‑corp vs C‑corp).

9. CONCLUSION and DECISION
The paper addresses an important question and produces striking descriptive facts. However, the causal claims rest on a set of identification and inference choices that are currently inadequately implemented and documented for a top general‑interest journal. The author must implement robust doubly robust/AIPW estimation, credible standard errors (bootstrap or replicate weights accounting for first stage), add diagnostic figures, explore heterogeneity within the unincorporated group, and either find quasi‑experimental variation or substantially strengthen sensitivity analyses and temper causal language.

If the author thoroughly addresses the issues above, this paper could make an influential contribution. As it stands, major revision is required.

DECISION: MAJOR REVISION