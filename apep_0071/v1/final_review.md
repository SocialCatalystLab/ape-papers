# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-28T14:04:31.827112
**Response ID:** resp_0e88065b14e6c1f200697a08a0515c8197842b004ee3add2b3
**Tokens:** 33805 in / 5595 out
**Response SHA256:** 2d097e7826b533a3

---

## Referee Report (top general-interest economics journal standard)

### Summary
The paper asks whether exposure to sub-national (cantonal) energy/climate policy increases voters’ support for a subsequent national climate/energy policy. The author exploits variation in the timing of comprehensive cantonal energy-law implementation in Switzerland and studies voting on the May 2017 federal “Energy Strategy 2050” referendum. The headline result is *negative policy feedback*: municipalities in “treated” cantons (energy law in force pre-2017) are **less** supportive of the federal policy, with the preferred spatial RDD on same-language canton borders estimating about **−5.9 pp** (SE 2.32).

The question is important and publishable in principle. The current version shows serious promise, especially in its attention to language confounding and its effort to combine RDD + permutation-style checks + staggered DiD/event-study. However, the identification story is not yet tight enough for a top journal: the border RDD hinges on strong assumptions about “only the policy changes at borders,” but the paper’s own placebo evidence suggests sizable generic border discontinuities on unrelated referendums. The “same-language” restriction helps but does not solve the deeper concern that *cantons differ discontinuously at borders along many political and administrative dimensions*, and the paper does not yet deliver the convincing suite of falsification tests and design transparency required at AER/QJE/JPE/ReStud/Ecta/AEJ:EP.

---

# 1. FORMAT CHECK

**Length**
- The main text appears to run to roughly **36–37 pages** (Conclusion around p. 36; references start around p. 38), **excluding** appendices and references. This clears the “≥25 pages” norm.

**References**
- The bibliography covers core RDD and staggered DiD citations (Lee & Lemieux; Imbens & Lemieux; Calonico et al.; Callaway & Sant’Anna; Goodman-Bacon; Sun & Abraham) and relevant political-economy concepts (Pierson; Mettler; Wlezien; Oates; Shipan & Volden).
- But it is **thin** on (i) *border discontinuity* applied-econometrics practice (esp. “border-pair fixed effects,” multi-border aggregation, and spatial confounding), (ii) *policy feedback in environmental/climate contexts*, (iii) Swiss referendum voting/cleavage literature beyond a couple citations, and (iv) “local randomization” RD inference and clustering issues for geographic RD.

**Prose (bullets vs paragraphs)**
- Major sections (Intro, theory, results, discussion) are written largely in paragraph form. Bullet lists appear mainly for institutional details and data lists—acceptable.

**Section depth**
- Introduction, theory/lit, institutional background, strategy, results, discussion each have multiple substantive paragraphs. Pass.

**Figures**
- Maps and RD plots mostly have axes/legends; the RD plots (e.g., Fig. 7) have axes and a cutoff. Some map figures lack scale bars and do not show uncertainty (fine), but **readability** is mixed: several are visually dense, and some appendix figures (e.g., border heterogeneity plots) look more like internal diagnostics than publication-quality exhibits.

**Tables**
- Tables contain real numbers; no placeholders. Pass.

**Bottom line on format:** generally acceptable, but figures need publication-level polish and the “corrected vs pre-correction” dual pipeline needs clearer presentation (right now it is confusing).

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors
- Core regression tables report **SEs in parentheses** (e.g., Table 4 OLS; Table 5 RD; Table 6 covariate balance; Table 15 CSA).
- RD results report robust/bias-corrected CIs.
- Pass.

### (b) Significance testing
- Hypothesis tests are reported (p-values, CIs). Pass.

### (c) Confidence intervals
- 95% CIs are provided for key RD results (Table 5) and elsewhere. Pass.

### (d) Sample sizes
- N is reported for main regressions and RD effective samples (NL/NR). Pass.

### (e) DiD with staggered adoption
- The paper explicitly avoids naive TWFE and uses **Callaway & Sant’Anna (2021)** with cohort timing, and discusses Goodman-Bacon bias. This is good practice. Pass on methodology.
- However: the panel is *very sparse* (4 referendums across 17 years, with different policy objects). Even if econometrically “correct,” this does not provide the kind of compelling identification one expects—treat this as descriptive support, not confirmation.

