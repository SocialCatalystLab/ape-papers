# GPT 5.2 Review - Reviewer 1/3 (Parallel)

**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Reasoning effort:** medium
**Timestamp:** 2026-01-29T21:41:05.124389
**Review mode:** Parallel (3 independent reviewers)
**Response ID:** resp_0a74adec9aada07e00697bc5285cb0819780141b8417f017ec
**Tokens:** 19541 in / 6543 out
**Response SHA256:** a7f41ed4768b3a78

---

## 1. FORMAT CHECK

**Length**
- The document runs to **~37 pages including appendices/references** (page numbers shown up to 37). The **main text appears to be ~28–29 pages** (through the conclusion on p. 28), meeting the “≥25 pages excluding references/appendix” bar.

**References**
- The bibliography is **not adequate for a top general-interest journal**. It is short and omits (i) key econometric inference/spatial methods relevant here, (ii) key border-design/cross-border spillover references, and (iii) a sizable portion of the cannabis–alcohol substitution and traffic-safety empirical literature (see Section 4 below for concrete additions with BibTeX).

**Prose vs bullets**
- Introduction and Results are mostly paragraphs, but several major sections rely heavily on **bullet/numbered lists** (e.g., Institutional Background; Conceptual Framework “Testable Predictions”; “Threats”/“Robustness” lists).
- Bullets are fine for variable definitions and robustness inventories, but for AER/QJE/JPE/ReStud/Ecta/AEJ:EP the **main conceptual argument and contribution framing should be written as paragraph prose**, not as a sequence of hypotheses and confounds in list form.

**Section depth (3+ substantive paragraphs each)**
- **Introduction (pp. 1–3):** yes (multiple paragraphs).
- **Institutional Background (pp. 3–7):** largely yes, though some parts read like a report.
- **Conceptual Framework (pp. 7–10):** borderline—there is a model and then many lists; needs more narrative development.
- **Data (pp. 10–15):** yes, though some parts are overly operational.
- **Empirical Strategy (pp. 15–19):** yes.
- **Results (pp. 20–27):** yes.
- **Discussion/Limitations (pp. 25–27):** yes, but still reads like a technical report rather than journal-ready synthesis.

**Figures**
- Figures are primarily **maps** (Figures 1–3, pp. 35–37). They appear to have legends, but maps **lack standard “axes”**; that can be acceptable, yet they should include at minimum: **scale bars, clearer legends, and higher-resolution labeling**. Figure 3’s informational content is limited (dots and triangles without a clear quantitative takeaway).
- For top outlets, you need at least one **core “result figure”** (e.g., binned scatter/partial residual plot; distance-band event-study-style gradient; coefficient plot across specifications/bands), not just maps.

**Tables**
- Tables contain real numbers and SEs; **no placeholders**.
- However, some presentation is confusing: Table 3 reports binary means as “31.7” and SD as “46.5” with a note about scaling to percentage points. Top journals typically present binary outcomes as **0.317 with SD 0.465**, or clearly label “percent.”

---

## 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors
- **PASS** mechanically: the main regression tables report **SEs in parentheses** (e.g., Table 5).

### (b) Significance testing
- **PASS** mechanically: stars and t-based inference are used; a wild cluster bootstrap p-value is reported (Appendix B.1).

### (c) Confidence intervals
- **FAIL for top-journal standards**: the main results do **not report 95% confidence intervals** (neither in tables nor in text). This is easily fixable but required.

### (d) Sample sizes
- **PASS**: N is reported for regressions.

### (e) DiD with staggered adoption
- Not a canonical staggered-adoption DiD with a treated group turning on and TWFE; the paper uses **continuous “access cost”** with state and time FE. So the specific “TWFE staggered adoption” failure mode is not directly triggered.
- That said, your identifying variation **does include time breaks** from NV (2017) and CA (2018) being added to the choice set. If you want to claim causal time-series evidence, you should implement something closer to a **design-based DiD/event-study** around those openings for locations whose nearest dispensary changes because of them (see suggestions below).

