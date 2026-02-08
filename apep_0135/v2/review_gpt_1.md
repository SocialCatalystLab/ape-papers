# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-02T22:42:58.376669
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 20886 in / 6895 out
**Response SHA256:** 6e6a266eb77cbae9

---

Thank you for the opportunity to review “Technological Obsolescence and Populist Voting: Evidence from U.S. Metropolitan Areas.” The paper asks an interesting and policy-relevant question and assembles a novel dataset (modal technology vintage by CBSA) merged to county-level presidential returns across four elections (2012, 2016, 2020, 2024). The central empirical finding—that older-technology CBSAs are more Republican, and that the technology–voting correlation emerged with Trump (2012→2016 gains) but did not predict subsequent within-Trump gains—is potentially important. However, the paper in its current form has important weaknesses in presentation, identification, and robustness that must be addressed before it is publishable in a top general-interest journal. Below I give a comprehensive, rigorous review organized according to your requested headings.

1. FORMAT CHECK (format issues I expect the authors can and should fix)
- Length: The LaTeX source is long and includes a substantial appendix. Based on the structure (main text plus appendix figures/tables), I estimate the paper is at least ~30–40 pages (main text + appendix), i.e., it likely meets the “>=25 pages” threshold. Please state the exact page count in the submission. If the submitted PDF is shorter/longer, indicate so. (Reference: whole source.)
- References / Literature coverage: The bibliography is extensive and cites many relevant empirical and theoretical works (Autor et al., Acemoglu & Restrepo, Rodrik, Moretti, Margalit, etc.). However, key modern methodological papers about staggered DiD inference and heterogeneous treatment timing are missing (see Section 4 below for specific missing citations and BibTeX entries). The paper cites Callaway & Sant'Anna and Goodman-Bacon (both present), which is good, but it omits Sun & Abraham (2021), de Chaisemartin & D’Haultfoeuille (2020), and other crucial DiD/heterogeneous-timing discussions; these should be cited and engaged with if any DiD-like or fixed-effects event analysis is used. The literature on geographic sorting and migration should be more fully engaged (e.g., treatments of residential sorting and political selection). See Section 4 for explicit missing references and why they matter.
- Prose: Major sections (Introduction, Data, Conceptual Framework, Empirical Strategy, Results, Discussion, Conclusion) are written in paragraphs (good). However, several parts read episodically and sometimes repeat the same assertions across sections (e.g., repeated claims about sorting vs. causal interpretations occur multiple times). Tighten and reduce repetition. The Introduction is long but generally in paragraph form (good). The Data and Results sections are paragraph-heavy and acceptable.
- Section depth: Major sections are present and generally have multiple paragraphs. Some subsections (e.g., parts of the robustness checks and the “Mechanisms” subsection) contain shorter paragraphs and bullet lists—acceptable in Data/Methods for variable definitions, but in Results and Discussion the paper should keep full-paragraph exposition. Ensure each major section contains at least three substantive paragraphs with a clear logical flow—some subsections presently have 1–2 paragraphs only.
- Figures: Figures are included (figure files appear referenced in appendix), but in the LaTeX source they are referenced by filename only (e.g., figures/fig1_tech_age_distribution.pdf). In the document provided to referees, ensure:
  - Figures are embedded at high resolution.
  - Each axis has a label and units.
  - Regression/binned lines are clearly plotted and described in captions.
  - All figures are legible in print (fonts not too small).
  - Captions should be self-contained and include data source, sample, and whether plotted values are weighted/unweighted.
- Tables: Tables in the main text contain numeric coefficients and standard errors (no placeholders). However, several table notes claim “standard errors clustered by CBSA” while other tables say “heteroskedasticity-robust”; be consistent and report exact clustering/SE methodology per column. Also include 95% confidence intervals in at least main tables or report them in an appendix.

2. STATISTICAL METHODOLOGY (critical — the paper cannot pass without improved identification/inference)
This paper uses regression analysis with standard errors, fixed effects, and “gains” regressions. The authors do report standard errors and Ns, which is necessary. But the methodological treatment has important omissions and weaknesses. Below I enumerate required corrections and checks—if these are not addressed, the paper is not publishable.

