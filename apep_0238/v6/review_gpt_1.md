# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-15T00:31:58.577369
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 35321 in / 4954 out
**Response SHA256:** dac44187b91abc0a

---

## Referee Report: “Demand Recessions Scar, Supply Recessions Don't: Evidence from State Labor Markets”

### Summary
This paper compares the labor-market persistence of the Great Recession versus the COVID recession using cross-state variation in exposure and a local-projection (LP) design. The headline claim is that demand-driven downturns generate persistent “scarring” in employment while supply-driven downturns do not. Empirically, the paper estimates cross-sectional LP coefficients at multiple horizons (up to 120 months for the Great Recession and 48 for COVID) and finds persistent negative effects of Great Recession housing-boom exposure, but rapid mean reversion to zero for COVID Bartik exposure. The paper then rationalizes the asymmetry with a DMP model augmented with participation and skill depreciation; it uses counterfactuals to attribute a large share of welfare losses to skill depreciation.

The topic is important and of broad interest. The empirical patterns are provocative and clearly presented. My main concerns are (i) whether the empirical design cleanly identifies “demand vs supply” rather than “financial/housing-crisis recession vs pandemic recession with extraordinary policy and recall/temporary-layoff dynamics,” and (ii) whether the inference and interpretation are fully aligned with the small cross-section (N=50) and with shift-share best practices. These issues look *fixable* with additional analyses, tighter framing, and somewhat more disciplined inference and interpretation. I view this as a promising paper that needs a substantial revision to meet top general-interest standards.

---

# 1. FORMAT CHECK

### Length
- The LaTeX source appears to be **well above 25 pages** excluding references/appendix (likely ~40–60 pages including appendix and exhibits). **Pass**.

### References / bibliography coverage
- The in-text citations cover many relevant areas: hysteresis (Blanchard & Summers), local projections (Jordà), housing-demand channel (Mian & Sufi), long-term unemployment (Kroft et al.), COVID labor-market papers (Cajner et al., Barrero et al.), shift-share methods (Adao et al., Borusyak et al.), etc.
- However, several important literatures/method papers are either missing or insufficiently engaged (see Section 4 below for concrete additions and BibTeX). **Mostly pass, but should be strengthened.**

### Prose vs bullets
- Major sections are in **paragraph form**, not bullet lists. Robustness section begins with a sentence listing items; acceptable, though ideally include at least a short paragraph motivating which robustness checks matter most and what they imply. **Pass**.

### Section depth (3+ substantive paragraphs)
- Introduction, Background, Framework, Data, Strategy, Results, Mechanisms, Model: all have substantial paragraphs.
- Robustness section in main text is short (1–2 paragraphs plus a figure). Consider expanding it in the main text to 3+ substantive paragraphs, relegating details to appendix. **Minor issue.**

### Figures
- Figures are included via `\includegraphics{...}` and have captions/notes. Since I am reviewing LaTeX source (not rendered PDF), I cannot verify axes/data visibility; I will not flag that as missing. Captions generally specify what is plotted. **Pass, conditional on rendered quality.**

### Tables
- Tables contain real numeric values, SEs, Ns, etc. No placeholders. **Pass**.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors for coefficients
- Main tables report **HC1 SEs in parentheses** (e.g., Table 2 “Local Projection Estimates,” Table 3 IV, mechanism tables). **Pass**.

### (b) Significance testing / inference tests
- You report conventional stars, plus **permutation p-values** and **wild cluster bootstrap p-values** for Table 2. This is good practice given N=50 and 9 clusters.
- Some other tables (e.g., mechanism, appendix UR/LFPR) rely only on HC1. Given the emphasis on finite-sample concerns, you should either (i) report the same “three inference approaches” consistently for all main outcomes, or (ii) clearly justify why only Table 2 gets the enhanced inference. **Mostly pass but inconsistent.**

