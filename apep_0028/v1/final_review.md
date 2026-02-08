# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-18T19:41:09.141307
**Response ID:** resp_0359ab1d2bd768d100696d2876f3548190a60b4c4e336b4cdc
**Tokens:** 15874 in / 8294 out
**Response SHA256:** c3908773aa32bfd0

---

## Referee Report (Top-5 Economics Journal)

### Summary
The paper evaluates Montana’s 2023 statewide zoning reforms (ADU legalization + duplex legalization in larger cities) using state-level monthly building permits (BPS), implementing (i) TWFE DiD with five “Mountain West” controls and (ii) synthetic control with a 47-state donor pool. The TWFE estimate is positive but imprecise; SCM yields essentially zero; the event study shows concerning pre-trends. The authors ultimately conclude identification is not credible with available data and advocate for place-level designs.

That conclusion is largely correct—but it is also the core problem for publication in a top journal: the current design is not capable of learning the policy effect on the relevant margins (ADUs/duplexes) with credible identification. The paper is transparent and careful, but as executed it is closer to a policy memo or “null / cannot-identify” note than an AER/QJE/Ecta contribution.

---

# 1. FORMAT CHECK

**Length**
- Appears to be ~36 pages including appendix figures (Appendix begins around p. 35; references around p. 32). Main text from Introduction (p. 4) through Conclusion (p. 30) is ~27 pages **excluding** references/appendix, so it **meets** the 25-page threshold.

**References**
- Contains key DiD and SCM citations (Callaway & Sant’Anna; Goodman-Bacon; Sun & Abraham; de Chaisemartin & d’Haultfœuille; Abadie et al.; Arkhangelsky et al.).
- However, the *applied housing/zoning reform* literature coverage is thin and somewhat dated/partial (see Section 4 below). The policy-domain citations are not yet at “top-journal” completeness.

**Prose**
- Major sections are written in paragraph form (not bullets). **Pass.**

**Section depth**
- Introduction: 3+ substantive paragraphs. **Pass.**
- Policy background: multi-paragraph and detailed. **Pass.**
- Literature: multiple subsections. **Pass.**
- Results/Discussion: multiple paragraphs. **Pass.**
- One concern: much of Discussion reiterates limitations already apparent from Results; a top-journal version needs deeper economic interpretation and a clearer mapping from legal change → feasible set → supply response margins.

**Figures**
- Figures shown have axes and visible series (e.g., Fig. 1 p. 19; Fig. 2 p. 22; Fig. 3 p. 26). **Pass**, though publication-quality could be improved (see Section 5).

**Tables**
- Tables contain real numbers and inference objects (SEs, CIs, p-values, N). **Pass.**

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### a) Standard Errors
- Main TWFE DiD table reports SEs in parentheses (Table 2, p. 19) and additional inference. **Pass.**

### b) Significance Testing
- p-values reported (clustered and wild bootstrap in Table 2). **Pass.**

### c) Confidence Intervals
- 95% CI reported for main estimate (Table 2). **Pass.**

### d) Sample Sizes
- N is reported (e.g., N=432 in Table 2). **Pass.**

### e) DiD with staggered adoption
- Not a staggered adoption setting (single treated state; controls never treated in the stated design). **Pass** on this specific criterion.

### Major inference concerns despite formal “Pass”
Even though the paper checks the boxes, a top journal will scrutinize whether the inference procedure is *valid and informative* in a “one treated unit + few clusters” environment.

1) **Cluster-robust SEs with 6 clusters are not credible** (Table 2 uses 6 state clusters). The paper acknowledges few clusters and uses wild cluster bootstrap (good), but:
   - With **one treated cluster**, standard asymptotics remain fragile.
   - Wild cluster bootstrap can still be unreliable in extreme treated/control imbalance and with strong serial correlation.
   - You cite Conley & Taber (2011) and related work, but you do not implement the most compelling inference strategies for *one treated unit*.

2) **Randomization/permutation inference for the DiD is missing.**
   - You do permutation inference for SCM placebo gaps (Table 5), but not for the DiD estimator with the hand-picked 5-state control set.
   - A top-journal referee will want a Fisher-style placebo distribution: “assign” treatment to each control state (or to each state in a broader donor pool) and re-estimate the TWFE/DiD effect, then locate Montana in that distribution. This is particularly important because your SCM exercise suggests the DiD control choice is driving results.

3) **No power/minimum-detectable-effect analysis.**
   - Given volatility in monthly permits and the small effective sample (one treated unit), a formal power calculation or MDE would be essential to interpret “null” effects.

**Bottom line on methodology:** You have *reported* inference, but you have not yet delivered inference that is persuasive for a top journal given the design’s constraints.

---

# 3. IDENTIFICATION STRATEGY

### Credibility
- The paper’s own event study (Fig. 2, p. 22) shows **material pre-trend instability**. This is fatal for a DiD interpretation with the chosen controls.
- SCM produces “no effect,” but also reports **imperfect pre-fit** (pre-RMSPE ≈ 10, Table 5). With noisy monthly outcomes, SCM can be fragile; still, your placebo rank (20th/48, p=0.958) indicates the post-period gap is not distinguishable from noise.

