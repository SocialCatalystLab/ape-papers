# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-29T20:17:30.092940
**Response ID:** resp_014561fba3d05ed900697bb1ac336481a2913d780c05a0b95a
**Tokens:** 22561 in / 5698 out
**Response SHA256:** 452bd5420c48bebd

---

## Referee Report (Top General-Interest Economics Journal / AEJ: Economic Policy)

This manuscript is best understood as a **data-infrastructure / descriptive atlas** paper: it assembles a geocoded crash dataset (FARS) linked to OpenStreetMap road attributes and marijuana policy timing, then presents maps and descriptive patterns, especially around state borders. That is potentially valuable. However, **as currently written it does not meet the standards for publishable empirical economics in a top journal** because it **does not execute (or report) any formal statistical inference or causal design**, despite repeatedly motivating DiD/event studies and spatial RDD.

Below I am rigorous on both **format** and **content**, as requested.

---

# 1. FORMAT CHECK

### Length
- Appears to be **~31 pages including references and appendix** (your excerpt shows pagination to p.31 with appendix figures).
- **Main text** looks to be roughly **~26–27 pages** (references begin around p.27). This likely clears the “≥25 pages excluding references/appendix” bar, but please verify and explicitly state page counts in the submission PDF.

### References
- The bibliography is **thin for the methods it proposes** and incomplete for the cannabis/traffic safety domain.
- You cite some key applied papers (e.g., Anderson et al. 2013; Cook et al. 2020) and a few methods papers (Callaway & Sant’Anna 2021; Sun & Abraham 2021; Keele & Titiunik 2015), but **major foundational and “must-cite” references are missing** (see Section 4).

### Prose vs bullets
- **Introduction (Section 1)** is in paragraphs—good.
- **Data section (Section 2)** uses extensive bulleting (variable definitions, pipeline steps). That is acceptable in Data/Methods, but the paper starts reading like a technical report rather than an AER/QJE/JPE/Restud/Ecta narrative.
- Some later sections (e.g., **Section 5**) are very short and underdeveloped; several subsections are closer to notes than full paragraphs.

### Section depth (3+ substantive paragraphs each)
Several major sections fail this standard:
- **Section 5.1 (Alcohol Involvement)** is essentially one paragraph (p.18 in your excerpt).
- **Section 6 (Policy Border Patterns)** is thin and does not provide a complete empirical analysis—more a preview.
- **Section 9 (Discussion)** is closer to a list of caveats than a developed interpretation.

### Figures
- Many figures are visually informative, but several do **not meet publication norms**:
  - Maps (e.g., Figures 5–8) largely lack axes (lat/long ticks) and provide limited cartographic context; this is often okay for an atlas, but top journals expect **self-contained** figures with clear interpretability.
  - Several plots use “approximately” in text without showing uncertainty. Only a few figures show CIs (e.g., Figure 11 shades a 95% CI, but the construction is unclear and not tied to a regression or a stated estimator).
  - Figure readability: fonts and legends look small in the embedded PDF images.

### Tables
- Tables shown (Table 1, Table 2) contain real numbers—good.
- However, there are **no regression tables**, which is not necessarily fatal for a data paper, but is fatal for a paper claiming designs and patterns that imply causal interpretation.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

Your instructions correctly state: **a paper cannot pass without proper statistical inference.** On that criterion, the manuscript **fails**.

### (a) Standard Errors
- There are **no regression coefficients** and thus **no SEs in parentheses anywhere**.
- The paper makes numerical claims (e.g., “THC detected is 19% vs 10%”) without presenting **sampling uncertainty**, even though those are sample proportions from a finite sample.

**Result: FAIL.**

### (b) Significance testing
- No hypothesis tests, no randomization inference, no permutation/placebo tests, no formal discontinuity tests at borders.

**Result: FAIL.**

