# GPT-5-mini Review

**Role:** External referee review
**Model:** openai/gpt-5-mini
**Paper:** paper.pdf
**Timestamp:** 2026-02-07T08:23:08.540846
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 23245 in / 6225 out
**Response SHA256:** ae898ead5f4855fe

---

Summary

This is an interesting, well-motivated paper that asks whether community-level broadband diffusion changed the moral language used in local government meetings. The authors combine the LocalView corpus (transcripts), the Moral Foundations Dictionary, and ACS broadband measures and implement a staggered DiD using the Callaway & Sant’Anna (2021) estimator. The paper reports a clear and carefully defended null: no detectable effect of crossing a 70% broadband subscription threshold on individualizing/binding moral language or the derived universalism index. The authors are transparent about power limits (98% of places are eventually treated, only 9 never-treated), conduct pre-trend tests, perform HonestDiD sensitivity checks, and present multiple robustness checks. The null is interpreted through a “cheap talk” lens: local government speech may be institutionally constrained and therefore insensitive to information shocks.

Overall assessment: the paper addresses an important and novel question, uses an up-to-date DiD estimator, and is mostly careful and transparent. Nevertheless, there are several substantive methodological, identification, measurement, and presentation issues that must be addressed before this is suitable for a top general interest journal. Most importantly: (i) the near-universal treatment rate produces severe power and control-group problems, which limit the credibility and informativeness of the null; (ii) the measurement of moral language relies on dictionary counts that are insensitive to context, negation, and framing; and (iii) several alternative strategies and robustness analyses would substantially strengthen the causal interpretation (e.g., instrumenting with exogenous infrastructure grants or exploiting earlier infrastructure data, using richer text classifiers, and rethinking aggregation/weighting). I recommend MAJOR REVISION. Below I give a detailed, constructive list of format and content comments, diagnostic flags, and concrete steps to improve the paper.

1. FORMAT CHECK

- Length: The LaTeX source is substantial (main text + appendix with many figures/tables). I estimate the manuscript will render to roughly 30–50+ PDF pages including figures and appendix. That is fine for a top journal revision; no trim is necessary, though moving some long robustness tables to the appendix is appropriate (which the authors largely do).

- References: The paper cites most of the key recent DiD literature (Callaway & Sant’Anna 2021, Goodman-Bacon 2021, Sun & Abraham 2021, Rambachan & Roth 2023, Sant’Anna & Zhao 2020). It also cites Morals/Text literature (Graham/Haidt, Enke 2020) and political economy work. However, I recommend adding a few classic and methodological references discussed below (e.g., Bertrand, Duflo & Mullainathan on clustering; Lee & Lemieux and Imbens & Lemieux for RDD if any mention of RDD is needed; Abadie et al. on synthetic controls; Abadie, Athey papers on staggered adoption design and related issues). See Section 4 below for precise missing references and BibTeX.

- Prose: Major sections (Introduction, Theory, Data, Empirical Strategy, Results, Discussion, Conclusion) are written in paragraph form. Good.

- Section depth: Major sections are substantive with multiple paragraphs each. Good.

- Figures: All figure references appear to point to .pdf files and captions are descriptive. I cannot see the rendered graphics here, but captions indicate axes and sample sizes. Please ensure the final PDF has legible axes, readable font sizes, and well-labeled legends (including units for moral scores: words per 1,000). Figures should include N in figure notes where appropriate.

- Tables: All tables contain numerical estimates, standard errors, p-values; no placeholders. Good. A small comment: report exact N (place-years and places) in table notes for each regression, and report cluster count explicitly (you mention 47 states—please put that in all relevant table notes).

2. STATISTICAL METHODOLOGY (CRITICAL)

This is the most important section. Below I evaluate whether the paper satisfies the checklist (a–f) and highlight concerns.

a) Standard errors: PASS. Most coefficient estimates are reported with standard errors in parentheses (Tables 4–6, etc.). The authors also report p-values and mention wild cluster bootstrap p-values as a robustness check (please display those where relevant).

Recommendation: For top-journal standards, for every main estimate present (aggregate ATT, cohort ATTs, event-study coefficients, TWFE), report:
- SEs in parentheses
- number of clusters used for clustering
- (for state clusters) wild cluster bootstrap p-values if cluster count is small (47 is acceptable but borderline; reporting wild cluster p-values is good practice).

b) Significance testing: PASS. Authors present p-values, event-study joint pre-trend tests (Wald), and cohort-level inference.

