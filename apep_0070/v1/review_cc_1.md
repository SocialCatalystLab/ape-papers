# Internal Review - Round 1

**Reviewer:** Claude Code (Opus 4.5)
**Date:** 2026-01-28
**Mode:** Reviewer 2 (harsh, skeptical)

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length**: Paper is 25 pages including appendix. Main text ends at page 14 (before references). This is borderline short for a top journal but acceptable.
- **References**: Bibliography contains 20 references. Adequate for RDD methodology (Calonico, Keele & Titiunik) and policy literature (Campbell, Pierson). Missing some key RDD references (see below).
- **Prose**: All major sections are in paragraph form. No bullet points in Introduction, Results, or Discussion.
- **Section depth**: Each section has adequate depth.
- **Figures**: 4 main figures plus appendix figures. All show visible data with proper axes.
- **Tables**: All tables have real numbers with standard errors.

**PASS** on format.

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors**: Table 2 reports robust SEs in parentheses and p-values in brackets. **PASS**.

b) **Significance Testing**: P-values reported for all specifications. Main result p = 0.24 (not significant). Paper honestly acknowledges this. **PASS**.

c) **Confidence Intervals**: 95% CIs mentioned in text and shown in bandwidth sensitivity figure. **PASS**.

d) **Sample Sizes**: N reported for all specifications (left/right of cutoff). **PASS**.

e) **RDD Methodology**:
   - McCrary density test: Reported (t = 1.25, p = 0.21). **PASS**.
   - Bandwidth sensitivity: Figure 4 shows sensitivity across 3-20 km bandwidths. **PASS**.
   - Uses rdrobust package with MSE-optimal bandwidth. **PASS**.

**PASS** on statistical methodology.

### 3. IDENTIFICATION STRATEGY

**Strengths:**
- Clear spatial RDD at canton borders
- Restriction to German-speaking cantons addresses Röstigraben confound
- Running variable construction is transparent
- McCrary test supports no manipulation

**Concerns:**
1. **Contemporaneous covariate imbalance**: Table 5 shows a significant turnout discontinuity (-4.6 pp, p = 0.001). This is acknowledged but concerning. If municipalities differ systematically in political engagement, the treatment effect may be confounded.

2. **Pre-treatment balance not tested**: The paper mentions 2004 referendum data was not successfully merged. This limits the credibility of the parallel trends assumption.

3. **Canton-level language restriction**: Bern is bilingual. Some French-speaking municipalities near the border may be included. Paper acknowledges this limitation.

4. **Multi-segment border**: The 305 km treatment boundary comprises multiple segments. Keele & Titiunik (2015) warn about pooling across segments with potentially different treatment effects. Section 5.3 mentions this but lacks formal heterogeneity analysis.

**MARGINAL PASS** on identification - concerns are acknowledged but not fully resolved.

### 4. LITERATURE

**Present:**
- Keele & Titiunik (2015) for geographic RDD
- Calonico et al. (2020) for rdrobust
- Dell (2010) for spatial RDD
- Campbell (2012), Pierson (1993), Mettler & Soss (2004) for policy feedback

**Missing:**
- Imbens & Lemieux (2008) - foundational RDD review
- Lee & Lemieux (2010) - RDD design and implementation
- Gelman & Imbens (2019) - polynomial order in RDD

```bibtex
@article{ImbensLemieux2008,
  author = {Imbens, Guido W. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {615--635}
}

@article{LeeLemieux2010,
  author = {Lee, David S. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs in Economics},
  journal = {Journal of Economic Literature},
  year = {2010},
  volume = {48},
  pages = {281--355}
}

@article{GelmanImbens2019,
  author = {Gelman, Andrew and Imbens, Guido},
  title = {Why High-Order Polynomials Should Not Be Used in Regression Discontinuity Designs},
  journal = {Journal of Business \& Economic Statistics},
  year = {2019},
  volume = {37},
  pages = {447--456}
}
```

**MINOR REVISION** needed - add foundational RDD references.

### 5. WRITING QUALITY

- **Prose**: Well-written with smooth transitions. No bullet points in narrative sections.
- **Flow**: Clear arc from motivation to findings to implications.
- **Accessibility**: Technical choices explained with intuition.
- **Magnitudes**: Effect size contextualized (5% of mean yes-share).

**PASS** on writing quality.

### 6. OVERALL ASSESSMENT

**Key Strengths:**
1. Clean spatial RDD design exploiting canton borders
2. Novel application to policy feedback question
3. Transparent about null result (p = 0.24)
4. Appropriate robustness checks

**Critical Weaknesses:**
1. Insignificant main result limits publishable contribution
2. Significant turnout imbalance at border raises identification concerns
3. Lack of pre-treatment balance tests
4. Canton-level language restriction is imprecise

**Suggestions:**
1. Add pre-treatment referendum votes as placebo outcome
2. Conduct heterogeneity analysis by border segment
3. Obtain municipality-level language data
4. Discuss power analysis - was study sufficiently powered?

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

Given the null result, consider:
1. **Power calculation**: What effect size was the study powered to detect? This would help interpret the null.
2. **Mechanisms**: Even with null overall effect, are there heterogeneous effects by municipality characteristics (urban/rural, baseline support)?
3. **Alternative outcomes**: Are there other referendums in the sample period that could test the thermostatic hypothesis?

---

**DECISION: MAJOR REVISION**
