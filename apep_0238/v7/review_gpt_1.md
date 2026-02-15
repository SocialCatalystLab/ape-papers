# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T10:12:38.146189
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 38251 in / 4723 out
**Response SHA256:** 575c462fa5ab8833

---

## Referee Report: “Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets”

### Summary and contribution
The paper documents a striking contrast in the persistence of state labor-market downturns after (i) the Great Recession and (ii) COVID-19. Using cross-state “exposure” variation—pre-2007 housing booms for the Great Recession and a COVID Bartik/shift-share instrument for the pandemic—the authors estimate horizon-specific local projections (LPs). They find persistent employment shortfalls in housing-boom states after 2007–09 (half-life ≈ 60 months; negative effects persisting 7+ years) but essentially no persistence in COVID-exposed states after ~18 months. The paper then rationalizes this asymmetry with a DMP-style search model augmented with (i) unemployment-duration-based skill depreciation and (ii) participation exit; the model attributes a large share of welfare losses from “demand shocks” to scarring.

This is an important question with clear policy relevance, and the paper’s empirical core (a transparent cross-sectional LP/event-study around two macro events) is easy to understand and potentially publishable in a top general-interest outlet. However, the current draft has several weaknesses that prevent it from meeting top-journal standards yet—most importantly: (1) the inference and uncertainty presentation is incomplete/inconsistent with the paper’s claims of long-run persistence; (2) the identification argument for “demand vs supply” is not yet tight enough to justify the causal interpretation and the strong welfare/policy conclusions; and (3) the structural model is presented as “calibrated” but is not disciplined by the reduced-form moments in a way that would convince a skeptical reader.

I view the paper as **promising but not yet ready**.

---

# 1. FORMAT CHECK

### Length
- The manuscript appears to be well above **25 pages** excluding references/appendix (likely **~45–70 pages** including extensive appendix). **Pass**.

### References / coverage
- The bibliography in-text is extensive and includes many relevant strands (hysteresis; housing wealth channel; COVID labor markets; Bartik). However, several **foundational and diagnostic papers** for shift-share/Bartik and for local projections/event studies are missing (details in Section 4). **Borderline** for top journal expectations.

### Prose vs bullets
- Major sections (Intro/Background/Framework/Data/Strategy/Results/Mechanisms/Conclusion) are written in **paragraph form**. Bullets are used appropriately in a few places (appendix overview; lists). **Pass**.

### Section depth
- Major sections generally have **3+ substantive paragraphs**. **Pass**.

### Figures
- LaTeX uses `\includegraphics{}`; I cannot verify visual quality, but captions describe axes/CI bands. I will not flag as broken given source review. **No action**.

### Tables
- Tables are populated with real numbers and standard errors; no placeholders. **Pass**.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

## a) Standard errors reported
- Yes, the main tables (e.g., Table 2 / `tab:main`, Table 3 / IV, etc.) report **SEs in parentheses**. **Pass**.

## b) Significance testing
- Yes: stars, permutation p-values (brackets), wild cluster bootstrap p-values (curly braces), AKM SEs (angle brackets) for Bartik. **Pass**, but see concerns below.

## c) 95% confidence intervals for main results
- Figures claim to show 95% CIs; IV table includes AR 95% CI.
- **But** the *main result tables* (Table `tab:main`) do **not** explicitly report 95% CIs, and the narrative emphasizes persistence out to 7 years while many long-horizon coefficients are not statistically distinguishable from zero under the paper’s own preferred inference.
- For a top journal, I strongly recommend that the **headline results** be reported with **explicit 95% CIs** (either in the table, a companion table, or a figure with clearly labeled 95% intervals and an explicit statement about what inference procedure they correspond to). **Currently: partial pass, needs strengthening.**

## d) Sample sizes reported
- Table `tab:main` reports **N=50** (GR/COVID), and other tables report N. **Pass**.

## e) DiD with staggered adoption
- Not applicable: this is not staggered adoption DiD. The authors correctly note this in the Empirical Strategy. **Pass**.

## f) RDD requirements
- Not applicable. **Pass**.

### Critical inference issues to fix (even though SEs exist)
1. **Small-sample inference and “preferred” procedure are not consistently used in interpretation.**  
   You state wild cluster bootstrap p-values are “preferred,” but the prose often cites conventional significance or permutation p-values selectively. For instance, in Table `tab:main` (GR) the long-run horizons (48, 60, 84) are not significant under wild bootstrap (and not under permutation either at 48+), yet the Introduction/Conclusion use language (“deep, persistent scarring,” “remains negative through seven years,” “never fully recovers”) that reads as *statistically established persistence*. A top-journal reader will push back: at long horizons, you often have **imprecise estimates**; you have a **plateau of negative point estimates**, but limited power to reject moderate recovery.

