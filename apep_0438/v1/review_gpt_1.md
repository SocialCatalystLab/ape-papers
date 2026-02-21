# GPT-5.2 Review

**Role:** External referee review
**Model:** openai/gpt-5.2
**Paper:** paper.pdf
**Timestamp:** 2026-02-21T19:57:39.251029
**Route:** OpenRouter + LaTeX
**Review mode:** Tri-model (3 independent reviewers)
**Tokens:** 18781 in / 4389 out
**Response SHA256:** 7fda7f780f6ebfda

---

## Referee Report: “Secret Ballots and Women’s Political Voice: Evidence from the Swiss Landsgemeinde”

### Summary
The paper studies whether abolishing the *Landsgemeinde* (public show-of-hands voting for cantonal matters) affected political outcomes—especially gender-related policy preferences—measured using *federal* referendum vote shares (always secret ballot). The main design is a spatial difference-in-discontinuities (DiDisc) at the Appenzell Ausserrhoden (AR) – Appenzell Innerrhoden (AI) border, exploiting AR’s abolition in April 1997 while AI retained the institution. The central result is a precisely estimated zero for the DiDisc interaction (β₃ ≈ −0.0001, SE 0.0043), despite a stable cross-border level gap (AR more “progressive” by ~3–5 pp overall; larger on “gender” referendums).

The question is interesting, the institutional setting is memorable, and the paper is unusually clear about delivering a “well-identified null.” The main challenge is that the outcome is only indirectly affected by the institution (federal secret ballots), raising interpretation and external validity issues. There are also several econometric/inference weaknesses typical of spatial RDD and small-cluster DiD settings that need to be addressed more rigorously for a top general-interest journal.

---

# 1. FORMAT CHECK

### Length
- The LaTeX source suggests a full-length paper with intro through conclusion plus multiple appendices and many figures/tables. Likely **25+ pages excluding references/appendix**, but I cannot verify exact page count from source alone. If the compiled PDF is shorter than ~25 pages of main text, expand discussion and mechanisms/validation.

### References / literature coverage
- The citations include key adjacent topics (social pressure, direct democracy, institutions vs culture, spatial RDD references), but **methodology coverage is incomplete** for:
  - spatial RDD/border designs (needs more core references and best-practice discussion),
  - DiD inference with small number of clusters,
  - modern DiDisc and border DiD work.
- The bibliography is not shown (`references.bib` not included), so I cannot confirm whether all cited entries exist or whether important omissions are present. See Section 4 below for specific missing references and BibTeX.

### Prose vs bullets
- Major sections are written in paragraphs. Good.
- The conceptual framework uses a `description` list; that is fine and not the “bullet-point intro” problem.

### Section depth
- Introduction: clearly 3+ substantive paragraphs.
- Institutional background / data / empirical strategy / results / discussion all have multiple substantive paragraphs. Good.

### Figures
- The paper uses `\includegraphics{...}` calls. In source form I cannot verify axes visibility or data legibility; you do provide captions and notes with axes descriptions, which is good practice.
- One concern: Figure notes claim “fitted lines are local linear regressions” (Fig. 2), but the text also notes rdrobust often fails to converge in AR–AI. Make sure what is plotted matches what is estimated.

### Tables
- Tables contain real numbers (no placeholders). Good.
- However, several tables report coefficients and SEs but **not 95% confidence intervals** (the paper sometimes states a CI in text). For top journals, add CIs systematically in the main tables or as a consistent note.

---

# 2. STATISTICAL METHODOLOGY (CRITICAL)

### (a) Standard errors
- **PASS in main tables:** Table 2 (main) reports SEs in parentheses.
- Cross-sectional border-pair table reports SEs too.
- Some reported results in text (“rdrobust estimate … p=0.967”) do not display SE/CI; not fatal, but improve transparency.

### (b) Significance testing
- **PASS:** p-values and stars are reported; permutation inference is included for a key level effect.

### (c) Confidence intervals
- **Partially FAIL / needs improvement:** You state a 95% CI in text for the main DiDisc, and for gender votes, but the tables do not consistently report CIs.
- Recommendation: For the main estimands (DiDisc for all votes and for gender votes; turnout DiDisc), **report 95% CIs in the main table** (either columns with CI bounds or in notes).

### (d) Sample sizes
- **PASS:** N is reported in the main regression table and summary stats. Also clusters count is reported.

