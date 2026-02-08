# Final Review

**Purpose:** Log the paper's final state after all revisions
**Model:** gpt-5.2-2025-12-11
**Paper:** paper.pdf
**Timestamp:** 2026-01-30T07:30:35.283262
**Response ID:** resp_0ab1861331c718c700697c4f427fd88190aa1a1b893105c41d
**Tokens:** 21593 in / 6591 out
**Response SHA256:** 06958209a0dee47b

---

## Referee Report (Top General-Interest Journal Standard)

### Summary / Contribution
The paper asks whether access to legal recreational cannabis reduces alcohol involvement in fatal crashes via substitution. It uses (i) a **spatial regression discontinuity (RD)** at borders between recreational-legal and prohibition states in the western U.S. (2016–2019) using geocoded FARS fatal crashes, and (ii) a complementary **distance-to-nearest-dispensary** analysis within prohibition states using dispensary locations from OpenStreetMap (OSM). The main RD estimate is **+9.2 pp** (SE 5.9 pp), statistically indistinguishable from zero; the distance gradient is also null.

The question is important and policy-relevant. The empirical design is potentially credible. However, as currently executed, I do **not** think the paper meets the bar for AER/QJE/JPE/ReStud/Ecta or AEJ:EP. The main issues are (1) the paper’s estimand is **composition** (share of fatal crashes involving alcohol) rather than alcohol-related harm levels, (2) “access” is weakly measured and not validated (OSM snapshot; no dispensary opening dates; no first-stage), (3) the pooled geographic RD is under-justified and likely contaminated by spillovers and heterogeneous border segments, and (4) inference and design-based validity for a **geographic** RD require more than what is currently provided (spatial correlation, border-by-border identification, randomization/placebo along borders, etc.).

Below I give a demanding, detailed review organized per your requested rubric.

---

# 1. FORMAT CHECK

### Length
- Appears to be **~41 pages total** including appendix figures/tables (page numbers shown through ~41).
- Main text through conclusion is ~33–34 pages, then references and appendix. This **passes** the 25-page threshold.

### References coverage
- References include core marijuana/alcohol and RD basics (Imbens & Lemieux 2008; Keele & Titiunik 2015; Calonico et al. 2014; Dell 2010).
- However, it is **missing several foundational RD references**, key geographic border designs in applied micro, and major cannabis-and-traffic empirical papers. See Section 4 below.

### Prose vs bullets
- Major sections are primarily in paragraph form. Bullets are used mainly for variable lists and mechanisms, which is acceptable.
- That said, the paper reads in places like a **technical report / dissertation chapter**: overly long conceptual model exposition relative to contribution, and “list-like” writing in Data/Methods and mechanisms. For a top journal, you should compress and sharpen the narrative.

### Section depth
- Introduction, conceptual framework, data, empirical strategy, results, and conclusion each have multiple substantive paragraphs. **Pass.**
- But the “Conceptual Framework” is **too long relative to what it buys empirically**—it crowds out space that should be used to defend identification, address threats, and validate treatment intensity.

### Figures
- Figures shown have visible data, axes, and legends (e.g., RD plot with distance axis, alcohol involvement rate). **Pass**, though aesthetics could be improved to journal quality (font sizes, readability, consistent style).

### Tables
- Tables contain real numbers (no placeholders). **Pass.**
- However, several tables (e.g., subgroup RDs, placebo borders) would benefit from **standard RD reporting conventions** (bandwidth, polynomial order, kernel, effective N left/right, bias-corrected vs conventional). Some are partially reported but not consistently.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### a) Standard errors
- The main RD result reports SEs, p-values, and 95% CIs (Table 2). Distance regressions report SEs (Table 4). **Pass**.

### b) Significance testing
- Yes (p-values, tests). **Pass**.

### c) Confidence intervals
- Yes for the main RD. **Pass**, though you should report CIs consistently across *all* key specifications (including heterogeneity and placebo).

### d) Sample sizes
- Reported for main tables (effective N in RD; N in distance regressions). **Pass**, but tighten and standardize reporting.

### e) DiD with staggered adoption
- The paper is not primarily DiD. You mention DiD in motivation, not as main design. So no “TWFE with staggered timing” failure. **Pass**.

### f) RDD requirements (bandwidth sensitivity, McCrary)
- You provide bandwidth sensitivity and a density test discussion. **Pass in spirit**, but not at the level expected for **geographic RD** in a top journal. Specifically:
  1. **Density test interpretation** is hand-wavy (“population imbalance”). In geographic settings, the *running variable density* can jump for benign reasons, but you need design-based checks tailored to geography.
  2. You need to address **spatial correlation** and “effective” degrees of freedom. Crash-level heteroskedastic SEs are not enough in a spatial setting; inference can be anticonservative if outcomes are spatially clustered.

