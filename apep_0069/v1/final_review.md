# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-28T00:57:09.918059
**Response ID:** resp_06b4334aa665a7a4006979503d1760819db33ab170a65052c7
**Tokens:** 32987 in / 6030 out
**Response SHA256:** ae0b2b95f1492e71

---

## Referee Report (Top General-Interest Economics Journal)

### Summary (what the paper does)
The paper asks whether exposure to sub-national climate/energy regulation increases support for analogous national policy (“policy feedback”). Using Swiss canton-level adoption/in-force timing of comprehensive energy laws (MuKEn-style building/efficiency regulation) and municipality (Gemeinde) vote shares on the May 2017 federal Energy Strategy 2050 referendum, the paper estimates mostly *negative* effects of prior cantonal exposure on support for the federal referendum. The preferred design is a spatial RDD at internal canton borders; supporting evidence includes OLS with language-region controls, permutation-based “randomization inference,” and a small panel of four energy-related referendums (2000–2017) with staggered-adoption DiD (Callaway–Sant’Anna).

The question is interesting, the setting is attractive, and the paper takes inference seriously. However, **the core causal claim is not yet convincingly identified**, largely because (i) the *dominant confounder is language region* and (ii) the “clean” same-language border RDD is imprecise and not statistically distinguishable from zero, while the statistically significant pooled RDD mixes same-language and cross-language (Röstigraben) borders. The current draft **overstates what can be concluded** from the evidence.

Below I provide a demanding, detailed evaluation.

---

# 1. FORMAT CHECK

### Length
- The submitted PDF excerpt runs to **~56 pages including appendices and references** (page numbers visible up to the mid-50s). The **main text appears ~38 pages** (through Section 8 plus references starting around p. 38–42). This clears the “≥25 pages” bar.

### References
- The bibliography is substantial and includes many key methods citations (Calonico–Cattaneo–Titiunik; Goodman-Bacon; Sun–Abraham; Callaway–Sant’Anna; Cameron–Gelbach–Miller; Young).
- However, **important adjacent literatures are under-cited**, especially: geographic/spatial RDD nuances (local randomization / border designs), clustered randomization/permutation inference with few clusters, and political-economy of federalism/centralization in Switzerland beyond the classic texts. See Section 4 below for concrete missing references + BibTeX.

### Prose (paragraph form vs bullets)
- Major sections (Intro, framework, institutional background, results, discussion, conclusion) are **mostly in full paragraphs**. Bullet lists appear mainly for enumerations (e.g., referendum list; robustness list). This is acceptable for a top journal.

### Section depth (3+ substantive paragraphs each)
- **Introduction (Section 1)**: yes (multiple substantive paragraphs).
- **Theory/Lit (Section 2)**: yes.
- **Institutional (Section 3)**: yes.
- **Data (Section 4)**: yes.
- **Empirics (Sections 5–6)**: yes, though some subsections read like a technical report (lists of diagnostics/specs).
- **Discussion (Section 7)**: yes.

### Figures
- Figures generally have visible data, legends, axes. The main RDD plot (Figure 7, around p. 24 in excerpt) is legible and appropriately annotated.
- **However**:
  1. Several maps (Figures 1–5) are visually appealing but risk being “descriptive filler” for an econ top-5 unless tied tightly to identification and estimation decisions.
  2. Some coefficient plots (e.g., Figure 6/10/11 style) need clearer axis units and explicit sample/bandwidth references in captions to be fully publication-grade.

### Tables
- Tables include real numbers and SEs; no placeholders. Good.

**Format verdict:** broadly compliant; the main changes needed are *substantive*, not cosmetic.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard Errors reported?
- **PASS.** OLS tables report clustered SEs; RDD tables report SEs and robust bias-corrected CIs; DiD reports SEs; permutation inference reports p-values.

### (b) Significance testing conducted?
- **PASS.** p-values appear throughout.

### (c) 95% confidence intervals for main results?
- **Mostly PASS.** RDD tables report 95% CIs; OLS tables do not consistently report CIs (only SEs), but this is fixable and should be done for the *headline* estimate(s).

### (d) Sample sizes reported?
- **PASS.** N is reported for OLS and RDD (effective sample sizes on each side).

### (e) DiD with staggered adoption handled correctly?
- **PASS on method choice.** The paper explicitly avoids relying on biased TWFE and uses Callaway–Sant’Anna (Appendix Table 14; discussion around Figure 14). This is good practice.
- **But** the panel has only four referendums, two of which are very distant in time and arguably different policy objects. Parallel trends checks are therefore limited (see Section 3).

### (f) RDD requirements: bandwidth sensitivity and McCrary?
- **PASS.** Bandwidth sensitivity and McCrary density are included; covariate balance is shown.

