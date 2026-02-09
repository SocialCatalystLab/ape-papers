# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-09T14:10:52.116892
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 27301 in / 5090 out
**Response SHA256:** 369c1c867bb5e7e2

---

Summary
This is an interesting, policy-relevant and well-written paper that uses Swiss municipal referendum data and a spatial regression-discontinuity / difference-in-discontinuities design to test whether sub-national adoption of comprehensive cantonal energy laws increased or decreased subsequent federal-level support for analogous national legislation. The empirical finding — a local negative effect (preferred same-language border RDD estimate ≈ −5.9 pp, Calonico bias-corrected SE = 2.32, p ≈ 0.011; wild-cluster bootstrap p ≈ 0.06) and similar negative DiDisc result (−4.7 pp) — is novel and important for literatures on policy feedback, federalism and climate politics.

Overall I find the paper promising and potentially publishable in a top general-interest journal, but several substantive identification and robustness issues must be addressed to convince a skeptical referee and reader. Many are fixable with additional analyses and clearer exposition. Below I give (1) a short-format checklist on formatting, (2) a focused evaluation of statistical methodology and identification, (3) concrete suggestions and additional robustness checks, (4) comments on writing and presentation, and (5) an overall assessment and required decision.

1. FORMAT CHECK (technical / presentation)
- Length: Paper appears to be well over 25 pages (main text + many appendix sections and figures; I estimate ~40–60 pages in total including appendix). Pass.
- References: Bibliography is extensive and cites most standard methodological and substantive literature (Calonico et al., Keele & Titiunik, Imbens & Lemieux, McCrary, Callaway & Sant’Anna, Goodman-Bacon, etc.). Good coverage of policy feedback and Swiss politics literatures as well.
- Prose: Major sections (Intro, Conceptual framework, Institutional background, Data, Empirical strategy, Results, Discussion, Conclusion) are written in paragraph form rather than bullets. Pass.
- Section depth: Major sections generally contain multiple substantive paragraphs. Pass.
- Figures: The LaTeX source includes figures via \includegraphics; captions are informative. I could not visually inspect rendered figures here, but the manuscript provides figure captions that describe axes and samples. On visual review (when you prepare PDF), verify: (i) axes labeled with units, (ii) legend and bin widths in RDD plots shown, (iii) color scales accessible. Minor formatting note: make sure figure fonts and line weights are legible at journal size.
- Tables: Tables contain numeric estimates, SEs, p-values, sample sizes and notes. No placeholders seen. Pass.

Minor format suggestions:
- In a few tables captions, explicitly state which p-value is reported (bias-corrected, wild bootstrap, etc.) and which clustering level is used.
- Put the replication URL into the abstract footnote or main text with explicit DOI/commit hash for the version used to generate results.

2. STATISTICAL METHODOLOGY (critical)
The manuscript is methodologically ambitious and, so far, applies many of the right tools. But because statistical inference is decisive for claims, I highlight strengths and issues that need to be tightened.

What the paper does well
- Presents SEs, p-values, and 95% CIs for main results (Calonico bias-corrected RDD inference is used).
- Reports sample sizes (N) for RDD bandwidths and OLS regressions.
- Uses modern tools for staggered adoption (Callaway & Sant’Anna) and discusses Goodman-Bacon concerns.
- Uses wild cluster bootstrap and permutation inference to address few-cluster concerns.
- Implements standard RDD diagnostics (McCrary density test, covariate balance, bandwidth sensitivity, donut RDD).
- Uses Difference-in-Discontinuities to account for permanent border effects.

A. Checklist against required standards
a) Standard errors: PASS. Coefficients are reported with SEs in parentheses; RDD uses bias-corrected SEs.
b) Significance testing: PASS. p-values reported (multiple approaches).
c) 95% CIs: PASS for main RDD and other specifications.
d) Sample sizes: PASS. N is reported (overall and within RD bandwidth).
e) DiD with staggered adoption: The paper uses Callaway & Sant'Anna and discusses Goodman-Bacon; PASS conditional on detailed reporting and implementation (see comments below).
f) RDD requirements: McCrary and bandwidth sensitivity analyses are reported; PASS in principle.