c) Confidence intervals: PARTIAL. The authors report 95% CIs in some figures and give a CI in the text for the universalism ATT ([-0.831, 0.349]). Make sure all main estimates include 95% CIs in the tables or figure panels (for main ATT and log ratio ATT). For the equivalence tests and MDE calculations, present exact CI endpoints in tables.

d) Sample sizes: PASS. Place and place-year N appear in tables (~530 places, 2,751 place-years). But some regressions (cohort-specific) drop many observations; please explicitly report N and number of clusters for each regression in the corresponding table note (you already do this partly; standardize it).

e) DiD with staggered adoption: GOOD—authors use Callaway & Sant’Anna (2021) and Sant’Anna & Zhao doubly robust estimation, and they compare to Sun & Abraham and TWFE. That is appropriate. However, there are two important caveats:

- Near-universal treatment: Only 9 never-treated places (1.7% of sample). Callaway & Sant’Anna’s estimator permits use of not-yet-treated as controls, but when treatment is nearly universal the not-yet-treated set can be very small or empty for many cohorts and relative times. The authors recognize and document this (Tables 2, robustness). This is a fundamental identification/precision limit and must be handled carefully. I discuss remedies below.

- Aggregation weighting: make explicit which aggregation across group-time cells you implement (you describe unweighted average and an event-study weighting by N_g). Discuss how sensitive results are to alternative weightings (e.g., weighting by group-time sample size or by inverse variance), and report Sun & Abraham / IW aggregator standard errors if feasible.

f) RDD: Not applicable.

Other methodological concerns and suggestions:

- Power & control-group scarcity (fatal risk to informativeness): The authors correctly emphasize the lack of control units as the principal reason for wide C-S SEs. This is a substantive limitation; the authors do a good job quantifying MDEs, equivalence tests, and HonestDiD sensitivity. Still, the paper should (a) try additional identification strategies to obtain exogenous variation and/or more credible control groups, and (b) avoid overstating the informativeness of the null. I give constructive options below.

- Continuous treatment vs. binary threshold: The threshold (70%) is substantively motivated, but you also estimate a continuous TWFE specification where the binding score effect is marginally significant. The TWFE continuous specification is susceptible to bias (heterogeneous effects etc.). Consider estimating dose-response using modern estimators that allow continuous treatments and staggered timing (e.g., Callaway & Sant’Anna extensions or dose-response DiD methods). See Athey, Imbens (2018) / new literature on continuous treatments.

- Doubly robust models specifications: Provide details (in appendix) of the propensity score model and outcome regression functional forms used in the Sant’Anna & Zhao estimator (what covariates, any lags, interactions?). Also report balance checks on covariates after IPW reweighting.

- Multiple testing: You test many outcomes (5 foundations + composites + cohorts + heterogeneity). Report a multiple-testing correction (e.g., Romano-Wolf stepdown or Benjamini-Hochberg FDR) for the main family of hypotheses, or explicitly justify why not. At present a single cohort effect (2020 on binding) appears significant at 5% but likely a false positive.

3. IDENTIFICATION STRATEGY

Credibility and assumptions:

- Parallel trends: The authors do event-study pre-trend checks and report joint pre-trend tests (p ≈ 0.998), and use HonestDiD sensitivity. That is good. But pre-trend tests are informative only for cohorts with pre-periods; 2017 cohort (largest) has no pre-periods and contributes considerably to aggregate ATT. The authors mention this; make it explicit in each estimation: which cohorts inform pre-trends and which do not. Consider re-running the aggregate ATT excluding cohorts with no pre-periods (or presenting a sensitivity table). This helps readers judge how much the null is driven by the heavily pre-treated units.

- Measurement lag (ACS 5-year): The authors allow a one-year anticipation period to account for ACS smoothing. Explain in more formal detail why e = -1 suffices (the 5-year estimate covers t-4..t; if the actual crossing occurs in t-2 or t-3, could detection be delayed more than one year?). Consider sensitivity checks allowing 0,1,2 years anticipation.

