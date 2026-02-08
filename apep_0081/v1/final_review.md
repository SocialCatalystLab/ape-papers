# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-29T14:31:36.900007
**Response ID:** resp_03345e2fe257e71f00697b60853dd881969e6c7b4ccef2f18b
**Tokens:** 18082 in / 6033 out
**Response SHA256:** c69c5b511ce358d2

---

## Referee Report: “Roads, Crashes, and Substances: A Geocoded Atlas of Western US Traffic Fatalities” (Jan 29, 2026)

This manuscript is best understood as a **data infrastructure + descriptive atlas** paper. The dataset integration (FARS × OSM × policy timing) is potentially useful. However, for a top general‐interest economics journal (or AEJ:EP), the paper in its current form is **not remotely publishable** because it provides **no formal statistical inference** and does not execute the causal designs it repeatedly motivates (spatial RDD, DiD). The current draft reads like a technical report/data note with attractive maps, not a journal-ready economics paper.

Below I give a demanding, comprehensive review.

---

# 1. FORMAT CHECK

### Length
- The PDF excerpt shows **~29 pages including appendix/figures** (page numbers visible around pp. 11–16 and appendix at p. 29).  
- **Main text appears to end around p. 25**, with appendices after. The paper likely meets the “≥25 pages” threshold **only if appendices count**. For AER/QJE/JPE/ReStud/Ecta, the *main text* typically must stand alone; right now, much of what feels like “results” is figures/maps plus captions.

**Action:** Report **(i)** main-text page count excluding references/appendix, **(ii)** appendix length.

### References coverage
- Bibliography is **thin** for the questions raised. It includes Anderson et al. (2013), Hansen et al. (2015) (note: that paper is teen use, not traffic), Keele & Titiunik (2015), and modern DiD (Callaway–Sant’Anna; Sun–Abraham).
- Missing major RD references (Imbens–Lemieux; Lee–Lemieux; Calonico–Cattaneo–Titiunik; McCrary), missing core DiD references (Goodman-Bacon; Roth; Borusyak et al.), and missing much of the substantive traffic safety + cannabis literature.

### Prose vs bullets
- Major sections are mostly paragraph-form prose. Bullets are used appropriately in Data/Appendix variable definitions (Section 2; Appendix A.1). **This is acceptable.**
- However, parts of Sections 2.4–2.5 read like pipeline documentation rather than publication prose; it needs a more polished narrative.

### Section depth (3+ substantive paragraphs per major section)
- **Intro (Section 1):** ~6 paragraphs — OK.
- **Data (Section 2):** multiple subsections; many are 2–3 paragraphs plus bullets — borderline but mostly OK.
- **Descriptive patterns (Section 3):** short; reads like figure-by-figure commentary; likely <3 substantive paragraphs per subsection.
- **Showcase maps (Section 4):** essentially a sequence of map captions in prose; not “analysis” in the top-journal sense.
- **Discussion/limitations (Sections 7, 9):** present but not deep enough relative to the identification threats they themselves raise.

### Figures
- Time-series and bar figures have axes and labels (e.g., Figures 1–4; 10–11).  
- Several map figures are “atlas-style”; they have scale bars and legends, but **lack coordinate axes** and do not always show key contextual layers (roads, border line thickness, sampling window). This is fine for an online appendix but not sufficient for core empirical claims.
- Some figures are presented as screenshots/pages; ensure final submission uses vector graphics and journal style.

### Tables
- Tables shown (Table 1, Table 2) contain real numbers. **No placeholders.**

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

Per your own instructions: a paper cannot pass without inference. This manuscript **fails**.

### (a) Standard errors
- There are **no regressions** and hence **no coefficients with SEs** anywhere.
- Claims are based on raw descriptive differences (e.g., “~20% vs ~10% THC detected,” Section 3.2 / Table 2 Panel C) without any uncertainty quantification.

**Result:** **FAIL**.

### (b) Significance testing
- No hypothesis tests, no permutation/randomization inference, no clustering strategy, no border-pair inference.

**Result:** **FAIL**.

### (c) Confidence intervals
- No 95% CIs for any key quantity (differences in proportions, slopes, discontinuities).

**Result:** **FAIL**.

