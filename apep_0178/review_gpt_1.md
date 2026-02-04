# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-03T22:53:31.572435
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 16927 in / 6143 out
**Response SHA256:** c2ed08235d1ecaf8

---

Thank you for the opportunity to review this paper. Below I give a detailed, rigorous assessment organized according to your requested template. Overall verdict up front: the paper addresses an important and policy-relevant question, uses an excellent data source and large sample, and produces striking and potentially novel descriptive findings. However, the identification strategy and robustness reporting are insufficient for a top general-interest journal in its current form. Substantive issues around omitted variables, inference under weighting, and mechanistic evidence must be addressed. I therefore recommend MAJOR REVISION. Details follow.

1. FORMAT CHECK

- Length: The LaTeX source as provided appears to be roughly 20–30 pages of main text (hard to judge exactly from source). The requirement in your prompt is "at least 25 pages (excluding references/appendix)". The main text looks long but may be borderline. Please confirm page count in the compiled PDF minus references and appendix. If under 25 pages, expand exposition and robustness sections (many top journals expect a detailed appendix too).

- References: The bibliography is generally solid on entrepreneurship and self-employment literature (Hamilton 2000; Levine & Rubinstein 2017; Hurst et al. 2014; Fairlie & Robb). However:
  - The causal inference / program-evaluation literature relevant to propensity-score/IPW and sensitivity analysis is incompletely cited. See suggestions below (Rosenbaum & Rubin, Dehejia & Wahba, Imbens & Rubin, Hernán & Robins, etc.). Also some DiD/RDD staple references (Goodman-Bacon, Callaway & Sant'Anna, Lee & Lemieux, Imbens & Lemieux) are missing; while this paper does not use DiD or RDD, a top journal review will expect these methods and their pathologies to be acknowledged when discussing alternatives and limitations.
  - Literature on gendered returns to entrepreneurship, access to finance, and networks has some gaps (more recent papers on gender and entrepreneurship, network effects, and differential access to capital should be cited).

- Prose: Major sections (Introduction, Theory, Data, Empirical Strategy, Results, Discussion/Conclusion) are in paragraph form, not bullets. Good.

- Section depth: Most major sections (Intro, Data, Empirical Strategy, Results, Robustness, Gender) read substantive and contain multiple paragraphs. However, some subsections (e.g., “Propensity Score Diagnostics” in Robustness) make claims about diagnostics but do not present the actual tables/figures—these should be included and expanded to meet the expectation that each major section has 3+ substantive paragraphs plus supporting tables/figures.

- Figures: The source references figures (e.g., fig14_atlas_combined.pdf, fig12_state_bar_chart.pdf, fig11_gender_heterogeneity.pdf) but the LaTeX source does not embed the actual images here for review. The captions are informative. When submitting, ensure:
  - All figures have labeled axes, legends, and units.
  - Maps/bar charts use colorblind-friendly palettes and include precise scales.
  - Each figure includes notes with data source, estimation method, confidence intervals, and sample used.

- Tables: The tables shown (summary statistics, main results, heterogeneity) contain numbers and confidence intervals. No placeholders. But see below about standard errors and reporting conventions.

2. STATISTICAL METHODOLOGY (CRITICAL)

A paper cannot pass review without proper statistical inference. Below I evaluate whether the paper meets the standards.

a) Standard Errors:
- The paper reports 95% confidence intervals in square brackets for main estimates (e.g., Table 4 / Table \ref{tab:main}). That is acceptable as long as the reported confidence intervals are computed correctly and reflect the full estimation uncertainty (including the estimation of the propensity score and the weighting/trimming). The tables do not display standard errors in parentheses, but the CIs are shown. This is acceptable so long as the method for computing CIs is clearly stated and appropriate (see below).
- The Methods text (Sec. Empirical Strategy) says "Standard errors are computed using heteroskedasticity-robust sandwich estimators." This is insufficient. For IPW/AIPW, inference must account for the fact that weights are estimated (propensity-score uncertainty) and may be truncated. Robust sandwich SEs that treat weights as fixed can understate uncertainty.
- Required: Report how SEs/CIs are computed. Preferably:
  - Use influence-function-based variance formulas appropriate for IPW/AIPW estimators (cite Hirano, Imbens, Ridder 2003), or
  - Use bootstrap (clustered if necessary) that re-estimates propensity scores in each bootstrap sample (recommended), and report bootstrapped CIs. If bootstrap is used, state number of replications and sampling scheme.
