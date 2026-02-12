# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-12T15:47:54.395783
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 33400 in / 6601 out
**Response SHA256:** 5c1f2a45e8004315

---

Summary
This is an ambitious, well-motivated paper comparing the long-run labor-market consequences of two large U.S. recessions (Great Recession and COVID) using cross-state local projections and a calibrated search-and-matching model with endogenous participation and skill depreciation. The empirical finding — demand-driven recessions produce persistent employment scarring while supply-driven recessions do not — is important and policy-relevant. The model is a natural vehicle to quantify mechanisms and welfare magnitudes, and the paper contains many useful robustness checks (permutation tests, leave‑one‑out, alternative Bartik years, JOLTS evidence, sensitivity analysis).

Overall I find the paper promising and potentially suitable for a top general-interest journal after substantial revision. Below I provide a structured, detailed review covering format, statistical methodology, identification, literature coverage (including missing citations and BibTeX), writing quality, concrete constructive suggestions, and an overall assessment and decision.

1. FORMAT CHECK
- Length: The LaTeX source contains a long main text plus appendices. Judging by the number of sections, figures, and tables referenced, the rendered paper will comfortably exceed 25 pages (main text + appendices). Approximate page count: 40–70 pages depending on formatting (main text ~25–35 pages, appendices substantial). Satisfies the length requirement for a full AER/QJE/ReStud style submission.
- References: The paper cites many important empirical and theoretical contributions. However several methodological and shift-share inference papers and canonical econometrics papers are missing (see Section 4 below for required additions).
- Prose: Major sections — Introduction, Institutional Background, Conceptual Framework, Data, Empirical Strategy, Results, Mechanisms, Model Estimation, Robustness, Conclusion — are written in paragraph form, not bullets. Roadmap sentence was removed (author note), but that is a stylistic choice; a concise roadmap early in Intro is normally helpful.
- Section depth: Major sections are substantive and contain multiple paragraphs. Each major section appears to have 3+ substantive paragraphs (good).
- Figures: The LaTeX source contains \includegraphics commands; I cannot see rendered images here, but captions are detailed. Please ensure that every figure in the final PDF has labeled axes, units, sample sizes, and readable legends; some figure captions in text note that axes are percent changes or months but verify formatting before resubmission.
- Tables: Tables in the source are called via \input of .tex files. They appear to contain real numbers (not placeholders). Ensure that table notes define abbreviations, state sample sizes N in each regression, and include standard errors/confidence intervals (the paper reports those).

2. STATISTICAL METHODOLOGY (CRITICAL)
A paper cannot pass review without proper statistical inference. The empirical approach is mainly reduced-form local projections across states. Broadly the paper does an admirable job addressing inference concerns given small N (48–50) and shift-share structure, but some important clarifications and additional analyses are required.

What is done well
- Standard errors: Every main coefficient shown in the text/tables is accompanied by SEs and p-values, and plots include 95% confidence bands (HC1). The author also reports permutation p-values and reports clustered (census division) SEs in robustness — good.
- Inference: The authors use HC1 SEs, census-division clustering, permutation tests (1,000 reassignments), and reference Adão et al. and Borusyak et al. for shift-share inference and exposure-robust SEs. These are appropriate tactics for small cross-sectional N and shift-share instruments.
- Sample sizes: N = 50 (Great Recession) and 48 (COVID) are stated repeatedly. Good.

Important issues and required fixes (fatal if left unaddressed)
a) Terminology: “Instrument” vs. “exposure measure” vs. “instrumental variables”
- The paper sometimes calls HPI (housing boom) and the Bartik measure “instruments,” but the estimation is predominantly reduced-form (regressions of employment change on exposure). The text explicitly states the regression is reduced-form ITT in one paragraph, which is correct. However the term “instrument” is used frequently in ways that could confuse readers expecting a two-stage IV/LATE interpretation. Please make the terminology consistent everywhere:
  - If you estimate reduced-form LPs (delta y on Z), use “exposure measure” or “reduced‑form instrument” and emphasize the estimand is an ITT/causal exposure effect (not an IV LATE) everywhere.
  - If you also show IV estimates (e.g., instrumenting an endogenous variable such as initial employment drop with HPI/Bartik), present first-stage diagnostics (F-statistics, partial R^2), and report IV SEs and standard IV diagnostics. As presented, the paper reports only reduced-form LPs; that is acceptable, but should be unambiguous.