**Methodology verdict:** the paper clears the “publishable econometrics hygiene” threshold. The bigger issue is not missing inference—it is **whether the identifying variation isolates the causal effect of “policy exposure” rather than language/culture/centralization attitudes correlated with canton borders and adoption.**

---

# 3. IDENTIFICATION STRATEGY

### Core identifying claim
The paper’s preferred causal evidence is the spatial RDD at internal canton borders (Section 5.2; Table 5). The intended identifying assumption is: **potential outcomes vary smoothly at the border, and the only discontinuity is cantonal policy exposure**.

### Main identification problems

#### 1) Language-region discontinuities are not a “minor nuisance”—they are first-order
The paper is admirably upfront that language is the dominant confound (Section 4.2; Table 2; Figure 2). But then:

- The **pooled RDD** estimate is statistically significant (−2.73 pp, SE 1.10), yet it **explicitly pools borders where language changes discontinuously** (BE–FR/NE/VD/JU, GR–TI, etc.). Those borders are precisely where smoothness is least credible because the Röstigraben is a deep political cleavage correlated with federal policy support.
- The **same-language border RDD** (arguably the cleanest design) is **−1.36 pp (SE 1.27, p=0.28)**—not distinguishable from zero.

A top journal will not accept a causal narrative that leans on the pooled estimate while the cleaner design is null/imprecise. At minimum, the paper must reframe:

- either as “no evidence of positive feedback; point estimates slightly negative,”
- or present a stronger design that makes same-language comparisons decisive.

#### 2) “Same-language” is defined at canton-majority level—this is not enough locally
You correctly note BE and GR contain non-trivial linguistic minorities (Section 4.2 notes Jura bernois; GR has Italian/Romansh). In a geographic RD, the relevant condition is **local** continuity. A canton-majority language indicator is too coarse.

**Needed:** Gemeinde-level language shares (from census) or at least district-level, with:
- a border sample restricted to places with, say, ≥90% German on both sides (or symmetric thresholds),
- and/or controlling flexibly for local language composition in the running variable neighborhood.

Without this, even “same-language borders” can still embed sharp cultural changes.

#### 3) Border RD pooling across heterogeneous border segments is fragile
Pooling many borders assumes a common treatment effect and comparable counterfactual structure. Yet:
- urbanization differs sharply across borders (e.g., BL/BS area vs alpine GR borders),
- cross-border commuting/media markets differ,
- baseline environmental preferences differ.

You show border-pair heterogeneity plots (Appendix Figures 15–16), but they are very aggregated (“BE-multiple”, “Other”). A top-journal reader will ask: *which borders identify the effect?* and *are those borders credible?*

A more credible approach is to estimate:
- border-segment fixed effects (pair FE),
- allow border-specific slopes in distance,
- present a pre-registered or clearly justified aggregation scheme,
- and report leave-one-border-out robustness.

#### 4) The “double bandwidth” result reads like specification search
Table 5 highlights that doubling the bandwidth yields −3.64 pp (SE 0.84, p<0.001). But wider bandwidths increase bias risk in RD. In top journals, significant results from “less local” specifications are viewed skeptically unless accompanied by:
- convincing smoothness in covariates and pre-outcomes over that wider range,
- strong justification that the functional form captures global spatial trends,
- or a local randomization framework with explicit window choice logic.

Right now, the narrative risks appearing as: “the estimate becomes significant when I widen the window.” That is not a persuasive identification story.

#### 5) Treatment definition risks serious measurement error and endogeneity
Treatment is “comprehensive energy law in force before May 2017,” but:
- several “control” cantons had partial MuKEn implementation (you mention Zürich, St. Gallen, etc.),
- enforcement intensity likely varies within and across cantons,
- exposure at the household level differs (homeowners vs renters; renovation rates; subsidy take-up).

This likely biases estimates toward zero, but it also complicates interpretation: are we estimating “policy in force,” “salience of regulatory burden,” or “administrative experience”? A top journal needs a clearer mapping from treatment to mechanisms with measurable intermediate outcomes.

### Placebos and robustness
- **Good:** McCrary density, covariate balance, donut RD.
- **Less convincing:** the panel “parallel trends” relies on only two true pre-treatment referendums, far apart, and on different policy questions (2000 levy; 2003 nuclear moratorium extension). Those are not clean pre-trends for a 2017 building-efficiency federal law.
- **Missing:** placebo outcomes plausibly unaffected by cantonal energy laws (e.g., unrelated referendums held in similar years), to show border discontinuities are not generic “treated cantons vote differently on federal stuff.”

### Do conclusions follow from evidence?
Not yet. The paper claims “statistically significant negative effects” and frames this as contradicting policy feedback. But given:
- OLS with language controls is −1.8 pp (SE 1.9, not sig),
- same-language border RDD is not sig,
- the significant pooled RDD is confounded by language-border discontinuities,