B. Critical concerns and required fixes (fatal if not addressed)
1) Border-level (permanent) heterogeneity and placebo discontinuities (important)
- Table/Section "Placebo RDD on Unrelated Referendums" (Appendix) shows that other referendums (e.g., Immigration 2016 and Corporate Tax Reform 2017) have significant discontinuities at the same borders. That raises a central worry: the observed energy discontinuity could reflect pre-existing, border-level political differences (culture, parties, fiscal preferences) rather than causal feedback from cantonal energy laws.
- The author responds to this by (a) restricting to same-language borders, and (b) using Difference-in-Discontinuities with border-pair fixed effects. Both are the right strategies, but more evidence is necessary to convince readers that the DiDisc indeed isolates post-adoption changes rather than picking up divergence in other contemporaneous shocks or differential timing.

What to do:
- Show pre-treatment RDD placebo tests explicitly for the exact same border-pair sample and the exact same RD construction: run the same spatial RDD on pre-treatment votes (e.g., 2000 and 2003 referendums) using the corrected distance-to-own-border construction and the same bandwidths. You report canton-level panel pre-trends, but spatial RDD-level placebo evidence (no discontinuity before treatment) is a stronger test of the identifying assumption for the border design.
- Present border-pair-specific pre/post differences: for each same-language border pair, plot the RD discontinuity in a pre-treatment vote (e.g., 2003) and in the post-treatment energy vote; visually and statistically demonstrate that discontinuities changed after cantonal adoption (this is the DiDisc intuition but should be shown graphically and with the border-pair estimates).
- Re-run the DiDisc but show cohort-specific event-study-style estimates for border segments (or aggregated across similar cohorts) with confidence bands. If sample size limits precision, aggregate across border-pairs but still show pre-period flatness.
- Perform placebo DiDisc: pick other policy votes after the cantonal energy adoptions but that the canton laws should not plausibly affect (or that should have no causal link) — show that these do not show the same post-change in discontinuity.

If these show pre-existing discontinuities or show similar post-changes for unrelated policies, the causal claim is weakened.

2) Language measurement and local-language confounding (important)
- "Same-language borders" are defined using canton-level majority language. Some canton-majority German borders still include communities where local language is French or Italian (noted by author). Given language is the dominant predictor of vote shares (Röstigraben), measurement error here can be consequential.
What to do:
- Use Gemeinde-level language data if available (census language share) to (a) reclassify borders as same-language vs cross-language at the municipal scale, or (b) include continuous controls for % French/Italian speakers at municipality level in RDD and DiDisc specifications. If census-based municipal language data are noisy, show robustness where you (i) restrict to municipalities whose census language share > 80% German, (ii) or use a sensitivity analysis where same-language borders are defined more strictly.
- Explicitly report how many municipalities near each "same-language" border are actually small-French-speaking enclaves; show that excluding those does not alter the main estimate.

3) Few treated clusters / inference (important)
- You correctly perform wild cluster bootstrap with Webb weights and report p ≈ 0.06 for the main same-language RDD. That is borderline. The manuscript currently reports p = 0.011 (canton-clustered) and acknowledges bootstrap p ≈ 0.06 — but the conservative inference is arguably the more appropriate one given five treated cantons and ~13 border-pairs.
What to do:
- For the RDD, perform permutation inference (re-randomize treatment assignment across canton-level treated status) for the RDD estimand (not only for OLS). You currently perform permutation inference for OLS; extend it to RDD/DiDisc. This provides a finite-sample distribution under the sharp null for the exact estimator and sample construction.
- Report cluster-robust p-values for multiple clustering levels, but emphasize bootstrap/permutation results in the main text and table footnotes. If p ≈ 0.06 is the most credible number, adopt language like "statistically marginal at conservative inference (wild cluster bootstrap p≈0.06), but consistent across designs" — do not overstate significance.

4) Donut RDD and spillovers (important)
- The main RDD effect appears concentrated in the first few kilometers on the treated side (author interprets this as border-contrast salience). But the donut RDD shows attenuation and sign flip at large donut radii. This is consistent with a local effect but also suggests cross-border spillovers or local differences in selection.
What to do:
- Systematically report RDD estimates for multiple donut radii but with the same sample construction and show that estimates decline monotonically as the donut expands; discuss the MDE and precision for each donut. Present power calculations that show how much the sample shrinks and how the estimated effect is expected to attenuate by mechanical sample changes.
- Try an asymmetric bandwidth approach (different bandwidths on treated and control sides) if the treated and control distributions of distance differ.