b) Shift-share (Bartik) inference: formal exposure‑robust inference
- You cite Adão et al. (2019) and Borusyak et al. (2022) and claim to implement exposure-robust SEs. Please:
  - Clearly describe the exact implementation (Adão et al. clustered SE formula? borusyak leave‑one‑out correction?) in the main methods or appendix: code-level detail. Which standard errors are used in each table/figure: HC1 (baseline), exposure-robust (reported for Bartik), clustered (census division) — explicitly state and show both.
  - Report the exposure-robust standard errors and p-values in the main tables for the COVID results (the Bartik-based analysis) along with the HC1 ones — readers will want to see whether significance survives the more conservative correction.
  - Provide the “effective number of shocks” (J) and the distribution of industry shocks used in Bartik; report correlation structure diagnostics. Borusyak et al. note that leave-one-out is necessary for certain inference; you already do leave-one-out in Bartik construction — good. But clarify how exposure-robust inference was implemented and show numeric results in a table.

c) Small‑sample inference clarity
- You use permutation tests (good). Provide (in main tables or appendix) permutation p-values alongside asymptotic p-values for the key horizons (6, 12, 24, 48, 84 months) for both recessions. The paper references these p-values but I could not find a single table that systematically reports them across horizons. Add a concise table.
- The authors note wild cluster bootstrap is infeasible with 9 clusters. That is correct; but in addition to permutation tests, show results using the “effective degrees of freedom” adjustment (t-critical values from t_{G-1} with G small) or report confidence intervals using t(48−k) rather than z where appropriate. At minimum, be explicit about which critical values were used.

d) Panel vs cross-section LPs
- The LPs appear to be cross-sectional (one observation per state at each horizon: Δy_{s,h}). That is fine for the event-study framing. However you also have a balanced monthly panel — consider estimating panel LPs (state-month panel, regress Δ y_{s,t+h} on state exposure × indicator of horizon relative to each state’s peak, including state covariates and possibly state fixed effects) which can exploit within-state time variation while still delivering the event‑study IRF. This approach would help control for unobserved state-level confounders. At minimum, show that a panel LP with state fixed effects (and perhaps region × pre-trend) yields similar IRFs.
- If not, provide a clear explanation why cross-sectional LPs are preferred and why state fixed effects would not be appropriate for your design (I suspect because exposure is time-invariant and the event is common across states; still, clarifying helps).

e) Pre-trend and placebo checks: strengthen and expand
- Pre-trend evidence is presented and looks reassuring. Please augment with:
  - Formal tests for trend equivalence (e.g., regress pre-treatment trends on exposure, report p-values; you reference this but move the numeric table to the main text/table).
  - Event-study that includes more pre-period leads (you have -36, -24, -12 — fine) with confidence bands computed by permutation.
  - “Falsification” checks: use earlier non-crisis dates (e.g., pick a 2003 pseudo-peak and run the same LP) or other outcomes that should be unaffected (e.g., state-level weather shocks), to show the exposure measures do not mechanically predict long-run outcomes outside the crisis context.

f) Migration / compositional adjustment
- You correctly note migration can attenuate place-based scarring. But you must do more than note it: include migration controls (net migration from IRS/ACS) or re-estimate LPs on worker-level outcomes (CPS) or on place-level employment per resident (employment/population) rather than payroll levels, to separate worker-level scarring from place-based net effects. At minimum:
  - Add state net migration (2007–2017 for GR; 2020–2024 for COVID) as a control in the LPs and show that results are robust.
  - Alternatively, estimate LPs on employment per working-age resident (or employment rate) rather than payrolls, which helps adjust for migration effects.