### (f) RDD requirements
- Not applicable (you do not run an RDD). However, given the geography, an RDD/border discontinuity is a natural alternative and you should discuss why you do not use it.

### Inference adequacy (biggest statistical concern)
Even though you report clustered SEs and a wild bootstrap, the inference is **not yet credible for a top journal** because:
1. You cluster at **state** with **G=8 clusters**, and then rely on t(7) and an appendix bootstrap p-value. This is thin protection in a spatial setting where the regressor is essentially geography.
2. The main regressor varies **within state across space**, so the natural dependence structure is **spatial**, not purely within-state arbitrary correlation. A top-journal referee will expect **spatial HAC (Conley)** or a clear justification (plus robustness) using **multiway clustering** (e.g., by state×year and by border segment) or more granular clusters (county, commuting zone), with appropriate small-cluster corrections if needed.
3. The outcome uses **NHTSA alcohol imputation (DRUNK_DR)** which itself is a statistical model; your SEs treat the imputed outcome as observed. At minimum, you need sensitivity checks using (i) only tested BAC subsamples, (ii) alternative alcohol involvement definitions, and (iii) explicit discussion of generated-regressor/-outcome issues.

**Bottom line:** the paper does not “fail” because it lacks SEs, but it **does fail the “proper inference” bar for a top outlet** as currently executed. You need CIs, spatial dependence-robust inference, and serious sensitivity to outcome imputation.

---

## 3. IDENTIFICATION STRATEGY

### What you claim
You estimate (Eq. 3, p. 16):
\[
AlcoholInvolved_{ist}=\beta \log(DriveTime_{ist}) + \alpha_s + \delta_t + \varepsilon_{ist}.
\]
and interpret \(\beta>0\) as evidence that nearer legal cannabis access reduces alcohol-involved fatal crash share via substitution.

### Core identification problem: geography is not quasi-random here
The key identifying assumption (p. 18) is that conditional on state and year, distance to dispensaries is uncorrelated with unobserved determinants of alcohol-involved fatal crashes. This is **not credible** without much more structure because **drive time is a proxy for remoteness and rurality**:
- Rural areas have different:
  - alcohol culture and binge drinking prevalence,
  - enforcement intensity and EMS response times,
  - road types/speeds,
  - nighttime driving patterns,
  - seatbelt use,
  - vehicle mix (pickups, motorcycles),
  - VMT per capita,
  - poverty and labor-market composition.
Many of these are plausibly correlated with “how far from a major border metro / interstate corridor” a crash occurs, which is strongly correlated with your drive-time measure.

State FE do not solve this, because the confounding is **within-state spatial**.

### Conditioning on “fatal crash occurred” makes composition hard to interpret
Your outcome is the share of fatal crashes involving alcohol (p. 11). This is a **selected sample**: fatal crashes are not random, and the determinants of fatality conditional on crashing are strongly related to rurality (speed, EMS response time, seatbelt use). If nearer-to-border areas are more urban (slower speeds, quicker EMS), then *conditional on being fatal*, the composition could mechanically differ even with no substitution. Your placebo outcomes (daytime, elderly; Table 6) are not sufficient to rule this out.

A top journal will ask for **levels/rates**, not just conditional shares:
- alcohol-involved fatal crashes per population or per VMT,
- total fatal crashes per population or per VMT,
- non-alcohol fatal crashes per population or per VMT,
to show the composition effect is not an artifact of denominator changes.

### Treatment measurement is coarse and possibly systematically biased
Drive time is constructed from straight-line distance × 1.3 divided by constant speed (pp. 12–13). This will generate **systematic measurement error correlated with geography** (mountains, road network sparseness, winter closures)—exactly the same geography that affects crash severity and alcohol involvement patterns. This is not “classical attenuation” in any obvious way.

### Placebos and heterogeneity are suggestive but not dispositive
- Border-gradient attenuation (Table 7) is consistent with your story, but also consistent with “border counties are different” and “remote interior is different.” You need designs that compare **like with like** near borders (e.g., narrow bandwidths around borders; matched segments; border-pair FE).
- Daytime placebo is helpful but not strong: rural/urban differences can be larger at night, and many confounds (speeding, EMS delays) are also more salient at night.