### (e) DiD with staggered adoption
- Not relevant in the “classic” staggered-adoption sense for the headline AR–AI analysis (single border pair, one reform date for AR). So no TWFE staggered timing issue.
- However, you *do* pool multiple border pairs for cross-sectional RDD statements and mention other abolitions (NW 1996, OW 1998). If you later add a panel DiD across multiple cantons with varying abolition dates, then the staggered-adoption issue will become relevant and should be handled with Callaway–Sant’Anna / Sun–Abraham style estimators.

### (f) RDD requirements (bandwidth sensitivity, McCrary)
- **Currently not adequate.**
  - You assert McCrary is “trivially satisfied,” but you do **not actually show a McCrary test output or density plot** (and for spatial RDD with centroids, the McCrary test is conceptually awkward but not meaningless; at minimum show density of the running variable and discuss discreteness).
  - Bandwidth sensitivity is discussed in the appendix in a generic way, but there are not systematic sensitivity plots/tables (e.g., estimated discontinuity vs bandwidth multipliers).
  - More importantly: you frequently rely on **parametric polynomials in distance**, which is now viewed skeptically in RDD practice. For spatial RDD, this is more nuanced, but you should still show robustness to local linear specifications *where feasible* and/or alternative spatial smoothers.

### Additional inference issues (important)
1. **Only 24 clusters (20 vs 4)**
   - Municipality-clustered CRSE with 24 clusters is borderline; with **only 4 clusters on one side**, conventional cluster-robust inference can be unreliable.
   - You partially address with permutation inference, but the permutation is applied to the **cross-sectional level gap**, not the **DiDisc interaction**, which is your causal estimand.
   - Strong suggestion: implement **randomization inference / permutation inference for β₃ (AR×Post)** as well, and/or use **wild cluster bootstrap** designed for few clusters.

2. **Serial correlation and two-way clustering**
   - Your outcome is municipality × referendum; you include referendum fixed effects, but shocks may still be correlated within referendum date across municipalities (national campaign intensity, contemporaneous events). Referendum FE absorbs common levels, but residuals can still be correlated across municipalities for a given referendum due to differential responsiveness, measurement, etc.
   - Consider **two-way clustering (municipality and referendum/date)** or show that it does not matter. With only 379 referendums, two-way clustering is feasible.

3. **Weighting**
   - You treat each municipality-referendum equally. This estimates an average municipality effect, not an average voter effect. That may be fine, but you should be explicit and add a robustness check **weighting by eligible voters** (or total votes) to show the result is not driven by small municipalities.

4. **Functional form / saturation**
   - Since you have signed distance and a border, modern border designs often use **border-segment fixed effects** or allow flexible spatial trends. With only 24 municipalities, you cannot do much, but you can (i) show maps with centroids, (ii) report results excluding the AR capital (Herisau) or excluding the AI capital (Appenzell) to verify one influential unit is not driving patterns.

**Bottom line on methodology:** Not a fatal “no standard errors” situation—your main regressions have inference—but to clear a top journal bar you should substantially strengthen the inferential framework for small-cluster DiDisc and the credibility checks typical in spatial discontinuity designs.

---

# 3. IDENTIFICATION STRATEGY

### Credibility of identification
- The DiDisc logic at a stable historical border is attractive: pre-period identifies cultural discontinuity; post-period difference isolates institutional removal.
- However, there are two identification threats that require deeper treatment:

1. **The “treatment” is indirect (cantonal voting institution → federal voting outcomes).**
   - This is central and you acknowledge it, but it creates ambiguity: a null could mean “institution does not matter,” or “institution matters only for cantonal ballots / participation at Landsgemeinde itself,” or “institution matters but federal secret-ballot outcomes are too downstream/noisy.”
   - In top journals, this needs either (i) complementary outcomes more directly affected, or (ii) very strong mechanism argument and supporting evidence.

2. **AR’s abolition may coincide with broader modernization**
   - You state there were no other major reforms. This is plausible but should be documented.
   - At minimum: show **pre-trends not only in the border gap** but also in some observable modernization proxies (population growth, commuting, education, sectoral employment) if available at municipality level. Even coarse canton-level controls would help.

### Assumptions discussion
- Parallel trends analogue: DiDisc requires that absent abolition, the AR–AI discontinuity would have evolved similarly over time. Your event study is supportive, but it is built from year-by-year regressions with few municipalities.
- Continuity/functional form: spatial RDD relies on smooth potential outcomes in distance at the border. With centroids and few units, this assumption is hard to diagnose.

### Placebos / robustness
Good starts:
- event study,
- donut RDD,
- topic heterogeneity,
- permutation for level effect.