**Bottom line on methodology:** The paper is **not unpublishable due to missing inference**, but the current inference strategy is **not yet adequate** for a top journal geographic RD.

---

# 3. IDENTIFICATION STRATEGY

## 3.1 Is the identification credible?
The core claim is: near state borders, determinants of alcohol involvement in fatal crashes are smooth, while cannabis access changes discontinuously. This is plausible, but there are several major threats that are not fully handled:

### (i) The treatment is not “dispensary access”; it is “state legal status at crash location”
Your RD estimand is the discontinuity in alcohol involvement **by crash location** when crossing a border. But substitution is about **drivers’ consumption choices**, which depend on:
- driver residence,
- where they drank/used,
- where they drove,
- policing/enforcement expectations,
- and cross-border travel patterns.

Using crash location rather than driver residence creates **non-classical exposure mismeasurement**. You acknowledge this, but the paper does not do the key empirical step: **use FARS driver license state / residence proxies** to isolate border residents vs pass-through traffic.

### (ii) Spillovers and SUTVA violations near borders
In border regions, prohibition-state residents can and do buy in legal states. This means:
- Access may be **high on both sides** near the border.
- The discontinuity in “effective access” may be small, even if legalization matters in the interior.

This undermines the interpretation of a null RD as “no substitution.” It may instead mean “border RD has a weak first stage.” A top-journal version needs a **first-stage validation**:
- show discontinuity in *cannabis purchasing*, *THC-positive drivers*, *cannabis DUI arrests*, wastewater THC metabolites, Google Trends, dispensary foot traffic, or survey cannabis use **at the border**.

### (iii) Confounding policies at state borders
You discuss Utah BAC=0.05 and do a robustness exclusion. But borders also differ in:
- alcohol taxes and retail systems (control states),
- on-premise hours, Sunday sales,
- DUI enforcement intensity and penalties,
- seatbelt enforcement,
- speed limits / road design funding,
- cannabis enforcement priorities that may shift policing resources.

Border discontinuities in these could plausibly affect the **composition** of fatal crashes by alcohol involvement.

### (iv) Pooling across many borders with “nearest border” running variable
Pooling multiple border segments using “signed distance to nearest legal-prohibition border” is not obviously valid as a one-dimensional RD forcing variable, because:
- units near the cutoff on the treated side may correspond to a different border segment than units near the cutoff on the control side;
- the relevant local comparison set should be **within the same border segment** (or at least within matched segments).

You mention border fixed effects in one robustness, but (a) that is not integrated into the rdrobust framework in a transparent way, and (b) FE does not solve the core issue that the *local neighborhood* differs across borders.

A more defensible approach:
- estimate RD **separately by border segment** (or by “border commuting zone”), then combine via meta-analysis / partial pooling, and report heterogeneity.

## 3.2 Assumptions and validity checks
- Continuity is discussed and you show some covariate balance (nighttime/weekend/single vehicle/rural). Good start, but insufficient.
- For geographic RD, you should test balance on richer predetermined variables: road functional class, speed limit, weather, lighting, month, holiday indicators, vehicle type mix, etc.

## 3.3 Placebos and robustness
- Placebo “legal–legal” borders are helpful and mostly reassuring.
- But I would expect additional falsifications:
  - “pseudo cutoffs” 25km inside each state (shift the border) to test for spurious discontinuities;
  - placebo outcomes not plausibly affected by cannabis access (e.g., proportion involving motorcycles? daytime single-vehicle not-at-fault?).

## 3.4 Do conclusions follow from evidence?
The paper concludes that the results “challenge the narrative” that legalization reduces alcohol-related harms via substitution. That statement is **too strong given your estimand** (share among fatal crashes near borders) and the likelihood of:
- weak first stage at borders due to spillovers,
- mismatch between crash location and consumption location,
- composition effects.

A more defensible conclusion would be narrower: *“We find no detectable discontinuity in alcohol involvement among fatal crashes at legal/prohibition borders in 2016–2019.”* Claims about substitution mechanisms are second-order without a validated treatment intensity change.

## 3.5 Limitations
You discuss several limitations, which is good. But for a top journal, limitations must be tied to **threats to identification** and empirically addressed where possible (license-state splits; border-by-border analysis; better dispensary data; spatial inference).

---

# 4. LITERATURE (Missing references + BibTeX)

The bibliography is not yet adequate for a top general-interest journal. You need to cite:

