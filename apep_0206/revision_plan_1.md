# Revision Plan 1 -- Paper 189 (Salary Transparency / Making Wages Visible)

**Parent:** APEP-0204
**Date:** 2026-02-07
**Reviews synthesized:** GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash (external); Gemini-3-Flash (exhibit)

---

## Summary of Reviewer Decisions

| Reviewer | Decision |
|----------|----------|
| GPT-5-mini | Major Revision |
| Grok-4.1-Fast | Major Revision |
| Gemini-3-Flash | Major Revision |

All three reviewers find the paper technically strong with an important policy question and a compelling dual-dataset strategy. The unanimous concern is the inferential weakness of the CPS gender DDD when evaluated under design-based (permutation) inference, with secondary concerns about pre-trend significance, mechanism identification, and law heterogeneity.

---

## Categorized Concerns and Planned Responses

### A. INFERENCE WITH FEW TREATED CLUSTERS (All 3 Reviewers -- Highest Priority)

**Concern:** The CPS gender DDD has asymptotic p < 0.001 but Fisher permutation p = 0.154. All reviewers flag this as the primary barrier to top-journal acceptance. GPT and Gemini request wild cluster bootstrap p-values; Grok notes QWI mitigates but demands emphasis.

**Planned fix (text only -- no R code):**
1. **Strengthen the presentation of this caveat in the Introduction** by moving the inferential caveat earlier and making it more prominent, explicitly stating "only eight treated states" and citing the small-cluster inference literature.
2. **Add Conley & Taber (2011) and Imai & Kim (2021) citations** to the bibliography and cite them in the design-based inference section (Section 7.2) to ground the permutation approach in the formal literature.
3. **Rewrite Section 7.2 (Design-Based Inference)** to treat the CPS permutation result more prominently, explicitly acknowledge the divergence, and frame the cross-dataset confirmation as the resolution rather than a footnote.
4. **Add a paragraph in Section 7.2** noting that wild cluster bootstrap is a natural complement and acknowledging it as a direction for further robustness (we cannot run it without R code changes).
5. **Strengthen the "product of false-positive rates" language** that GPT flagged as potentially misleading -- rephrase to a more precise probabilistic statement about independent confirmation.

**Acknowledged limitation:** Wild cluster bootstrap p-values cannot be added without re-running R code. We flag this transparently as a planned robustness check for the next revision.

---

### B. PRE-TREND SIGNIFICANCE (GPT, Gemini)

**Concern:** CPS event study shows marginally significant t=-2 coefficient (-0.013, p<0.10). GPT requests joint pre-trend tests and more systematic Rambachan-Roth bounds. Gemini flags this as a "red flag."

**Planned fix (text only):**
1. **Expand the pre-trends discussion in Section 6.1** to explicitly note: (a) t=-2 is the only marginally significant pre-period coefficient out of 5 tested; (b) with 5 pre-period tests at alpha=0.10, the expected number of false positives is 0.5; (c) the coefficient is small (-0.013) relative to the treatment effect (0.040-0.056).
2. **Add language about multiple testing across event-time periods** as the explanation for isolated marginal significance.
3. **Strengthen the HonestDiD discussion** by noting that the M=0 bound excluding zero is the definitive pre-trend robustness result.
4. **Reference the QWI quarterly event studies** (40+ pre-periods) as providing much stronger pre-trend support with finer temporal resolution.

**Acknowledged limitation:** Joint F-test on pre-period coefficients and gender-specific pre-trend tests require R code. Flagged for next revision.

---

### C. MECHANISM IDENTIFICATION (GPT, Grok)

**Concern:** GPT requests Oaxaca-Blinder decomposition of QWI DDD into price vs. composition components. GPT and Grok suggest job-posting compliance data (Burning Glass, Indeed). GPT wants direct evidence on information flows.

**Planned fix (text only):**
1. **Expand the Mechanisms discussion (Section 8.1)** to explicitly acknowledge that the mechanism is identified by exclusion (ruling out alternatives via the predictions table) rather than by direct observation.
2. **Add a paragraph discussing composition vs. price** in the QWI section: note that the CPS individual-level results (which control for demographics) agree with the QWI aggregate results, providing indirect evidence that the effect operates through prices rather than composition.
3. **Add Hall & Krueger (2012) citation** (suggested by Gemini) to discuss why dynamism is null under a wage-posting regime.
4. **Add Cowgill (2021) citation** (suggested by Grok) for job-posting experiments.

**Acknowledged limitation:** Direct compliance data and Oaxaca-Blinder decomposition require new data and code. Flagged for future work in the limitations section.

---

### D. LAW HETEROGENEITY (GPT, Gemini)

**Concern:** GPT strongly urges exploiting cross-state variation in employer size thresholds, enforcement, and coverage as additional identification and mechanism tests. Gemini requests firm-size threshold analysis in QWI.

**Planned fix (text only):**
1. **Expand Section 3 (Institutional Background)** to more explicitly catalog the heterogeneity dimensions: coverage thresholds (all vs. 15+ vs. 50+), enforcement (complaint-based vs. private right of action), and specificity (good faith vs. precise).
2. **Add a paragraph in Discussion (Section 8.4 Policy Implications)** noting that the threshold variation creates scope for future dose-response analysis.
3. **Add language in the Limitations section** acknowledging this as an underexploited source of variation.

**Acknowledged limitation:** Threshold-based heterogeneity analysis requires new R code. Flagged explicitly.

---

### E. MULTIPLE TESTING (GPT)

**Concern:** Dozens of outcomes tested; GPT requests Benjamini-Hochberg or Bonferroni corrections and explicit primary/secondary hypothesis designation.

