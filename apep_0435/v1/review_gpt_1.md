# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T17:21:44.127011
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 21270 in / 4485 out
**Response SHA256:** 3c8a8c55cb2b9058

---

## Referee Report: “The Convergence of Gender Attitudes: Forty Years of Swiss Municipal Referenda”

### Summary
The paper uses Swiss municipality-level referendum results (1981–2021) to study (i) persistence of local “gender progressivism” and (ii) convergence in its cross-municipality dispersion. The setting is attractive: revealed-preference voting data at fine geographic resolution over four decades. The central findings—strong persistence but substantial σ-convergence after 1999/2004, driven by German-speaking municipalities catching up—are potentially publishable in a top field/general journal if the authors sharpen identification claims, tighten the interpretation of AIPW in this context, and address several measurement/comparability issues across referenda.

My main concern is not “inference” (you do report clustered SEs, N, and bootstrap p-values), but *interpretation*: the analysis mostly establishes long-run cross-sectional correlations and dispersion changes across *different* policy questions, not a causal effect of “1981 norms” or of the 2004 policy event. This is fixable, but it requires reframing, additional tests, and clearer conceptualization of what is being identified.

---

# 1. FORMAT CHECK

- **Length**: From the LaTeX provided, the main text looks roughly ~20–25 pages in 12pt, 1.5 spacing, plus a sizeable appendix. It is likely near the 25-page threshold but may be slightly short/long depending on figures. For AER/QJE/JPE/ReStud/Ecta norms, ensure main text is comfortably ≥25 pages excluding references/appendix *or* follow the journal’s word-count norms.
- **References**: The introduction cites classic culture/persistence papers and some Swiss “Röstigraben” work. However, the bibliography (not shown) likely misses key literatures on (i) measuring culture with voting, (ii) political economy of referenda, and (iii) modern causal methods relevant to your claims (even if you are not doing DiD/RDD). See Section 4 below for concrete additions with BibTeX.
- **Prose**: Major sections are in paragraph form; bullets appear only in the data appendix—appropriate.
- **Section depth**: Introduction, Background, Data, Strategy, Results, Discussion each have multiple substantive paragraphs. Good.
- **Figures**: Since this is LaTeX source, I see `\includegraphics{...pdf}` calls with captions and notes; I cannot verify axes/legibility. Do not interpret this as missing figures, but ensure in the compiled PDF that all axes are labeled (units in % points), and that dispersion figures clearly indicate which referendum each point corresponds to.
- **Tables**: Tables contain real numbers with SEs and N. Good.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### a) Standard Errors
**PASS.** Main regression tables present SEs in parentheses; tables state clustering at the canton level.

### b) Significance Testing
**PASS.** Stars and p-values are provided; you also report wild cluster bootstrap p-values.

### c) Confidence Intervals
**Mostly PASS, but improve.** The text and a figure mention “95% confidence intervals,” but the key tables do not report CIs explicitly. Top journals increasingly prefer either (i) CI columns in main tables for headline estimates or (ii) coefficient plots with 95% CIs for all main outcomes. Recommendation: add a coefficient plot (with CIs) for the persistence and convergence regressions, or add CI brackets in the main tables.

### d) Sample Sizes
**PASS.** N is reported (2,094) throughout.

### e) DiD with staggered adoption
Not applicable (you are not using DiD). You *do* discuss a post-2004 acceleration; be careful not to imply a DiD/event-study identification without implementing it.

### f) RDD requirements
Not applicable (you propose RDD as future work but do not implement it).

### Additional inference issues to address (important)
1. **26-cluster inference**: You appropriately worry about over-rejection and use wild cluster bootstrap. Good. But: in several places you still interpret conventional p-values strongly (“highly significant”). For 26 clusters, emphasize bootstrap p-values (or randomization inference if relevant), and consider reporting **CR2/CR3** small-sample cluster-robust SEs (e.g., Bell-McCaffrey adjustments) as a robustness check.
2. **Weighting / heteroskedasticity**: Municipality-level vote shares have different precision because valid ballots vary enormously across municipalities. Treating each municipality equally is defensible for “community norms,” but your interpretation sometimes drifts toward “the Swiss electorate.” Consider:
   - reporting both **unweighted** (municipality as unit) and **weighted by valid ballots/eligible voters** estimates;
   - or explicitly stating the estimand is municipality-average behavior, not voter-average behavior.