the defensible conclusion is weaker: **“no evidence of positive feedback; estimates are small and often negative; identification strongest where estimates are least precise.”**

---

# 4. LITERATURE (missing references + BibTeX)

You cite many core methods papers. Still, for a top field/general journal, several literatures should be more fully integrated.

## (A) Geographic RD / border designs (beyond the basics)
You cite Keele–Titiunik (2015) and Dell (2010) plus Holmes (1998), Dube et al. (2010). Add work emphasizing **border RD implementation pitfalls**, **local randomization**, and **RD inference**.

1) **Cattaneo, Frandsen, Titiunik (2015)** (local randomization in RD; conceptual alternative to continuity-based RD that is often more natural in geographic settings):
```bibtex
@article{CattaneoFrandsenTitiunik2015,
  author  = {Cattaneo, Matias D. and Frandsen, Brigham R. and Titiunik, Rocio},
  title   = {Randomization Inference in the Regression Discontinuity Design: An Application to Party Advantages in the {U.S.} Senate},
  journal = {Journal of Causal Inference},
  year    = {2015},
  volume  = {3},
  number  = {1},
  pages   = {1--24}
}
```

2) **Kolesár and Rothe (2018)** (robust bias-aware RD inference; helps justify bandwidth choices and interpret sensitivity):
```bibtex
@article{KolesarRothe2018,
  author  = {Koles{\'a}r, Michal and Rothe, Christoph},
  title   = {Inference in Regression Discontinuity Designs with a Discrete Running Variable},
  journal = {American Economic Review},
  year    = {2018},
  volume  = {108},
  number  = {8},
  pages   = {2277--2304}
}
```

3) Consider also engaging with the “geographic discontinuity / border FE” applied literature to justify pooling and show best practices (you have some, but currently it reads more PoliSci than Econ in this part).

## (B) Inference with few clusters / randomization inference under clustering
You cite Young (2019) and some cluster-robust guidance. Add modern work clarifying when cluster adjustments matter, and permutation/RI validity with clustered assignment.

1) **Abadie, Athey, Imbens, Wooldridge (2023)**:
```bibtex
@article{AbadieAtheyImbensWooldridge2023,
  author  = {Abadie, Alberto and Athey, Susan and Imbens, Guido W. and Wooldridge, Jeffrey M.},
  title   = {When Should You Adjust Standard Errors for Clustering?},
  journal = {Quarterly Journal of Economics},
  year    = {2023},
  volume  = {138},
  number  = {1},
  pages   = {1--35}
}
```

2) **Canay, Romano, Shaikh (2017)** (randomization tests; useful when discussing RI assumptions beyond “exchangeability”):
```bibtex
@article{CanayRomanoShaikh2017,
  author  = {Canay, Ivan A. and Romano, Joseph P. and Shaikh, Azeem M.},
  title   = {Randomization Tests Under an Approximate Symmetry Assumption},
  journal = {Econometrica},
  year    = {2017},
  volume  = {85},
  number  = {3},
  pages   = {1013--1030}
}
```

## (C) Sensitivity analysis for parallel trends / DiD credibility
Given the thin pre-period evidence, add a sensitivity framework:

1) **Rambachan and Roth (2023)**:
```bibtex
@article{RambachanRoth2023,
  author  = {Rambachan, Ashesh and Roth, Jonathan},
  title   = {A More Credible Approach to Parallel Trends},
  journal = {Review of Economic Studies},
  year    = {2023},
  volume  = {90},
  number  = {5},
  pages   = {2555--2591}
}
```

## (D) Climate policy acceptance / backlash evidence in economics
The discussion cites Stokes (2016) (good), but for an econ audience, add work on distributional incidence and perceived costs:

1) **Borenstein and Davis (2016)** (incidence/heterogeneity in energy policy benefits/costs—useful for “cost salience” channel):
```bibtex
@article{BorensteinDavis2016,
  author  = {Borenstein, Severin and Davis, Lucas W.},
  title   = {The Distributional Effects of {U.S.} Clean Energy Tax Credits},
  journal = {Tax Policy and the Economy},
  year    = {2016},
  volume  = {30},
  number  = {1},
  pages   = {191--234}
}
```

2) **Aklin and Urpelainen (2013/2018)**-type references could also help situate “policy feedback vs backlash” in energy transitions (choose your preferred canonical one; I’m not providing BibTeX here to avoid guessing the exact outlet/version you want).

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets
- **PASS** on the basic requirement: the main narrative is in paragraphs; bullet points are used sparingly.

