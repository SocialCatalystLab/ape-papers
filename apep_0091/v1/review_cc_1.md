# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Alcohol Involvement in Fatal Crashes at Cannabis Legalization Borders
**Date:** 2026-01-30

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length:** 39 pages (including appendix), ~32 pages main text - PASS (exceeds 25 pages)
- **References:** Adequate coverage of RDD methodology (Imbens & Lemieux, Lee & Lemieux, Calonico et al.) and cannabis policy literature
- **Prose:** Major sections written in full paragraphs - PASS
- **Section depth:** Each major section has substantive paragraphs - PASS
- **Figures:** All figures show visible data with proper axes - PASS
- **Tables:** All tables have real numbers, no placeholders - PASS

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors:** All coefficients have SEs in parentheses - PASS
b) **Significance Testing:** Results properly reported with p-values - PASS
c) **Confidence Intervals:** 95% CIs provided for main estimates - PASS
d) **Sample Sizes:** N reported for all regressions - PASS
e) **RDD Methodology:**
   - Uses rdrobust package with MSE-optimal bandwidth - PASS
   - Bandwidth sensitivity analysis presented - PASS
   - No explicit McCrary manipulation test, but sorting at state borders is implausible given fatal crash occurrence is not manipulable - ACCEPTABLE

### 3. IDENTIFICATION STRATEGY

- **Credibility:** The spatial RDD at state borders is a credible identification strategy. Cannabis policy changes discontinuously at state lines while other factors vary smoothly.
- **Assumptions discussed:** Continuity assumption addressed through covariate balance tests - PASS
- **Placebo tests:** Multiple placebo borders tested (OR-WA, CA-OR, etc.) - PASS
- **Robustness checks:** Bandwidth sensitivity, kernel variation examined - PASS
- **Limitations discussed:** Section 4.3 acknowledges measurement error in dispensary locations, medical cannabis programs as confounders - PASS

### 4. LITERATURE

The paper engages well with the RDD literature and cannabis policy literature. Key citations include:
- Calonico, Cattaneo, and Titiunik (2014) for rdrobust
- Hansen (2015) for RDD implementation
- Anderson, Hansen, and Rees (2013) for cannabis-driving literature

### 5. WRITING QUALITY

- **Prose:** Written in clear academic prose throughout - PASS
- **Narrative flow:** Strong arc from motivation to findings - PASS
- **Accessibility:** Technical terms explained, magnitudes contextualized - PASS
- **Figures/Tables:** Publication-quality with clear labels - PASS

### 6. CRITICAL WEAKNESSES

1. **Main estimate precision:** The confidence interval [-2.3, +20.8] is wide and spans zero. While the paper correctly interprets this as inconclusive, reviewers may question whether the design has sufficient power.

2. **Measurement error in dispensary locations:** Using 2020 OSM data to proxy 2016-2019 locations is a limitation. The paper acknowledges this but could strengthen by showing results are robust to excluding observations very close to borders where entry/exit of specific dispensaries matters most.

3. **No explicit McCrary test:** While sorting on fatal crash location is implausible, a formal density test would strengthen the paper.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Add McCrary density test** at the border to formally check for manipulation (even if implausible, referees expect it)

2. **Event study plot:** Show how the RDD estimate evolves over years to test for dynamic effects

3. **Spillover analysis:** Test whether alcohol involvement in legal states near the border differs from legal states far from the border

---

## OVERALL ASSESSMENT

**Strengths:**
- Novel spatial RDD design applied to an important policy question
- Comprehensive robustness checks including bandwidth sensitivity and placebo tests
- Honest interpretation of null findings
- Well-written and professionally presented

**Weaknesses:**
- Wide confidence intervals limit policy implications
- Reliance on 2020 dispensary data for earlier crash years

**DECISION: MINOR REVISION**

The paper is methodologically sound with an interesting design. The null finding is scientifically valuable. Minor revisions to address power considerations and add a formal density test would strengthen the paper.