### (f) RDD requirements
- McCrary density test is shown (Fig. 8) and bandwidth sensitivity is shown (Fig. 10). Pass.
- That said, geographic RD requires *more* than McCrary + bandwidth. You must confront:
  1. **Spatially correlated errors / clustering** at border-segment level.
  2. Multiple borders pooled together: inference must reflect the effective number of independent border segments, not municipality count.
  3. Potentially “bad controls” and functional-form sensitivity in 2D geography.

**Verdict on statistical methodology:** It **does not fail** the basic inference checklist; the paper is **publishable in principle**. But the **inference architecture is not yet top-journal-grade for a geographic RD** because the paper treats municipalities as the unit of information even though the identifying variation is arguably at the border-segment (or canton-pair) level. This is fixable, but not optional.

---

# 3. IDENTIFICATION STRATEGY

## What works
- The language confound (Röstigraben) is real and large; the paper recognizes it and makes a serious attempt to restrict to same-language borders.
- The “corrected sample construction” (distance to own canton’s treated-control border) is a thoughtful correction and should be standard.

## Core credibility problems (currently fatal for top journals without major revision)

### 3.1 The RD continuity assumption is not defended with the right falsifications
The key claim is: near canton borders, municipalities are comparable except for cantonal energy-law exposure. In Switzerland, this is **not obviously true**. Cantons differ sharply in:
- tax systems, fiscal capacity, transfers;
- school systems and civic curricula;
- political culture and party strength;
- administrative implementation capacity and enforcement intensity;
- and potentially many other environmental and building-regulation policies.

A top journal will require direct evidence that “nothing else jumps” at treated-control borders *in outcomes correlated with energy-policy support*. The paper currently provides:
- McCrary density: good but close to irrelevant for geographic RD (no one believes municipalities sort across centuries-old borders).
- Balance on a few covariates (log population, turnout, urban share): far too few, and arguably weak proxies.

### 3.2 Placebo referendums indicate generic border discontinuities
Appendix Table 13 reports large and significant discontinuities for unrelated referendums (immigration enforcement, corporate tax reform), which is a red flag: it implies that borders capture **general political differences**.

The author downweights these placebos because they are on the “pre-correction” sample, but that is not an acceptable resolution. A top-journal reader will conclude: “the design finds jumps everywhere; the energy jump is not special.”

You need placebo tests **on the exact same corrected sample pipeline** and, crucially, on the **same-language border subset**, using:
- prior *energy-related* referendums (especially the 2016 Atomausstiegsinitiative and earlier energy votes) as pre-treatment outcomes in the *same RD design*;
- and/or party vote shares from federal elections as predetermined political outcomes.

### 3.3 Treatment definition and intensity are under-validated
“Comprehensive energy law implementing MuKEn” is a coarse 0/1. But Swiss cantons had:
- partial MuKEn adoption,
- different enforcement intensity,
- different subsidy generosity,
- and different pre-existing building codes.

Measurement error in treatment can attenuate or bias the RD discontinuity depending on correlation with other canton characteristics. A top journal will demand a stronger treatment appendix: policy indices, enforcement proxies, spending, inspection rates, retrofit rates, heat-pump adoption—anything that documents that the “treated” border indeed represents a sharp discontinuity in *experienced policy*.

### 3.4 Pooling across multiple borders/cantons risks composition-driven results
Even within “same-language” borders, you pool heterogeneous canton pairs (AG–ZH, AG–SO, AG–LU, BL–SO, GR–SG, etc.). If one or two borders drive the result, the pooled estimate is fragile. You show some heterogeneity plots, but not in a way that supports a clear aggregation logic or correct inference.

### 3.5 Mechanisms are speculative
The discussion offers thermostatic preference, cost salience, and “federal overreach.” But there is no direct mechanism evidence (survey data, media exposure, building-sector exposure, homeowner shares). At top journals, a purely reduced-form result is acceptable *if identification is bulletproof*; here, identification is not yet bulletproof, so mechanism evidence becomes more important.

**Bottom line on identification:** promising but not yet credible enough for AER/QJE/JPE/ReStud/Ecta/AEJ:EP. The paper needs a redesigned falsification and inference suite that treats the *border-pair* as the source of identifying variation.