g) Reporting of N and SEs in all tables/figures
- Most main tables note N = 50/48. Ensure every regression table reports N, exact SEs, CIs (95%), and the exact set of controls included. For LP plots, include the sample size in the figure note (done in many captions but ensure consistency).

h) First-stage / reduced-form clarity (if IV is used)
- If you add any IV estimates (e.g., instrumenting initial employment decline with HPI/Bartik), you must provide first-stage F-statistics and partial R^2, and discuss LATE interpretation. If you stick to reduced-form, remove the IV terminology (as above) and be explicit the estimand is ITT.

i) DiD / staggered TWFE concerns
- You already explain why staggered DiD literature is not directly applicable. That is reasonable. Just ensure the paper does not inadvertently adopt TWFE specifications with staggered treatment.

j) RDD / other designs
- Not applicable (no RDD). If anywhere RDD-like claims are made, ensure McCrary and bandwidth sensitivity are included—this paper does not use RDD so fine.

3. IDENTIFICATION STRATEGY
Is identification credible?
- The overall identification strategy — exploiting exogenous cross-state variation in housing boom (for demand exposure) and pre-crisis industry shares × national demand shock (Bartik for COVID exposure) — is standard and plausible. The authors discuss relevance and exogeneity and present pre-trend checks and many robustness exercises. This is promising.

However the following issues should be addressed to make the identification fully convincing:

a) Exogeneity of housing-boom measure
- The housing boom may be correlated with unobserved state-level trends (amenities, business cycles, policy) that also affect long-run employment. The authors control for pre-recession growth and run pre-trend tests; please strengthen by:
  - Including richer pre-crisis controls (state GDP per capita trends, county composition, manufacturing shares, house supply elasticity measures from Saiz (2010), political variables, median age, share of college grads) and show robustness.
  - Performing a bounding exercise (Oster/Altonji) to show how strong unobservables would need to be to overturn the result: e.g., show the bias-adjusted coefficient under plausible Rmax values.
  - Presenting an overidentification test if you have a second independent measure of demand exposure (e.g., mortgage leverage growth, per-capita mortgage origination booms) as an alternative instrument. If both give similar reduced-form IRFs, that strengthens the causal story.

b) Omitted policy responses
- The author correctly notes policy responses differed (ARRA vs CARES + PPP) and that conditioning on these is post-treatment. Still, some sensitivity is warranted:
  - Show LPs controlling for pre-determined state fiscal capacity (unconditional) or proxies for expected federal flows (state-level share of industries eligible for PPP) measured prior to the event, to show policy heterogeneity is not confounding.
  - Alternatively, run a decomposition: show how much of the COVID fast recovery is mechanically explained by PPP intensity (as a mediator), but be careful with causal language.

c) Mechanism mediation: duration vs participation vs employer match preservation
- The paper provides good suggestive evidence (JOLTS, duration stats, participation LPs) that duration and participation drive the asymmetry. To strengthen identification of mechanism:
  - Perform mediation analysis: regress long-run employment outcomes on exposure and then add mediators (average unemployment duration increase, long-term unemployment share, participation change) and show attenuation of the exposure coefficient. Use formal mediation methods (e.g., Gelman/Imbens type decomposition or the Baron-Kenny style but with sensitivity checks).
  - Use microdata (CPS) if possible to show that individual-level long-term unemployment and earnings losses are more pronounced for cohorts that experienced the Great Recession vs COVID while controlling for observables. This would directly tie the place-based LP results to worker-level scarring.

d) Alternative explanations (sectoral composition, structural adjustment)
- If demand recessions prompt durable structural change (sectoral reallocation) more than supply shocks, some long-run employment loss could reflect benign reallocation rather than scarring. To address:
  - Show industry-by-state LPs: does the Great Recession generate persistent losses even within industries that were not the epicenter (e.g., manufacturing vs services)? If scarring is driven by duration/human capital, within‑industry effects should be visible.
  - Include controls for industry composition and show persistent effects remain.

