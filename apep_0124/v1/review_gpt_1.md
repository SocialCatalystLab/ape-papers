# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-01-31T22:30:07.065785
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 20394 in / 8000 out
**Response SHA256:** 26a99f32ab2a4e27

---

Thank you for the opportunity to review this interesting paper. Below I provide a thorough, rigorous review aimed at improving the paper’s chances at a top general-interest or policy journal. I focus first on format issues, then give a detailed assessment of the statistical methodology and identification, followed by literature suggestions (with concrete BibTeX entries), writing/organization feedback, constructive suggestions for analyses to add, and a final overall assessment and decision.

Summary of paper (one-sentence): The author uses a municipal-level regression discontinuity (RDD) around the 50% yes-vote cutoff for nationally passing federal referendums in Switzerland (2010–2019) to estimate whether narrowly “losing” locally (voted against a referendum that passed nationally) reduces subsequent turnout in referendums in the same policy domain, finding a precise null (point estimate 0.05 pp, SE = 0.84).

Overall impression: The research question is important, the Swiss setting is a strong and creative context for identification, and the author has implemented a number of standard RDD validity checks (McCrary test, bandwidth sensitivity, polynomial and kernel checks, covariate balance). However, there are several substantive methodological and inferential gaps (pooling across referendums without adequately addressing referendum-specific heterogeneity; treatment of inference with clustered/multiway dependence and relatively few clusters; choice of estimand/weighting; outcome construction and potential selection; and some robustness analyses missing or underdeveloped) that need to be addressed before this paper is publishable in a top general-interest or policy journal. I recommend MAJOR REVISION. Below are details.

1. FORMAT CHECK (required)

- Length: The manuscript (main text + appendices) appears to be about ~39 pages (appendix included; main text excluding appendices appears to be ~26–30 pages). That exceeds the 25-page informal threshold you specified. (I saw page numbers 38–39 in the appendix images.) Length is acceptable for a top journal submission if the core text (intro, methods, results, discussion) is crisp; some appendix material may remain extensive.

- References: The paper cites many relevant references (Anderson et al. 2005; Blais & Gélineau 2017; Lee 2008; Calonico et al. 2014; Cattaneo et al. 2015/2020; McCrary 2008; Caughey & Sekhon 2011; Mettler & Soss 2004; Soss 1999). However, several foundational and widely-cited methodological works are missing or not discussed in the text (see Section 4 below). The theoretical/political behavior literature coverage is reasonable but could be expanded in places (see Section 4).

- Prose: Major sections (Introduction, Institutional Background, Data, Empirical Strategy, Results, Discussion, Conclusion) are written in paragraph form. There are many well-structured paragraphs. I did note some lists in the Data Appendix and in some parts of the institutional description, but the main sections are paragraphs, not bullets—this meets your requirement.

- Section depth: Each major section (Intro, Institutional Background, Data, Empirical Strategy, Results, Discussion) has multiple substantive paragraphs (3+), so the depth-of-section requirement is satisfied.

- Figures: Figures are present (density of running variable, RD plots, bandwidth sensitivity). Axes appear labeled in the included figures. However, some figure axes labels and notes are sparse (e.g., Figure 3 would benefit from clearer labeling of binned means: bin width, number of bins, units). The appendix figures are small in the provided images—make sure in the submission the figures are publication-quality with legible fonts and full captions.

- Tables: The paper contains tables with real numbers (summary statistics, RD estimates, placebo tests, bandwidth sensitivity). I did not see any placeholder tables. Table notes could be expanded (e.g., exactly how N within bandwidth is computed, what weighting if any used).

2. STATISTICAL METHODOLOGY (CRITICAL)

A paper cannot pass review without rigorous inference. Below I check the key items you required.

a) Standard Errors: PASS (the author reports cluster-robust SEs, provides p-values, and reports a 95% CI for the main estimate). Example: Main effect 0.05 pp with SE = 0.84 and CI [-1.60, 1.70] reported (Section 5.3, Table 4).

b) Significance Testing: PASS (p-values reported; tests for McCrary and covariate balance reported).

c) Confidence Intervals: PASS for main result (95% CI reported).

d) Sample Sizes: PASS — N within bandwidth and full sample N are reported in tables (e.g., Table 4 shows N within bandwidth (left/right/total) and full sample N).

