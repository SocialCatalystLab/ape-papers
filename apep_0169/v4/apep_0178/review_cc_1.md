# Internal Review - Round 1

**Reviewer:** Claude Code (Reviewer 2 mode)
**Paper:** The Atlas of Self-Employment in America
**Date:** 2026-02-03

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length:** 33 pages total, approximately 27-28 pages of main text. PASS.
- **References:** 16 references. Adequate but could be expanded. Foundational IPW references missing (Hirano, Imbens, Ridder 2003 is cited but others missing).
- **Prose:** All major sections written in paragraph form. PASS.
- **Section depth:** Each section has substantial paragraphs. PASS.
- **Figures:** Referenced but not directly visible in LaTeX review. Assumed OK.
- **Tables:** All tables have real numbers with CIs. PASS.

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors:** All coefficients have 95% CIs reported in brackets. PASS.

b) **Significance Testing:** Significance stars (*** p<0.01, ** p<0.05, * p<0.10) properly used. PASS.

c) **Confidence Intervals:** Present for all main estimates. PASS.

d) **Sample Sizes:** N reported for all analyses. Table 2 now shows N for aggregate, incorporated, and unincorporated analyses. PASS.

e) **Methodology:** This is an IPW (inverse probability weighting) paper, not DiD or RDD. The IPW methodology appears correctly implemented with propensity score estimation, weight truncation at 99th percentile, and robust standard errors. PASS.

f) **Diagnostics:** Propensity score overlap discussed, covariate balance SMD reported, sensitivity analysis (E-values, Oster's delta) included. PASS.

### 3. IDENTIFICATION STRATEGY

**Strengths:**
- Clear statement of selection-on-observables assumption
- Appropriate acknowledgment that assumption is untestable
- E-value and Oster coefficient stability analyses strengthen credibility
- Covariate balance diagnostics well-documented

**Weaknesses:**
- **The paper cannot claim causal identification** under selection on observables with cross-sectional data. The paper appropriately hedges but should be more explicit that these are conditional associations, not causal effects.
- No panel dimension to address time-invariant unobservables
- Entrepreneurial ability, risk preferences remain uncontrolled confounders

**Assessment:** Methodology is appropriate for the question, and limitations are acknowledged. ACCEPTABLE.

### 4. LITERATURE

**Strengths:**
- Cites Hamilton (2000), Moskowitz and Vissing-Jorgensen (2002), Levine and Rubinstein (2017)
- Cites Benz and Frey (2008) on compensating differentials
- Cites relevant sensitivity analysis papers (VanderWeele & Ding, Oster)

**Missing references:**
- **Hurst & Pugsley (2011)** "What Do Small Businesses Do?" - Key paper on heterogeneity in small businesses
- **Astebro et al. (2014)** "Seeking the Roots of Entrepreneurship" - Survey of entrepreneurship research
- **Rosenbaum & Rubin (1983)** - Foundational propensity score paper
- **Fairlie (2005)** on racial differences in self-employment

### 5. WRITING QUALITY

**Strengths:**
- Introduction is compelling with the "American Dream" framing
- Clear narrative arc from puzzle → decomposition → resolution
- Prose is crisp and engaging throughout
- Technical choices explained with intuition
- Magnitudes well-contextualized

**Minor issues:**
- Some repetition between abstract, introduction preview, and results sections
- Could tighten some transitions

**Assessment:** Writing quality is strong. PASS.

### 6. CONSTRUCTIVE SUGGESTIONS

1. **Industry decomposition:** The paper would benefit from showing whether the incorporated premium varies by industry (professional services vs. construction vs. retail). This would help distinguish selection from structural explanations.

2. **Longitudinal extension:** If possible, use ACS panel linking (SERIALNO matching across years) to examine transitions into/out of self-employment.

3. **Mechanism investigation:** The gender finding (women don't benefit from incorporation) is striking. Could add analysis of industry composition by gender, or hours worked conditional on incorporation, to illuminate mechanisms.

4. **Policy simulation:** Back-of-envelope calculation of what shifting X% of unincorporated workers to incorporated status would do for aggregate earnings.

---

## PART 2: OVERALL ASSESSMENT

### Key Strengths
1. Novel decomposition by incorporation status, geography, and gender
2. Large sample (1.4M observations) enabling precise state-level estimation
3. Striking finding that incorporated premium accrues only to men
4. Beautiful maps and clear visualizations
5. Appropriate sensitivity analyses for observational design
6. Well-written with compelling narrative

### Critical Weaknesses
1. Cannot establish causality - these are conditional associations
2. Unobserved confounders (ability, risk preferences) likely bias estimates
3. Limited literature review (missing some key entrepreneurship papers)
4. Some percentage conversions could be more careful (e.g., log points vs. %)

### Specific Suggestions
1. Add missing literature citations
2. Be even more explicit about limitations of selection-on-observables
3. Consider adding industry decomposition analysis
4. Explore mechanisms behind gender finding

---

## DECISION

This paper makes a valuable contribution by systematically decomposing the self-employment penalty along three dimensions. The methodology is appropriate and well-executed. The gender finding is particularly novel and policy-relevant. Writing quality is strong. Main concerns are about causal claims (which should be softened) and some missing literature. These are addressable with revision.

DECISION: MINOR REVISION
