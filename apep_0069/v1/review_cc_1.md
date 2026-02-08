# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Role:** Reviewer 2 (harsh, skeptical)
**Paper:** Does Local Policy Experience Build National Support? Evidence from Energy Policy in a Federal System
**Timestamp:** 2026-01-27

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length:** ~15 pages of main text (excluding references/appendix). The 25-page minimum is NOT met. This is a significant concern—the paper reads as a working paper or research note rather than a full journal submission.

- **References:** 9 citations total. This is far too thin for a top journal. Key literatures are underrepresented (see Section 4).

- **Prose vs. Bullets:** Generally acceptable. Major sections are in paragraph form. Some bullet points in Section 2.2-2.3 for policy descriptions, which is appropriate.

- **Figures:** One RDD figure (Figure 1) with proper axes and visible data. Publication quality is acceptable.

- **Tables:** 8 tables with real numbers. Table notes are adequate but could be more detailed.

### 2. STATISTICAL METHODOLOGY

**a) Standard Errors:** ✓ PASS
- Clustered at canton level (appropriate given treatment varies at canton level)
- Reported in parentheses in Table 3

**b) Significance Testing:** ✓ PASS
- P-values reported for main estimates
- Stars indicate significance levels

**c) Confidence Intervals:** ✓ PASS (for RDD)
- Table 4 reports 95% CI for spatial RDD

**d) Sample Sizes:** ✓ PASS
- N reported for all regressions (N=2,120 for OLS, N=498 for RDD)

**e) DiD with Staggered Adoption:** N/A
- This is not a DiD paper

**f) RDD Diagnostics:** ⚠️ CONCERNS
- Bandwidth selection: MSE-optimal reported ✓
- **McCrary density test: NOT REPORTED** - This is a standard RDD diagnostic
- **Bandwidth sensitivity: NOT SHOWN** - Only one bandwidth (3.9km) reported
- **Covariate balance at cutoff: NOT SHOWN** - Paper claims municipalities should be similar but doesn't test this
- **Donut specifications: NOT REPORTED**

The RDD is labeled "exploratory" but still lacks basic diagnostics that would make it interpretable.

### 3. IDENTIFICATION STRATEGY

**OLS with Language Controls (Primary):**
- The identification relies on conditioning on language region. This is transparently weak—selection into early MuKEn adoption is almost certainly correlated with unobserved environmental preferences.
- The paper acknowledges this but has limited ability to address it.
- With only 5 treated cantons (all German-speaking), there is essentially no within-language variation in treatment.

**Spatial RDD (Exploratory):**
- The paper correctly identifies that language borders (BE-FR, BE-JU, BE-NE) violate the continuity assumption.
- However, it still pools all borders in the main estimate rather than restricting to same-language borders.
- This is appropriately labeled "exploratory" and not used for causal claims in Abstract/Conclusion.

**Core Concern:** The paper's main result is a precisely estimated null (−1.8 pp, SE=1.9). But with only 5 treated cantons and treatment perfectly confounded with canton-level unobservables, this null could reflect: (a) no true effect, (b) measurement error attenuating effects toward zero, or (c) inadequate statistical power. The paper cannot distinguish these.

### 4. LITERATURE (Missing References)

The paper cites only 9 references. For a top journal, this is inadequate. Missing:

**RDD Methodology (critical since the paper includes an RDD):**
```bibtex
@article{ImbensLemieux2008,
  author = {Imbens, Guido W. and Lemieux, Thomas},
  title = {Regression Discontinuity Designs: A Guide to Practice},
  journal = {Journal of Econometrics},
  year = {2008},
  volume = {142},
  pages = {615--635}
}

@article{CattaneoEtAl2020,
  author = {Cattaneo, Matias D. and Idrobo, Nicolás and Titiunik, Rocío},
  title = {A Practical Introduction to Regression Discontinuity Designs: Foundations},
  journal = {Cambridge Elements: Quantitative and Computational Methods for Social Science},
  year = {2020}
}

@article{DellaVignaCard2020,
  author = {DellaVigna, Stefano and Card, David and Mas, Alexandre},
  title = {What Do Editors Maximize? Evidence from Four Economics Journals},
  journal = {Review of Economics and Statistics},
  year = {2020}
}
```

