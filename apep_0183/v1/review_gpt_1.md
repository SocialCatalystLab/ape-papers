# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-04T03:14:52.340975
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 20925 in / 5790 out
**Response SHA256:** cc0f8055507970b8

---

Thank you for the opportunity to review “High on Employment? A Spatial Difference-in-Discontinuities Analysis of Marijuana Legalization and Industry-Specific Labor Market Effects.” The paper asks an important policy question and uses an innovative spatial difference‑in‑discontinuities (DiDisc) design with administrative QWI data. The topic is of clear general-interest relevance and the approach shows promise. However, several substantive methodological, identification, and presentation shortcomings must be addressed before this paper is suitable for a top general‑interest journal. Below I provide a rigorous, detailed review organized according to your requested checklist: format, statistical methodology, identification, literature, writing quality, constructive suggestions, and an overall assessment with a required editorial decision.

1. FORMAT CHECK

- Length: The LaTeX source suggests a substantive main text (Introduction through Conclusion) followed by a large appendix. My reading of the manuscript (Introduction through end of Conclusion) is roughly 30–40 pages of single-column 12pt text (excluding the bibliography and appendix figures/tables). This exceeds the 25-page informal threshold; approximate main-text length ≈ 34 pages. Please confirm final compiled page count excluding references and appendix.

- References: The bibliography is present (\bibliography{references}) but many key methodological and empirical references discussed in the text are not listed explicitly in the document (see Literature section below). Ensure the references file contains all cited works. Also the paper sometimes cites papers inline (e.g., “\citet{dave2022effects}”) — ensure the references list matches all citations.

- Prose: Major sections (Introduction, Institutional Background, Theoretical Framework, Data, Empirical Strategy, Results, Mechanisms & Discussion, Conclusion) are written in paragraph form, not bullets. Good.

- Section depth: Major sections are long and substantive. Most sections (e.g., Intro, Theoretical Framework, Empirical Strategy, Results, Mechanisms & Discussion) contain multiple paragraphs (typically >3). Acceptable.

- Figures: The LaTeX lists many figures (maps, event studies, RDD visualizations). The captions indicate axes and confidence intervals. I cannot view the embedded PDF figures here, but the code references sensible filenames and captions. On revision, ensure every figure has labeled axes with units and the data sources clearly noted in the caption. Also include number of bins and bin width for binned RDD plots.

- Tables: Tables in the main text (Tables 1–6) contain numeric coefficients, standard errors, p-values, Ns, and other relevant statistics — no placeholders seen. Good.

Summary (format): Mostly acceptable. Provide compiled page count excluding references/appendix and ensure bibliography contains all cited works.

2. STATISTICAL METHODOLOGY (CRITICAL)

A paper cannot pass a top‑journal review without rigorous inference and full transparency about identification. Below I list required checks and whether the paper meets them. I treat each criterion as pass/fail with comments.

a) Standard Errors
- Pass: Every coefficient reported in main tables has standard errors in parentheses (e.g., Table “Main DiDisc Estimates” shows SEs, Table “Industry Heterogeneity” shows SEs). Good.

b) Significance Testing
- Pass: The paper reports p-values, p‑value brackets, and uses hypothesis testing, including FDR correction for multiple testing. Good.

c) Confidence Intervals
- Partial Pass: The main table reports 95% CIs for the aggregate estimate (Table 1). Many tables report CIs for robustness/bandwidth table as ranges. Ensure that all main results (aggregate and industry) also show explicit 95% CIs (not only p-values). Add CIs to industry table (Table 4) and to key robustness tables for easy reading.

d) Sample Sizes
- Pass: N observations and N counties are reported in tables (e.g., Table 1 includes N obs = 5,638, N counties = 125). Industry table reports Ns per industry. Good.