e) RDD-specific requirements: PARTIAL PASS. The author runs McCrary density test; presents bandwidth sensitivity (0.5–1.5× optimal); uses rdrobust with bias correction (Calonico et al. 2014) and reports robustness to polynomial order and kernel. These are appropriate and required.

However, several critical inference/implementation issues remain (see key problems below). Because the paper pools across 56 referendums and 2,122 municipalities, implementation and inference need additional careful treatment before I could endorse publishability.

Key methodological and inference concerns (major):

1) Pooling across referendums without adequately accounting for referendum-specific conditional expectations and heterogeneity. The RDD relies on the assumption of continuity within each running-variable instance (i.e., within each referendum, conditional expectation of potential outcomes is continuous at the municipal 50% threshold). Pooling many referendums is common in practice, but it must be done carefully:

   - The paper does not explicitly state whether the local polynomials / rdrobust estimations include referendum fixed effects, referendum-specific trends, or otherwise allow the conditional mean function to differ by referendum. If estimation simply pools all observations across referendums and fits a single local polynomial, that implicitly assumes the same functional relationship between municipal yes-share and subsequent turnout across all referendums. That is unlikely to hold.

   - Remedy: Either estimate the RD separately for each referendum and then meta-analyze the referendum-level estimates (e.g., inverse-variance weighted), or estimate a pooled model that includes referendum fixed effects and allows the running-variable polynomial to vary by referendum (e.g., interact referendum indicators with polynomial terms or use separate local fits within each referendum). At minimum, show results with referendum fixed effects and/or per-referendum estimates aggregated (forest plot) and show that pooling is not biasing results.

   - Related point: if the running-variable distribution or the appropriate bandwidth differs by referendum, the pooled MSE-optimal bandwidth used by rdrobust may not be appropriate. Per-referendum bandwidths or a hierarchical modeling approach would be cleaner.

2) Dependence structure / clustering and limited cluster inference:

   - Author clusters at the canton level (26 clusters) and uses t-distribution with df = 25. Cantonal clustering is defensible because media and cantonal institutions generate within-canton correlation. However, there are multiple dimensions of dependence:

     (i) Repeated outcomes by municipality across multiple subsequent referendums (panel structure). Clustering at the canton level partially accounts for this but does not target the dependence at the municipality level. Municipality-level clustering might be needed (with many municipalities, that would be preferable).

     (ii) Dependence across observations arising within the same focal referendum and within the same subsequent referendum: observations from the same focal referendum but different municipalities share the same focal event and may have correlated shocks (campaigns, national context). Likewise, the same subsequent referendum outcome constitutes many observations observed simultaneously. This suggests two-way clustering (e.g., cluster by canton and by referendum or use multiway clustering by canton and by subsequent-referendum) may be appropriate.

   - With only 26 canton clusters, classical cluster-robust inference may be imprecise. The author should (a) report results with alternative clustering choices (municipality-level clustering, two-way clustering (canton × subsequent referendum), and (b) use wild cluster bootstrap t-tests (Roodman, Cameron, and Conley variants), especially if cluster count is small-ish.

   - At minimum run robustness checks using wild cluster bootstrap p-values (Cameron, Gelbach, and Miller 2008/2011), and report whether main inference (null) changes. Given the point estimate is essentially zero with a large SE, I do not expect dramatic changes, but the robustness analysis is required.

3) Estimand and weighting: municipal average vs voter average.

   - The RDD appears to be run unweighted at the municipality-referendum observation level. Municipalities vary enormously in size (eligible voters mean ~3,847 but distribution heavily skewed). The policy-relevant estimand is arguably the effect on voters (i.e., voter-weighted effect) rather than municipality-weighted effect. Which estimand does the author intend?

   - Reporting both the municipality-average and the voter-weighted RD estimates is important. Voter-weighted RD can be implemented by weighting each municipality by eligible voters (or using individual-level data if available). These two estimands can differ if effect heterogeneity correlates with municipality size (very plausible). The paper should present both.

