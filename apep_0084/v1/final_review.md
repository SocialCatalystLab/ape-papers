# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-29T21:46:19.370880
**Response ID:** resp_08240d3e92c4b38a00697bc66e6e708190a3d96ea54b7ddcb5
**Tokens:** 19541 in / 5855 out
**Response SHA256:** ae7fc8561efd49ea

---

## Referee Report: “The Price of Distance: Cannabis Dispensary Access and the Composition of Fatal Crashes” (Jan 2024)

### Summary
The paper uses FARS fatal-crash microdata (2016–2019) from eight “recreational-illegal” states near western legal markets and constructs a continuous proxy for access to legal recreational cannabis: (log) driving time to the nearest legal dispensary. The main finding is that longer driving time is associated with a higher probability that a fatal crash involves alcohol (β ≈ 0.024 in an LPM with state and year FE), with stronger effects near legal-state borders and null placebos for daytime crashes and elderly-driver involvement. The paper interprets this as evidence of marijuana–alcohol substitution operating through cross-border purchasing spillovers.

The question is important and the “continuous access cost” idea is potentially publishable. However, for a top general-interest journal the current design does not deliver credible causal identification: the access proxy is highly correlated with within-state rurality/road type/enforcement and border-region selection, the measurement of “driving time” is extremely approximate, and the outcome is a *composition conditional on a fatal crash* (raising interpretational and selection concerns). The paper reads like a competent early-stage project but not yet at AER/QJE/JPE/ReStud/Ecta/AEJ:EP standards.

---

# 1. FORMAT CHECK

**Length**
- The PDF excerpt shows **~37 pages total**, with the main narrative reaching **Section 8 on p. 28** and appendices thereafter. That suggests **≥25 pages of main text**. **Pass**.

**References**
- The bibliography is **thin for a top journal** (Anderson et al. 2013; Hansen et al. 2020; a Cato update; a few cannabis-driving review papers; Cameron et al. 2008).
- Missing large parts of: (i) recreational legalization and traffic safety evidence base; (ii) substitution/complementarity literature; (iii) spatial econometrics / spatial inference; (iv) modern DiD/event-study identification and small-cluster inference beyond one bootstrap citation. **Fail for top-journal positioning** (fixable but substantial).

**Prose vs bullets**
- Major sections (Intro, Institutional Background, Conceptual Framework, Data, Empirical Strategy, Results, Discussion/Limitations, Conclusion) are largely in **paragraph form**. There are bullet lists in Data/Institutional sections that are acceptable. **Pass**.

**Section depth**
- Introduction (pp. 1–3): ≥3 substantive paragraphs. **Pass**.
- Background/Data/Empirical Strategy/Results each have multiple paragraphs. **Pass**.

**Figures**
- Figures in Appendix C are maps without conventional x/y axes (maps typically don’t need axes) but they **lack scale bars, clear legends in publication style, and readability** at journal resolution. Figure 3 appears sparse and not very informative visually. For a top journal, these are **not publication-quality**. **Major revisions needed**.

**Tables**
- Tables show real numbers and SEs. **Pass**, but note an internal consistency issue: Table 3 reports binary variables scaled 0–100 (“percentages”), yet regression tables report the dependent variable mean as 0.317. Units should be harmonized.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors
- Regression tables report **SEs in parentheses** (e.g., Table 5). **Pass**.

### (b) Significance testing
- Conventional significance stars are provided and a wild cluster bootstrap p-value is mentioned. **Pass**.

### (c) Confidence intervals
- The paper **does not report 95% confidence intervals** for main estimates (Tables 5–8). Top journals typically expect CIs (and/or coefficient plots). **Fail (fixable)**.

### (d) Sample sizes
- Regressions report **N** and mean DV. **Pass**.

### (e) DiD with staggered adoption
- The main specification is not a standard binary-treatment DiD/TWFE; it is a cross-sectional-with-time FE model using a *continuous access proxy* that changes when NV/CA become available and as “nearest dispensary” changes. So the “TWFE with staggered adoption” critique is not mechanically applicable.
- **However**, the paper implicitly relies on time variation in access induced by legalization/openings in NV/CA, yet it does not implement a design that cleanly separates treated vs never-treated locations with parallel-trends diagnostics. If the paper wants to lean on NV/CA timing as plausibly exogenous shocks, it should use an event-study/DiD framework (and then modern estimators become relevant). As written, the approach is closer to “dose-response with FE,” and the key concern is omitted variables correlated with geography and access.

