# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-01T00:26:19.041153
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 37231 in / 7061 out
**Response SHA256:** b16b3ded692a8ffe

---

Thank you for the opportunity to review this interesting paper. The question — whether prior sub‑national climate policy increases or decreases popular demand for national climate action — is important for climate governance and federalism literatures. The paper uses a clever spatial RDD at internal canton borders in Switzerland, supplemented by OLS, permutation inference, wild cluster bootstrap, a Callaway–Sant’Anna staggered-DiD panel, and a Difference‑in‑Discontinuities design. The empirical implementation is substantial and the paper is generally well organized.

That said, the manuscript is not yet ready for a top general-interest or AEJ: Economic Policy publication. Below I provide a detailed, rigorous review organized by the requested checklist: format, statistical methodology (critical), identification, literature, writing quality, constructive suggestions, and an overall assessment. I conclude with a single explicit editorial decision.

1. FORMAT CHECK

- Length: The manuscript (main text + appendices) is long — the PDF pages run into the 60s (page numbers show up through 62 in the appendix). The main paper (excluding appendices/references) appears to be >25 pages. That satisfies the length requirement for a full empirical paper. (See page headers / figure page numbers throughout the file.)

- References: The bibliography is expansive and includes most canonical references for policy feedback and the econometric methods used (Pierson; Mettler; Campbell; Keele & Titiunik; Calonico et al.; Callaway & Sant’Anna; Goodman‑Bacon; Cameron et al.; MacKinnon & Webb; Young). However, some contemporary papers and best-practice diagnostics relevant to staggered DiD and robustness to pre-trend violations and spatial dependence are missing (see Section 4 below for specifics and BibTeX entries I recommend adding).

- Prose: Major sections (Introduction, Theoretical Framework/Literature, Institutional Background, Data, Empirical Strategy, Results, Discussion, Conclusion) are written in paragraph form, not bullets. Good.

- Section depth: Most major sections contain multiple paragraphs and substantive discussion. For example: Introduction (pp. 1–4) provides motivation and contributions across 3+ substantive paragraphs; Theoretical Framework (pp. 4–7) has multiple paragraphs. Good.

- Figures: Generally the figures show data and axes (bin means, RD plots, maps). However, a few figures displayed in the appendix (small thumbnails in the PDF provided for review) have labels or legends that are hard to read in the version I received. In the final submission ensure all figures are publication quality: larger fonts, labeled axes, units, and clear legends. Figure notes should state data source and sample (corrected vs. pre‑correction).

- Tables: All tables shown include numeric estimates, standard errors, CIs, N values (e.g., Table 4, Table 5, Table 9, Table 11, Table 12). They are not placeholders.

Minor formatting suggestions:
- Include a clear "Main results table" in the main text (one table with the preferred specifications side-by-side) so readers do not have to chase Table 5, Table 9, and Appendix tables to understand the core finding.
- Figure/table notes must explicitly say whether the sample uses the “corrected” running variable (distance to own-canton treated-control border) or the pre-correction union boundary. Some figures state this; others do not. Be consistent.

2. STATISTICAL METHODOLOGY (CRITICAL)

A paper that aims for a top journal must be impeccable on identification and inference. Below I evaluate the methodological components against the checklist items in the referee brief.

a) Standard Errors: PASS. Every coefficient in the main tables is reported with standard errors in parentheses (e.g., Table 4, Table 5, Table 9). The RDD uses Calonico et al. bias-corrected SEs and reports CIs (Table 5). Good.

b) Significance Testing: PASS. The paper reports p-values, significance levels, and performs permutation tests and wild cluster bootstrap. Good.

c) Confidence Intervals: PASS. Main results (Table 5, row 2) report 95% CIs [−10.5, −1.4] for the same‑language RDD. Good.

d) Sample Sizes: PASS. N or effective sample counts are reported in tables (e.g., Table 5 reports NL and NR and BW). Other tables report N (e.g., Table 4 reports N = 2,120). Good.

e) DiD with Staggered Adoption: PASS (subject to caveats). The manuscript explicitly acknowledges concerns with TWFE and uses Callaway & Sant’Anna (2021) to estimate group-time ATTs (Section 6.5 and Appendix Table 17). That is the correct modern approach. The paper also notes Basel‑Stadt’s exclusion for cohort inference, which is appropriate. Good.

f) RDD diagnostics: PASS (but see caveat). The paper reports MSE-optimal bandwidths, bandwidth sensitivity (Figure 10), donut RDDs (Figure 11 and Table 14), McCrary density test (Figure 8), and covariate balance tests (Table 6). These are the right diagnostics; however, see the identification critique below.