## 4.1 Foundational RD / geographic RD methods
1) **Lee & Lemieux (2010, JEL)** — standard RD reference; almost always cited.
```bibtex
@article{LeeLemieux2010,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  number = {2},
  pages = {281--355}
}
```

2) **McCrary (2008)** — canonical density test (you reference “McCrary test” but cite Calonico).
```bibtex
@article{McCrary2008,
  author = {McCrary, Justin},
  title = {Manipulation of the Running Variable in the Regression Discontinuity Design: A Density Test},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  number = {2},
  pages = {698--714}
}
```

3) **Cattaneo, Idrobo & Titiunik (2019 book)** — modern RD theory/practice; useful for standards and reporting.
```bibtex
@book{CattaneoIdroboTitiunik2019,
  author = {Cattaneo, Matias D. and Idrobo, Nicolas and Titiunik, Rocio},
  title = {A Practical Introduction to Regression Discontinuity Designs: Foundations},
  publisher = {Cambridge University Press},
  year = {2019}
}
```

4) Border discontinuity designs in applied micro (not RD per se but central to “borders as identification”):
- **Dube, Lester & Reich (2010)** contiguous-county borders (minimum wage).
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
```

- **Holmes (1998)** classic border approach (right-to-work/manufacturing).
```bibtex
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

## 4.2 Cannabis legalization and traffic safety (must engage directly)
Your citations on traffic/cannabis are quite limited. You should cite prominent empirical studies on recreational legalization and crashes/fatalities, and systematic reviews.

Examples to add (verify exact bibliographic details in your final manuscript):
1) **Santaella-Tenorio et al.** on cannabis laws and traffic fatalities (often cited in public health/econ policy debates).
```bibtex
@article{SantaellaTenorio2017,
  author = {Santaella-Tenorio, Julieta and Mauro, Christine and Wall, Melanie and Kim, John H. and Cerd{\'a}, Magdalena and Keyes, Katherine M. and Martins, Silvia S. and Hasin, Deborah},
  title = {US Traffic Fatalities, 1985--2014, and Their Relationship to Medical Marijuana Laws},
  journal = {American Journal of Public Health},
  year = {2017},
  volume = {107},
  number = {2},
  pages = {336--342}
}
```

2) **Aydelotte et al.** on fatal crashes after recreational legalization (widely cited).
```bibtex
@article{Aydelotte2017,
  author = {Aydelotte, J. D. and Brown, L. H. and Luftman, K. M. and Mardock, A. L. and Teixeira, P. G. and Coopwood, T. B. and others},
  title = {Crash Fatality Rates After Recreational Marijuana Legalization in Washington and Colorado},
  journal = {American Journal of Public Health},
  year = {2017},
  volume = {107},
  number = {8},
  pages = {1329--1331}
}
```

3) **Systematic review** on cannabis and driving impairment / crash risk beyond Hartman & Huestis (2013), e.g., Rogeberg & Elvik meta-analysis (commonly cited).
```bibtex
@article{RogebergElvik2016,
  author = {Rogeberg, Ole and Elvik, Rune},
  title = {The Effects of Cannabis Intoxication on Motor Vehicle Collision Revisited and Revised},
  journal = {Addiction},
  year = {2016},
  volume = {111},
  number = {8},
  pages = {1348--1359}
}
```

## 4.3 Substitution/complementarity literature (economic + policy)
Beyond Anderson et al. (2013) and a few others, you should position against broader evidence:
- Pacula et al. on cannabis policy and consumption responses,
- studies on alcohol/cannabis cross-price elasticities,
- recreational legalization and alcohol sales/taxes (e.g., using Nielsen scanner, tax receipts).

At minimum, add a few economics papers on alcohol substitution using sales/taxes (or credible demand data). (I’m not providing BibTeX here because the “right” set depends on what you actually engage and replicate; but the current lit review is thin for a top journal.)

---

# 5. WRITING QUALITY (CRITICAL)

### a) Prose vs bullets
- Introduction/Results/Discussion are in prose. **Pass.**
- Still, the paper is verbose and sometimes reads like it is explaining RD to the reader rather than making a tight argument. AER/QJE readers expect concision and force.

### b) Narrative flow
- The motivation is clear; the “hook” is serviceable (alcohol deaths; substitution narrative).
- Flow is weakened by the long conceptual model section that does not yield additional identifying variation or testable implications beyond the obvious.

### c) Sentence quality
- Generally competent and readable.
- But there is repeated insistence on “rigor” and “well-identified” that will trigger skepticism unless backed by sharper design-based evidence (border-specific estimates, spatial inference, first-stage validation).