### (c) Confidence intervals
- Only a small number of figures show something labeled as a “95% CI” (e.g., Figure 11), but:
  - the estimator is not clearly defined,
  - the sampling procedure is not stated,
  - it is not linked to an identification strategy with assumptions.

**Result: FAIL (for “main results”).**

### (d) Sample sizes for regressions
- There are no regressions. For many descriptive graphs, N is sometimes shown (good), but not systematically and not for each subgroup/bin in a transparent way.

**Result: FAIL (as applied to causal claims).**

### (e) DiD with staggered adoption
- You discuss staggered adoption and cite appropriate papers (Callaway & Sant’Anna; Sun & Abraham), but you **do not implement any DiD/event study**.
- You also repeatedly group states by “eventual legalization status” (e.g., Figure 3 note), which is **not** an acceptable treatment definition for DiD and risks severe bias if later-treated states differ pre-trends.

**Result: FAIL (no executed design).**

### (f) RDD requirements
- You motivate spatial RDD (Section 8) and show RDD-style plots (Figure 15) but:
  - no local-linear specification,
  - no bandwidth sensitivity,
  - no donut/border-corridor robustness,
  - no covariate balance,
  - no McCrary-type density/manipulation test (adapted for spatial running variable),
  - no discussion of spatial autocorrelation/inference clustering.

**Result: FAIL.**

### Bottom line on methodology
As written, this is **not publishable** in AER/QJE/JPE/ReStud/Ecta/AEJ:EP. A top-journal contribution—even a “data” paper—must either (i) provide credible causal evidence with inference, or (ii) be explicitly positioned as a data release with rigorous validation, measurement error quantification, and uncertainty reporting. Currently it does neither.

---

# 3. IDENTIFICATION STRATEGY

### Credibility
- The paper repeatedly signals causal ambitions (“enables event study designs,” “motivates spatial RDD”) but **does not deliver a coherent identification design with estimates**.
- The strongest quasi-experimental idea is the **policy border spatial RDD** (Keele & Titiunik framework), but you do not articulate the required continuity assumptions in a way that would satisfy econometric scrutiny.

### Key assumptions: discussed but not operationalized
- **Parallel trends**: not tested because no event study is estimated.
- **RDD continuity**: not tested with covariate balance, placebo borders, or density checks.
- **SUTVA/spillovers**: cross-border shopping is acknowledged (Section 8.4) but this directly threatens the interpretation of “policy discontinuity”—and you do not model spillovers.

### Placebos / robustness
Absent in any serious sense:
- No pre-trend plots for crash outcomes around legalization dates.
- No placebo outcomes (e.g., daytime crashes, non-driver fatalities, weather-related crashes).
- No placebo borders (borders between two illegal states, or two legal states post-2018).
- No sensitivity to alternative THC definitions (cannabinoid codes vs text match) beyond a brief note.
- No robustness to excluding “Test Not Given” records or conditioning on actual testing.

### Do conclusions follow from evidence?
- Many conclusions are phrased as “patterns” rather than causal claims, which helps. But the rhetoric still overreaches (e.g., repeated “discontinuities at borders” language) without formal discontinuity tests and without dealing with testing/reporting heterogeneity.

### Limitations
- You correctly emphasize drug-testing/reporting selection issues (Section 7.2–7.3). This is a strong part of the manuscript.
- But you do not follow through with solutions (bounding, selection models, reweighting, validation exercises).

---

# 4. LITERATURE (missing references + BibTeX)

## Methods literature you should cite (and actually use)
### Difference-in-differences (staggered adoption)
You cite Callaway & Sant’Anna (2021) and Sun & Abraham (2021). Missing essentials:
1. **Goodman-Bacon (2021)** decomposition (to explain why TWFE fails and to justify your estimator).
2. **de Chaisemartin & D’Haultfoeuille (2020)** TWFE negative weights issue.
3. **Borusyak, Jaravel & Spiess (2021)** imputation / event-study estimation.
4. **Roth, Sant’Anna, Bilinski & Poe (2023)** pretrend testing and event-study practice.