### Core identification problems (substantive, not just econometric)
1) **Outcome does not map cleanly to the policy margin.**
   - BPS “new residential units authorized” is a poor proxy for ADU legalization impacts because many ADUs are:
     - conversions of existing space,
     - permitted as alterations rather than new units,
     - inconsistently classified across jurisdictions.
   - Even for duplex legalization, the relevant margin is **2-unit structures** in specific municipalities; aggregating to the state level (and to “multi-family” broadly) severely dilutes treatment intensity and adds measurement error.

2) **Treatment is heterogeneous within Montana.**
   - SB323 applies only to cities above thresholds (you note this). State-level aggregation implies partial treatment with unknown intensity over time and space. That alone can push estimates toward zero even if local effects are large.

3) **Legal injunction creates a treatment timing/expectations mess.**
   - You treat Jan 2024 as the start, but the injunction begins Dec 29, 2023 and is lifted March 2025. This is closer to:
     - an “announcement” in May 2023,
     - a “blocked implementation” regime,
     - then a “credible implementation” regime.
   - A single post period dummy is not economically aligned with the institutional setting.

### Placebos and robustness
- Robustness checks are limited (Table 4): excluding Idaho; redefining treatment to March 2025. Useful but not enough.
- You should show:
  - sensitivity to donor pools (regional vs national),
  - alternative outcome transformations (log/asinh; seasonal adjustment; quarterly aggregation),
  - explicit pre-trend tests (joint test of leads),
  - alternative counterfactual construction (synthetic DiD; augmented SCM; interactive fixed effects).

### Do conclusions follow from evidence?
- Yes: the conclusion that identification is not credible is consistent with the evidence.
- But for a top journal, “we cannot identify with these data” is not, by itself, a publishable endpoint unless paired with a novel method, a new dataset, or a design that ultimately works.

### Limitations
- Limitations are discussed extensively (Section 6.4, p. 29). This is a strength, but it also underscores that the current empirical approach is not delivering interpretable policy estimates.

---

# 4. LITERATURE (Missing references + BibTeX)

You cite several key DiD papers and canonical SCM. Missing pieces are mainly (i) modern SCM/SCM-inference developments and (ii) applied zoning-reform evidence in North America.

## (A) Synthetic control / panel counterfactual methods (missing or underused)
1) **Abadie (2021 JEL)** — definitive overview, expectations about fit, inference, donor choice.
```bibtex
@article{Abadie2021,
  author  = {Abadie, Alberto},
  title   = {Using Synthetic Controls: Feasibility, Data Requirements, and Methodological Aspects},
  journal = {Journal of Economic Literature},
  year    = {2021},
  volume  = {59},
  number  = {2},
  pages   = {391--425}
}
```

2) **Ben-Michael, Feller, Rothstein (2021)** — augmented SCM to reduce bias under imperfect pre-fit (highly relevant given your RMSPE).
```bibtex
@article{BenMichaelFellerRothstein2021,
  author  = {Ben-Michael, Eli and Feller, Avi and Rothstein, Jesse},
  title   = {The Augmented Synthetic Control Method},
  journal = {Journal of the American Statistical Association},
  year    = {2021},
  volume  = {116},
  number  = {536},
  pages   = {1789--1803}
}
```

3) **Doudchenko & Imbens (2016)** — clarifies connections between SCM, DiD, regression weighting; useful for motivating SDID/ASCM choices.
```bibtex
@techreport{DoudchenkoImbens2016,
  author      = {Doudchenko, Nikolay and Imbens, Guido W.},
  title       = {Balancing, Regression, Difference-in-Differences and Synthetic Control Methods: A Synthesis},
  institution = {National Bureau of Economic Research},
  year        = {2016},
  number      = {22791}
}
```

4) **MacKinnon & Webb (2017)** — wild cluster bootstrap in small samples; important given your reliance on wild bootstrap with 6 clusters and one treated.
```bibtex
@article{MacKinnonWebb2017,
  author  = {MacKinnon, James G. and Webb, Matthew D.},
  title   = {Wild Bootstrap Inference for Wildly Different Cluster Sizes},
  journal = {Journal of Applied Econometrics},
  year    = {2017},
  volume  = {32},
  number  = {2},
  pages   = {233--254}
}
```

## (B) Housing supply / land-use regulation (important missing foundations)
1) **Albouy & Ehrlich (2018)** — welfare/social cost framing for land-use restrictions; helps elevate the economic stakes beyond permits.
```bibtex
@article{AlbouyEhrlich2018,
  author  = {Albouy, David and Ehrlich, Gabriel},
  title   = {Housing Productivity and the Social Cost of Land-Use Restrictions},
  journal = {Journal of Urban Economics},
  year    = {2018},
  volume  = {107},
  pages   = {101--120}
}
```

