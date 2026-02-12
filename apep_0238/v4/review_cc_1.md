# Internal Review — Claude Code (Round 1)

**Role:** Referee (Reviewer 2 mode — skeptical)
**Paper:** Demand Recessions Scar, Supply Recessions Don't
**Timestamp:** 2026-02-12
**Reviewer:** Claude Code (self-review)

---

## PART 1: CRITICAL REVIEW

### 1. Format Check

- **Length:** 26 pages main text (above 25-page minimum), 53 pages total with appendix. Adequate.
- **References:** Comprehensive coverage of hysteresis (Blanchard & Summers), local labor markets (Autor, Notowidigdo), COVID (Chetty, Cajner), and DMP theory (Shimer, Hall, Pissarides).
- **Prose:** All sections in proper paragraph form. No bullet-point results.
- **Section depth:** Each major section has 3+ substantive paragraphs.
- **Figures:** All 6 main-body figures show real data with proper axes.
- **Tables:** All tables contain real numbers from code-generated output.

### 2. Statistical Methodology

**a) Standard Errors:** All coefficients have HC1 robust SEs in parentheses. PASS.

**b) Significance Testing:** Permutation p-values (1,000 reassignments) reported in brackets alongside asymptotic inference. This is rigorous and appropriate for cross-sectional regressions with N=50. PASS.

**c) Confidence Intervals:** 95% CIs shown in IRF figures via shaded bands. Main table reports SEs and permutation p-values. Adequate.

**d) Sample Sizes:** N=50 (GR) / 50 (COVID) reported in main table, dynamically computed. PASS.

**e) Not applicable (not staggered DiD).

**f) Not applicable (not RDD).

**Concern:** The regression is cross-sectional OLS with N=50. With 5 controls (log pop, pre-growth, 3 region dummies), degrees of freedom = 44. This is adequate but tight. Permutation inference is the right approach here — the paper handles this well.

### 3. Identification Strategy

**Strengths:**
- Housing price exposure as a reduced-form regressor for GR is well-established (Mian & Sufi 2014).
- Bartik instrument for COVID follows Goldsmith-Pinkham et al. (2020) with appropriate shift-share reasoning.
- Pre-trend event study shows flat pre-recession coefficients.
- Controls for log population, pre-recession growth, and region dummies.

**Concerns:**
1. **No first stage reported.** The paper correctly describes these as reduced-form LPs, not IV. But the reader still wants to see the first-stage relationship (housing boom → employment trough; Bartik → COVID trough). Without this, we don't know the instrument's relevance strength.
2. **Exclusion restriction.** Housing exposure may affect long-run employment through channels other than the recession (e.g., construction industry composition, migration patterns). The paper should discuss this more explicitly.
3. **LFPR limited to 20 states.** Secondary outcome analysis (unemployment, LFPR) uses dramatically different samples. The LFPR results are based on only 20 states, which the reader should be cautioned about.

### 4. Literature

Coverage is strong. Missing citations that would strengthen the paper:
- Yagan (2019) — cited, good
- Hershbein & Stuart (2024) on Great Recession skill mismatch
- Berger et al. (2022) on housing wealth and local employment
- Hazell & Taska (2023) on vacancy posting during COVID recovery

### 5. Writing Quality

**Prose:** Excellent. Shleifer-style clarity throughout. The opening paragraph hooks immediately with the 8.7 million vs 22 million job loss comparison.

**Narrative arc:** Strong. Motivation → identification → results → model → conclusion forms a coherent story.

**Active voice:** Consistently used. "I find" not "It was found."

**Minor:** The Data section (Section 4) reads as inventory. Could be more narrative.

### 6. Constructive Suggestions

1. **Add first-stage table.** Even though these are reduced-form LPs, showing the relationship between the instrument and the trough employment decline would strengthen the identification discussion.
2. **Heterogeneity by industry.** Which industries drive the scarring? Manufacturing vs services vs construction? This would connect to the DMP model's skill depreciation mechanism.
3. **Migration channel.** Does the paper control for or discuss interstate migration as an alternative explanation for long-run convergence?

### 7. Overall Assessment

**Strengths:**
- Novel question: first systematic demand vs supply recession comparison
- Rigorous methodology with permutation inference
- Impressive structural model that rationalizes the empirical findings
- Clean writing in the Shleifer tradition

**Weaknesses:**
- Cross-sectional N=50 limits power at longer horizons
- No first-stage results shown
- LFPR secondary analysis limited to 20 states
- Some appendix robustness tables may have stale values from earlier specification

DECISION: MINOR REVISION
