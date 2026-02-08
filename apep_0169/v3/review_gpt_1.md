# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-03T22:14:50.143841
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 18703 in / 6513 out
**Response SHA256:** 58b3918e237c760d

---

Thank you for the opportunity to review this paper. The paper poses an important and timely question—how the well-documented “self‑employment earnings penalty” varies by legal form (incorporation), geography, and gender—and exploits large ACS samples to document striking heterogeneity. The decomposition is potentially valuable for researchers and policymakers. However, the paper currently overreaches in its causal language, understates identification challenges, and requires substantial methodological, robustness, and framing improvements before it would be suitable for a top general‑interest journal. Below I provide a rigorous, structured review covering format, statistical methodology, identification, literature, writing quality, constructive suggestions, and an overall assessment with a required editorial decision.

1. FORMAT CHECK (explicit, itemized)

- Length:
  - The LaTeX source is substantial. Based on the document structure (main text + appendix, many tables and figures), the manuscript appears to exceed the 25‑page threshold typical for top journals. Estimate: roughly 35–45 pages including figures and appendix (excluding references/appendix would still be >25 pages). So LENGTH seems acceptable for a full submission.

- References / bibliography coverage:
  - The bibliography covers many of the canonical empirical papers on self‑employment (Hamilton 2000; Levine & Rubinstein 2017; Moskowitz & Vissing‑Jorgensen 2002; Hurst et al. 2014) and several methodological references (Hirano et al. 2003; Oster 2019; VanderWeele & Ding 2017; Austin 2009). However, it omits key recent methodological work relevant to causal inference with panel/two‑way differences and other common quasi‑experimental designs (see Section 4 below for specific missing citations and BibTeX entries requested by the journal checklist). The omission is important because the manuscript makes causal claims from cross‑sectional IPW analysis but does not engage the literature on credible causal designs or recent cautions about TWFE and heterogeneous effects.

- Prose (Intro, Lit Review, Results, Discussion):
  - Major sections are written in paragraph form and not as bullets. The Introduction and subsequent sections are full‑paragraph prose.

- Section depth:
  - Each major section (Introduction, Theory, Data, Empirical Strategy, Results, Robustness, Discussion/Conclusion) contains multiple substantive paragraphs. Sufficient depth in the main sections is present.

- Figures:
  - Figures are included (e.g., atlas maps, bar charts). The LaTeX source references PDF files under figures/, and captions include notes about axes and units. I cannot view the images directly here, but the captions indicate the figures show estimates with confidence intervals and state maps. Please ensure all figure files are high resolution and that axes, legends, color scales, and units are clearly labeled in the final submission. Also ensure color palettes are accessible (colorblind‑safe).

- Tables:
  - All tables in the source include numeric entries (no placeholders). Tables include sample sizes and confidence intervals. Good.

Summary: The manuscript passes basic format checks (length, prose style, tables present). The main problems are substantive (methodology, identification, literature engagement, framing) rather than superficial formatting.

2. STATISTICAL METHODOLOGY (critical; must be rigorous)

Short answer: the paper reports rich descriptive and IPW results with CIs and sample sizes. That is necessary but not sufficient for a top‑journal causal claim. Several methodological strengths exist (large sample, reporting of 95% CIs, reporting N per regression, IPW diagnostics, AIPW checks, E‑values and Oster analysis). However, the current statistical strategy is not adequate to sustain the strong causal claims made in many parts of the paper without substantial additional analyses and caveats. Below I work through the required checklist items and point out failures and places that must be fixed.

a) Standard Errors:
- PASS in the sense that every reported coefficient is accompanied by a 95% CI (in brackets) and significance stars. The notes state “Robust standard errors” and present Ns. The paper displays confidence intervals for main estimates (Table 3, Table 5, etc.). This satisfies the basic requirement that coefficients have sampling inference attached.

b) Significance testing:
- PASS: p‑values / significance stars and 95% CIs are reported for main estimates.

c) Confidence intervals:
- PASS: main results include 95% CIs.