a) Standard errors
- The paper reports standard errors in parentheses for coefficients in main tables (e.g., Table 1). That is acceptable. However:
  - The authors must explicitly report 95% confidence intervals for main estimates (either in parentheses or in an adjacent column/panel). Top journals expect either CIs or SEs with clearly stated significance levels; I recommend adding 95% CIs in main tables as brackets in addition to SEs.
  - In the main FE specifications, the paper clusters SEs by CBSA. That is plausible, but the authors must justify the clustering level and test robustness to alternative clustering choices (e.g., state-level clustering, two-way clustering by CBSA and state, and wild cluster bootstrap if cluster count is small). The paper reports some of this in robustness text, but please show these alternative standard errors in a table or appendix (state-clustered SEs, two-way clustered SEs, wild cluster bootstrap p-values).
  - The authors should report exact number of clusters; CBSA cluster count equals number of CBSAs in the sample (e.g., 896). If using state-level clustering, report number of clusters (states) and warn about small-cluster inference if applicable.

b) Significance testing
- The paper conducts standard hypothesis tests and annotates p-values. That is fine. But please:
  - Where coefficients are used to interpret substantive effects (e.g., “10-year increase → 1.2 pp higher GOP share”), report SEs and 95% CIs around those converted magnitudes.
  - For key claims (e.g., that gains occur 2012→2016 but not later), include tests of equality across coefficients (formal tests of difference) and report p-values for those equality tests.

c) Confidence intervals
- Provide 95% CIs at least in main tables (preferred) or as an additional column. Many readers mentally expect CIs; add them.

d) Sample sizes
- The paper reports N for main regressions in table notes. That is good. Please ensure every regression in the appendix also reports N and the number of clusters used for SEs. For example, Table \ref{tab:main_results} reports Observations but not number of clusters; add “Number of CBSAs (clusters) = XXX.”

e) DiD with staggered adoption
- The paper does not perform a canonical staggered-DiD analysis (i.e., there is no “treatment” of some CBSAs at different times) so the TWFE staggered-adoption warnings do not directly apply. Nevertheless, the paper uses CBSA fixed effects plus a time-varying continuous treatment. Two warnings:
  - If any event-study or dynamic DiD-style figures are added to show pretrends (recommended, see below), the authors must avoid the pitfalls of TWFE event-study when treatment timing is heterogeneous and treatment effects vary. In that case they must employ modern methods (Callaway & Sant’Anna is cited; also see Sun & Abraham and de Chaisemartin & D’Haultfoeuille). See Section 4 for concrete literature to add and methods to use.
  - If the authors interpret the positive within-CBSA FE estimate as causal, they must demonstrate pre-trend parallelism or otherwise use a credible identification strategy (instrument, discontinuity, or quasi-experiment). At present the gains test (2012→2016) is a suggestive correlation and not a causal estimate.

f) RDD (not used)
- The paper does not use an RDD. If an RDD is proposed, McCrary tests and bandwidth sensitivity must be included. Not applicable here.

Summary on statistical methodology: The paper meets minimum reporting requirements (coefficients, SEs, Ns). But it fails to convincingly distinguish correlation from causation, and the inference around the key causal claim (that the correlation is sorting, not causal) is based on suggestive patterns rather than rigorous causal identification. Without a credible additional identification strategy (event-study with proper accounting for heterogeneous effects, IV, natural experiment, or richer longitudinal variation and pre-trend evidence) the paper cannot sustain causal claims. This is a major deficiency that requires substantial revision.

If the authors do not add substantially stronger identification or present convincing placebo/pretrend evidence, the paper is unpublishable at a top general-interest outlet. I state this clearly: the paper, as-is, cannot be accepted because its core interpretive claim (sorting rather than causal effect of technology on voting) rests on suggestive regressions without rigorous pre-trend testing and without addressing potential confounders (migration, composition changes, unobserved correlate variables). See Identification comments next.

3. IDENTIFICATION STRATEGY (credibility, assumptions, robustness)
The paper is careful in language in several places, and the authors explicitly say they cannot randomly assign technology vintage. I appreciate the caution. Nevertheless, the identification tests and discussion have gaps.