Important methodological caveats and concerns (these are material):

1) Inference with few treated clusters: The paper correctly flags the few‑clusters problem (5 treated cantons, ~12 border pairs). It applies wild-cluster bootstrap with Webb weights and permutation randomization inference. However:
   - The permutation test in Section 5.3 and Figure 12 randomly reassigns treatment to 5 of 26 cantons and shows the OLS-language-control observed estimate (−1.80) lies in the permutation distribution (p=0.62). The paper correctly notes this is not "truly exact" given nonrandom adoption. But the permutation exercise as implemented (randomly assigning five treated cantons) is not convincing as a placebo for the causal RDD estimate, because the identifying design is spatial RDD at borders, not canton-level random assignment. For meaningful permutation inference the randomization distribution should reflect the actual assignment mechanism of interest — for instance:
     - Permute treatment status across border-pairs (i.e., randomly select five cantons and compute the spatial RDD discontinuity using the same corrected running variable) — but crucially preserve the spatial contiguity and balance properties. The current permutation on cantons mixes up language and geography in a way that reduces power to detect the treatment effect and is not a tight placebo.
   - The wild-cluster bootstrap p-values reported (around 0.058) are borderline. The paper correctly flags p≈0.06 (Section 6.8). With such marginal p-values, the causal claims must be carefully framed and hedged.

2) Placebo RDDs: Table 15 (C.4) shows significant discontinuities for other, unrelated referenda in the same border sample (e.g., Immigration Feb 2016: +4.05 pp, p=0.001; Corporate Tax Reform Feb 2017: −3.27 pp, p<0.001). The author notes these placebo tests used the pre-correction sample and thus are not directly comparable. But the existence of discontinuities for unrelated referenda at the same canton borders is worrying: it suggests persistent political differences across borders that potentially violate the RDD continuity assumption. The paper attempts to deal with this by focusing on “same-language” German–German borders to eliminate the major Röstigraben confound. But language is assigned at the canton level (Section 4.2 and 7.2), and several cantons are internally heterogeneous (Bern has French-speaking Jura bernois; Graubünden has Romansh/Italian areas). Therefore the same-language restriction (canton-majority language) is imperfect and may still leave unobserved border heterogeneity.

3) Local covariates and confounders: The RDD balance tests (Table 6) include log population, urban share, and turnout and show no discontinuities. But other potential confounders that plausibly affect referendum preferences should be tested and shown to be smooth at the border: party vote shares (federal party support in recent elections), education levels, income, employment in construction/energy sectors, proportion of homeowners vs renters, and municipal language share at the municipality level (not canton-level majority). These are not shown in the main text. Placebo discontinuities on unrelated issues raise the bar: you need to demonstrate smoothness on a richer set of pre-determined covariates.

Conclusion re methodology: The author has implemented many best-practice methods (bias-corrected RDD inference, McCrary test, bandwidth sensitivity, DiD with CSA, wild bootstrap), which is laudable. Nevertheless, with the observed placebo discontinuities and the few clusters/border-pairs issue producing marginal p-values under conservative inference, the causal claim that "cantonal energy law exposure reduced support for federal energy legislation" is not yet convincingly established. The manuscript must do more to rule out persistent border-level political differences and to strengthen inference.

Given that rigorous statistical inference is mandatory for publication in a top journal, I must say: if the author cannot (a) convincingly rule out pre‑existing border differences as the driver of the RDD discontinuity, and (b) present robust inference that survives conservative methods (border‑pair clustering / wild bootstrap / border-pair permutation tailored to the RDD design), then the paper is not publishable in top journals in its present form.

3. IDENTIFICATION STRATEGY

Is the identification credible?

- Strategy summary (paper): The primary identification uses spatial RDD at internal canton borders comparing municipalities close to treated-control canton boundaries (Sections 5.2 and 6.2). The author restricts to same-language borders to mitigate the Röstigraben confound and uses corrected distance-to-own-canton-border construction. Supplementary identification: county‑level / canton-level OLS with language controls (Section 5.1), staggered DiD with Callaway–Sant’Anna (Section 5.4), and Difference‑in‑Discontinuities (Section 6.7) to difference out permanent border effects.