5) Covariate balance and heterogeneous border-level confounders (addressable)
- You report balance tests for log population, urban share, turnout aggregated across pooled borders. But given variation across border pairs, show covariate balance at the border-pair level (or at least show that adjusted balance after including % language share, party vote shares in prior elections, income proxies, unemployment, and structural economic indicators is acceptable).
What to do:
- Provide balance checks for pre-treatment political outcomes (e.g., previous referendum yes-shares for related votes, vote shares for major parties in last cantonal/national elections) within RD bandwidths. If pre-treatment political differences exist, use DiDisc with border-pair FE and show stability.

6) Panel / staggered adoption estimators (clarify)
- You use Callaway & Sant'Anna and present group-time ATTs in appendix. Good. Make sure you clearly state which comparisons are used (never-treated controls vs not-yet-treated) and report aggregated ATT with appropriate standard errors and whether you use the staggered-event-time weighting.
What to do:
- Add event-study plots from Callaway & Sant'Anna that show pre-trends for treated cohorts. If pre-trends are present in some cohorts, report cohort-specific results or modify estimator (e.g., use doubly robust weighting or alternative estimators).

3. IDENTIFICATION STRATEGY — credibility, assumptions, and limits
- Identification strategy is logical: geography-based spatial RDD at canton borders is a strong design if the continuity assumption holds. The Röstigraben confound is realistic and explicitly tackled via same-language borders. The DiDisc approach is appropriate to net out permanent border differences.
- The main threats: pre-existing border-level political differences unrelated to energy policy (address via pre-treatment RDDs and DiDisc event-study), imperfect language measurement (address via municipality-level language data, reclassification), spillovers and cross-border information flows (explore donut RDDs, asymmetric bandwidths), and low effective number of treated clusters (address via permutation inference tailored to RDD and cautious presentation of p-values).
- Authors discuss many of these threats; I ask for stronger empirical evidence (pre-RDD placebos and event-studies) and clearer emphasis on conservative inference.

4. LITERATURE — missing / recommended citations (specific)
The paper cites most of the core literature. A few additional methodological papers would strengthen the design discussion and inference toolbox. These are not fatal omissions but I recommend adding them and briefly explaining relevance.

Please add and cite these (BibTeX entries provided):

1) Armstrong & Kolesár (2018): useful for robust inference and optimal critical values in RD-type settings; helps justify inference choices.
```bibtex
@article{ArmstrongKolesar2018,
  author = {Armstrong, Timothy B. and Kolesár, Michal},
  title = {Finite-Sample Optimality of Some Structural Inference Procedures},
  journal = {Econometrica},
  year = {2018},
  volume = {86},
  pages = {319--338}
}
```
Relevance: gives theoretical background on finite-sample optimal inference and may be cited when discussing small-sample inference and choice of procedures.

2) Rambachan & Roth (2020): methods for sensitivity and falsification for DiD/event-study designs and pre-trend robustness.
```bibtex
@article{RambachanRoth2020,
  author = {Rambachan, Ariel and Roth, Jonathan},
  title = {Robust and Practical Sensitivity Analysis for Difference-in-Differences},
  journal = {Working Paper},
  year = {2020},
  volume = {},
  pages = {}
}
```
Relevance: provides robustness/sensitivity tools for event-study/DiD inference which are useful for your DiDisc/staggered treatment analyses (testing how robust results are to deviations from parallel trends).

3) Cattaneo, Titiunik & Vazquez-Bare (2019) — if you plan to use robust RD inference software and discuss bias-correction; you cite Calonico 2014 and Cattaneo 2020, but a recent practical paper on implementation could help.
```bibtex
@article{CattaneoTitiunikVazquez2019,
  author = {Cattaneo, Matias D. and Titiunik, Rocío and Vazquez-Bare, Tatiana},
  title = {Alternative Approaches to Robust Inference in Regression Discontinuity Designs},
  journal = {Journal of Research},
  year = {2019},
  volume = {Available as working paper}
}
```
Relevance: supports choices of bandwidth selection and bias correction.

(If you already use packages implementing these methods, cite the package versions explicitly.)

5. WRITING QUALITY (critical but mostly positive)
- Prose quality: strong. The Introduction hooks the reader, lays out competing hypotheses, and previews results cleanly. The conceptual framework is well-structured.
- Prose vs bullets: major sections are paragraphs. Data/Methods uses brief lists where acceptable. Pass.
- Narrative flow: Good flow from theory → institutional context → data → methods → results → discussion. The border-level storytelling (near-border dip interpretation) is compelling.
- Sentence quality and accessibility: high. The manuscript is readable by non-specialists. A few places where technical choices are stated briefly should include more intuition for non-technical readers (e.g., why bias-corrected RD inference matters and how wild bootstrap works).
- Tables: Generally clear; but a few table notes should state exactly which p-values are reported and the clustering level used. Also explicitly flag whether RDD SEs are Calonico bias-corrected.