- Credibility: The core identification strategy is:
  - Cross-sectional regressions with year FE and controls.
  - CBSA fixed-effects regressions to exploit within-CBSA variation.
  - “Gains” regressions testing whether prior technology age predicts changes (2012→2016, 2016→2020, 2020→2024).

  These are reasonable starting points. However, credibility hinges on two things the paper currently lacks in sufficient detail:
  1) Evidence on pre-trends / placebo tests: For any interpretation of within-CBSA variation as causal (or to rule it out), show event-study-style plots of elections before 2012 where possible (if data exists earlier) or run placebo “gains” regressions using pre-2012 vote changes (if modal age can be measured earlier). The paper now uses only 2012 as a pre-Trump baseline. That is helpful, but testing for pre-existing trends within the 2000s would strengthen claims that the 2012→2016 shift was unique. If technology vintage is serially persistent (corr ~0.89 between adjacent years), then pre-existing voting trends might correlate with technology and confound interpretation.
  2) Tests for compositional change / migration: The hypothesis of sorting implies people with different political preferences sort into regions; this requires evidence that residential composition (e.g., inflows/outflows by education/party ID) did not change contemporaneously, or evidence that composition explains the effect. The paper presents suggestive correlates (education, industry share) and shows attenuation after adding controls, but does not present dynamic evidence on migration flows or voter churn. Add robustness using IRS migration data, ACS migration flows, or change in population composition at the CBSA-level over the 2012–2016 period. If sorting is the story, you should observe differential migration/compositional change corresponding to Trump’s rise.
- Key assumptions: The authors reference parallel trends implicitly but do not formally test assumptions. For causal claims:
  - For DiD/event-study-style inference: demonstrate parallel trends pre-treatment.
  - For gains regressions: show that pre-2012 gains were uncorrelated with technology age (placebo), and test whether 2012 technology predicted earlier electoral changes (e.g., 2008→2012) if data allow.
  - For within-CBSA FE: show that shocks to technology age are plausibly exogenous to concurrent political shocks (e.g., sudden plant closures or large investments would confound).
- Placebo tests and robustness checks: The paper runs several robustness checks (alternative tech measures, metro vs micro, quadratic terms, clustering choices). But I recommend adding:
  - Event-study plots with pre-2012 elections, if possible.
  - Placebo “outcome” tests: test whether technology age predicts outcomes it should not predict if the sorting story were correct (e.g., short-run changes in very localized non-political outcomes).
  - Permutation/randomization inference: randomly reassign technology age to CBSAs and recompute the distribution of coefficients to check whether observed effects are surprising relative to random assignment.
  - Instrumental variable (IV) or historical-exposure strategy: consider instruments for technology vintage that are plausibly exogenous to contemporary politics (e.g., historical industry composition or pre-1950 industry footprints, distance to major rail or port infrastructure that predicted early capital vintage but not modern political preferences, conditional on controls). At the least, present sensitivity analyses (Oster-style) to gauge how much unobserved confounding would be needed to explain away the effect.

- Do conclusions follow from evidence? The central descriptive facts (cross-sectional correlation; 2012→2016 gains predicted by tech age; null for later gains) are well supported by reported regressions. But the stronger interpretive claim—that the correlation reflects sorting rather than causal effects—is not definitively established. The gains evidence is suggestive of a one-time realignment, but that alone does not prove sorting: a plausible alternative is that Trump uniquely appealed to an economic grievance (or other mechanisms) that technology predicted in 2012→2016 but that later dynamics (COVID, incumbency, base consolidation) attenuated. The authors need to rule out such alternative explanations more thoroughly.

- Limitations: The paper acknowledges limitations (technology measure is capital age only, etc.). This is good but expand on:
  - Measurement error: modal age aggregated across industries may mix composition and within-industry technology choices. If industry composition is a mediator or confounder, report “within-industry” versions of the main regressions (i.e., industry-by-CBSA technology age vs. voting), or instrument for within-industry tech using lagged industry investments.
  - Ecological inference: CBSA-level analysis weights each CBSA equally (authors note). Consider population-weighted regressions as a robustness check to assess whether relationships are driven by small CBSAs.

4. LITERATURE (missing references and why to add them)
The paper cites many relevant empirical and theoretical works. However, the methodological literature on staggered DiD and event-study inference that is crucial if the authors present dynamics or use FE/event-study methods deserves fuller treatment. Also, the literature on residential sorting and political selection should be engaged. Below I list specific bibliographic items the paper should add, with brief justification and suggested BibTeX entries.

