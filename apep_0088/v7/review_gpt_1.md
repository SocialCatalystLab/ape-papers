# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-07T03:58:26.550048
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 27301 in / 5147 out
**Response SHA256:** bdb4a47c827e7351

---

Thank you for the opportunity to review this interesting paper. The question—do successful sub‑national climate policies build public demand for national action or instead satisfy (and thereby reduce) demand—is important for both research and policy. The Swiss referendum setting is promising, and the author uses a thoughtful suite of designs (OLS with language controls, spatial RDD, Difference‑in‑Discontinuities, modern staggered‑DiD methods, and permutation/wild bootstrap inference). The headline result—a negative local treatment effect (≈ −5.9 pp at same‑language canton borders)—is plausible and economically meaningful.

That said, there are several substantive and presentation issues that must be addressed before this paper is publishable in a top general interest journal. Below I provide a comprehensive review organized according to your requested checklist: format, statistical methodology (fatal checks), identification, literature, writing, constructive suggestions, overall assessment, and a decision.

1. FORMAT CHECK

- Length:
  - The provided LaTeX source plus appendices is substantial. My estimate: main text ≈ 25–30 pages and appendices ≈ 25–30 pages (total ≈ 50–60 pages). If the target journal requires a 25‑page main text limit (excluding refs/appendix), the main text appears to be around that threshold; please confirm final page counts in the compiled PDF and indicate which material you plan to keep in the main text versus the online appendix.

- References:
  - The bibliography is extensive and covers most of the relevant literatures (RDD, few‑cluster inference, policy feedback, federalism, Swiss politics, modern DiD literature). Good coverage overall.
  - Minor omissions noted below in the Literature section (I suggest adding a couple of references on spatial RDD implementation and border inference).

- Prose:
  - Major sections (Introduction, Conceptual Framework, Institutional Background, Empirical Strategy, Results, Discussion, Conclusion) are written as continuous prose, not bullets. This is good.
  - The Data appendix contains some bullet lists (acceptable for enumerating referendums and treatment verification).

- Section depth:
  - Most major sections (Intro, Conceptual Framework, Empirical Strategy, Results, Discussion) have multiple substantive paragraphs. The Introduction and Results are particularly well developed.

- Figures:
  - The LaTeX shows included figures (maps, RDD plots, diagnostics). Assuming the compiled PDF displays them, the captions are informative. The source indicates axis/scales and notes. In a final submission: ensure all figure axes include units and tick labels readable at journal size.

- Tables:
  - Tables display real numbers and standard errors. No placeholders. Good.

2. STATISTICAL METHODOLOGY (CRITICAL)

General appraisal: The paper is methodologically ambitious and mostly implements appropriate modern techniques. However, a few crucial methodological issues need clarification, stronger robustness, or additional analyses. Below I follow your checklist of mandatory items.

a) Standard errors:
  - Coefficients in tables have SEs in parentheses. RDD results report bias‑corrected SEs and 95% CIs (Calonico et al. corrections). DiD/DiDisc and OLS tables report clustered SEs. Good.

b) Significance testing:
  - Multiple forms of inference are presented: (i) analytic/bias‑corrected SEs and CIs for RDD (Calonico et al.), (ii) cluster‑robust SEs (canton clustering), (iii) border‑pair clustering, (iv) wild cluster bootstrap (Webb weights), and (v) permutation inference. This is the right spirit.

c) Confidence intervals:
  - RDD specifications include 95% CIs (bias‑corrected). Good.

d) Sample sizes:
  - N is reported for regressions and bandwidth samples (e.g., Table 6 reports N within bandwidths). The paper also reports canton and municipality counts. Good.

e) DiD with staggered adoption:
  - The author explicitly references and implements Callaway & Sant’Anna (2021) and Goodman‑Bacon concerns. Appendix Table (Callaway‑Sant’Anna results) is provided. This is appropriate. A few clarifying points are needed (see Identification/Constructive Suggestions).

