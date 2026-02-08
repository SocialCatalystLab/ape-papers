# Internal Review - Round 1

**Reviewer:** Claude Code (Reviewer 2 Mode)
**Date:** 2026-01-22
**Paper:** Salary Transparency Laws and Wage Outcomes

---

## 1. FORMAT CHECK

- **Length:** 42 pages total - PASS (exceeds 25-page requirement)
- **References:** 16 citations covering DiD methodology (Sun-Abraham, Goodman-Bacon, de Chaisemartin), transparency literature (Baker, Bennedsen, Cullen), and general labor (Blau, Card, Stigler) - ADEQUATE
- **Prose:** All major sections written in full paragraphs - PASS
- **Section depth:** Each section has multiple substantive paragraphs - PASS
- **Figures:** 12 figures with proper axes and visible data - PASS
- **Tables:** 10 tables with real numbers, SEs, and significance stars - PASS

**Format Assessment: PASS**

---

## 2. STATISTICAL METHODOLOGY

### Standard Errors
- All coefficients have clustered SEs at state level - PASS
- SEs reported in parentheses in all tables - PASS

### Significance Testing
- Stars notation used (*** p<0.01, ** p<0.05, * p<0.10) - PASS
- P-values reported in supplementary tables - PASS

### Confidence Intervals
- 95% CIs reported for main results and heterogeneity - PASS

### Sample Sizes
- N reported for all specifications (459 state-year observations; 1,180,455 individuals) - PASS

### DiD with Staggered Adoption
- Paper uses Sun-Abraham interaction-weighted estimator via fixest - PASS
- Explicitly addresses heterogeneous treatment effects concern - PASS
- Uses never-treated and not-yet-treated as controls - PASS

**Methodology Assessment: PASS**

---

## 3. IDENTIFICATION STRATEGY

### Strengths
1. Appropriate use of Sun-Abraham estimator for staggered DiD
2. Event study provides visual test of parallel trends
3. Multiple robustness checks (excluding Colorado, California, unweighted)
4. Heterogeneity analysis by gender, age, education, and wage percentile

### Critical Weaknesses

**MAJOR CONCERN 1: Pre-trend violation**
- The t=-3 coefficient is positive (+0.027) and highly significant (p<0.001)
- This is a SERIOUS violation of parallel trends
- The paper acknowledges this but doesn't adequately address it
- **Recommendation:** Apply HonestDiD sensitivity analysis (Rambachan-Roth) to bound treatment effects under violations of parallel trends

**MAJOR CONCERN 2: Selection into treatment**
- States adopting transparency laws are systematically different (higher wages, more educated)
- Pre-treatment balance table shows 0.13 log point gap in earnings
- Paper claims DiD differences out level differences, but the pre-trend violation suggests trend differences too

**MODERATE CONCERN 3: Treatment timing coding**
- NY adopted September 2023 but coded as 2024 treatment
- This may attenuate estimates if employers responded immediately
- Could cause anticipation effects to appear in "pre-treatment" period

### Missing Robustness Checks
1. No HonestDiD sensitivity analysis for parallel trends violations
2. No bacon decomposition to show TWFE weights
3. No test using never-treated only as controls (mentioned but not separately reported)
4. No regression discontinuity using firm size thresholds

---

## 4. LITERATURE GAPS

### Missing Key Citations

The paper should cite:

```bibtex
@article{RambachanRoth2023,
  author = {Rambachan, Ashesh and Roth, Jonathan},
  title = {A More Credible Approach to Parallel Trends},
  journal = {Review of Economic Studies},
  year = {2023},
  volume = {90},
  number = {5},
  pages = {2555--2591}
}

@article{BorusyakJaravel2024,
  author = {Borusyak, Kirill and Jaravel, Xavier and Spiess, Jann},
  title = {Revisiting Event Study Designs: Robust and Efficient Estimation},
  journal = {Review of Economic Studies},
  year = {2024},
  note = {forthcoming}
}

@article{AtheyImbens2022,
  author = {Athey, Susan and Imbens, Guido W.},
  title = {Design-based Analysis in Difference-In-Differences Settings with Staggered Adoption},
  journal = {Journal of Econometrics},
  year = {2022},
  volume = {226},
  number = {1},
  pages = {62--79}
}
```

### Domain Literature Gaps
- Should cite Duchini et al. (2020) on Italian pay transparency
- Should cite Gulyas et al. (2023) on Austrian reporting requirements
- Should engage more with wage posting literature (Hall-Krueger, etc.)

---

## 5. WRITING QUALITY

### Strengths
- Clear, professional prose throughout
- Well-structured narrative arc
- Introduction effectively motivates the question
- Technical methods explained accessibly
- Good use of transitions between sections

### Weaknesses
- Some repetition between Introduction and Results
- Discussion section could be more speculative about mechanisms
- Some paragraphs in Robustness section are thin

**Writing Assessment: PASS - Minor polish needed**

---

## 6. CONSTRUCTIVE SUGGESTIONS

### To Strengthen the Paper

1. **HonestDiD Analysis (ESSENTIAL)**
   - Run Rambachan-Roth sensitivity analysis
   - Show bounds on ATT under various violations of parallel trends
   - This directly addresses the t=-3 pre-trend concern

2. **Bacon Decomposition**
   - Show which 2x2 comparisons drive the TWFE estimate
   - Helps readers understand whether results are driven by sensible comparisons

3. **Triple-Difference Design**
   - Use self-employed workers as within-state control group
   - They're in same state, same time, but not subject to transparency laws
   - Would strengthen identification considerably

4. **Firm Size Threshold RDD**
   - Several laws have firm size thresholds (15+, 50+, etc.)
   - RDD using administrative data could provide cleaner identification

5. **Posted Wage Analysis**
   - Complement realized wage analysis with job posting data
   - Indeed, Glassdoor, or Burning Glass data on posted ranges
   - Would help distinguish wage compression from composition effects

### Framing Improvements

1. Lead with the surprising result: transparency LOWERS wages
2. Better connect to Cullen-Pakzad-Hurson equilibrium model
3. Discuss welfare implications more thoroughly
4. Consider "wage compression vs. wage reduction" framing

---

## 7. OVERALL ASSESSMENT

### Key Strengths
1. Novel and policy-relevant research question
2. Appropriate modern DiD methodology (Sun-Abraham)
3. Comprehensive heterogeneity analysis
4. Clear, professional writing
5. Surprising and provocative findings

### Critical Weaknesses
1. **Pre-trend violation at t=-3 is a major threat to identification**
2. No sensitivity analysis to address parallel trends concerns
3. Missing some important literature citations
4. No placebo using self-employed or other unaffected groups

### Required Revisions for Acceptance
1. Add HonestDiD sensitivity analysis showing bounds under PT violations
2. Add Bacon decomposition showing comparison weights
3. Discuss triple-diff using self-employed as placebo more seriously
4. Add missing citations (Rambachan-Roth, Borusyak et al., Athey-Imbens)

---

## DECISION: MAJOR REVISION

The paper addresses an important and timely question with appropriate methodology. However, the significant pre-trend violation at t=-3 is a serious threat to the causal interpretation. The paper cannot be published without formally addressing parallel trends concerns through HonestDiD sensitivity analysis or alternative identification strategies. The methodological framework is sound, and with these additions, the paper could make a meaningful contribution.

DECISION: MAJOR REVISION