```bibtex
@article{GoodmanBacon2021,
  author  = {Goodman-Bacon, Andrew},
  title   = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year    = {2021},
  volume  = {225},
  number  = {2},
  pages   = {254--277}
}

@article{deChaisemartinDHaultfoeuille2020,
  author  = {de Chaisemartin, Cl{\'e}ment and D'Haultfoeuille, Xavier},
  title   = {Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects},
  journal = {American Economic Review},
  year    = {2020},
  volume  = {110},
  number  = {9},
  pages   = {2964--2996}
}

@article{BorusyakJaravelSpiess2021,
  author  = {Borusyak, Kirill and Jaravel, Xavier and Spiess, Jann},
  title   = {Revisiting Event Study Designs: Robust and Efficient Estimation},
  journal = {Review of Economic Studies},
  year    = {2021},
  volume  = {90},
  number  = {6},
  pages   = {3253--3295}
}

@article{RothSantAnnaBilinskiPoe2023,
  author  = {Roth, Jonathan and Sant'Anna, Pedro H.C. and Bilinski, Alyssa and Poe, John},
  title   = {What's Trending in Difference-in-Differences? A Synthesis of the Recent Econometrics Literature},
  journal = {Journal of Econometrics},
  year    = {2023},
  volume  = {235},
  number  = {2},
  pages   = {2218--2244}
}
```

### Regression discontinuity (including spatial/border settings)
You cite Keele & Titiunik (2015). Missing essentials:
1. **Imbens & Lemieux (2008)** and **Lee & Lemieux (2010)** for canonical RD.
2. **McCrary (2008)** density test (adapt or discuss its spatial analogue).
3. **Calonico, Cattaneo & Titiunik (2014)** robust bias-corrected inference.
4. **Cattaneo, Idrobo & Titiunik (2020)** RD handbook.

```bibtex
@article{ImbensLemieux2008,
  author  = {Imbens, Guido W. and Lemieux, Thomas},
  title   = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year    = {2008},
  volume  = {142},
  number  = {2},
  pages   = {615--635}
}

@article{LeeLemieux2010,
  author  = {Lee, David S. and Lemieux, Thomas},
  title   = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year    = {2010},
  volume  = {48},
  number  = {2},
  pages   = {281--355}
}

@article{McCrary2008,
  author  = {McCrary, Justin},
  title   = {Manipulation of the Running Variable in the Regression Discontinuity Design: A Density Test},
  journal = {Journal of Econometrics},
  year    = {2008},
  volume  = {142},
  number  = {2},
  pages   = {698--714}
}

@article{CalonicoCattaneoTitiunik2014,
  author  = {Calonico, Sebastian and Cattaneo, Matias D. and Titiunik, Rocio},
  title   = {Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs},
  journal = {Econometrica},
  year    = {2014},
  volume  = {82},
  number  = {6},
  pages   = {2295--2326}
}

@book{CattaneoIdroboTitiunik2020,
  author    = {Cattaneo, Matias D. and Idrobo, Nicol{\'a}s and Titiunik, Rocio},
  title     = {A Practical Introduction to Regression Discontinuity Designs: Foundations},
  publisher = {Cambridge University Press},
  year      = {2020}
}
```

## Substantive literature: cannabis and traffic safety
You cite Anderson et al. (2013), Romano et al. (2017), Cook et al. (2020). You should also engage:
- **Santaella-Tenorio et al. (2017)** (systematic review on recreational cannabis laws & crashes).
- **Aydelotte et al. (2017)** (traffic fatalities after legalization—though medical/public health, widely cited).
- **Hall & Lynskey (2020)** or similar review on cannabis-impaired driving measurement issues.
- More recent econ/public policy work using newer post-2016 legalization waves (CA/NV), and work discussing **testing regime endogeneity** and **measurement** (a core issue for your paper).