f) RDD diagnostics (McCrary and bandwidth sensitivity):
  - The paper reports McCrary tests, bandwidth sensitivity, donut RDDs, covariate balance, and border‑pair heterogeneity forest plots. These are necessary. However:
    - The McCrary test results are only summarised graphically (appendix figure) and description indicates “no discontinuity,” but the exact estimated density jump and p‑value are not stated numerically. Please report the McCrary test statistic and p‑value(s) for each primary specification (pooled & same‑language).
    - For spatial RDD it is especially important to show (a) that municipality centroids relative to borders do not cluster suspiciously, and (b) that the density test is robust to alternative binning/choices. Provide numerical results.
    - The Donut RDD shows attenuation when excluding the immediate border zone (which the paper interprets substantively). That result is informative (treatment concentrated close to border), but it also raises concerns about spatial spillovers/contrast effects—see Identification below.

Summary of statistical checklist pass/fail:
  - The paper passes the basic statistical requirements: SEs, p‑values, 95% CIs, and sample sizes are reported; DiD with staggered timing is handled with Callaway‑Sant'Anna; RDD diagnostics performed. So no fatal omission of inference. Good.

BUT: The RDD identification faces an important threat—pre‑existing border discontinuities for other referendums—reported in the Placebo RDD results (Appendix). Those placebos constitute a substantive challenge (see Identification), and they must be addressed convincingly. Because this is a potential identification breach rather than a simple inference issue, it is critical for the paper’s credibility.

3. IDENTIFICATION STRATEGY

Strengths:
  - Spatial RDD at canton borders is a sensible design given the policy is canton‑level and borders are exogenous to recent municipal sorting.
  - The language confound (Röstigraben) is acknowledged and handled by restricting to same‑language canton borders (German–German). That is necessary and appropriate.
  - The author implements Difference‑in‑Discontinuities (DiDisc) to net out permanent border effects, and modern staggered DD (Callaway & Sant’Anna). Permutation and wild bootstrap inference are used to address few clusters.

Main identification concerns (these must be addressed and substantially strengthened):

A. Placebo discontinuities at the same borders on unrelated referendums (Appendix, “Placebo RDD”):
  - Appendix Table (Placebo RDD) shows statistically significant discontinuities at the same canton borders for unrelated referendums (Immigration Feb 2016: +4.05 pp, Corporate Tax Reform Feb 2017: −3.27 pp). This suggests the same borders have pre‑existing political discontinuities unrelated to energy laws.
  - The author acknowledges this and argues that DiDisc (border‑pair FE) differences out these permanent discontinuities. That is a sensible mitigation, but I recommend additional, explicit evidence that the DiDisc is doing what is claimed:
    - Show pre‑treatment RDD (e.g., for 2000/2003 referendums) at the same borders and quantify whether the discontinuity changed after the canton adopted energy laws. A graphical “difference of RDD plots” (pre vs post) for the same border segments would be persuasive.
    - Present event‑study like RDD estimates across multiple referendums (pre/post) for the same border pairs. This connects directly to the Difference‑in‑Discontinuities idea and shows changes in discontinuities over time.
    - In addition to border‑pair FE, consider including border‑pair × time trends (or border‑pair × referendum FE) if feasible, to show robustness to slowly varying border differences.

B. Spatial spillovers and the near‑border mechanism:
  - The paper’s substantive mechanism emphasizes a near‑border contrast: treated municipalities close to untreated neighbors see the contrast and update downward. That narrative fits the observed near‑border dip, but it creates two concerns:
    - Spillover/contagion: residents on the control side may be influenced by policies implemented in the treated canton (cross‑border commuting, shopping, communications). If control residents near the border were exposed to treated‑canton policy effects, then the estimated discontinuity could be biased (attenuated or amplified depending on spillover direction). The Donut RDD that excludes very near municipalities changes estimates, indicating sensitivity.
    - Possible selective implementation or enforcement differences across canton borders that correlate with other policies or with local parties. The significant placebo discontinuities on other referendums make this plausible.
  - Suggested analyses:
    - Estimate spillover decay functions: regress yes‑share on distance to the nearest treated canton border (non‑signed) and interact with being on treated vs control side. Plot the fitted curves to show how the treatment effect decays with distance on each side.
    - Implement a local randomization RDD (Cattaneo et al.) using a narrow window to treat municipalities within a very small distance as plausibly randomized, and perform Fisher‑type randomization inference restricted to that window.
    - Include covariates that capture cross‑border interaction intensity (commuting flows, shared media markets, cross‑border infrastructure) and check whether results are robust controlling for these.