d) Sample sizes:
- PASS: N is reported in main tables and in the summary table; state‑level Ns are reported in Table 6.

e) DiD with staggered adoption (relevant?):
- Not applicable: the paper does not use DiD / TWFE with staggered timing. However, because the paper makes causal claims about the effect of "self‑employment" (treatment) on earnings using cross‑sectional IPW, a major issue is that the chosen method (selection on observables) may be inadequate: see identification comments below.

f) RDD:
- Not applicable.

Important methodological issues and failures (these render the strongest causal claims unsupportable without revision):

1. Core identification: selection on observables (IPW) vs. real causal inference
   - The identification assumption (unconfoundedness conditional on observed X) is stated clearly in Section 4, but it is extremely strong here. The authors control for demographics and a small set of covariates (age, sex, college, marital status, race indicators, homeownership, year). Yet there are obvious powerful confounders unobserved in the ACS that plausibly determine both selection into incorporated/unincorporated self‑employment and earnings: prior earnings history, occupation/industry detailed controls, prior employment status, wealth beyond homeownership, access to startup capital, entrepreneurial ability and human capital, business age (longevity), presence of paid employees, and local labor market shocks at finer geographic levels (MSA/county). These are discussed in the paper as limitations, but the strength of results and the paper's tone often imply causal effects (e.g., “Incorporated self-employed workers earn 7 percent more than comparable wage workers”), which is misleading without stronger strategies.

   - The paper’s sensitivity analyses (E‑values, Oster) are useful but insufficient. E‑values and Oster depend on certain assumptions and can be sensitive to functional form and omitted variable patterns; they do not substitute for richer identification (e.g., temporal variation, panel methods, quasi‑experiment, instruments, or boundaries/bounding approaches).

2. Cross‑sectional design and reverse causality / selection:
   - ACS is cross‑sectional. Without prior earnings or longitudinal transitions, we cannot distinguish whether high‑earning wage workers become incorporated or whether incorporated status generates higher earnings. The Roy model section correctly frames selection, but the empirical strategy does not address dynamic selection.

3. Propensity score covariates:
   - The propensity model omits very relevant covariates that are available in ACS and should be included (e.g., occupation and industry codes, class of worker prior indicators if available, public sector indicator, detailed educational attainment beyond bachelor’s, commuting/urban status, MSA fixed effects or county/state controls, family composition, presence of children, nativity/years since immigration). Including occupation and industry is particularly critical: self‑employed and wage workers in different industries will have systematically different returns. The omission is likely to bias IPW estimates.

4. Clustering / inference with geographic variation:
   - The paper reports robust standard errors. Given that many of the analyses focus on state‑level heterogeneity (10 states), inference for coefficients that vary by state or where treatment assignment is correlated within states may need clustering at the state level or, where the number of clusters is small (10), wild bootstrap inference or randomization inference. The paper does not report clustered SEs or discuss small‑cluster inference. For state‑level estimates, this is particularly important for any cross‑state comparisons or for interactions with state variables.

5. Weight trimming and overlap:
   - The paper trims weights at the 99th percentile and reports propensity score ranges and overlap. However, the stated estimated propensity scores (0.02–0.17) for aggregate self‑employment indicate the treated probability is low and reweighting could be sensitive to extreme weights; trimming addresses some issues but more diagnostics (percent effective sample size, distribution of weights by subgroup, plots of weighted covariate balance across many variables) are needed to convince readers.

6. Balance and representation of unincorporated heterogeneity:
   - The unincorporated category is very heterogeneous. The authors acknowledge this but then treat it as a single group. More within‑group heterogeneity analyses (by industry, occupation, presence of paid employees, income quantiles among unincorporated) are necessary to make credible statements about "the unincorporated penalty."

7. Causal language and policy implications:
   - Given the limitations above, many policy recommendations (e.g., reclassifying gig workers as employees) go beyond what the cross‑sectional IPW design can support. The paper should substantially temper causal claims unless additional identification strategies are implemented.

