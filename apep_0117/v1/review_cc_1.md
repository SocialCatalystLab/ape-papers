# Internal Review - Paper 116 (Round 1)

## PART 1: CRITICAL REVIEW (Reviewer 2 Mode)

### 1. FORMAT CHECK

**Length**: The paper is approximately 28 pages of main text (before appendices begin on page 31), plus 6 pages of appendices. **PASS** - exceeds 25-page requirement.

**References**: The bibliography (pages 29-30) includes foundational papers on job lock (Madrian 1994, Gruber & Madrian 2000), doubly robust estimation (Robins et al. 1994, Bang & Robins 2005), bridge employment (Cahill et al. 2006, Quinn 1999, Ruhm 1990), and ACA/self-employment (Fairlie et al. 2017, Olds 2016). The sensitivity analysis cites Cinelli & Hazlett (2020). **PASS** - adequate coverage.

**Prose**: All major sections are written in full paragraphs. The Introduction, Institutional Background, Results, and Discussion sections contain substantive prose rather than bullet points. **PASS**.

**Section depth**: Each major section has multiple substantive paragraphs. The Robustness section (6.8) is particularly thorough. **PASS**.

**Figures**: All 7 figures display visible data with proper axes, labels, and legends. Figure 7 on page 36 shows the Medicaid expansion heterogeneity correctly. **PASS**.

**Tables**: All 7 tables contain real numbers with standard errors or confidence intervals. No placeholders in the data. **PASS**.

### 2. STATISTICAL METHODOLOGY

**a) Standard Errors**: Every coefficient estimate in Tables 2-7 includes standard errors in parentheses or 95% confidence intervals. **PASS**.

**b) Significance Testing**: Results report significance through confidence intervals and effect sizes. The paper correctly emphasizes that the triple-difference estimate (-0.05) is "statistically indistinguishable from zero" with CI [-0.26, 0.16]. **PASS**.

**c) Confidence Intervals**: All main results include 95% CIs. **PASS**.

**d) Sample Sizes**: N is reported for all regressions in Tables 2, 5, 6, and 7. **PASS**.

**e) DiD with Staggered Adoption**: This paper does NOT use DiD in the traditional sense - it uses inverse propensity weighted (IPW) regression comparing self-employed to wage workers, with a pre/post ACA comparison using Medicare-eligible workers as a placebo. This is a cross-sectional comparison with a policy timing element, not staggered treatment adoption across units. The methodology is appropriate. **PASS**.

**f) RDD**: Not applicable - this is not an RDD design.

**Overall Methodology Assessment**: The doubly robust estimation approach is appropriate for this selection-on-observables design. The Medicare placebo group provides a credible falsification test. **PASS**.

### 3. IDENTIFICATION STRATEGY

**Credibility**: The paper is admirably honest about the limitations of its identification strategy (Section 5.5). It acknowledges:
- Selection on observables is the core assumption, which cannot be directly tested
- Unobserved confounders (risk preferences, entrepreneurial ability) could bias results
- The ACS is repeated cross-section, not panel data

**Placebo Tests**: The Medicare-eligible (65-74) placebo group is well-motivated - these workers have Medicare regardless of employment, so ACA should not affect them through the health insurance channel. The finding that BOTH groups show similar post-ACA widening of the self-employment hours gap is compelling evidence against an ACA-specific effect.

**Sensitivity Analysis**: Section 6.8.5 provides calibrated sensitivity analysis following Cinelli & Hazlett (2020), reporting E-values and benchmarking to observed confounders. This is good practice.

**Critical Concern**: The paper notes a "pre-trend" issue - the self-employment effect jumped substantially from 2012 (-0.31 hours) to 2014 (-1.05 hours), which complicates attribution to the ACA. The paper acknowledges this but could discuss it more thoroughly.

### 4. LITERATURE

The literature review is adequate but could be strengthened:

**Covered well**:
- Job lock literature (Madrian, Gruber)
- Bridge employment (Cahill et al., Quinn, Ruhm)
- ACA and self-employment (Fairlie et al., Olds)
- Doubly robust methods (Robins et al., Bang & Robins)

**Potentially missing**:
- More recent ACA labor supply papers (e.g., Leung & Mas 2018 on labor supply effects)
- Papers on older worker labor supply more broadly
- The extensive literature on the value of flexibility in employment

### 5. WRITING QUALITY

**Prose vs. Bullets**: The paper is written entirely in proper academic prose. No bullet-point sections in the main text. **PASS**.

**Narrative Flow**: The paper tells a clear story:
1. Self-employment may serve as bridge employment for older workers
2. Health insurance was a barrier pre-ACA
3. ACA should have enabled more flexible retirement through self-employment
4. Evidence shows self-employed work fewer hours, but ACA didn't differentially affect this
5. Other factors (capital, skills, preferences) may dominate

**Sentence Quality**: The writing is clear and professional. Occasional passive voice but generally readable.

**Accessibility**: Technical terms are explained. The conceptual framework (Section 3) provides intuition for the mechanisms.

**Figures/Tables**: Publication-quality with clear labels and notes.

### 6. CONSTRUCTIVE SUGGESTIONS

The paper is methodologically sound with a well-executed null result. Suggestions to strengthen:

1. **Explore the pre-trend more**: The jump from 2012 to 2014 is larger than subsequent changes. This deserves more attention - was something else changing in 2012-2014?

2. **Add a placebo outcome test**: The paper mentions this in passing (Section 6.8.6) but could formally test effects on outcomes that shouldn't be affected (e.g., marital status, household size).

3. **Consider dose-response by subsidy eligibility**: Workers at different income levels face different ACA premium subsidies. Those at 138-250% FPL face the steepest subsidy phase-out. Heterogeneity by income could provide additional tests of the mechanism.

4. **Discuss the null result's policy implications more**: The finding that health insurance wasn't the binding constraint is important. What ARE the binding constraints? The paper mentions capital, skills, and risk preferences but could be more specific about policy implications.

5. **Address the 2019 dip**: In Table 6, the 2019 estimate (-0.79) is notably smaller than 2017 (-1.15) and 2022 (-1.52). Any explanation?

### 7. OVERALL ASSESSMENT

**Key Strengths**:
- Well-designed study with credible placebo group
- Honest about limitations and null result
- Thorough robustness checks
- Clean presentation of a negative finding

**Critical Weaknesses**:
- Pre-trend concern (2012-2014 jump) not fully resolved
- Limited ability to address selection on unobservables without panel data
- The null finding, while important, limits novelty

**Specific Suggestions**:
1. Add more discussion of the pre-trend issue
2. Consider additional heterogeneity analyses (by income/subsidy eligibility)
3. The @CONTRIBUTOR_GITHUB placeholders need to be replaced (this is an APEP project convention, but should be noted)

---

## DECISION: MINOR REVISION

The paper is methodologically sound, well-written, and appropriately cautious about its null finding. The identification strategy is reasonable given data constraints, and the Medicare placebo test is clever. The main issues are:
1. Better engagement with the 2012-2014 pre-trend
2. Minor placeholder text issues

The core finding - that the ACA did not substantially affect self-employment as a bridge employment pathway - is a valuable contribution that challenges simple job lock narratives. With minor revisions to address the pre-trend discussion and clean up placeholders, this paper is ready for external review.

DECISION: MINOR REVISION