### (f) RDD
- Not applicable.

### Additional inference concerns (still critical)
1. **Eight clusters only**: Clustering at the **state level with G=8** is very fragile. The paper mentions wild cluster bootstrap (Cameron et al. 2008), which is good, but:
   - It should **systematically report bootstrap p-values** (or randomization-inference style) for key tables, not only mention one in Appendix B.1.
   - It should consider **spatial correlation** (crashes correlated within space, not just within state). Conley (1999)-type SEs or spatial HAC, or at minimum sensitivity to clustering at alternative geographic levels (county, border-segment × year, etc.), is expected.

**Bottom line on methodology:** The paper meets minimal inference requirements (SEs/N/p-values), but **falls short of top-journal standards** because (i) no CIs; (ii) insufficient treatment of spatial correlation and few-cluster inference as a central design feature rather than an appendix note.

---

# 3. IDENTIFICATION STRATEGY

This is the core problem.

### Claimed identification
The paper’s identifying assumption (Section 5.3–5.4) is that conditional on state and year FE, log driving time to nearest dispensary is as-good-as-random with respect to unobserved determinants of alcohol involvement in fatal crashes.

### Why this is not credible as written
1. **Access proxy is a deterministic function of geography** within a state. Within-state geography is strongly related to:
   - rurality/urbanicity,
   - road type (interstate vs rural two-lane),
   - EMS response times (affecting fatality likelihood),
   - enforcement intensity / DUI policing,
   - baseline drinking culture,
   - tourism corridors,
   - weather/mountain driving conditions.
   State FE do **not** address within-state heterogeneity. The paper needs much tighter controls/FE structure.

2. **“Dispensary locations are exogenous to illegal-state crashes” is not sufficient.**
   Even if CO regulators do not choose sites based on WY crashes, dispensaries cluster near:
   - population centers,
   - major highways,
   - border crossings with economic activity.
   Those same features plausibly affect alcohol-involved fatal-crash composition. The paper’s exogeneity argument is therefore incomplete.

3. **Outcome is conditional on a fatal crash (composition).**
   The estimand is \( P(\text{alcohol} \mid \text{fatal crash}) \). This can change even if the *level* of alcohol-impaired driving does not, because:
   - fatality risk differs by road type and speed,
   - marijuana access could change VMT patterns,
   - EMS/survivability differs across space.
   This creates serious interpretational ambiguity and potential selection/collider issues: conditioning on fatal crashes may induce spurious relationships if access correlates with determinants of “fatal given crash.”

4. **Driving time measurement is very coarse.**
   Section 4.3 uses Haversine distance ×1.3 and an assumed 85 km/h to proxy “driving time.” In the Mountain West, topology and road networks make this error non-classical and spatially patterned (mountain passes, sparse highways). That can correlate with alcohol involvement through road risk. The paper asserts “ordering” is what matters, but that is not demonstrated.

### Existing robustness/placebos
- Border-distance heterogeneity and time-of-day heterogeneity are supportive but **not decisive**, because border/rural structure and nightlife patterns also vary with geography.
- Placebos (daytime crashes, elderly driver involvement) are useful but limited: they do not rule out confounding by road type/urbanicity that affects alcohol involvement specifically (e.g., rural high-speed roads might be more associated with alcohol-related fatal crashes than non-alcohol ones).

### What is missing for credibility
At minimum, I would expect:
- **County (or finer) fixed effects** (the paper mentions a county-aggregation robustness, but not a crash-level specification with county FE; the aggregation changes the estimand and can mask confounding).
- Controls/FE for **road type**, **speed limit**, **urban/rural classification**, **interstate proximity**, and **weather** (FARS has many of these).
- A design that uses plausibly exogenous shocks (e.g., **NV 07/2017 and CA 01/2018 openings**) in an **event-study**, with pre-trends checks, rather than relying mainly on cross-sectional geography.
- Stronger falsification tests: e.g., **pre-period placebo using 2010–2013** (before CO/WA retail) with “future dispensary access” predicted by later dispensary locations. If distance-to-future-dispensaries already predicts alcohol involvement pre-legalization, the design is invalid.

**As written, identification is not sufficient for a top field or general-interest outlet.**

---

# 4. LITERATURE (MISSING REFERENCES + BibTeX)

