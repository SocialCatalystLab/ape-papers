# GPT 5.2 Review - Reviewer 2/3 (Parallel)

**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** medium
**Timestamp:** 2026-01-29T21:41:05.126644
**Review mode:** Parallel (3 independent reviewers)
**Response ID:** resp_07398bba8177b2d000697bc5287c2c81a1ab2f41a80e23be5c
**Tokens:** 19541 in / 6267 out
**Response SHA256:** 960baa884cf3fae1

---

## Referee Report (General-Interest / AEJ:EP Standard)

### Summary
The paper asks whether proximity to legal recreational cannabis dispensaries in neighboring states reduces the **share of fatal crashes involving alcohol** in “illegal” (recreational-prohibition) states, consistent with marijuana–alcohol substitution. Using FARS fatal-crash microdata (2016–2019) for eight states and a continuous treatment (log driving time to nearest dispensary), the headline estimate is that a 1-unit increase in log drive time raises the probability a fatal crash involves alcohol by **2.4 pp** (baseline 31.7%), with stronger effects near borders and null placebos.

The question is important and the “continuous access cost” idea is potentially publishable. However, at a top journal bar, the current design is **not yet credibly identified**, the measurement of “driving time” is too approximate, inference and presentation are incomplete for main claims (notably lack of 95% CIs), and the paper is severely under-positioned in the literature (very thin references for both substance substitution and spatial/border empirical strategies). Substantial rethinking and additional analyses are needed.

---

# 1. FORMAT CHECK

### Length
- The PDF appears to run to **~37 pages including appendices and figures**, with the main text ending around p. 28 (Conclusion) and references around pp. 29–30. That likely clears the “25 pages excluding references/appendix” threshold **only narrowly**. If the journal counts strictly (main text only), you are around the cutoff.

### References
- **Not adequate.** The bibliography is extremely sparse for a top journal paper in this area (only a handful of citations). It omits key work on:
  - cannabis legalization and traffic safety (beyond the one Econ Inquiry paper),
  - marijuana–alcohol substitution (many papers),
  - border/spatial designs and threats,
  - inference with few clusters and spatial correlation,
  - modern causal DiD (relevant if you lean on staggered openings of CA/NV or market expansion).

### Prose vs bullets
- The paper is mostly paragraph prose in Intro/Results/Discussion, but there are many bullet lists in core exposition sections (e.g., Institutional Background, Data, Conceptual Framework—pp. ~4–13). Bullet lists are fine for variable definitions, but here they often substitute for narrative development.

### Section depth
- Introduction (pp. ~1–3): yes, multiple paragraphs.
- Institutional Background (pp. ~4–7): yes.
- Conceptual Framework (pp. ~8–10): borderline; much is list-like.
- Data/Empirics (pp. ~11–19): yes, but heavy list formatting.
- Results (pp. ~20–27): yes.
- Discussion/Limitations (pp. ~25–27): yes.

### Figures
- Figures are maps; they do not have axes in the usual sense, but should have:
  - scalebars, north arrows, coordinate grid ticks, and clear legend/units.
- Figure 3 (border crashes) is visually plausible but the plotted geometry is hard to interpret (no scale; unclear extent). For a top journal, these are **not publication-quality** as currently rendered.

### Tables
- Tables contain real numbers and SEs; no placeholders. This is good.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard Errors
- Pass for the regression tables shown: coefficients have **clustered SEs in parentheses** (Tables 5–10).

### (b) Significance testing
- Pass mechanically (stars, clustered SEs; bootstrap p-value reported for the main effect).

### (c) Confidence intervals
- **Fail.** A top journal would expect **95% confidence intervals** for the main specification(s) and key heterogeneity estimates, ideally in both tables and a coefficient plot. Reporting only stars and a single bootstrap p-value is not enough.

### (d) Sample sizes
- Pass: N is reported in the regression tables.

### (e) DiD with staggered adoption
- The design is *not* a standard DiD of legalization because the sample excludes legalizing states and uses continuous proximity. However:
  - You explicitly exploit **staggered opening of NV (2017) and CA (2018)** in the treatment construction (Section 4.2) and discuss “panel variation.”
  - Yet the regression is essentially cross-sectional with state/year FE, and identification appears to come mostly from **cross-sectional geographic differences** in distance within state, not from quasi-experimental timing.
  - If you pivot toward a timing-based interpretation (CA/NV openings), you will need modern staggered-adoption methods and diagnostics. As written, you are not doing TWFE DiD, so I would not label this as a “TWFE staggered adoption fail,” but the paper is currently **vulnerable to the critique that it implicitly leans on time variation without properly identifying it**.