Still missing/should add:
- **Permutation / randomization inference for the DiDisc interaction** (key).
- **Placebo borders**: use borders where no institutional change occurred in 1997 but estimate a “fake DiDisc” at 1997 to show you don’t mechanically get zero/nonzero. For example:
  - SG–AI border with a placebo “abolition” in 1997 (no abolition in SG, none in AI) should show no DiDisc break.
  - Or use AR border with a non-AI neighbor to test whether AR had a structural break in 1997 unrelated to Landsgemeinde.
- **Placebo treatment dates**: re-estimate DiDisc pretending abolition happened in, say, 1993 or 2001. The distribution of placebo β₃’s is a compelling visualization.
- **Sensitivity to clustering/inference method**: wild cluster bootstrap p-values; randomization inference.

### Do conclusions follow?
- The conclusion “Landsgemeinde does not cause conservative voting; it correlates with culture” is plausible given the stability, but it is **too strong** given the indirect mechanism and limited power for gender referendums (MDE ~7pp).
- A more defensible statement: “Abolition did not measurably change federal referendum voting near the border; any effect on federal outcomes is smaller than ~1pp (overall) and cannot be ruled out up to ~7pp for gender issues.”

### Limitations
- You list several limitations candidly (small AI sample; indirect mechanism; power). Good.
- I would elevate the indirect-mechanism limitation from “one of several” to “the central limitation,” and outline a concrete plan to test more proximal outcomes.

---

# 4. LITERATURE (MISSING REFERENCES + BIBTEX)

## Key missing methodology references
1. **Difference-in-discontinuities design foundations / applications**
   - You use the term DiDisc but do not cite core references establishing it and its assumptions.
   - Add:
     - Grembi, Nannicini & Troiano (2016) on DiDisc in fiscal rules (very commonly cited for DiDisc).
2. **Spatial/border RDD and geographic discontinuities**
   - You cite Keele & Titiunik (2015) and Dell (border work), but the border discontinuity literature is larger; add at least one canonical geographic RDD reference and discussion of pitfalls.
3. **Small-cluster inference**
   - With 24 clusters and very unbalanced sides, you should cite wild cluster bootstrap / randomization inference references used in applied micro.

## Suggested BibTeX entries

```bibtex
@article{GrembiNanniciniTroiano2016,
  author  = {Grembi, Veronica and Nannicini, Tommaso and Troiano, Ugo},
  title   = {Do Fiscal Rules Matter?},
  journal = {American Economic Journal: Applied Economics},
  year    = {2016},
  volume  = {8},
  number  = {3},
  pages   = {1--30}
}
```

```bibtex
@article{CameronGelbachMiller2008,
  author  = {Cameron, A. Colin and Gelbach, Jonah B. and Miller, Douglas L.},
  title   = {Bootstrap-Based Improvements for Inference with Clustered Errors},
  journal = {Review of Economics and Statistics},
  year    = {2008},
  volume  = {90},
  number  = {3},
  pages   = {414--427}
}
```

```bibtex
@article{RoodmanNielsenMacKinnonWebb2019,
  author  = {Roodman, David and Nielsen, Morten {\O}rregaard and MacKinnon, James G. and Webb, Matthew D.},
  title   = {Fast and Wild: Bootstrap Inference in Stata Using Boottest},
  journal = {Stata Journal},
  year    = {2019},
  volume  = {19},
  number  = {1},
  pages   = {4--60}
}
```

```bibtex
@article{GelmanImbens2019,
  author  = {Gelman, Andrew and Imbens, Guido},
  title   = {Why High-Order Polynomials Should Not Be Used in Regression Discontinuity Designs},
  journal = {Journal of Business \& Economic Statistics},
  year    = {2019},
  volume  = {37},
  number  = {3},
  pages   = {447--456}
}
```

```bibtex
@article{CattaneoIdroboTitiunik2019,
  author  = {Cattaneo, Matias D. and Idrobo, Nicolas and Titiunik, Rocio},
  title   = {A Practical Introduction to Regression Discontinuity Designs: Foundations},
  journal = {Cambridge Elements: Quantitative and Computational Methods for Social Science},
  year    = {2019}
}
```

If you expand beyond AR–AI into staggered adoption (NW/OW/AR), then you must also cite (and likely use):
- Callaway & Sant’Anna (2021), Sun & Abraham (2021), Goodman-Bacon (2021). (You currently mention Goodman-Bacon only implicitly; not cited.)

---

# 5. WRITING QUALITY (CRITICAL)

### Prose vs bullets
- **PASS.** The paper reads like a conventional journal article, not bullet slides.