2. **Multiple-horizon reporting without a formal joint inference strategy.**  
   You acknowledge multiple testing, but for a headline claim about persistence vs transience, I would expect at least one of:
   - a **pre-specified summary statistic** with a single test (e.g., average effect 48–84 months; or integral/area under IRF beyond 24 months; or effect at a pre-registered horizon like 48 months), with a 95% CI; and/or
   - a **familywise error rate** control / Romano-Wolf stepdown applied to a small set of key horizons (say 12, 24, 48, 84); and/or
   - a **randomization-inference-based confidence band** across horizons (common in event-study designs).

3. **Choice of clustering and the object being clustered is not fully justified.**  
   Your baseline is HC1 with N=50; then you use wild cluster bootstrap at **9 census divisions**. With only 9 clusters, many readers will worry about cluster definition arbitrariness and residual spatial correlation. Consider:
   - reporting **state-level HC2/HC3** (leverage-adjusted) as an additional check for N=50 cross-sections;  
   - reporting **Conley (spatial HAC)** standard errors as robustness (state centroids, distance cutoff), since shocks and recovery may be spatially correlated;  
   - clarifying why census division is the right dependence structure for errors in a cross-state regression (not just “few clusters”).

**Bottom line:** You have “inference,” but for top journals the *way you summarize and interpret it* needs to be tightened substantially. This is not a fatal flaw, but it is a major revision item.

---

# 3. IDENTIFICATION STRATEGY

### What is credible
- The *empirical fact* that Great Recession recovery was slower than COVID recovery is uncontroversial in national data. Your value-add is tying that to **cross-state exposure gradients** and showing the gradient persists after 2007–09 but not after 2020.
- Using **pre-determined housing boom variation** as a proxy for Great Recession demand exposure is well grounded in the literature (Mian & Sufi and many follow-ups).
- The COVID Bartik design using pre-2020 industry shares × national industry shocks is a standard approach; leave-one-out construction and Rotemberg weights are good practice.

### Key identification gaps / threats
1. **“Demand vs supply” is not identified—“housing-wealth-driven vs sectoral-contact-driven” is.**  
   The paper’s title and causal language assert the nature of the recession (demand vs supply) drives scarring. But empirically you are comparing:
   - Great Recession exposure = housing boom (plus IV with Saiz elasticity), which loads heavily on *construction/real estate/credit* channels and on *place-based booms*; versus
   - COVID exposure = contact-intensive/leisure composition shocks + policy/match-preservation environment.
   
   These packages differ along many dimensions besides “demand vs supply,” including: credit crunch intensity, household leverage, foreclosure externalities, local government finance, sectoral reallocation, remote-work feasibility, and the scale/timing of fiscal transfers.

   The paper needs a clearer identification statement: **what exactly is exogenous, and what causal parameter is being estimated?** As written, the causal claim “supply recessions don’t scar” may be too broad given only two episodes and two exposure measures.

2. **Endogeneity of housing booms to pre-trends and long-run growth fundamentals.**  
   You show pre-trends are flat in employment (good). But a skeptical reader will worry that 2003–06 housing boom states differ in:
   - long-run population growth trends,
   - land-use regulation, amenity growth, and urbanization,
   - industrial composition (beyond your Bartik horse race),
   - longer-run housing supply constraints that shape both boom and post-2009 adjustment.
   
   The Saiz IV helps, but your IV estimates attenuate and even flip at longer horizons (Table `tab:saiz_iv`), and the paper treats that as “expected imprecision.” A top journal will want a more disciplined discussion: **what horizons does the IV credibly speak to?** If IV is only informative through 48 months, you should align the long-run “7-year scarring” narrative accordingly, or provide alternative evidence that long-horizon persistence is not confounding.

3. **COVID “no scarring” could reflect differential policy response correlated with Bartik exposure.**  
   You argue policy is endogenous and you are estimating a “total effect inclusive of policy.” That is acceptable, but then the conclusion should be more careful: the reduced form combines **shock incidence + policy mitigation**. The statement “supply recessions don’t scar” is then partly a statement about **policy feasibility and political economy** during COVID, not purely about shock type.

4. **Migration and composition.**  
   You include an emp/pop check, which is good. But the emp/pop analysis appears to use population data with limitations and different horizon availability; for top-journal standards, you should:
   - more clearly document population measure frequency, interpolation, and timing;
   - provide a consistent set of horizons; and
   - consider using **CPS microdata** (or IRS migration data) to directly decompose employment changes into population vs employment-rate components.

### Placebos / robustness
- Pre-trends are shown; permutation inference is provided.
- You do not yet show sufficiently rich **placebo exposures** (e.g., apply COVID Bartik exposure to 2007 outcomes; apply housing-boom exposure to 2020 outcomes; or use “fake peaks” in non-recession years).
- Consider placebo outcomes: e.g., outcomes plausibly unaffected (public-sector employment? tradable vs nontradable split?) to validate channels.

