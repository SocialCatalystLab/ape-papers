# Internal Review Round 1 - Claude Code (Reviewer 2 Role)

**Paper:** Urban-Rural Heterogeneity in the Labor Market Effects of Women's Suffrage
**Date:** 2026-01-21
**Reviewer:** Claude Code (Internal Review)

## Overall Assessment

This paper examines the effects of women's suffrage on female labor force participation using staggered difference-in-differences methods applied to IPUMS full-count census data (1880-1920). The central finding is surprising and potentially important: contrary to the policy channel hypothesis that predicted urban effects would dominate, the paper finds that suffrage effects are **larger in rural areas** than in urban areas.

**Verdict: MINOR REVISION**

The paper is well-written, methodologically sound, and presents an interesting puzzle. However, several issues need to be addressed before external submission.

---

## Major Issues

### 1. Urban Classification is Imputed, Not Observed

**Problem:** The paper uses probabilistic imputation of urban status based on state-year urbanization rates. This means individual urban/rural classification contains measurement error by construction. The heterogeneity finding (larger rural effects) is vulnerable to concerns about misclassification.

**Required Action:**
- Add explicit discussion in Data section about how urban status was assigned
- Report sensitivity analysis using different urbanization thresholds (e.g., what if we classify everyone as rural in states with <30% urbanization?)
- Consider bootstrapped standard errors that account for imputation uncertainty

### 2. LABFORCE Variable Availability

**Problem:** The paper constructs labor force participation from OCC1950 rather than LABFORCE because LABFORCE is not available for the 1900 census. While the paper mentions using OCC1950-based measures, it does not adequately discuss how this affects comparability across census years.

**Required Action:**
- Add explicit discussion in Data section about why LABFORCE is unavailable for 1900
- Report the correlation between OCC1950-based and LABFORCE-based measures for years where both are available
- Discuss potential bias if the OCC1950-based measure differs systematically from LABFORCE

### 3. Pre-Trends in Event Study

**Problem:** The event study figures show coefficients at very long pre-treatment horizons (-30 to -38 years). At these horizons, only Wyoming and Utah contribute (adopted 1869-1870), and these states have no pre-treatment census data. The event study may not adequately test parallel trends for the states that actually identify the effect.

**Required Action:**
- Focus event study discussion on event times that have adequate sample sizes
- Report which treatment cohorts contribute to each event time
- Consider separate event studies for "late adopters" with multiple pre-periods

---

## Minor Issues

### 4. Statistical Significance

Several key estimates approach but do not achieve statistical significance at conventional levels:
- Main TWFE effect: p = 0.054
- Urban effect: p = 0.106

The paper should be more cautious in language about these results. "Approaching significance" is not "significant."

### 5. Missing Table and Figure References

The compiled PDF shows undefined references for several tables and figures (tab:summary, tab:stratified, fig:event_study_overall). These need to be fixed.

### 6. Robustness Section is Empty

The file `sections/07_robustness.tex` appears to be empty or minimal. Given the surprising nature of the findings, a thorough robustness section is essential.

### 7. Mechanisms Section

The mechanisms section (06_mechanisms.tex) needs to be populated with actual analysis of potential channels.

---

## Suggestions for Improvement

1. **Strengthen the "surprising finding" narrative:** The paper's central contribution is documenting that rural effects dominate urban effects. This should be highlighted more prominently in the abstract and introduction.

2. **Add placebo tests:** Run the same analysis on men, who could already vote. A null effect would strengthen causal interpretation.

3. **Discuss alternative interpretation more carefully:** The ceiling effects interpretation (urban women already participating at higher rates) is plausible but needs more careful treatment. What were baseline participation rates in urban vs rural areas?

4. **Consider Bacon decomposition:** Report the Goodman-Bacon decomposition to show which comparisons drive the estimates.

---

## Required Revisions Before External Submission

1. Fix undefined references
2. Add discussion of urban imputation methodology
3. Add discussion of OCC1950-based LFP measure
4. Populate robustness section with:
   - Alternative urbanization thresholds
   - Excluding early adopters
   - Male placebo
5. Fix event study interpretation to focus on well-identified event times

---

## Detailed Comments

**Introduction:**
- Line 6: "approximately 2.3 percentage points" - should specify this is the overall effect, not the rural effect which is larger
- Consider adding the surprising finding (rural > urban) to the abstract

**Data Section:**
- Need explicit statement: "The LABFORCE variable is not available for the 1900 census. We therefore construct labor force participation from occupation codes..."
- Need explicit statement: "We assign urban status probabilistically based on historical state-year urbanization rates from..."

**Results Section:**
- Table 2 reference (tab:main_results) is undefined
- Table 3 reference (tab:stratified) is undefined
- Figure references are undefined
- The discussion of pre-trends should note which cohorts contribute to each event time

**Discussion:**
- The interpretation section is thorough and well-reasoned
- The limitations section appropriately acknowledges measurement issues

---

## Summary

The paper documents an interesting and surprising finding about the effects of women's suffrage on female labor force participation. The finding that rural effects dominate urban effects challenges the prevailing policy channel hypothesis. However, the paper needs revisions to address measurement concerns (urban imputation, OCC1950-based LFP) and to fix technical issues (undefined references, empty sections) before external submission.

**Recommendation:** Address the required revisions and resubmit for Round 2 internal review.