- Confounding trends: Broadband penetration correlates with economic development and other time-varying factors. The doubly robust approach helps, but remaining confounding is plausible. The authors discuss future IV opportunities (e.g., FCC grants). I strongly recommend attempting one or more of the following (feasible fixes, ranked):

  1) Instrumental variable using exogenous infrastructure grants: The paper mentions FCC grants (ARRA, BEAD). The authors should attempt an IV strategy exploiting quasi-random grant allocation rules or eligibility thresholds. This is nontrivial, but even a partial IV showing similar point estimates (with larger SEs) would strengthen causal claims. If IV is infeasible or weak, be transparent.

  2) Exploit pre-2017 variation: If LocalView includes transcripts earlier than 2017 (they say 2006–2023 are available), consider expanding treatment assignment using earlier broadband measures (FCC Form 477 or ACS earlier) and focusing on an earlier period when more places were untreated—this would yield more balanced cohorts and greater power. The authors may have limited transcripts for earlier years in some places, but exploring it is important.

  3) Use infrastructure or provider entry data: Instead of household subscription rate, use ISP coverage, last-mile infrastructure deployment, or dates of provider expansion (e.g., publicly available ISP buildout datasets) as treatment. These events are more plausibly exogenous to local moral speech and sometimes have sharper timing.

  4) Synthetic control(s): For places with clear pre-trends and enough pre-periods, a synthetic control approach (Abadie, Diamond & Hainmueller 2010) could help for case studies (not as a panacea for the entire sample). This would provide examples of treated places and their counterfactuals.

  5) Difference-in-differences with matching: Pre-match treated places to similar not-yet-treated places on pre-treatment moral language trends and covariates to ensure better comparability, then run C-S on matched sample.

- Outcome weighting/aggregation: You aggregate transcripts to place-year by word-count weighting. That is reasonable but has implications: larger meetings or places contribute more; if broadband adoption correlates with meeting length, this can bias results. Consider reporting unweighted (place-year equal-weight) results as a sensitivity check, or two alternative weighting schemes (e.g., median across meetings within place-year, count of meetings using moral words/total meetings, or speaker-level analyses).

- Heterogeneity inference: Authors try to split by partisanship and rurality but find estimation infeasible—document more clearly in table notes which subgroup estimates are feasible and why. Do not overinterpret subgroup nulls where estimation is impossible.

4. LITERATURE (Provide missing references)

The paper cites much relevant literature, but I recommend adding the following, with short notes on why each is relevant. Below I include BibTeX entries as requested.

- Bertrand, Duflo & Mullainathan (2004) — classic on serial correlation and clustered SEs.
- Lee & Lemieux (2010) — canonical RDD review (the paper mentions RDD in the instructions and RDD bandwidth tests; not directly applicable to this paper, but include if you discuss RDD alternatives).
- Imbens & Lemieux (2008) — econometrics for RDD (optional).
- Abadie, Diamond & Hainmueller (2010) — synthetic control method for comparative case studies.
- Athey & Imbens (2018) — design-based/causal inference perspectives for staggered adoption/event studies.
- Roth (2022) or related work on pre-testing / event-study pitfalls—though Rambachan & Roth 2023 is cited, consider including other methodological tutorials if space allows.

BibTeX entries (suggested):

```bibtex
@article{Bertrand2004,
  author = {Bertrand, Marianne and Duflo, Esther and Mullainathan, Sendhil},
  title = {How Much Should We Trust Differences-In-Differences Estimates?},
  journal = {Quarterly Journal of Economics},
  year = {2004},
  volume = {119},
  pages = {249--275}
}

@article{LeeLemieux2010,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  pages = {281--355}
}

@article{ImbensLemieux2008,
  author = {Imbens, Guido W. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {615--635}
}

@article{Abadie2010,
  author = {Abadie, Alberto and Diamond, Alexis and Hainmueller, Jens},
  title = {Synthetic Control Methods for Comparative Case Studies: Estimating the Effect of California's Tobacco Control Program},
  journal = {Journal of the American Statistical Association},
  year = {2010},
  volume = {105},
  pages = {493--505}
}

@article{AtheyImbens2018,
  author = {Athey, Susan and Imbens, Guido},
  title = {Design-based Analysis in Difference-in-Differences Settings with Staggered Adoption},
  journal = {Harvard Data Science Review},
  year = {2018},
  volume = {1},
  pages = {1--25}
}
```

Why relevant: Bertrand et al. is the canonical reference for clustered standard errors in DiD settings and should be cited where clustering choices are discussed (Section 4.5). Lee & Lemieux/Imbens & Lemieux are the standard RDD guides (useful if authors mention RDD or alternative designs). Abadie et al. is the classic synthetic control reference and provides an alternative identification approach. Athey & Imbens (2018) discusses staggered adoption designs and some design considerations.