6. CONSTRUCTIVE SUGGESTIONS (analyses and presentation)
Priority empirical additions (must do before resubmission):
1. Pre-treatment spatial RDD placebo tests using the corrected distance construction and same-language border sample (e.g., apply RDD to 2000 and 2003 votes). Show flat discontinuities pre-treatment.
2. Permutation inference for the RDD and DiDisc estimators (reassign treatment to 5 of 26 cantons) and report permutation p-values for these estimators (this gives a finite-sample test tailored to your estimator).
3. Use municipality-level language shares to (a) reclassify same-language borders more precisely; or (b) include language share as local control in RDDs; or (c) restrict to municipalities with >80% German share for same-language analysis. Report how sensitive the main estimate is to these choices.
4. Provide border-pair-level pre/post visuals and statistics (forest of border-pair pre-treatment discontinuities and post-treatment discontinuities). This helps show the DiDisc assumption holds at the pair level.
5. Report covariate balance for richer pre-determined variables (past referendum outcomes, party vote shares, income proxies, employment) within RD bandwidths. If imbalance exists, show DiDisc with border-pair FE and discuss remaining concerns.
6. Emphasize the conservative inference result (wild cluster bootstrap p ≈ 0.06) in the main text and be careful with language about "statistical significance." Consider wording like "robust negative point estimate; marginally statistically significant under conservative inference" and present exact p-values/CIs.

Further helpful analyses (strongly encouraged if feasible):
7. Heterogeneity by distance: present a nonparametric plot of treatment effect by distance bins on the treated side to show how quickly the effect decays inland (you partially do this; perhaps show local slopes).
8. Mechanisms: while neighborhoods and homeowner cost salience are plausible channels, consider leveraging municipal-level proxies (homeownership rates, share of old buildings, construction permit rates, number of heat-pump installations per capita, municipal expenditures on energy programs) to show differential effects consistent with the "cost salience" mechanism.
9. Survey evidence: if any national or canton-level public opinion surveys around 2016–2017 include questions on energy policy and local experience, incorporate them (even descriptively) to corroborate mechanism claims.
10. Reframe the presentation of inference: present a small table that lists multiple inference approaches (canton-clustered, border-pair clustered, wild bootstrap, permutation RI) and their p-values/CIs for the main estimator, with short discussion of which inference is most credible.

7. OVERALL ASSESSMENT

Key strengths
- Important, policy-relevant question with a clear and novel empirical design.
- Use of spatial RDD and DiDisc is appropriate and methodologically sophisticated.
- Transparent presentation: many diagnostics and robustness checks in the appendix; replication code link provided.
- Clear writing and strong conceptual framing linking to policy feedback and federalism literatures.

Critical weaknesses (fixable)
- Potential permanent border-level confounding (placebo discontinuities for other referendums) threatens causal interpretation; stronger pre-treatment spatial RDD placebos and border-pair diagnostics are required.
- Language measurement at canton level imperfectly controls the dominant Röstigraben confound; use municipality-level language info or stricter same-language definitions.
- Inference is sensitive to clustering assumptions: conservative wild bootstrap p ≈ 0.06, so claims of "statistical significance" must be tempered and conservative inference emphasized.
- Mechanism claims (cost salience, visible counterfactual) are plausible but need stronger empirical support (e.g., heterogeneity by homeownership, building age, or survey evidence).

Specific suggestions for improvement (recap)
1. Run pre-treatment RDD placebos (2000, 2003) with corrected distance for the same sample and show no discontinuity pre-adoption.
2. Perform permutation inference for the RDD / DiDisc estimand(s).
3. Use municipality-level language shares (or stricter >80% criteria) and show sensitivity of main estimate.
4. Provide border-pair-specific pre/post plots and covariate balance.
5. Present mechanism tests using municipality-level proxies and, if possible, survey evidence.
6. Emphasize conservative inference results in the main text; avoid overstating p-values that rely on less-appropriate clustering.

Decision
The paper makes a meaningful contribution and with the additional empirical work suggested above it could be suitable for a general-interest outlet. However, the core identification issues (border-level permanent differences and language measurement) and the sensitivity of inference to few clusters require substantial additional analyses.

DECISION: MAJOR REVISION