Bottom line: The paper meets the technical minimum of providing standard errors, confidence intervals, and reporting N. Nevertheless, the causal identification strategy is weak for the strong causal claims made. In its current form the paper is not publishable in a top general‑interest journal as a causal contribution. It may be publishable as a careful descriptive decomposition with very explicit caveats—but the manuscript repeatedly interprets associations as causal “effects.” To be acceptable for top journals as causal work, the authors must substantially strengthen identification or frame the contribution as descriptive and be cautious with policy recommendations.

3. IDENTIFICATION STRATEGY (credibility and tests)

- Credibility:
  - The stated identification strategy (IPW under selection on observables) is clearly described (Section 4). The author(s) thoughtfully discuss unobserved confounding and present sensitivity analyses. This transparency is good.

- Key assumption discussion:
  - The paper discusses selection on observables and recognizes its strength as an assumption (see Section 1.4, “The Empirical Challenge” and Section 9). Good. However, there is insufficient exploration of whether the observed covariates plausibly satisfy conditional independence in this context. In particular, the absence of industry/occupation and prior earnings is a major omission. The authors should demonstrate how inclusion of these controls affects estimates. They should also discuss common measurement error concerns (income underreporting by the self‑employed) more thoroughly, and whether it is differential by incorporation.

- Placebo tests and robustness:
  - The paper includes some robustness checks: year splits, full‑time sample, AIPW, placebo among retirees / not in labor force, E‑values, and Oster coefficients. These are useful and should remain. But more targeted placebo tests would strengthen the case:
    - Placebo outcomes (e.g., outcomes not plausibly affected by current employment status such as childhood characteristics or prior year variables if available).
    - Falsification via variables that should be unaffected (e.g., education) to check for residual confounding.
    - Regression discontinuity around incorporation law changes or state policy shocks (see constructive suggestions).

- Do conclusions follow from evidence?
  - The descriptive conclusions about heterogeneity in the association between self‑employment and earnings are supported by the presented IPW estimates. However, causal interpretations (e.g., “incorporation provides advantages that generate higher earnings”) are not fully warranted without stronger identification or much more cautious language. Some of the policy prescriptions and "mechanisms" are speculative.

- Limitations discussion:
  - The manuscript has a limitations subsection (Section 9 robustness/limitations) that lists many of the same caveats I raise. This is good; the tone should be moved earlier and invoked whenever causal language is used. But the limitations discussion should be expanded and tied to explicit sensitivity exercises.

4. LITERATURE (missing and needed references)

The paper cites several important empirical and methodological references, but several key methodological works (especially on DiD and causal inference with heterogeneous effects) and important empirical/structural literature on entrepreneurship and self‑employment are missing. Because the paper emphasizes causal interpretation and state heterogeneity, it should explicitly situate itself in the methodological literature and in quasi‑experimental work on entrepreneurship or effects of incorporation.

I strongly recommend adding the following papers (minimum); for each I provide why it is relevant and a suggested BibTeX entry.

A. DiD/staggered timing / heterogeneous effects literature (relevant because the paper draws causal inference and presents state‑level heterogeneity; at minimum these works should be cited as background on threats from pooling and naive methods):

1) Callaway, Brantly, and Pedro H. C. Sant'Anna (2021) — methods for DiD with multiple time periods and treatment timing heterogeneity (Callaway & Sant'Anna). Even if you do not use DiD, cite because it addresses bias when using TWFE in heterogeneous treatment settings.

Why relevant: The field has learned that TWFE can be misleading with heterogeneous effects; if the authors later add a difference‑in‑differences or event‑study using state policy variation (e.g., changes in incorporation costs, tax rules) this literature provides correct estimators.

BibTeX:
@article{CallawaySantAnna2021,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference‑in‑Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}

2) Goodman‑Bacon (2021) — decomposes TWFE DiD and shows biases arise with staggered treatment timing.

Why relevant: Same as above.

BibTeX:
@article{GoodmanBacon2021,
  author = {Goodman‑Bacon, Andrew},
  title = {Difference‑in‑Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}

3) de Chaisemartin & D’Haultfoeuille (2020) — alternative robust DiD approach.