The literature section is underdeveloped. It should (i) clearly distinguish this paper from within-state legalization studies; (ii) engage with cross-border spillovers (taxes, alcohol, cigarettes); (iii) cite modern causal inference tools relevant to spatial exposure and few-cluster settings; (iv) cover more of the cannabis–alcohol substitution and traffic safety literature.

## Key missing methodology citations
```bibtex
@article{Conley1999,
  author  = {Conley, Timothy G.},
  title   = {GMM Estimation with Cross Sectional Dependence},
  journal = {Journal of Econometrics},
  year    = {1999},
  volume  = {92},
  number  = {1},
  pages   = {1--45}
}

@article{CallawaySantAnna2021,
  author  = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title   = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year    = {2021},
  volume  = {225},
  number  = {2},
  pages   = {200--230}
}

@article{GoodmanBacon2021,
  author  = {Goodman-Bacon, Andrew},
  title   = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year    = {2021},
  volume  = {225},
  number  = {2},
  pages   = {254--277}
}

@article{SunAbraham2021,
  author  = {Sun, Liyang and Abraham, Sarah},
  title   = {Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects},
  journal = {Journal of Econometrics},
  year    = {2021},
  volume  = {225},
  number  = {2},
  pages   = {175--199}
}
```
**Why relevant:** Even if the paper is not a canonical DiD, it leans on policy timing (NV/CA openings) and should either (a) adopt event-study tools properly, or (b) explain why it is not needed.

## Missing cannabis policy / traffic safety evidence
```bibtex
@article{Aydelotte2017,
  author  = {Aydelotte, J. David and Mardock, Austin L. and Mancheski, Charles A. and Quamar, Asad and Teixeira, Pablo G. and Brown, C. V. R. and Coopwood, T. Ben},
  title   = {Fatal Crashes in the United States After Recreational Marijuana Legalization},
  journal = {American Journal of Public Health},
  year    = {2017},
  volume  = {107},
  number  = {8},
  pages   = {1329--1331}
}

@article{SantaellaTenorio2017,
  author  = {Santaella-Tenorio, Joanna and Mauro, Christine M. and Wall, Melanie M. and Kim, Junhan and Cerda, Magdalena and Keyes, Katherine M. and Hasin, Deborah S. and Martins, Silvia S.},
  title   = {US Traffic Fatalities, 1985--2014, and Their Relationship to Medical Marijuana Laws},
  journal = {American Journal of Public Health},
  year    = {2017},
  volume  = {107},
  number  = {2},
  pages   = {336--342}
}
```
**Why relevant:** These are prominent public health/econ-adjacent papers on fatal crashes post-cannabis law changes; the paper must position itself relative to these results and discuss differences in design/estimand.

## Missing substitution/complementarity literature (examples)
```bibtex
@article{CrostGuerrero2012,
  author  = {Crost, Benjamin and Guerrero, Santiago},
  title   = {The Effect of Alcohol Availability on Marijuana Use: Evidence from the Minimum Legal Drinking Age},
  journal = {Journal of Health Economics},
  year    = {2012},
  volume  = {31},
  number  = {1},
  pages   = {112--121}
}

@article{PaculaSevigny2014,
  author  = {Pacula, Rosalie Liccardo and Sevigny, Eric L.},
  title   = {Marijuana Liberalization Policies: Why We Can't Learn Much from Policy Still in Motion},
  journal = {Journal of Policy Analysis and Management},
  year    = {2014},
  volume  = {33},
  number  = {1},
  pages   = {212--221}
}
```
**Why relevant:** The substitution mechanism is central; the paper needs to engage with evidence for substitution vs complementarity and measurement/interpretation issues when policy is evolving.

## Cross-border spillovers literature (relevant framing)
Many spillover designs come from cigarette/alcohol tax borders, which are conceptually close to this “distance to legal market” approach. At least cite classic border tax avoidance/spillover work and explain how cannabis differs.

(If the authors want, I can suggest a targeted set once the paper chooses whether it is primarily a “spatial access” paper or a “policy timing” paper.)

---

# 5. WRITING QUALITY (CRITICAL)

**Prose vs bullets**
- Mostly paragraphs in main sections. **Pass**.

**Narrative flow**
- The paper has a clear arc (motivation → access-cost idea → results → placebos). That said, it currently **over-claims credibility** relative to identification strength, and it spends too much space asserting exogeneity rather than *demonstrating* it.
- The most important missing narrative element for a top journal is: **“Why should we believe within-state geography is not the story?”** That requires sharper design and clearer exposition.