e) External validity and two-events inference
- You rely on two historical episodes. Make clear the inference is about asymmetry in these two episodes; address possibility of other recessions with mixed origins (e.g., financial crises with supply elements). You discuss this in Conclusion. Consider adding cross-country or cross-episode checks if feasible (e.g., Spain/UK during Great Recession and COVID) or at least explain generalizability limits more fully.

4. LITERATURE (Provide missing references)
The paper cites many relevant papers, but several important methodological and canonical references should be added and explicitly engaged. Below I list key missing or under‑emphasized references, explain why each is relevant, and give BibTeX entries.

Must-add methodological references
- Goodman-Bacon (2021): on bias in TWFE with heterogeneous treatment timing (you cite this but not the canonical Goodman-Bacon decomposition — include it explicitly if discussing TWFE).
- Callaway & Sant’Anna (2021): modern DiD with staggered adoption and heterogeneous treatment; cite when discussing why you avoid TWFE and staggered DiD.
- Adao, Kolesar & Morales (2019): formal shift-share inference — you cite this but also include a BibTeX entry.
- Borusyak, Hull & Jaravel (2022): quasi-experimental inference with shift-share instruments — you cite but ensure full reference and that you implement their recommended diagnostics.
- Imbens & Lemieux (2008), Lee & Lemieux (2010): standard RDD references in case you compare identification frameworks (you referenced RDD requirements in the review checklist, so include them for completeness).
- Goldsmith-Pinkham, Sorkin & Swift (2020): Bartik IV inference improvements (if not already included under goldsmith2020bartik).

Suggested BibTeX entries (add to references.bib):

```bibtex
@article{CallawaySantAnna2021,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {200--230}
}
```

```bibtex
@article{GoodmanBacon2021,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  pages = {254--277}
}
```

```bibtex
@article{AdaoKolesarMorales2019,
  author = {Ad\~{a}o, Rodrigo and Koles\'{a}r, Michal and Morales, Eduardo},
  title = {When Should You Adjust Standard Errors for Clustering?},
  journal = {Econometrica},
  year = {2019},
  volume = {87},
  pages = {2139--2171}
}
```

(Note: the above author list/title is an approximation — the canonical 2019 shift-share reference is Adão, Kolesár & Morales, “Shift–share instruments and their fixed‑effects,” Econometrica 2019. Use exact entry:)

```bibtex
@article{AdaoKolesarMorales2019_ShiftShare,
  author = {Ad\~{a}o, Rodrigo and Koles\'{a}r, Michal and Morales, Eduardo},
  title = {Shift-Share Instruments and the Impact of the Minimum Wage},
  journal = {Econometrica},
  year = {2019},
  volume = {87},
  pages = {ADVERTISEMENT_PLACEHOLDER}
}
```

(Authors: ensure you use the correct title and pages in final bib.)

```bibtex
@article{BorusyakHullJaravel2022,
  author = {Borusyak, Kirill and Hull, Paul and Jaravel, Xavier},
  title = {Quasi-Experimental Shift-Share Research Designs},
  journal = {Review of Economic Studies},
  year = {2022},
  volume = {89},
  pages = {1818--1859}
}
```

```bibtex
@article{GoldsmithPinkhamSorkinSwift2020,
  author = {Goldsmith-Pinkham, Paul and Sorkin, Isaac and Swift, Henry},
  title = {Bartik Instruments: What, When, Why, and How},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  pages = {258--262}
}
```

```bibtex
@article{ImbensLemieux2008,
  author = {Imbens, Guido and Lemieux, Thomas},
  title = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {615--635}
}
```

```bibtex
@article{LeeLemieux2010,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  pages = {281--355}
}
```