Why relevant: Methodological context for heterogeneous effects.

BibTeX:
@article{deChaisemartin2020,
  author = {de Chaisemartin, Cl\'{e}ment and D'Haultf\oe{}uille, Xavier},
  title = {Two‑Way Fixed Effects Estimators with Heterogeneous Treatment Effects},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  pages = {296--302}
}

B. RDD / other causal design methodological references (if authors ever pursue local policy discontinuities):

4) Imbens & Lemieux (2008) — RDD tutorial for economists.

Why relevant: If exploring RDD around thresholds (e.g., firm size thresholds for regulation), this is essential.

BibTeX:
@article{ImbensLemieux2008,
  author = {Imbens, Guido W. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {615--635}
}

5) Lee & Lemieux (2010) — RDD in practice economics survey.

Why relevant: Similar reason.

BibTeX:
@article{LeeLemieux2010,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  pages = {281--355}
}

C. Entrepreneurship / self‑employment empirical work that should be discussed (additional context):

6) Kerr, Nanda & Rhodes‑Kropf (2014) — entrepreneurship and returns literature (startup returns, financing).

Why relevant: Provides broader theoretical context for entrepreneurship returns.

BibTeX:
@article{KerrNandaRhodesKropf2014,
  author = {Kerr, William R. and Nanda, Ramana and Rhodes‑Kropf, Matthew},
  title = {Entrepreneurship as Experimentation},
  journal = {Journal of Economic Perspectives},
  year = {2014},
  volume = {28},
  pages = {25--48}
}

7) Blanchflower & Oswald (1998) is cited; consider adding more recent work on gig economy (Katz & Krueger 2019 is cited), and papers on employer vs own‑account distinctions.

D. Methodology for IPW and causal inference with high‑dimensional/machine learning propensity scores:

8) Chernozhukov et al. (2018) — double/debiased machine learning.

Why relevant: Useful if you plan to use machine learning for propensity/ outcome models and to bolster robustness.

BibTeX:
@article{Chernozhukov2018,
  author = {Chernozhukov, Victor and Chetverikov, Denis and Demirer, Mert and Duflo, Esther and Hansen, Christian and Newey, Whitney and Robins, James},
  title = {Double/Debiased Machine Learning for Treatment and Structural Parameters},
  journal = {The Econometrics Journal},
  year = {2018},
  volume = {21},
  pages = {C1--C68}
}

Notes: The authors already cite Hirano, Imbens, & Ridder (2003), which is good. Also cite Abadie (2005) if profiles for matching, and Abadie & Imbens (2006) for matching variance.

I have included the minimum key citations the manuscript should engage with (Callaway & Sant'Anna, Goodman‑Bacon, Imbens & Lemieux, Lee & Lemieux, Chernozhukov). Please add these to the literature review and explain how their lessons inform your empirical approach.

5. WRITING QUALITY (critical)

Overall: the manuscript is readable, generally well structured, and not written in bullets. The narrative is compelling and the introduction hooks the reader with the well‑known Hamilton puzzle and motivates the importance of disaggregation. Nevertheless, there are several serious writing and framing issues to address:

a) Prose vs. bullets:
  - PASS. Major sections are paragraph prose.

b) Narrative flow:
  - The narrative structure (motivation → previous literature → three open questions → empirical challenge → preview of findings) is strong. However, the current draft sometimes slides from descriptive language into causal language without making the distinction explicit. Tighten language to distinguish associations from causal effects, or bolster identification as suggested below.

c) Sentence quality / placement of key insights:
  - Generally clear and concise. Some paragraphs are long and try to do too much—break them into shorter paragraphs, especially in the Results and Discussion sections. Place the main finding of a paragraph at the opening sentence, not buried in the middle.

d) Accessibility:
  - The econometric methods are explained, but readers who are not causal inference specialists may not appreciate the limitations. Provide more intuition for IPW (how it works, what it aims to accomplish) and for the sensitivity measures (E‑value, Oster) in brief nontechnical language in the main text; relegate technical details to the appendix.