- Credibility assessment:
  - Pros:
    - Spatial RDD is a natural design here and comparing contiguous municipalities is a sound strategy for removing many geographic and socio-economic confounders.
    - The corrected running variable (distance to own canton’s treated-control border) and exclusion of cantons with no treated-control border (e.g., Basel‑Stadt) are explicit and appropriate methodological fixes (Section B.1).
    - The use of CSA for staggered DiD and DiDisc to control for permanent border effects demonstrates awareness of modern identification pitfalls.
  - Cons / threats:
    - Language confounding (Röstigraben) is the dominant concern. The same-language borders specification (Table 5 row 2) is the author’s preferred causal estimate (−5.9 pp, SE=2.32, p=0.011). But the same-language restriction uses canton-majority language, which is not fully granular; municipalities along such borders can and do differ in local language shares and cultural/political composition.
    - Placebo RDDs on other referenda (Table 15) indicate that political discontinuities at these borders exist for other issues. That suggests the RDD may be picking up persistent political differences across contiguous regions rather than the causal effect of cantonal energy laws.
    - The DiDisc estimate (~−2.5 pp, Table 9) is smaller in magnitude and statistically weaker than the same-language cross-sectional RDD (−5.9 pp). This attenuation suggests some of the RDD cross-sectional effect may be due to permanent border differences.
    - The wild cluster bootstrap p-value (~0.058) is marginal. With borderline significance, interpretation should be cautious.

- Are key assumptions discussed? Yes. The paper discusses continuity assumptions for RDD, and parallel trends for DiD. Diagnostics (McCrary, covariate balance, bandwidth sensitivity, donuts, border-pair heterogeneity) are performed. But more is needed on unobserved time‑varying confounders at borders (e.g., local campaigns, partisan mobilization) that could bias RDD estimates.

- Placebo & robustness: The paper does a number of placebo and robustness checks but, crucially, some placebos show sizeable discontinuities. The author acknowledges limitations (Section 7.2). The current robustness evidence is mixed; the same-language RDD is supportive but DiDisc attenuates the effect and placebos reveal potential border heterogeneity.

Bottom line on identification: The strategy is promising and partially convincing, but not yet airtight. To make the identification credible for a top journal the author must do more to rule out persistent border-level political heterogeneity (particularly language/party differences at the municipality level) and to strengthen inference (see Section 6 below for specific, actionable robustness/analyses to add).

4. LITERATURE (Provide missing references)

The paper cites a broad set of literatures (policy feedback, federalism, RDD/DiD methods, climate policy acceptance). I recommend adding the following specific references and briefly explain why they are relevant. I also provide BibTeX entries you can paste into your .bib file.

a) Inference and robustness with staggered DiD and pre-trends
- Reason: The paper already uses Callaway & Sant’Anna (2021), Goodman‑Bacon (2021), Sun & Abraham (2021), and cites de Chaisemartin & D’Haultfœuille and Ferman & Pinto. It should also cite methodological work on assessing and robustifying pre‑trends (Rambachan & Roth), which is especially relevant given the small number of treated units and the DiDisc analysis here.
- Add:
```bibtex
@techreport{RambachanRoth2020,
  author = {Rambachan, A. and Roth, J.},
  title = {Robust and Honest Pre-Trends Testing in Event Studies},
  institution = {National Bureau of Economic Research (NBER) Working Paper},
  year = {2020},
  number = {w28407}
}
```
(If you prefer the arXiv version: Rambachan & Roth (2020), arXiv:2008.03801.)

b) Spatial autocorrelation and spatial HAC standard errors
- Reason: The RDD and the municipality-level outcome are spatially clustered; standard cluster-robust inference may not be sufficient. Conley (1999) spatial HAC or Conley-style standard errors are relevant alternatives to address spatial correlation.
- Add:
```bibtex
@article{Conley1999,
  author = {Conley, Timothy G.},
  title = {GMM Estimation with Cross Sectional Dependence},
  journal = {Journal of Econometrics},
  year = {1999},
  volume = {92},
  pages = {1--45}
}
```

c) Randomization inference for clustered assignments / few clusters
- Reason: The paper uses permutation tests and cites Young (2019) and MacKinnon & Webb. For cluster-level randomization inference literature the paper could cite works that discuss how to permute under spatial cluster dependence.
- Add:
```bibtex
@article{Young2019,
  author = {Young, Alwyn},
  title = {Channeling Fisher: Randomization Tests and the Statistical Insignificance of Seemingly Significant Experimental Results},
  journal = {Quarterly Journal of Economics},
  year = {2019},
  volume = {134},
  pages = {557--598}
}
```
(The manuscript already cites Young; keep but include discussion on how to implement permutations that respect spatial structure.)

d) Additional references on policy feedback and diffusion in environmental policy
- Reason: The paper cites key classics. Consider adding Stokes (2016) (already cited) and more literature on whether local policy experience produces national-level support in environmental contexts (for example Stoutenborough et al. 2014 is referenced; you might add Datta & Lopez? — but existing coverage is adequate).