---

# 4. LITERATURE (missing references + BibTeX)

## (i) Geographic/border RD and border discontinuity designs (economics practice)
You cite Holmes (1998) and Dube et al. (2010), but you do not engage with the broader “border-pair fixed effects / contiguous-border designs” and spatial confounding literature that would be natural for this paper.

**Add:**
1) **Gibbons, Machin & Silva (2013)** on boundary discontinuities and local identification.
```bibtex
@article{Gibbons2013,
  author  = {Gibbons, Stephen and Machin, Stephen and Silva, Olmo},
  title   = {Valuing School Quality Using Boundary Discontinuities},
  journal = {Journal of Urban Economics},
  year    = {2013},
  volume  = {75},
  pages   = {15--28}
}
```

2) **Keele, Titiunik, and coauthors on geographic RD implementation details** beyond the 2015 Political Analysis piece (you cite that). Consider adding work discussing threats unique to geographic RD and inference with spatial correlation. One relevant applied-econometrics reference is:
```bibtex
@article{Cattaneo2016LocalRandomization,
  author  = {Cattaneo, Matias D. and Frandsen, Brigham R. and Titiunik, Rocio},
  title   = {Randomization Inference in the Regression Discontinuity Design: An Application to Party Advantages in the U.S. Senate},
  journal = {Journal of Causal Inference},
  year    = {2015},
  volume  = {3},
  number  = {1},
  pages   = {1--24}
}
```
(Use if you adopt local-randomization inference near borders; otherwise cite appropriate local-randomization RD references.)

## (ii) Climate policy acceptability / backlash and policy feedback in environmental settings
You cite Stokes (2016) and Carattini et al. (2018), good. But you should connect to the rapidly growing political economy of climate policy support and backlash literature.

**Add:**
3) **Mildenberger & Tingley (2019)** (climate mass politics framing and support).
```bibtex
@article{Mildenberger2019,
  author  = {Mildenberger, Matto and Tingley, Dustin},
  title   = {Beliefs About Climate Beliefs: The Importance of Second-Order Opinions for Climate Politics},
  journal = {British Journal of Political Science},
  year    = {2019},
  volume  = {49},
  number  = {4},
  pages   = {1279--1307}
}
```

4) **Klenert et al. (2018)** on carbon pricing acceptability and design.
```bibtex
@article{Klenert2018,
  author  = {Klenert, David and Mattauch, Linus and Combet, Emmanuelle and Edenhofer, Ottmar and Hepburn, Cameron and Rafaty, Ryan and Stern, Nicholas},
  title   = {Making Carbon Pricing Work for Citizens},
  journal = {Nature Climate Change},
  year    = {2018},
  volume  = {8},
  pages   = {669--677}
}
```

## (iii) Swiss referendum voting and language cleavages
Given how central the Röstigraben is, the paper needs deeper engagement with Swiss voting behavior work (beyond Herrmann & Armingeon and Kriesi).

**Add (examples):**
5) **Sciarini & Tresch** (Swiss voting behavior; referendum choice determinants). One possible entry (verify exact bibliographic details for the version you cite):
```bibtex
@book{Sciarini2016,
  author    = {Sciarini, Pascal and Tresch, Anke},
  title     = {Swiss Politics: The Federal Council, Direct Democracy, and Political Parties},
  publisher = {Palgrave Macmillan},
  year      = {2016}
}
```
(If you prefer journal articles, cite Swiss Electoral Studies/Swiss Political Science Review pieces specifically on language cleavages and environmental votes.)

**Why these additions matter:** your design is only as credible as your handling of cross-canton political-cultural discontinuities. The Swiss voting literature provides candidate confounders and relevant placebo outcomes.

---

# 5. WRITING QUALITY (CRITICAL)

## Strengths
- The paper is readable and generally well organized.
- The motivation is clear and the top-line result is stated early.
- The “language confound” is explained clearly with helpful maps.