### (d) Sample sizes for regressions
- No regressions; N is occasionally reported for maps, but not systematically for estimands.

**Result:** **FAIL**.

### (e) DiD with staggered adoption
- The paper does **not implement DiD**. It only discusses DiD in Section 8.2 and acknowledges missing years 2006–2015 prevent event studies.  
- In addition, the grouping choice in Figure 3/Table 2 is problematic: “Legal states” are defined by eventual legal status, **not crash-date legal status**, and the paper explicitly notes CA/NV 2016 are pre-legalization but still included as “Legalized States.” That is fine descriptively but **not acceptable** even for pre-analysis framing in a causal paper.

**Result:** Not executed; if executed later, must avoid TWFE pitfalls.

### (f) RDD requirements
- The paper shows “RDD-style plots” (Figure 15) and repeatedly motivates border RDD (Sections 4.1, 6, 8.1), but provides **none** of the required RD diagnostics:
  - No bandwidth sensitivity,
  - No McCrary density/manipulation test (sorting around border),
  - No covariate balance/continuity checks,
  - No donut RD, placebo borders, placebo outcomes,
  - No clear running variable definition for each border segment (and no discussion of spatial autocorrelation / clustering along borders).

**Result:** **FAIL**.

### Bottom line on methodology
Even if the goal is “methodological and descriptive rather than causal” (end of Section 1), top journals still require **formal inference** for headline comparisons and discontinuities. As written, the paper is **unpublishable** in AER/QJE/JPE/ReStud/Ecta/AEJ:EP.

---

# 3. IDENTIFICATION STRATEGY

The manuscript **does not deliver an identification strategy**; it advertises one.

### What is credible
- The idea of leveraging **state policy borders** with crash geocodes is promising, and the dataset could support credible spatial RD designs **if implemented correctly**.

### Key assumptions not adequately handled
- **Continuity at borders:** only asserted informally (“motivate spatial RDD designs”), not defended with balance tests or discussion of border-specific confounds (enforcement, road quality, traffic composition, commuting patterns, tourism corridors, altitude/weather differences).
- **No sorting/manipulation:** drivers can cross borders intentionally; cannabis purchase tourism is exactly the behavior that violates “no sorting.” This is not fatal for RD if interpreted as an *exposure discontinuity* design, but then the estimand must be framed carefully and tested with density checks and mobility proxies.
- **Drug reporting selection:** the paper correctly notes FARS drugs file is “findings not panels,” but then still interprets “THC detected among crashes with drug records” as a meaningful rate and highlights cross-state differences. That selection is plausibly **policy-induced** (legalization → more policing/testing/reporting), which could mechanically generate discontinuities.

### Placebos / robustness
- None executed.
- No robustness to:
  - alternative THC definitions (cannabinoids vs THC text match),
  - alternative snapping distance thresholds (50/100/200m),
  - excluding crashes with large snap distances,
  - border-pair heterogeneity handled formally,
  - multiple hypothesis adjustment for many borders/outcomes.

### Conclusions vs evidence
- The paper is careful in places (“consistent with… though we cannot isolate”), but still uses language implying “visible discontinuities” and “foundation for causal research.” That is fine, but for top journals you must either:
  1) **Do the causal research**, or  
  2) Move to a **data-journal/data-note outlet** and substantially tone down empirical claims.

---

# 4. LITERATURE (missing references + BibTeX)

## Major missing methods references

### Regression Discontinuity (required)
You cite Keele & Titiunik (2015) but omit the canonical RD references and modern robust RD inference.

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
```

```bibtex
@article{LeeLemieux2010,
  author  = {Lee, David S. and Lemieux, Thomas},
  title   = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year    = {2010},
  volume  = {48},
  number  = {2},
  pages   = {281--355}
}
```

```bibtex
@article{McCrary2008,
  author  = {McCrary, Justin},
  title   = {Manipulation of the Running Variable in the Regression Discontinuity Design: A Density Test},
  journal = {Journal of Econometrics},
  year    = {2008},
  volume  = {142},
  number  = {2},
  pages   = {698--714}
}
```

```bibtex
@article{CalonicoCattaneoTitiunik2014,
  author  = {Calonico, Sebastian and Cattaneo, Matias D. and Titiunik, Rocio},
  title   = {Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs},
  journal = {Econometrica},
  year    = {2014},
  volume  = {82},
  number  = {6},
  pages   = {2295--2326}
}
```

**Why relevant:** You explicitly propose border RDD and show RDD-style plots (Appendix Figure 15). A top journal will demand these diagnostics and robust inference as tabled main results.

### Difference-in-Differences (required)
You cite Callaway–Sant’Anna and Sun–Abraham, but you need the modern “what goes wrong with TWFE” canon and inference guidance.

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
```