### (f) RDD
- Not used. But note: your border-focused results and mechanism strongly suggest a **border RDD / geographic RD** could be a natural design; if you pursue it, you must implement RD best practices (bandwidth sensitivity, density tests, covariate balance, donut RD, etc.).

### Inference concerns not addressed
- **Few clusters (8 states):** you do a wild cluster bootstrap (good), but top journals often expect:
  - reporting bootstrap-based CIs,
  - sensitivity to alternative clustering (e.g., by county, by border segment), and
  - discussion of the fact that “state clustering” with only 8 clusters is fragile.
- **Spatial correlation:** crashes and unobservables are spatially correlated. State clustering may not address spatial dependence well. Consider **Conley (spatial HAC)** or at least robustness to spatially aggregated units.

**Bottom line on methodology:** the paper is *not unpublishable due to missing SEs*, but it is **not publishable at a top journal standard** because inference and uncertainty communication (CIs; spatial dependence) are incomplete, and the estimand/design are not yet convincingly causal.

---

# 3. IDENTIFICATION STRATEGY

### Core identifying assumption (Section 5.3–5.4)
You assume that conditional on state and year FE, log drive time to the nearest dispensary is as-good-as-random with respect to unobserved determinants of alcohol involvement in fatal crashes.

This is **not credible** as currently defended.

#### Main threats (insufficiently handled)
1. **Within-state rurality / road type / enforcement gradients correlated with distance-to-border**
   - Distance to a dispensary is tightly linked to being near a border corridor, interstate highways, and particular economic/geographic regions. These regions differ systematically in:
     - road design and speeds (fatal crash composition changes),
     - policing and testing/imputation patterns (affecting DRUNK_DR),
     - bar density and alcohol access, and
     - demographics (age, income, tribal lands, etc.).
   - State FE do **not** address within-state confounding. The paper acknowledges urban–rural differences (Section 3.5; 5.4) but does not solve them.

2. **Crash location ≠ driver residence**
   - Treatment is constructed at the **crash GPS location**, but the behavioral margin is about where people live (and shop). You mention this (Limitations), but the implications are deeper:
     - Measurement error is not obviously classical. Long-distance travelers (freight, tourism) crash on interstates; those corridors may also be systematically closer/farther to dispensaries.
     - Border areas have more cross-border travel of many types.

3. **Treatment measurement is very coarse**
   - “Driving time” is approximated as: haversine × 1.3 ÷ 85 km/h (Section 4.3).
   - This may severely mis-measure access in mountainous regions and along sparse road networks—precisely where many of your states are.
   - If mismeasurement is spatially structured (not classical), it can bias estimates in unknown directions.

4. **Dispensary data timing and completeness**
   - You use a curated OSM sample and partially treat early states as “always on,” conceding look-ahead measurement error (Section 4.2).
   - For top-journal credibility, you need a dispensary panel with opening dates or at least a demonstrably stable subset (and show results robust to restricting to dispensaries verified open pre-2016).

5. **Outcome construction and imputation**
   - DRUNK_DR uses NHTSA imputation. If imputation models incorporate covariates correlated with geography (rurality, survival, testing regimes), and if those covariates correlate with distance to borders/dispensaries, you can generate spurious spatial patterns.
   - You need sensitivity using **observed BAC/tested-only** subsamples and/or alternative FARS alcohol indicators.

6. **Composition estimand is hard to interpret**
   - You estimate Pr(alcohol involved | fatal crash). Even if causal, this does not identify whether alcohol-involved fatal crashes fell in levels.
   - A mechanism like increased marijuana tourism could raise non-alcohol fatal crashes, mechanically lowering the alcohol share even if alcohol crashes did not fall.

### Current robustness/placebos are not sufficient
- “Daytime crashes” placebo is weak because daytime crash composition differs in many ways unrelated to intoxication; it’s not a clean falsification.
- “Elderly driver involvement” is also weak because elderly crash risk is related to rural roads, daylight driving, and region type—again correlated with your treatment.
- Border-distance heterogeneity (Table 7) is suggestive but not dispositive; border areas differ on many dimensions.

### What would make identification credible?
You likely need to move toward one of these designs:

1. **Geographic RD / border discontinuity**:
   - Compare locations just inside illegal states vs just inside legal states (or just inside illegal states but varying closeness to border dispensaries), using flexible controls for distance to border and local geography.
   - Implement modern RD toolkit: bandwidth sensitivity, donut, covariate balance, manipulation/density checks (for running variable), and clear mapping from running variable to treatment.