e) DiD with Staggered Adoption
- Potential Concern (requires clarification): The paper addresses staggered adoption concerns in Section 5.1 and argues the estimator avoids TWFE problems because (i) control group is never-treated states for most borders and (ii) only two treated cohorts (CO and WA in 2014). The argument is plausible but incomplete.

  - The paper cites Goodman-Bacon style issues but should explicitly implement and report robustness checks using modern methods designed for staggered adoption: at a minimum, Callaway & Sant’Anna (2021) and Sun & Abraham (2021) (or equivalent) event‑study estimators that are robust to heterogeneous treatment effects. The text says the author believes TWFE bias is small with two cohorts and never-treated controls, which can be true, but the claim must be supported empirically. I recommend estimating cohort‑specific ATTs (Callaway & Sant'Anna) and/or event-study using Sun & Abraham to show the TWFE and robust estimators yield similar results.

  - PASS only after authors run and report these alternative estimators and show estimates are consistent.

f) RDD requirements (McCrary, bandwidth sensitivity)
- FAIL (as currently presented): For any RDD or spatial RDD design, the McCrary density test (McCrary 2008) or analogous plausibility checks are standard. The paper argues that county boundaries cannot be manipulated and that density tests are less relevant (Section 5.2). While geographic sorting of county centroids may be less manipulable, related concerns remain: (i) discontinuities in pre-treatment covariates across the border, (ii) discontinuities in population, county size, or pre-treatment outcomes, and (iii) sorting at the individual/firm level that appears in aggregate county-level data. The paper conducts temporal placebo tests and reports pre-trends (event-study), which is valuable, but is missing two standard checks:

  - A formal test (or plots) for discontinuities in pre-treatment covariates (population, employment shares, pre-treatment earnings levels, demographic composition) at the border and whether those discontinuities are stable over time.

  - A density/sorting check: while McCrary may not be directly applicable to county centroids, the paper should show the distribution of county centroids / population mass vs. signed distance (or a histogram of county population/population density by distance) to show no discontinuity at the border. At minimum, include a test for discontinuity in county population or pre-treatment employment at distance = 0. Absent these, the RDD assumptions are not adequately examined.

Summary (methodology): The paper includes many good inference practices (SEs, clustering, wild bootstrap, permutation tests, BRL). However, key tests required for spatial RDD and for staggered DiD robustness are missing. If these tests are not provided and do not support the design, the paper is unpublishable in its current form.