- Failure in current draft: The paper does not state whether the variance estimate accounts for estimated propensity scores or whether bootstrapping was used. Please report and, if not done, redo inference with valid variance estimation. Until then, the paper's inference is not fully credible.

b) Significance Testing:
- The paper reports p-level markers (*** etc.) and 95% CIs. This is fine, but again depends on valid SEs.

c) Confidence Intervals:
- 95% CIs are reported for main results. Good, but see note above about correct computation.

d) Sample Sizes:
- N is reported for many analyses (e.g., Table \ref{tab:main}, Table \ref{tab:hetero_educ}, Table \ref{tab:state_results}, Table \ref{tab:gender}). Good. But be explicit in every regression/table what sample was used, whether person weights were applied in estimation, and whether weights were used in inference.

e) DiD with Staggered Adoption:
- Not applicable: the paper does not use DiD. (Nevertheless, if the paper discusses policy implications or alternative designs, acknowledge the issues in TWFE with staggered adoption if you propose DiD in future work.)

f) RDD:
- Not applicable.

Bottom-line for methodology: The paper does include precision measures (CIs) and sample sizes. However, it currently fails a top-journal standard because inference details are insufficiently described and likely mis-specified (no account for estimated weights, no clustering, no robust resampling reported). In addition there are important omitted variable concerns that threaten identification (see Identification section below). Because of those issues, the methodological approach in its present form is not sufficient for publication in a top general-interest journal. This is a substantive, not merely technical, failing: without stronger identification or transparent sensitivity analysis and inference, causal or policy interpretations are premature.

3. IDENTIFICATION STRATEGY

- Identification claim: The author(s) are explicit that they estimate conditional associations under a selection-on-observables assumption (unconfoundedness / conditional independence) using IPW/AIPW (Section Empirical Strategy). That is appropriate so long as it is clearly presented as associative, not causal. The paper makes some policy claims which verge into causal interpretation; the language must be tightened.

- Are key assumptions discussed? Yes, the selection-on-observables assumption is stated (equation). The authors also present sensitivity analyses (E-values, Oster). This is good practice. However:
  - The set of covariates used in the propensity score (age, age^2, female, college, married, race indicators, homeownership, COVID period) is fairly limited given the strong selection concerns in entrepreneurship. Important omitted confounders include:
    - Industry and occupation controls (sector matters enormously for both choice to incorporate and earnings).
    - Prior earnings/wage history or pre-treatment wages (if available in ACS, perhaps not; but consider using prior-year earnings if panel is available elsewhere).
    - Hours worked and full-time status (they are outcomes but could be controlled for in secondary analyses).
    - Measures of local labor market opportunity beyond state fixed effects (MSA-level unemployment rates, industry composition).
    - Measures of business characteristics (employer vs. own-account; presence of paid employees).
    - Education depth (degree type), experience/tenure in field, immigrant status beyond race/ethnicity (nativity, year arrived).
    - Occupation and industry are probably the most important omitted covariates.
  - The omission of occupation/industry is the largest identification concern. Incorporated self-employed tend to cluster in particular industries (professional services, finance, construction), with much higher earnings distribution than, e.g., personal services and gig work. Without industry/occupation controls, the estimated "incorporated premium" may primarily reflect sectoral composition rather than legal-form returns per se.
  - The paper does some heterogeneity by education and gender, but that does not substitute for industry controls.
  - The propensity score diagnostics section claims excellent balance (SMD < 0.01). However, those diagnostics are not shown (no table or plot included). The claim is implausibly strong given only the small set of covariates used; please provide the balance tables/love plots for each binary comparison (aggregate, incorporated vs wage, unincorporated vs wage) and for key subgroups (gender, education). Also show the distribution of estimated propensity scores (histograms and kernal density), and show how weights are truncated and how many observations are affected.
  - The sensitivity analyses (E-values and Oster) are helpful but must be implemented and interpreted carefully given the IPW/AIPW framework:
    - The E-value is normally used for binary outcomes; translating log-point earnings effects to risk ratios requires care. Explain exactly how E-values were computed and justify their interpretation for continuous outcomes.
    - The Oster (2019) implementation assumptions (R^2_max = 1.3 * R^2_full) should be justified; Oster's method assumes linear regression; using it after IPW/AIPW requires clarity about which regression is used to compute R^2. Provide these regressions and sensitivity calculations in the appendix.
    - Relying solely on E-values and Oster is insufficient. Consider additional bounding approaches (Altonji, Elder and Taber 2005; use of negative control outcomes, placebo covariates), and show how large an omitted confounder would need to be in terms of observables (e.g., compare required association to strongest observed covariate).
  - The paper reports "placebo analysis among retired workers" with a null result. That test is not very informative because the relation between past self-employment and current income among retirees could be weak for many reasons; it does not mimic the selection problem among current workers.