### d) Accessibility
- High for economists; non-specialists can follow.
- However: interpreting a null on **share of fatal crashes** as “no substitution” will confuse careful readers. You must explain why composition is the right policy object (or reframe).

### e) Figures/Tables
- Clear enough for a draft.
- To be publication-quality: consistent formatting, larger fonts, and include key RD reporting elements in notes (kernel, order, bandwidth selection method, left/right N).

---

# 6. CONSTRUCTIVE SUGGESTIONS (How to make it publishable)

## 6.1 Fix the estimand: levels, not shares
Your outcome is “alcohol-involved share among fatal crashes.” Substitution is fundamentally about reducing alcohol harm; the natural outcomes are:
- alcohol-involved fatal crashes per capita / per VMT,
- total fatal crashes (and alcohol-involved separately),
- fatalities (not crashes) involving alcohol.

A compositional outcome can move mechanically if cannabis affects the denominator. If you want composition, you need to be explicit that you are estimating *conditional composition*, not overall harm.

**Recommendation:** Add analyses of **counts/rates** using exposure denominators:
- crash counts in small border strips (e.g., 0–25km bins) normalized by VMT proxies (AADT, HPMS), population, or roadway miles.
- Even if imperfect, it is more aligned with welfare/policy.

## 6.2 Validate the “first stage” (treatment intensity)
A top-journal paper needs evidence that cannabis access truly changes at the border for the relevant population. Options:
- Use FARS drug test indicators (THC-positive drivers, where available) to show a discontinuity.
- Use external data: dispensary foot traffic (SafeGraph/PlaceIQ), Google Trends near borders, wastewater, or state sales data mapped to border counties.
- At minimum, show discontinuity in **distance to dispensaries** and dispensary density by side of border *at the crash location* and year.

Without this, a null RD is hard to interpret.

## 6.3 Border-by-border RD and heterogeneity
Stop relying on a pooled “nearest border” running variable as the main result. Do:
- Separate RD estimates by border segment (CO–WY, CO–UT, OR–ID, WA–ID, NV–UT, etc.).
- Then combine with inverse-variance weighting or hierarchical model.
- Report heterogeneity formally (Q-test / random effects).

This will also clarify whether Utah (0.05 BAC) or specific tourism borders drive patterns.

## 6.4 Improve inference for spatial RD
Crash-level errors are spatially correlated. You should implement at least one of:
- cluster SEs by border segment × distance bin, or by county pairs along borders;
- Conley (spatial HAC) standard errors;
- randomization inference / permutation tests along the border (assign placebo borders or rotate treatment labels along contiguous border points);
- local randomization RD as a robustness.

## 6.5 Replace OSM dispensary data (or seriously qualify it)
OSM is not a defensible primary source for dispensary location/time in a top journal. Use:
- state licensing datasets with addresses and opening dates (CO MED, WA LCB, OR OLCC, NV CCB, CA DCC),
- or commercial directories with historical openings (Weedmaps/Leafly archives), ideally validated.

At minimum, relegate OSM to appendix and show robustness to alternative sources.

## 6.6 Address driver residence and cross-border travel
Use FARS driver license state to restrict to:
- drivers licensed in the state where the crash occurs vs out-of-state,
- border-county residents only,
- or a “likely exposed” subgroup.

If substitution is among residents, pooling in pass-through interstate traffic will attenuate effects.

## 6.7 Reframe claims and strengthen external validity
Even if results remain null, the publishable contribution is: *a careful geographic RD shows no border discontinuity in alcohol involvement in fatal crashes in 2016–2019*. Avoid claiming this “challenges the narrative” without showing that access truly differs and that your estimand maps to harms.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important policy question with a credible motivating hypothesis.
- Uses high-quality fatal crash census data (FARS) with geocodes.
- Implements core RD elements (bandwidth sensitivity, placebo borders, covariate balance, CI reporting).

### Critical weaknesses (in current form)
1. **Wrong (or at least incomplete) outcome for the policy claim**: composition among fatal crashes is not “alcohol-related harms.”
2. **Weak and poorly validated treatment variation**: border spillovers likely collapse the discontinuity in access; OSM dispensary data are not credible for timing and completeness.
3. **Pooling across heterogeneous borders with a “nearest border” forcing variable** needs a more rigorous justification and border-specific analysis.
4. **Spatial inference and design-based validity checks are not sufficient** for a geographic RD at top-journal standards.
5. Conclusions overreach relative to what is identified.

### Specific improvement priorities (highest ROI)
- Add level/rate outcomes; validate a first-stage; border-by-border RD; spatially robust inference; replace OSM with licensing data; incorporate driver residence/license state.

---

DECISION: REJECT AND RESUBMIT