I state this explicitly: If the authors cannot (1) demonstrate robustness to staggered adoption issues using modern estimators (Callaway & Sant'Anna, Sun & Abraham) and (2) provide appropriate continuity/sorting diagnostics (McCrary‑style or covariate discontinuities) and/or show pre-treatment covariate stability, the paper should be considered unpublishable at a top journal. The authors partially address these concerns, but more is required.

3. IDENTIFICATION STRATEGY

Is the identification credible?

- Innovation: The spatial difference‑in‑discontinuities (DiDisc) design is an interesting way to combine border RDD and DiD logic and to difference out level differences at borders. The idea of temporal placebos adds credibility.

- Key assumptions and tests:
  - Parallel trends in border discontinuities (the core DiDisc identifying assumption) is explicitly stated (Section 5.2) and partially tested using event study pre-period coefficients and temporal placebo tests (Figures 3 and 4, Table of placebos). This is good and necessary.

  - However, the core assumption that discontinuities would remain constant absent treatment is **not fully established**. Temporal placebo tests are useful but limited (they test that discontinuities did not change in pre-periods). They do not protect against contemporaneous confounders that coincide with legalization (e.g., local shocks, oil price changes, local policy changes) or differential trends among some border pairs.

  - The paper would be strengthened by:
    - Border‑pair level leave‑one‑out estimates and border‑by‑border heterogeneity plots (they mention limited power but should still show +/- estimates). You report that border-by-border estimates could not be reliably computed — nevertheless, a leave‑one‑out table (which you mention in text but do not show) is crucial; include it in the appendix with CIs.
    - Tests for discontinuities in pre-treatment covariates (population, industry composition, pre-treatment earnings/employment levels) and evidence that these discontinuities are stable over time. Present these as figures/tables (e.g., binned scatterplots for pre-period means and tests).
    - Mapping of dispensary/licensing locations and their distances to border counties. The paper argues that cannabis industry concentrates in interiors; a map of license locations would support this and show why border counties may not capture direct cannabis employment.
    - Sensitivity to possible contemporaneous shocks: e.g., control for oil/gas price or county-level shocks where relevant, or show that results are robust to adding border-pair-specific linear/quadratic time trends.

- Placebo tests: The temporal placebo analysis (Table 2) is a strength. But the paper reports 8 placebos and states none significant at 10% — provide joint F-statistics and p-values (they say joint F-test is used but don't show the statistic and p-value). Also show placebo distributions for each border pair and pooled.

- Spillovers: The paper thoughtfully addresses commuting zone spillovers by excluding cross-border CZs in a robustness check. This is good. But I would like to see an IV-style addressing of spillovers (or at least discussion and bounds for spillover attenuation). For example, what is the likely attenuation bias from imperfect compliance (commuting)? Provide calibration or a sensitivity analysis.

Conclusion on identification: The DiDisc design is promising and the temporal placebo tests help. But the authors must provide additional continuity/sorting diagnostics, explicit modern staggered‑DiD robustness, border‑by‑border (leave‑one‑out) sensitivity, and clearer treatment of potential contemporaneous confounders and spillovers. Until then, identification is not fully credible for a top‑tier publication.

4. LITERATURE (Provide missing references)

The paper cites some of the relevant literature (Dube on border designs, Benjamini‑Hochberg on FDR, some marijuana/labor work). However, several foundational methodology papers and RDD/DiD references are missing or should be added explicitly and discussed in relation to the approach. The paper often refers to these ideas in text but may not include full citations in the references file. At minimum, the authors must cite and engage with:

- Callaway, Sant’Anna (2021) — for DiD with multiple time periods and variation in timing.
- Goodman‑Bacon (2021) — decomposition of TWFE and the problem of negative weights in staggered DiD.
- Sun & Abraham (2021) — event‑study estimators robust to heterogeneous treatment effects.
- de Chaisemartin & D’Haultfœuille (2020) — issues with TWFE; alternative estimators.
- Imbens & Lemieux (2008); Lee & Lemieux (2010) — methodology primers for RDD approaches.
- McCrary (2008) — density test for RDD manipulation.
- Cameron, Gelbach & Miller (2008) — wild cluster bootstrap inference.
- Conley (1999) or Conley,  spatial HAC methods (if implementing Conley SEs).
- Additional marijuana and labor literature: Powell et al. (2018) and Wen & Hockenberry (2015) are cited, but include more recent studies (e.g., Dave et al. 2022 is cited). Consider also including reviews/meta‑analyses if available.

You requested specific BibTeX entries. Below are suggestions (canonical entries). Include them in the references file and cite where relevant.

- Callaway & Sant'Anna (2021):
```bibtex
@article{callaway2021difference,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}
```

- Goodman‑Bacon (2021):
```bibtex
@article{goodman2021difference,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}
```

- Sun & Abraham (2021):
```bibtex
@article{sun2021estimating,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {175--199}
}
```

- Imbens & Lemieux (2008):
```bibtex
@article{imbens2008regression,
  author = {Imbens, Guido W. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {615--635}
}
```

- Lee & Lemieux (2010) [survey]:
```bibtex
@article{lee2010regression,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  pages = {281--355}
}
```

- McCrary (2008):
```bibtex
@article{mccrary2008manipulation,
  author = {McCrary, Justin},
  title = {Manipulation of the Running Variable in the Regression Discontinuity Design: A Density Test},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {698--714}
}
```

- Cameron, Gelbach & Miller (2008) — wild cluster bootstrap:
```bibtex
@article{cameron2008bootstrap,
  author = {Cameron, A. Colin and Gelbach, Jonah B. and Miller, Douglas L.},
  title = {Bootstrap-Based Improvements for Inference with Clustered Errors},
  journal = {The Review of Economics and Statistics},
  year = {2008},
  volume = {90},
  pages = {414--427}
}
```

- de Chaisemartin & D'Haultfœuille (2020):
```bibtex
@article{de2020two,
  author = {de Chaisemartin, Clément and D'Haultfœuille, Xavier},
  title = {Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  pages = {296--301}
}
```

Why each is relevant:
- Callaway & Sant'Anna and Sun & Abraham provide estimators robust to heterogeneous treatment effect timing and should be used to verify the TWFE-based DiDisc estimates are not biased by timing heterogeneity.
- Goodman‑Bacon explains decomposition of TWFE and is useful to diagnose potential negative-weight issues.
- Imbens & Lemieux, Lee & Lemieux, and McCrary provide canonical RDD diagnostics and caveats; even if the running variable is geographic, the continuity/diagnostic logic applies via covariate balance/density tests.
- Cameron et al. supports the paper’s use of wild cluster bootstrap and should be cited where used.
- de Chaisemartin & D'Haultfœuille adds to the recent discussion on TWFE bias.

5. WRITING QUALITY (CRITICAL)

Overall the manuscript is well organized and reads like a standard empirical economics paper. However, several writing and presentation improvements are necessary for readability and persuasion.

a) Prose vs. Bullets
- Pass: Major sections are written in full paragraphs. Only a few places use short lists, typically in Data/Methods as allowed.

b) Narrative Flow
- Strengths: The Introduction motivates the question well and lays out the logic for DiDisc succinctly (pp. 1–4 of the LaTeX). The Theoretical Framework is concise and sets testable predictions.
- Weakness: Some sections, especially Results and Discussion, are overly long and occasionally repeat similar points across paragraphs. For top‑tier publication the prose should be tightened: summarize main findings early (e.g., at the end of Introduction) and avoid repeating the same robustness checks multiple times in different sections.