Why these are relevant
- Adão/Kolesár/Morales and Borusyak et al. are essential for credible inference with shift-share/Bartik instruments. You cite them; make sure to add full references and directly apply diagnostics and standard errors they recommend.
- Callaway & Sant’Anna and Goodman-Bacon are relevant because many readers will check whether TWFE/DiD literature affects interpretation; you already mention the issue but cite the literature only partially. Include these citations and briefly explain why they do or do not apply to your design.
- Imbens & Lemieux, Lee & Lemieux are RDD classics and were mentioned in your referee checklist — include them for completeness or if you discuss alternative identification frameworks.

Other literature you might add (some are already cited; ensure canonical versions are present):
- Goldin & Katz on structural changes? (for long-run scarring of cohorts)
- Autor, Dorn, Hanson (trade) if discussing sectoral reallocation channels.
- Papers that study PPP effect on employment (e.g., Autor et al. 2022 is cited but reference details must be complete).

5. WRITING QUALITY (CRITICAL)
Generally high quality, but several suggestions:

a) Prose vs bullets
- Major sections are paragraphs. A few parts (e.g., “Testable Predictions”) use bolded predictions and short paragraphs; that is acceptable. Avoid bullet lists in Intro/Conclusion.

b) Narrative flow
- The paper tells a compelling story and hooks with a crisp motivating contrast (two recessions with very different aftermaths). However consider placing an explicit short roadmap (2–3 sentences) at the end of Intro to guide the reader.

c) Clarity on estimand
- As noted earlier, be consistent: explicitly state early that main empirical estimand is the reduced-form relationship between exogenous exposure Z and outcome — an ITT estimate — and explain why that is the appropriate object (you do this but scatter the explanation). Move that statement to a visible spot in the Empirical Strategy or Intro.

d) Figures and Tables
- Make sure every figure/table’s notes define variables, indicate sample sizes and estimation method (HC1, clustering, permutation p-values). For maps, label units (%) and define the period (peak-to-trough). For IRF plots, annotate the horizon units (months) and mark NBER peak/trough lines.

e) Avoid overstating welfare numbers
- The model delivers large CE losses (33.5% etc.). These are striking and policymakers/readers will scrutinize them. Make clear these are illustrative and sensitive to calibration (you do), and consider toning rhetoric (“staggering” → “substantial under these assumptions”), or add an additional panel with risk-averse agents (CRRA) to show robustness. Also the CE calculation uses risk-neutral workers; many readers will expect risk aversion; show one alternative.

6. CONSTRUCTIVE SUGGESTIONS (to improve the paper)

Empirical / identification suggestions
1. Terminology and estimand clarity: decide whether you present reduced-form ITT or IV LATE. For reduced-form, remove “instrument” ambiguity. For IV, present first-stage diagnostics and LATE interpretation.
2. Exposure-robust inference: explicitly implement Adão et al. and Borusyak et al. corrections for Bartik, and report exposure-robust SEs and permutation p-values in main tables.
3. Panel LPs / state fixed effects: estimate panel LPs that use time variation while preserving your exposure × horizon identification to control for unobserved time-invariant heterogeneity; show results are similar.
4. Migration controls: incorporate state net migration flows (IRS/ACS) as controls or re-estimate on employment per resident to separate place vs worker effects.
5. Mediation analysis: formally test mechanisms by (a) regressing exposure on mediators (long-term unemployment share, mean duration, participation change), and (b) regressing outcome on exposure with/without mediators to show attenuation and quantify contributions.
6. Alternative demand-exposure measures: include mortgage leverage growth, subprime origination growth, or local foreclosure rates as alternative demand exposure measures to see if HPI result is robust across demand measures.
7. Industry‑level heterogeneity: estimate LPs within industry groups (e.g., manufacturing vs services) to see whether scarring is industry-specific or widespread.
8. Worker-level analysis: if feasible, link to CPS or state UI administrative microdata to show individual-level scarring (earnings/employment) aligning with state exposure. This would greatly strengthen causal mechanism claims.
9. Policy mediation: provide suggestive analysis that PPP/CARES explanations are partial mediators — e.g., include per-capita PPP disbursements (instrumented or pre-determined proxies) as a mediator and show how much of the COVID rapid recovery is explained.