e) Figures / Tables—self‑explanatory:
  - Table and figure captions are generally informative. But some table notes specify that outcomes are converted to percentage using the exponential formula; consider including a short parenthetical next to log coefficients in the tables to show the % interpretation. Ensure figure maps include legends and confidence bands, and that the figures are readable in black & white print.

f) Tone and policy claims:
  - The Discussion (policy implications) overinterprets causal implications (e.g., suggesting reclassification of gig workers as employees). Tone down policy prescriptions or clearly mark them as contingent on causal interpretation and future research.

6. CONSTRUCTIVE SUGGESTIONS (how to make it stronger)

The paper is promising; with substantive changes it could make a strong contribution. Below are concrete recommendations—some are high‑priority, others are recommended to improve credibility and impact.

High‑priority methodological/identification improvements (required before top‑journal acceptance):

1. Add richer covariates to the propensity score and outcome models
   - Include detailed occupation and industry dummies (2‑ or 3‑digit SOC/NAICS), MSA or county fixed effects (or at least urban/rural and MSA indicators), nativity/years since immigration, number of children, presence of children under 6, veteran status, more granular education categories, public‑sector indicator, and (if available) indicators of firm size or employer characteristics for prior job. These are likely available in ACS PUMS and will materially change balance.

2. Control for prior earnings or use pre‑treatment earnings in a panel / pseudo‑panel design
   - The lack of prior earnings is a major confounder. Options:
     a) Use CPS or SIPP panel data that track individuals over time (if accessible) to estimate earnings changes at transitions to self‑employment and incorporate firm formation. Hamilton (2000) used longitudinal methods—replicating a similar transition analysis for incorporation (switchers) would be very persuasive.
     b) Construct a pseudo‑panel tying individuals across ACS waves is not possible, but you could use retrospective variables if any exist, or auxiliary data linking pre‑treatment earnings from tax records (if you can access). If not possible, explicitly emphasize that the analysis is cross‑sectional and reframing the paper as descriptive with careful causal caveats.

