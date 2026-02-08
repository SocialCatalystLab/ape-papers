# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Medicaid Postpartum Coverage Extensions and PHE Unwinding
**Date:** 2026-02-03

## PART 1: CRITICAL REVIEW

### 1. Format Check
- **Length:** Approximately 27-28 pages of main text (excluding references/appendix). PASS.
- **References:** Bibliography covers key methodological papers (Callaway & Sant'Anna, Goodman-Bacon, Sun & Abraham) and relevant policy literature. PASS.
- **Prose:** All major sections written in paragraph form. PASS.
- **Section depth:** All sections have 3+ substantive paragraphs. PASS.
- **Figures:** 5 figures with visible data and proper axes. PASS.
- **Tables:** 4 tables with real numbers. PASS.

### 2. Statistical Methodology
- **Standard errors:** All coefficients have SEs in parentheses. PASS.
- **Significance testing:** Bootstrap inference via CS-DiD, clustered SEs for TWFE. PASS.
- **Confidence intervals:** 95% CIs reported in event study. PASS.
- **Sample sizes:** N reported in Table 2 (added state-years and observations rows). PASS.
- **DiD with staggered adoption:** Uses Callaway & Sant'Anna (2021) as primary, TWFE as biased benchmark. Goodman-Bacon decomposition provided. PASS.
- **set.seed:** Present in both 03_main_analysis.R and 04_robustness.R. PASS.

### 3. Identification Strategy
- Parallel trends pre-test: p-value = 0.994 for Medicaid outcome. Strong support.
- Placebo tests: High-income postpartum (null), non-postpartum low-income (null). Good.
- Placebo outcome: Employer insurance shows significant negative effect (-3.2pp), which is concerning. Paper discusses this as pandemic labor market disruption. Acceptable but warrants more attention.
- PHE confounding acknowledged extensively and framed as the paper's central contribution.
- Control group: 22 not-yet-treated/never-treated states, stronger than the 2 never-adopters alone.
- Limitation: Only 1 post-treatment year for the 2022 cohort (which is 25 of 29 treated states). This limits the event study dynamics.

### 4. Literature
- Key methodological citations present (Callaway & Sant'Anna 2021, Goodman-Bacon 2021, Sun & Abraham 2021, de Chaisemartin & D'Haultfoeuille 2020).
- Policy literature cited (Daw et al. 2020, Gordon et al. 2022, McManis 2023).
- Maternal health literature cited (Hoyert 2023, Petersen et al. 2019, Eliason 2020).
- Missing: Rambachan & Roth (2023) on honest parallel trends (cited in bib but not used in analysis). Consider applying HonestDiD sensitivity analysis.

### 5. Writing Quality
- Prose is clear, well-organized, and reads like a journal submission.
- Strong narrative arc: maternal mortality crisis -> policy response -> PHE interaction -> empirical evaluation.
- The PHE suppression hypothesis is well-developed and interesting.
- Good use of institutional detail.

### 6. Constructive Suggestions
1. The counterintuitive positive uninsurance result (+2.4pp) needs more robustness. Consider showing it's not present in sub-periods.
2. A simple power calculation in the text would help justify why the null result is not surprising given sample size and PHE confounding.
3. Consider a triple-difference approach (postpartum vs non-postpartum, within treated vs control, before vs after) to address PHE confounding.

### 7. Overall Assessment
- **Strengths:** Novel policy evaluation with modern methods, excellent institutional analysis, honest null result with compelling explanation, appropriate placebo tests.
- **Weaknesses:** Limited post-treatment period (1 year for most treated states), counterintuitive uninsurance result, employer insurance placebo failure.
- **Overall:** Solid working paper with important policy implications. The PHE interaction story is the main contribution.

DECISION: MINOR REVISION