## Weaknesses (important for top journals)
1) **Over-claiming “natural experiment” and causal language**: The intro and abstract lean into causal framing (“I exploit variation… natural experiment… shaped voting”). Given the placebo-border discontinuities, you must either (i) deliver a much stronger identification defense, or (ii) temper language to “quasi-experimental evidence consistent with…”.
2) **Internal inconsistency and reader confusion around “corrected vs pre-correction”**: You present key figures (e.g., Fig. 7) using a different running variable than the main table (Table 5), and then ask the reader to reconcile them. At top journals, this is a major presentation flaw. The main exhibit must correspond to the main estimate—full stop.
3) **Mechanism discussion reads as a menu**: thermostatic vs cost salience vs federal-overreach are all plausible; without direct evidence, the discussion feels speculative. Either add mechanism evidence or tighten the discussion to what the design can actually speak to.

---

# 6. CONSTRUCTIVE SUGGESTIONS (what to do to reach top-journal standard)

## 6.1 Make the geographic RD design credible
You likely need **three upgrades**:

### (A) Border-pair fixed effects / border-segment design
Estimate specifications that compare *only within a given treated-control border pair* (or even border segment), e.g.:
- include **canton-pair fixed effects** (AG–ZH, AG–SO, etc.) and allow separate slopes by border-pair;
- present an aggregation that is transparent (e.g., inverse-variance weighted average across border-pairs);
- and compute inference clustered at **border-pair** level (or use randomization inference across border-pairs).

This is crucial because otherwise your effective “N” is not 800 municipalities but ~a dozen borders.

### (B) Placebos that match the main pipeline exactly
Re-run the RD using:
- earlier referendums on energy/environment policy (pre-2011 and pre-treatment for early adopters),
- party vote shares from federal elections (predetermined political outcomes),
- and any socioeconomic outcomes unaffected by energy laws (education composition, age structure, homeownership, building stock age), if available.

These must be:
- on the **corrected sample construction**,
- on the **same-language border subset**,
- with identical bandwidth choice rules.

### (C) Show that treatment is “sharp” at the border in actual policy exposure
Construct (even coarse) canton-level or municipal-level measures of exposure:
- subsidy spending per capita (if available),
- retrofit/permit counts,
- heat pump adoption rates,
- building energy certificate issuance,
- or enforcement intensity indicators.

Then show these jump at treated-control borders (or at least differ strongly at canton level in the expected direction). Without this, “treated” is a label, not an exposure discontinuity.

## 6.2 Tighten the main result presentation
- Make the *primary* RD plot correspond to the *primary* estimate (corrected sample + same-language).
- Move “pre-correction” plots to an appendix clearly labeled as legacy/diagnostic.
- Provide a single “main table” with: estimate, SE, 95% CI, bandwidth, NL/NR, number of borders, and an explicit statement of the running variable.

## 6.3 Mechanism evidence (even minimal) would add large value
Options:
- Swissvotes post-referendum survey items: perceived costs, attitudes toward federalism, trust, environmental concern. Show treated cantons differ in mechanism-consistent ways.
- Heterogeneity by homeowner share / building renovation intensity (municipality-level proxies).
- Media exposure / campaign intensity differences (if measurable).

## 6.4 Reframe and calibrate external validity claims
Given Switzerland’s distinctive direct democracy, you should:
- clarify what generalizes (thermostatic response to “already implemented policy”) vs what is Switzerland-specific (referendum aggregation, language cleavages).
- avoid strong claims about “Paris Agreement bottom-up momentum” unless you can connect to comparable settings.

---

# 7. OVERALL ASSESSMENT

## Key strengths
- Important question with clear policy relevance.
- Serious attention to a first-order confound (language regions).
- Uses modern staggered-adoption estimators rather than naive TWFE.
- Provides standard RD diagnostics (density, bandwidth sensitivity).

## Critical weaknesses
- Geographic RD identification is **not yet persuasive**: too few covariates/balance checks; pooling across borders; inadequate handling of spatial correlation and “effective N.”
- Placebo referendum discontinuities strongly suggest border confounding; dismissing them due to “pre-correction sample” is not adequate.
- Main figures do not align with main estimates, reducing transparency and credibility.
- Mechanism claims are not supported by evidence.

## What would change my view
A revised version that (i) performs border-pair-based estimation and inference, (ii) runs properly matched placebos on the corrected/same-language pipeline, and (iii) documents sharp exposure differences at borders would be substantially more credible and could become publishable.

---

DECISION: MAJOR REVISION