- Placebo tests and robustness checks:
  - More checks needed:
    - Include occupation and industry in propensity score and as covariates in outcome models; show how the incorporated premium changes.
    - Control for metro/MSA labor market characteristics or include state-by-year (or state × period) fixed effects to absorb local time-varying shocks.
    - Estimate effects separately within narrow industry × occupation cells where feasible (or at least three-digit industry groups) to show within-sector incorporated vs. unincorporated contrasts.
    - Show results for 'employers' vs 'own-account' where possible—ACS has variables indicating number of persons employed by business? If not available, approximate via self-reported business characteristics (e.g., BEW?).
    - Recompute estimates weighting/unweighting with person-weights and explain whether person weights are used in estimation or only in summary statistics.
    - Report outcome regression (OLS) results with covariates (as complementary evidence).
    - Consider using an instrumental variables design if a credible instrument can be found for incorporation (e.g., local changes in incorporation fees, legal environment, or firm registration shocks), though I recognize that may be difficult.

- Do conclusions follow from evidence?
  - The descriptive finding that incorporated self-employed earn substantially more than unincorporated self-employed is well supported descriptively (mean earnings differ markedly).
  - The claim that incorporation "provides access to institutions" and that this is the causal mechanism is plausible but not convincingly identified by the current IPW approach. The authors are careful in many places to couch results as conditional associations, but the Discussion and Policy Implications sometimes make stronger causal claims. Tighten language to avoid causal statements unless further identification is provided.

- Are limitations discussed? Yes (Section Robustness and Limitations). The discussion acknowledges selection-on-observables, measurement of earnings, heterogeneity of unincorporated category, and limited geographic coverage. Good—but the limitations discussion must more directly acknowledge the magnitude of potential bias from omitted industry/occupation and entrepreneurial ability.

4. LITERATURE (Provide missing references)

The paper needs to more clearly position itself vis-à-vis key methodological and substantive literatures. Below are specific recommended additions (with short rationale and BibTeX entries). Include these especially for reviewers/editors who will look for awareness of causal-inference best practice and for the DiD/RDD classic papers if any such methods are discussed in extended work.

A. Causal-inference / propensity-score / AIPW references (missing, relevant to IPW/AIPW inference and variance estimation):
- Rosenbaum & Rubin (1983) — foundational on propensity scores.
- Dehejia & Wahba (2002) — practical demonstration of propensity-score matching and diagnostics.
- Hirano, Imbens & Ridder (2003) — efficient estimation for average treatment effects using estimated propensity scores (relevant for IPW variance).
- Imbens & Rubin (2015) — general reference on causal inference (textbook).
- Robins & Hernán (2009) / Hernán & Robins (2020) — modern causal inference approaches and g-methods.
- Austin (2009) is cited; add Rosenbaum & Rubin and subsequent AIPW literature.

Provide BibTeX entries:

```bibtex
@article{RosenbaumRubin1983,
  author = {Rosenbaum, Paul R. and Rubin, Donald B.},
  title = {The central role of the propensity score in observational studies for causal effects},
  journal = {Biometrika},
  year = {1983},
  volume = {70},
  pages = {41--55}
}

@article{DehejiaWahba2002,
  author = {Dehejia, R. H. and Wahba, S.},
  title = {Propensity Score-Matching Methods for Nonexperimental Causal Studies},
  journal = {The Review of Economics and Statistics},
  year = {2002},
  volume = {84},
  pages = {151--161}
}

@article{HiranoImbensRidder2003,
  author = {Hirano, Keisuke and Imbens, Guido W. and Ridder, Geert},
  title = {Efficient Estimation of Average Treatment Effects Using the Estimated Propensity Score},
  journal = {Econometrica},
  year = {2003},
  volume = {71},
  pages = {1161--1189}
}

@book{ImbensRubin2015,
  author = {Imbens, Guido W. and Rubin, Donald B.},
  title = {Causal Inference for Statistics, Social, and Biomedical Sciences: An Introduction},
  publisher = {Cambridge University Press},
  year = {2015}
}

@book{HernanRobins2020,
  author = {Hern{\'a}n, Miguel A. and Robins, James M.},
  title = {Causal Inference: What If},
  publisher = {CRC Press},
  year = {2020}
}
```