e) Concluding note on citations: The manuscript already cites most of the econometric staples (Calonico et al., Keele & Titiunik, Callaway & Sant’Anna, Goodman‑Bacon). The additional works above are meant to strengthen the discussion of inference and spatial dependence.

5. WRITING QUALITY (CRITICAL)

Overall the paper is readable and fairly well-structured, but improvements are required for a top-journal standard.

a) Prose vs. Bullets: PASS. The paper is written in full paragraphs. Appendix materials contain figures and bullet lists for data items (acceptable).

b) Narrative Flow: The Introduction hooks the reader with the broad policy question and places it in the policy feedback vs thermostatic debate (pp. 1–4). The flow from motivation to method to findings is present. However:
   - The exposition of the key threat to identification (language / Röstigraben) should be moved earlier and given more prominence in the Introduction. Right now much of the reader’s attention is drawn to the strong language confound only in Section 4.2. Put a short caveat in the introduction: “Language is a strong confound; we therefore rely primarily on same-language RDD and DiDisc.”
   - The Results section currently mixes many different specifications. Present a short “roadmap” in the Results opening paragraph that tells the reader which estimates are primary (same-language spatial RDD, DiDisc) and which are supportive (OLS, pooled RDD, CSA DiD). Use bolded labels sparingly to guide the reader.

c) Sentence Quality: Most sentences are clear and grammatically fine. A few long paragraphs could be tightened. Avoid passive voice when present: e.g., “This setting provides a natural experiment: did experience with local climate policy implementation shape how citizens voted on national climate action?” could be tightened to active phrasing.

d) Accessibility:
   - Technical terms are mostly explained. However, the RDD and corrected-sample running-variable construction should include a short, intuitive explanation in the main text (not only in Appendix B.1): e.g., present a small schematic map or a short step-by-step box so non-specialists can follow exactly what "distance to own canton’s treated-control border" means.
   - The magnitude of effects should be contextualized more. Moving from “−5.9 pp” to “6 percentage-point decrease is X% of the mean, or closes Y% of the gap between typical low and high cantons” is good (the author already does some contextualization; I encourage quantifying in more places and summarizing in the conclusion).

e) Figures/Tables: Some figures (maps, RDD plots) are good. But ensure the following before resubmission:
   - All figures have clear axis labels, tick marks, and readable fonts at journal page size.
   - Each figure/table note should specify exactly which sample is used (corrected vs pre-correction), which bandwidth and kernel, and the inference method behind SEs/CIs.
   - The main RDD figure should show both the raw binned means and the bias-corrected local linear fits, with the discontinuity and CI clearly annotated.

Writing issues are not fatal but polishing is required. Make the narrative tighter and the main results more front-and-center (including a single “preferred results” table).

6. CONSTRUCTIVE SUGGESTIONS

The paper shows promise. Below are concrete, constructive steps to strengthen identification and clarity. Many are essential to making the causal claim more convincing.

A. Strengthen RDD identification

1) Municipality-level language: Replace canton-level majority-language controls with municipality-level language share (from the census). Use municipality Italian/French/German share as a covariate in RDD and in balance tests. This will reduce measurement error and better rule out residual language confounding on same-language borders with internal heterogeneity (e.g., Jura bernois and Graubünden).

2) Party/political controls at the municipality level: Add pre-treatment covariates such as vote shares for national parties in the previous federal election(s) (e.g., 2015 federal election), municipal education rates, income, and shares employed in construction/energy industries. Show RDD balance tests for these covariates and include them as RD covariates in adjusted RDDs.

3) Border-pair permutation inference: Implement permutation inference that respects the spatial structure of the design. Two options:
   - Randomly reassign the treatment status among canton borders (i.e., randomly choose border-pairs to be “treated-control” and compute the RDD discontinuity), keeping the spatial adjacency structure intact.
   - Bootstrap by border-pair: re-sample border segments (cluster bootstrap) rather than cantons. Report permutation p-values based on the distribution of border-pair estimates. This will produce a randomization distribution more relevant to the actual design than reassigning arbitrary cantons.

4) Border-pair fixed effects / fully specified DiDisc: Expand the Difference-in-Discontinuities analysis:
   - Run DiDisc with municipality fixed effects, referendum fixed effects, border-pair-year fixed effects if data permits to absorb any border-specific time trends.
   - Conduct pre‑treatment RDD checks for 2000 and 2003 referendums using the corrected sample construction (distance to own canton border) to verify there was no pre-existing discontinuity in energy-related outcomes before cantonal law adoption.

5) Include Conley spatial HAC standard errors as a robustness check to account for spatial correlation across municipalities (Conley 1999). Compare results with canton-cluster and border-pair clustered SEs.