C. Small number of treated cantons and cluster inference:
  - The paper already uses wild cluster bootstrap (Webb weights) and reports multiple clustering choices; good. But a few clarifications would increase confidence:
    - Report the exact number of border pairs used in the same‑language RDD and their distribution of municipality counts. When clustering by border pair, there are only ~13 clusters (paper reports p = 0.045 with border‑pair clustering), which is small. For such few clusters, wild bootstrap is recommended but has limitations. Consider randomization inference tailored to the RDD: permute treatment status across border pairs (not across cantons) and recompute RD estimates to form a permutation distribution. This aligns the inference to the level of variation.
    - Provide the wild bootstrap implementation details: number of bootstrap draws, algorithm, and whether bootstrap is applied to the bias‑corrected RD estimator (Calonico et al.'s approach).

D. Use of canton‑level language vs. Gemeinde‑level language:
  - Using canton majority language to classify same‑language borders is defensible, but it may leave residual local language heterogeneity (e.g., French‑speaking Gemeinden inside Bern near Jura). The author notes this in limitations, but robustness checks using municipality‑level language (from census) would strengthen claims that same‑language restriction eliminates Röstigraben confounding locally. If municipality‑level language is noisy or unavailable, consider alternative proxies (municipal vote shares on language‑sensitive referendums pre‑2011) to validate language homogeneity near the borders used.

E. Donut RDD sign reversal at large exclusion radii:
  - The donut RDD (Appendix) shows sign reversal when excluding municipalities within 2 km. The author argues this is expected because the effect concentrates near the border. This is plausible, but it could also indicate the local discontinuity is not robust and is driven by a small set of municipalities that are atypical. To increase confidence:
    - Identify the specific municipalities that drive the effect when including the 0–2 km band. Report their characteristics (population, urban/rural, economic composition, media markets, local politics). If a handful of towns are driving the result, the authors should examine whether these are outliers or have other features causing the discontinuity.

F. Placebo tests:
  - The author runs placebo RDDs on unrelated referendums, which is excellent. The fact that some unrelated referendums show discontinuities at the same borders is a red flag that must be fully integrated into the paper’s interpretation: either explain why energy RDD results are robust to these persistent border discontinuities (DiDisc attempt), or show that the post‑adoption change is unique to energy referendums.

4. LITERATURE (Provide missing references)

The literature coverage is generally very good and includes the key methodological and substantive works. A few additional citations would strengthen both the methods and policy literatures:

a) Spatial / border analysis and inference:
  - Abadie, Diamond & Hainmueller (2010/2012) on synthetic control is not directly necessary, but sometimes border analyses use SC to construct counterfactual regions; optional.
  - Cattaneo, Frandsen & Titiunik (2015) on randomization inference in RDDs / local randomization approach—this is useful when the RDD window is small and permutation inference is appropriate.
  - Ferman, Pinto & Possebom (2019) on inference with few treated groups (they already cite Ferman & Pinto 2019 in the bibliography—good).

I recommend adding the following two methodological papers (with BibTeX). They are not absolutely required but are useful citations for readers interested in spatial RDD/local randomization and border inference.

- Cattaneo et al. on local randomization:

```bibtex
@article{cattaneo2015randomization,
  author = {Cattaneo, Matias D. and Frandsen, Brigham R. and Titiunik, Rocio},
  title = {Randomization Inference in the Regression Discontinuity Design: An Application to Party Advantages in the Uruguayan Senate},
  journal = {Journal of Causal Inference},
  year = {2015},
  volume = {3},
  pages = {1--21}
}
```

- Keele, Titiunik and others already present; another helpful practical guide:

```bibtex
@book{cattaneo2020practical,
  author = {Cattaneo, Matias D. and Idrobo, Nicolas and Titiunik, Rocio},
  title = {A Practical Introduction to Regression Discontinuity Designs: Foundations},
  publisher = {Cambridge University Press},
  year = {2020}
}
```

(You already cite Cattaneo et al. 2020 and Keele & Titiunik—good. If you prefer, cite the local randomization approach explicitly.)

Additionally, in the policy feedback literature consider citing work synthesizing policy feedback in regulatory domains (negative or mixed feedback):

- Hacker, Theda. (2004) "The Historical Logic of National Institutional Development" is often cited in policy feedback contexts. Optional.

You already cite the major policy feedback literature (Pierson, Mettler, Campbell) and thermostat literature (Wlezien, Soroka & Wlezien). Good.

5. WRITING QUALITY (CRITICAL)

Overall quality:
  - The paper is well written. The Introduction is engaging and frames the question clearly. The narrative flow from motivation → institutional setting → design → results → interpretation is logical.

Strengths:
  - The motivation is crisp, the conceptual framework lays out alternative hypotheses clearly (positive feedback vs. thermostat), and the Discussion ties the empirical findings back to theory and policy.
  - Figures and tables are explained thoroughly in text.

Areas for improvement:
  - Make the role of the Placebo RDDs and DiDisc clearer earlier. Currently the Placebo RDD results (which raise an important identification issue) are in the appendix; given their importance, bring a summary and response into the main Results section (e.g., a paragraph in the RDD diagnostics or Identification section) so readers know the author confronted this threat head‑on.
  - Some methodological descriptions (e.g., corrected sample construction and how distances are computed) are technical and currently in the Appendix. That's fine, but in the main text provide a slightly clearer, short paragraph summarizing the corrected construction and why it matters. The present description is good but dense.
  - Clarify how the DiDisc border‑pair fixed effects are implemented (which pairs, how many; are some pair FE dropped because of lack of variation?). A short sentence in the main results would help.

Form/style:
  - The writing uses many good concrete examples (homeowner costs, cross‑border observation). Continue this—policy readers appreciate concrete magnitudes.
  - There are a few long paragraphs; consider breaking them into smaller ones for readability.

6. CONSTRUCTIVE SUGGESTIONS (to strengthen and increase impact)

Below are concrete analyses and framing changes that would increase credibility and impact:

A. Strengthen evidence that the observed discontinuity is driven by policy experience (not persistent border differences)
  - Produce pre/post RDD plots for each major border pair (or aggregated across same‑language pairs): show discontinuity before MuKEn adoption and after. The key test is whether the discontinuity at the same borders increased (in magnitude or sign) after treatment adoption. This is the natural placebo / event‑study check for DiDisc.
  - Alternatively, implement a border‑pair specific event study: for each border pair, estimate RDD discontinuity across multiple referendums and plot the time series of discontinuities.

B. Robustness: alternative inference tailored to RDD
  - Implement permutation inference at the border‑pair level: randomly reassign which border pairs are treated (subject to maintaining treated canton counts) and recompute RDD. This permutation distribution is more faithful to the structure of variation and small number of clusters than canton or municipality clustering.
  - Provide numerical McCrary test statistics and p‑values for each main specification and alternative binning choices.

C. Address possible spillovers and local comparisons
  - Estimate treatment effect as a function of distance (not just binary inside/outside bandwidth). Fit flexible kernels to visualize the effect decay and show whether control side experiences spillovers.
  - Control for commuting patterns (if available): include cross‑border commuting intensity as a control or instrument for local cross‑border interactions.

