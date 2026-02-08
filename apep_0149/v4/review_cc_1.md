# Internal Review - Round 1

**Reviewer:** Claude Code (Reviewer 2 mode - harsh, skeptical)
**Paper:** State Minimum Wage Increases and Business Establishments
**Date:** 2026-01-28

---

## PART 1: CRITICAL REVIEW

### 1. FORMAT CHECK

- **Length:** ~9 pages excluding appendix - significantly below the 25-page standard for top journals. This is a substantial concern.
- **References:** 8 references cited - inadequate for a top journal. Key literature on entrepreneurship, business dynamics, and minimum wage policy is missing.
- **Prose:** Major sections are appropriately in paragraph form - PASS
- **Section depth:** Introduction and Methods have adequate depth; Discussion and Conclusion are thin (1-2 paragraphs each)
- **Figures:** Figure 1 (event study) properly rendered with axes and confidence intervals - PASS
- **Tables:** Tables 1-3 contain real numbers with standard errors - PASS

### 2. STATISTICAL METHODOLOGY

a) **Standard Errors:** All regressions report clustered SEs - PASS

b) **Significance Testing:** Significance levels noted but no stars appear in results (all null) - acceptable given the findings

c) **Confidence Intervals:** Main CI reported for CS estimator [-0.036, 0.010]. TWFE CI can be computed from SE but not explicitly reported - MINOR CONCERN

d) **Sample Sizes:** N = 510 reported for all specifications - PASS

e) **DiD with Staggered Adoption:** Paper uses Callaway-Sant'Anna with never-treated controls and explicitly excludes 13 already-treated states from event study analysis. Also reports Bacon decomposition showing 82% weight on clean treated-vs-untreated comparisons - PASS

**Methodology PASS** - The identification strategy is appropriate and addresses heterogeneity concerns.

### 3. IDENTIFICATION STRATEGY

**Strengths:**
- Uses heterogeneity-robust estimator (CS) alongside TWFE
- Correctly excludes already-treated states from event study
- Event study supports parallel trends (pre-treatment coefficients near zero)
- Bacon decomposition shows clean comparisons receive dominant weight

**Concerns:**
- **Selection into treatment:** Paper briefly mentions "state political factors" but doesn't rigorously address whether states that raise MW are fundamentally different in ways correlated with business formation trends
- **Anticipation effects:** Given MW increases are often announced years in advance (California example noted), entrepreneurs may adjust before implementation. The event study window may miss relevant pre-treatment adjustments
- **Alternative confounders:** No discussion of concurrent state policies (e.g., business regulations, tax changes) that may correlate with MW increases
- **Endogeneity of MW timing:** Do states raise MW when their economies are strong (and business formation naturally high)?

### 4. LITERATURE

**Missing critical references:**

The paper cites only 8 references. Key missing literature includes:

**Entrepreneurship and business dynamics:**
```bibtex
@article{fairlie2013entrepreneurship,
  author = {Fairlie, Robert W and Fossen, Frank M},
  title = {Opportunity versus Necessity Entrepreneurship: Two Components of Business Creation},
  journal = {IZA Discussion Papers},
  year = {2018},
  number = {11258}
}

@article{hurst2004entrepreneurship,
  author = {Hurst, Erik and Lusardi, Annamaria},
  title = {Liquidity Constraints, Household Wealth, and Entrepreneurship},
  journal = {Journal of Political Economy},
  year = {2004},
  volume = {112},
  pages = {319--347}
}
```

**Minimum wage employment effects:**
```bibtex
@article{autor2016contribution,
  author = {Autor, David H and Manning, Alan and Smith, Christopher L},
  title = {The Contribution of the Minimum Wage to US Wage Inequality over Three Decades},
  journal = {American Economic Journal: Applied Economics},
  year = {2016},
  volume = {8},
  pages = {58--99}
}

@article{harasztosi2019labor,
  author = {Harasztosi, P{\'e}ter and Lindner, Attila},
  title = {Who Pays for the Minimum Wage?},
  journal = {American Economic Review},
  year = {2019},
  volume = {109},
  pages = {2693--2727}
}
```

**Business formation studies:**
```bibtex
@article{decker2014role,
  author = {Decker, Ryan and Haltiwanger, John and Jarmin, Ron and Miranda, Javier},
  title = {The Role of Entrepreneurship in US Job Creation and Economic Dynamism},
  journal = {Journal of Economic Perspectives},
  year = {2014},
  volume = {28},
  pages = {3--24}
}
```

### 5. WRITING QUALITY

a) **Prose vs. Bullets:** Appropriate paragraph format throughout - PASS

b) **Narrative Flow:** Introduction establishes the question but lacks a compelling hook. Transitions between sections are functional but could be stronger.

c) **Sentence Quality:** Prose is clear but somewhat mechanical. Lacks the narrative sophistication of top journal publications.

d) **Accessibility:** Technical choices explained adequately.

e) **Figures/Tables:** Publication quality. Figure 1 event study is clear and informative.

**Main writing concern:** The paper reads like a technical report rather than a compelling narrative. At 9 pages, it lacks the depth expected for AER/QJE.

### 6. CONSTRUCTIVE SUGGESTIONS (Part 2)

The paper has sound methodology but limited contribution in its current form. To strengthen:

1. **Industry heterogeneity:** CBP data allows industry-level analysis. Show effects by sector (retail, food service vs. professional services). This could reveal meaningful heterogeneity masked by aggregation.

2. **Effect on establishment size:** Does MW affect average size of establishments even if count doesn't change?

3. **Entry vs. exit:** Can you decompose net establishment change into gross flows? BDS (Business Dynamics Statistics) might help.

4. **Mechanism exploration:** What share of employment in entering establishments is at/near MW? If most entrants pay above MW, null effect is expected.

5. **Geographic heterogeneity:** Do effects differ in border counties (geographic RDD design)?

6. **Longer pre-trends:** Extend data backward if possible to strengthen parallel trends evidence.

### 7. OVERALL ASSESSMENT

**Strengths:**
- Sound econometric methodology
- Appropriate use of heterogeneity-robust estimators
- Clearly documented sample restrictions
- Event study supports parallel trends

**Critical Weaknesses:**
1. **Length:** At 9 pages, paper is far below journal standards
2. **Literature:** Only 8 references; misses key entrepreneurship and MW literatures
3. **Discussion is thin:** Mechanisms largely hand-waved
4. **Limited contribution:** Null finding on aggregate establishments adds modest value; heterogeneous effects would be more interesting
5. **No industry analysis:** Missing obvious extension that CBP data supports

---

## DECISION: MAJOR REVISION

The methodology is sound and the paper addresses an interesting question, but it is far too short for a top journal submission. The paper needs:
1. Expansion to 25+ pages with deeper discussion of mechanisms and literature
2. At minimum 15-20 additional references engaging with entrepreneurship and MW literatures
3. Industry-level heterogeneity analysis
4. More rigorous treatment of identification threats (selection, anticipation, concurrent policies)

With substantial expansion and additional analysis, this could become a solid contribution. In current form, it would be desk-rejected at AER/QJE/AEJ.

DECISION: MAJOR REVISION