a) DiD / staggered timing / event-study literature (must cite if event-study or TWFE interpretations are used)
- Sun, L. and Abraham, S. (2021): Shows biases in TWFE event-study with heterogeneous treatment timing and proposes corrected estimators.
- de Chaisemartin, C. and D’Haultfoeuille, X. (2020): Provides alternative estimators for staggered adoption.
- Borusyak, M., Jaravel, X., and Spiess, J. (2021): Event-study methods and recommendations.
- I suggest adding these papers and using their methods (or at least discussing them) if the authors show dynamic effects or pre/post plots.

BibTeX entries:
```bibtex
@article{sunab2021,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating dynamic treatment effects in event studies with heterogeneous treatment effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {175--199}
}

@article{deChaisemartin2020,
  author = {de Chaisemartin, Clément and D'Haultfœuille, Xavier},
  title = {Two-way fixed effects estimators with heterogeneous treatment effects},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  pages = {XXXX--XXXX}  % please fill page numbers if known
}

@article{borusyak2021event,
  author = {Borusyak, Kirill and Jaravel, Xavier},
  title = {Revisiting event study designs},
  journal = {Available at SSRN / Working Paper},
  year = {2021}
}
```
(Please replace missing page numbers or use working-paper DOIs if needed.)

Why relevant: If authors present pre–post dynamics or interpret FE coefficients as capturing causal dynamics, they must account for heterogeneous effects/biased TWFE in event-study contexts.

b) Sorting / residential selection literature
- Many papers document selection/sorting between places by education, income, and political preferences. Representative references the authors should cite and engage with:
  - McKenzie & Paul (papers on selection?), Chetty et al. (they already cite Chetty et al. 2014—good).
  - Nathaniel Hendren/ Raj Chetty/others on migration and selection—Chetty, Hendren & Katz 2014 is cited; add follow-ups on adult migration and sorting if relevant.
  - "Sorting and the decline of manufacturing communities" — e.g., Diamond (2016) on migration? If a canonical paper on political sorting exists (e.g., Bishop 2008?), cite it.

I will suggest one concrete addition:
```bibtex
@article{song2018sorting,
  author = {Song, Jae and Price, David and Guvenen, Fatih and Bloom, Nicholas and von Wachter, Till},
  title = {Firming Up Inequality},
  journal = {Quarterly Journal of Economics},
  year = {2019},
  volume = {134},
  pages = {1--50}
}
```
Why relevant: This and related work help illuminate firm-worker sorting and its political-economic implications; authors should show how their measure of technology vintage might capture firm-level decisions that attract certain workers.

c) Methods for causal inference with stock variables / long-term processes
- Papers discussing identification with slow-moving stocks and the difficulty of attributing contemporaneous political changes to long-run stock variables (e.g., literature on place-based policy effects that must account for selection).
- Consider sensitivity/identification methods such as Oster (2019) for omitted variable bias or Altonji/Ellwood/Taber selection-on-observables approaches.

Suggested citation:
```bibtex
@article{oster2019,
  author = {Oster, Emily},
  title = {Unobservable selection and coefficient stability: theory and evidence},
  journal = {Journal of Business & Economic Statistics},
  year = {2019},
  volume = {37},
  pages = {187--204}
}
```

d) Other empirical work linking technology/automation to politics
- The paper cites Autor, Acemoglu & Restrepo, Frey & Osborne. It could also cite work on robots/automation and voting (if any) or on digital infrastructure and geographic sorting. If such literature exists (e.g., studies linking broadband access to voting), include and discuss.

5. WRITING QUALITY (critical)
Top general-interest journals expect crisp, compelling prose and a clearly articulated narrative. The paper is generally readable and cautious in interpretation, but there are weaknesses:

a) Prose vs bullets
- The major sections are paragraph-based (good). However, some subsections use enumerated lists (e.g., theoretical mechanisms, section 3). Lists are acceptable in theory sections but keep them short and explanatory. The paper repeats the “sorting vs causal” message multiple times verbatim; condense to sharpen narrative.

b) Narrative flow
- The Introduction lays out motivation, data, and preview of results well; but it repeats key numerical results multiple times (e.g., the 0.033 FE coefficient appears in Intro and again in Results). Reduce repetition and focus each section on making unique contributions to the argument (Intro = hook + contribution; Data = measurement details; Results = evidence; Discussion = interpretation and policy).
- The tension between “technology predicts cross-sectional GOP share” and “sorting interpretation” is interesting, but the narrative should guide the reader through why a one-time realignment (2012→2016) provides natural leverage for testing sorting vs causal stories—explain intuition more compactly.