c) Sentence Quality
- Generally good. A few long sentences could be shortened for clarity (e.g., the paragraph describing DiDisc in the Introduction). Use active voice where possible. Place the key result sentences at the start of paragraphs.

d) Accessibility
- The paper does a good job explaining the DiDisc intuition (Introduction/Section 5). However, some econometric choices (why border-pair-by-quarter FE, specifics of BRL implementation, permutation test design) require plain-language justification and intuition for non-specialist readers. For example, explain what wild cluster bootstrap does and why it is needed when there are very few clusters.

e) Figures/Tables
- Improve figure captions: they should be fully self‑contained (data source, sample, definitions of treatment/control, number of bins or smoothing choices). For the RDD visualizations state bin widths, polynomial fit orders, and whether binned means are population-weighted. For the event study show confidence bands that come from the robust estimator specified and mention the inference method used.

f) Pre‑registration claim
- The paper states “These predictions are registered before examining industry‑specific results.” Provide the pre‑analysis plan or registry link and date (e.g., OSF) in the paper (footnote in the Theoretical Framework) and include any deviations. Without a link/registration record, the claim is unsubstantiated.

6. CONSTRUCTIVE SUGGESTIONS

The paper shows promise and, with revisions, could make a strong contribution. Below are concrete suggestions to strengthen the paper’s credibility and impact.

A. Key methodological/identification analyses to add (required):
1. Staggered‑DiD robustness
   - Implement Callaway & Sant’Anna (2021) cohort ATT estimators (by cohort and overall) and Sun & Abraham (2021) event‑study estimator. Present these alongside the TWFE DiDisc results. If estimates align, state this explicitly; if not, discuss differences.

2. Continuity / density / covariate balance checks
   - Show discontinuity tests for pre-treatment covariates at the border (population, pre-treatment earnings, employment, industry composition, demographics). Display binned scatterplots of pre-period means vs. distance with linear fits.
   - Provide a “density” style plot: e.g., population-weighted histogram of signed distance to border to detect any discontinuity in the mass of population near the border.

3. McCrary analog for counties
   - If the standard McCrary is not applicable, justify and show an alternative (e.g., test discontinuity in county population, number of establishments, employment counts) at the border.