### Conclusion vs evidence
You sometimes phrase results as “marijuana legalization reduces…” (e.g., Abstract; Conclusion). Given your design, a more accurate claim is: **“areas in prohibition states closer to legal dispensaries have a lower alcohol-involved share among fatal crashes.”** Causal substitution requires substantially stronger identification and mechanisms.

---

## 4. LITERATURE (missing references + BibTeX)

Your references (p. 29–30) are too thin for a top general-interest journal. You should add:

### (A) Spatial inference / clustering / small-G
Why relevant: your regressor is geographic; dependence is spatial; and you have only 8 state clusters.

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

@article{CameronMiller2015,
  author = {Cameron, A. Colin and Miller, Douglas L.},
  title = {A Practitioner’s Guide to Cluster-Robust Inference},
  journal = {Journal of Human Resources},
  year = {2015},
  volume = {50},
  number = {2},
  pages = {317--372}
}

@article{MacKinnonWebb2017,
  author = {MacKinnon, James G. and Webb, Matthew D.},
  title = {Wild Bootstrap Inference for Wildly Different Cluster Sizes},
  journal = {Journal of Applied Econometrics},
  year = {2017},
  volume = {32},
  number = {2},
  pages = {233--254}
}
```

### (B) Border discontinuity / cross-border policy evaluation
Why relevant: your mechanism is explicitly cross-border shopping/spillovers; the canonical approach uses border-pair comparisons.

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

### (C) Modern DiD/event-study methods (if you lean on NV/CA openings)
Why relevant: you discuss staggered openings (NV 2017, CA 2018). If you present designs around these, you should cite the modern toolkit.

```bibtex
@article{CallawaySantanna2021,
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

### (D) Cannabis/alcohol substitution and traffic safety (broaden substantially)
You cite Anderson et al. (2013) and Hansen et al. (2020) but omit much related empirical work in econ/public health. At minimum you need to engage and distinguish from:
- papers on cannabis legalization and alcohol sales/consumption,
- papers on cannabis and crash outcomes beyond FARS,
- polysubstance use and enforcement interactions.

(You should add several domain citations; I’m not providing a long BibTeX block here because you’ll want to choose the most directly comparable set, but the current list is not sufficient.)

---

## 5. WRITING QUALITY (CRITICAL)

### (a) Prose vs bullets
- **Does not meet top-journal writing standards yet.** Too many sections read like a technical report: enumerated hypotheses (H1–H4), enumerated confounds, enumerated robustness. For AER/QJE/JPE/ReStud/Ecta, the reader expects a **narrative argument** with signposting, not lists.

### (b) Narrative flow
- The motivating question is clear and policy-relevant, but the paper does not sufficiently grapple upfront with the biggest objection: **distance to dispensaries is distance to urban/border areas**. This should be confronted in the introduction with a clear preview of *design-based* solutions, not only controls/FE and suggestive heterogeneity.

### (c) Sentence/paragraph quality
- Generally readable, but often “report-like”: long blocks of institutional detail and mechanical descriptions (e.g., the drive-time construction) without connecting back to identification threats and estimands.
- Several claims are stronger than warranted (e.g., substitution “supported” rather than “consistent with”).

### (d) Accessibility
- Good on institutional timing.
- Weak on econometric intuition for why the remaining within-state spatial variation is plausibly exogenous.

### (e) Figures/Tables
- Tables are mostly fine, but you need:
  - coefficient plots with CIs,
  - a visualization of the identifying variation (within-state gradients, within-county time shifts from CA/NV entry),
  - and clearer figure takeaways than maps.

---

## 6. CONSTRUCTIVE SUGGESTIONS (to make it publishable)

### A. Fix the estimand: move from “composition among fatal crashes” to rates
1. Construct outcomes at a geographic unit (county, tract, grid cell):
   - alcohol-involved fatal crashes per population (or per VMT if available),
   - total fatal crashes per population,
   - non-alcohol fatal crashes per population.
2. Estimate Poisson/PPML with exposure offsets, plus FE. This directly addresses the denominator problem and selection into “fatal.”

### B. Use a border design (your setting screams for it)
1. **Contiguous-county border-pair FE** (à la Dube–Lester–Reich; Holmes):
   - Compare counties in illegal states bordering legal states to adjacent legal-side counties, with border-segment FE and distance-to-nearest-dispensary on the legal side.
   - Alternatively, within illegal states only: compare counties close to the border along the same corridor versus slightly farther, with flexible border-segment controls.
2. Implement narrow bandwidth analyses (e.g., within 50km, 25km) with flexible controls for distance to border *and* distance to nearest metro.

### C. Exploit time variation credibly (NV/CA openings)
Right now, most “within-county” drive time is fixed, so your design is mostly cross-sectional geography. A stronger approach:
- Define “exposure shocks” when NV opens in 2017 and CA opens in 2018 for locations whose nearest dispensary changes materially.
- Run an event-study/DID around those openings for affected vs unaffected areas, using Callaway–Sant’Anna/Sun–Abraham style estimators if treatment is discretized, or continuous-treatment event-study methods.

### D. Repair treatment measurement
- Replace the 1.3×Haversine/constant-speed proxy with actual routing using OSRM/OpenRouteService (open-source) for the **nearest dispensary only** (compute nearest by Haversine first, then route to top-k candidates). This is computationally feasible and eliminates a major credibility issue.
- Incorporate dispensary opening dates more carefully for CO/WA/OR (you currently assume most are open by 12/2015; that may be okay, but top journals will want a better-documented, date-stamped panel if timing matters).

### E. Address DRUNK_DR imputation concerns
- Replicate main results using:
  - tested BAC subsample only (with selection discussion),
  - alternative alcohol indicators (BAC≥0.08; police-reported impairment),
  - bounds/sensitivity analyses.
- Discuss that DRUNK_DR is a generated outcome and what that implies for inference.

### F. Inference upgrades
- Report **95% CIs everywhere** for main coefficients and key implied effects (e.g., doubling time).
- Add **Conley (spatial HAC)** SEs and/or robust checks with different spatial cutoffs.
- Present wild bootstrap p-values in the **main tables**, not only in the appendix.

### G. Mechanism validation (important for a general-interest journal)
- Bring in at least one direct mechanism proxy:
  - border dispensary sales (where public),
  - SafeGraph/Veraset mobility trips to dispensary tracts,
  - DUI arrests, alcohol sales, or ER alcohol admissions near borders.
Even one compelling mechanism validation would greatly strengthen the causal story.

---

## 7. OVERALL ASSESSMENT

**Key strengths**
- Novel question and potentially important externality channel: cross-border cannabis access affecting alcohol-impaired driving in prohibition states.
- Clear construction of a continuous “access cost” measure and a well-motivated substitution hypothesis.
- Some good suggestive patterns: stronger near borders; nighttime vs daytime differences.

**Critical weaknesses**
1. **Identification is not credible** as written: distance-to-dispensary is strongly entangled with within-state rurality/urbanity, border economics, road environment, EMS response, and enforcement—none convincingly addressed with the current FE structure.
2. **Outcome/estimand problem**: conditioning on fatal crashes and focusing on the alcohol-involved share creates serious selection/denominator issues; the welfare interpretation is not identified.
3. **Inference is not top-journal ready**: 8 state clusters in a spatial setting, no spatial HAC, no CIs, and insufficient treatment of imputed alcohol outcomes.
4. **Literature is incomplete**, missing core methods and border-spillover foundations.

**Specific improvements**
- Rebuild around a border design + rates (not shares) + routing-based treatment + spatial inference + mechanism validation. That package could become a credible AEJ:EP paper and potentially more, depending on strength of effects and mechanism evidence.

DECISION: REJECT AND RESUBMIT