2. **Event study / DiD around openings of CA/NV (and possibly dispensary expansions)**
   - Use counties (or grid cells) in illegal states as units; exploit that CA retail begins 2018 and NV 2017, changing the nearest-legal option for some areas but not others.
   - You must define “treated” areas whose nearest legal market changes, and use never-treated (or not-yet-treated) areas carefully with modern estimators.

3. **Instrumental-variables style exposure**
   - E.g., predicted dispensary access based on legal-state regulatory rules and pre-period road network, not on endogenous or post outcomes.

As written, the identification is **too correlational** for AER/QJE/JPE/ReStud/Ecta/AEJ:EP.

---

# 4. LITERATURE (Missing references + BibTeX)

The literature section is currently far below the bar. You need to cite (i) traffic safety & cannabis policy evidence, (ii) marijuana–alcohol substitution evidence, (iii) spatial/border methods and threats, (iv) inference with few clusters/spatial correlation, and (v) (if you lean into timing) staggered-adoption DiD.

Below are specific must-add references with BibTeX.

### (A) Staggered adoption / DiD diagnostics (if you use timing variation)
```bibtex
@article{CallawaySantAnna2021,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  number = {2},
  pages = {200--230}
}

@article{GoodmanBacon2021,
  author = {Goodman-Bacon, Andrew},
  title = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  number = {2},
  pages = {254--277}
}

@article{SunAbraham2021,
  author = {Sun, Liyang and Abraham, Sarah},
  title = {Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects},
  journal = {Journal of Econometrics},
  year = {2021},
  volume = {225},
  number = {2},
  pages = {175--199}
}
```

### (B) Few clusters and robust inference
```bibtex
@article{CameronMiller2015,
  author = {Cameron, A. Colin and Miller, Douglas L.},
  title = {A Practitioner's Guide to Cluster-Robust Inference},
  journal = {Journal of Human Resources},
  year = {2015},
  volume = {50},
  number = {2},
  pages = {317--372}
}
```

### (C) Spatial correlation / Conley SEs
```bibtex
@article{Conley1999,
  author = {Conley, Timothy G.},
  title = {GMM Estimation with Cross Sectional Dependence},
  journal = {Journal of Econometrics},
  year = {1999},
  volume = {92},
  number = {1},
  pages = {1--45}
}
```

### (D) Border designs / spatial RD guidance (if you pursue border discontinuity)
```bibtex
@article{KeeleTitiunik2015,
  author = {Keele, Luke and Titiunik, Roc{\'i}o},
  title = {Geographic Boundaries as Regression Discontinuities},
  journal = {Political Analysis},
  year = {2015},
  volume = {23},
  number = {1},
  pages = {127--155}
}
```

### (E) Cannabis laws and traffic fatalities (policy literature you should engage)
A non-exhaustive set; you should add and discuss how your approach differs.
```bibtex
@article{SantaellaTenorio2017,
  author = {Santaella-Tenorio, Julia and Mauro, Christine M. and Wall, Melanie M. and Kim, Jun and Cerd{\'a}, Magdalena and Keyes, Katherine M. and Hasin, Deborah S. and Martins, Silvia S.},
  title = {US Traffic Fatalities, 1985--2014, and Their Relationship to Medical Marijuana Laws},
  journal = {American Journal of Public Health},
  year = {2017},
  volume = {107},
  number = {2},
  pages = {336--342}
}
```

### (F) Marijuana–alcohol substitution (beyond Anderson et al.)
You need to cover a broader set of evidence on substitution/complementarity and consumption responses.
```bibtex
@article{CrostGuerrero2012,
  author = {Crost, Benjamin and Guerrero, Santiago},
  title = {The Effect of Alcohol Availability on Marijuana Use: Evidence from the Minimum Legal Drinking Age},
  journal = {Journal of Health Economics},
  year = {2012},
  volume = {31},
  number = {1},
  pages = {112--121}
}
```

### (G) Cross-border spillovers literature (to properly frame “spillovers”)
```bibtex
@article{DubeLesterReich2010,
  author = {Dube, Arindrajit and Lester, T. William and Reich, Michael},
  title = {Minimum Wage Effects Across State Borders: Estimates Using Contiguous Counties},
  journal = {Review of Economics and Statistics},
  year = {2010},
  volume = {92},
  number = {4},
  pages = {945--964}
}

@article{Holmes1998,
  author = {Holmes, Thomas J.},
  title = {The Effect of State Policies on the Location of Manufacturing: Evidence from State Borders},
  journal = {Journal of Political Economy},
  year = {1998},
  volume = {106},
  number = {4},
  pages = {667--705}
}
```