4. Border‑by‑border heterogeneity and leave‑one‑out
   - Provide leave‑one‑out DiDisc estimates (8 estimates) and a forest plot to show sensitivity to each border. Provide a table showing which borders, if any, move results materially.

5. Pre‑analysis plan / registration
   - Provide the registry URL and the exact pre-specified industries/predictions. If pre-analysis plan is not available, clearly label which analyses were pre‑specified vs exploratory.

6. Show dispensary / license map
   - Add a map of cannabis retail/cultivation license locations overlaid with county borders and treated vs control counties to empirically support the claim about interior clustering.

B. Additional empirical checks to increase confidence:
1. Covariate‑adjusted DiDisc: include county-level controls (pre-treatment covariates) and test stability.
2. Power / MDE calculation: provide minimum detectable effect sizes given cluster count, sample size, and outcome variance. This helps interpret null findings.
3. Alternative inference: report wild cluster bootstrap p‑values for industry estimates too (small clusters may render cluster SEs unreliable).
4. Report 95% CIs for all key coefficients in main tables (industry table, bandwidth table).
5. Show the permutation distribution plots from the random reassignment inference, and indicate where the actual estimate lies — helps readers visualize empirical significance.
6. Provide results for interior counties (state-level DiD) as a complement to border analysis; if differences exist, discuss the spatial heterogeneity.

C. Interpretation and framing:
1. Be explicit about external validity — the border design estimates local effects near borders; do not overgeneralize.
2. For the information sector negative finding: present a robustness check that conditions on county-level tech growth indicators (e.g., firm creation, patenting proxy, or share of employment in high‑tech occupations) or show whether the result is driven by one border (they mention sensitivity).
3. Discuss potential attenuation bias due to cross-border spending and commuting with quantitative bounds.

7. OVERALL ASSESSMENT

Key strengths
- Interesting, policy‑relevant question with high public and academic interest.
- Innovative use of spatial difference‑in‑discontinuities and temporal placebo tests.
- Use of administrative QWI data focusing on new‑hire wages is appropriate for detecting near‑term labor market responses.
- Considerable set of robustness checks already implemented (bandwidth sensitivity, exclude cross‑border CZs, alternative outcomes, wild bootstrap, permutation tests).

Critical weaknesses (must be addressed)
- Missing key methodological robustness checks for staggered adoption: must implement Callaway & Sant’Anna and Sun & Abraham estimators (or equivalent) and report results.
- Incomplete RDD/sorting diagnostics: must present covariate/discontinuity tests and a McCrary analogue.
- Small number of clusters (8 border pairs) raises inference concerns; although the authors use wild cluster bootstrap and permutation tests, they must present these results comprehensively (including wild bootstrap inference for industry results and CI plots).
- The “pre‑registered predictions” statement lacks a link or documentation.
- The puzzling information-sector result requires further investigation and either stronger robustness or stronger caveating (label as exploratory).
- Lack of maps/dispensary location evidence to justify claims about interior concentration.

Specific suggestions for improvement
- Add the missing methodological references with BibTeX entries as provided above.
- Provide the pre-analysis plan link and details of any deviations.
- Add covariate balance tables and discontinuity tests in the appendix.
- Present leave‑one‑out and alternative estimator results in appendix figures/tables.
- Improve figure captions and add 95% CIs to industry and robustness tables for readability.

8. DECISION (REQUIRED)

Given the substantive methodological gaps that are fixable but material (staggered‑DiD robustness, RDD diagnostics, inference with few clusters, and pre-analysis plan documentation), I recommend a revise‑and‑resubmit with major revisions.

You can salvage this paper for a top journal, but the authors must perform the additional analyses and provide clearer evidence that the DiDisc identification is valid and robust. The combination of a credible DiDisc design, pre‑treatment placebo validation, and administrative data is promising; with the required checks and clearer presentation the paper could make an excellent contribution.

DECISION: MAJOR REVISION