```bibtex
@article{BorusyakJaravelSpiess2021,
  author  = {Borusyak, Kirill and Jaravel, Xavier and Spiess, Jann},
  title   = {Revisiting Event-Study Designs: Robust and Efficient Estimation},
  journal = {arXiv preprint arXiv:2108.12419},
  year    = {2021}
}
```

```bibtex
@article{Roth2022,
  author  = {Roth, Jonathan},
  title   = {Pretest with Caution: Event-Study Estimates after Testing for Parallel Trends},
  journal = {American Economic Review: Insights},
  year    = {2022},
  volume  = {4},
  number  = {3},
  pages   = {305--322}
}
```

**Why relevant:** You propose DiD applications (Section 8.2) and acknowledge missing years. If you add those years (you should), these are mandatory.

## Missing substantive literature on cannabis legalization and traffic safety

At minimum, you need to engage the public health / policy evidence base that directly studies recreational legalization and traffic outcomes (fatalities, DUI, crash rates), plus measurement issues about THC impairment vs detection.

```bibtex
@article{SantaellaTenorio2017,
  author  = {Santaella-Tenorio, Juliet and Mauro, Christine and Wall, Melanie M. and Kim, Jae Won and Cerd{\'a}, Magdalena and Keyes, Katherine M. and Hasin, Deborah S. and Martins, Silvia S.},
  title   = {US Traffic Fatalities, 1985--2014, and Their Relationship to Medical Marijuana Laws},
  journal = {American Journal of Public Health},
  year    = {2017},
  volume  = {107},
  number  = {2},
  pages   = {336--342}
}
```

```bibtex
@article{Aydelotte2017,
  author  = {Aydelotte, J. Daniel and Brown, Larry H. and Luftman, Kathleen M. and Mardock, Anne L. and Reeves, Matthew J. and Rusch, Emily K. and Ku, Brian S. and Teixeira, Paulo G. and Coopwood, Brooke and Owen, Eli C. and Rusyniak, Daniel E.},
  title   = {Crash Fatality Rates After Recreational Marijuana Legalization in Washington and Colorado},
  journal = {American Journal of Public Health},
  year    = {2017},
  volume  = {107},
  number  = {8},
  pages   = {1329--1331}
}
```

(If you disagree with these exact citations or want economics-only references, you still must cite them because reviewers will know them.)

**Why relevant:** Your headline descriptive claim (THC detection ~20% vs ~10%) is not interpretable without positioning relative to existing evidence and measurement critiques.

## Missing measurement/interpretation references
You need citations about:
- THC pharmacokinetics and impairment vs detection,
- heterogeneity in toxicology testing and reporting in FARS,
- best practices for drug involvement measures in fatal crashes.

Right now Section 7.2–7.3 acknowledges these issues but cites almost nothing.

---

# 5. WRITING QUALITY (CRITICAL)

### a) Prose vs bullets
- Generally acceptable: Intro/Results/Discussion are in paragraphs. Bullets mostly confined to variable definitions and lists.
- However, **the paper reads like a project report**: “pipeline proceeds as follows,” “showcase: zooming in,” many figure walk-throughs. Top journals expect an argument, not a tour.

### b) Narrative flow
- The opening motivation is standard but not compellingly framed for a general-interest audience. The “hook” is generic (“40,000 Americans annually…”).
- The paper’s core contribution is *data*, but the introduction oversells causal potential while under-delivering on executed analysis. This creates a credibility gap.

### c) Sentence quality
- Mostly clear, but often repetitive (“This visualization motivates…”). Many paragraphs start with figure references rather than insight-led topic sentences.

### d) Accessibility
- Good explanations of FARS drug limitations (findings vs panels). This is one of the strongest parts.
- But the estimands are not sharply defined. For example, “THC-positive rate among crashes with drug findings” needs to be foregrounded as a **selected-sample descriptive statistic**, not a proxy for impairment prevalence.