2) **Paciorek (2013)** — housing supply elasticity estimation and determinants; relevant for interpreting why reforms may not move permits quickly.
```bibtex
@article{Paciorek2013,
  author  = {Paciorek, Andrew},
  title   = {Supply Constraints and Housing Market Dynamics},
  journal = {Journal of Urban Economics},
  year    = {2013},
  volume  = {77},
  pages   = {11--26}
}
```

## (C) Applied zoning reform evidence (your review is currently too narrow)
You cite Auckland (Greenaway-McGrevy & Phillips) and some descriptive US policy work. For a top journal, you need to engage more systematically with:
- empirical evaluations of upzoning and missing-middle reforms,
- ADU reforms (post-2016 California and elsewhere) with credible causal designs,
- the growing literature on state preemption of local zoning.

I am not providing BibTeX for these applied papers here because the exact “closest” set depends on your revised design (place-level / parcel-level vs state aggregates). But the revision must cite and contrast with credible North American evidence (and not primarily reports/think-tank pieces).

---

# 5. WRITING AND PRESENTATION

**Structure and clarity**
- Clear narrative and unusually candid interpretation for an early policy evaluation.
- However, the paper sometimes oversells novelty (“most aggressive…in U.S. history”) without formal substantiation. For a top journal, either document this claim systematically or temper it.

**Tables/Figures**
- Readable, but not yet top-journal polish:
  - Figure captions should state sample, unit, time aggregation, and whether series are seasonally adjusted.
  - For Fig. 1 (p. 19), the volatility is extreme; consider quarterly aggregation or smoothing in an appendix while keeping raw monthly in the main text.
  - For SCM, show donor weights in a table; show pre-period fit visually with clearer scaling and perhaps cumulative outcomes.

**Terminology**
- The outcome is “permits,” not “construction.” You are careful at points, but the title/phrasing should avoid conflating permits with completed units, especially given ADUs.

---

# 6. CONSTRUCTIVE SUGGESTIONS (How to make this publishable/impactful)

A top-journal version needs a design that (i) maps to the treated margin and (ii) yields credible counterfactuals.

## A. Move from state-level to place-level identification (essential)
1) **Triple-difference / within-Montana design using SB323 eligibility**
- Compare places just above vs below the 5,000 population threshold (and county >70,000 threshold) before/after implementation, using place-level permit data.
- This immediately addresses the “state aggregation dilutes treatment” issue you correctly highlight.

2) **RDD / difference-in-discontinuities at the population cutoff**
- If you use an RDD around 5,000, you must do:
  - bandwidth sensitivity,
  - McCrary density test,
  - covariate balance,
  - donut RDD if manipulation is plausible.
- This could be compelling if Montana towns near the threshold are comparable and if permits are measured consistently.

## B. Measure the policy margin properly (ADUs/duplexes)
- Collect **municipal permit microdata** that separately identifies ADUs and duplexes (many cities track this).
- Alternatively, use administrative address/structure data (e.g., address point additions) to detect small-unit infill.
- Re-estimate effects on:
  - ADU permits specifically,
  - 2-unit structure permits,
  - small multifamily (3–4) where substitution might occur.

## C. Align treatment timing with institutions
- Model at least three periods:
  1) post-enactment/anticipation (May 2023 onward),
  2) injunction (Dec 29, 2023–Mar 3, 2025),
  3) post-decision implementation (Mar 2025 onward).
- A single “Post Jan 2024” dummy is not credible given the injunction.

## D. Improve inference for one treated unit
- Add **randomization inference** for DiD (reassign treatment across states; compute distribution of placebo DiD effects).
- Consider Conley–Taber-style inference explicitly tailored to one treated unit.
- Report MDE/power.

## E. Economic outcomes beyond permits
If you can obtain appropriate data, broaden outcomes:
- rents (ZORI), prices (Zillow/ACS), vacancies,
- composition (share of 2-unit / ADU),
- land values, redevelopment rates.
Even null permit effects might coexist with price effects if expectations or land markets respond first.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Transparent, replicable workflow using public data.
- Uses multiple estimators (TWFE DiD + SCM) and does not “cherry pick” the favorable one.
- Appropriately cautious interpretation; explicitly flags pre-trend problems (Fig. 2, p. 22) and aggregation/treatment heterogeneity issues (Conclusion, p. 30).

### Critical weaknesses (fatal for top journal in current form)
1) **Design–outcome mismatch**: state-level BPS permits are not a valid/precise measure of ADU legalization impacts and only weakly measure duplex legalization.
2) **No credible identification**: pre-trends + heterogenous treatment + injunction timing undermine causal claims. The paper essentially demonstrates non-identification.
3) **Inference remains fragile**: 6 clusters, 1 treated unit, high volatility—wild bootstrap is not enough without stronger randomization-style inference and/or a design with many treated/control units (place-level).
4) **Contribution is currently negative/diagnostic** rather than delivering a credible estimate of an economically meaningful parameter.

### Specific improvements needed
- Rebuild around within-state place-level variation and explicit ADU/duplex outcomes; fix treatment timing; strengthen inference with randomization inference and/or RDD/DDD designs.

---

DECISION: REJECT