You should also add and engage seriously with the broader cannabis policy economics literature (Pacula and coauthors; pricing/taxes; retail rollout; local bans) and the traffic safety economics literature (alcohol taxes, MLDA, DUI enforcement, ride-sharing).

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets
- **Borderline fail for a top journal.** While the Introduction and Results are mostly paragraph-based, large portions of Institutional Background, Conceptual Framework, and Data rely on bullet lists where the paper should instead provide integrated narrative and clearer argumentation (pp. ~4–13).
- Top general-interest outlets expect fewer “report-style” enumerations and more tightly argued prose.

### Narrative flow
- The intro has a clear motivation and states a main result early (good).
- But the paper’s arc is not yet compelling because identification is not nailed down; as a result, the narrative reads like: “distance correlates with alcohol involvement” rather than “we identify a causal substitution channel.”

### Sentence-level quality and accessibility
- Generally readable, but there is excess repetition (many sections restate the same coefficient interpretation).
- Some internal inconsistencies/ambiguities:
  - The conceptual model uses **round-trip time** but the constructed variable is **one-way time** (Section 3.1 vs 4.3). This is not a trivial mismatch for interpretation.
  - The paper sometimes claims “panel variation” but the treatment is largely time-invariant for many locations absent CA/NV timing or dispensary openings.

### Figures/Tables quality
- Tables are mostly fine.
- Figures are not yet at publication quality (legibility, scale, interpretability).

---

# 6. CONSTRUCTIVE SUGGESTIONS (What to do to reach AEJ:EP / top-5 readiness)

## A. Redesign identification around quasi-experimental variation
1. **Leverage CA (2018) and NV (2017) openings as shocks**
   - Define exposure: counties/grid cells in illegal states for which the *nearest legal market* changes discontinuously at those dates.
   - Estimate an event-study / DiD on **levels** (counts/rates) of alcohol-involved fatal crashes, not just shares.
   - Use modern staggered estimators if treatment timing differs across units.

2. **Border discontinuity / spatial RD**
   - Implement a geographic RD around borders where dispensaries are plausibly “accessible,” focusing on narrow bandwidths and controlling flexibly for distance-to-border and road network.
   - This would directly address your strongest mechanism claim (“effects concentrated within 50–100 km of borders”).

## B. Improve measurement of “access”
- Replace haversine×1.3÷speed with **actual routing times** (OSRM, OpenRouteService, Valhalla, or Google if feasible) at least for:
  - nearest-dispensary candidate set (pre-filter by haversine, then route top K),
  - robustness subsamples (border regions).
- Build a **dispensary panel** with opening dates (state licensing records, archival snapshots) or restrict to dispensaries verified open by 2016 to avoid look-ahead.

## C. Move from “composition” to “levels” and welfare-relevant outcomes
- Estimate:
  - counts/rates of alcohol-involved fatal crashes (Poisson/negative binomial with exposure),
  - total fatal crashes,
  - non-alcohol fatal crashes,
  - and ideally VMT-adjusted rates (even if imperfect).
- The composition result alone cannot support welfare claims.

## D. Address outcome validity and imputation concerns
- Replicate using:
  - tested-only BAC measures,
  - alternative alcohol-involvement indicators,
  - and show robustness to excluding states/years with low testing rates.
- Explain precisely what DRUNK_DR is, how imputation might vary geographically, and why this does not mechanically induce your pattern.

## E. Strengthen falsification tests
Better placebos/outcomes that are plausibly orthogonal to cannabis access:
- weather-related crash indicators,
- seatbelt usage,
- pedestrian involvement,
- commercial truck involvement,
- daytime *single-vehicle* crashes vs multi-vehicle (or other structure),
- outcomes for which substitution mechanism has no reason to operate.

## F. Reframe contribution relative to prior work
- Right now the paper claims novelty (“continuous treatment within illegal states”), but many related designs exist in border-spillover and access-cost contexts. You need to:
  - articulate precisely what is identified that prior legalization DiDs do not,
  - show that your design is not simply picking up “border region differences.”

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important policy question; plausible behavioral mechanism.
- Creative idea: continuous “price of distance” treatment.
- Uses high-quality fatal crash census data.
- Attempts to grapple with few-cluster inference via wild bootstrap.

### Critical weaknesses (publication blockers)
1. **Identification is not credible** under the stated assumption; within-state geography correlated with many determinants of alcohol involvement.
2. **Treatment measurement is crude** and likely spatially structured.
3. **Outcome and estimand limitations** (share among fatal crashes) prevent strong claims about safety/welfare.
4. **Literature coverage is far below standard**; missing major strands and methods.
5. **Presentation**: missing 95% CIs; figures not publication-ready; too report-like in key sections.

---

DECISION: REJECT AND RESUBMIT