### (c) Confidence intervals
- Figure 4 shows shaded **95% CIs (HC1)**. IV table provides AR 95% CI. Good.
- But the *main numeric tables* do not report 95% CIs for key coefficients (only SEs/p-values). Top journals often accept SEs, but your own reviewer prompt asks for 95% CIs for main results; adding a CI column/row for the key horizon(s)—especially h=48 for both recessions—would improve readability and discipline. **Minor fix recommended.**

### (d) Sample sizes
- Table 2 explicitly reports N=50. Other tables also show N. **Pass**.

### (e) DiD with staggered adoption
- Not applicable. You are explicit you are not running staggered TWFE. **Pass**.

### (f) RDD requirements
- Not applicable. **Pass**.

### Additional methodology issues to address (important)
1. **Serial correlation across horizons / multiple testing across h.**  
   LPs are estimated separately by horizon; with many horizons (especially 3-month grid), readers will worry about “significance hunting.” You partially address this with IRF plots and half-life. Consider adding:
   - a **family-wise** or **uniform confidence band** approach over horizons (e.g., Romano–Wolf stepdown; or bootstrap-based uniform bands),
   - or at minimum a discussion that inference is not based on a single cherry-picked horizon and show stability of the sign over a prespecified range (e.g., h=24–84).
2. **Few-cluster bootstrap with 9 clusters** is good, but you should be explicit that the division-cluster bootstrap is the preferred inferential device (HC1 can be misleading). In Table 2, several coefficients have HC1 stars but wild-bootstrap p-values that are much larger (e.g., GR at h=12 has HC1 p<0.10 but wild bootstrap {0.101}). Your narrative should reflect the more conservative inference.

---

# 3. IDENTIFICATION STRATEGY

### What works well
- The “single event date, continuous exposure” design is conceptually clean and avoids staggered-adoption DiD pitfalls.
- Housing-boom exposure is a standard and intuitive measure for the Great Recession (Mian & Sufi style).
- COVID Bartik based on pre-2020 industry shares interacted with national industry shocks is also standard for measuring initial COVID incidence.
- You include pre-trend tests (event study) and migration check using emp/pop.

### Key concerns (need serious strengthening)

#### 3.1. Are you identifying “demand vs supply” or “Great Recession vs COVID”?
The paper’s central causal claim is about **shock type**. But empirically you compare **two specific episodes** that differ along many dimensions besides demand/supply:

- scale and composition of fiscal/monetary responses (ZLB constraints, ARRA vs massive transfers),
- institutional features of temporary layoffs/recall (especially important in COVID),
- sectoral shutdown policies and reopening dynamics,
- health risks and labor supply responses,
- measurement and seasonal-adjustment challenges in early COVID data.

You do acknowledge this partially (Conceptual Framework caveat; Conclusion limitations), but to sustain the paper’s strong title claim, you need either:
- (i) stronger empirical tests that *within each recession* isolate “demand-like” versus “supply-like” components, or  
- (ii) a reframing that the result is “financial/housing-demand collapses create scarring; pandemic shutdowns with recall do not,” with demand/supply treated as an interpretive lens rather than the object of identification.

Concretely, I recommend adding at least one of the following:

1) **Within-Great-Recession “supply-ish” exposure** vs “demand-ish” exposure.  
   You already compute a Great Recession Bartik measure in the appendix. Bring it into the main text more prominently and sharpen interpretation: does an industry-composition (sectoral) shock in 2008–09 show less persistence than housing-net-worth exposure *within the same episode*? This would help separate “demand channel” from “recession episode.”

2) **Within-COVID “demand-ish” exposure**.  
   For example, construct a measure capturing *local demand shortfall* (e.g., exposure to high-income service consumption, or pre-COVID reliance on in-person consumer spending) and see if those states show more persistence, conditional on initial COVID industry shock. Even if you ultimately find little, showing the attempt will bolster credibility.

3) **Intermediate episodes / external validity.**  
   You mention extending to 2001 or Volcker in future work. For publication, even a shorter extension to the **2001 recession** (and/or early-1980s) using comparable state CES employment could provide a third data point: do “milder demand downturns” show any persistence gradient? Even if power is limited, it helps justify the general claim.