5. WRITING QUALITY (CRITICAL)

Overall prose is clear, well-structured, and reads like a journal article. A few stylistic and clarity suggestions:

a) Prose vs bullets: The main sections are in paragraph form. Only minor lists are in enumerate/enumerate environments for theory/mechanisms, which is fine.

b) Narrative Flow: The introduction is strong—good hooks and motivation (Enke 2020, moral foundations, LocalView corpus). The transition from descriptive measurement to causal design is logical. One suggestion: reiterate earlier that the 98% treatment rate is the central practical constraint and preview how you will deal with it. This prepares readers for the null being a power-constrained null.

c) Sentence Quality: Generally crisp. A few long paragraphs (e.g., long expository blocks in the introduction/theory) could be split for readability. Place the paper’s main numeric result (ATT = -0.241, SE = 0.301) in a highlighted sentence in the introduction’s last paragraph so readers can see it early.

d) Accessibility: The text does a good job explaining technical terms and giving intuition. For technical readers, include short footnotes or an appendix describing the C-S estimator and aggregation choices more formally (you do some of this).

e) Tables: Mostly self-explanatory. A few improvements:
- For each table of regression results, include (i) the exact regression specification in a note, (ii) the number of places, place-years, and clusters, and (iii) whether estimates come from C-S (doubly robust) or TWFE.
- For event-study figures, ensure reference period is clearly labeled (e.g., e = -2 as baseline) and that confidence intervals are described (clustered SEs).

6. CONSTRUCTIVE SUGGESTIONS — TO STRENGTHEN THE PAPER

The paper is promising. Below are concrete analyses/changes that would substantially improve credibility and contribution.

A. Address the power/control-group limitation aggressively

- Try expanding the time window backwards (use LocalView transcripts from earlier years, and treat earlier broadband diffusion years). If LocalView has sufficient pre-2017 transcripts for many places, re-define cohorts using earlier years so a larger share of the sample is untreated for longer. That would increase the number of not-yet-treated controls and might reduce MDEs.

- Attempt an IV strategy using exogenous variation in broadband infrastructure rollout tied to federal/state grants or provider-entry rules. The authors mention FCC grants—try to operationalize it. Even if the IV is weak, reporting first-stage strength, locality coverage, and sensitivity to IV estimates is informative.

- Use ISP-level entry or Form 477 coverage dates to create sharper treatment timing for places where infrastructure deployment was sudden and plausibly exogenous.

- If none of the above is feasible, be explicit and rigorous in stating that the paper documents a “design-limited null”: given the paucity of untreated controls, the paper cannot reject moderate effects. Reframe conclusions to highlight this limitation and focus contribution on measurement, descriptive facts (distribution of moral language across places), and laying groundwork (replication code, appendices) for future work.

B. Improve text measurement

- Move beyond raw dictionary counts for the core robustness: apply at least one context-sensitive classification method. Options (in decreasing order of required effort):

  1) Fine-tune a transformer (e.g., RoBERTa or BERT) on a labeled subset of text for moral foundation categories. You can label a modest random sample (e.g., 2–5k sentences) for the five foundations or for universalism vs. communalism; human labeling will be needed but even small labeled sets can deliver much more accurate classification than word-count dictionaries.

  2) Use existing moral classification models (if available) or topic modeling combined with manual inspection to ensure dictionary words are used in the intended sense.

  3) Use contextual heuristics: exclude matches within negations (“not fair”), apply simple rules for sarcasm/negation, or implement phrase-based matching to reduce false positives.

  4) As a faster approach, use LLMs (GPT-style) to annotate a sample of transcripts for moral orientation and compare those annotations with dictionary-based measures to quantify measurement error. Use the discrepancy to perform attenuation-bias correction (bell-shaped correction) or to include measurement error bounds.

- Report dictionary precision/recall statistics on a labeled subset to quantify measurement validity. Without that, null results may be driven by measurement noise.

C. Expand outcome set (triangulation)

- The cheap-talk hypothesis suggests governance speech may be unresponsive but other communication forms could move. Try to analyze additional outcomes where politicians express themselves more freely:
  - Politicians’ social media posts (Twitter/X, Facebook): measure moral language change in those platforms for the same places/politicians.
  - Campaign speeches or local op-eds (if available).
  - Voting records or official policy choices (e.g., votes on policies that are morally charged locally).
  These complementary outcomes would test whether broadband affects private/public expressive spaces differently.