3. **AIPW for a “continuous treatment” that is itself an outcome**: You model 1981 vote share as a continuous “treatment” and apply GPS/AIPW. This is not wrong mechanically, but it invites a causal interpretation (“effect of 1981 progressivism on 2020 outcomes”) that is not credible under unconfoundedness with such limited covariates (language/religion/suffrage year). AIPW does not solve omitted variables; it solves functional form and covariate imbalance *conditional on unconfoundedness*. You should either:
   - (i) explicitly frame AIPW as a **reweighting robustness check** for linearity/overlap rather than a causal estimator; or
   - (ii) massively expand covariates (municipality socioeconomic structure, education, sectoral composition, urbanization, age structure, immigrant share, etc.) so unconfoundedness is at least plausible.

**Bottom line**: Statistical inference is present (good), but causal language around AIPW needs tightening, and you should improve estimand clarity (unweighted vs weighted, municipality vs voter).

---

# 3. IDENTIFICATION STRATEGY

### What is credibly identified right now
- **Persistence**: You convincingly document *long-run within-canton cross-sectional association* between 1981 support for equal rights and 2020/2021 support for other gender-related policies.
- **σ-convergence**: You convincingly document that the **dispersion of municipality vote shares** is lower in 2021 than in (especially) 1999.

### Key identification/interpretation concerns
1. **Comparability across referenda (construct validity of “gender progressivism”)**  
   Your convergence claim uses dispersion across *different policy questions* (equal rights, maternity insurance variants, paternity leave, same-sex marriage). Dispersion changes may reflect:
   - different issue salience,
   - different partisan coalitions,
   - different campaign structures,
   - different national baselines (and “ceiling/floor compression”),
   - different mapping from underlying attitudes to vote shares.
   
   You acknowledge floor compression for 1984, but the bigger issue is that comparing σ across fundamentally different referenda is not a clean measure of “norm convergence.” It is suggestive, but you need stronger evidence that these votes load on a common latent factor and that changes in dispersion reflect convergence in that factor rather than changing issue content.
   
   **Fix**: estimate a **latent factor model / IRT** (e.g., a one-dimensional ideal-point model for municipalities) using multiple referenda, then study σ-convergence of the *latent municipal gender factor* over time. Even with only six referenda, you can:
   - treat each referendum as an “item” with difficulty/discrimination parameters;
   - recover municipality scores and compare dispersion across time windows.
   Alternatively, use PCA on standardized vote shares and show the first component is stable and interpretable as “gender progressivism,” then track its dispersion.

2. **“Convergence accelerated after 2004” is not identified causally**  
   The post-2004 narrative is intriguing but currently descriptive. Without a design exploiting variation in exposure/intensity, it is easy to overinterpret. At minimum, this needs to be framed as a **temporal coincidence** rather than an inferred mechanism.
   
   **Fix options**:
   - Pre-register a *formal structural break test* in the σ-series (though N_t=6 is tiny; power is limited).
   - Use richer time-series of related votes (if more than six gender-relevant referenda exist, add them) to create a more continuous σ_t series.
   - If you want a causal mechanism story, you need cross-sectional variation: e.g., differential local exposure to maternity leave implementation, childcare expansion, female labor demand shocks, media penetration, etc.

3. **Unconfoundedness for AIPW is very strong here**  
   Conditioning on canton-level language/religion/suffrage year is unlikely to make 1981 vote shares “as good as random.” Municipality-level education, income, urbanization, industry, age structure, and migration are likely major confounders and also plausibly persistent.
   
   **Fix**: add municipality controls (time-varying if possible) and/or use designs that net out time-invariant municipality heterogeneity (see below).

4. **Better use of the panel structure**  
   You have repeated outcomes for the same municipalities (1981, 1984, 1999, 2004, 2020, 2021). Yet the core “persistence regression” is cross-sectional (2020 on 1981). Consider exploiting the panel:
   - municipality fixed effects (though 1981 is time-invariant, so not for persistence slope directly),
   - but you can model **rank persistence** and **mean reversion** in a panel framework,
   - or estimate transition dynamics (Markov/rank-rank mobility), which may align better with your “sticky but converging” theme.

### Placebos/robustness
- The falsification with non-gender referenda is helpful and well-presented. However, it does not fully rule out “general ideology,” because “progressive” on corporate responsibility but “conservative” on immigration/defense is a known multidimensional pattern. Your mixed signs are consistent with multidimensional ideology rather than domain-specific gender norms per se.
  
  **Fix**: include additional “ideology proxies,” e.g., municipality-level party vote shares in federal elections (SVP/SP/FDP/Green), or construct an ideology factor from many non-gender referenda, then show 1981 gender vote predicts future gender votes *conditional on ideology*.