B. DiD / staggered adoption and TWFE pathology (even if not used, include as best-practice pointers if authors later use panel methods):
- Goodman-Bacon (2021) on decomposition of TWFE with staggered timing.
- Callaway & Sant'Anna (2021) on DiD with staggered adoption.

```bibtex
@techreport{GoodmanBacon2021,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  year = {2021},
  institution = {NBER Working Paper}
}

@article{CallawaySantAnna2021,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}
```

C. RDD classic references (if later used): Imbens & Lemieux (2008), Lee & Lemieux (2010). Provide these if the authors mention RDD.

```bibtex
@article{LeeLemieux2010,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  pages = {281--355}
}

@article{ImbensLemieux2008,
  author = {Imbens, Guido and Lemieux, Thomas},
  title = {Regression discontinuity designs: A guide to practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {615--635}
}
```

D. Entrepreneurship / gender / finance literature that should be cited:
- Recent work on gender differences in entrepreneurship outcomes and financing (e.g., papers on gender gaps in VC, networks, and earnings).
- A few suggestions (add as appropriate based on domain and framing):
  - Coleman (2000) on women's entrepreneurship and self-employment constraints.
  - Carter, Brush, Greene et al. (2003) on female entrepreneurship worldwide.
  - More recent field evidence on gender bias in investment decisions and contracting (e.g., Brooks et al. 2014 is cited; add Kuhn & Shen?).

(If you want, I can provide precise BibTeX entries for each domain-specific paper you would like added—tell me which ones to prioritize.)

5. WRITING QUALITY (CRITICAL)

a) Prose vs Bullets: Major sections are in paragraphs, not bullets. PASS.

b) Narrative Flow:
- The Introduction presents a clear, engaging puzzle and motivates the decomposition by legal form well (good hook). The flow from motivation → method → findings → implications is generally logical and coherent.
- Some transitions from empirical results to policy implications are stronger than warranted by the identification. Tone should be calibrated: emphasize conditional associations and limit strong causal language unless more convincing identification is provided.

c) Sentence Quality:
- Overall prose is crisp and well written. A few long paragraphs (e.g., Intro) could be tightened.
- Some technical terms (IPW, AIPW, E-value, Oster) are used without enough intuition for a non-specialist; but the paper generally explains methods briefly.

d) Accessibility:
- The paper is accessible to an intelligent non-specialist in economics, but econometric choices would benefit from brief intuition (e.g., why IPW is chosen over regression adjustment or matching; what "doubly robust" means in plain language).
- Convert log-point effects frequently to percentage changes (the paper does this consistently—good).

e) Figures/Tables:
- Tables are generally clear; include exact p-values optionally. But add:
  - A covariate-balance table (unweighted vs weighted) for each main comparison (aggregate, incorporated vs wage, unincorporated vs wage), including standardized mean differences and weighted means. Include a love plot figure.
  - A table showing sensitivity of main estimates to inclusion of additional controls (industry, occupation, state × year FE).
  - For state-level tables/figures, clarify whether state estimates control for compositional differences or are raw IPW within state.

6. CONSTRUCTIVE SUGGESTIONS (to make the paper more impactful and credible)

A. Inference and Variance Estimation
- Recompute SEs/CIs with methods that account for estimated propensity scores:
  - Use the influence-function variance formulas for IPW/AIPW (cite Hirano, Imbens & Ridder 2003 and related work).
  - Or use bootstrap (resampling PSUs if ACS cluster-PUMS sampling requires; otherwise robust bootstrap), re-estimating the propensity score in each replicate and recomputing weights. Report both analytic and bootstrap results; if they differ, explain why.
- Cluster SEs where appropriate. Since the sampling units are individuals but treatment may be correlated within geographic clusters (MSA or state), cluster at least by state (given some results are by state) or at a lower level if possible (PUMA), and discuss implications.