D. Municipality‑level language and other covariates
  - If possible, use municipality‑level language or share of French/German speakers from census to more precisely define same‑language borders and to adjust for within‑canton language heterogeneity. This reduces the measurement error from using canton majority language.

E. Heterogeneity analyses
  - The urban/rural heterogeneity is informative but limited. Consider heterogeneity by:
    - Homeownership share (owners likely bear retrofit costs).
    - Median income or building age (older building stock more affected by retrofit rules).
    - Share employed in construction/installation sectors (who might benefit).
  - These can illuminate the mechanism: if homeowners and construction‑sector workers respond differently, this supports a cost salience channel.

F. Clarify DiD / Callaway‑Sant’Anna implementation
  - Provide more details on assumptions, control groups used, and whether covariate‑adjusted CS estimators were used. In the appendix Table you report group‑time ATTs; in the main text summarize these and interpret.
  - Discuss whether staggered timing and limited post‑treatment periods (e.g., BL and BS have little post‑treatment time) limit power or bias in CS estimates.

G. Interpretation and policy framing
  - The policy implications are strong—sub‑national success can cap national ambition—but be careful not to overgeneralize beyond contexts like Switzerland (direct democracy, strong cantonal autonomy). The paper acknowledges external validity concerns; add a few sentences suggesting what institutional features make the thermostat more or less likely (direct democracy, visibility of compliance costs, media markets).

H. Replication and code
  - The paper links to replication materials on GitHub—excellent. In the replication README include exact code to reproduce the primary RDD and DiDisc results, the wild bootstrap settings, and the corrected distance construction script.

7. OVERALL ASSESSMENT

Key strengths:
  - Important and policy‑relevant question.
  - Thoughtful, modern empirical strategy combining spatial RDD, DiDisc, permutation inference, and staggered DiD methods.
  - Clear writing and strong presentation of main results.
  - The same‑language border restriction is a sensible way to address the dominant language confound.

Critical weaknesses (must be addressed):
  - Placebo RDDs show that the same canton borders have discontinuities for other, unrelated referendums. This threatens the identifying assumption that only the energy policy changed discontinuously at those borders. The paper attempts to address this with DiDisc, but stronger and more explicit pre/post RDD evidence is needed to convince readers that the observed change is causally attributable to MuKEn adoption rather than pre‑existing border politics.
  - Potential spillovers and the concentration of effects in the immediate border zone warrant deeper exploration (local randomization, distance decay, cross‑border interactions).
  - Inference at the border‑pair level uses few clusters. Although the author uses wild bootstrap and permutation checks, I recommend additional border‑pair permutation inference tailored to the RDD and better reporting of exact bootstrap procedures.

Specific suggestions for revision (summary):
  - Bring the placebo RDD results and the DiDisc mitigation into the main text; show pre/post RDD plots across referendums to demonstrate that discontinuities changed after adoption.
  - Report McCrary statistics numerically and provide more details on the wild bootstrap/perm inference implementations; consider permutation inference at the border‑pair level.
  - Use municipality‑level language where available to sharpen the same‑language specification.
  - Explore spillovers/decay, incorporate commuting or cross‑border interaction measures, and report whether results remain when adjusting for them.
  - Expand heterogeneity tests (homeownership, building age, construction employment) to illuminate mechanism.
  - Clarify Callaway‑Sant’Anna implementation and how cohort structure may affect estimates given limited post periods for late adopters.
  - Make minor presentation improvements: bring some diagnostics into main Results, add McCrary numbers, and confirm figure axis labels and readability.

8. DECISION

The paper is promising and potentially an important contribution, but the identification concerns stemming from persistent border discontinuities and possible spillovers are substantial. They are addressable with additional analyses and clearer presentation, but they are not trivial. Therefore I recommend a revision that is more than minor.

DECISION: MAJOR REVISION

If the authors address the issues above—especially the placebo RDD findings and provide convincing pre/post discontinuity evidence, border‑pair permutation inference, and spillover analyses—this paper could be a strong candidate for publication in a top general interest journal.