D. Revisit aggregation and weighting

- Present robustness to alternative aggregation: (i) equal-weight place-year averages, (ii) speaker-level analyses (if speaker metadata exists), (iii) median meeting-level outcomes per place-year.

- Consider weighting by inverse-variance in aggregations of group-time ATTs (or show that results are insensitive).

E. Clarify anticipation and ACS smoothing

- Explore sensitivity to allowing two-year anticipation windows. Show how event-study coefficients change.

- Consider constructing treatment using ACS 1-year estimates where available (you do that in a robustness check for >20k population). Report those results more prominently: do places with 1-year series (larger places) show similar patterns? If so, that is useful evidence.

F. Multiple testing and effect-size calibration

- Perform multiple-testing correction for familywise inference across the five foundations and primary composites. Also consider pre-registering (in the revision cover letter state which hypotheses are primary).

- Present effect-size interpretation in more concrete terms: what does a 0.5 unit change in universalism index mean in terms of number of moral words per meeting, or analogous to Enke (2020) county-level changes on vote share? You compare to Enke’s cross-sectional benchmarks—make that comparison concrete numerically.

G. Make the null informative

- The authors already compute MDEs and conduct TOST. Strengthen by reporting power curves (power as function of effect size), and report what effect sizes would be policy-relevant (e.g., effect sizes that would materially shift county-level vote shares, or that correspond to 1 additional moral word per meeting).

H. Minor but useful improvements

- Report full specification of the propensity score model and outcome regression in an appendix (variables, transformations, interactions).

- Include balance tables before/after reweighting.

- For the C-S estimator, report the numbers of not-yet-treated units at each relative time used for identification (a table that shows how many controls exist for each cohort/time). This concretely demonstrates the scarcity problem.

- Carefully reconcile why some C-S specifications do not converge at other thresholds; explain precise diagnostics triggering “did not converge” and consider small-sample fixes (regularization or trimming) to improve convergence.

7. OVERALL ASSESSMENT

Key strengths

- Novel question at the intersection of political economy, moral psychology, and text-as-data.
- Large and unique dataset (LocalView transcripts) and clear, theoretically motivated measurement (Moral Foundations/Enke framework).
- Use of modern staggered DiD estimators (Callaway & Sant’Anna) and sensitivity analyses (Rambachan & Roth / HonestDiD).
- Transparent reporting of power limitations and informative null analyses.

Critical weaknesses

- Near-universal treatment severely limits credible control-group variation; many subgroup estimations are infeasible and aggregate ATT SEs are large. This limits the informativeness of the null.
- Reliance on dictionary-based moral measurement carries nontrivial measurement error and context insensitivity; the null may be an artifact of noisy measurement attenuating effects.
- Identification could be strengthened by exploiting alternative exogenous variation in broadband rollout (grants, provider entry, Form 477) or an earlier adoption window.
- Some robustness checks (e.g., alternative thresholds) do not converge; these require clearer diagnostics and explanation.

Specific suggestions for improvement (recap)

1. Attempt to obtain additional exogenous variation (FCC grants / ISP deployment dates) or extend the pre-treatment window to earlier years to increase the not-yet-treated pool.

2. Implement at least one context-sensitive moral classification (a hand-labeled validation sample plus a transformer or LLM-assisted classifier) and report measurement performance (precision/recall). Use this to correct or bound attenuation bias.

3. Provide more detailed reporting of the C-S implementation (propensity score model, outcome regression, reweighting diagnostics, number of not-yet-treated controls at each relative time).

4. Report wild cluster bootstrap p-values and alternative clustering (place-level and Conley) more prominently; include the number of clusters in all tables.

5. If IV is infeasible, make the limits of inference central to the framing: the paper documents a design-limited null and uses the dataset to provide descriptive and methodological contributions rather than a strong causal null claim.

6. Triangulate with at least one alternative outcome (social media or campaign rhetoric) if possible.

DECISION: MAJOR REVISION

The paper is promising and potentially publishable in a top journal after the authors address the core identification/power issues and strengthen text measurement and robustness. The main path forward is either (A) obtain more credible exogenous variation (in time or instrument) to tighten inference, or (B) substantially reframe the contribution to emphasize descriptive measurement, null informativeness given data constraints, and a programmatic agenda for future causal work. Either path should be accompanied by improved text classification and clearer presentation of the C-S identification details and the control-group scarcity diagnostics.