B. Augment covariates and robustness
- Add occupation and industry controls to the propensity score and the outcome model, and show how the incorporated premium and unincorporated penalty change. These are crucial controls and likely to attenuate the incorporated premium.
- If ACS contains any variables on whether the self-employed have paid employees, firm size, or class-of-worker detail (e.g., employer vs own-account), include those as covariates or present subgroup analyses by employer status.
- Include local labor market controls: MSA unemployment rate, industry composition, or state × year fixed effects to absorb region-time shocks.
- Provide balance tables and love plots for all IPW analyses (aggregate, incorporated vs wage, unincorporated vs wage), and for key subgroups (gender).
- Be explicit about whether person-sampling weights (ACS person weights) are used in estimation; if used, describe how they interact with IPW weights (often multiply them or re-normalize). If not used, justify and show robustness when applied.

C. Mechanisms and additional evidence
- To bolster the institutional-constraint mechanism, attempt to show direct or proxy evidence for channels:
  - Include occupation/industry and show whether the incorporated premium remains within industries (suggesting a legal-form effect) or disappears (suggesting composition).
  - Examine access to capital proxy: use homeownership/median house value or ZIP-level lending rates if available; show whether the incorporated premium is concentrated among those with collateral.
  - Examine use of benefits or retained earnings proxies: if ACS has questions on self-employed business income vs. wage/salary breakdown, use them to check whether incorporated owners report more business income vs. wage.
  - Use interaction analyses: e.g., does the incorporated premium vary by homeownership (proxy for wealth) or by presence of college degree? The paper already does some heterogeneity by education and shows interesting patterns; extend to interactions with homeownership and occupation.
- If possible, bring in complementary administrative data or surveys that record business status, paid employees, or firm-level revenue (e.g., SUSB, non-public business registers), even if only as corroboration for the mechanisms.

D. Sensitivity and bounding approaches
- Present Altonji, Elder & Taber-style bounds or follow-up sensitivity analyses that benchmark the strength of an omitted confounder to observed covariates (i.e., “would need to be X times as strong as marital status to explain away the effect”).
- Be transparent on assumptions behind Oster calculation; provide effect of varying R^2_max.

E. Presentation and emphasis
- Soften language around causal claims: replace “incorporation provides access to credit that amplifies returns” with “incorporation is associated with features consistent with institutional access; mechanisms are suggestive but not definitively identified.”
- Emphasize the policy implication that composition matters: when policymakers look at self-employment, they should disaggregate by legal form.

7. OVERALL ASSESSMENT

- Key strengths:
  - Important and policy-relevant question with fresh framing (legal-form decomposition).
  - Exceptional sample size (1.4 million) enabling precise heterogeneity analyses.
  - Clear and engaging presentation of core descriptive patterns and heterogeneity (gender, geography).
  - Use of IPW/AIPW and sensitivity analyses (E-values, Oster) shows awareness of causal concerns.

- Critical weaknesses:
  - Identification is fragile due to omitted key covariates (industry/occupation, employer status, prior wage history, business characteristics). These omissions likely bias the estimated incorporated premium.
  - Inference details are incomplete: need variance estimates that account for estimated propensity scores and possible clustering; bootstrap recommended.
  - Some robustness claims (very small SMDs) are asserted but not documented with tables/figures.
  - Mechanisms are plausible but under-evidenced; strengthening mechanism tests is necessary for policy interpretation.
  - Some sensitivity tools (E-value, Oster) are used without fully explaining implementation details and assumptions.

- Specific suggestions for improvement (summary):
  1. Add industry and occupation controls to the propensity score and outcome regressions and show how estimates change.
  2. Provide full propensity-score diagnostics (balance tables, love plots, PS distributions) in the appendix.
  3. Recompute SEs/CIs using bootstrap or influence-function-based variance that accounts for estimated weights; cluster where appropriate.
  4. Include additional robustness checks: state × year FE, MSAs, full-time-only samples (already partly done), and employer vs own-account splits if possible.
  5. Strengthen mechanism tests using proxies for access to capital, clients, and networks.
  6. Soften policy claims that imply causality until additional identification or convincing robustness is established.
  7. Expand literature citations for causal-inference methods and for gender/entrepreneurship nuances; include the BibTeX entries I provided above.

8. DECISION

Given the importance of the question and the promise of the data and findings, but given the substantive identification and inference issues described above, my recommendation is:

DECISION: MAJOR REVISION

(If the authors address the methodological concerns—especially industry/occupation controls, valid variance estimation for IPW/AIPW, detailed balance diagnostics, and stronger mechanism tests—this paper could be a strong candidate for a top general-interest journal. For the current submission, the paper is not yet publishable in such venues.)