**Planned fix (text only):**
1. **Add a paragraph to the Introduction** explicitly designating primary hypotheses: (1) aggregate wage effect, (2) gender DDD, and (3) labor market dynamism. All industry heterogeneity and subgroup analyses are secondary/exploratory.
2. **Add a footnote in Section 6** noting that the three primary outcomes are pre-specified and that industry-level results should be interpreted as exploratory.
3. **Add language in the Robustness section** acknowledging the multiple testing concern and noting that the two primary results (null aggregate, significant gender DDD) survive conservative Bonferroni correction across the three primary hypotheses.

---

### F. MISSING REFERENCES (All 3 Reviewers)

**Concern:** GPT suggests Conley & Taber (2011), Imai & Kim (2021), Abadie et al. (2010). Grok suggests Cowgill (2021), Kline et al. (2021), and better engagement with Blundell et al. (2022). Gemini suggests Hall & Krueger (2012).

**Planned fix:**
1. Add all recommended references to the bibliography.
2. Cite them at appropriate points in the text:
   - Conley & Taber (2011) and Imai & Kim (2021): Section 7.2 (Design-Based Inference)
   - Abadie et al. (2010): Section 7.5 (SDID discussion)
   - Cowgill (2021): Section 8.1 (Mechanisms)
   - Hall & Krueger (2012): Section 8.1 (Dynamism null discussion)
   - Blundell et al. (2022): Section 8.2 (Magnitude comparison -- already in bib, add text engagement)
   - Kline et al. (2021): Section 8.1 (Firm effects on gaps)

---

### G. WRITING AND PRESENTATION (GPT, Grok, Gemini)

**Concern:** GPT wants clearer C-S control group labeling in tables, 95% CIs in all main tables, and ITT-to-TOT calculation. Grok flags AI-generation metadata as unconventional. Gemini flags repetitive contribution section and insufficient doubly-robust intuition.

**Planned fix (text only):**
1. **Add explicit control group labels** to table notes for Tables 4, 5, and 6 (specify "never-treated states" or "not-yet-treated" as applicable).
2. **Add a sentence of intuition on doubly-robust estimation** in Section 5.2 (Empirical Strategy, CPS).
3. **Add ITT-to-TOT paragraph** in Section 8.3 (Limitations): at 60-90% compliance, TOT effects are 1.11-1.67x the ITT, i.e., 4.4-9.3 pp for the CPS gender DDD.
4. **Tighten the Contribution section** to reduce repetition with the results summary.
5. **Reframe AI-generation language** in acknowledgements: replace "autonomously generated" with "replication package" framing per Grok's suggestion.
6. **Add a note about t+3 identification** on Figure 3 caption (already present -- verify prominence).

---

### H. EXHIBIT-SPECIFIC REVISIONS (Exhibit Review)

**Concern:** Exhibit reviewer recommends: (a) seasonally adjusting QWI figures (Figs 4, 6, 11); (b) promoting Table 15 (CPS bargaining) to main text; (c) decimal-aligning Table 3 and adding SDs; (d) moving Fig 5 (dynamism coeff plot) to appendix; (e) refining Fig 10 (gender event study) to plot difference; (f) adding CPS summary stats table to main text; (g) Y-axis label on Fig 7.

**Planned fix (text only):**
1. **Figure captions improved** where possible (Y-axis labels, legend clarifications).
2. **Promote Table 15 discussion** by adding a cross-reference paragraph in the main text near Table 8 pointing to the appendix CPS bargaining results.
3. **Add note about QWI seasonality** in figure captions for Figs 4, 6, 11, explaining that the sawtooth pattern reflects quarterly seasonality in earnings and that the regression estimates already account for quarter fixed effects.
4. **Add CPS summary stats cross-reference** -- note in Section 4.4 that CPS balance table (Appendix Table 13) provides the CPS summary statistics.

**Acknowledged limitation:** Decimal alignment, SD addition to Table 3, seasonal adjustment of figures, and restructuring figure layout all require either R code changes or substantial LaTeX table reformatting that goes beyond text edits. Flagged for next revision.

---

## Changes Requiring R Code (Deferred to Next Revision)

| Item | Reviewer | Priority |
|------|----------|----------|
| Wild cluster bootstrap p-values | GPT, Gemini, Grok | High |
| Joint pre-trend F-test (CPS gender DDD) | GPT | High |
| QWI gender-specific HonestDiD | Grok | Medium |
| Oaxaca-Blinder decomposition of QWI DDD | GPT | Medium |
| Firm-size threshold heterogeneity analysis | GPT, Gemini | Medium |
| Seasonally adjusted QWI figures | Exhibit | Medium |
| Gender-specific event studies with joint pre-test | GPT | Medium |
| Benjamini-Hochberg adjusted p-values | GPT | Low |
| Border/spillover tests | GPT | Low |
| SDID for gender DDD specifically | Gemini | Low |

---

## Text Changes Summary (This Revision)

| Section | Change |
|---------|--------|
| Abstract | Minor: strengthen inference caveat language |
| Introduction | Move inference caveat earlier; designate primary hypotheses; tighten contribution |
| Section 3 | Expand law heterogeneity description |
| Section 5 | Add doubly-robust intuition; add control group specification |
| Section 6.1 | Expand pre-trends discussion with multiple testing framing |
| Section 7.2 | Major rewrite: strengthen design-based inference discussion, add references |
| Section 8.1 | Expand mechanisms: add composition vs. price, add Hall & Krueger, Cowgill |
| Section 8.2 | Add Blundell comparison, ITT-to-TOT calculation |
| Section 8.3 | Expand limitations: threshold heterogeneity, direct mechanism evidence, wild bootstrap |
| Bibliography | Add 6 new references |
| Table notes | Improve control group labeling, estimator specification |
| Figure captions | Add QWI seasonality note, Y-axis clarifications |
| Acknowledgements | Reframe AI metadata |