#### 3.2. Housing boom exogeneity and alternative channels
Your OLS reduced-form regressions interpret HPI boom as “demand collapse severity.” But HPI boom correlates with:
- long-run Sun Belt growth, migration, land-use regulation, construction cyclicality,
- sectoral composition (construction/real estate),
- demographic and education composition,
- pre-2007 trend growth and subsequent mean reversion.

You do pre-trend tests and include pre-recession growth controls/region FE. Still, top journals will expect:
- **richer pre-determined controls** (education shares, age structure, manufacturing share, initial housing supply elasticity, unionization, etc.), and/or
- a more explicit discussion that your coefficient is not solely a demand channel but a bundle of local adjustments induced by the housing boom and bust.

Your IV using Saiz elasticity is a good step, but the IV results attenuate and turn positive at long horizons. This creates interpretive tension with the strong scarring narrative. Two suggestions:
- Focus the “causal demand-scarring” claim on horizons where the IV is informative (say h≤48) and be more cautious about very long horizons in the housing design.
- Discuss (and possibly test) **exclusion restriction threats**: Saiz elasticity may be correlated with agglomeration, productivity, long-run growth, and amenity-driven migration, which can affect post-2007 employment trajectories independently of the housing-bust demand channel.

#### 3.3. Shift-share/Bartik identification
You cite Borusyak et al. (2022) and Adao et al. (2019) and mention AKM SEs in robustness checks. Good. But the paper should:
- report the **AKM exposure-robust SEs** for the *main COVID coefficients* in the main table (or an adjacent table/column), not only “in robustness checks.”
- clarify what the “shocks” are (industry-level national employment changes) and justify their exogeneity (pandemic contact-intensity channel) with citations and some evidence.
- consider **Rotemberg weights** / influence diagnostics for the shift-share instrument (Goldsmith-Pinkham, Sorkin, Swift). This is now close to expected in top-journal shift-share designs.

---

# 4. LITERATURE (missing references + BibTeX)

### Key missing / underused method references
1) **Shift-share identification, Rotemberg weights, and diagnostics**  
   - Goldsmith-Pinkham, Sorkin, Swift (2020): foundational for Bartik interpretation and identifying variation.  
   Why relevant: you use a Bartik exposure for COVID (and also GR Bartik in appendix). This paper provides the modern econometric framing and diagnostics (influence of industry shocks, Rotemberg weights).
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

2) **Local projections inference and interpretation / state dependence**
   - Plagborg-Møller and Wolf (2021): LPs vs VARs and inference properties; very relevant given centrality of LPs.
   ```bibtex
   @article{PlagborgMollerWolf2021,
     author = {Plagborg-M{\o}ller, Mikkel and Wolf, Christian K.},
     title = {Local Projections and {VAR}s Estimate the Same Impulse Responses},
     journal = {Econometrica},
     year = {2021},
     volume = {89},
     number = {2},
     pages = {955--980}
   }
   ```
   (You cite “plagborg2021local” but ensure the exact reference is included and correctly specified.)

3) **Uniform confidence bands / multiple-horizon inference** (optional but valuable)
   - Romano and Wolf (2005, 2016) stepdown methods are widely used; or recent macro LP work on uniform bands. If you implement stepdown, cite it.
   ```bibtex
   @article{RomanoWolf2005,
     author = {Romano, Joseph P. and Wolf, Michael},
     title = {Stepwise Multiple Testing as Formalized Data Snooping},
     journal = {Econometrica},
     year = {2005},
     volume = {73},
     number = {4},
     pages = {1237--1282}
   }
   ```