---

# 4. LITERATURE (MISSING REFERENCES + BibTeX)

You cite major culture-persistence papers and some Swiss cultural-border work. Key missing pieces:

## (i) Swiss referenda / voting as data; Swissvotes
You use Swiss direct democracy as a core measurement device; you should cite standard references on Swiss referenda datasets and political economy.

```bibtex
@article{Hug2001,
  author  = {Hug, Simon},
  title   = {Policy Consequences of Direct Legislation in Switzerland: Explaining the Adoption of Federal Acts},
  journal = {European Journal of Political Research},
  year    = {2001},
  volume  = {39},
  number  = {2},
  pages   = {179--206}
}
```

Swissvotes dataset is central for validation; cite the data source formally if possible (many journals allow dataset citations). If there is a canonical Swissvotes paper/tech report, add it.

## (ii) Culture and voting / revealed preferences
Your “revealed preference” framing would benefit from citations using voting patterns as culture/attitude measures.

```bibtex
@article{GennaioliRainer2007,
  author  = {Gennaioli, Nicola and Rainer, Ilia},
  title   = {The Modern Impact of Precolonial Centralization in Africa},
  journal = {Journal of Economic Growth},
  year    = {2007},
  volume  = {12},
  number  = {3},
  pages   = {185--234}
}
```

(Example of using political outcomes as persistent local traits; adjust if you prefer closer voting/culture papers.)

## (iii) Modern causal inference around “doubly robust” / AIPW practice
You cite Robins (1994) and some GPS papers, but top journals expect more modern references clarifying double robustness and practical implementation.

```bibtex
@article{ChernozhukovEtAl2018,
  author  = {Chernozhukov, Victor and Chetverikov, Denis and Demirer, Mert and Duflo, Esther and Hansen, Christian and Newey, Whitney and Robins, James},
  title   = {Double/Debiased Machine Learning for Treatment and Structural Parameters},
  journal = {The Econometrics Journal},
  year    = {2018},
  volume  = {21},
  number  = {1},
  pages   = {C1--C68}
}
```

```bibtex
@article{AtheyImbens2017,
  author  = {Athey, Susan and Imbens, Guido W.},
  title   = {The State of Applied Econometrics: Causality and Policy Evaluation},
  journal = {Journal of Economic Perspectives},
  year    = {2017},
  volume  = {31},
  number  = {2},
  pages   = {3--32}
}
```

(These help you frame AIPW as a modern tool and clarify what it does/doesn’t buy you.)

## (iv) Inference with few clusters / wild bootstrap
You cite Cameron et al. (2008). Also cite the key “few clusters” problem and wild cluster bootstrap developments.

```bibtex
@article{CameronMiller2015,
  author  = {Cameron, A. Colin and Miller, Douglas L.},
  title   = {A Practitioner’s Guide to Cluster-Robust Inference},
  journal = {Journal of Human Resources},
  year    = {2015},
  volume  = {50},
  number  = {2},
  pages   = {317--372}
}
```

```bibtex
@article{RoodmanEtAl2019,
  author  = {Roodman, David and Nielsen, Morten {\O}rregaard and MacKinnon, James G. and Webb, Matthew D.},
  title   = {Fast and Wild: Bootstrap Inference in Stata Using boottest},
  journal = {The Stata Journal},
  year    = {2019},
  volume  = {19},
  number  = {1},
  pages   = {4--60}
}
```

## (v) Convergence concepts beyond growth (if you keep β/σ framing)
You cite Barro & Sala-i-Martin. Consider citing work discussing σ-convergence measurement caveats and distribution dynamics.

```bibtex
@article{Quah1993,
  author  = {Quah, Danny},
  title   = {Galton's Fallacy and Tests of the Convergence Hypothesis},
  journal = {Scandinavian Journal of Economics},
  year    = {1993},
  volume  = {95},
  number  = {4},
  pages   = {427--443}
}
```

Why relevant: β-convergence regressions can mechanically imply mean reversion without true distributional convergence; Quah-style distribution dynamics are a natural complement to your message.

---

# 5. WRITING QUALITY (CRITICAL)

### a) Prose vs bullets
**PASS.** Main sections are written in full paragraphs. Bullets appear in the appendix for variable lists—appropriate.

### b) Narrative flow
Strong opening anecdote (Appenzell Innerrhoden) and clear motivation. The “persistence vs convergence” tension is an effective hook. The arc generally works: motivation → setting → method → results → interpretation.

