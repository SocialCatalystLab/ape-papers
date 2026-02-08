# Internal Review - Round 1

**Reviewer:** Claude Code (Internal Review)
**Paper:** High on Employment? A Spatial Difference-in-Discontinuities Analysis of Marijuana Legalization and Industry-Specific Labor Market Effects
**Date:** 2026-02-04

---

## PART 1: CRITICAL REVIEW

### Format and Presentation

The paper is well-structured with clear sections following standard economics formatting. Tables and figures are properly labeled with informative captions. The LaTeX compilation appears clean with no broken references in the main regression tables (Tables 2-6).

**Issues:**
- The paper is appropriately detailed at 25+ pages of main text (ending at `\label{apep_main_text_end}` on page 25).

### Statistical Methodology

**Strengths:**
- The DiDisc design is well-motivated and appropriate for the research question
- Multiple hypothesis correction (Benjamini-Hochberg FDR) properly applied to industry results
- Wild cluster bootstrap addresses the small-cluster problem (8 clusters)
- Extensive robustness checks across bandwidths, polynomial orders, and sample restrictions

**Concerns:**
1. **Treatment timing heterogeneity**: Colorado opened retail Q1 2014, Washington opened Q3 2014. The paper uses a single $P_t$ indicator but doesn't clearly explain how this accommodates the staggered timing. For Washington border pairs, Q1-Q2 2014 are pre-treatment periods, but the paper's description of "2014-2019 as post-treatment" is ambiguous. This appears to be handled correctly in practice (the WA-OR analysis is restricted to post-Q3 2014), but the exposition could be clearer.

2. **Event study interpretation**: Figure 3 shows the event study with coefficients normalized to e=-1. The text states pre-treatment coefficients "oscillate around zero" ranging from -0.12 to +0.04. A coefficient of -0.12 at e=-12 suggests a 12% gap relative to e=-1, which is economically meaningful. While technically consistent with parallel trends if not statistically significant, this warrants discussion.

3. **Cluster count**: 8 clusters is borderline for cluster-robust inference. The paper acknowledges this and provides wild bootstrap p-values, which is appropriate.

### Identification Strategy

**Strengths:**
- The DiDisc design elegantly differences out pre-existing level differences at borders
- Temporal placebo tests validate the identifying assumption (all 8 placebos insignificant)
- Geographic heterogeneity across 8 diverse border pairs supports external validity

**Concerns:**
1. **Local Average Treatment Effect (LATE) interpretation**: The paper correctly notes that effects are identified only at borders, not statewide. However, the policy implications section makes strong claims about "labor market concerns should not be central to the legalization debate" - this extrapolation from border effects to statewide policy relevance should be more cautious.

2. **Oregon contamination**: Oregon legalized in 2015, and the paper restricts WA-OR analysis to Q3 2014-Q2 2015 (4 quarters). This is a very short post-treatment window. The main results pool all borders, which may mix the short WA-OR window with longer windows for other borders.

### Internal Consistency

I verified several consistency checks:
- Abstract reports τ=-3.1%, SE=6.2% → matches Table 2 Column 4
- 95% CI [-15.1%, 9.0%] → computed correctly from -0.031 ± 1.96×0.062
- Industry results (Table 4) report Information τ=-0.130, SE=0.030, p=0.001, q_FDR=0.03 - the math checks out (t=4.33)

**One inconsistency noted by Gemini advisor:**
- The claim that Information has t-stat 4.33 but Figure 5 shows the CI "nearly touching zero" - I would need to see Figure 5 to verify, but the reported numbers in Table 4 are internally consistent.

### Literature Review

The literature review is adequate, citing key papers (Dave et al. 2022, Nicholas et al. 2019, Dube et al. 2010). The paper correctly positions its contribution as providing spatial quasi-experimental evidence with explicit placebo validation.

### Writing Quality

The writing is clear and professional. Technical explanations are accessible. The discussion of null results is appropriately nuanced rather than overselling insignificant findings.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Clarify treatment timing**: Add a sentence in Section 5.1 explicitly stating that $P_t$ is defined relative to each cohort's retail opening date (Q1 2014 for CO borders, Q3 2014 for WA borders).

2. **Event study magnitude**: The e=-12 coefficient of -0.12 is large in magnitude even if insignificant. Consider adding a sentence acknowledging this and noting that the wide confidence interval at long leads is expected with small samples.

3. **Temper policy extrapolation**: The conclusion's claim that "labor market concerns should not be central to the legalization debate" is strong given the LATE interpretation is limited to border regions. Consider softening to "labor market effects at state borders appear minimal."

4. **Information sector puzzle**: The large significant negative effect in Information (-13%) is the paper's most surprising finding. The discussion offers explanations (Utah's Silicon Slopes growth) but could strengthen this with data on tech sector location decisions during 2014-2019.

---

## Summary

This is a solid empirical paper with a well-executed identification strategy and appropriate statistical methods. The main finding (null aggregate effect) is credibly estimated, and the temporal placebo tests provide strong validation of the identifying assumption. The industry heterogeneity results are thoughtfully presented with FDR correction.

The paper's main limitation is inherent to the border design: effects are local to border regions, which may differ from statewide effects if the cannabis industry concentrates in interior locations. The paper acknowledges this limitation transparently.

Minor issues around treatment timing exposition and policy extrapolation could be addressed in revision, but these do not constitute fatal flaws.

**DECISION: MINOR REVISION**