3. Exploit quasi‑experimental variation if possible
   - Search for plausibly exogenous policy variation that affects incorporation costs/benefits (state law changes on LLC/S‑corp taxation, fees, registration requirements, state‑level programs that reduce incorporation cost) and use difference‑in‑differences (with appropriate modern DiD estimators like Callaway & Sant'Anna) to estimate causal effects of incorporation on earnings (or selection into incorporation). This would dramatically improve causal credibility.

4. Use IV or bounding methods if quasi‑experiment not available
   - Instruments could include state‑level variation in incorporation costs or deadlines (if plausibly exogenous). If valid instruments cannot be found, consider partial identification (bounds), or communicate clearly that estimates are associations.

5. Improve inference for state comparisons
   - When comparing across states, cluster standard errors at the state level, but with only 10 clusters use wild cluster bootstrap (Cameron et al.) or present randomization inference where possible. Discuss the small number of independent clusters and interpret state comparisons with caution.

6. Expand heterogeneity / mechanism analysis
   - Disaggregate unincorporated category by occupation/industry and income quantiles to show which parts of the unincorporated distribution drive the large penalty.
   - Examine “employer” vs “own‑account” within self‑employment if possible (ACS may have an indicator for number of employees?).
   - If ACS has a variable for weeks worked or number of weeks employed, include that to better decompose hours vs returns per hour.
   - Examine retention of earnings (e.g., business income vs wage income) if the ACS shows schedule or business income components—acknowledge measurement error.

7. Address measurement error / underreporting
   - Hurst et al. (2014) is cited. Consider adjusting for potential income underreporting by self‑employed (sensitivity analysis), or at least quantify how differential underreporting by incorporation status could change results.

8. Strengthen propensity‑score diagnostics and present them
   - Provide plots of propensity score overlap by comparison (incorporated vs wage, unincorp vs wage), distribution of weights, effective sample size after weighting, and detailed balance tables for many covariates (including industry/occupation after you add them). Report weighted means/standardized differences in the appendix.

9. Clarity about causal language
   - If you cannot execute stronger causal strategies, reframe the paper as a careful descriptive decomposition and explicitly avoid calling the IPW estimates “causal effects.” Where causal language is used, make it conditional (“conditional association” or “average difference conditional on observed covariates”).

Medium‑priority robustness/extensions (recommended to increase impact):

10. Use doubly robust/machine‑learning methods
    - Implement double/debiased machine learning (Chernozhukov et al.) or targeted maximum likelihood estimation (TMLE) to check robustness of IPW estimates when using high‑dimensional controls.

11. Explore dynamics (age or tenure of business)
    - If ACS indicates weeks worked or business age, show how effects vary with tenure in self‑employment. If not available, acknowledge limitation more strongly.

12. Explore local labor market controls
    - Add MSA × industry interactions or include MSA fixed effects to control for local opportunity structure.

13. Provide more detailed discussion of mechanisms
    - Use supplementary tables to show sectoral composition of incorporated vs unincorporated by gender and state to illuminate whether compositional mechanisms explain much of the observed gender/incorporation gap.

14. Robustness: alternative outcome measures
    - Use log weekly earnings or log hourly wages (earnings / usual hours) as outcomes where possible to separate hours vs pay per hour effects.

15. Closer engagement with entrepreneurship literature
    - Connect to literature on access to finance, social networks, and female entrepreneurship (cite studies on gendered access to capital).

7. OVERALL ASSESSMENT

- Key strengths:
  - Important and policy‑relevant question.
  - Very large, recent data set with clear operationalization of incorporated vs unincorporated self‑employment (ACS class of worker codes).
  - Clear, well‑written exposition and a compelling visual “atlas” of state heterogeneity.
  - Thoughtful sensitivity checks (E‑value, Oster, AIPW) and reporting of sample sizes and CIs.

- Critical weaknesses:
  - The main empirical identification relies on selection on observables but omits extremely important covariates (industry/occupation, prior earnings) and therefore cannot sustain strong causal claims.
  - Cross‑sectional design: dynamic selection and prior earnings are not addressed; conclusions about “returns to incorporation” risk conflating selection and treatment.
  - Inference for state comparisons and interactions requires careful clustering / small‑cluster methods and reporting.
  - Policy recommendations are sometimes stated too strongly given the observational design.
  - Missing methodological citations important for any paper making causal claims or using cross‑state comparisons (Callaway & Sant'Anna, Goodman‑Bacon, Imbens & Lemieux, Lee & Lemieux, etc.).

- Specific suggestions for improvement (summary):
  - Add industry/occupation/MSA controls and re‑run IPW.
  - Where possible, use panel data or quasi‑experimental variation (state law changes) to identify causal effects of incorporation or self‑employment.
  - Expand heterogeneity and mechanism analyses (sectoral composition, employer vs own‑account, hours vs wage per hour).
  - Adjust inference for state‑clustered comparisons and address small number of clusters.
  - Moderate causal language and provide clearer framing as descriptive if causal identification cannot be strengthened.
  - Add the missing methodological literature (see Section 4 above) and explain how their findings inform the present strategy.

8. DECISION (required)

Given the substantive importance of the topic and the reasonable descriptive evidence, but given the major identification and interpretation issues that must be addressed before making causal claims or strong policy prescriptions, I recommend:

DECISION: MAJOR REVISION

If the authors take the revision seriously—either by substantially strengthening causal identification (preferred) or by reframing claims as descriptive and executing the robustness/heterogeneity analyses and improved diagnostics described above—this paper would become a much stronger candidate for publication in a top journal.

Minor final editorial notes (to assist revision)
- Cite the missing methodological references above and add their BibTeX entries.
- Provide full figure files in high resolution and ensure colorblind‑safe palettes.
- Move the limitations/identification caveats earlier in the paper (end of Introduction) so readers see them before encountering strong causal statements.
- Add appendix tables with full balance diagnostics and the exact propensity score specification.

I am happy to review a revised version that addresses the above points.