B. Address placebo RDD results

6) Re-run placebo RDDs for the same set of historical referenda (including 2000 and 2003) using the corrected sample construction (distance to own canton border). The present placebo results (Table 15) use pre-correction sample and are not comparable. If placebos still show discontinuities on other unrelated issues, that would strongly suggest permanent border heterogeneity — in which case, the author must substantially weaken causal claims and frame results as associations or conditional estimates.

7) If placebos persist, consider an alternative identification strategy: use a synthetic control or matching at the canton level for treated cantons, comparing outcomes in treated cantons to weighted combinations of neighboring or similar cantons; or use a within-canton municipality panel difference (if there are municipal-level changes in policy or enforcement intensity over time) — though I recognize municipal policy is not the treatment here.

C. Strengthen inference and presentation

8) Pre-register or at least clearly declare the primary specification before reporting a battery of robustness checks. Explicitly state in the Methods/Results sections which estimates are primary (e.g., "Preferred estimate: same-language spatial RDD, corrected sample, MSE-optimal bandwidth, bias-corrected local linear estimator; Table 5 row 2").

9) Report effect sizes in substantive terms: absolute percentage points, relative to the national mean, and what a 6 pp change implies in political terms (e.g., moving a canton from majority support to minority). Discuss potential policy significance (e.g., how many votes or seats would be affected if scaled).

10) Expand the mechanism section: The thermostatic interpretation is plausible, but the paper could probe mechanisms more directly:
    - If municipal-level data on renovations, heat pump installations, or subsidy take-up exist, conditional analyses on higher-exposure municipalities (e.g., those with high rates of building renovation) could show stronger negative feedback.
    - If survey data (e.g., Swiss voter surveys) exist on policy awareness or cost salience, link municipal exposure to individual-level attitudes (instrumental variable?).

D. Robustness of DiD / panel evidence

11) Use Rambachan & Roth pre-trend-robust inference (or placebo bounds) to show the DiD estimates are not driven by slight pretrend violations. Given small number of treated cantons, sensitivity analysis to violations of the parallel trends is important.

12) Clarify the Callaway–Sant’Anna estimation details: show group-specific control group composition and how never-treated cantons are used; report influence diagnostics (which control cantons drive which cohort estimates). Provide permutation tests for CSA at the canton level if feasible.

7. OVERALL ASSESSMENT

Key strengths:
- Important policy question with wide relevance for climate governance and federalism.
- Creative use of internal canton borders and spatial RDD combined with modern DiD and DiDisc strategies.
- Substantial set of diagnostics and robustness checks (RDD bandwidth sensitivity, McCrary test, donut RDD, DiDisc, Callaway–Sant’Anna, wild cluster bootstrap).
- Good use of corrected running-variable construction and attention to coding/verifiability.

Critical weaknesses:
- Primary causal claim relies on a same-language RDD whose identifying assumption is threatened by persistent border-level political heterogeneity (placebo discontinuities on other referenda) and imperfect language controls (canton-level language assignment).
- Inference is borderline under conservative methods (wild-cluster bootstrap p ≈ 0.058; border-pair p-values larger than canton-cluster p-values). With marginal p-values, conclusions must be hedged.
- Randomization/permutation tests are not fully tailored to the spatial RDD design (permutation over cantons is not the most relevant null distribution).
- More covariate balance tests (party vote shares, municipal language shares, education/income) and municipality-level controls are needed.
- Mechanisms are plausible but not directly tested; more evidence to distinguish thermostatic vs cost-salience vs federal-overreach would strengthen the paper.

Specific suggestions for improvement (recap):
- Replace canton-level language control with municipality-level language share in all RDD and balance tests.
- Include municipal pre‑treatment party vote shares, income, education, sectoral employment as balance checks and controls.
- Re-run placebo RDDs for other referenda using the corrected running variable; if discontinuities persist, re-assess identification and re-frame results.
- Implement border-pair permutation / bootstrap inference that preserves spatial structure; present these as primary conservative p-values.
- Add Conley spatial HAC SEs as robustness.
- Tighten narrative, foreground main specification, and quantify effect magnitude and policy significance.

8. DECISION

Given the mixed evidence — a plausible negative effect in the preferred same-language RDD specification but important threats to identification (placebo discontinuities, residual language heterogeneity), and borderline conservative inference — I recommend substantial revision. The paper is promising and potentially publishable after the author implements the additional robustness checks and clarifications recommended above and then demonstrates that the main result holds under more conservative, spatially aware inference and after more convincing control for border heterogeneity.

DECISION: MAJOR REVISION