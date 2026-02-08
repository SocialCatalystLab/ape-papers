# Internal Review - Round 1

**Reviewer:** Claude Code (self-review)
**Paper:** Shining Light on Paychecks: Salary Transparency Laws and the Gender Wage Gap
**Date:** 2026-02-06

---

## PART 1: CRITICAL REVIEW

### 1. Format Check
- **Length:** ~25 pages main text + appendix. Meets the minimum.
- **References:** Comprehensive — covers Callaway & Sant'Anna, Goodman-Bacon, Cullen & Pakzad-Hurson, Baker et al., Goldin, and other key cites.
- **Prose:** All major sections in paragraph form. No bullet-point results.
- **Figures:** Event study plots with proper axes and confidence bands.
- **Tables:** All tables contain real numbers with standard errors in parentheses.

### 2. Statistical Methodology
- **Standard errors:** Clustered at state level, reported in parentheses throughout.
- **Significance:** Asymptotic p-values reported. Fisher permutation p-values in robustness.
- **DiD:** Uses Callaway & Sant'Anna (2021) for staggered adoption. TWFE shown only as comparison. PASS.
- **Sample sizes:** N reported in all regression tables.
- **Confidence intervals:** Lee bounds and HonestDiD sensitivity provide interval estimates.

### 3. Identification Strategy
- Credible staggered DiD exploiting state-level adoption of salary transparency laws.
- Parallel trends tested via event study plots.
- Key concern: only 8 treated states, which limits Fisher permutation inference (p=0.154 vs asymptotic p<0.001). Paper discusses this tension honestly in Section 6.7.
- LOTO analysis shows no single state drives results.
- HonestDiD sensitivity analysis provided.

### 4. Weaknesses
1. **Small number of treated clusters (8 states):** This is the paper's fundamental limitation. Design-based inference is inherently weak with so few clusters. The paper acknowledges this but cannot solve it — only time and more state adoptions will help.
2. **CPS ASEC sample size per state-year cell:** Some treated state-year cells may be thin. The paper does not discuss minimum cell sizes.
3. **Aggregate null result:** The main aggregate ATT is null (-0.4%, p=0.717). The gender gap narrowing is the interesting finding but comes from a triple-difference that has even fewer effectively treated observations.

### 5. Writing Quality
- Prose is clean and flows well after revision.
- Abstract is concise (122 words).
- The inferential tension is discussed once in the appropriate section rather than repeated throughout.
- Active voice used throughout.

### 6. Constructive Suggestions
- Report minimum state-year cell sizes to reassure readers about thin cells.
- Consider discussing external validity — would results generalize to states that have not yet adopted?

## OVERALL ASSESSMENT

Strong paper with clean identification, honest reporting of a null aggregate result, and a compelling gender gap finding. The main limitation (8 treated states) is inherent to the policy landscape and well-acknowledged.

DECISION: MINOR REVISION