### c) Sentence quality
Generally crisp and readable. However, there is occasional over-claiming language (“show that…”, “confirm that…”) where the evidence is correlational. Replacing with “document,” “is consistent with,” “is suggestive of,” etc., would improve credibility.

### d) Accessibility
Good explanations of the Swiss context and β/σ-convergence. AIPW/GPS explanation is somewhat technical; consider adding a short intuitive paragraph: what exactly is being reweighted and what “double robustness” means here given the treatment is continuous and measured with error.

### e) Tables
Tables are clean with notes, N, clustering. Two improvements:
1. Report 95% CIs (or add a companion coefficient plot).
2. In falsification table, clarify sign interpretation (e.g., for “Mass Immigration,” is a higher YES share “more conservative” or “more restrictive”? Readers outside Switzerland will not know).

---

# 6. CONSTRUCTIVE SUGGESTIONS (HOW TO MAKE IT MORE IMPACTFUL)

## A. Strengthen the measurement of “gender attitudes” over time
1. **Latent factor / IRT / PCA approach** (high priority):  
   Build a municipality “gender norm” index using all gender referenda, allowing referendum-specific difficulty/discrimination. Then:
   - test persistence of the latent index,
   - test σ-convergence of that index,
   - show robustness to dropping same-sex marriage (which some may view as distinct from gender equality).

2. **Add more gender-relevant votes if possible**:  
   Switzerland likely has additional referenda touching family policy, childcare, abortion, equality enforcement, partnership laws (registered partnership), etc. More time points will make σ_t dynamics credible and allow more formal trend/break analysis.

## B. Clarify estimands and reduce causal overreach
1. Reframe AIPW as: **(i) functional-form robustness** and **(ii) covariate rebalancing**—not as a credible causal estimate unless you add rich municipality covariates.
2. Be explicit that the baseline “persistence” parameter is a **predictive relationship** (or “conditional correlation”) unless you can defend unconfoundedness.

## C. Address confounding with richer covariates and ideology controls
1. Add municipality-level controls (ideally measured pre-1981 or early): education, urban/rural status, population density, sectoral composition, income/tax base, age structure, foreign-born share, commuting patterns.
2. Add **party vote shares** (SVP/SP/FDP/Green) from federal elections as a proxy for ideology. Then show:
   - 1981 gender vote predicts 2020/2021 gender votes even conditional on ideology;
   - and/or show that an ideology factor predicts non-gender referenda but not the same way.

## D. Improve convergence analysis beyond SD
1. Report **rank mobility**: Spearman rank correlation of municipalities’ gender vote shares between 1981 and 2020/2021; transition matrices across deciles; Shorrocks mobility index. This matches your “sticky but converging” theme.
2. Look at **distributional changes**: kernel density evolution for the latent index; quantify polarization (e.g., bimodality coefficient) not just SD.

## E. Weighting and interpretation
1. Provide both **municipality-weighted** and **voter-weighted** analyses, and interpret them carefully (community norms vs electorate norms).
2. In σ-convergence, consider dispersion in **log-odds** of YES share to mitigate mechanical compression near 0/100 and improve comparability across referenda with different baselines.

## F. Mechanisms (optional, but would elevate the paper)
Even a simple correlational mechanism exercise would help:
- correlate convergence/catch-up with municipality changes in urbanization, education, female labor force participation, childcare availability, or migration inflows;
- or interact baseline conservatism with time-varying proxies for media/internet penetration.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Excellent setting and data construction (municipality harmonization, balanced panel).
- Clear and interesting question: persistence *and* convergence of gender norms.
- Inference is taken seriously (clustered SEs + wild bootstrap).
- The empirical patterns (persistence within canton + large decline in dispersion by 2021) are noteworthy and likely of broad interest.

### Critical weaknesses (fixable, but substantial)
1. **Construct validity / comparability**: σ-convergence is computed across different referenda that may not measure the same latent attitude with stable mapping.
2. **Causal language vs correlational design**: AIPW risks being read as a causal claim without a credible unconfoundedness story or rich covariates.
3. **Domain-specificity falsification is not fully decisive**: mixed signs across non-gender referenda may reflect multidimensional ideology rather than true domain specificity.

### Specific high-return improvements
- Build a latent gender-attitude index (IRT/PCA) and redo persistence and convergence on that index.
- Add ideology controls (party vote shares or a non-gender referendum factor).
- Provide weighted vs unweighted estimands and consider log-odds transformations for dispersion.

DECISION: MAJOR REVISION