### Narrative flow
- The introduction (Section 1, ~pp. 2–4) has a strong motivating question and a “surprising” result. That’s good.
- But the paper currently has **two competing stories**:
  1) “The effect is negative and significant (thermostatic voter).”
  2) “Once you control for language, it’s small and not significant.”

A top journal needs one coherent story with clearly defined estimands and a hierarchy of evidence. Right now, the narrative emphasizes statistically significant pooled/big-bandwidth RDD results, while the cleanest same-language comparisons are non-significant. This is a *writing and framing* problem as much as a methods problem.

### Sentence/paragraph quality
- Generally clear and readable.
- However, the paper sometimes **overstates certainty** (“directly contradict,” “statistically significant negative effects,” “supports thermostatic”) given the identification issues above. Tighten claims.

### Accessibility
- Strong: explains Swiss institutional setting well (Section 3).
- Needs improvement: explain **why canton borders approximate quasi-random assignment** despite deep cultural/political discontinuities (language, religion, rurality) that often *do* align with borders in Switzerland.

### Figures/Tables publication quality
- Many figures are good, but the paper includes a large number of maps/plots. For AER/QJE/JPE/ReStud/Ecta, you likely need **fewer but more decisive** visuals:
  - one treatment map,
  - one main outcome map (optional),
  - one main RD plot,
  - one coefficient plot summarizing preferred estimates,
  - move the rest to appendix.

---

# 6. CONSTRUCTIVE SUGGESTIONS (to make it publishable and impactful)

## A) Make the border design credibly “same culture”
1) **Use Gemeinde-level language shares** (census) and:
   - restrict the RD sample to municipalities that are overwhelmingly German on both sides,
   - re-define “same-language border” locally rather than by canton majority,
   - show balance in language shares at the cutoff.

2) Add **border-segment fixed effects** (pair FE) and allow:
   - segment-specific distance trends,
   - segment-specific treatment effects (then meta-analyze).

3) Implement a **local randomization RD** (Cattaneo–Frandsen–Titiunik style):
   - choose a window (e.g., ±5km) justified by covariate balance,
   - run randomization inference within that window.
Geographic RD often fits local-randomization better than continuity-based polynomial fits.

## B) Demonstrate the effect is not “generic treated-canton federal skepticism”
Run placebo RD/DiD on **unrelated referendums** around 2016–2017 (or multiple years) where cantonal energy law exposure should not matter (e.g., health insurance, immigration, transport not tied to energy/buildings). If the same discontinuity appears, your interpretation collapses into “these cantons vote differently.”

## C) Strengthen the panel evidence
Four referendums across 17 years is thin. If data permit, expand the panel to:
- more energy/environment referendums,
- and/or cantonal referendums on energy/building policy,
- and/or VOX post-referendum surveys to track attitudes/mechanisms.

Also consider **Rambachan–Roth** sensitivity to quantify how strong differential trends would need to be to overturn your conclusions.

## D) Mechanisms: move beyond “consistent with”
Right now, Section 7 lists plausible channels (thermostat, cost salience, federal overreach) but provides little direct evidence. Possible measurable mechanism tests:
- renovation rates / building permits / heat pump adoption before vs after cantonal law (administrative data),
- local electricity prices, grid surcharge salience, subsidy take-up,
- media coverage intensity in treated vs control cantons,
- homeowner share (renter vs owner) interacted with treatment in the RD window.

Even one well-executed mechanism test would substantially increase publishability.

## E) Reframe the contribution more carefully
Given the evidence, a more defensible framing is:
- **“Local policy experience does not generate positive mass support for national harmonization; if anything, it may reduce it.”**
That is still an interesting and publishable message, but it requires discipline: do not oversell “statistically significant negative effects” when the clean RD is not significant.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Excellent question and setting (Swiss federalism + direct democracy).
- Serious attention to inference (SEs, CIs, RD diagnostics, staggered DiD).
- Transparent discussion of a major confound (language).
- The paper is written clearly and is close to being a strong empirical contribution.

### Critical weaknesses (why top journals will reject as-is)
1) **Identification is not yet persuasive**: pooled RD mixes language borders; same-language RD is null/imprecise; canton-majority language is too coarse for a geographic design.
2) **Overstated conclusions** relative to the strongest credible design.
3) **Mechanisms are speculative** without supporting evidence.
4) Panel “pre-trends” are weak given few, distant, and substantively different referendums.

### What would change my mind
If the author:
- reconstructs the RD using local language shares (or otherwise credibly holds culture constant),
- shows the negative effect is robust within truly comparable border communities,
- and adds placebo outcomes + at least one mechanism validation,

then the paper could plausibly meet AEJ:EP quality and potentially compete for a top general-interest journal depending on effect clarity and contribution positioning.

---

DECISION: MAJOR REVISION