```bibtex
@article{SantaellaTenorio2017,
  author  = {Santaella-Tenorio, Julian and Mauro, Christine and Wall, Melanie and Kim, Jae Hoon and Cerd{\'a}, Magdalena and Keyes, Katherine M. and Galea, Sandro and Martins, Silvia S.},
  title   = {US Traffic Fatalities, 1985--2014, and Their Relationship to Medical Marijuana Laws},
  journal = {American Journal of Public Health},
  year    = {2017},
  volume  = {107},
  number  = {2},
  pages   = {336--342}
}

@article{Aydelotte2017,
  author  = {Aydelotte, Jayson D. and Brown, Lawrence H. and Luftman, Kevin M. and Mardock, Amanda L. and Teixeira, Pedro G. and Coopwood, T. B. and Ali, Salman and Rix, Kathleen and Williams, Jacob and Jalbert, Leah and others},
  title   = {Crash Fatality Rates After Recreational Marijuana Legalization in Washington and Colorado},
  journal = {American Journal of Public Health},
  year    = {2017},
  volume  = {107},
  number  = {8},
  pages   = {1329--1331}
}
```

(If you believe Santaella-Tenorio 2017 is not the right match for the specific claim in the title, then you must replace with the correct systematic review(s) and ensure accuracy; the point is: **you need a serious “what do we know” section** that goes beyond 3–5 citations.)

## Data/measurement references (FARS, geocoding, GIS reproducibility)
Given your contribution is data integration, you should cite:
- NHTSA/FARS documentation versions (year-specific) and any changes to drug reporting fields around 2018.
- Standard references on using OpenStreetMap data in research beyond Boeing (2017), including data quality variability and temporal mismatch.

---

# 5. WRITING QUALITY (CRITICAL)

### (a) Prose vs bullets
- Intro is readable.
- But the manuscript increasingly reads like an internal methods memo. For a top journal, you need a **stronger narrative arc** and fewer list-like subsections outside Data/Appendix.
- Several sections are underwritten (notably Sections 5–6). A top-journal reader will ask: *What is the paper’s core empirical deliverable—an atlas, a validated dataset, or a causal analysis?* Right now it is torn between these.

### (b) Narrative flow
- The motivation (traffic fatalities + marijuana policy) is clear.
- The contribution is described, but the paper does not *deliver a headline result with inference*; instead it delivers visual patterns. That is not enough for the journals you list unless positioned as a data/measurement paper with rigorous validation and uncertainty quantification.

### (c) Sentence quality
- Generally competent, but overuses parentheticals and qualifiers (“approximately,” “critical period,” “unprecedented granularity”) without backing them with measured validation metrics.
- Some claims read promotional (“unprecedented granularity,” “previously infeasible”) and should be replaced with precise statements: what exactly was infeasible, for which estimators/outcomes, and why?

### (d) Accessibility
- You do explain key limitations (THC detection ≠ impairment; missing testing; OSM time mismatch). That is good.
- However, you should more clearly explain what outcomes can be credibly studied with which years (e.g., **THC only reliable 2018+**), and how that affects interpretation.

### (e) Figures/tables quality
- The figures are interesting but not yet at a publication-quality standard. Each figure needs:
  - explicit sample definition in the note (e.g., tested drivers only? any drug record including “test not given”?),
  - uncertainty where claims are comparative,
  - consistent treatment definitions (avoid “eventual legalizer” grouping for time-series comparisons).

---

# 6. CONSTRUCTIVE SUGGESTIONS (to make it publishable)

You have two viable paths; right now you are stuck between them.

## Path A (recommended): Reframe as a **data/measurement paper**, not a causal policy paper
If the goal is an “atlas + integrated dataset” contribution, then you must add **validation and measurement science**:
1. **Geocoding validation**: quantify spatial error using internal FARS fields (route number, milepost, county) or external validation where possible; report distributions of snap distances by state/year/road type.
2. **Testing/reporting regime documentation**: formalize the selection problem:
   - model/report the probability of drug record presence,
   - show how it changes discontinuously at borders (this is crucial: border “discontinuities” in THC-positive shares may be pure reporting).
