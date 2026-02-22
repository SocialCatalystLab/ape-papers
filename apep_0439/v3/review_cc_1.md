# Internal Review — Claude Code (Round 1)

**Role:** Reviewer 2 (harsh, skeptical)
**Paper:** paper.pdf
**Timestamp:** 2026-02-22

---

## PART 1: CRITICAL REVIEW

### Format Check
- **Length:** 25 pages main text (verified via `\label{apep_main_text_end}` on page 25). Passes.
- **References:** 30 references covering Swiss cultural economics, RDD methodology, culture and identity, gender economics, econometrics. Adequate.
- **Prose:** All major sections in paragraph form. No bullet-point results.
- **Section depth:** All major sections have 3+ paragraphs. Framework section is well-developed.
- **Figures:** 7 figures, all with visible data and proper axes.
- **Tables:** 6 tables with real numbers, no placeholders.

### Statistical Methodology
- SEs reported for all regressions (municipality-clustered). PASS.
- 95% CIs reported for main results. PASS.
- Permutation inference with 500 iterations. Language p < 0.002, interaction p = 0.936. Well-executed.
- N reported for all regressions (8,727 in main, 8,723 with controls — 4 obs dropped for missing controls, should be noted).
- Not DiD or RDD — this is a cross-sectional/panel OLS with predetermined treatments. Appropriate method.

### Identification Strategy
- Language and religion are historically predetermined (5th century, 16th century). Credible.
- Within-canton estimates absorb institutional differences. Strong.
- Falsification with non-gender referenda is excellent — shows complete reversal of main effects.
- Spatial sorting concern acknowledged but not directly tested. Minor weakness.
- No formal spatial RDD — authors acknowledge this limitation honestly.

### Key Weaknesses
1. **Referendum-specific interactions are not always zero**: The paper acknowledges sign-switching (+3.4pp in 1981, -4.8pp in 2020), but the "modularity" framing implies a universal null. The sign-switching itself is interesting and underexplored — why would the interaction be positive for equal rights but negative for paternity leave?

2. **Power for individual referenda**: With ~1,450 obs per referendum, SEs on the interaction are ~1.0-1.4pp. This means the paper has limited power to detect interactions below ~2-3pp per referendum. The aggregate precision is much better (SE = 0.83pp).

3. **No municipality-level covariates beyond size and turnout**: Census-derived income, education, or foreign-born share would strengthen identification. However, since treatments are predetermined, omitted variable bias concerns are mitigated.

4. **Permutation figure**: Caption says two panels (language left, interaction right) but should verify both are rendered correctly.

### Literature
- Core Swiss spatial literature well-covered (Eugster et al., Basten & Betz, Fässler et al.).
- Cultural economics framework (Alesina & Giuliano, Fernández, Tabellini) present.
- Missing: Autor et al. (2023) on culture and voting; Giuliano & Nunn (2021) on cultural change.
- The Crenshaw (1989) citation is bold and effective — connects intersectionality to economics.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Explore the sign-switching**: The interaction flips from positive (1981, 2002) to negative (2020, 2021). Is this a cohort effect? A modernization effect? This pattern is more theoretically interesting than "zero on average."

2. **Add Oster (2019) bounds**: Even though treatments are predetermined, computing delta/Rmax would quantify how large selection on unobservables would need to be to generate the null interaction spuriously.

3. **Consider a formal spatial RDD**: Even a simple distance-to-border specification within bilingual cantons would strengthen the within-canton results.

4. **Promote the interaction plot**: The parallel-lines interaction plot (currently Appendix Figure 7) should be in the main text. It is the most intuitive visualization of modularity.

## OVERALL ASSESSMENT

**Strengths:** Excellent conceptual framing ("modularity"), clean empirical setting, honest reporting of corrected results, dramatic falsification test (sign reversal on non-gender referenda), well-written prose.

**Weaknesses:** Limited covariates, referendum-specific interactions are non-trivial (undermines "consistently zero" claim), no spatial RDD component.

**Verdict:** This is a solid, well-framed paper with an interesting null result. The modularity test is genuinely novel. The main effects are large and precisely estimated. The paper would benefit from acknowledging that individual-referendum interactions are sometimes significant while the pooled estimate is zero due to sign-switching.

DECISION: MINOR REVISION