c) Sentence quality
- Many sentences are clear and active voice is used. However, the writing sometimes hedges excessively (overuse of “may”, “could”)—this is acceptable given observational data, but tighten sentences when stating descriptive facts (e.g., “We find X” vs “We document evidence consistent with X” depending on whether the claim is causal).

d) Accessibility
- Good job explaining the modal age measure in plain language (Section 2.3). A few technical terms (e.g., “modal age”, “CBSA”, “TWFE”) are defined; ensure every technical term is defined at first use.
- When discussing magnitudes, give concrete examples (the paper does this in Section “Summary of Findings”—good). Add another example that shows the political relevance: e.g., how many CBSAs would switch partisan outcomes with an x-year difference? But avoid overclaiming.

e) Figures/Tables quality
- Table and figure captions need to be more self-contained. For tables, include number of clusters, the weighting scheme (unweighted vs population-weighted), and whether the unit is CBSA or CBSA-year. For figures, label axes with “GOP share (%)” or “Modal technology age (years)”, state sample size, and clarify whether regression lines are weighted/unweighted.

6. CONSTRUCTIVE SUGGESTIONS (to make the paper more impactful)
The paper shows promise. To strengthen it for a top journal, I recommend the following concrete additions and changes (some are methodological, some presentation/diagnostic):

A. Strengthen causal identification or reframe as careful descriptive paper
- Option 1 (preferred): Strengthen causal identification. Possible approaches:
  1) Event-study with more pre-periods and corrected estimator: If the technology series or voting data allows, run an event-study showing dynamic effects around 2016 using Sun & Abraham or Callaway & Sant’Anna-style estimators that account for heterogeneous timing. Test for pre-trends.
  2) Instrumental variables: Find plausible instruments for modal technology age (historical industry composition, pre-1950 plant age, legacy transportation infrastructure, exogenous shocks to industry that determined capital vintage but not present politics). Use IV with strong first stage and present overidentification/sensitivity tests.
  3) Exploit quasi-experiments: e.g., natural experiments where a plant installed new technology due to a tax credit or regulatory program that only certain CBSAs experienced; compare political outcomes pre/post with matched controls.
  4) Individual-level microdata: If available, link individual-level voter or survey data to local technology measures to reduce ecological inference problems. For example, use CCES or ANES linked to CBSA-level tech vintage and estimate individual-level models controlling for local composition and individual covariates. This helps distinguish composition vs. place effect.
- Option 2 (if causal identification not feasible): Recast paper as a thorough descriptive analysis of the covariation and a careful exploration of mechanisms, explicitly avoiding causal language. Emphasize the novel dataset and diagnostics demonstrating why simple causal interpretations are problematic. A high-quality descriptive paper can still be published in top journals if it provides new and robust regularities plus insight.

B. Add rigorous pre-trend/placebo analyses
- Event-study with pre-2012 election data (2000/2004/2008/2012) if tech data or earlier comparable measures exist; otherwise show placebo gains (e.g., 2004→2008) that tech age does not predict.
- Randomization inference/permutation tests to demonstrate the robustness of coefficients to chance correlation.

C. Compositional tests
- Directly test the sorting mechanism: use IRS migration data, ACS 1-year flow tables, or county-level net migration by education/age group between 2012 and 2016 to test whether CBSAs with older tech experienced different inflows/outflows correlated with political change.
- Show whether changes in CBSA composition (education share, race/ethnicity mix, age) account for the 2012→2016 gains. Decompose via Oaxaca–Blinder-style decomposition or mediation analysis.

D. Within-industry analysis
- Separate within-industry technology age from industry composition by constructing a measure of within-industry vintage (the difference between CBSA-industry modal age and national industry modal age). Regress voting on within-industry deviations to isolate technology choices rather than the CBSA’s industry mix.

E. Heterogeneity and alternative outcomes
- Test whether technology age predicts other outcomes one would expect under a causal economic-grievance mechanism: local wage growth, unemployment, labor force participation, business formation rates. If technology causes economic stagnation that leads to voting changes, there should be corresponding economic signatures.
- Test whether older-technology CBSAs are more affected by other shocks (e.g., trade shocks, plant closings) and whether those interactions predict voting.