4) Outcome construction and selection concerns:

   - Outcome is municipal turnout in subsequent referendums in the same policy domain occurring 1–3 years after the focal referendum. There are several issues:

     (i) Using only same-domain subsequent referendums may create selection: some domains have more follow-up variation than others; the distribution of subsequent referendums across municipalities may be correlated with the focal outcome or local politics. The author should show distribution of how many subsequent referendums per focal referendum, and check that the set of subsequent referendums is not itself discontinuous at the cutoff.

     (ii) Pooling outcomes across many different subsequent referendums (different issues, different national salience) requires controlling for the characteristics of the subsequent referendum (fixed effects for the subsequent referendum or modeling its influence). The author does not indicate including subsequent-referendum fixed effects; if not included, the effect might be confounded by the content or salience of those subsequent referendums.

     (iii) The choice of 1–3 years is justified as a follow-up window, but results should be shown for alternative windows (the author reports 1–2 and 2–3 in appendix—this is good) and also for the immediate next referendum (the earliest subsequent vote) to capture short-run demobilization.

5) Power, MDE, and interpretability:

   - The paper reports the 95% CI [-1.60, 1.70] and says this is precise and rules out economically meaningful effects >1.7 pp. This is a useful calculation, but the author should present a clearer power/MDE analysis tied to the estimand (municipality-weighted vs voter-weighted), and show conventional MDEs for realistic bandwidths (e.g., for the 0.5× optimal bandwidth), and the implied relative effect compared to typical GOTV interventions. The current discussion of MDE is cursory—expand it and show power curves (bandwidth vs MDE).

6) Multiple inference and clustering degrees of freedom:

   - There are many robustness checks and subgroup analyses. The author reports many non-significant results; to the extent multiple hypothesis testing is used, it is good practice to discuss multiple-inference adjustments (if making many claims of null effects one could present Bonferroni or BH-adjusted p-values for heterogeneity checks). Given the main result is a null, emphasize pre-specified tests and treat exploratory heterogeneity as suggestive.

7) Local randomization approach and inference:

   - The author runs a local randomization permutation test in a ±0.5 pp window (~11,847 observations) and finds no effect (p=0.94); this is a useful complementary check. But I recommend reporting the exact randomization inference procedure (which statistic used in permutation, how permutations constructed across referendums) and showing per-referendum randomization inference if feasible.

Bottom line on methodology: The core RDD checks are present (McCrary, bandwidth sensitivity, kernel/polynomial, covariate balance). However, the pooling across many referendums, the way dependence is handled, the weighting/estimand ambiguity, and the link between focal and subsequent referendums need to be addressed with additional analyses. As currently implemented, these issues are serious enough that the paper cannot be accepted in top journals until addressed.

If methodology fails, the paper is unpublishable. At present, important methodological gaps remain; with rigorous additional analyses (see suggestions below) the paper could be salvaged.

3. IDENTIFICATION STRATEGY

Credibility: The conceptual identification (close margins near 50% as-as-if-random assignment of local winner/loser) is appropriate and well motivated for Swiss municipal referendums. The authors correctly note that policy outcome is nationally determined and is identical across municipalities for passing referendums; thus local “winning” is only a local psychological/informational treatment rather than a policy difference—this makes for a clean “psychological treatment” RDD.

However, the practical implementation of identification could be sharpened:

- Continuity assumption: The author states it and conducts McCrary and covariate-balance tests—good. But continuity must be argued and tested per referendum or make explicit the pooling approach used. Provide per-referendum McCrary density checks for a subset of referendums (e.g., show the distribution of the running variable near the cutoff for a randomly selected subset or for the narrow-bandwidth set).

- Plausibility of “as-if random”: Good argument about no actor having incentive/ability to manipulate municipal referendum counts. But the author should discuss potential local get-out-the-vote strategies by partisan actors that could push municipalities around 50% and whether these would threaten the design (the author can test whether municipalities just above 50% had unusual campaign spending or organizational presence—if spending data are unavailable, use proxies).

- Placebo tests: The current placebo cutoffs (30%, 40%, 60%, 70%) are useful; also include leads/lags placebo: test whether future subsequent turnout (prior to focal referendum) shows a discontinuity at 50% to check for pre-existing differences.

- External validity & interpretation: The author explains that the RDD identifies local-average treatment effects for municipalities near the cutoff and discusses habituation vs mobilization channels. The discussion is adequate, but more explicit statements about estimand (municipality-average vs voter-average) and local nature of result (LATE for municipalities near 50) are needed.

4. LITERATURE (Provide missing references)

The paper cites many relevant works but is missing several canonical and very relevant references. The policy and political behavior literature coverage is reasonable but can be strengthened.

Methodological literature to add (must be cited and briefly discussed in Empirical Strategy / Appendix):