### Do conclusions follow from evidence?
- The evidence supports: **(i)** Great Recession housing-exposed states had more persistent relative employment declines than less-exposed states; **(ii)** COVID industry-exposed states recovered quickly in relative terms.  
- The stronger interpretation—**demand recessions intrinsically scar whereas supply recessions intrinsically do not**—is suggestive but not yet fully nailed down.

### Limitations
- You mention “sample of two recessions.” Good. But the policy conclusions and welfare ratios are stated very strongly relative to the reduced-form identification strength.

---

# 4. LITERATURE (missing references + BibTeX)

You cite many relevant papers, but several key references are missing or should be engaged more directly.

## (A) Shift-share / Bartik identification and inference
You cite Adao-Kolesár-Morales and Borusyak et al., plus Goldsmith-Pinkham et al. Add:

1. **Borusyak, Hull, Jaravel (2022)** — shift-share designs: assumptions, invalidity modes, and practical guidance.  
```bibtex
@article{BorusyakHullJaravel2022,
  author = {Borusyak, Kirill and Hull, Peter and Jaravel, Xavier},
  title = {Quasi-Experimental Shift-Share Research Designs},
  journal = {The Review of Economic Studies},
  year = {2022},
  volume = {89},
  number = {1},
  pages = {181--213}
}
```

2. **Goldsmith-Pinkham, Sorkin, Swift (2020)** — already cited as “goldsmith2020bartik,” but ensure the formal journal version is referenced and fully discussed as the Rotemberg-weight diagnostic foundation.  
```bibtex
@article{GoldsmithPinkhamSorkinSwift2020,
  author = {Goldsmith-Pinkham, Paul and Sorkin, Isaac and Swift, Henry},
  title = {Bartik Instruments: What, When, Why, and How},
  journal = {American Economic Review},
  year = {2020},
  volume = {110},
  number = {8},
  pages = {2586--2624}
}
```

3. **Kolesár (2013/2015 working paper; and related AKM follow-ups)** — on shift-share standard errors and effective number of shocks (if you rely heavily on AKM SEs, readers expect discussion of “many shocks” conditions). If you prefer journal-only citations, at least add the AKM AER paper you already cite and make explicit how many “shocks” (industries) you truly have (J=10 is small).

## (B) Local projections and inference
You cite Jordà and Ramey; consider adding:
- **Jordà, Schularick, Taylor (2015)** (LPs in macro with historical data; also about persistent effects).  
```bibtex
@article{JordaSchularickTaylor2015,
  author = {Jord{\`a}, {\`O}scar and Schularick, Moritz and Taylor, Alan M.},
  title = {Betting the House},
  journal = {Journal of International Economics},
  year = {2015},
  volume = {96},
  number = {S1},
  pages = {S2--S18}
}
```
(If you want something more directly LP-method oriented, you might cite survey chapters, but top journals will accept Jordà (2005) plus careful exposition.)

## (C) Great Recession local labor markets / housing and employment persistence
You cite Mian & Sufi and Charles et al. Add:
- **Guren, McKay, Nakamura, Steinsson (2021)** on housing wealth, consumption, and labor market dynamics (demand channel).  
```bibtex
@article{GurenMcKayNakamuraSteinsson2021,
  author = {Guren, Adam and McKay, Alisdair and Nakamura, Emi and Steinsson, J{\'o}n},
  title = {Housing Wealth Effects: The Long View},
  journal = {The Review of Economic Studies},
  year = {2021},
  volume = {88},
  number = {2},
  pages = {669--707}
}
```

## (D) Hysteresis / scarring: empirical foundations
You cite Blanchard & Summers; Cerra and others. Consider adding:
- **DeLong and Summers (2012)** (hysteresis and fiscal policy—already cite “delong2012fiscal” but ensure full reference and connect to your policy claims).
- **Fatás and Summers (2018)** is cited; ensure complete bib.

## (E) “Plucking” and asymmetry
You cite Dupraz et al. Good. But you may also want to acknowledge a broader business cycle asymmetry literature (e.g., Sichel 1993; Hamilton 1989-type nonlinearities) if you lean on the “plucking” metaphor, though not strictly required.

---

# 5. WRITING QUALITY (CRITICAL)

### a) Prose vs bullets
- Major sections are paragraphs. **Pass**.

### b) Narrative flow
- The Introduction is strong: salient facts, a clear puzzle, and a simple conceptual distinction. The paper is readable for a general audience.
- However, the paper sometimes **over-claims relative to the statistical evidence** (especially long-horizon “never recovers” language). Tightening claims to match estimands and precision will materially improve credibility.

