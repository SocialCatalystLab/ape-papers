# Internal Review - Round 1

**Role:** Reviewer 2 (harsh, skeptical) + Editor (constructive)
**Paper:** Roads Without Revolution: Rural Connectivity and the Gender Gap in India's Structural Transformation

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length:** ~25 pages main text (through page 25), plus ~9 pages appendix. Meets the 25-page minimum.
- **References:** ~35 references covering transportation infrastructure, RDD methodology, gender/labor, and India-specific literature. Adequate.
- **Prose:** All major sections written in full paragraphs. No bullet-point issues except appropriately in Estimation Details and Data Appendix.
- **Section depth:** Each section has 3+ substantive paragraphs. Introduction is strong at ~11 paragraphs.
- **Figures:** 7 figures, all show visible data with proper axes and labels.
- **Tables:** 5 tables with real numbers, proper notes. No placeholders.

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors:** All coefficients have robust SEs in parentheses. Table notes explain these are bias-corrected. PASS.

b) **Significance Testing:** All results include p-values. PASS.

c) **Confidence Intervals:** CI reported in text for main result (-0.0063 to 0.0105). Figures show 95% CI bands. PASS.

d) **Sample Sizes:** Effective N reported in all tables. PASS.

e) **RDD Methodology:**
- McCrary density test: PASS (t=1.29, p=0.198)
- Bandwidth sensitivity: 6 multipliers tested. PASS.
- Covariate balance: 5 covariates, all null. PASS.
- Placebo cutoffs: 5 placebo thresholds tested. PASS.
- Donut hole: 3 specifications. PASS.
- Randomization inference: 500 permutations. PASS.

**Concern:** The text on page 17 says "approximately 14% for villages near the threshold" but Table 1 shows the baseline female non-ag share is 0.106 (10.6%) below and 0.113 (11.3%) above threshold. This discrepancy should be corrected to match Table 1.

**Concern:** Table 3 vs Table 4 Panel A at 1.0x optimal: same point estimate (0.0021) but different SEs (0.0043 vs 0.0055) and p-values (0.444 vs 0.088). The table note explains this is due to fixing h in the bias-correction procedure. This is technically correct but confusing. Consider adding a sentence in the text acknowledging this more explicitly.

### 3. IDENTIFICATION STRATEGY

- The identification is credible for a village-level ITT analysis. The running variable (Census 2001 population) is pre-determined.
- Key assumptions are well-discussed: continuity, no manipulation, no compound treatment.
- The habitation-vs-village measurement issue is honestly discussed in Section 2.2 and Section 5.3. This is the paper's main limitation and is appropriately flagged.
- The nightlights pre-trend failure (Section 6.3) is transparently reported. The paper correctly notes this invalidates the nightlights RDD but not the Census-based analysis.
- Placebo and robustness checks are comprehensive.

**Concern:** The paper could benefit from a power calculation. With 77,040 observations in the effective sample, what is the minimum detectable effect? This would strengthen the "precisely estimated null" claim.

### 4. LITERATURE

The literature review is solid. Key papers cited include:
- Asher & Novosad (2020) AER on PMGSY
- Aggarwal (2018) JDE on PMGSY and poverty
- Donaldson (2018) AER on Indian railroads
- Jayachandran (2021), Afridi et al. (2023) on gender norms
- CCT (2014) on rdrobust methodology

**Missing references to consider:**
- Shamdasani (2021) on rural roads and agricultural productivity
- Asher, Garg & Novosad (2020) on social networks and roads
- Bertrand, Kamenica & Pan (2015) on gender identity norms

### 5. WRITING QUALITY

a) **Prose:** Excellent. All sections in full paragraphs with strong transitions. PASS.

b) **Narrative Flow:** The introduction effectively hooks with the "growth without women" paradox, clearly states what the paper does, previews results, and positions the contribution. Strong arc throughout.

c) **Sentence Quality:** Generally crisp and engaging. Active voice used appropriately. The conclusion's final line ("The road has been built. The question is what else must change before women can walk it.") is memorable.

d) **Accessibility:** Technical choices well-motivated. Magnitudes contextualized (e.g., "roughly 7% of the baseline").

**Minor issue:** The conceptual framework (Section 3) lists three scenarios but could be more concise. It reads somewhat mechanically.

### 6. CONSTRUCTIVE SUGGESTIONS

1. **Power analysis:** Add an MDE calculation to Section 5 or a footnote. With N~77,000 and SE=0.0043, the MDE at 80% power is roughly 0.012 (1.2 pp). State this explicitly.

2. **First-stage exploration:** Even without habitation-level data, could you estimate the "effective first stage" by comparing the village-level RDD with Asher & Novosad's habitation-level estimates? This would help readers assess how much attenuation to expect.

3. **Figure 3 (RDD plots) y-axis interpretation:** Panel C shows gender gap change values around 0.04 (4 percentage points). This is the *mean* of the gap change, not the RDD estimate. Clarify in the figure notes that the y-axis shows conditional means, and the RDD estimate captures the *discontinuity* at 500.

4. **Bandwidth sensitivity narrative:** The text says effects are significant only "at narrow bandwidths" but Panel A shows significance at both 0.5x AND 0.8x optimal. The 0.8x result (p=0.037) is actually below 0.05 with a reasonable sample (57,878). Consider discussing why you dismiss this result more carefully.

### 7. OVERALL ASSESSMENT

**Key Strengths:**
- Clean identification with pre-determined running variable
- Massive sample (582K villages) providing excellent statistical power
- Comprehensive robustness checks (bandwidth, polynomial, donut, placebo, RI)
- Honest treatment of the nightlights pre-trend failure
- Well-written with strong narrative arc
- Genuine contribution as a null result paper

**Critical Weaknesses:**
- One remaining text-table inconsistency (14% vs 10.6% baseline)
- No formal power calculation to back "precisely estimated null" claim
- The 0.8x bandwidth result (p=0.037) deserves more discussion
- Missing MDE calculation

**Specific Suggestions:**
1. Fix the 14% baseline reference to match Table 1 (~11%)
2. Add MDE calculation
3. Discuss 0.8x bandwidth result more carefully
4. Consider adding a brief paragraph on external validity

DECISION: MINOR REVISION