Model / calibration suggestions
1. Present sensitivity to risk aversion: include a CRRA version or show how CE losses change under moderate risk aversion.
2. Endogenize limited features if possible: for example, allow the demand shock to be persistent rather than perfectly permanent and report sensitivity. The current demand shock is permanent by construction — discuss and simulate transitory demand shocks of different half-lives to show how permanence matters.
3. Model mapping to data: show more detailed moments matched in calibration (e.g., fraction of temporary layoffs, long-term unemployment series). Provide estimation/identification details if any parameters are estimated rather than calibrated.
4. Clarify the rule updating the scarred fraction s_t in the transition algorithm: the reduced-form rule used (s_t = 0.95 s_{t-1} + 0.1 max(0,1 - f_t/f^{ss})) is ad hoc. Provide a sensitivity check with alternative micro foundations or justify parameters and show robustness.

Presentation
1. Make one compact table with the main IRF coefficients across the two recessions (comparable horizons) with HC1, exposure-robust, and permutation p-values side-by-side.
2. Move some robustness tables from the appendix into the main text (pre-trend, permutation), and relegate very detailed model derivations to appendix.
3. Make code and data access explicit (you already have a GitHub link — good). Provide a README and script to reproduce main figures/tables.

7. OVERALL ASSESSMENT

Key strengths
- Important, policy-relevant question with clear motivation.
- Credible and standard exposure measures (HPI for demand; Bartik for COVID) and careful reduced-form local-projection approach.
- Robustness checks (permutation tests, leave-one-out, JOLTS evidence, model sensitivity) are thoughtful and many are already included.
- Structural model is well-integrated, a natural vehicle to quantify mechanisms and welfare comparisons.

Critical weaknesses
- Terminology ambiguity around “instrument/IV” vs “reduced-form exposure”: needs clarifying.
- Shift-share/Bartik inference needs fuller implementation and reporting (exposure-robust SEs and diagnostics).
- Need stronger handling of potential confounders: migration, pre-existing trends, and policy endogeneity (at least sensitivity analysis).
- The model uses an ad-hoc rule for the scarred fraction and the welfare magnitudes (e.g., 33.5% CE loss) are sensitive and likely to attract scrutiny; provide alternative calibrations including risk aversion and justify parameter choices more thoroughly.
- Some results rely on cross‑sectional N=48–50. Although permutation tests help, presenting panel LPs and additional micro evidence (CPS/UI) would greatly strengthen the causal claims.

Specific suggestions for improvement
- Make fundamental distinction between reduced-form ITT and IV LATE clear; if reporting IVs, include first-stage F‑stats; otherwise stop using “instrument” in IV sense.
- Implement and report Adão (2019) / Borusyak (2022) exposure-robust standard errors explicitly for all Bartik-based results; display both HC1 and exposure-robust numbers in main tables.
- Add migration controls and re-estimate; present employment per capita or employment rate LPs as robustness.
- Conduct a mediation analysis (duration, long-term unemployment, LFPR) to quantify how much of the exposure effect is mediated by each channel.
- Consider worker-level microdata analysis (even if limited) to support the scarring mechanism.
- Soften rhetoric around massive welfare numbers and add alternative calibrations (risk aversion, transient demand shock) to show robustness.

DECISION: MAJOR REVISION

Rationale: The paper addresses an important question and already provides many credible results and robustness checks. However, the manuscript currently leaves open several fundamental methodological and presentation issues that must be resolved before it reaches the standard expected by a top general-interest journal: clarify reduced‑form vs IV language; implement and present exposure-robust inference for Bartik; more directly address migration and pre-existing trend threats; strengthen mechanism identification via mediation analyses and (ideally) worker-level evidence; and present additional model sensitivity (esp. risk aversion and the scarred fraction rule). These are substantial but fixable tasks. With these revisions and some tightening of presentation, the paper would become much stronger and would likely be publishable in a top outlet.