- Imbens, Guido W., and Thomas Lemieux. 2008. "Regression discontinuity designs: A guide to practice." Journal of Econometrics. This is a foundational practitioner’s guide to RD methods and should be cited when laying out the RDD assumptions and estimation choices.

- Lee, David S., and Thomas Lemieux. 2010. "Regression Discontinuity Designs in Economics". Journal of Economic Literature or Journal of Economic Perspectives? (commonly cited as JEP 2010). This is a canonical review and should be cited alongside Lee (2008).

- Cameron, A. Colin, Jonah B. Gelbach, and Douglas L. Miller. 2011. "Robust inference with multiway clustering." Journal of Business & Economic Statistics. This paper is important because your dataset has multiple possible clustering dimensions (canton, municipality, referendum) — cite and discuss multiway clustering.

- Calonico, Sebastian, Matias D. Cattaneo, Max H. Farrell, and Rocio Titiunik. 2019. "Regression Discontinuity Designs: Theory and Practice" (or updated rdrobust references). The paper already cites Calonico et al. 2014; it is good to also discuss later methodological updates (bias correction, robust inference) if relevant.

Political behavior / turnout literature to consider:

- Blais, André. 2000. "To Vote or Not to Vote? The Merits and Limits of Rational Choice Theory." University of Pittsburgh Press. (Background on turnout dynamics.)

- Gerber, Alan S., and Donald P. Green. 2000/2008. "Get Out the Vote" (and updated edition). You cite Green & Gerber 2008. Good—tie MDE comparisons more explicitly to these experiments.

- Bertrand, Marianne, Esther Duflo, and Sendhil Mullainathan. 2004. "How much should we trust differences-in-differences estimates?" (for a cautionary example on inference—relevant if you discuss DiD or clustered SEs.) This is tangential but relevant to inference discussion.

Specific missing empirical works on winner-loser effects (some are cited, but add if missing):

- If there are papers on turnout responses to close elections (U.S. House close-election RD literature, e.g., Caughey & Sekhon 2011 is cited; include others if relevant).

Below are suggested BibTeX entries for the most essential missing methodological references. I provide conventional entries you can include in the bibliography.

Suggested BibTeX entries (please check formatting with your BibTeX style):

```bibtex
@article{ImbensLemieux2008,
  author = {Imbens, Guido and Lemieux, Thomas},
  title = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  number = {2},
  pages = {615--635}
}

@article{LeeLemieux2010,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  number = {2},
  pages = {281--355}
}

@article{CameronGelbachMiller2011,
  author = {Cameron, A. Colin and Gelbach, Jonah B. and Miller, Douglas L.},
  title = {Robust Inference with Multiway Clustering},
  journal = {Journal of Business \& Economic Statistics},
  year = {2011},
  volume = {29},
  number = {2},
  pages = {238--249}
}

@article{CalonicoCattaneoTitiunik2014,
  author = {Calonico, Sebastian and Cattaneo, Matias D. and Titiunik, Rocio},
  title = {Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs},
  journal = {Econometrica},
  year = {2014},
  volume = {82},
  number = {6},
  pages = {2295--2326}
}

@article{CalonicoCattaneoFarrellTitiunik2019,
  author = {Calonico, Sebastian and Cattaneo, Matias D. and Farrell, Max H. and Titiunik, Rocio},
  title = {Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs},
  journal = {Econometrica},
  year = {2019},
  volume = {87},
  number = {6},
  pages = {2733--2768}
}
```

Why each is relevant:

- Imbens & Lemieux (2008) and Lee & Lemieux (2010) are foundational RD references that the paper should cite when discussing identification, bandwidth choice intuition, and interpretation of local effects.

- Cameron et al. (2011) is essential because the paper’s inference involves potentially multiway clustering (cantons, municipalities, referendums), and the discussion/inference should address this literature.

- Calonico et al. updates are essential because the author uses rdrobust and bias-corrected inference; the most recent practical recommendations should be cited and the exact version/optioning reported.

5. WRITING QUALITY (CRITICAL)

Overall the writing is competent and in many places clear; your narrative is logically organized and the institutional background is helpful. But there are several writing and presentation issues to address for top-journal quality.

a) Prose vs. Bullets: PASS. Major sections are written in full paragraphs, not bullets. Some appendices use short enumerated lists for steps in sample construction—acceptable.