**Sentence quality / accessibility**
- Generally readable and non-technical readers can follow.
- But the paper often uses “consistent with” language where a top journal would require either stronger causal design or more careful wording.

**Figures/tables quality**
- Tables are mostly clear; figures are not yet top-journal quality (legend/scale/visual clarity; no coefficient plots; no “first stage” style plots of access vs geography).
- For a top journal, I would expect:
  - coefficient/event-study plots with CIs,
  - maps with scale bars and readable legends,
  - binned scatterplots showing the key relationship with controls/FE residualization.

---

# 6. CONSTRUCTIVE SUGGESTIONS (HOW TO MAKE THIS PUBLISHABLE)

## A. Rebuild the identification around plausibly exogenous shocks
1. **Event study around NV (07/2017) and CA (01/2018) openings**:
   - Define “exposure” as predicted change in nearest-drive-time when NV/CA become available.
   - Compare high-exposure vs low-exposure locations *within the same illegal state*, with **location FE (county/tract/grid-cell)** and **time FE (month-year)**.
   - Show **pre-trends** and dynamic effects.

2. **Pre-period placebo (strongly recommended)**:
   - Use FARS 2010–2013 (or earlier) and compute “future access” using later dispensary locations.
   - Demonstrate that before any relevant retail markets opened, the same access measure does **not** predict alcohol involvement.

## B. Address spatial confounding directly
- Add **county FE** (or finer: census tract / 0.25° grid-cell FE) plus **year-month FE**.
- Control flexibly for **distance to border**, **distance to nearest interstate**, **urbanicity**, **speed limit**, **road functional class**, **weather**, **light conditions**, etc.
- Consider a **border-segment FE** approach: partition the legal/illegal border into segments and compare crashes at varying distances from the *same segment*.

## C. Fix the “composition conditional on fatal crash” problem
Top journals will ask: does marijuana access reduce *alcohol-involved fatal crashes per VMT* (or per population), not just the alcohol share?

- Estimate models for:
  - counts of alcohol-involved fatal crashes by county-month with population/VMT offsets (Poisson/PPML),
  - total fatal crashes,
  - non-alcohol fatal crashes.
- If the key effect is only compositional, you must be explicit about what that does and does not imply.

## D. Improve measurement of “driving time”
- Replace the Haversine×1.3/85 approach with:
  - OSRM / Valhalla routing on OpenStreetMap road networks (open-source, scalable), at least for nearest candidates.
- Sensitivity: show results under alternative routing factors/speeds; demonstrate rank correlation with true route times for a validation subsample.

## E. Inference upgrades
- Report **95% CIs** everywhere for headline estimates.
- Use **spatial HAC (Conley)** or show robustness to:
  - clustering at county,
  - two-way clustering (state × year),
  - randomization inference / wild bootstrap reported systematically.

## F. Clarify institutional inconsistencies
- The paper repeatedly calls AZ/NM/MT etc. “illegal states” but several have medical programs. That is fine if the margin is recreational legality, but the paper should:
  - define “illegal” precisely as “recreational prohibited,”
  - control for **medical access intensity** (medical dispensary density, patient counts, program start dates).

## G. Tone down causal language until design warrants it
- Replace strong causal statements with carefully qualified claims unless and until the event-study / placebo structure is implemented.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important question with policy relevance (spillovers and substitution).
- Creative continuous-treatment concept (“price of distance”).
- Clean descriptive patterns (border attenuation; nighttime stronger; some placebos).

### Critical weaknesses (top-journal blocking)
1. **Identification is not credible** with only state/year FE given strong within-state geographic confounding.
2. **Outcome is conditional on fatal crashes**, making interpretation and welfare conclusions tenuous without level/rate analyses.
3. **Exposure measurement is too approximate** and potentially spatially non-classical.
4. Literature positioning and inference presentation (CIs, spatial correlation) are below top-journal expectations.

### Specific highest-priority revisions
1. Implement an **event-study / exposure-shock design** around NV/CA openings with strong pre-trends/placebos.
2. Add **fine geographic FE** + rich road/urban controls and spatial inference.
3. Estimate **levels/rates** (counts per population/VMT) in addition to composition.

---

DECISION: REJECT AND RESUBMIT