### c) Sentence quality
- Generally crisp and active.
- Occasional metaphors (guitar string) are engaging, but ensure they do not substitute for careful identification language.

### d) Accessibility
- Econometric choices (LPs, Bartik, permutation inference) are explained reasonably well.
- The model section is long and formal; consider moving some derivations to appendix and focusing the main text on the few mechanisms you actually discipline with data.

### e) Tables
- Tables are mostly self-contained and well-noted.
- Two improvements:
  1. For Table `tab:main`, add explicit **95% CI** columns/rows (for the preferred inference method).
  2. Standardization is inconsistent across main vs appendix tables (raw Bartik in appendices, standardized in main). This invites confusion. Choose one convention and stick to it, or always report both.

---

# 6. CONSTRUCTIVE SUGGESTIONS (to increase impact)

## A. Make the core empirical claim sharper with a pre-specified persistence estimand
Instead of (or in addition to) horizon-by-horizon stars, define one or two primary outcomes:

1. **Long-run scarring index**: average of β̂_h over h ∈ {48, 60, 72, 84} months (Great Recession), with a bootstrap/permutation CI.  
2. **Recovery time metric**: smallest h such that CI includes zero and stays near zero thereafter (with an operational definition).

This would directly support “persistent vs transient” in a way that avoids multiple-testing concerns.

## B. Strengthen the “demand vs supply” interpretation with cross-episode falsifications
Do more cross-episode tests using the same empirical machinery:

- Apply **COVID Bartik exposure** to Great Recession outcomes (2007–2017). If “industry composition” alone does not generate long persistence, that helps isolate the housing/wealth (demand) channel.
- Apply **housing boom exposure** to COVID outcomes (2020–2024). If housing exposure does not predict slower COVID recovery, that supports the idea that housing/credit channels matter specifically for demand-driven recessions.
- Use additional “supply-ish” shocks historically: e.g., natural disasters, oil supply shocks, or sectoral shocks (trade shocks are not “supply recessions,” but they are reallocation shocks). Even one additional episode would reduce the “two recessions” critique.

## C. Clarify what is identified: “shock type” vs “policy package”
Right now, the reduced-form estimates are *inclusive* of policy responses. That’s fine, but then the title and policy conclusions should be framed as:

- “Recessions associated with prolonged hiring collapses (housing/credit demand channel) generate scarring; recessions dominated by temporary separations with match preservation (COVID era) do not.”

Alternatively, if you want a purer shock-type statement, you need evidence that policy differences are not doing the work (hard).

## D. Consider micro validation for the mechanism (even a limited one)
Your story hinges on duration-driven skill loss and participation exit. State-level aggregates have low power. A convincing extension would be to incorporate:

- CPS microdata: duration distributions by state and their relationship with HPI exposure; or
- LEHD/QWI: earnings/employment persistence; or
- UI claims duration by state.

Even descriptive evidence that **long-term unemployment shares** covary with HPI exposure across states after 2008 would directly connect reduced-form persistence to the mechanism.

## E. Discipline the model with the reduced-form moments (or be explicit it’s illustrative)
Top journals will ask: what is the model adding beyond a narrative?
Two options:

1. **Moment matching / indirect inference**: choose λ, χ parameters to match the empirical half-life or the IRF shape (not just external calibration).  
2. If you keep it calibrated, explicitly label welfare numbers as **illustrative**, reduce emphasis on the “330:1” ratio, and show how sensitive it is to risk aversion, savings, and partial recovery of productivity (your own appendix notes the demand shock is fully permanent, unlike reality).

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important and timely question with clear policy relevance.
- Transparent empirical design with intuitive exposure measures.
- Good practice diagnostics for Bartik (Rotemberg weights, leave-one-out).
- The paper is generally well written and well organized.

### Critical weaknesses
1. **Inference/uncertainty is not aligned with long-horizon claims**; multiple-horizon inference is not summarized with a primary estimand.
2. **Identification of “demand vs supply”** is suggestive but not fully credible as a general statement; exposure measures bundle many channels.
3. **Structural model is insufficiently disciplined by the reduced form**, and welfare magnitudes are stated too forcefully given calibration choices (risk neutrality, permanent shock, reduced-form scarring proxy).

### Specific, high-priority fixes
- Introduce a small set of **pre-registered key horizons or summary persistence statistics** with 95% CIs under the preferred inference.
- Add **cross-episode falsification/placebo** exercises (swap exposures across episodes).
- Tighten the causal language: be explicit that you estimate the effect of *exposure measures* (housing boom, COVID industry mix), not shock “type” in general.
- Either discipline the model to match the LP IRFs (even loosely) or scale back the welfare rhetoric.

---

DECISION: MAJOR REVISION