b) Narrative Flow:

   - The Introduction is clear and frames the question well, but it could be sharpened. The “hook” could be stronger: lead with a crisp contrast (attitudinal winner-loser gap vs behavioral null) and preview the key identification idea more succinctly. Right now the intro meanders somewhat through literature before converging on the punchline.

   - The theoretical hypotheses (demobilization, mobilization, habituation) are well presented. But the paper could do more to tie the hypothesized mechanisms to testable empirical patterns (e.g., expect heterogeneity by referendum-type, by organizational capacity, by municipality size), and then present those planned tests earlier.

   - The methodological narrative should state clearly and early that the design is pooled across 56 referendums and 2,122 municipalities and preview how pooling is handled (e.g., whether referendum fixed effects are used). That is a major implementation detail that belongs in the Empirical Strategy intro.

c) Sentence Quality:

   - Prose is generally readable and uses active voice. There are several long paragraphs that could be split for readability. Tighten sentences where possible. Avoid excessive repetition of the same phrase. Example: the paper reiterates the same justification for Swiss context across several paragraphs; streamline.

d) Accessibility:

   - The paper is mostly accessible to a non-specialist. However, econometric choices (bandwidth selection, robust bias correction) should have a one-paragraph intuition accessible to non-technical readers describing why the particular rdrobust procedure is used.

   - Magnitudes: The paper compares CIs to GOTV magnitudes (1–5 pp) which is good. Expand on this a bit: e.g., how does the MDE compare to typical turnout differences across regions or by referendum type? Give concrete examples.

e) Figures/Tables:

   - Improve figure captions: captions should be self-contained, explaining what is plotted, units, bin width (for binned scatter), kernel, polynomial order, bandwidth used, and sample used.

   - Tables should include a clear header row, show exact N, standard errors in parentheses, and note whether SEs are clustered and at what level.

   - Table 3 (covariate balance) could be expanded to show more pre-determined covariates: age composition, prior turnout in other votes (a pre-treatment turnout measure), and share of left/right party IDs if data available.

Writing recommendation summary: tighten the introduction, explicitly present the empirical strategy and pooling choices early, add more intuitive explanations of econometric decisions, and make all figures and tables self-contained.

6. CONSTRUCTIVE SUGGESTIONS (analyses and robustness to strengthen contribution)

The paper is conceptually promising and can become a strong contribution with additional analyses, robustness checks, and clarifications. Below are concrete suggestions, roughly ordered by priority.

Top-priority additions (required):

1) Address pooling across referendums (methodological fix).

   - Option A (preferred): Run the RD separately for each referendum (i.e., for each focal referendum run an RD of subsequent turnout on municipal yes-share around 50%). Then meta-analyze the distribution of referendum-level treatment effects (plot histogram/forest plot) and compute an inverse-variance-weighted average effect. This directly addresses heterogeneity and validates pooling assumptions. Report median effect across referendums as well.

   - Option B: If pooling is necessary for power, run pooled RD but include referendum fixed effects and allow running-variable polynomials to vary by referendum (interact referendum indicators with polynomial terms) or at least include referendum-specific intercepts. Report robust SEs.

   - Either way, explicitly state the estimand (average across referendums? LATE per referendum?), and show that pooled and per-referendum estimates are consistent.

2) Inference robustness: clustering and multiway dependence.

   - Re-estimate main results with alternative clustering strategies: (i) cluster by municipality; (ii) two-way cluster by canton and by subsequent referendum (or by focal referendum); (iii) multiway clustering (Cameron-Gelbach-Miller). Report results.

   - Because number of canton clusters is only 26, run wild cluster bootstrap p-values (e.g., Cameron et al. wild cluster bootstrap or use the boottest package in Stata/R) for the main RD estimate and key heterogeneity checks.

3) Clarify estimand / weighting.

   - Present both municipality-weighted and voter-weighted estimates. If weighted estimates differ, discuss implications.

4) Control for subsequent-referendum fixed effects.

   - Since the outcome is turnout in various subsequent referendums, include fixed effects (or strata dummies) for the subsequent referendum to remove variation caused by differences in salience across subsequent votes.

5) Per-referendum balance and McCrary checks.

   - Present (perhaps in appendix) McCrary tests and covariate-balance tests for a subset of referendums or summarize the distribution of McCrary statistics across referendums to show there is no systematic