3. **Uncertainty for descriptive statistics**:
   - for each state share (THC-positive among drug records), report **binomial CIs** or bootstrap CIs clustered at county/state as appropriate.
4. **A “data user’s guide” section**:
   - what estimands are reasonable with these data,
   - what estimands are not,
   - recommended practice for denominators (tested drivers vs any record vs all crashes).
5. **Replicability**:
   - provide versioning (FARS release versions; OSM extraction date; PBF snapshots),
   - provide a stable archived release (Dataverse/Zenodo) with checksums.

This could plausibly fit AEJ:EP (or a field journal) if executed exceptionally well.

## Path B: Actually deliver the causal designs you claim (DiD + spatial RDD)
If you want a top general-interest econ audience, you need **credible estimates**:

### DiD/event study (crash counts; alcohol involvement)
- Define treatment precisely (possession legal date vs retail opening date).
- Use modern estimators:
  - **Callaway & Sant’Anna (2021)** group-time ATT with never-treated controls (WY/NE/KS/ID/UT).
  - Or **Sun & Abraham (2021)** interaction-weighted event studies.
- Unit of analysis: county-month (or county-quarter) crash counts with population/VMT offsets; or road-segment-month if you want to exploit OSM.
- Inference: cluster at state or border-segment level; consider randomization inference with few clusters if using state-level variation.
- Report: coefficients + SEs + 95% CIs + N, with pre-trend tests and event-study plots.

### Spatial RDD at borders (THC outcomes, 2018–2019)
- Use a canonical RD estimator (local linear with triangular kernel).
- Report bandwidth sensitivity (multiple bandwidths, CCT-optimal bandwidth).
- Implement **density tests** (spatial analogue): show the distribution of crashes by distance to border and test for discontinuities (you already plot counts; you need a test).
- Show covariate balance (road type, speed limit availability, nighttime, weather, county characteristics) at the cutoff.
- Correct inference for spatial correlation (cluster by small spatial cells or by border segment; use spatial HAC if appropriate).
- Address multiple border pairs explicitly: don’t pool unless you justify homogeneity; consider border-pair fixed effects.

### Address the biggest threat: endogenous testing/reporting
- Treat **drug-testing/reporting** as an outcome and as a selection mechanism.
- Consider bounding exercises: e.g., worst-case bounds on THC share among untested, or sensitivity analysis under assumptions about missing not at random.
- At minimum: replicate all border discontinuity results under alternative denominators:
  1) all fatal crashes, 2) any drug record, 3) explicitly tested for cannabinoids, 4) tested drivers only.

---

# 7. OVERALL ASSESSMENT

## Key strengths
- The integrated dataset concept is useful, and the replication pipeline could be a public good.
- Clear acknowledgment of major limitations (THC detection vs impairment; missing testing; OSM temporal mismatch).
- Maps are visually compelling and could motivate future work.

## Critical weaknesses (publishability blockers)
1. **No statistical inference** supporting any comparative claim (SEs/CIs/tests absent).
2. **No implemented identification strategy** despite repeatedly motivating DiD and spatial RDD.
3. **Border “discontinuities” are asserted visually** without RD estimators, bandwidth checks, or manipulation/density tests.
4. **Endogenous testing/reporting is central** yet not modeled or corrected; it plausibly drives your headline THC differences.
5. The paper is caught between being an atlas/data note and a causal policy evaluation—top journals require you to choose and execute.

## Specific improvements (high priority)
- Decide: data/measurement paper vs causal evaluation paper.
- Add formal estimators + inference and rewrite Sections 5–6 into fully developed analyses.
- Expand literature substantially, especially methods and measurement/testing endogeneity.
- Upgrade figures to publication quality; add uncertainty and consistent denominators.

---

DECISION: REJECT AND RESUBMIT