F. Robustness to weighting scheme
- Present both unweighted (each CBSA equal) and population-weighted specifications. The choice materially affects interpretation (authors note CBSA equal-weighting). At least show both to demonstrate robustness.

G. Reporting and presentation polish
- Add 95% CIs in main tables.
- Add a short “roadmap” paragraph at the end of the Introduction telling the reader exactly what each section does and where key robustness checks are located (appendix references).
- Reduce repetition.

7. OVERALL ASSESSMENT (concise)
- Key strengths:
  - Introduces a novel dataset: modal technology age by CBSA over time.
  - Documents a striking descriptive pattern: modal technology age correlates with Republican vote share, and the technology–vote relationship appears to emerge with Trump (Romney→Trump gains).
  - Thoughtful attention to alternative interpretations (sorting vs causal) and many robustness checks already included.
- Critical weaknesses:
  - Identification is suggestive but not convincing for the causal claims or for definitively establishing sorting as the correct interpretation. Lack of rigorous pre-trend/event-study diagnostics and no stronger quasi-experimental design.
  - Key methodological literature on event-study / staggered DiD heterogeneity is not fully engaged (Sun & Abraham, de Chaisemartin & D’Haultfoeuille, etc.). Authors risk misinterpretation if they present dynamic effects without using modern methods.
  - The paper needs more direct evidence on compositional sorting (migration/entry/exit) and on economic channels (wages, employment growth) that would support either causal or sorting mechanisms.
  - Some presentation issues (figure/table captions, addition of CIs, consistent SE reporting) should be fixed.
- Specific suggestions for improvement (recap):
  - Add pre-trend/placebo event-study evidence using modern, heterogeneity-robust estimators.
  - Attempt an IV or quasi-experimental design, or recast the paper as descriptive if a credible causal strategy is infeasible.
  - Directly test sorting via migration/compositional change and show within-industry analyses to separate composition vs within-industry technology choice.
  - Add the missing methodological citations and use recommended estimators where appropriate.
  - Improve table/figure presentation (CIs, cluster counts, captions), and tighten prose.

Decision
Given the paper’s potential but the substantive flaws in identification and the need for additional robustness and methodological engagement, my recommendation is:

DECISION: MAJOR REVISION

If the authors can (1) substantially strengthen causal identification (event-study with proper methodological corrections, IV/quasi-experiment, or individual-level analysis) or (2) recast and tighten the paper as a definitive descriptive contribution with rigorous diagnostics of sorting and composition (e.g., migration evidence, within-industry tests), then the paper could become suitable for resubmission to a top general-interest journal.

Finally, to help the authors, I reproduce below the concrete BibTeX entries I recommended earlier (fill page numbers/DOIs as appropriate):

```bibtex
@article{sunab2021,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating dynamic treatment effects in event studies with heterogeneous treatment effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {175--199}
}

@article{deChaisemartin2020,
  author = {de Chaisemartin, Cl\'ement and D'Haultf\oe{}uille, Xavier},
  title = {Two-way fixed effects estimators with heterogeneous treatment effects},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  pages = {XXXX--XXXX}  % add correct pages/DOI
}

@article{borusyak2021event,
  author = {Borusyak, Kirill and Jaravel, Xavier},
  title = {Revisiting event study designs},
  journal = {Available at SSRN / Working Paper},
  year = {2021}
}

@article{oster2019,
  author = {Oster, Emily},
  title = {Unobservable selection and coefficient stability: theory and evidence},
  journal = {Journal of Business \& Economic Statistics},
  year = {2019},
  volume = {37},
  pages = {187--204}
}

@article{song2019firming,
  author = {Song, Jae and Price, David and Guvenen, Fatih and Bloom, Nicholas and von Wachter, Till},
  title = {Firming Up Inequality},
  journal = {Quarterly Journal of Economics},
  year = {2019},
  volume = {134},
  pages = {1--50}
}
```

Specific page/section citations required by the referee policy: Throughout my review I referenced sections of the manuscript (e.g., Data: Section 2, Empirical Strategy: Section 4, Results: Section 6, Gains: Section 6.6). Please add these changes in those corresponding sections: event-study and pre-trend tests in Section 4 (Empirical Strategy) and Section 6 (Results), migration/compositional tests in Section 6 (Mechanisms), and methodological citations in the Introduction and Empirical Strategy.

I am happy to reread a revised version once the authors have addressed the substantive methodological issues and added the recommended robustness checks.