### e) Figures/tables publication quality
- Plots are readable. Map figures need clearer annotation and consistent design language (projection, basemap, border line weight, road overlays).
- Several captions are long but still do not provide what a journal reader needs: **exact sample restrictions, N, unit of observation, and uncertainty**.

---

# 6. CONSTRUCTIVE SUGGESTIONS (HOW TO MAKE THIS TOP-JOURNAL IMPACTFUL)

You have two viable paths; the current hybrid does not work.

## Path A: Make it a real causal economics paper (recommended for AEJ:EP / AER)
1. **Expand to continuous years 2001–2019 (or 2001–2023)**. Your biggest self-inflicted wound is omitting 2006–2015, which contains the key adoption timing (CO/WA 2012; OR/AK 2014–15).
2. Implement **two core designs with full inference**:
   - **Border spatial RD** for 2016–2023 (or 2014–2023 for pioneers) with:
     - CCT robust bias-corrected RD inference,
     - bandwidth sensitivity tables,
     - McCrary density test on crash locations relative to border,
     - covariate continuity checks (weather, road class, time of day, etc.),
     - placebo borders (legal–legal borders; illegal–illegal borders; or “fake borders” shifted geographically),
     - clustering/spatial HAC or randomization inference along border segments.
   - **Staggered DiD/event study** at state level **and** border-county level using Callaway–Sant’Anna / Sun–Abraham / Borusyak–Jaravel–Spiess.
3. Define outcomes that are actually credible:
   - Main: **fatal crash counts per VMT** (or fatalities per VMT) at county-month or border-segment-month level.
   - Secondary: alcohol involvement; drug-record reporting rate (as an endogenous measurement outcome).
4. Address drug testing selection explicitly:
   - Treat “has drug record” as an outcome.
   - Use bounding / sensitivity analysis (e.g., Rosenbaum bounds style logic, or worst/best-case bounds).
   - Consider focusing on **fatal driver** toxicology (more consistently tested) and clearly separate “driver died” vs “driver survived.”
5. Integrate road exposure:
   - OSM road attributes are fine, but for speed limits consider **HPMS** or state DOT sources; OSM speed tags are missing nonrandomly.
6. Reframe contribution:
   - If you want the general-interest payoff, the paper must answer: **Did legalization increase traffic fatalities (or impaired fatal crashes), and by how much?** The atlas should support—not substitute for—that answer.

## Path B: Make it a pure data paper (not a top econ journal fit)
If you want it to remain descriptive/infrastructure:
- Remove causal language (“discontinuities motivate RDD”) from the main claims; keep it as “example applications.”
- Add rigorous **data validation** instead:
  - Geocoding accuracy checks against known locations where possible,
  - snap-distance distribution + sensitivity,
  - crosswalk validation of FARS functional class vs OSM highway type,
  - reproducibility tests (same pipeline, different OSM extraction date),
  - comparison to NHTSA published aggregates to show you reproduce official counts.

Right now you are *implicitly promising causal inference* while delivering neither inference nor validation at the level required.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- The integrated dataset concept is useful: FARS geocodes + OSM road attributes + policy timing.
- The manuscript is unusually transparent about a central limitation: **FARS drugs file reports findings, not testing panels** (Sections 2.1, 7.2).
- The maps demonstrate potential for spatial designs.

### Critical weaknesses
- **No statistical inference** whatsoever; no SEs/CIs/tests. This alone is decisive for top journals.
- Identification is **suggested but not implemented**; RD/DiD requirements are not met.
- Substance measurement is too fragile for the descriptive comparisons highlighted (THC “detected” conflates impairment, testing, reporting).
- Literature positioning is incomplete, with several foundational methods and substantive policy papers missing.
- The paper’s narrative is closer to a repository README + atlas than a journal article.

### Specific high-priority fixes (if resubmitting as economics)
1. Add continuous years and execute staggered DiD and/or RD with full diagnostics and inference.
2. Build credible denominators (VMT) and a clear estimand.
3. Treat drug reporting as endogenous measurement; show robustness.
4. Expand literature and reposition contribution honestly.

---

DECISION: REJECT AND RESUBMIT