**Swiss Referendum Voting:**
```bibtex
@article{Kriesi2005,
  author = {Kriesi, Hanspeter},
  title = {Direct Democratic Choice: The Swiss Experience},
  journal = {Lanham, MD: Lexington Books},
  year = {2005}
}

@article{Trechsel2000,
  author = {Trechsel, Alexander H. and Sciarini, Pascal},
  title = {Direct Democracy in Switzerland: Do Elites Matter?},
  journal = {European Journal of Political Research},
  year = {2000},
  volume = {38},
  pages = {99--124}
}
```

**Spatial RDD:**
```bibtex
@article{Dell2010,
  author = {Dell, Melissa},
  title = {The Persistent Effects of Peru's Mining Mita},
  journal = {Econometrica},
  year = {2010},
  volume = {78},
  pages = {1863--1903}
}

@article{Keele2015,
  author = {Keele, Luke J. and Titiunik, Rocío},
  title = {Geographic Boundaries as Regression Discontinuities},
  journal = {Political Analysis},
  year = {2015},
  volume = {23},
  pages = {127--155}
}
```

**Environmental Referendum Voting:**
```bibtex
@article{Kahn2007,
  author = {Kahn, Matthew E. and Matsusaka, John G.},
  title = {Demand for Environmental Goods: Evidence from Voting Patterns on California Initiatives},
  journal = {Journal of Law and Economics},
  year = {2007},
  volume = {40},
  pages = {137--173}
}
```

### 5. WRITING QUALITY

**Prose vs. Bullets:** ✓ PASS - Major sections use proper paragraphs.

**Narrative Flow:** ✓ PASS - The paper tells a coherent story from motivation through results to implications.

**Sentence Quality:** Acceptable but not exceptional. Some passive voice and repetitive sentence structures.

**Accessibility:** Good. Technical choices are explained.

**Figures/Tables:** Acceptable. Figure 1 could use larger fonts for readability.

### 6. CONSTRUCTIVE SUGGESTIONS

The paper has a compelling question but faces fundamental data limitations. To strengthen:

1. **Restrict RDD to same-language borders only** and report that as the main RDD result. This would be: AG-ZH, AG-SO, BL-SO, GR-SG. Cross-language borders should be reported separately.

2. **Add RDD diagnostics:**
   - McCrary density test
   - Bandwidth sensitivity (half, double, triple the MSE-optimal)
   - Covariate balance at the cutoff

3. **Power analysis:** Calculate the minimum detectable effect given sample sizes. If the MDE is larger than economically meaningful effects, acknowledge explicitly.

4. **Mechanism exploration:** With only aggregate data, mechanism identification is limited. Survey data would help, but at minimum, test heterogeneity by:
   - Urban/rural
   - Distance to cantonal capital (exposure intensity)
   - Canton-level policy "dosage" (years since adoption)

5. **Expand literature review** substantially.

6. **Extend main text** to 25+ pages with deeper institutional discussion and more robustness checks.

---

## PART 2: OVERALL ASSESSMENT

### Key Strengths
- Interesting and policy-relevant question
- Honest about limitations (RDD labeled "exploratory")
- Clear writing and logical structure
- Real data, properly analyzed

### Critical Weaknesses
1. **Underpowered:** 5 treated cantons, all German-speaking, provides very limited identifying variation
2. **Missing RDD diagnostics:** No McCrary test, bandwidth sensitivity, or covariate balance
3. **Too short:** ~15 pages main text vs. 25-page standard
4. **Thin literature:** 9 citations is inadequate
5. **Treatment definition concerns:** "Comprehensive MuKEn adoption" is somewhat subjective

### Verdict

This paper addresses an interesting question with careful attention to confounding (the Röstigraben issue is well-handled). However, the fundamental limitation—only 5 treated cantons—means the null finding is hard to interpret. Is this a true null, or insufficient power? The paper cannot answer this.

For a top general-interest journal, the paper needs: (a) more pages with deeper analysis, (b) proper RDD diagnostics, (c) expanded literature, and (d) ideally, additional identifying variation or individual-level data to sharpen mechanism tests.

As currently written, this is a solid working paper that could become a field journal publication (e.g., *Journal of Environmental Economics and Management*, *European Journal of Political Economy*) with revisions. It is not ready for AER/QJE/JPE.

---

**DECISION: MAJOR REVISION**