### Narrative flow
- Strong hook, clear setting, clear main result. The “institutional fossil” framing is effective.
- One narrative weakness: the paper sometimes treats the DiDisc as directly “public vs secret voting,” but then later clarifies federal referendums are always secret. This can confuse readers about what is being tested. The introduction should more explicitly say: *“We test whether a public cantonal institution spills over into federal secret-ballot choices via norms/social pressure.”*

### Sentence quality / accessibility
- Generally crisp and accessible.
- You do a good job stating magnitudes (pp differences) and relating to hypotheses.

### Tables clarity
- Tables are readable with notes. Add:
  - explicit 95% CIs in the table,
  - clarification whether coefficients are in share points (0–1) vs percentage points (currently 0.034 is 3.4pp but many readers may misread).

### One important writing/positioning issue
- The paper markets itself as “first causal test” of public vs secret voting effects on women’s voice. That may be overstated given:
  - the outcome is not public voting; it’s secret-ballot federal referendums,
  - the treatment is abolishing a cantonal institution, not switching the federal ballot.
- Rephrase contribution as “first causal test of whether eliminating a highly public cantonal voting institution changes downstream political preferences as expressed in federal secret ballots,” unless you add cantonal outcomes.

---

# 6. CONSTRUCTIVE SUGGESTIONS (TO INCREASE IMPACT)

## A. Measure more proximal outcomes (highest priority)
To convincingly speak to “secret ballot and women’s political voice,” consider adding outcomes closer to the treatment:

1. **Cantonal voting outcomes / cantonal referendums** in AR pre/post (and AI as control), where the Landsgemeinde directly applied pre-1997.
   - If canton-level ballots exist in administrative data, you could examine whether AR’s cantonal decisions changed after the switch to secret ballots.
   - This would be much more directly aligned with the mechanism of social pressure.

2. **Gender gap in political participation** if available:
   - turnout by gender (possibly from surveys or administrative registers),
   - women elected to cantonal offices,
   - candidacies / office-holding.

Even descriptive evidence here would help the causal story.

## B. Strengthen inference for the DiDisc interaction
- Implement **wild cluster bootstrap** p-values for β₃.
- Add **randomization inference for β₃**:
  - permute which municipalities are “treated side” *and* (optionally) placebo treatment dates.
- Consider **Fisher exact-style randomization inference** at the municipality level using aggregated pre/post means (collapse to 24 units, compute DiD in means) to show robustness.

## C. Clarify estimand and units
- Decide whether the estimand is:
  - average municipality effect (unweighted), or
  - average voter effect (weighted).
- Report both as robustness.

## D. Revisit spatial RDD implementation choices
- Centroid distance is common but can be noisy in irregular polygons. Robustness:
  - distance from **nearest boundary point to municipality polygon** (not centroid),
  - population-weighted centroids (if available).
- Avoid relying heavily on polynomial distance controls; show local linear with bandwidth choice when feasible, and show that results do not hinge on quadratic vs linear (you already do some of this).

## E. Placebo and falsification tests
- Placebo reform year tests (1993/2001).
- Other borders placebo DiDisc in 1997.
- Outcomes that should not respond (e.g., topics plausibly unrelated to social norms) as “negative controls,” though interpret carefully.

## F. Interpretation of “culture dominates”
- Your discussion floats a possibility that Landsgemeinde left a persistent cultural imprint that abolition cannot reverse. That is important and should be incorporated more formally:
  - Your design identifies a **short/medium-run effect of removing the institution**, not the long-run historical effect of having had the Landsgemeinde for centuries.
  - In other words, the null is about *marginal change* in the 1997 institutional form, not about the total effect of centuries of institutional experience.

---

# 7. OVERALL ASSESSMENT

### Key strengths
- Memorable and important institutional setting; clear motivation.
- Clean empirical idea (DiDisc at a sharp border) and transparent presentation.
- Honest reporting of a null with power calculations.
- Event-study visualization is compelling and aligns with the main estimate.

### Critical weaknesses (fixable but substantial)
1. **Inference for the main causal parameter (DiDisc interaction) is not yet top-journal-ready** given 24 clusters and severe imbalance; permutation inference is currently focused on the level gap, not the DiDisc.
2. **RDD/Geographic discontinuity validation is thin** (no displayed density, no systematic bandwidth sensitivity, reliance on parametric polynomials).
3. **Outcome is downstream/indirect**, making the leap to “secret ballot and women’s political voice” too strong without complementary evidence on cantonal outcomes or participation.

### Specific improvements to prioritize
- Add wild cluster bootstrap + randomization inference for β₃.
- Add placebo dates/borders.
- Add weighted regressions and two-way clustering.
- If feasible, incorporate cantonal outcomes or direct measures of women’s political behavior.

---

DECISION: MAJOR REVISION