### Missing / underemphasized hysteresis and labor-market persistence references
4) **Deeper hysteresis evidence and mechanisms**
   - Blanchard and Summers (1986) is cited; consider also:
   - Ball (2009) on hysteresis in unemployment (if not already), and  
   - Nakamura & Steinsson type work on multipliers/hysteresis is optional depending on scope.  
   One very relevant modern paper:
   - **Nakamura and Steinsson (2014)**? (More fiscal multipliers than hysteresis per se.)  
   Alternatively:
   - **Jordà, Schularick, Taylor (2016)** on macro-financial recessions and recoveries could help position the “financial demand recessions are different” angle.
   ```bibtex
   @article{JordaSchularickTaylor2016,
     author = {Jord{\`a}, {\`O}scar and Schularick, Moritz and Taylor, Alan M.},
     title = {The Great Mortgaging: Housing Finance, Crises, and Business Cycles},
     journal = {Economic Policy},
     year = {2016},
     volume = {31},
     number = {85},
     pages = {107--152}
   }
   ```

### COVID labor market “temporary layoffs/recall” literature
5) You cite Fujita & Moscarini-style recall dynamics (fujita2017recall). For COVID specifically, consider citing work emphasizing temporary layoffs and recall:
   - e.g., **Hall and Kudlyak** on unemployment flows and recalls during COVID (if you use/mention recall prominently).
   ```bibtex
   @article{HallKudlyak2020,
     author = {Hall, Robert E. and Kudlyak, Marianna},
     title = {Unemployed with Jobs and without Jobs},
     journal = {Review of Economics and Statistics},
     year = {2022},
     volume = {104},
     number = {5},
     pages = {1008--1021}
   }
   ```
   (Year/journal may differ depending on final publication details; please verify exact bibliographic info.)

### Place-based adjustment / migration and GE spillovers
6) You cite Beraja et al. (2019). Also consider:
   - **Feyrer, Sacerdote, Stern** type results?  
   - More directly, **Moretti** for local labor markets and spatial equilibrium framing, if not cited.
   ```bibtex
   @book{Moretti2011,
     author = {Moretti, Enrico},
     title = {Local Labor Markets},
     publisher = {Handbook of Labor Economics, Volume 4B},
     year = {2011},
     editor = {Ashenfelter, Orley and Card, David},
     pages = {1237--1313}
   }
   ```
   (This is a handbook chapter; format accordingly if you prefer `@incollection`.)

---

# 5. WRITING QUALITY (CRITICAL)

### (a) Prose vs bullets
- Major sections are properly written in paragraphs. **Pass**.

### (b) Narrative flow
- The Introduction is engaging and clearly motivates the puzzle with two stark employment paths.
- The structure is logical: background → framework → data → empirical strategy → results → mechanisms → model.
- One flow issue: the paper sometimes *overstates* “demand vs supply” as the single axis explaining the difference, while later acknowledging policy endogeneity and mixed shocks. Tighten the narrative so that claims and evidence align.

### (c) Sentence quality
- Generally strong, readable, and active. Some passages are rhetorically emphatic (e.g., “staggering magnitude,” “442:1”), which risks sounding less scientific unless more carefully caveated (you do caveat some). Consider toning down superlatives in the main text and pushing them into a calibrated “illustrative magnitude” discussion.

### (d) Accessibility / magnitudes
- Magnitudes are usually contextualized (e.g., 1-SD implies 0.8pp lower employment at 48 months). Good.
- For COVID, coefficients are on a Bartik scale that is unintuitive; you partly fix this by plotting standardized IRFs. Consider consistently reporting **per 1-SD exposure** effects in the main tables (not only for the UR mechanism table), to improve interpretability.

### (e) Tables
- Tables are clear with notes. A suggestion: in Table 2, explicitly label the three inference rows (HC1 SE, permutation p, wild bootstrap p) in the leftmost column to avoid confusion for readers skimming.

---

# 6. CONSTRUCTIVE SUGGESTIONS (to strengthen contribution and credibility)

## 6.1. Make the “shock type” claim testable beyond “two episodes”
To justify the title-level generalization, add at least one design element that varies “demand vs supply-ness” *within* an episode or across more episodes. Strong candidates:

1) **Within-episode horse race**: Great Recession HPI exposure vs Great Recession Bartik exposure jointly in the LP:
   \[
   \Delta y_{s,h} = \alpha_h + \beta_h^{HPI} HPI_s + \beta_h^{Bartik} Bartik^{GR}_s + \gamma_h'X_s + \varepsilon_{s,h}
   \]
   If HPI remains persistent while GR-Bartik is less persistent, that is closer to your conceptual claim.

2) **Temporary-layoff/recall channel**: show that states with larger shares of temporary layoffs (from CPS micro or published CPS tabulations, even if only at regional level) recover faster conditional on Bartik exposure. This links the mechanism directly to micro behavior.

3) **Add 2001 recession** as a third episode with a Bartik (industry) and/or demand proxy (tech exposure, investment collapse). Even a smaller appendix analysis would reduce the “sample of two recessions” critique.

## 6.2. Strengthen shift-share credibility
- Report **AKM (Adao–Kolesár–Morales) SEs** for the COVID main coefficients at key horizons (e.g., h=3, 12, 18, 48) in the main results table or an immediately adjacent table.
- Provide **Rotemberg weight diagnostics** (Goldsmith-Pinkham et al. 2020): which industries drive identification? If leisure/hospitality dominates, say so and discuss what that implies.
- Consider a robustness where you **drop the top-weighted industry** (e.g., leisure/hospitality) and show the recovery-to-zero result remains.

## 6.3. Reconcile OLS vs IV at long horizons
Your narrative emphasizes scarring through 7+ years, but IV becomes uninformative/turns positive at long horizons. Options:
- Center the causal claim on **medium-run horizons** where identification is strongest (12–60 months), and treat 84–120 months as descriptive.
- Alternatively, refine the model to allow partial recovery in aggregate demand/productivity rather than a fully permanent shock, which you already note as a reason the model overpredicts long-run persistence.

## 6.4. Consider alternative outcome measures
To connect more directly to scarring and mechanisms:
- Use **employment rate (EPOP)** as the primary outcome (you already do a migration decomposition). Consider moving EPOP closer to the main results.
- If feasible, incorporate **earnings or wage** measures at the state level (QCEW average weekly wage; or CPS MORG) to show persistent income scarring in demand-exposed states, not just employment.

## 6.5. Model discipline and welfare magnitudes
The welfare results are striking but currently feel loosely disciplined by the reduced-form evidence.
- Provide an explicit mapping from the empirical LP coefficient (e.g., at h=48) to the model shock size (\(\Delta a\)) and/or scarring parameter \(\lambda\). Right now you choose a 5% permanent productivity shock; clarify how it is chosen (calibration target).
- Consider reporting welfare under **CRRA utility** as a benchmark (even if illustrative), since risk-neutral CE losses can look implausibly huge. This would preempt skepticism.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Important question with broad relevance: why some recessions leave long shadows.
- Clean, transparent empirical approach with LPs and cross-state exposures; good use of permutation and wild bootstrap inference in the main table.
- Clear empirical takeaway: Great Recession exposure predicts persistent cross-state employment gaps; COVID exposure does not.
- Structural model provides a coherent narrative mechanism (duration dependence/skill depreciation) consistent with observed long-term unemployment patterns.

### Critical weaknesses (fixable but substantial)
- The paper risks **over-identifying “shock type”** with “episode” (GR vs COVID). Without within-episode tests or additional episodes, the core general claim remains vulnerable.
- Shift-share/Bartik presentation should be modernized with **Rotemberg weights and AKM SEs** prominently reported.
- Inference and narrative occasionally lean on HC1 significance even where the few-cluster bootstrap is more conservative.
- IV evidence is supportive in the medium run but not at long horizons; the paper should harmonize claims with that pattern.

### Bottom line
This is a strong draft with real potential. With added empirical tests that separate “demand vs supply” from “which recession,” more disciplined shift-share inference/diagnostics, and a slightly more cautious (but sharper) framing of what is identified, the paper could become publishable in a top general-interest outlet.

DECISION: MAJOR REVISION